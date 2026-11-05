# .zprofile - Sourced for login shells, before .zshrc.
# Configure login-session environment: source env files, set PATH, deduplicate paths.

# Source main environment file
source ~/.env.sh

# Paths
# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Keyring
# On a headless Linux login (SSH, console) nothing unlocks the GNOME login
# keyring, and tools that keep secrets in it (sbx) fail while it is locked.
# Prompt once to unlock it. Every guard below just skips quietly: other OSes,
# no terminal, graphical sessions (PAM unlocks those), no keyring on this machine.
_zprofile_unlock_keyring() {
  emulate -L zsh  # own options; also makes the INT trap below local
  [[ $OSTYPE == linux* ]] || return 0
  [[ -o interactive && -t 0 && -t 1 ]] || return 0
  [[ ${XDG_SESSION_TYPE:-tty} == tty ]] || return 0
  [[ -n $DBUS_SESSION_BUS_ADDRESS ]] || return 0
  [[ -f ${XDG_DATA_HOME:-$HOME/.local/share}/keyrings/login.keyring ]] || return 0
  (( $+commands[busctl] && $+commands[timeout] )) || return 0
  [[ -x /usr/bin/python3 ]] || return 0

  # Already unlocked (e.g. by another session) or no Secret Service: nothing to do.
  local locked
  locked=$(timeout 5 busctl --user get-property org.freedesktop.secrets \
    /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked 2>/dev/null) || return 0
  [[ $locked == 'b true' ]] || return 0

  # Ctrl-C skips the prompt without aborting the rest of login.
  trap 'stty echo 2>/dev/null; print; return 0' INT
  local pw
  read -rs 'pw?Login keyring is locked. Password (Enter to skip): ' || { print; return 0 }
  print
  [[ -n $pw ]] || return 0

  # Password goes over stdin (never argv) to gnome-keyring's own unlock call, on
  # one D-Bus connection; the standard Unlock method needs a GUI prompter.
  local err
  err=$(print -rn -- "$pw" | timeout 15 /usr/bin/python3 -c '
import sys
try:
    import gi
    gi.require_version("Gio", "2.0")
    from gi.repository import Gio, GLib
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    def call(path, iface, method, args, rtype):
        return bus.call_sync("org.freedesktop.secrets", path, iface, method, args,
                             GLib.VariantType(rtype), Gio.DBusCallFlags.NONE, 10000, None)
    _, session = call("/org/freedesktop/secrets", "org.freedesktop.Secret.Service", "OpenSession",
                      GLib.Variant("(sv)", ("plain", GLib.Variant("s", ""))), "(vo)").unpack()
    call("/org/freedesktop/secrets", "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface",
         "UnlockWithMasterPassword",
         GLib.Variant("(o(oayays))", ("/org/freedesktop/secrets/collection/login",
                                      (session, b"", sys.stdin.buffer.read(), "text/plain"))), "()")
except Exception as e:
    print(getattr(e, "message", None) or e, file=sys.stderr)
    sys.exit(1)
' 2>&1)
  local rc=$?
  unset pw
  if (( rc == 0 )); then
    print 'Login keyring unlocked.'
  else
    print -u2 "Login keyring not unlocked: ${err:-exit status $rc}"
  fi
  return 0
}
_zprofile_unlock_keyring
unfunction _zprofile_unlock_keyring
