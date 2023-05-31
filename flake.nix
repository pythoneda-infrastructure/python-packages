{
  description = "Infrastructure layer of PythonEDA Python Packages";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda = {
      url = "github:pythoneda/base/0.0.1a7";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "flake-utils";
    };
    pythoneda-infrastructure-base = {
      url = "github:pythoneda-infrastructure/base/0.0.1a5";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "flake-utils";
    };
    pythoneda-python-packages = {
      url = "github:pythoneda/python-packages/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description = "Infrastructure layer of Pythoneda Python Packages";
        license = pkgs.lib.licenses.gpl3;
        homepage =
          "https://github.com/pythoneda-infrastructure/python-packages";
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-infrastructure-python-packages =
            pythonPackages.buildPythonPackage rec {
              pname = "pythoneda-infrastructure-python-packages";
              version = "0.0.1a3";
              src = ./.;
              format = "pyproject";

              nativeBuildInputs = [ pkgs.poetry ];

              propagatedBuildInputs = with pythonPackages; [
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base
                pythoneda-python-packages.packages.${system}.pythoneda-python-packages
              ];
              pythonImportsCheck = [ ];

              meta = with pkgs.lib; {
                inherit description license homepage maintainers;
              };
            };
          default = packages.pythoneda-infrastructure-python-packages;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}
