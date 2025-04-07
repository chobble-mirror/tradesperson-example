{
  inputs = {
    nixpkgs.url = "nixpkgs";
    chobble-template = {
      url = "git+https://git.chobble.com/chobble/chobble-template.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      chobble-template,
    }:
    let
      systems = [
        "x86_64-linux"
        #"aarch64-linux"
        #"x86_64-darwin"
        #"aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          sourcePrep = pkgs.runCommand "chobble-template-source" { } ''
            mkdir -p $out
            ${pkgs.rsync}/bin/rsync \
              --delete \
              --recursive \
              --exclude="/test" \
              --exclude="*.md" \
              "${chobble-template}/" $out/

            ${pkgs.rsync}/bin/rsync \
              --recursive \
              --exclude="*.nix" \
              --exclude="README.md" \
              "${self}/" $out/src/
          '';

          importedFlake = import "${sourcePrep}/flake.nix";
          outputs = importedFlake.outputs {
            self = sourcePrep;
            nixpkgs = nixpkgs;
          };
          finalBuild = outputs.packages.${system}.site;
        in
        {
          default = finalBuild;
          site = finalBuild;
        }
      );
    };
}
