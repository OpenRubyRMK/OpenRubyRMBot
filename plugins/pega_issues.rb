# -*- coding: utf-8 -*-

# Cinch plugin that watches for strings of the form
# "#<num>" to occur and pastes a link to the corresponding
# issue on Pegasus Alpha’s bugtracker, whose URL ist set by
# the :base_url option.
class Cinch::PegaIssues
  include Cinch::Plugin

  match /#(\d+)/, :use_prefix => false

  def execute(msg, num)
    msg.reply("Issue ##{num} is at #{config[:base_url]}/#{num}")
  end

end
