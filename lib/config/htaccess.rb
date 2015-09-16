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

    def authorized? (encrypted_string)
      parse_htpasswd

      credentials = Base64.decode64 encrypted_string
      user, password = credentials.split(":")

      password = "{SHA}" + Digest::SHA1.base64digest(password)

      return (@credentials[user] == password) ? true : false
    end

    def users
      parse_htpasswd

      @credentials.keys
    end

    def parse_htpasswd
      passwdFile = File.open(@auth_user_file, 'r')

      passwdFile.each do |pair|
        #remove \n
        pair.chomp!
        user, passwd = pair.split(":")

        @credentials[user] = passwd
      end

      passwdFile.close
    end
  end
end