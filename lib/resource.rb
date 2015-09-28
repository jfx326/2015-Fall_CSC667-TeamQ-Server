module WebServer
  class Resource
    attr_reader :request, :conf, :mimes, :contents, :script

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes
    end

    def resolve
      #TODO: Check if this will get marked down since it return //
      @absolute_path = aliased? || script_aliased? || (@conf.document_root + @request.uri)

      #TODO: Why does or work here and || doesn't?
      unless @request.uri.include? "." or @script
        if @request.uri[-1] != "/"
          @absolute_path << "/"
        end

        @absolute_path << @conf.directory_index
      end

      return @absolute_path
    end

    def process
      resolve

      @auth_browser = AuthBrowser.new(@absolute_path, @conf.access_file_name, @conf.document_root)
      authorized = @auth_browser.protected? ? authorize : 200

      if authorized == 200
        serve
      else
        return authorized
      end
    end

    def serve
      case @request.http_method
        when 'GET', 'HEAD', 'POST'
          File.exist?(@absolute_path) ? retrieve : 404
        when 'PUT'
          #TODO: Could this fail, if not, remove the if block
          #TODO: check if this is right of if the request should overwrite
          !File.exist?(@absolute_path) ? create : 400
        when 'DELETE'
          File.exist?(@absolute_path) ? delete : 404
        else
          return 403
      end
    end

    def retrieve
      if @script
        execute
      else
        file = File.open(@absolute_path, "rb")
        @contents = file.read
        file.close

        return 200
      end
    end

    def execute
      script = IO.popen([env_var, @absolute_path])
      script.write(@request.body)
      @contents = script.read

      return 200
    rescue
      return 500
    end

    def create
      file = File.new(@absolute_path, 'w')
      file.puts @request.body
      file.close

      return 201
    rescue
      return 500
    end

    def delete
      File.delete(@absolute_path) rescue return 500

      return 204
    end

    def authorize
      authorization = request.headers['AUTHORIZATION']

      if authorization != nil
        encrypted_string = authorization.split(' ').last

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

          @script = true

          return path
        end
      end    

      @script = false

      return @script
    end

    def content_type
      ext = @absolute_path.split(".").last

      return mimes.for_extension(ext)
    end

    def env_var
      env = ENV
      env['REQUEST_METHOD'] = @request.http_method
      env['REQUEST_URI'] = @request.uri
      env['REMOTE_ADDRESS'] = @request.remote_address
      env['REMOTE_PORT'] = @request.remote_port.to_s
      env['SERVER_PROTOCOL'] = @request.version
      env.merge!(@request.headers)

      return env
    end
  end
end