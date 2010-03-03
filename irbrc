#!/usr/bin/ruby
require 'irb/completion'
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

%w[rubygems looksee/shortcuts].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end
begin
  # load wirble
  require 'wirble'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize
  rescue LoadError
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

def time(times = 1)
  require 'benchmark'
  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end

if defined? Benchmark
  class Benchmark::ReportProxy
    def initialize(bm, iterations)
      @bm = bm
      @iterations = iterations
      @queue = []
    end
    
    def method_missing(method, *args, &block)
      args.unshift(method.to_s + ':')
      @bm.report(*args) do
        @iterations.times { block.call }
      end
    end
  end

  def compare(times = 1, label_width = 12)
    Benchmark.bm(label_width) do |x|
      yield Benchmark::ReportProxy.new(x, times)
    end
  end
end







require 'tempfile'
 
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






# Giles Bowkett, Greg Brown, and several audience members from Giles' Ruby East presentation.
require 'tempfile'
class InteractiveEditor
  DEBIAN_SENSIBLE_EDITOR = "/usr/bin/sensible-editor"
  MACOSX_OPEN_CMD = "open"
  XDG_OPEN = "/usr/bin/xdg-open"
 
  def self.sensible_editor
    return ENV["VISUAL"] if ENV["VISUAL"]
    return ENV["EDITOR"] if ENV["EDITOR"]
    return MACOSX_OPEN_CMD if Platform::IMPL == :macosx
    if Platform::IMPL == :linux
      if File.executable?(XDG_OPEN)
        return XDG_OPEN
      end
      if File.executable?(DEBIAN_SENSIBLE_EDITOR)
        return DEBIAN_SENSIBLE_EDITOR
      end
    end
    raise "Could not determine what editor to use. Please specify."
  end
 
  attr_accessor :editor
  def initialize(editor = :vim)
    @editor = editor.to_s
    if @editor == "mate"
      @editor = "mate -w"
    end
  end
  def edit_interactively
    unless @file
      @file = Tempfile.new("irb_tempfile")
    end
    system("#{@editor} #{@file.path}")
    Object.class_eval(`cat #{@file.path}`)
    rescue Exception => error
      puts error
  end
end
 
module InteractiveEditing
  def edit_interactively(editor = InteractiveEditor.sensible_editor)
    unless IRB.conf[:interactive_editors] && IRB.conf[:interactive_editors][editor]
      IRB.conf[:interactive_editors] ||= {}
      IRB.conf[:interactive_editors][editor] = InteractiveEditor.new(editor)
    end
    IRB.conf[:interactive_editors][editor].edit_interactively
  end
  
  def handling_jruby_bug(&block)
    if RUBY_PLATFORM =~ /java/
      puts "JRuby IRB has a bug which prevents successful IRB vi/emacs editing."
      puts "The JRuby team is aware of this and working on it. But it might be unfixable."
      puts "(http://jira.codehaus.org/browse/JRUBY-2049)"
    else
      yield
    end
  end
 
  def vi
    handling_jruby_bug {edit_interactively(:vim)}
  end
 
  def mate
    edit_interactively(:mate)
  end
 
  # TODO: Hardcore Emacs users use emacsclient or gnuclient to open documents in
  # their existing sessions, rather than starting a brand new Emacs process.
  def emacs
    handling_jruby_bug {edit_interactively(:emacs)}
  end
end
 
# Since we only intend to use this from the IRB command line, I see no reason to
# extend the entire Object class with this module when we can just extend the
# IRB main object.
self.extend InteractiveEditing if Object.const_defined? :IRB










# http://gilesbowkett.blogspot.com/2007/11/irb-what-was-that-method-again.html
class Object
  def grep_methods(search_term)
    methods.find_all {|method| method.downcase.include? search_term.downcase}
  end
end



module Pastie
  def pastie(stuff_to_paste = nil)
    # automate creating pasties
    %w{platform net/http }.each {|lib| require lib}
    
    stuff_to_paste ||= copy
    return unless stuff_to_paste
    # return nil unless stuff_to_paste

    pastie_url = Net::HTTP.post_form(URI.parse("http://pastie.caboo.se/pastes/create"),
                                     {"paste_parser" => "ruby",
                                      "paste[authorization]" => "burger",
                                      "paste[body]" => stuff_to_paste}).body.match(/href="([^\"]+)"/)[1]

    Clipboard.write(pastie_url) if Clipboard.available?
    
    case Platform::IMPL
    when :macosx
      Kernel.system("open #{pastie_url}")
    when :mswin
      pastie_url = pastie_url.chop if pastie_url[-1].chr == "\000"
      Kernel.system("start #{pastie_url}")
    end

    return pastie_url
  end
end
 
class Object
  include Pastie
end if Object.const_defined? :IRB

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']
