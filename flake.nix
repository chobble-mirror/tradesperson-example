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
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        let
          templatePackages = chobble-template.packages.${system};
          pkgs = nixpkgs.legacyPackages.${system};
          newSite = pkgs.stdenv.mkDerivation {
            name = "chobble-template-site";
            src = ./.;
            buildInputs = templatePackages.site.buildInputs;
            dontPatchShebangs = true;
            phases = [
              "unpackPhase"
              "setupTemplatePhase"
              "configurePhase"
              "buildPhase"
              "installPhase"
            ];
            setupTemplatePhase = ''
              cp -r ${chobble-template}/* ./
              cp -r ${chobble-template}/.[!.]* ./ 2>/dev/null || true
              find src -name "*.md" -type f -delete
              rm -rf src/images/*
            '';
            configurePhase = templatePackages.site.configurePhase;
            buildPhase = templatePackages.site.buildPhase;
            installPhase = templatePackages.site.installPhase;
            dontFixup = true;
          };
        in
        {
          site = newSite;
          default = newSite;
        }
      );
      devShells = chobble-template.devShells;
    };
}
