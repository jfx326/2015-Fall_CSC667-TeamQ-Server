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

      httpd_file = File.open('config/httpd.conf', 'rb')
      mime_file = File.open('config/mime.types', 'rb')

      @options[:httpd_conf] = HttpdConf.new(httpd_file)
      @options[:mime_types] = MimeTypes.new(mime_file)

      httpd_file.close
      mime_file.close
    end

    def start
      port = options[:httpd_conf].port || DEFAULT_PORT
      @server ||= TCPServer.open(port)
      puts "Starting server on localhost:#{port}\n\n"

      loop do
        socket = @server.accept
        Thread.new { Worker.new(socket, self) }
      end
    end

    private
  end
end

WebServer::Server.new.start
