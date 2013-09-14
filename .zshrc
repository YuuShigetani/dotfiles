# users generic .zshrc file for zsh(1)

# tmux autoload
if which tmux 2>&1 >/dev/null; then
  #if not inside a tmux session, and if no session is started, start a new session
  test -z "$TMUX" && (tmux -2 attach || tmux -2 new-session)
fi
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'

# tmuxinator
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

## Environment variable configuration
#
# LANG
# http://curiousabt.blog27.fc2.com/blog-entry-65.html
export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8


## Backspace key
bindkey "^?" backward-delete-char

## Default shell configuration
#
# set prompt
# colors enables us to idenfity color by $fg[red].
autoload colors
colors
case ${UID} in
  0)
    PROMPT="%B%{${fg[red]}%}%/#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
      PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
  *)
    # Color
    DEFAULT=$'%{\e[1;0m%}'
    RESET="%{${reset_color}%}"
    # GREEN=$'%{\e[1;32m%}'
    GREEN="%{${fg[green]}%}"
    # BLUE=$'%{\e[1;35m%}'
    BLUE="%{${fg[blue]}%}"
    RED="%{${fg[red]}%}"
    CYAN="%{${fg[cyan]}%}"
    WHITE="%{${fg[white]}%}"

    # Prompt
    setopt prompt_subst
    # PROMPT='${fg[white]}%(5~,%-2~/.../%2~,%~)% ${RED} $ ${RESET}'
    PROMPT='${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{$fg_bold[blue]%}${USER}@%m ${RESET}${WHITE}$ ${RESET}'
    RPROMPT='${RESET}${WHITE}[${BLUE}%(5~,%-2~/.../%2~,%~)% ${WHITE}]${WINDOW:+"[$WINDOW]"} ${RESET}'

    # Vi入力モードでPROMPTの色を変える
    # http://memo.officebrook.net/20090226.html
    function zle-line-init zle-keymap-select {
      case $KEYMAP in
        vicmd)
          PROMPT="${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{$fg_bold[cyan]%}${USER}@%m ${RESET}${WHITE}$ ${RESET}"
          ;;
        main|viins)
          PROMPT="${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{$fg_bold[blue]%}${USER}@%m ${RESET}${WHITE}$ ${RESET}"
          ;;
      esac
      zle reset-prompt
    }
    zle -N zle-line-init
    zle -N zle-keymap-select

    # 直前のコマンドの終了ステータスが0以外のときは赤くする。
    # ${MY_MY_PROMPT_COLOR}はprecmdで変化させている数値。
    local MY_COLOR="$ESCX"'%(0?.${MY_PROMPT_COLOR}.31)'m
    local NORMAL_COLOR="$ESCX"m


    # Show git branch when you are in git repository
    # http://d.hatena.ne.jp/mollifier/20100906/p1

    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git svn hg bzr
    zstyle ':vcs_info:*' formats '(%s)-[%b]'
    zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
    zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
    zstyle ':vcs_info:bzr:*' use-simple true

    autoload -Uz is-at-least
    if is-at-least 4.3.10; then
      # この check-for-changes が今回の設定するところ
      zstyle ':vcs_info:git:*' check-for-changes true
      zstyle ':vcs_info:git:*' stagedstr "+"    # 適当な文字列に変更する
      zstyle ':vcs_info:git:*' unstagedstr "-"  # 適当の文字列に変更する
      zstyle ':vcs_info:git:*' formats '(%s)-[%c%u%b]'
      zstyle ':vcs_info:git:*' actionformats '(%s)-[%c%u%b|%a]'
    fi

    function _update_vcs_info_msg() {
      psvar=()
      LANG=en_US.UTF-8 vcs_info
      psvar[2]=$(_git_not_pushed)
      [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
    }
    add-zsh-hook precmd _update_vcs_info_msg

    function _git_not_pushed()
    {
      if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
        head="$(git rev-parse HEAD)"
        for x in $(git rev-parse --remotes)
        do
          if [ "$head" = "$x" ]; then
            return 0
          fi
        done
        echo "{?}"
      fi
      return 0
    }

    RPROMPT="%1(v|%F${CYAN}%1v%2v%f|)${vcs_info_git_pushed}${RESET}${WHITE}[${BLUE}%(5~,%-2~/.../%2~,%~)% ${WHITE}]${WINDOW:+"[$WINDOW]"} ${RESET}"

    ;;
esac

# case "$TERM" in
#   xterm*|kterm*|rxvt*)
#   PROMPT=$(print "%B%{\e[34m%}%m:%(5~,%-2~/.../%2~,%~)%{\e[33m%}%# %b") PROMPT=$(print "%{\e]2;%n@%m: %~\7%}$PROMPT") # title bar
#   ;;
#   *)
#   PROMPT='%m:%c%# '
#   ;;
# esac

# 指定したコマンド名がなく、ディレクトリ名と一致した場合 cd する
setopt auto_cd

# cd でTabを押すとdir list を表示
setopt auto_pushd

# ディレクトリスタックに同じディレクトリを追加しないようになる
setopt pushd_ignore_dups

# コマンドのスペルチェックをする
setopt correct

# コマンドライン全てのスペルチェックをする
setopt correct_all

# 上書きリダイレクトの禁止
setopt no_clobber

# 補完候補リストを詰めて表示
setopt list_packed

# auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示
setopt list_types

# 補完候補が複数ある時に、一覧表示する
setopt auto_list

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash

# {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl

# シンボリックリンクは実体を追うようになる
#setopt chase_links

# 補完キー（Tab,  Ctrl+I) を連打するだけで順に補完候補を自動で補完する
setopt auto_menu

# sudoも補完の対象
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# 色付きで補完する
zstyle ':completion:*' list-colors di=34 fi=0
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 複数のリダイレクトやパイプなど、必要に応じて tee や cat の機能が使われる
setopt multios

# 最後がディレクトリ名で終わっている場合末尾の / を自動的に取り除かない
setopt noautoremoveslash

# beepを鳴らさないようにする
setopt nolistbeep

# Match without pattern
# ex. > rm *~398
# remove * without a file "398". For test, use "echo *~398"
setopt extended_glob

# Keybind configuration
# emacs like keybind (e.x. Ctrl-a goes to head of a line and Ctrl-e goes
#   to end of it)
bindkey -e

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

# glob(*)によるインクリメンタルサーチ
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

# Command history configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 登録済コマンド行は古い方を削除
setopt hist_ignore_all_dups

# historyの共有
setopt share_history

# 余分な空白は詰める
setopt hist_reduce_blanks

# add history when command executed.
setopt inc_append_history

# history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store
# サスペンド中のプロセスと同じコマンド名を実行した場合はリジュームする
#setopt auto_resume

# =command を command のパス名に展開する
#setopt equals

# ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
#setopt extended_glob

# zsh の開始・終了時刻をヒストリファイルに書き込む
#setopt extended_history

# Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
#setopt NO_flow_control

# 各コマンドが実行されるときにパスをハッシュに入れる
#setopt hash_cmds

# コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
#setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify

# シェルが終了しても裏ジョブに HUP シグナルを送らないようにする
#setopt NO_hup

# Ctrl+D では終了しないようになる（exit, logout などを使う）
#setopt ignore_eof

# コマンドラインでも # 以降をコメントと見なす
#setopt interactive_comments

# メールスプール $MAIL が読まれていたらワーニングを表示する
#setopt mail_warning

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
#setopt mark_dirs

# ファイル名の展開で、辞書順ではなく数値的にソートされるようになる
#setopt numeric_glob_sort

# コマンド名に / が含まれているとき PATH 中のサブディレクトリを探す
setopt path_dirs

# 戻り値が 0 以外の場合終了コードを表示する
# setopt print_exit_value

# pushd を引数なしで実行した場合 pushd $HOME と見なされる
#setopt pushd_to_home

# rm * などの際、本当に全てのファイルを消して良いかの確認しないようになる
#setopt rm_star_silent

# rm_star_silent の逆で、10 秒間反応しなくなり、頭を冷ます時間が与えられる
#setopt rm_star_wait

# for, repeat, select, if, function などで簡略文法が使えるようになる
#setopt short_loops

# デフォルトの複数行コマンドライン編集ではなく、１行編集モードになる
#setopt single_line_zle

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# ^でcd ..する
function cdup() {
  echo
  cd ..
  zle reset-prompt
}
zle -N cdup
# bindkey '\^' cdup

# ctrl-w, ctrl-bキーで単語移動
# bindkey "^W" forward-word
# bindkey "^B" backward-word

# back-wordでの単語境界の設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified

# URLをコピペしたときに自動でエスケープ
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# 勝手にpushd
setopt autopushd

# エラーメッセージ本文出力に色付け
e_normal=`echo -e "¥033[0;30m"`
e_RED=`echo -e "¥033[1;31m"`
e_BLUE=`echo -e "¥033[1;36m"`

function make() {
  LANG=C command make "$@" 2>&1 | sed -e "s@[Ee]rror:.*@$e_RED&$e_normal@g" -e "s@cannot¥sfind.*@$e_RED&$e_normal@g" -e "s@[Ww]arning:.*@$e_BLUE&$e_normal@g"
}
function cwaf() {
  LANG=C command ./waf "$@" 2>&1 | sed -e "s@[Ee]rror:.*@$e_RED&$e_normal@g" -e "s@cannot¥sfind.*@$e_RED&$e_normal@g" -e "s@[Ww]arning:.*@$e_BLUE&$e_normal@g"
}

# Completion configuration
fpath=(~/.zsh/functions/Completion ${fpath})
autoload -U compinit
compinit -u


# zsh editor
autoload zed


# Prediction configuration
autoload predict-on
# predict-off

# Command Line Stack [Esc]-[q]
bindkey -a 'q' push-line


# Alias configuration
# expand aliases before completing
# aliased ls needs if file/dir completions work
setopt complete_aliases

alias where="command -v"


## terminal configuration
# http://journal.mycom.co.jp/column/zsh/009/index.html
# {{{
  unset LSCOLORS

  case "${TERM}" in
  xterm)
    export TERM=xterm-color
    ;;
  kterm)
    export TERM=kterm-color
    # set BackSpace control character
    stty erase
    ;;
  cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;32:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30'
    zstyle ':completion:*' list-colors \
      'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
  kterm*|xterm*)
    # Terminal.app
    # precmd() {
    #   echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    # }
    # export LSCOLORS=exfxcxdxbxegedabagacad
    # export LSCOLORS=gxfxcxdxbxegedabagacad
    # export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30'
    export CLICOLOR=1
    export LSCOLORS=ExFxCxDxBxegedabagacad
    zstyle ':completion:*' list-colors \
      'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
  dumb)
    echo "Welcome Emacs Shell"
    ;;
  esac
