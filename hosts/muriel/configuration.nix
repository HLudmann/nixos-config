{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "muriel";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
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

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

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
  };

  # Enable docker
  virtualisation.docker.enable = true;

  # Define a user account.
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
      neovim
      nodejs
      python3
      rustup
      seafile-client
      terraform
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

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim 
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
  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];

  system.stateVersion = "22.11";
}
