source ~/.zplug/init.zsh

# コマンドラインハイライト auto-fuと相性が悪い
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# syntax-highlightning、greenは暗いので明るくする
zplug "~/dotfiles/zsh_highlight_color_change", from:local, defer:2

# 色拡張
zplug chrissicool/zsh-256color

# 自動補完
zplug b4b4r07/auto-fu.zsh

# ヒストリ検索拡張
zplug zsh-users/zsh-history-substring-search, defer:3

# 補完対象強化
zplug zsh-users/zsh-completions

# テーマ
zplug yous/lime

# pecoのframework
zplug "mollifier/anyframe"

# freqencyを考慮したファイル・フォルダ補完
zplug "plugins/fasd", from:oh-my-zsh

# 新時代のcd
zplug "b4b4r07/enhancd", use:init.sh

# git系のaliasがほしい
zplug "plugins/git",   from:oh-my-zsh

# ファイル移動
zplug "rupa/z", use:"*.sh"

# check コマンドで未インストール項目があるかどうか verbose にチェックし
# false のとき（つまり未インストール項目がある）y/N プロンプトで
# インストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# プラグインを読み込み、コマンドにパスを通す
zplug load --verbose

# 文字コードの指定
export LANG=ja_JP.UTF-8

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# cdなしでディレクトリ移動
setopt auto_cd

# ビープ音の停止
setopt no_beep

# ビープ音の停止(補完時)
setopt nolistbeep

# cdするとpuchdされていくようにする
setopt auto_pushd

# ヒストリ(履歴)を保存、数を増やす
HISTFILE=~/.zsh_history
HISTSIZE=6000000
SAVEHIST=6000000

## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# cdr系をロード
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs

# プロンプト
# PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
# PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
# コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

# エイリアス
alias ...='cd ../..'
alias ....='cd ../../..'

alias l='ls -lFh --color=auto'
alias la='ls -lAFh --color=auto'
alias ll='ls -lG'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'
alias ju='jupyter notebook'

alias dirs='dirs -v'
alias pu="pushd"
alias po="popd"

# hubコマンドエイリアスをgitコマンドにかける
eval "$(hub alias -s)"

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

# cd後にls
chpwd() { ls -lFh --color=auto }

# pecoでzを使う
function peco-z-search
{
  which peco z > /dev/null
  if [ $? -ne 0 ]; then
    echo "Please install peco and z"
    return 1
  fi
  local res=$(z | sort -rn | cut -c 12- | peco)
  if [ -n "$res" ]; then
    BUFFER+="cd $res"
    zle accept-line
  else
    return 1
  fi
}
zle -N peco-z-search

# 補完全般とauto-fu.zsh
setopt   auto_list auto_param_slash list_packed rec_exact
unsetopt list_beep
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors 'di=1;34'
zstyle ':completion:*' format '%F{white}%d%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' remote-access false
zstyle ':completion:*' completer _oldlist _complete _match _ignored \
    _list _history
zstyle ':completion:sudo:*' environ PATH="$SUDO_PATH:$PATH"
fpath=(~/dotfiles/.zsh/completions $fpath) # hubの補完
autoload -U compinit
compinit

zstyle ':auto-fu:highlight' input bold
zstyle ':auto-fu:highlight' completion fg=white
zstyle ':auto-fu:var' postdisplay ''

# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end

dir=~/.oh-my-zsh/custom/plugins/zsh-completions/src
if [ -e $dir ]; then
    fpath=($dir $fpath)
    plugins+=(zsh-completions)
    autoload -U compinit && compinit
fi

# キーバインディングの設定
# キーバインディングをemacs風に(-vはvim)
bindkey -e
# ディレクトリインクリメントサーチ
bindkey '^f' peco-z-search
## bash history一覧インクリメントサーチ & 実行
bindkey '^r' anyframe-widget-execute-history
## branch一覧をインクリメントサーチ & checkout
bindkey '^b' anyframe-widget-checkout-git-branch
## プロセス一覧をインクリメントサーチ & kill
bindkey '^x^k' anyframe-widget-kill
## deleteキー
bindkey "^[[3~" delete-char
# history-substring-search有効化
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

[[ -z $DISABLE_AUTO_FU_COMPLETION ]] && source $HOME/dotfiles/.zsh.d/auto-fu-config.zsh