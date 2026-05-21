{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ./users.nix
    ./networking.nix
    ./packages.nix
  ];

  # ── Time & Locale ─────────────────────────────────────────────────────────
  time.timeZone              = "Pacific/Auckland";
  i18n.defaultLocale         = "en_US.UTF-8";

  # ── Nix settings ──────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };

  systemd.services.amazon-init.enable = false; 

programs.git = {
  enable = true;
  config = {
    user.name = "Phillip Stephens";
    user.email = "phillip@cs.stanford.edu";
  };
};
  # ── State version (do not change after first deploy) ──────────────────────
  system.stateVersion = "25.11";
}
