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

require "logger"
require "em-irc"

#Namespace for this project.
module OpenRubyRMBot

  #The version number of this program.
  VERSION = "0.0.1-dev"

  #Namespace containing the loadable plugins. This namespace
  #is usually filled by files in the plugins/ directory of
  #your OpenRubyRMBot installation; see IRCBot for an
  #explanation of writing plugins.
  module Plugins
  end

end

require_relative "open_ruby_rmbot/pluggable"
require_relative "open_ruby_rmbot/irc_bot"
