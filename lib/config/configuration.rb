module WebServer
  class Configuration
    attr_reader :errors

    def initialize(file_content)
      @file_content = file_content
      @errors = Array.new
    end

    def parse
      @file_content.each_line do |line|
        line.chomp!
        parse_line(line) unless line[0] == '#'
      end
    end

    def removeQuotes(val)
      return val.chomp('"').reverse.chomp('"').reverse if val
    end
  end
end
