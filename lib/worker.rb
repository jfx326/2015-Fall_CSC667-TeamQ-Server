require 'timeout'
require_relative 'request'
require_relative 'response'
require_relative 'logger'

module WebServer
  class Worker
    # Takes a reference to the client socket and the logger object
    def initialize(client_socket, options={})
      @socket = client_socket
      @options = options
      @request_count = 0

      setup_log
      process_request
      close_request
    end

    def setup_log
      log_file_path = @options[:httpd_conf].log_file

      @logger = Logger.new(log_file_path, @options)
    end
    
    def process_request
      #TODO: THIS NEEDS ERROR CHECKING!!
      max_requests = @options[:httpd_conf].max_requests || 0

      loop do
        @request_count += 1
        evaluate_request

        wait_for_request rescue break
        break if (max_requests > 0 && (@request_count + 1) > max_requests)
      end
    end

    def evaluate_request
      request = Request.new(@socket)
      resource = Resource.new(request, @options[:httpd_conf], @options[:mime_types])
      response = Response::Factory.create(resource)

      @logger.log(request, response)
      @socket.puts response.to_s
    end

    def wait_for_request
      expiry = @options[:httpd_conf].timeout || -1

      Timeout::timeout(expiry) do
        loop { break if(!@socket.eof?) }
      end
    end

    def close_request
      @socket.close

      @logger.close
    end
  end
end
