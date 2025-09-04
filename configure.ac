#
# Copyright © 2025 Barry Schwartz
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License, as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received copies of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
#

AC_PREREQ([2.72])
AC_INIT([onedrive-flake],[1.0.2])

AC_CONFIG_SRCDIR([this.is.onedrive-flake])
AC_CONFIG_AUX_DIR([build-aux])

AC_PROG_MKDIR_P
AC_PROG_SED
AC_CHECK_PROGS([NIXFMT],[nixfmt])

onedrive_versions='2.5.6'
nixpkgs_versions='release-25.05 nixos-unstable'
systems='x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin'

AC_ARG_VAR([SYSTEM],[such as "x86_64-linux aarch64-linux" (space separated)])
if test "${ac_cv_env_SYSTEM_set}" != set; then
   SYSTEM="${systems}"
fi

AC_ARG_VAR([NIXPKGS_VERSION],[such as "release-25.05 nixos-unstable" (space separated)])
if test "${ac_cv_env_NIXPKGS_VERSION_set}" != set; then
   NIXPKGS_VERSION="${nixpkgs_versions}"
fi

AC_ARG_VAR([ONEDRIVE_VERSION],
	   [abraunegg/onedrive versions (space separated)])
if test "${ac_cv_env_ONEDRIVE_VERSION_set}" != set; then
   ONEDRIVE_VERSION="${onedrive_versions}"
fi

AC_ARG_VAR([WITH_SYSTEMD],
	   [use systemd? ("true", "false", or a space separated list)])
if test "${ac_cv_env_WITH_SYSTEMD_set}" != set; then
   WITH_SYSTEMD="false true"
fi
for b in ${WITH_SYSTEMD}; do
  if test "${b}" != "false" && test "${b}" != "true"; then
     AC_MSG_ERROR([WITH_SYSTEMD entries must be either "true" or "false".])
  fi
done

AC_CONFIG_COMMANDS([flake-diversification],
[
  for system in ${system_list}; do
    for nixpkgs in ${nixpkgs_list}; do
      for onedrive in ${onedrive_list}; do
        for systemd in ${systemd_list}; do
	  destdir="${builddir}/${system}/${nixpkgs}/onedrive-${onedrive}/systemd-${systemd}"
          ${MKDIR_P} "${destdir}"
	  ${SED} < "${srcdir}"/flake.nix.in > "${destdir}"/flake.nix \
	  	 -e "s/@SYSTEM@/${system}/g" \
	  	 -e "s/@NIXPKGS_VERSION@/${nixpkgs}/g" \
	  	 -e "s/@ONEDRIVE_VERSION@/${onedrive}/g" \
	  	 -e "s/@WITH_SYSTEMD@/${systemd}/g"
 	  ${NIXFMT} "${destdir}"/flake.nix
	done
      done
    done
  done
],
[
  MKDIR_P="${MKDIR_P}"
  SED="${SED}"
  NIXFMT="${NIXFMT}"
  srcdir=`realpath "${srcdir}"`
  builddir=`realpath "$(pwd)"`
  system_list="${SYSTEM}"
  nixpkgs_list="${NIXPKGS_VERSION}"
  onedrive_list="${ONEDRIVE_VERSION}"
  systemd_list="${WITH_SYSTEMD}"
])

AC_OUTPUT

# local variables:
# coding: utf-8
# end:
