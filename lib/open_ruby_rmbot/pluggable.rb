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

#Mixin module making methods in a module overridable by mixins, most useful
#for establishing a plugin structure. This module is used by the IRCBot
#class to define some methods as "hooks" which you can override inside
#a plugin module which then is mixed into IRCBot.
#
#==Example
#Suppose you have a class Machine:
#
#  class Machine
#    
#    def produce
#      #Produce something...
#    end
#    
#  end
#
#Now, what do you do if you want to make your machine easily extendible
#by plugins? Ideally you could say "just create a plugin module, define
#a #produce instance method on it and include it into +Machine+". Now,
#if you try this, you will be bitten by the way Ruby looks up methods;
#if this is your plugin module:
#
#  module MakeItSmarter
#  
#    def produce
#      super
#      #Do something with self...
#    end
#    
#  end
#
#And if you include it like this:
#
#  class Machine
#    include MakeItSmarter
#  end
#
#Then MakeItSmarter#produce won’t be called, because the ancestor hierarchy looks
#like this (read from left to right):
#  Machine < MakeItSmarter < Object
#Now, the Pluggable module does some black magic with anonymous modules; if you
#make your +Machine+ class’ #procude method pluggable, it will work:
#
#  class Machine
#    extend Pluggable
#    
#    pluggify do
#      
#      def produce
#        #Produce something...
#      end
#
#    end
#
#  end
#
#  module MakeItSmarter
#
#    def produce
#      super
#      #Do something with self...
#    end
#
#  end
#
#  class Machine
#    include MakeItSmarter
#  end
#
#This works because the ancestor hierarchy now looks like this:
#
#  Machine < MakeItSmarter < ##Anonymous module## < Object
#                                 ↑ Machine#produce is defined here
module OpenRubyRMBot::Pluggable
  
  #call-seq:
  #  pluggify(){...}
  #
  #Makes all methods defined inside it’s block overridable via
  #+include+ statements in the including class. See the documentation
  #of the Pluggable module for an example.
  #
  #Furthermore, if you define a module called +ClassMethods+ inside the block,
  #this method will automatically extend the including class by it.
  def pluggify(&block)
    mod = Module.new(&block)
    def mod.inspect
      "#<Pluggable anonymous module>"
    end
    include(mod)
  end

end
