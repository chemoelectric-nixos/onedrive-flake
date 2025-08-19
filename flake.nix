{
  description = "A Nix flake for abraunegg/onedrive";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        withSystemd = true;
        lib = nixpkgs.lib;
        owner = "abraunegg";
        pname = "onedrive";
        version = "2.5.6";
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      rec {
        packages.onedrive = pkgs.stdenv.mkDerivation (var: {
          name = pname + "-" + version;
          pname = pname;
          version = version;
          src = pkgs.fetchFromGitHub {
            owner = owner;
            repo = pname;
            rev = "refs/tags/v${version}";
            hash = "sha256-AFaz1RkrtsdTZfaWobdcADbzsAhbdCzJPkQX6Pa7hN8=";
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

            for s in $out/lib/systemd/user/onedrive.service $out/lib/systemd/system/onedrive@.service; do
              substituteInPlace $s \
                --replace-fail "/usr/bin/sleep" "${pkgs.coreutils}/bin/sleep"
            done
          '';

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
        packages.default = packages.onedrive;
      }
    );
}
