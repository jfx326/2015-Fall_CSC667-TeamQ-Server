require 'open3'

module WebServer
  class Resource
    attr_reader :request, :conf, :mimes, :contents, :script

    def initialize(request, httpd_conf, mimes)
      @request, @conf, @mimes = request, httpd_conf, mimes
    end

    def resolve
      #TODO: Check if this will get marked down since it return //
      @absolute_path = aliased? || script_aliased? || (@conf.document_root + @request.uri)

      #TODO: Why does or work here and || doesn't?
      @absolute_path << @conf.directory_index if @absolute_path[-1] == "/"

      return @absolute_path
    end

    def process
      resolve

      @auth_browser = AuthBrowser.new(@absolute_path, @conf.access_file_name, @conf.document_root)
      authorized = @auth_browser.protected? ? authorize : 200

      return authorized == 200 ? serve : authorized
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
      args = (@request.http_method == 'POST') ? @request.body : @request.params
      @contents = IO.popen([env_var, @absolute_path, *args]).read

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

        return @auth_browser.authorized?(encrypted_string) ? 200 : 403
      else
        @contents = @auth_browser.htaccess.auth_name

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
      env_var = Hash.new
      env_var['REQUEST_METHOD'] = @request.http_method
      env_var['REQUEST_URI'] = @request.uri
      env_var['REMOTE_ADDRESS'] = @request.remote_address
      env_var['REMOTE_PORT'] = @request.remote_port.to_s
      env_var['SERVER_PROTOCOL'] = @request.version
      env_var.merge!(@request.headers)

      return env_var
    end
  end
end