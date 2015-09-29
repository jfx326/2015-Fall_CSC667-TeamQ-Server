require 'digest'
require 'base64'

module WebServer
  class AuthBrowser
    def initialize(path, access_file_name, doc_root)
      @path = path
      @access_file_name = access_file_name   
      @doc_root = String.new doc_root
      @credentials = Hash.new
    end

    #TODO: Best way to do this?
    def protected?
      directories = @path.gsub(@doc_root, "").split("/")

      if directories.last.include? "."
        directories = directories[0...-1]
      end

      access_file_path = find_access_files(directories)

      if(access_file_path) 
        htaccess_file(access_file_path)
        return true
      else
        return false
      end      
    end

    def authorized? (encrypted_string)
      parse_htpasswd

      user, password = decrypt_access_string(encrypted_string)

      return (@credentials[user] == password) ? true : false
    end

    def parse_htpasswd
      #TODO: Needs error checking
      passwdFile = File.open(@htaccess.auth_user_file, 'r')

      passwdFile.each do |pair|
        #remove \n
        pair.chomp!
        user, passwd = pair.split(":")

        @credentials[user] = passwd
      end

      passwdFile.close
    end

    def find_access_files(directories)    
      check_path = @doc_root
      is_protected = false

      directories.reverse.each do |path| 
        check_path << path + "/"
        is_protected = File.exist?(check_path + @access_file_name)

        if is_protected
          return check_path + @access_file_name
        end
      end

      return false
    end

    def htaccess_file(access_file_path)
      htaccess_content = File.open(access_file_path)
      @htaccess = Htaccess.new(htaccess_content)  
    end

    def decrypt_access_string(access_string)
      credentials = Base64.decode64 access_string
      user, password = credentials.split(":")
      password = "{SHA}" + Digest::SHA1.base64digest(password)

      return user, password
    end

    def users
    end
  end
end