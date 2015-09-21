module WebServer
  class Logger

    # Takes the absolute path to the log file, and any options
    # you may want to specify.  I include the option :echo to 
    # allow me to decide if I want my server to print out log
    # messages as they get generated
    
    # TODO: clarify "I include option :echo...?"
    
    # log_file_path already defined at httpd_conf.conf
    def initialize(log_file_path, options={})
      @options = options
      
      unless @options.has_key?(:echo) # please see TODO above
        @options[:echo] = File.open(log_file_path, 'a')
      end
      
      message = Time.now.strftime('%a, %e %b %Y %H:%M:%S %Z') + "\r\n"
      message << "Connection opened.\r\n"
      puts message
      @options[:echo].puts message
    end

    # Log a message using the information from Request and 
    # Response objects
    def log(request, response)
      message = "User #{request.user_id} requested with "
      message << "HTTP/#{request.version} at #{request.uri}:\r\n"
      message << "Headers:\r\n"
      request.headers.each do |header, value|
        message << "#{header}: #{value}\r\n"
      end
      
      message << "Options:\r\n"
      request.params.each do |option, value|
        message << "#{option}: #{value}\r\n"
      end
      
      message << "Server responded with #{response.code}.\r\n"
      
      puts message
      @options[:echo].puts message
    end

    # Allow the consumer of this class to flush and close the 
    # log file
    def close
      message = "Connection closed.\r\n"
      puts message
      @options[:echo].puts message
      @options[:echo].close
    end
  end
end
