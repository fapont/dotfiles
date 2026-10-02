# wt-clone <git-url> [dest-dir]
#
# git clone --bare <url> <dest-dir>/.git, cd into <dest-dir>, then create the
# first worktree on whatever branch the remote's HEAD points at (main,
# master, or anything else). dest-dir defaults to the repo's own name, so
# it clones into ./<repo>/.git.
wt-clone() {
  emulate -L zsh
  if [[ $# -lt 1 ]]; then
    echo "usage: wt-clone <git-url> [dest-dir]" >&2
    return 1
  fi

  local url="$1"
  local dest="${2:-${${url:t}%.git}}"
  git clone --bare -- "$url" "$dest/.git" || return 1
  cd -- "$dest" || return 1
  wt switch "$(wt config state default-branch)"
}

# awsp [-a] [<profile> | - | -u | -c]
#
# kubectx for AWS profiles: exports AWS_PROFILE in the current shell (hence a
# function, not a script/mise task). With no profile, picks one with fzf; the
# preview shows its ~/.aws/config section plus the SSO profile it delegates to
# through `aws-vault exec`. Only aws-vault-backed profiles (credential_process)
# are listed: the hundreds of team *-shared-sso ones are noise unless -a.
#   awsp             pick with fzf
#   awsp <profile>   switch directly (tab-completes)
#   awsp -           back to the previous profile
#   awsp -u          unset AWS_PROFILE
#   awsp -c          print the current profile
_awsp_profiles() {
  local all=${1:-0}
  awk -v all="$all" '
    function flush() { if (name != "" && (all || cp)) print name }
    /^\[/ {
      flush(); name = ""; cp = 0
      if ($0 ~ /^\[default\]/) name = "default"
      else if ($0 ~ /^\[profile /) { name = $0; sub(/^\[profile /, "", name); sub(/\].*/, "", name) }
      next
    }
    /^credential_process/ { cp = 1 }
    END { flush() }
  ' "${AWS_CONFIG_FILE:-$HOME/.aws/config}"
}

awsp() {
  emulate -L zsh
  local cfg="${AWS_CONFIG_FILE:-$HOME/.aws/config}" all=0 target
  [[ $1 == -a ]] && { all=1; shift }

  case "$1" in
    -c) print -r -- "${AWS_PROFILE:-<none>}"; return ;;
    -u) [[ -n $AWS_PROFILE ]] && typeset -g _AWSP_PREV=$AWS_PROFILE
        unset AWS_PROFILE; return ;;
    -)  [[ -z $_AWSP_PREV ]] && { echo "awsp: no previous profile" >&2; return 1 }
        target=$_AWSP_PREV ;;
    -*) echo "usage: awsp [-a] [<profile> | - | -u | -c]" >&2; return 1 ;;
    ?*) target=$1
        if ! _awsp_profiles 1 | grep -qxF -- "$target"; then
          echo "awsp: unknown profile '$target' in $cfg" >&2; return 1
        fi ;;
    *)
      # Prints the picked profile's section, then the section of the profile
      # its credential_process delegates to (`aws-vault exec <sso-profile>`).
      local preview='
        function hdr(l, n) { if (l ~ /^\[default\]/) return "default"; n = l; sub(/^\[(profile )?/, "", n); sub(/\].*/, "", n); return n }
        NR == FNR {
          if (/^\[/) cur = hdr($0)
          else if (cur == p && /^credential_process/ && match($0, /exec [^ ]+/)) src = substr($0, RSTART + 5, RLENGTH - 5)
          next
        }
        /^[[:space:]]*$/ { next }
        /^\[/ { cur = hdr($0); show = (cur == p || cur == src); if (show && seen++) print "" }
        show'
      target=$(_awsp_profiles $all | fzf --height=40% --reverse --no-multi \
        --header="current: ${AWS_PROFILE:-<none>}" \
        --preview="awk -v p={} ${(qq)preview} ${(qq)cfg} ${(qq)cfg}") || return
      ;;
  esac

  [[ $target == $AWS_PROFILE ]] && return
  [[ -n $AWS_PROFILE ]] && typeset -g _AWSP_PREV=$AWS_PROFILE
  export AWS_PROFILE=$target
  echo "AWS_PROFILE=$target"
}

if (( $+functions[compdef] )); then
  _awsp() {
    local -a profiles=(${(f)"$(_awsp_profiles 1)"})
    _arguments '-a[list every profile]' "1:AWS profile:(- -u -c ${profiles})"
  }
  compdef _awsp awsp
fi
