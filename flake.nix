{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        akuse = pkgs.appimageTools.wrapType2 rec {
          name = "akuse";
          pname = "akuse";
          version = "1.10.1";

          src = pkgs.fetchurl {
            url = "https://github.com/akuse-app/akuse/releases/download/${version}/linux-akuse-${version}.AppImage";
            hash = "sha256-1o+uhD84KmPN9sN6chEOnASj8yyazHOlMCoF/kK5yvE=";
          };

          extraInstallCommands =
            let
              contents = pkgs.appimageTools.extract { inherit pname version src; };
            in
            ''
              install -m 444 -D ${contents}/akuse-beta.desktop -t $out/share/applications
              substituteInPlace $out/share/applications/akuse-beta.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
              cp -r ${contents}/usr/share/icons $out/share
            '';

          meta = with pkgs.lib; {
            description = "Simple and easy to use anime streaming desktop app without ads.";
            homepage = "https://github.com/ThaUnknown/akuse";
            license = licenses.gpl3;
            maintainers = with maintainers; [ aleganza ];
            platforms = [ "x86_64-linux" ];
            mainProgram = "akuse";
          };
        };
      };

      defaultPackage.${system} = self.packages.${system}.akuse;
    };
}