require_relative 'configuration'

# Parses, stores, and exposes the values from the httpd.conf file
module WebServer
  class HttpdConf < Configuration

    #TODO: Errors - malformed syntax, nonexistent properties && Reduce size of this method

    def initialize(httpd_file_content)
      @script_aliases = Array.new
      @aliases = Array.new
      @script_alias_path = Hash.new
      @alias_path = Hash.new

      httpd_file_content.each_line do |line|      
        unless line[0] == '#'
          property, value, value_path = line.split(" ")   

          value = removeQuotes(value)
          value_path = removeQuotes(value_path)

          assign(property, value, value_path)
        end
      end 
    end

    def removeQuotes(val)
      if val != nil and val[0] == '"' and val[-1] == '"'
        val = val[1...-1]
      end 

      val
    end

    def assign(property, value, value_path)
      case property
        when "ServerRoot"
          @server_root = value
          ENV['DOCUMENT_ROOT'] = value
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
        when "ScriptAlias"
          @script_aliases.push(value)
          @script_alias_path[value] = value_path
        when "Alias"
          @aliases.push(value)
          @alias_path[value] = value_path
      end
    end

    #TODO: can we attr_reader these?

    # Returns the value of the ServerRoot
    def server_root 
      @server_root
    end

    # Returns the value of the DocumentRoot
    def document_root
      @document_root
    end

    # Returns the directory index file
    def directory_index
      @directory_index || "index.html"
    end

    # Returns the *integer* value of Listen
    def port
      @port
    end

    # Returns the value of LogFile
    def log_file
      @log_file
    end

    # Returns the name of the AccessFile 
    def access_file_name
      @access_file_name
    end

    # Returns an array of ScriptAlias directories
    def script_aliases
      @script_aliases
    end

    # Returns the aliased path for a given ScriptAlias directory
    def script_alias_path(path)      
      @script_alias_path[path]
    end

    # Returns an array of Alias directories
    def aliases
      @aliases
    end

    # Returns the aliased path for a given Alias directory
    def alias_path(path)
      @alias_path[path]
    end
  end
end
