{ config, pkgs, unstablePkgs, unstableSys, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  # disabledModules = [ "services/monitoring/netdata.nix" ];
  imports =
    [ # Include the results of the hardware scan.
      # "${unstableSys}/nixos/modules/services/monitoring/netdata.nix"
      ./hardware-configuration.nix
      ../../modules/reasonable-defaults.nix
    ];

  # sops
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "yushamin";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Enable firewall
  networking.firewall = {
    # enable the firewall
    enable = true;
    checkReversePath = "loose";

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [22 80 443];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = let
    nativeLang = "fr_FR.UTF-8";
  in {
    LC_ADDRESS = nativeLang;
    LC_IDENTIFICATION = nativeLang;
    LC_MEASUREMENT = nativeLang;
    LC_MONETARY = nativeLang;
    LC_NAME = nativeLang;
    LC_NUMERIC = nativeLang;
    LC_PAPER = nativeLang;
    LC_TELEPHONE = nativeLang;
    LC_TIME = nativeLang;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  # Enable Nvidia drivers
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.kdeconnect.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };
  
  # instal font
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # Configure console keymap
  console = {
    font = "FiraCode";
    useXkbConfig = true; # use xkbOptions for keymap in tty
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;  # Disabled, pipewire config should take care of this
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable docker
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    daemon.settings = {
      fixed-cidr-v6 = "fd00::/80";
      ipv6 = true;
    };
  };

  services.flatpak.enable = true;

  # Define a user account.
  users.users.hldmna = {
    isNormalUser = true;
    description = "hldmna";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      btop
      firefox
      zsh
    ];
  };

  # Configure SSH Server
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This will regularly tell the SSD which blocks are deleted on the filesystem side,
  # so these blocks can be used for other things by the SSD controller.
  # => Helps SSD performance & lifespan!
  # See: https://en.wikipedia.org/wiki/Trim_(computing)
  services.fstrim.enable = true; # Runs weekly

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    zip
    unzip
    ark
    _7zz
    just
    cudatoolkit
    nvidia-offload
    python310
    tailscale
  ];

  # Enable Netdata
  # Use latest version
  services.netdata = {
    package = unstablePkgs.netdata;
    enable = true;
    config = {
      global = {
        # update interval
        "update every" = 15;
      };
      ml = {
        # enable machine learning
        "enabled" = "yes";
      };
    };
    configDir = {
      "python.d.conf" = pkgs.writeText "python.d.conf" ''
        nvidia_smi: yes
      '';
      "python.d/nvidia_smi.conf" = pkgs.writeText "python.d/nvidia_smi.conf" ''
        loop_mode    : yes
        poll_seconds : 1
        exclude_zero_memory_users : yes
      '';
    };
  };

  # Enable Tailscale
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale;
  sops.secrets.tailscale-authkey = {};
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.tailscale-authkey.path})
    '';
  };

  # Enable Traefik
  services.traefik = {
    enable = true;
    package = unstablePkgs.traefik;
    group = "docker";
    staticConfigFile = "/etc/traefik/traefik.yml";
  };

  system.stateVersion = "22.11";
}
