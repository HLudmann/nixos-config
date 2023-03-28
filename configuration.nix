# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/lenovo/thinkpad/t490>
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "muriel"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hldmna = {
    isNormalUser = true;
    description = "hldmna";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      btop
      cargo
      curl
      firefox
      fzf
      gcc
      git
      gh
      go
      gnumake
      nodejs
      python3
      rustup
      seafile-client
      terraform
      vscode
      wezterm
      wget
      zsh
    ];
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -lh";
      la = "ls -alh";
      l = "ls -Alh";
      nixos-update = "sudo nixos-rebuild switch";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "golang" "rust" "thefuck" "systemadmin"];
      theme = "crunch";
      customPkgs = with pkgs; [
        zsh-git-prompt
        zsh-nix-shell
        zsh-completions
        zsh-command-time
        zsh-fast-syntax-highlighting
        nix-zsh-completions
      ];
    };
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    fprintd
    direnv
    nix-direnv
  ];

  environment.sessionVariables = rec {
    NPM_CONFIG_PREFIX = "~/.npm-global";
  };

  # Direnv config
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
  # if you also want support for flakes
  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Fingerprint reader daemon
  services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090; # (If the vfs0090 Driver does not work, use the following driver)
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
