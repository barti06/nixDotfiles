{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    clang
    clang-tools
    lldb
    lld
    llvm

    cmake
    cmake-language-server
    cmake-format
    ninja

    python3
    cargo

    lazygit
    lua-language-server
    pyright
    bash-language-server
    nixd

    mesa-demos

    rustup

    jdk
    jdt-language-server
    maven

    netbeans

    antigravity-cli
  ];
}
