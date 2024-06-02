#!/usr/bin/env -S nu
#use lib/std.nu [get_arch, fetch_generic]

export def get_arch [] {
  return "x86_64"
}

export def get_fedora_version [] {
  return (run-external --redirect-combine rpm '-E' '%fedora' | complete).stdout
}

export def fetch_generic [url: string, suffix: string] {
  let temporary_place = (mktemp -t --suffix $suffix)
  http get $url | save -f $temporary_place
  return $temporary_place
}

export def fetch_copr [url: string] {
  let copr_name = (PWD=/etc/yum.repos.d mktemp --suffix ".repo")
  http get $url | save -f $copr_name
  return $copr_name
}

let ARCH = (get_arch)
let ARCH_ZAP = "amd64"

const BREW_TARGET = "/usr/libexec/brew-install"
http get "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | save -f $BREW_TARGET
run-external chmod '+x' $BREW_TARGET

let GUM_LATEST = (http get https://api.github.com/repos/charmbracelet/gum/releases/latest | get assets | where {|e| $e.name | str ends-with $"($ARCH).rpm" } | get browser_download_url).0
let GUM_RPM = (fetch_generic $GUM_LATEST ".rpm")
run-external dnf -y install $GUM_RPM
rm -f $GUM_RPM

let ZAP_TARGET = "/usr/bin/zap"
let ZAP_LATEST = (http get https://api.github.com/repos/srevinsaju/zap/releases/latest | get assets | where {|e| $e.name | str ends-with $"($ARCH_ZAP)" } | get browser_download_url).0
let ZAP_BIN = (fetch_generic $ZAP_LATEST "")
mv $ZAP_BIN $ZAP_TARGET
run-external chmod '+x' $ZAP_TARGET