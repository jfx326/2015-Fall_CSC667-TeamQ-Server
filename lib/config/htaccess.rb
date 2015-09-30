require_relative 'configuration'

module WebServer
  class Htaccess < Configuration
    attr_reader :auth_user_file, :auth_type, :auth_name, :require_user

    def initialize(htaccess_file_content)      
      super(htaccess_file_content)

      parse
    end

    def parse_line(line)
      key, value = line.split(' ', 2)

      value = removeQuotes(value)

      #TODO: should do some error checking on this
      case key
        when 'AuthUserFile'
          @auth_user_file = value
        when 'AuthType'
          @auth_type = value
        when 'AuthName'
          @auth_name = value
        when 'Require'
          @require_user = (value == 'valid-user') ? value : value.split(' ').last
      end
    end
  end
end