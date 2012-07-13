# -*- coding: utf-8 -*-
# This file is part of OpenRubyRMBot.
# 
# Copyright © 2012 OpenRubyRMK Team
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

module OpenRubyRMBot::Plugins

  #Plugin name: *default_private_commands*
  #
  #Plugin module for IRCBot handling private messages addressed to
  #the bot.
  #
  #This module currently provides the following commands to the bot:
  #
  #[help]
  #  Gives a link to the OpenRubyRMK wiki describing which commands
  #  the IRCBot understands.
  #
  #If an unknown command is encountered, automatically sends the
  #message for the +help+ command plusan error message.
  module DefaultPrivateCommands

    #Name of this plugin as it occurs in the plugin list file.
    def self.name
      "default_private_commands"
    end

    protected

    #Hooks into IRCBot#parse_message and parses private
    #messages.
    def parse_visible_message(from, to, msg)
      # Allow other hooks to run
      super
      # Only care for private messages
      return unless to.downcase == @config[:nickname].downcase

      # Actual parsing
      @log.debug("PM from #{from}: #{msg}")
      # `to' is always the bot’s nickname for this method
      case msg
      when /^help$/i
        multiline_message(from, @config[:help] % {:nickname => @config[:nickname], :version => OpenRubyRMBot::VERSION})
      else
        multiline_message(from, @config[:help] % {:nickname => @config[:nickname], :version => OpenRubyRMBot::VERSION})
        message(from, "I didn't got this, sorry: #{msg}")
      end
    end

  end

end
