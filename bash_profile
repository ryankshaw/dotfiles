source ~/.bash/aliases
source ~/.bash/config
source ~/.bash/completions
source ~/.profile

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

