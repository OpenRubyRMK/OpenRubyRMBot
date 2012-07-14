# -*- coding: utf-8 -*-
# This file is part of OpenRubyRMBot.
# 
# Copyright © 2012 The OpenRubyRMK Team
# 
# OpenRubyRMBot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# OpenRubyRMBot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with OpenRubyRMBot.  If not, see <http://www.gnu.org/licenses/>.

#The actual Bot class. You can configure the bot through the
#+open_ruby_rmbot.conf+ file in the config/ directory of your
#OpenRubyRMBot installation.
#
#== Plugins
#OpenRubyRMBot is easily extendable through plugins. By default,
#it comes with the two plugins +default_public_triggers+ that
#defines the triggers the bot usually reacts to and
#+default_private_commands+ which defines the commands the bot
#usually understands via private messages. You can add your
#own plugins (or even replace the default plugins) with a few
#simple steps. First, for your plugin to be even recognised,
#you have to place the plugin’s main file into the plugins/
#directory of your OpenRubyRMBot installation. The file’s name
#doesn’t really matter, but be sure to choose something not
#conflicting with other plugins you want to use. All files
#in the plugins/ directory are automatically loaded at startup,
#so ensure you do not pollute any namespaces outside your plugin
#until the plugin is actually *loaded* by OpenRubyRMBot.
#
#Next, open up the file in your favourite editor and place
#something like this in it:
#
#  module OpenRubyRMBot::Plugins::MyPlugin
#
#    def self.name
#      "my_plugin"
#    end
#
#    def parse_visible_message(from, to, msg)
#      super
#    end
#
#  end
#
#This is the base skeleton for every plugin. You have to
#define a module with a unique name (i.e. not conflicting
#with the names of other plugins) under the namespace
#<tt>OpenRubyRMBot::Plugins</tt> and then define a module
#method called +name+ on that module. Again, note that
#the +name+ method is defined on the _module_, not as an
#instance method! This is important, because OpenRubyRMBot
#uses this method to identify your plugin (so, once again,
#ensure it returns a string not used by other plugins). This
#is the name of the plugin that needs to be placed into the
#plugin list file <tt>plugins.conf</tt> in order to activate
#your plugin at startup.
#
#The +parse_visible_message+ method is the main entry point
#of your plugin. It will be called for each message that
#is visible to OpenRubyRMBot, i.e. both generally public
#messages and PMs targetted at the bot. This includes
#messages that have already been processed by other plugins,
#so it is possible to process a message twice or more often.
#The parameters this method receives are as follows:
#
#[from]
#  The nick that sent the message.
#[to]
#  In case of a public message, this is the channel the
#  message was sent to (recognisable by one or more
#  leading # signs) or, in case of a private message,
#  the nick the message was targetted at. This should
#  normally be the nickname of the bot, as PMs to other
#  users shouldn’t even be visible to the bot.
#[msg]
#  The actual message sent.
#
#What you do inside this method is completely your
#own decision. Just ensure you call +super+ as soon
#as possible to allow other plugins to run (ideally make
#it the first line of your method).
#
#Inside this (and possibly other if you define them) instance
#method you have access to a couple of methods to interact
#with the IRC channel, server, and nicks. Probably the most
#important one is +message+, which takes a target (either
#a channel name or a nickname) and a single-line message
#(use IRCBot#multiline_message if you want to sent multiple
#lines, but note IRC servers often cut flooding messages,
#so limit yourself to a maximum of appr. 4 lines of
#text per response). Let’s extend our sample plugin
#with an echo functionality (you shouldn’t do this in
#praxis as it becomes annoying):
#
##  module OpenRubyRMBot::Plugins::MyPlugin
#
#    def self.name
#      "my_plugin"
#    end
#
#    def parse_visible_message(from, to, msg)
#      super
#      if to.downcase == @config[:channel].downcase
#        message(to, "#{from} said to #{to}: #{msg}")
#      end
#    end
#
#  end
#
#This will echo everything said publically in the chatroom
#back to the channel. Note two things in the above code:
#
#1. We’re using the @config hash here. This hash contains
#   the parsed contents of the main configuration file,
#   using symbols instead of strings as keys.
#2. We downcase the channel names. This is necessary,
#   because lazy guys tend to not use the proper capitalization
#   for channel and nicknames, causing our bot to possibly
#   overlook a message.
#
#Finally, open the config/plugins.conf file and add a new line to
#the bottom of that file:
#
#  my_plugin
#
#This will cause OpenRubyRMBot to call #use_plugin with your
#plugin module as an argument, effectively extending the
#bot with your module.
#
#You can find a list of all methods available in the bot
#in the documentation of <tt>em-irc</tt>, the library used
#under the hood by OpenRubyRMBot. You can find it at
#http://rubydoc.info/gems/em-irc . Probably the most
#interesting part of their docs is the Commands module:
#http://rubydoc.info/gems/em-irc/EventMachine/IRC/Commands .
class OpenRubyRMBot::IRCBot < EventMachine::IRC::Client
  extend OpenRubyRMBot::Pluggable

  #The root directory path of your OpenRubyRMBot installation.
  ROOT_DIR = Pathname.new(__FILE__).dirname.parent.parent

  #The path to the configuration file to read.
  CONFIG_FILE = ROOT_DIR + "config" + "open_ruby_rmbot.conf"

  #The path to the file listing the plugins to load.
  PLUGINS_FILE = ROOT_DIR + "config" + "plugins.conf"

  #The path to the directory containing the plugins.
  PLUGINS_DIR = ROOT_DIR + "plugins"

  #The current configuration of OpenRubyRMBot.
  attr_reader :config
  #Whether or not in debug mode. See also #debug_mode?
  attr_reader :debug

  #Creates a new instance of the bot, reading the CONFIG_FILE.
  #Note this method doesn’t start the bot, call #run! for this
  #to happen.
  #==Parameter
  #[debug] ($DEBUG) If this is set, ignores the +logfile+ and +loglevel+
  #        directives of the configuration file and logs to standard
  #        output with logging level DEBUG (0). Defaults to Ruby’s own
  #        debugging state, which usually is +nil+. If this is the symbol
  #        :all, additionally activates em-irc’s underlying logger that
  #        outputs *everything* regarding the connection.
  def initialize(debug = $DEBUG)
    @config = YAML.load_file(CONFIG_FILE.to_s)
    @config.symbolize_keys!
    @config.freeze
    super(host: @config[:network], port: @config[:port])

    # If running in debug mode, always log to $stdout with
    # loglevel DEBUG and ignore the directives in the
    # configuration file.
    @debug = debug
    if @debug
      @log = Logger.new($stdout)
      @log.level = Logger::DEBUG
    else
      @log = Logger.new(@config[:logfile] % {:install => ROOT_DIR.to_s})
      @log.level = @config[:loglevel]
    end

    # Set the time format the user wants (the space at the
    # end is necessary as the #PID is appended there directly
    # otherwise).
    @log.datetime_format = "#{@config[:logformat]} "

    # Activate the underlying logger if requested
    if @debug == :all
      @logger = @log
    end

    # Notify the user that we are starting
    @log.info("OpenRubyRMBot version #{OpenRubyRMBot::VERSION} starting up.")
    @log.info("Copyright (C) 2012 The OpenRubyRMK team")
    @log.info("This is free software, as defined by the GNU GPL.")
    @log.info("See the file COPYING in the sources for more information.")

    # Write PID file
    @__pid_file = @config[:pid_file] % {:install => ROOT_DIR.to_s}
    if File.file?(@__pid_file)
      @log.fatal("PID file #@__pid_file already exists. If this is a stale file, please delete it.")
      exit 3
    else
      File.open(@__pid_file, "w"){|f| f.write($$)}
      @log.debug("PID written to #@__pid_file.")
    end
    at_exit{File.delete(@__pid_file)}

    # Load plugins
    @plugins = []
    plugin_mods = OpenRubyRMBot::Plugins.constants.map{|sym| OpenRubyRMBot::Plugins.const_get(sym)}
    File.readlines(PLUGINS_FILE).reject{|l| l.strip.empty? || l.strip.start_with?("#")}.each do |name|
      name = name.strip # Remove whitespace
      if mod = plugin_mods.find{|mod| mod.name == name} # Single = intended
        use_plugin(mod)
      else
        @log.fatal("Unable to find requested plugin '#{name}'.")
        exit 2
      end
    end
    @log.info("Loaded plugins: #{@plugins.map(&:name).join(', ')}")

    ### Registering of callbacks follows ###

    # Connected to the server.
    on :connect do
      @log.info("Connected to #{@config[:network]}.")
      nick @config[:nickname]
    end

    # Nickname granted.
    on :nick do
      @log.info("Nickname #{@config[:nickname]} granted by the network.")
      join @config[:channel]
    end

    # Channel reached.
    on :join do |who, channel|
      @log.info("Successfully /join-ed #{@config[:channel]}")
      message(channel, "#{@config[:nickname]} is back again!")
      channel_joined(channel)
    end

    # A message was posted.
    on :message do |from, to, msg| # `to' maybe the #channel or a nick
      parse_visible_message(from, to, msg)
    end

  end

  #true if in debug mode, false otherwise.
  def debug_mode?
    @debug
  end

  #Adds a plugin module to IRCBot. See the class’
  #documentation for more information on plugins.
  #==Parameter
  #[plugin] The plugin module to include.
  def use_plugin(plugin)
    @plugins << plugin
    extend(plugin)
  end

  protected

  pluggify do

    #Central handler for parsing messages. This method is hookable,
    #so you can just create a module overriding it and +include+ it
    #into IRCBot, it will then be called automatically. Ensure to
    #call +super+ in your overriden method to ensure it works with
    #further modules.
    #
    #This method is called for every public and private message seen
    #by OpenRubyRMBot.
    #==Parameters
    #[from] The nick who sent the message.
    #[to]   The target #channel or nick.
    #[msg]  The actual message.
    def parse_visible_message(from, to, msg)
      # Do nothing
    end

    #As with #parse_visible_message, you can override this
    #method in your plugin. Works the exact same way, but
    #is called when OpenRubyRMBot joins a channel.
    #==Parameter
    #[channel] The channel the bot just joined to.
    def channel_joined(channel)
      # Do nothing
    end

  end

  #Splits up a message line by line and sends it to the
  #IRC server with a short delay.
  #==Parameters
  #[to]  To whom to send the message.
  #[msg] The actual message.
  def multiline_message(to, msg)
    msg.each_line do |line|
      message(to, line.strip)
      sleep 1 # Network refuses otherwise
    end
  end

end

# Load the files in the plugins/ directory.
# Note this doesn’t automatically enable the plugins
# defined in these files.
OpenRubyRMBot::IRCBot::PLUGINS_DIR.each_child do |path|
  require(path) if path.extname == ".rb"
end
