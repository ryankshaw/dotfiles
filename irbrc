# 'looksee/shortcuts'
# Examine the precise method lookup path of any ruby object in ways not possible in standard ruby
# This defines a method lp ("lookup path") which lets you do:
# lp some_object

# 'ap' Awesome Print gem (gem install awesome_print), like pretty_print but more awesome

# 'net-http-spy' Print information about any HTTP requests being made


%w[ rubygems 
    looksee 
    tempfile 
    ap ].each do |g|
  begin
    require g
  rescue LoadError  => err
     warn "Couldn't load #{g}: #{err}"
  end
end

# Load the readline module.
IRB.conf[:USE_READLINE] = true

# Remove the annoying irb(main):001:0 and replace with >>
IRB.conf[:PROMPT_MODE]  = :SIMPLE

# Tab Completion
# require 'irb/completion'

# Automatic Indentation
IRB.conf[:AUTO_INDENT]=true

# Save History between irb sessions
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"

# Wirble is a set of enhancements for irb
# http://pablotron.org/software/wirble/README
# Implies require 'pp', 'irb/completion', and 'rubygems'
begin
  # load wirble
  require 'wirble'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize
rescue LoadError => err
  warn "Couldn't load Wirble: #{err}"
end


# Load / reload files faster
# http://www.themomorohoax.com/2009/03/27/irb-tip-load-files-faster
def fl(file_name)
   file_name += '.rb' unless file_name =~ /\.rb/
   @@recent = file_name 
   load "#{file_name}"
end
 
def rl
  fl(@@recent)
end

# Reload the file and try the last command again
# http://www.themomorohoax.com/2009/04/07/ruby-irb-tip-try-again-faster
def rt
  rl
  eval(choose_last_command)
end

# prevent 'rt' itself from recursing. 
def choose_last_command
  real_last = Readline::HISTORY.to_a[-2]
  real_last == 'rt' ? @@saved_last :  (@@saved_last = real_last)
end

# http://sketches.rubyforge.org/
# Sketches allows you to create and edit Ruby code from the comfort of your editor, 
# while having it safely reloaded in IRB whenever changes to the code are saved.
begin
  require 'sketches'
  Sketches.config :editor => 'mate -w'  
rescue Exception => e
  warn "Couldn't load sketches: #{e}"
end

# http://github.com/cldwalker/bond
# Bond (Bash-like tab completion)
begin
  require 'bond'
  Bond.start
rescue Exception => e
  warn "Couldn't load sketches: #{e}"
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def paste
  `pbpaste`
end

 
# This module adds a method, #to_file, which dumps the contents of self into a
# temp file and then returns the path of that file. This is particularly useful
# when calling out to shell commands which expect their input in the form of
# files.
#
# Example: use UNIX 'diff' to compare two objects:
#
# >> a = ["foo", "bar", "baz"].join("\n")
# => "foo\nbar\nbaz"
# >> b = ["foo", "buz", "baz"].join("\n")
# => "foo\nbuz\nbaz"
# >> puts `diff #{a.to_file} #{b.to_file}`
# 2c2
# < bar
# ---
# > buz
# => nil
#
module ConvertableToFile
  def to_file
    path = nil
    Tempfile.open(object_id.to_s) do |tempfile|
      tempfile << self
      path = tempfile.path
    end
    path
  end
end
 
class Object
  include ConvertableToFile
end








# http://gilesbowkett.blogspot.com/2007/11/irb-what-was-that-method-again.html
class Object
  def grep_methods(search_term)
    methods.find_all {|method| method.downcase.include? search_term.downcase}
  end
end
