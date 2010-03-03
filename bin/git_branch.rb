#! /usr/bin/ruby

# LIGHT_RED="\033[1;31m"
# YELLOW="\033[0;33m"
# GREEN="\033[0;32m"
# 
# 
# using these colors is what breaks my console so that it dies on pressing the up arrow thrugh the history.
# it has something to do with: http://stackoverflow.com/questions/342093/ps1-line-wrapping-with-colours-problem
LIGHT_RED=""
YELLOW=""
GREEN=""
WHITE = ""

def git_status
  res = ""
  status_output = `git status 2> /dev/null`
  if status_output =~ /On branch/i 
    res << "#{GREEN}(#{status_output.split[3]})"
  end
  res
end
puts git_status