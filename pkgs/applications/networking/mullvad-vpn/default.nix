{ stdenv, lib, fetchurl, dpkg
, alsa-lib, atk, cairo, cups, dbus, expat, fontconfig, freetype
, gdk-pixbuf, glib, gnome2, pango, nspr, nss, gtk3, mesa
, xorg, autoPatchelfHook, systemd, libnotify, libappindicator
}:

let deps = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gnome2.GConf
    pango
    gtk3
    libappindicator
    libnotify
    mesa
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxshmfence
    nspr
    nss
    systemd
  ];

in

stdenv.mkDerivation rec {
  pname = "mullvad-vpn";
  version = "2021.6";

  src = fetchurl {
    url = "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/MullvadVPN-${version}_amd64.deb";
    sha256 = "0vpahryw4hm1k9p4vang84ji88znz67s7wxnwqndf02a627n7fcm";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = deps;

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "dpkg-deb -x $src .";

  runtimeDependencies = [ (lib.getLib systemd) libnotify libappindicator ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mullvad $out/bin

    mv usr/share/* $out/share
    mv usr/bin/* $out/bin
    mv opt/Mullvad\ VPN/* $out/share/mullvad

    sed -i 's|"\/opt\/Mullvad.*VPN|env MULLVAD_DISABLE_UPDATE_NOTIFICATION=1 "'$out'/bin|g' $out/share/applications/mullvad-vpn.desktop

    ln -s $out/share/mullvad/mullvad-{gui,vpn} $out/bin/
    ln -s $out/share/mullvad/resources/mullvad-daemon $out/bin/mullvad-daemon
    ln -sf $out/share/mullvad/resources/mullvad-problem-report $out/bin/mullvad-problem-report

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/mullvad/mullvadvpn-app";
    description = "Client for Mullvad VPN";
    changelog = "https://github.com/mullvad/mullvadvpn-app/blob/${version}/CHANGELOG.md";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ Br1ght0ne ymarkus flexagoon ];
  };

}
