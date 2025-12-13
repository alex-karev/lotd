{
  description = "LOTD - Lord Of The Datasets";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    lib = nixpkgs.lib;
    forEachSystem = lib.genAttrs supportedSystems;
    packageName = "lotd";
    getDependencies = pythonPackages:
      with pythonPackages; [
        torch
        datasets
        tokenizers
        transformers
      ];
  in {
    # Package to build
    packages = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      pythonPackages = pkgs.python312Packages;
      lotd = pythonPackages.buildPythonPackage {
        pname = packageName;
        version = "0.1.0";
        pyproject = true;
        src = ./.;
        build-system = [
          pythonPackages.setuptools
          pythonPackages.wheel
        ];
        dependencies = getDependencies pythonPackages;
        pythonImportsCheck = [packageName];
        meta = with pkgs.lib; {
          description = "Lord of the Datasets - Efficient NLP dataset preprocessing";
          license = licenses.mit;
          homepage = "https://github.com/alex-karev/lotd";
        };
      };
    in {
      lotd = lotd;
      default = lotd;
    });

    # Development shell
    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        name = packageName;
        PYTHONPATH = "${self}/src";
        packages =
          [
            pkgs.python312
            pkgs.python312Packages.twine
            pkgs.python312Packages.build
          ]
          ++ getDependencies pkgs.python312Packages;
      };
    });
  };
}
