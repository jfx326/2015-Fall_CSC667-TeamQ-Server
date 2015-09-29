# This class should be used to encapuslate the functionality 
# necessary to open and parse configuration files. See
# HttpdConf and MimeTypes, both derived from this parent class.
module WebServer
  class Configuration
    def initialize(file_content)
      @file_content = file_content
    end

    def parse
      @file_content.each_line do |line|
        parse_line(line) unless line[0] == '#'
      end
    end
  end
end
