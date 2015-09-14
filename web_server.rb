require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end

module WebServer
  class Server
    attr_reader :options

    DEFAULT_PORT = 2468

    def initialize(options={})
      # Set up WebServer's configuration files and logger here
      # Do any preparation necessary to allow threading multiple requests"    

      @options = options

      puts "Loading Configuration..."   
      httpd_file = File.open('config/httpd.conf', 'rb')
      mime_file = File.open('config/mime.types', 'rb')

      @options[:httpd_conf] = HttpdConf.new(httpd_file)
      puts "Finished loading httpd_conf..."

      @options[:mime_types] = MimeTypes.new(mime_file)
      puts "Finished loading MIME Types..."

      httpd_file.close
      mime_file.close
    end

    def start
      # Begin your 'infinite' loop, reading from the TCPServer, and
      # processing the requests as connections are made

      port = options[:httpd_conf].port || DEFAULT_PORT
      @server ||= TCPServer.open(port)

      puts "Starting server on localhost:#{port}\n\n"
      loop do 
        socket = @server.accept
        puts "Incoming connection..."

        request = Request.new(socket)
        puts "Request created..."
        resource = Resource.new(request, @options[:httpd_conf], @options[:mime_types])
        puts "Requesting resource #{request.uri}"
        response = Response::Factory.create(resource)
        puts "Response created..."

        socket.write response.to_s
        puts "Response transmitted..."

        socket.close
        puts "Connection terminated\n\n"
      end 
    end

    private
  end
end

WebServer::Server.new.start
