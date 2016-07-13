module Cmdlib
  # Class for create command object.
  class Command

    # Contain object with describe text.
    attr_accessor :name, :brief, :details, :example

    # List with options for command and subcommand.
    attr_accessor :options, :subcmd
    
    # Mandatory argument numbers for command.
    attr_accessor :argnum

    def initialize
      @name  = ''
      @brief = ''
      @details = []
      @example = []
      @options = {}
      @subcmd  = []
      @argnum  = 0
    end

    def init
    end
    
    def handler( global_options, args )
      puts "error: handler do not set for this command."
    end
    
    def addopt ( opt )
      raise TypeError, 'Incorrectly types for option object.' unless
	opt.instance_of? Cmdlib::Option
	
      @options[opt.longname.to_sym] = opt
    end
    
    def addcmd ( cmd )
      raise TypeError, 'Incorrectly types for command object.' unless
	cmd.is_a? Cmdlib::Command

      @subcmd << cmd
    end

  end # class Command
end # module Cmdlib
