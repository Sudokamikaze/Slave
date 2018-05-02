

#
# User configuration sourced by interactive shells
#

# Change default zim location 
export ZIM_HOME=/usr/lib/zim

# Source global config
source /etc/zsh/zimrc

# Source zim
source ${ZIM_HOME}/init.zsh

zprompt_theme='pure'
GPG_TTY=$(tty)
export GPG_TTY

export TERM=xterm
