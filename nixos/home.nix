{ pkgs, ... }:

{
  home.username = "phillip";
  home.homeDirectory = "/home/phillip";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    papirus-icon-theme
    bibata-cursors
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtsvg
    catppuccin-kde        # Plasma colour scheme + global theme
    catppuccin-kvantum    # Qt/Kvantum theme
    catppuccin-papirus-folders  # Coloured Papirus folders
  ];

  programs.plasma = {
    enable = true;

    colorSchemes = [ "CatppuccinMochaBlue" ];  # after installing the theme

    workspace = {
      colorScheme = "CatppuccinMochaBlue";
      cursorTheme = "Bibata-Modern-Classic";
      iconTheme = "Papirus-Dark";
      wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/wallpapers/nixos-wallpaper-nineish-dark-gray.png";
    };

    fonts = {
      general = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    };

    panels = [
      {
        location = "top";
        floating = true;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          { 
            name = "org.kde.plasma.icontasks";
            config.General.launchers = [];
          }
          "org.kde.plasma.marginsseperator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    kwin = {
      effects = {
        blur.enable = true;
        desktopSwitching.animation = "slide";
        minimization.animation = "magiclamp";
        translucency.enable = true;
      };
      virtualDesktops = {
        number = 4;
        names = [ "1" "2" "3" "4" ];
      };
    };

    shortcuts = {
      kwin = {
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
      };
    };
  };

  # Kvantum theming
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Catppuccin-Mocha-Blue
  '';
}
