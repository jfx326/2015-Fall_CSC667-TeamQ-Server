# The Request class encapsulates the parsing of an HTTP Request
module WebServer
  class Request
    attr_accessor :http_method, :uri, :version, :headers, :body, :params

    # Request creation receives a reference to the socket over which
    # the client has connected
    def initialize(socket)
      # Perform any setup, then parse the request

      #TODO: can we get rid of these?
      @headers = Hash.new
      @body = String.new
      @params = Hash.new

      @socket = socket.to_a  
      parse      
    end

    # I've added this as a convenience method, see TODO (This is called from the logger
    # to obtain information during server logging)
    def user_id
      # TODO: This is the userid of the person requesting the document as determined by 
      # HTTP authentication. The same value is typically provided to CGI scripts in the 
      # REMOTE_USER environment variable. If the status code for the request (see below) 
      # is 401, then this value should not be trusted because the user is not yet authenticated.
      '-'
    end

    #TODO: Confused about this
    # Parse the request from the socket - Note that this method takes no
    # parameters
    def parse
      parse_request_line

      #TODO: THIS SHOULD BE \r\n
      header_end = @socket.index("\n")

      @socket[1...header_end].each do |header_line|
        parse_header(header_line)
      end

      @socket[header_end+1..-1].each do |body_line|
        parse_body(body_line)
      end

      @body.chomp!
    end

    # The following lines provide a suggestion for implementation - feel free
    # to erase and create your own...
    def next_line
    end

    def parse_request_line
      @http_method, @uri, @version = @socket[0].split(" ")
      parse_params
    end

    def parse_header(header_line)
      key, value = header_line.split(": ")

      key.upcase!
      key.sub!("-","_")
      value.chomp!
      
      @headers[key] = value
    end

    def parse_body(body_line)
      @body = @body + body_line
    end

    def parse_params      
      @uri, query = @uri.split("?")

      key, value = query.split("=")
      @params[key] = value
    end
  end
end
