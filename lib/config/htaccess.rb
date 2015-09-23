module WebServer
  class Htaccess
    attr_reader :auth_user_file, :auth_type, :auth_name, :require_user

    def initialize(htaccess_file_content)
      @htaccess = htaccess_file_content
      @credentials = Hash.new

      parse
    end

    def parse
      @htaccess.each_line do |line|
        key, value = line.split(" ", 2)

        #Remove quotes and \n from the end of the line
        value = value.chomp.chomp('"').reverse.chomp('"').reverse

        #TODO: should do some error checking on this
        case key
          when "AuthUserFile"
            @auth_user_file = value
          when "AuthType"
            @auth_type = value
          when "AuthName"
            @auth_name = value
          when "Require"
            @require_user = value
        end
      end
    end
  end
end