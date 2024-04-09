# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ config
, pkgs
, ...
}:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  python =
    let
      packageOverrides = self:
        super: {
          opencv4 = super.opencv4.override {
            enableGtk2 = true;
            gtk2 = pkgs.gtk2;
            #enableFfmpeg = true; #here is how to add ffmpeg and other compilation flags
            #ffmpeg_3 = pkgs.ffmpeg-full;
          };
        };
    in
    pkgs.python3.override { inherit packageOverrides; self = python; };
in
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ./cachix.nix

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-25.9.0"
        "electron-19.1.9"
        "nix-2.16.2"
      ];
    };
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  # nix.nixPath = ["/etc/nix/path"];
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
    trusted-users = [ "root" "sean" ];
  };

  # FIXME: Add the rest of your current configuration
  # Enable networking
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;


  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  services.printing.drivers = [ pkgs.cnijfilter2 ];

  # Hardrive stuff
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  # hardware.pulseaudio.support32Bit = true;
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  services.pipewire.audio.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.wireplumber.enable = true;

  # Power management
  powerManagement.enable = true;
  services.thermald.enable = true;

  # GPU hardware acceleration
  hardware.opengl.extraPackages = [
    pkgs.intel-compute-runtime
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # TODO: Set your hostname
  networking.hostName = "heisenberg";

  # TODO: This is just an example, be sure to use whatever bootloader you prefer

  boot.kernelModules = [ "fuse" "kvm-intel" "coretemp" "i915.force_probe=8a56" ];
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  '';

  hardware.enableAllFirmware = true;

  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "bira";
        plugins = [
          "sudo"
          "per-directory-history"
          "python"
          "direnv"
          "colorize"
          "git"
          "gnu-utils"
          "mix"
          "mix-fast"
        ];
      };
    };
    xfconf = {
      enable = true;
    };
  };

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    sean = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "password";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "networkmanager" "wheel" "kvm" "libvertd" "podman" "audio" "video" ];
      shell = pkgs.zsh;
    };
  };

  environment.systemPackages =
    with pkgs;
    let
      RStudio-with-my-packages = rstudioWrapper.override {
        packages = with rPackages; [ tidyverse snakecase ];
      };
    in
    [
      intel-ocl
      RStudio-with-my-packages
      wget
      elixir-ls
      unstable.elixir
      unstable.erlang
      python3Full
      jupyter-all
      firefox
      thunderbird
      unstable.vscode
      mlt
      kdenlive
      audacity
      libreoffice
      obsidian
      git
      nodejs
      ffmpeg_5-full
      glaxnimate
      intel-media-driver
      intel-vaapi-driver
      fuse
      inkscape
      gimp
      meld
      gnome.gnome-tweaks
      oh-my-zsh
      rclone
      arion
      docker-client
      ollama
      obs-studio
      gnome-extension-manager
      pulseaudioFull
      pavucontrol
      exiftool
      digikam
      spotify
      livebook
      canon-cups-ufr2
      carps-cups
      cnijfilter2
      busybox
      vlc
      freecad
      gcc
      inotify-tools
      dig
      unstable.direnv
      pgadmin4-desktopmode
      gparted
      etcher
      dupeguru
      unstable.maptool
      nixpkgs-fmt
      openmw
      nixd
      handbrake
      (python3.withPackages (ps: with ps; [
        opencv4
      ]))
      R
      qtcreator
    ];

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };


  virtualisation.docker.enable = false;
  virtualisation.podman.dockerSocket.enable = true;

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
