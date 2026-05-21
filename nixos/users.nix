{ config, pkgs, ... }:

{
  # ── Admin user ────────────────────────────────────────────────────────────
  users.users.phillip = {
    isNormalUser   = true;
    description    = "Admin user";
    extraGroups    = [ "wheel" "users" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFKKfkv3C6sDntua03IdR1jBxxvFSyfmq7MAPJ9i+rV stanford"
    ];
  };

  # ── Root login via key only (no password) ─────────────────────────────────
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.phillip.openssh.authorizedKeys.keys;

  # ── sudo without password for wheel ───────────────────────────────────────
  security.sudo.wheelNeedsPassword = false;

  # ── Disable password auth globally ────────────────────────────────────────
  users.mutableUsers = false;
}
