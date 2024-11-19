{
  description = "A basic flake to with flake-parts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{
      self,
      systems,
      nixpkgs,
      treefmt-nix,
      flake-parts,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ treefmt-nix.flakeModule ];
      systems = import inputs.systems;

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          stdenv = pkgs.stdenv;
          sbcl = pkgs.sbcl;
          version = "0.2.1";

          ciel = sbcl.buildASDFSystem {
            pname = "CIEL";
            inherit version;

            nativeLibs = with pkgs; [
              zstd
              inotify-tools
            ];

            lispLibs = with pkgs.sbclPackages; [
              access
              alexandria
              arrow-macros
              bordeaux-threads
              cl-ansi-text
              cl-ansi-text
              cl-cron
              cl-csv
              cl-ftp
              cl-ppcre
              cl-reexport
              clesh

              clingon
              closer-mop
              cmd
              dbi
              defstar
              dexador
              dissect
              easy-routes
              fiveam
              for
              fset
              generic-cl
              hunchentoot
              local-time
              log4cl
              lparallel
              lquery
              nodgui
              metabang-bind
              modf
              named-readtables
              parse-float
              parse-number
              printv
              pythonic-string-reader
              quicksearch
              quri
              repl-utilities
              serapeum
              shasht
              shlex
              spinneret
              secret-values
              str
              sxql
              trivia
              trivial-arguments
              trivial-do
              trivial-monitored-thread
              trivial-package-local-nicknames
              trivial-types
              vgplot
              which
            ];

            systems = [
              "ciel"
              "ciel/repl"
            ];

            src = pkgs.fetchFromGitHub {
              owner = "ciel-lang";
              repo = "CIEL";
              rev = "v${version}";
              # rev = "master";
              hash = "sha256-m+tZ28Yd212Ud15Ba9cHost8payKzeyqqF4rPlDOMy4=";
            };
          };

          sbcl' = sbcl.withOverrides (
            self: super: {
              inherit ciel;
            }
          );

          lisp = sbcl'.withPackages (ps: [ ps.ciel ]);
        in
        rec {
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
            };

            settings.formatter = { };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nil
            ];
          };

          # packages.default = sbcl';
          packages.default = lisp;
        };
    };
}
