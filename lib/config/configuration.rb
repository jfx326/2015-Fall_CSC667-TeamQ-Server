module WebServer
  class Configuration
    def initialize(file_content)
      @file_content = file_content
    end

    def parse
      @file_content.each_line do |line|
        line.chomp!
        parse_line(line) unless line[0] == '#'
      end
    end

    def removeQuotes(val)
      if val != nil and val[0] == '"' and val[-1] == '"'
        val = val[1...-1]
      end

      val
    end
  end
end
