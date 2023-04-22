{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> {};
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  disabledModules = [ "services/monitoring/netdata.nix" ];
  imports =
    [ # Include the results of the hardware scan.
      <nixos-unstable/nixos/modules/services/monitoring/netdata.nix>
      ./hardware-configuration.nix
      ../../modules/reasonable-defaults.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "yushamin";

  # Enable networking
  networking.networkmanager.enable = true;

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
  services.xserver.videoDrivers = [ "nvidia" ];
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
  virtualisation.docker.enable = true;

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
  ];

  # Enable Netdata
  # Use latest version
  nixpkgs.config.packageOverrides = pkgs: {
    inherit (unstable) netdata;
  };
  services.netdata = {
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

  system.stateVersion = "22.11";
}
