require 'open3'

module WebServer
  class Resource
    attr_reader :request, :conf, :mimes, :contents, :script

    def initialize(request, httpd_conf, mimes)
      @request, @conf, @mimes = request, httpd_conf, mimes
    end

    def process
      resolve

      @auth_browser = AuthBrowser.new(@absolute_path, @conf.access_file_name, @conf.document_root)
      authorized = @auth_browser.protected? ? authorize : 200

      return authorized == 200 ? serve : authorized
    end

    def resolve
      @absolute_path = aliased? || script_aliased? || (@conf.document_root + @request.uri)

      if !@absolute_path.include?('.') && !@script
        @absolute_path << "/#{@conf.directory_index}"
      end

      return @absolute_path
    end

    def serve
      case @request.http_method
        when 'GET', 'HEAD', 'POST'
          File.exist?(@absolute_path) ? retrieve : 404
        when 'PUT'
          create
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
        file = File.open(@absolute_path)
        @contents = file.read
        file.close

        return 200
      end
    rescue
       return Error.new('Unable to open resource', 500)
    end

    def execute
      if (@request.http_method == 'POST')
        @request.parse_params(@request.body)
      end

      args = @request.params

      @contents = IO.popen([env, @absolute_path, *args]).read

      return 200
    rescue
      return Error.new('Script Execution Error', 500)
    end

    def create
      file = File.new(@absolute_path, 'w')
      file.puts @request.body
      file.close

      return 201
    rescue
      return Error.new('Unable to create resource', 500)
    end

    def delete
      File.delete(@absolute_path) rescue return Error.new('Unable to delete resource', 500)
      return 204
    end

    def authorize
      authorization = request.headers['AUTHORIZATION']

      if authorization != nil
        encrypted_string = authorization.split(' ').last

        return Error.new('Unable to Authenticate', 500) if @auth_browser.htaccess.errors.count > 0
        return @auth_browser.authorized?(encrypted_string) ? 200 : 403
      else
        @contents = @auth_browser.htaccess.auth_name

        return 401
      end
    end

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
      ext = @absolute_path.split('.').last

      return mimes.for_extension(ext)
    end

    def env
      env = {
        'DOCUMENT_ROOT' => @conf.document_root,
        'REQUEST_METHOD' => @request.http_method,
        'REQUEST_URI' => @request.uri,
        'REMOTE_ADDRESS' => @request.socket.peeraddr[1],
        'REMOTE_PORT' => @request.socket.peeraddr[3],
        'SERVER_PROTOCOL' => @request.version
      }
      env.merge!(@request.headers)

      return env
    end
  end
end