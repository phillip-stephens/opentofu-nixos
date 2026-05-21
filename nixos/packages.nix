{ config, pkgs, ... }:

{
  # ── System packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Essentials
    git
    vim
    curl
    wget
    htop
    tmux
    jq

    # Diagnostics
    lsof
    strace
    tcpdump
    netcat-gnu

    # Nix helpers
    nix-tree
    nvd 

    tailscale
  ];

  # ── Shell ──────────────────────────────────────────────────────────────────
  programs.bash.enableCompletion = true;
  environment.variables.EDITOR   = "vim";
}
