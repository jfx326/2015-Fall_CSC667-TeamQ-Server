module WebServer
  class Request
    attr_reader :http_method, :uri, :version, :headers, :body, :params, :socket, :remote_address, :remote_port

    def initialize(socket)
      @socket = socket

      @headers = Hash.new
      @body = String.new
      @params = Hash.new
      @remote_port, @remote_address = Socket.unpack_sockaddr_in(@socket.getpeername)

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

    def parse
      parse_request_line

      @socket.each do |line|
        line.chomp!
        break if line == ''

        parse_header(line)
      end

      if @headers['CONTENT_LENGTH'].to_i > 0
        @socket.each do |body_line|
          parse_body(body_line)
        end

        @body.chomp!
      end

    rescue
      return 400
    end

    def parse_request_line
      @http_method, @uri, @version = @socket.gets.split(' ')

      parse_params
    end

    def parse_header(header_line)
      key, value = header_line.split(": ")

      key.upcase!
      key.sub!("-","_")
      
      @headers[key] = value
    end

    def parse_body(body_line)
      @body << body_line
    end

    def parse_params
      if @uri.include? "?"
        @uri, query = @uri.split('?')

        params = query.split('&')

        params.each do |param|
          key, value = param.split('=')
          @params[key] = value
        end
      end
    end
  end
end
