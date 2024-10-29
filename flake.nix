{
  description = "A Nix-flake-based C/C++ development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell.override
          {
            # Override stdenv in order to change compiler:
            # stdenv = pkgs.clangStdenv;
          }
          {
            packages = with pkgs; [
              pkg-config
              ncurses
              jq
              clang-tools
              cmake
              codespell
              conan
              cppcheck
              doxygen
              gtest
              lcov
              vcpkg
              vcpkg-tool
              bear
              lldb
            ] ++ (if system == "aarch64-darwin" then [ ] else [ gdb ]);
          shellHook = ''
            export CFLAGS="$CFLAGS -I${pkgs.ncurses.dev}/include"
            export LDFLAGS="$LDFLAGS -L${pkgs.ncurses}/lib"
            export PATH=$PATH:$PWD/build/Linux/rel/gcc/bin:$PWD/build/Linux/dbg/gcc/bin
          '';
          };
      });
    };
}
