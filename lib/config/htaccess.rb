require_relative 'configuration'

module WebServer
  class Htaccess < Configuration
    attr_reader :auth_user_file, :auth_type, :auth_name, :require_user

    def initialize(htaccess_file_content)      
      super(htaccess_file_content)

      parse
      validate
    end

    def parse_line(line)
      key, value = line.split(' ', 2)

      value = removeQuotes(value)

      case key
        when 'AuthUserFile'
          @auth_user_file = value
        when 'AuthType'
          @auth_type = value
        when 'AuthName'
          @auth_name = value
        when 'Require'
          #Specific users specified in format 'Require: user jrob' -- split(' ').last will return the required user
          @require_user = (value == 'valid-user') ? value : value.split(' ').last
      end
    end

    def validate
      if !File.exist?(@auth_user_file)
        msg = 'htaccess Error: Invalid AuthUserFile path'
        @errors.push(Error.new(msg))
        puts msg
      end
    end
  end
end