{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # Define the system architecture
      system = "x86_64-linux";

      # Import nixpkgs for the specified system
      pkgs = import nixpkgs { inherit system; };

      # Define the akuse package
      akuse = pkgs.appimageTools.wrapType2 rec {
        name = "akuse";
        pname = "akuse";
        version = "1.10.1";

        # Fetch the AppImage from the GitHub releases
        src = pkgs.fetchurl {
          url = "https://github.com/akuse-app/akuse/releases/download/${version}/linux-akuse-${version}.AppImage";
          hash = "sha256-1o+uhD84KmPN9sN6chEOnASj8yyazHOlMCoF/kK5yvE=";
        };

        # Additional installation commands to handle desktop file and icons
        extraInstallCommands =
          let
            contents = pkgs.appimageTools.extract { inherit pname version src; };
          in
          ''
            install -m 444 -D ${contents}/akuse-beta.desktop -t $out/share/applications
            substituteInPlace $out/share/applications/akuse-beta.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
            cp -r ${contents}/usr/share/icons $out/share
          '';

        # Package metadata
        meta = with pkgs.lib; {
          description = "Simple and easy to use anime streaming desktop app without ads.";
          homepage = "https://github.com/ThaUnknown/akuse";
          license = licenses.gpl3;
          maintainers = with maintainers; [ aleganza ];
          platforms = [ "x86_64-linux" ];
          mainProgram = "akuse";
        };
      };
    in
    {
      # Define the packages for the specified system
      packages.${system} = {
        inherit akuse;
      };

      # Set the default package to akuse
      defaultPackage.${system} = self.packages.${system}.akuse;
    };
}