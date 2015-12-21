module Cmdlib
  # Class for create command object.
  class Command

    # Contain object with describe text.
    attr_accessor :describe

    # Numbers of required arguments.
    attr_accessor :argnum

    def initialize
      @describe = Describe.new
      @argnum = nil
    end

    def handler
      puts "fatal error: do not set handler for '#{@describe.oname}' command."
    end
  end # class Command

end # module Cmdlib
