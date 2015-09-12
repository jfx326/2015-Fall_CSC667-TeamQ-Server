require_relative 'configuration'

# Parses, stores and exposes the values from the mime.types file
module WebServer
  class MimeTypes < Configuration

    def initialize(mime_file_content)
      @mime_types = Hash.new

      mime_file_content.each_line do |line|
        unless line[0] == '#'
          split = line.split(" ")

          if(split.size > 1)
            split[1..-1].each do |extension|
              @mime_types[extension] = split[0]
            end
          end
        end
      end

      puts 
    end
    
    # Returns the mime type for the specified extension
    def for_extension(extension)
      if @mime_types[extension] != nil 
        @mime_types[extension]
      else 
        "text/plain"
      end
    end
  end
end
