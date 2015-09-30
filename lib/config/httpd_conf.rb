require_relative 'configuration'

module WebServer
  class HttpdConf < Configuration
    attr_reader :server_root, :document_root, :directory_index, :port, :log_file, :access_file_name, :script_aliases, :aliases, :max_requests, :timeout

    #TODO: Errors - malformed syntax, nonexistent properties && Reduce size of this method
    def initialize(httpd_file_content)
      super(httpd_file_content)

      set_defaults
      parse
      validate
    end

    def set_defaults
      @directory_index = 'index.html'
      @access_file_name = '.htaccess'
      @port = 80

      @script_aliases = Array.new
      @aliases = Array.new
      @script_alias_path = Hash.new
      @alias_path = Hash.new
    end

    def parse_line(line)
      property, value, value_path = line.split(' ')

      value = removeQuotes(value)
      value_path = removeQuotes(value_path)

      assign(property, value, value_path)
    end

    def assign(property, value, value_path)
      case property
        when "ServerRoot"
          @server_root = value

        when "DocumentRoot"
          @document_root = value

        when "DirectoryIndex"
          @directory_index = value              
        when "Listen"
          @port = value.to_i
        when "LogFile"
          @log_file = value
        when "AccessFileName"
          @access_file_name = value
        when "MaxKeepAliveRequests"
          @max_requests = value.to_i
        when "KeepAliveTimeout"
          @timeout = value.to_i
        when "ScriptAlias"
          @script_aliases.push(value)
          @script_alias_path[value] = value_path
        when "Alias"
          @aliases.push(value)
          @alias_path[value] = value_path
        else
          @errors.push(Error.new("htttp.conf Error: Unrecognised or Invalid directive"))
      end
    end

    def script_alias_path(path)      
      @script_alias_path[path]
    end

    def alias_path(path)
      @alias_path[path]
    end

    def validate
      @errors.push(Error.new("htttp.conf Error: Invalid ServerRoot path")) if !File.exist?(@server_root)
      @errors.push(Error.new("htttp.conf Error: ServerRoot path can not be a file")) if File.file?(@server_root)
      @errors.push(Error.new("htttp.conf Error: Invalid DocumentRoot path")) if !File.exist?(@document_root)
      @errors.push(Error.new("htttp.conf Error: DocumentRoot path can not be a file")) if File.file?(@document_root)
      @errors.push(Error.new("httpd.conf Error: Invalid Log File path. Given directory doesn't exist")) if !File.exist?(File.dirname(@log_file))
    end
  end
end
