#!/bin/sh

main() {
  if [ ! -f "${PWD}/dbeaver_dark_theme.sh" ]; then
    # This is needed to get path to CSS files easily
    echo "You must change current directory to directory with \"dbeaver_dark_theme.sh\" before executing it!" >&2
    return 1
  fi
  css_files_dir="${PWD}/theme"

  css_dir_default="$(find /usr/lib/dbeaver/plugins/org.eclipse.ui.themes_* -maxdepth 1 -name css)" || return "$?"
  if [ ! -d "${css_dir_default}" ]; then
    echo "Could not find the css directory! Make sure DBeaver is installed." >&2
    return 1
  fi

  css_dir_backup="${PWD}/backup"

  [ "$#" -gt 0 ] && { action="${1}" && shift || return "$?"; } || action=""
  if [ "${action}" = "install" ]; then
    echo "Creating backup from \"${css_dir_default}\" to \"${css_dir_backup}\"..." >&2
    if [ -d "${css_dir_backup}" ]; then
      echo "Creating backup from \"${css_dir_default}\" to \"${css_dir_backup}\": skipped! Backup already exists!" >&2
    else
      cp -rT "${css_dir_default}" "${css_dir_backup}" || return "$?"
      echo "Creating backup from \"${css_dir_default}\" to \"${css_dir_backup}\": success!" >&2
    fi

    echo "Applying CSS files from \"${css_files_dir}\" to \"${css_dir_default}\"..." >&2
    sudo rm -rf "${css_dir_default}" || return "$?"
    sudo cp -rT "${css_files_dir}" "${css_dir_default}" || return "$?"
    echo "Applying CSS files from \"${css_files_dir}\" to \"${css_dir_default}\": success!" >&2
  elif [ "${action}" = "uninstall" ]; then
    echo "Applying backup from \"${css_dir_backup}\" to \"${css_dir_default}\"..." >&2
    if [ ! -d "${css_dir_backup}" ]; then
      echo "Backup \"${css_dir_backup}\" not found! Maybe \"dbeaver_dark_theme\" was already uninstalled." >&2
      return 1
    fi
    sudo cp -rT "${css_dir_backup}" "${css_dir_default}" || return "$?"
    echo "Applying backup from \"${css_dir_backup}\" to \"${css_dir_default}\": success!" >&2

    rm -rf "${css_dir_backup}" || return "$?"
    echo "Backup \"${css_dir_backup}\" removed!" >&2
  else
    echo "Usage: ${0} [install|uninstall]" >&2
    return 1
  fi
}

main "${@}" || exit "$?"
