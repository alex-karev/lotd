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
        version = "0.1.4";
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
        packages =
          [
            pkgs.python312
            pkgs.python312Packages.twine
            pkgs.python312Packages.build
            pkgs.python312Packages.mkdocs
            pkgs.python312Packages.mkdocs-material
            pkgs.python312Packages.mkdocstrings
            pkgs.python312Packages.mkdocstrings-python
          ]
          ++ getDependencies pkgs.python312Packages;
        shellHook = ''
          echo -e "Notes for developer:\n"
          echo -e "Testing: PYTHONPATH=\$PYTHONPATH:./src python examples/*.py"
          echo -e "Preview docs: mkdocs serve"
          echo -e "Update docs:\n\t1. edit docs/*\n\t2. mkdocs build\n\t3. mkdocs gh-deploy"
          echo -e "Update version:\n\t1. update version in pyproject.toml and flake.nix\n\t2. rm -r ./dist\n\t3. python -m build\n\t4. python -m twine upload dist/*"
          echo -e "When adding new features don't forget to change __init__.py"
        '';
      };
    });
  };
}
