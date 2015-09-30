module WebServer
  class Logger

    def initialize(log_file_path, options={})
      @log_file = retrieve(log_file_path)
      @options = options

      @message = String.new
    end

    def retrieve(log_file_path)
      if File.exist?(log_file_path)
        return File.open(log_file_path, 'a')
      else
        return File.new(log_file_path, 'a')
      end
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
      @message << "[#{Time.now.strftime('%a, %F, %T %z')}] "
      @message << "\"#{request.http_method} #{request.uri} #{request.version}\" "
      @message << "#{response.code} "
      @message << ((response.content_length == 0) ? '-' : "#{response.content_length}")
      @message << "\r\n"

      puts @message if @options[:echo]
      @log_file.puts @message
    end

    def close
      @log_file.close
    end
  end
end
