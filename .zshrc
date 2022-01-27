# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/evancarey/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#

export PATH="/Users/evancarey/.local/bin:${PATH}"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# this isn't working ??
export EDITOR=/usr/local/bin/vim
export VISUAL=${EDITOR}

HISTSIZE=99999
HISTFILESIZE=999999
SAVEHIST=$HISTSIZE

# vim shell cli
bindkey -v
# enable ctrl-r history searching
bindkey '^R' history-incremental-search-backward

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# aliases and functions
alias mgka="cd ~/prj/magic-kaito"
alias mgkb="cd ~/prj/magic-kaito-b"
alias mgkc="cd ~/prj/magic-kaito-c"
alias mgkd="cd ~/prj/magic-kaito-d"
alias act=". ./env/bin/activate"
alias alarms="pbpaste > /tmp/$$.txt && ./bin/integration_alarms.sh /tmp/$$.txt"

# make list of uuids from integrations alarms
alarm_uuids() {
  ./bin/fetch_creds.py -p `grep ^D ${1} | awk -F'/' '{print $6}' | sort | uniq`
}

# run (by id) the scraper headless and drop profile and log files in ~/tmp
byid() {
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | tr '/' '-')
  ./bin/fetch_creds.py -p ${1} | jq '.[]' | python -m cProfile -o ~/tmp/${BRANCH_NAME}-${1}.prof scraper_runner.py -d 2>&1 | tee ~/tmp/${BRANCH_NAME}-${1}.log
}

# run (by id) the scraper headless and drop profile and log files in ~/tmp
byidh() {
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | tr '/' '-')
  ./bin/fetch_creds.py -p ${1} | jq '.[]' | python -m cProfile -o ~/tmp/${BRANCH_NAME}-${1}.prof scraper_runner.py -d --headed 2>&1 | tee ~/tmp/${BRANCH_NAME}-${1}.log
}

# test a facility id to verify you get what you expect
byidt() {
  ./bin/fetch_creds.py -p ${1} | jq '.[]' 
}

# pull kaito logs for given UUID
prdlogs() {
  mkdir -p ./tmp/${1}
  for i in $(kubectl -n screen-scrapers get pods | grep ${1} | cut -d ' ' -f 1); do
    echo $i
    kubectl -n screen-scrapers logs ${i} > ./tmp/${1}/${i}.log
  done
}

# monitor docker stats for particular container
mgkm() {
    while true; do docker stats --no-stream | grep ${1} | awk '{ if(index($4, "GiB")) {gsub("GiB","",$4); print $4*1000} else {gsub("MiB","",$4); print $4}}' | awk -v date="$(date +%T)" '{print $0", "date}'; sleep 1; done > ${1}.csv
}

# magic kaito env vars
export PYTHONDEVMODE=1

# jenv config
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# paa-js ld and include paths to support builds
export CPPFLAGS=-I/usr/local/opt/openssl/include
export LDFLAGS=-L/usr/local/opt/openssl/lib
export BUILD_LIBRDKAFKA=0

#export SSLKEYLOGFILE=~/.ssl-key.log

# add ghcup path
export PATH="$HOME/.cabal/bin:/Users/evancarey/.ghcup/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# source dev env vars
source ~/prod.env

# source aliases
source ~/.zsh/aliases
