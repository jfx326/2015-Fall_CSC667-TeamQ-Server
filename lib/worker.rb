require_relative 'request'
require_relative 'response'

# This class will be executed in the context of a thread, and
# should instantiate a Request from the client (socket), perform
# any logging, and issue the Response to the client.
module WebServer
  class Worker
    # Takes a reference to the client socket and the logger object
    def initialize(client_socket, server=nil)
      @socket = client_socket
      @server = server

      process_request
    end

    # Processes the request
    def process_request
      # puts "Incoming connection..."

      #TODO: THIS NEEDS ERROR CHECKING!!
      request = Request.new(@socket)
      puts "REQUEST: #{request.http_method} #{request.uri}\n"
      # puts "Request created..."
      resource = Resource.new(request, @server.options[:httpd_conf], @server.options[:mime_types])
      response = Response::Factory.create(resource)
      # puts "Response created..."

      @socket.write response.to_s
      # puts "Response transmitted..."

      @socket.close
      # puts "Connection terminated\n\n"
    end
  end
end
