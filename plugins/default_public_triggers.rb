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

  #Plugin name: *default_public_triggers*
  #
  #Plugin module for IRCBot providing support for public
  #messages containing certain triggers.
  #
  #This module provides the following triggers:
  #
  #[#num]
  #  Posts a ticket URL to the +ticket_url+ defined
  #  in the configuration file.
  #[<botname>:]
  #  Causes a dummy response that this is a bot you can’t talk to.
  #
  #Additionally this plugin provides support for the following
  #additional configuration file directives:
  #
  #[ticket_url]
  #  The URL template to use when the <tt>#num</tt> trigger is
  #  encountered. %{id} in this string is replaced with +num+.
  module DefaultPublicTriggers

    #Name of this plugin as it occurs in the plugin list file.
    def self.name
      "default_public_triggers"
    end

    protected

    #Hooks into IRCBot#parse_message and parses public
    #messages.
    def parse_visible_message(from, to, msg)
      # Allow other hooks to run
      super
      # Only cater for public messages in our channel
      return unless to.downcase == @config[:channel].downcase
      channel = to
      @log.debug("Public message from #{from} in channel #{channel}: #{msg}") if @debug # Performance killer

      # Actual parsing. This is a gist of possible cases in which
      # the bot takes action. Each condition has a short example
      # statement triggering it.
      case msg
      when /^#{@config[:nickname]}[:,]/
        # Assuming the bot is named ORRBot, the default:
        # "ORRBot: Hey you!"
        message(channel, "I'm just a bot, don't try to talk to me!")
      when /#(\d+)/
        # "This is discussed in #43"
        message(channel, "Ticket ##$1 is at #{@config[:ticket_url] % {:id => $1}}")
      end
    end

  end

end
