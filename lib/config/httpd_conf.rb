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
          property, value, valuepath = line.split(" ")   

          if value != nil and value[0] == '"' and value[-1] == '"'
            value = value[1...-1]
          end 

          unless valuepath == nil
            valuepath = valuepath[1...-1]
          end 

          assign(property, value, valuepath)
        end
      end 
    end

    def assign(property, value, valuepath)
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
        when "ScriptAlias"
          @script_aliases.push(value)
          @script_alias_path[value] = valuepath
        when "Alias"
          @aliases.push(value)
          @alias_path[value] = valuepath
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
      @directory_index
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
