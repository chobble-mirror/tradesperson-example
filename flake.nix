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
              ${pkgs.rsync}/bin/rsync -a --update \
                --exclude="*.md" \
                --exclude="src/images/*" \
                ${chobble-template}/ ./

              mkdir -p src/images
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