# }}}

export EDITOR=vim
export PATH=$PATH:$HOME/local/bin:/usr/local/git/bin
export PATH=$PATH:$HOME/dotfiles/bin
export PATH=$PATH:/sbin
export MANPATH=$MANPATH:/opt/local/man:/usr/local/share/man

expand-to-home-or-insert () {
  if [ "$LBUFFER" = "" -o "$LBUFFER[-1]" = " " ]; then
    LBUFFER+="~/"
  else
    zle self-insert
  fi
}

# zsh の exntended_glob と HEAD^^^ を共存させる。
# http://subtech.g.hatena.ne.jp/cho45/20080617/1213629154
# {{{
  typeset -A abbreviations
  abbreviations=(
    "L"    "| $PAGER"
    "G"    "| grep"

    "HEAD^"     "HEAD\\^"
    "HEAD^^"    "HEAD\\^\\^"
    "HEAD^^^"   "HEAD\\^\\^\\^"
    "HEAD^^^^"  "HEAD\\^\\^\\^\\^\\^"
    "HEAD^^^^^" "HEAD\\^\\^\\^\\^\\^"
  )
# }}}

# 略語展開
# {{{
  magic-abbrev-expand () {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[-_a-zA-Z0-9^]#}
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
  }

  magic-abbrev-expand-and-insert () {
    magic-abbrev-expand
    zle self-insert
  }

  magic-abbrev-expand-and-accept () {
    magic-abbrev-expand
    zle accept-line
  }

  no-magic-abbrev-expand () {
    LBUFFER+=' '
  }

  zle -N magic-abbrev-expand
  zle -N magic-abbrev-expand-and-insert
  zle -N magic-abbrev-expand-and-accept
  zle -N no-magic-abbrev-expand
  bindkey "\r"  magic-abbrev-expand-and-accept # M-x RET はできなくなる
  bindkey "^J"  accept-line # no magic
  bindkey " "   magic-abbrev-expand-and-insert
  bindkey "."   magic-abbrev-expand-and-insert
  bindkey "^x " no-magic-abbrev-expand
