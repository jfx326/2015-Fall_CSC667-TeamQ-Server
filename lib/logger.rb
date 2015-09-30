module WebServer
  class Logger

    # Takes the absolute path to the log file, and any options
    # you may want to specify.  I include the option :echo to 
    # allow me to decide if I want my server to print out log
    # messages as they get generated
    
    # log_file_path already defined at httpd_conf.conf
    def initialize(log_file_path, options={})
      @log_file = File.open(log_file_path, 'a')
      @options = options

      @message = String.new
    end

    # Log a message using the information from Request and 
    # Response objects
    
    # CLF (from http://httpd.apache.org/docs/2.2/mod/mod_log_config.html)
    # "%h %l %u %t \"%r\" %>s %b"
    # %h	Remote host
    # %l	Remote logname (from identd, if supplied). This will return a dash
    #     unless mod_ident is present and IdentityCheck is set On.
    # %u	Remote user (from auth; may be bogus if return status (%s) is 401)
    # %t	Time the request was received (standard english format)
    # %r	First line of request
    # %s	Status. 
    # %b	Size of response in bytes, excluding HTTP headers. In CLF format,
    #     i.e. a '-' rather than a 0 when no bytes are sent.
    
    # for remote logname (%l) just use "-"
    def log(request, response)
      @message = "#{request.socket.peeraddr[3]} - #{request.user_id} "
      @message << "[" + Time.now.strftime('%a, %F, %T %z') + "] "
      @message << "\"#{request.http_method} #{request.uri} #{request.version}\" "
      @message << "#{response.code} "
      
      if response.content_length == 0
        @message << "-"
      else
        @message << "#{response.content_length}"
      end
      
      @message << "\r\n"
    end

    # Allow the consumer of this class to flush and close the 
    # log file
    def close
      # if :echo option given, also print message to console
      if @options.has_key?(:echo) && @options[:echo] == true
        puts @message
      end
      
      @log_file.puts @message
      @log_file.close
    end
  end
end
