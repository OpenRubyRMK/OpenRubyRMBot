# -*- coding: utf-8 -*-

# Cinch plugin that watches for strings of the form
# "#<num>" to occur and pastes a link to the corresponding
# issue on Pegasus Alpha’s bugtracker.
class CinchPlugins::PegaIssues
  include Cinch::Plugin

  # Base URL to which the issue number gets appended.
  ISSUE_BASE_URL = "https://devel.pegasus-alpha.eu/issues"

  set :prefix, //
  match /#(\d+)/

  def execute(msg, num)
    msg.reply("Issue ##{num} is at #{ISSUE_BASE_URL}/#{num}")
  end

end
