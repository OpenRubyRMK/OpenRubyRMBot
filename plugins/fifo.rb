# FIFO plugin for Cinch that allows to create a gate in the
# filesystem to directly paste something into all channels
# Cinch currently is in.
#
# Add the following to your configure.do stanza:
#
#   config.plugins.options[CinchPlugins::Fifo] = {
#     :fifo_path => "/tmp/myfifo"
#   }
#
# +fifo_path+ is the path to the named pipe on the filesystem.
# Note the user running Cinch must have write access in that
# directory.
class CinchPlugins::Fifo
  include Cinch::Plugin

  listen_to :connect, :method => :startup
  listen_to :disconnect, :method => :shutdown

  def startup(msg)
    File.mkfifo(config[:fifo_path])
    File.chmod(0666, config[:fifo_path])

    File.open(config[:fifo_path], "r+") do |fifo|
      bot.log("Opened FIFO (named pipe) at #{config[:fifo_path]}.", :info)

      fifo.each_line do |line|
        msg = line.strip
        bot.log("Got message from the FIFO: #{msg}", :debug)
        bot.channels.each{|channel| channel.send(msg)}
      end
    end
  end

  def shutdown(msg)
    File.delete(config[:fifo_path])
  end

end
