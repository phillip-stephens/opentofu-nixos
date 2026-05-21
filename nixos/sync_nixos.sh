#!/bin/bash
sudo rm /etc/nixos/*
for f in ./*.nix; do sudo ln -sf "$(realpath "$f")" "/etc/nixos/$(basename "$f")"; done
