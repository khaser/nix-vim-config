{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    sway-vim-kbswitch = {
      url = "github:khaser/sway-vim-kbswitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sway-vim-kbswitch }@inputs: {

    lib.vim = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
      pkgs.callPackage ./vim.nix {
        sway-vim-kbswitch = sway-vim-kbswitch.defaultPackage.x86_64-linux;
      };

  };
}
