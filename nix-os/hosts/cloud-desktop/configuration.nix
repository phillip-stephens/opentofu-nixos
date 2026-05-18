{ pkgs, ... }: {
  networking.hostName = "cloud-nixos";
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFKKfkv3C6sDntua03IdR1jBxxvFSyfmq7MAPJ9i+rV stanford"
  ];

  system.stateVersion = "25.05";
}
