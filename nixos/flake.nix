{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, plasma-manager, home-manager, ... }: {
    nixosConfigurations.nixos-aws = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.phillip = {
            imports = [
              plasma-manager.homeManagerModules.plasma-manager
              ./home.nix
            ];
          };
        }
      ];
    };
  };
}
