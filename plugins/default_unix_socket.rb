module OpenRubyRMBot::Plugins::DefaultUNIXSocket

  def self.name
    "default_unix_socket"
  end

  def channel_joined(channel)
    super
    # Set up the listener for data over the UNIX domain socket.
    @stop_listening_on_unix_socket = false
    listener = lambda do
      socket_path = @config[:socket_path] % {:install => ROOT_DIR.to_s}
      UNIXServer.open(socket_path) do |server|
        @log.info("UNIX domain socket at #{socket_path} ready.")
        loop do
          begin
            # Only one client at a time
            msg = server.accept_nonblock.read
            # Echo everythread read to all channels connected to
            channels.each{|channel| message(channel, msg)}
          rescue IO::WaitReadable
            # accept_nonblock raises this if no client is available.
            # Check whether we are shutting down and if so, end the
            # listing and remove the socket file.
            break if @stop_listening_on_unix_socket
          end
        end
        # Cleanup
        File.delete(socket_path)
      end
    end
    EventMachine.defer(listener)

    # When we disconnect from the IRC server, stop
    # the UNIX socket listening.
    on :disconnect do
      @log.debug("Shutting down UNIX domain socket.")
      @stop_listening_on_unix_socket = true
    end
  end

end