# }}}

# Incremental completion on zsh
# http://mimosa-pudica.net/src/incr-0.2.zsh
# やっぱりauto_menu使いたいのでoff
# source ~/.zsh/incr*.zsh

# http://d.hatena.ne.jp/tarao/20100531/1275322620
# incremental completion
# {{{
  function () {
    local A
    A=~/.zsh/auto-fu.zsh/auto-fu.zsh
    [[ -e "${A:r}.zwc" ]] && [[ "$A" -ot "${A:r}.zwc" ]] ||
    zsh -c "source $A; auto-fu-zcompile $A ${A:h}" >/dev/null 2>&1
  }
  source ~/.zsh/auto-fu.zsh/auto-fu; auto-fu-install

  # initialization and options
  function zle-line-init () { auto-fu-init }
  zle -N zle-line-init
  zstyle ':auto-fu:highlight' input bold
  zstyle ':auto-fu:highlight' completion fg=white
  zstyle ':auto-fu:var' postdisplay ''

  # afu+cancel
  function afu+cancel () {
    afu-clearing-maybe
    ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur"; }
  }
  zle -N afu+cancel
  function bindkey-advice-before () {
    local key="$1"
    local advice="$2"
    local widget="$3"
    [[ -z "$widget" ]] && {
      local -a bind
      bind=(`bindkey -M main "$key"`)
      widget=$bind[2]
    }
    local fun="$advice"
    if [[ "$widget" != "undefined-key" ]]; then
      local code=${"$(<=(cat <<"EOT"
        function $advice-$widget () {
          zle $advice
          zle $widget
        }
        fun="$advice-$widget"
EOT
        ))"}
      eval "${${${code//\$widget/$widget}//\$key/$key}//\$advice/$advice}"
    fi
    zle -N "$fun"
    bindkey -M afu "$key" "$fun"
  }
  bindkey-advice-before "^G" afu+cancel
  bindkey-advice-before "^[" afu+cancel
  bindkey-advice-before "^J" afu+cancel afu+accept-line
  # # delete unambiguous prefix when accepting line
  function afu+delete-unambiguous-prefix () {
    afu-clearing-maybe
    local buf; buf="$BUFFER"
    local bufc; bufc="$buffer_cur"
    [[ -z "$cursor_new" ]] && cursor_new=-1
    [[ "$buf[$cursor_new]" == ' ' ]] && return
    [[ "$buf[$cursor_new]" == '/' ]] && return
    ((afu_in_p == 1)) && [[ "$buf" != "$bufc" ]] && {
      # there are more than one completion candidates
      zle afu+complete-word
      [[ "$buf" == "$BUFFER" ]] && {
        # the completion suffix was an unambiguous prefix
        afu_in_p=0; buf="$bufc"
      }
      BUFFER="$buf"
      buffer_cur="$bufc"
    }
  }
  zle -N afu+delete-unambiguous-prefix
  function afu-ad-delete-unambiguous-prefix () {
    local afufun="$1"
    local code; code=$functions[$afufun]
    eval "function $afufun () { zle afu+delete-unambiguous-prefix; $code }"
  }
  afu-ad-delete-unambiguous-prefix afu+accept-line
  afu-ad-delete-unambiguous-prefix afu+accept-line-and-down-history
  afu-ad-delete-unambiguous-prefix afu+accept-and-hold
