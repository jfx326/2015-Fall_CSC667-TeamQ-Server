module WebServer
  class Error < StandardError
    attr_reader :message

    def initialize(message, code=nil)
      @message = message
      @code = nil
    end
  end
end
