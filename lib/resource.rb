module WebServer
  class Resource
    attr_reader :request, :conf, :mimes, :contents

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
      case request.http_method
        when 'GET'
          retrieve
        when 'HEAD'
          retrieve
        when 'POST'

        when 'PUT'
          create
        else
          return 403
      end
    end

    def retrieve
      resolve

      @auth_browser = AuthBrowser.new(@full_path, @conf.access_file_name, @conf.document_root)
      authorized = @auth_browser.protected? ? authorize : 200

      if authorized == 200
        if File.exist?(@full_path)
          file = File.open(@full_path, "rb")
          @contents = file.read
          file.close

          return 200
        else
          return 404
        end
      else
        return authorized
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

    def authorize
      authorization = request.headers['AUTHORIZATION']

      if authorization != nil
        encrypted_string = authorization.split(" ").last

        if @auth_browser.authorized?(encrypted_string)
          return 200
        else
          return 403
        end
      else
        return 401
      end
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

    def content_type
      ext = @full_path.split(".").last

      return mimes.for_extension(ext)
    end
  end
end