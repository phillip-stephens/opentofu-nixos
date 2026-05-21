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

  # Enable Plasma 6
services.udisks2.enable = lib.mkForce true; # Need to do this for Plasma to work with AWS AMI
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;   # or remove this for X11
  };

  # Enable XRDP
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";  # XRDP works best with X11
    openFirewall = false;  # Don't expose to public internet
  };

  # Only allow RDP through Tailscale interface
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3389 ];
  # ── State version (do not change after first deploy) ──────────────────────
  system.stateVersion = "25.11";
}
