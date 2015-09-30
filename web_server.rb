require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end

module WebServer
  class Server
    attr_reader :options

    DEFAULT_PORT = 2468

    def initialize(options={})
      @options = options
      @options[:echo] = true

      httpd_file = File.open('config/httpd.conf', 'rb')
      mime_file = File.open('config/mime.types', 'rb')

      @options[:httpd_conf] = HttpdConf.new(httpd_file)
      @options[:mime_types] = MimeTypes.new(mime_file)

      httpd_file.close
      mime_file.close
    end

    def start
      raise LoadError if (@options[:httpd_conf].errors.count > 0)

      server

      loop do
        socket = @server.accept

        Thread.new { Worker.new(socket, @options) }
      end
    rescue LoadError
      puts "Aborting server start - configuration errors"

      @options[:httpd_conf].errors.map { |e| puts e.message }
    end

    def server
      port = options[:httpd_conf].port || DEFAULT_PORT
      @server ||= TCPServer.open(port)

      puts "Starting server on localhost:#{port}\n\n"
    end
  end
end

WebServer::Server.new.start
