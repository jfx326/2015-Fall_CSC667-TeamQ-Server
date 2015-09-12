require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end

module WebServer
  class Server
    attr_reader :options, :http_conf, :mime_types

    DEFAULT_PORT = 2468

    def initialize(options={})
      # Set up WebServer's configuration files and logger here
      # Do any preparation necessary to allow threading multiple requests"    

      @options = options

      httpd_file = File.open('config/httpd.conf', 'rb')
      mime_file = File.open('config/mime.types', 'rb')

      @httpd_conf = HttpdConf.new(httpd_file)
      @mime_types = MimeTypes.new(mime_file)

      httpd_file.close
      mime_file.close
    end

    def start
      # Begin your 'infinite' loop, reading from the TCPServer, and
      # processing the requests as connections are made
    end

    private
  end
end

WebServer::Server.new.start
