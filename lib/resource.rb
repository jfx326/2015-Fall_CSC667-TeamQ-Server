module WebServer
  class Resource
    attr_reader :request, :conf, :mimes

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes
    end

    def resolve
      @full_path = aliased? || script_aliased? || (@conf.document_root + @request.uri)

      unless @request.uri.include? "."
        if @request.uri[-1] != "/"
          @full_path << "/"
        end

        @full_path << @conf.directory_index
      end

      return @full_path
    end

    def serve
      if resolve
        if ['GET', 'HEAD', 'POST',].include? request.http_method
          if File.exist?(@full_path)
            file = File.open(@full_path, "rb")
            contents = file.read
            file.close

            return contents
          else
            404
          end
        elsif 'PUT' == request.http_method

        else
          400
        end
      else
        500
      end
    end

    def script_aliased? 
      @conf.script_aliases.each do |script_alias|
        if @request.uri.include? script_alias
          sub = @conf.script_alias_path(script_alias)
          path = @request.uri.sub(script_alias, sub)

          return path
        end
      end    

      return false
    end

    #TODO: Check if this should exist. Seriously schould combine the two
    def aliased?      
      @conf.aliases.each do |path_alias|
        if @request.uri.include? path_alias
          sub = @conf.alias_path(path_alias)
          path = @request.uri.sub(path_alias, sub)

          return path
        end
      end

      return false
    end

    #TODO: This is a bit iffy
    def protected?
      File.exist?(@conf.access_file_name)
    end

    def content_type
      ext = @full_path.split(".").last

      return mimes.for_extension(ext)
    end
  end
end