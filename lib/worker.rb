require 'timeout'
require_relative 'request'
require_relative 'response'
require_relative 'logger'

module WebServer
  class Worker

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
      keep_alive = @options[:httpd_conf].keep_alive
      max_requests = @options[:httpd_conf].max_requests

      loop do
        @request_count += 1
        evaluate_request

        if keep_alive
          wait_for_request rescue break
          break if (max_requests > 0 && (@request_count + 1) > max_requests)
        else
          break
        end
      end
    end

    def evaluate_request
      request = Request.new(@socket)
      request.parse
      resource = Resource.new(request, @options[:httpd_conf], @options[:mime_types])
      response = Response::Factory.create(resource)

    rescue Error => e
      response = Response::BadRequest.new
    ensure
      @logger.log(request, response)
      @socket.puts response.to_s
    end

    def wait_for_request
      expiry = @options[:httpd_conf].timeout

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
