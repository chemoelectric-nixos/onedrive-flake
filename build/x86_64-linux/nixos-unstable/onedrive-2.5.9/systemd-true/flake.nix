# Copyright (c) 2003-2025 Eelco Dolstra and the Nixpkgs/NixOS contributors
# Copyright (c) 2025, 2026 Barry Schwartz
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{
  description = "A Nix flake for abraunegg/onedrive";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      withSystemd = true;
      owner = "abraunegg";
      pname = "onedrive";
      version = "2.5.9";

      hash-for =
        version:
        if version == "2.5.6" then
          "sha256-AFaz1RkrtsdTZfaWobdcADbzsAhbdCzJPkQX6Pa7hN8="
        else if version == "2.5.7" then
          "sha256-IllPh4YJvoAAyXDmSNwWDHN/EUtUuUqS7TOnBpr3Yts="
        else if version == "2.5.9" then
          "sha256-Vrr7KR4yMH+IZ56IUTp9eAhxEtiXx+ppleUd7jSLzxc="
        else
          "";
    in
    {
      packages.x86_64-linux = rec {

        default = onedrive;

        onedrive = pkgs.stdenv.mkDerivation (var: {
          name = pname + "-" + version;
          pname = pname;
          version = version;
          src = pkgs.fetchFromGitHub {
            owner = owner;
            repo = pname;
            rev = "refs/tags/v${version}";
            hash = hash-for version;
          };
          nativeBuildInputs = [
            pkgs.autoreconfHook
            pkgs.coreutils
            pkgs.installShellFiles
            pkgs.dmd
            pkgs.pkg-config
          ];
          buildInputs = [
            pkgs.curl
            pkgs.dbus
            pkgs.libnotify
            pkgs.sqlite
          ]
          ++ lib.optionals withSystemd [ pkgs.systemd ];

          configureFlags = [
            (lib.enableFeature true "notifications")
            (lib.withFeatureAs withSystemd "systemdsystemunitdir" "${placeholder "out"}/lib/systemd/system")
            (lib.withFeatureAs withSystemd "systemduserunitdir" "${placeholder "out"}/lib/systemd/user")
          ];

          # we could also pass --enable-completions to configure but
          # we would then have to figure out the paths manually and
          # pass those along.
          postInstall = ''
            installShellCompletion --cmd onedrive \
              --bash contrib/completions/complete.bash \
              --fish contrib/completions/complete.fish \
              --zsh contrib/completions/complete.zsh
          ''
          + (
            if version == "2.5.6" then
              ''
                for s in $out/lib/systemd/user/onedrive.service $out/lib/systemd/system/onedrive@.service; do
                  substituteInPlace $s \
                    --replace-fail "/usr/bin/sleep" "${pkgs.coreutils}/bin/sleep"
                done
              ''
            else
              ""
          );

          passthru = {
            tests.version = pkgs.testers.testVersion {
              package = var.finalPackage;
              version = "v${version}";
            };
          };

          meta = {
            homepage = "https://github.com/abraunegg/onedrive";
            description = "Complete tool to interact with OneDrive on Linux";
            license = lib.licenses.gpl3Only;
            mainProgram = pname;
            platforms = lib.platforms.linux;
          };
        });

      };
    };
}
