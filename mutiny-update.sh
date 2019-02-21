#! /usr/bin/env bash

source common.sh

for pkg in "$MUTINY_PKG_PATH/"*; do
  pkgname="$(basename "$pkg")"
  pkgver="$(grep pkgver "$pkg/PKGBUILD" | cut -d= -f2)"
  pkgrel="$(grep pkgrel "$pkg/PKGBUILD" | cut -d= -f2)"

  crewname="${pkgname//-/_}"
  crewver="$(grep '^\s*version' "$CREW_PKG_PATH/$crewname.rb" | head -n1 | sed -E "s/^.*version.*['\"](.+)['\"].*$/\1/")"

  if [ "$pkgver" != "${crewver%%-*}" ] && [ "$pkgver-$pkgrel" != "${crewver%%-*}-${crewver##*-}" ]; then
    msg "Updating package '%s' from '%s' to '%s'..." "$pkgname" "$pkgver-$pkgrel" "$crewver"
    ./mutiny.sh "$crewname"

    if (grep -q 'build()' "$pkg/PKGBUILD"); then
      warning "Not building '%s' due to no binaries available." "$pkgname"
    else
      msg "Building '%s'..." "$pkgname"
      (cd "$pkg"; makepkg -d --sign)
    fi
  else
    msg "Package '%s' is up to date." "$pkgname"
  fi
done
