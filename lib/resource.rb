module WebServer
  class Resource
    attr_reader :request, :conf, :mimes, :contents

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes
    end

    def resolve
      #TODO: Check if this will get marked down since it return //
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
      case request.http_method
        when 'GET'
          retrieve
        when 'HEAD'
          retrieve
        when 'POST'
          process
        when 'PUT'
          create
        else
          403 #TODO: Unauthorized? or 400 Bad Request
      end
    end

    def retrieve
      if File.exist?(@full_path)
        file = File.open(@full_path, "rb")
        @contents = file.read
        file.close

        return 200
      else
        404
      end
    end

    def process
      #TODO: I have no idea what this should actually be doing...
      if request.body != nil
        #TODO: assuming property=value& sequence
        params = body.split("&")
        params.each do |param|
          @contents << param[0] + ": " + param[1]
        end

        return 200
      else
        return 400
      end
    end

    def create
      #TODO: Check if this is append if exists or create
      unless File.exist?(@full_path)
        #TODO: Could this fail, if not, remove the if block
        if file = File.new(@full_path, "w")
          file.puts @request.body
          file.close

          return 201
        end
      else
        #TODO: check if this is right of if the request should overwrite
        return 400
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
      File.exist? @conf.access_file_name
    end

    def content_type
      ext = @full_path.split(".").last

      return mimes.for_extension(ext)
    end
  end
end