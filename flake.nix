{
  description = "Flake for odin project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
      {
      devShells.${system}.default = pkgs.mkShell {
        LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${
        pkgs.lib.makeLibraryPath [
          # for raylib and openGL
          pkgs.libGL
          pkgs.xorg.libX11
          pkgs.xorg.libXi

          pkgs.glfw
        ]
      }";
        buildInputs = [
          (pkgs.odin.overrideAttrs (finalAttr: prevAttr: {

            src = pkgs.fetchFromGitHub {
              owner = "odin-lang";
              repo = "Odin";
              rev = "dev-2024-09"; # version of the branch
              hash = "sha256-GpmmTGM+5pcCCSwShbpIJPV9KMNqGeY4TKT5BBDqUu0=";
              # name = "${finalAttr.pname}-${finalAttr.version}"; # not gona work .
            };

            preBuild = ''

                 echo "# for use of STB libraries"
                 cd vendor/stb/src
                 make
                 cd ../../..

                 '';

          }))
          pkgs.glfw
             # x11 and raylib stuff
          pkgs.glxinfo
          pkgs.lld
          pkgs.gnumake
          pkgs.xorg.libX11.dev
          pkgs.xorg.libX11
          pkgs.xorg.libXft
          pkgs.xorg.libXi
          pkgs.xorg.libXinerama
          pkgs.libGL
          # needed for raylib
          pkgs.xorg.libXcursor
          pkgs.xorg.libXrandr
          pkgs.xorg.libXinerama
        ];
      };
    };
}
