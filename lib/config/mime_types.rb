require_relative 'configuration'

module WebServer
  class MimeTypes < Configuration

    def initialize(mime_file_content)
      super(mime_file_content)
      @mime_types = Hash.new

      parse
    end

    def parse_line(line)
      mime = line.split(' ')

      if mime.size > 1
        mime[1..-1].each do |extension|
          @mime_types[extension] = mime[0]
        end
      end
    end

    def for_extension(extension)
      return @mime_types[extension] != nil ? @mime_types[extension] : 'text/plain'
    end
  end
end