# }}}

# sudo.vim
# {{{
  sudo() {
    local args
    case $1 in
      vi|vim)
        args=()
        for arg in $@[2,-1]
        do
          if [ $arg[1] = '-' ]; then
            args[$(( 1+$#args ))]=$arg
          else
            args[$(( 1+$#args ))]="sudo:$arg"
          fi
        done
        command vim $args
        ;;
      *)
        command sudo $@
        ;;
    esac
  }
# }}}

# enterでls & git status
# {{{
# function do_enter() {
#   if [ -n "$BUFFER" ]; then
#     zle accept-line
#     return 0
#   fi
#   echo
#   ls -a
#   if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
#     echo
#     echo -e "\e[0;33m--- git status ---\e[0m"
#     git status -sb
#   fi
#   zle reset-prompt
#   return 0
# }
# zle -N do_enter
# bindkey '^m' do_enter
# }}}

# rakeコマンドをキャッシュ
# http://qiita.com/ToQoz/items/848abdf90a0f40e70ce0
# {{{
  _cachefile_updated_at() {
    echo $(stat .rake_tasks -c%Y)
  }

  _rakefile_updated_at() {
    echo $(stat Rakefile -c%Y)
  }

  _gemfile_updated_at() {
    echo $(stat Gemfile -c%Y)
  }

  _generate_cachefile() {
    [ -f .rake_tasks ] && rm .rake_tasks
    rake --silent --tasks 2> /dev/null | cut  -f 2 -d " " > .rake_tasks
  }

  _rake() {
    if [ -f Rakefile ]; then
      if [ ! -f .rake_tasks ] || \
         [ "`cat .rake_tasks | wc -l`" = "0" ] || \
         [ `_cachefile_updated_at` -lt `_rakefile_updated_at` ]; then
         # [ -f Gemfile -a `_cachefile_updated_at` -lt `_gemfile_updated_at` ]; then
        _generate_cachefile
      fi
      compadd `cat .rake_tasks`
    fi
  }
  compdef _rake rake
# }}}

# notify for slow commands
# http://qiita.com/hayamiz/items/d64730b61b7918fbb970
# {{{
  autoload -U add-zsh-hook 2>/dev/null || return

  __timetrack_threshold=10 # seconds
  read -r -d '' __timetrack_ignore_progs <<EOF
  less emacs vi vim
  ssh mosh telnet nc netcat
  gdb tmux guard edf fg
  xdg-open rails thin
  cassandra cassandra-cli
EOF

  export __timetrack_threshold
  export __timetrack_ignore_progs

  function __my_preexec_start_timetrack() {
    local command=$1
    export __timetrack_start=`date +%s`
    export __timetrack_command="$command"
  }

  function __my_preexec_end_timetrack() {
    local exec_time
    local command=$__timetrack_command
    local prog=$(echo $command|awk '{print $1}')
    local notify_method
    local message

    export __timetrack_end=`date +%s`

    if which growlnotify >/dev/null 2>&1; then
      notify_method="growlnotify"
    elif which notify-send >/dev/null 2>&1; then
      notify_method="notify-send"
    else
      return
    fi

    if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
      return
    fi

    for ignore_prog in $(echo $__timetrack_ignore_progs); do
      [ "$prog" = "$ignore_prog" ] && return
    done

    exec_time=$((__timetrack_end-__timetrack_start))
    if [ -z "$command" ]; then
      command="<UNKNOWN>"
    fi

    message="Command finished!\nTime: $exec_time seconds\nCOMMAND: $command"

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      case $notify_method in
        "growlnotify" )
          echo "$message" | growlnotify -n "ZSH timetracker" --appIcon Terminal
          ;;
        "notify-send" )
          notify-send -i gtk-info "ZSH timetracker" "$message"
          ;;
      esac
    fi
    unset __timetrack_start
    unset __timetrack_command
  }

  if which growlnotify >/dev/null 2>&1 ||
    which notify-send >/dev/null 2>&1; then
    add-zsh-hook preexec __my_preexec_start_timetrack
    add-zsh-hook precmd __my_preexec_end_timetrack
  fi
# }}}

# mkdir & cd
function mkcd() { mkdir -p $1 && cd $1; }

# alias設定
# {{{
  [ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias
# }}}

# os毎の設定
# {{{
  case "${OSTYPE}" in
  # Mac(Unix)
  darwin*)
    [ -f ~/dotfiles/.zshrc.osx ] && source ~/dotfiles/.zshrc.osx
    ;;
  # Linux
  linux*)
    [ -f ~/dotfiles/.zshrc.linux ] && source ~/dotfiles/.zshrc.linux
    ;;
  # freeBSD
  freebsd*)
    [ -f ~/dotfiles/.zshrc.freebsd ] && source ~/dotfiles/.zshrc.freebsd
    ;;
  esac
# }}}

## local固有設定
# {{{
  [ -f ~/.zshrc.local ] && source ~/.zshrc.local
# }}}
