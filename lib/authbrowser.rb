require 'digest'
require 'base64'

module WebServer
  class AuthBrowser
    attr_reader :htaccess

    def initialize(path, access_file_name, doc_root)
      @path, @access_file_name = path, access_file_name
      @doc_root = String.new doc_root
      @credentials = Hash.new
    end

    def protected?
      directories = @path.sub(@doc_root, "").split("/")

      access_file_path = find_access_files(directories)

      return (access_file_path) ? htaccess_file(access_file_path) : false
    end

    def authorized? (encrypted_string)
      parse_htpasswd

      user, password = decrypt_access_string(encrypted_string)
      required = @htaccess.require_user

      if required == 'valid-user'
        return (@credentials[user] == password) ? true : false
      else
        return (required == user && @credentials[required] == password) ? true : false
      end
    end

    def parse_htpasswd
      #TODO: Needs error checking
      passwdFile = File.open(@htaccess.auth_user_file, 'r')

      passwdFile.each do |pair|
        pair.chomp!
        user, passwd = pair.split(':')

        @credentials[user] = passwd
      end

      passwdFile.close
    end

    def find_access_files(directories)    
      check_path = @doc_root

      directories.each do |path|
        check_path << path + '/'

        return check_path if File.exist?(check_path + @access_file_name)
      end

      return false
    end

    def htaccess_file(access_file_path)
      htaccess_content = File.open(access_file_path + @access_file_name)
      @htaccess = Htaccess.new(htaccess_content)  
    end

    def decrypt_access_string(access_string)
      credentials = Base64.decode64 access_string
      user, password = credentials.split(':')
      password = '{SHA}' + Digest::SHA1.base64digest(password)

      return user, password
    end
  end
end