{ config, pkgs, ... }:

{

  # config src: https://github.com/sarcasticadmin/sodaflake
  # sanity
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  networking = {
    hostName = "nixos";
    firewall.enable = false;
    # all interfaces using dhcp
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Define a user account
  # were setting an initial password that is overridden but cloud-init
  users.users.user = {
    isNormalUser = true;
    description = "SODA user";
    extraGroups = [ "wheel" ];
    # cloud-init will override this on boot
    initialPassword = "sodamachine";
  };

  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neofetch
    vim
    git
  ];

  # Purge nano from being the default
  # youre in my world now, grandma
  environment.variables = { EDITOR = "vim"; };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # Theres a lot of cloud-init that doesnt work on nixos since its in conflict with
  # the declarative nixos config and theres some assumptions about where shells should
  # be in the cloud-init code. As an example bootcmd expects /bin/sh
  services.cloud-init = {
    enable = true;
    config = ''
      disable_ec2_metadata: True
      datasource_list: [ "NoCloud" ]
      # The modules that run in the 'init' stage
      cloud_init_modules:
        - seed_random
        - write-files
        - cc_set_passwords
    '';
  };

  # disabling for speed
  documentation.enable = false;
  # stateVersion should move along with nixos version
  system.stateVersion = config.system.nixos.version;
}
