# Docs for this file: https://github.com/input-output-hk/iogx/blob/main/doc/api.md#mkhaskellprojectinshellargs
# See `shellArgs` in `mkHaskellProject` in ./project.nix for more details.

{ repoRoot, inputs, pkgs, lib, system }:

# Each flake variant defined in your project.nix project will yield a separate
# shell. If no flake variants are defined, then cabalProject is the original
# project.
cabalProject:

{
  name = "nix-shell";

  packages = [
    pkgs.watchexec
    pkgs.cowsay
    pkgs.ghcid
    pkgs.haskellPackages.ghcide
    pkgs.treefmt
    pkgs.nodePackages.cspell
    pkgs.nodejs
  ];

  shellHook = ''
    export CABAL_DIR=$(pwd)/.CABAL_DIR
    set -o vi
  '';

  tools = {
    # haskellCompilerVersion = cabalProject.args.compiler-nix-name;
    cabal-fmt = null;
    cabal-install = null;
    haskell-language-server = null;
    # haskell-language-server-wrapper = cabalProject.args.hsPkgs.haskell-language-server;cabalProject.args.hsPkgs.haskell-language-server.wrapper;
    fourmolu = null;
    hlint = null;
    # stylish-haskell = null;
    ghcid = repoRoot.nix.patched-ghcid;
    shellcheck = null;
    prettier = null;
    editorconfig-checker = null;
    nixfmt-classic = null;
    # optipng = null;
    # purs-tidy = null;
  };

  preCommit = {
    cabal-fmt.enable = true;
    #   cabal-fmt.extraOptions = "";
    #   stylish-haskell.enable = false;
    #   stylish-haskell.extraOptions = "";
    fourmolu.enable = true;
    #   fourmolu.extraOptions = "";
    #   hlint.enable = false;
    #   hlint.extraOptions = "";
    shellcheck.enable = true;
    #   shellcheck.extraOptions = "";
    #   prettier.enable = false;
    #   prettier.extraOptions = "";
    editorconfig-checker.enable = true;
    #   editorconfig-checker.extraOptions = "";
    nixfmt-classic.enable = true;
    #   nixfmt-classic.extraOptions = "";
    #   optipng.enable = false;
    #   optipng.extraOptions = "";
    #   purs-tidy.enable = false;
    #   purs-tidy.extraOptions = "";
  };
}
