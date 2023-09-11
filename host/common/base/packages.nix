{ pkgs, ... }: {
  basePackages = with pkgs; [
    _1password
    agenix
    bat
    binutils
    curl
    dig
    dua
    duf
    unstable.eza
    fd
    file
    git
    gotop
    helix
    htop
    jq
    killall
    pciutils
    ripgrep
    rsync
    traceroute
    tree
    unzip
    usbutils
    vim
    wget
    yq-go
  ];
}
