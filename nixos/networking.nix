{ config, pkgs, lib, ... }:

{
  # ── Hostname ───────────────────────────────────────────────────────────────
  networking.hostName = "nixos-aws";

  # ── Firewall ───────────────────────────────────────────────────────────────
  networking.firewall = {
    enable       = true;
    allowedTCPPorts = [ 22 ];
  };

  # ── SSH hardening ──────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin             = lib.mkForce "no";
      PasswordAuthentication      = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding               = false;
      # Restrict ciphers/MACs to modern algorithms
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
    # Keep idle connections alive
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 3
    '';
  };
  # Enable Tailscale
  services.tailscale.enable = true;

  # Open the firewall for Tailscale
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # If you want to allow traffic forwarding (exit node / subnet router):
    # checkReversePath = "loose";
  };
}
