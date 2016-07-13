module Cmdlib
  # Class edscribe CLI application (TOP class).
  class App
    OPTION_PREFIX_SHORT = '-'
    OPTION_PREFIX_LONG  = '--'

    # This array contain information to use application.
    attr_accessor :name, :about, :usage
    
    # Version string (will be display to -v or --version).
    attr_accessor :version, :options, :commands
    
    def initialize ( appname )
      @name  = appname
      @about = []
      @usage = []
      @commands = []
      @options = {}
      @default = nil
      @version = '0.1.1'
      
      addopt Option.new( 'V', 'version', 'Display application version.' )
    end

    
    # Add CLICommand object to CLIHandler.
    def addcmd ( cmd )
      raise TypeError, 'Incorrectly types for command object.' unless
	cmd.is_a? Cmdlib::Command

      @commands << cmd
    end

    
    # Add CLICommand object to CLIHandler.
    def addopt ( opt )
      raise TypeError, 'Incorrectly types for option object.' unless
	opt.instance_of? Cmdlib::Option

      @options[opt.longname.to_sym] = opt
    end
    
    
    # Default command for run without arguments.
    def default ( cmd )
      raise TypeError, 'Incorrectly types for command object.' unless
	cmd.is_a? Cmdlib::Command
	
      @default = cmd
    end
    
    
    # Display commands info
    def display_commands( cmdlist )
      maxlen = 0
      cmdlist.each do |cmd|
	maxlen = cmd.name.length if cmd.name.length > maxlen
      end
      cmdlist.each do |cmd|
	print '  ' + cmd.name
	print "#{' ' * (maxlen - cmd.name.length)}  # "
	puts cmd.brief
      end
    end
    
    
    # Display options info
    def display_options( optlist )
      maxlen = 0
      listout = []
      optlist.each_value do |opt|
	optnames = ''
	if opt.shortname.length == 0
          optnames += '  ' 
	else
	  optnames += OPTION_PREFIX_SHORT + opt.shortname
	end
	optnames += ','
	optnames += OPTION_PREFIX_LONG + opt.longname if opt.longname.length != 0
	optnames += '=[...]' if opt.param == true
	listout << { :n => optnames, :b => opt.brief }
	maxlen = optnames.length if optnames.length > maxlen
      end
      listout.each do |opt|
	print '  ' + opt[:n]
	print "#{' ' * (maxlen - opt[:n].length)}  # "
	puts opt[:b]
      end
    end
 
    
    # Main method to run application.
    def run
      option_parser @options
      
      # Check on include version request.
      if @options[:version].value then
	puts "#{@name}, version #{@version}"
	exit
      end

      # Check on include help request.
      if ARGV[0] == 'help' or ARGV[0] == '--help' or ARGV[0] == '-h' then
	# Help arguments apsent, well then display information about application.
	if ARGV.size == 1 then
	  puts
	  puts "*** #{@name} ***".center(80)
	  # Display about info.
	  if @about.size > 0 then
	    puts '** ABOUT:'
	    @about.each do |line|
	      puts "  #{line}"
	    end
	  end
	  # Display usage info.
	  if @usage.size > 0 then
	    puts
	    puts '** USAGE:'
	    @usage.each do |line|
	      puts "  #{line}"
	    end
	  end
	  # Display options info.
	  puts
	  puts '** OPTIONS:'
	  display_options @options
	  # Display commands info
	  if @commands.size > 0 then
	    @commands.each do |c| c.init end
	    puts
	    puts '** COMMANDS:'
	    display_commands @commands
	    puts
	    puts "For details, type: help [COMMAND]"
	  end
	  puts
	# Help arguments exist, find command in application command list.
	else
	  ARGV.delete_at( 0 )
	  cmd = command_select
	  if ARGV.size != 0 then
	    puts "fatal error: unknown command '#{ARGV[0]}'"
	    exit
	  end
	  # Display describe information on command.
	  puts
	  puts Cmdlib::Describe.outtitle( cmd.name )
	  puts "  #{cmd.brief}"
	  if cmd.details.size > 0 then
	    puts
	    puts '** DETAILS:'
	    cmd.details.each do |e|
	      puts "  #{e}"
	    end
	  end
	  if cmd.example.size > 0 then
	    puts
	    puts '** EXAMPLE:'
	    cmd.example.each do |e|
	      puts "  #{e}"
	    end
	  end
	  # Display options info.
	  if cmd.options.size > 0 then
	    puts
	    puts '** OPTIONS:'	  
	    display_options cmd.options
	  end
	  # Display commands info.
	  if cmd.subcmd.size > 0 then
	    cmd.subcmd.each do |c| c.init end
	    puts
	    puts '** SUBCOMMANDS:'
	    display_commands cmd.subcmd
	    puts
	    puts "For details, type: help #{cmd.name} [SUBCOMMAND]"
	  end
	  puts
	end
	exit
      end
      
      # Handling default command (if exist her).
      if @default != nil then
	option_excess
	if ARGV.size < @default.argnum then
	  puts "fatal error: to few arguments for programm, use <help>."
	else
	  @default.handler( @options, ARGV )
	end
	exit
      end
      
      # Handling commands.
      cmd = command_select
      if cmd == nil then
	puts "fatal error: unknown command or command miss, use <help>."
	exit
      end
      if ARGV.size < cmd.argnum then
	puts "fatal error: to few arguments for command, use: <help> <command name>."
	exit
      end
      # Scaning options fir this command
      option_parser cmd.options
      option_excess
      #cmd.init
      cmd.handler( @options, ARGV )
      exit
    end
    
    
    # Search command in command list.
    # Return command object if search success,
    # else return nil.
    # cmdlist -- array with command objects.
    # cmd -- string with command name from ARGV.
    def command_search( cmdlist, cmd )
      cmdlist.each do |c|
	c.init
	return c if c.name == cmd
      end
      return nil
    end
    
    
    # Select and return command object in application.
    def command_select
      command = command_search( @commands, ARGV[0] )
      if command != nil then
        # remove command name from ARGV and search next.
        ARGV.delete_at( 0 )
        ARGV.each do |arg|
	  cmd = command_search( command.subcmd, arg )
	  break if cmd == nil
	  ARGV.delete_at( 0 )
	  command = cmd
        end
      end
      return command
    end
    
    
    # Check input arguments on equal option syntax.
    # if success return option { :n => <argument name>, :t => <option type> },
    # else return '' in all fields.
    def getopt ( opt )
      result = { :n => '', :t => '', }
      if opt.length > OPTION_PREFIX_LONG.length then
        if opt[0, OPTION_PREFIX_LONG.length] == OPTION_PREFIX_LONG then
          result[:n] = opt[OPTION_PREFIX_LONG.length, opt.length]
          result[:t] = OPTION_PREFIX_LONG
          return result
        end
      end
      if opt.length > OPTION_PREFIX_SHORT.length then
        if opt[0, OPTION_PREFIX_SHORT.length] == OPTION_PREFIX_SHORT then
          result[:n] = opt[OPTION_PREFIX_SHORT.length, opt.length]
          result[:t] = OPTION_PREFIX_SHORT
          return result 
        end
      end
      return result
    end


    # Check ARGV to exess options.
    def option_excess
      ARGV.each do |opt|
	o = getopt( opt )
	if o[:n] != '' then
	  puts "fatal error: unknown option '#{o[:t]}#{o[:n]}'"
	  exit
	end
      end
    end
    
    
    # Compare parsing option (form by getopt) with application option.
    # Return true if options is equal, else return false.
    # opt_form -- object formed by getopt.
    # opt_app  -- application option object.
    def option_compare ( opt_form, opt_app )
      case opt_form[:t]
      when OPTION_PREFIX_SHORT
        return true if opt_form[:n][0, opt_app.shortname.length] == opt_app.shortname
      when OPTION_PREFIX_LONG
	return true if opt_form[:n].split('=')[0] == opt_app.longname
      end
      return false
    end
    
    
    # Search option in application options.
    # Return option key-name if option found, else return nil.
    # option  -- object formed by getopt.
    # options -- options object list.
    def option_search( option, options )
      # Search in global options list
      options.each_value do |opt|
        return opt.longname.to_sym if option_compare( option, opt )
      end
      return nil
    end
    
    
    # Set application option object.
    # opt_form -- object formed by getopt.
    # opt_app  -- application option object.
    # Return delete name in ARGV or ''.
    def option_set ( opt_form, opt_app )
      if opt_app.param then
	# option parameter buit-in option name by '='
	if opt_form[:n].include? '=' then
	  opt_app.value = opt_form[:n].split('=')[-1]
	  return ''
	end
	# option parameter buit-in option name
	if opt_form[:t] == OPTION_PREFIX_SHORT and
	   opt_form[:n].length > opt_app.shortname.length then
	  opt_app.value = opt_form[:n][opt_app.shortname.length, opt_form[:n].length - opt_app.shortname.length]
	  return ''
	end
	# option parameter present in next ARGV.
	if opt_form[:i].next >= ARGV.size then
          puts "fatal error: unable to find argument for option '#{opt_form[:n]}'."
          exit
	end
	# if next argument is a option.
	arg = ARGV[opt_form[:i].next]
        if getopt( arg )[:n] != '' then
          puts "fatal error: miss argument for option '#{opt_form[:t]}#{opt_form[:n]}'."
          exit
        end
	opt_app.value = arg
	return arg
      else
	opt_app.value = true
      end
      return ''
    end
    
    
    # Parsing options in command line.
    def option_parser( optlist )
      return if optlist.size == 0
      deletelist = []
      # search option in argument list.
      ARGV.each_with_index do |opt,i|
	o = getopt( opt )
	if o[:n] != '' and o[:n] != 'h' and o[:n] != 'help'
	  o[:i] = i
	  # Search in application list
	  result = option_search( o, optlist )
	  if result != nil then
	    deletelist << opt
	    result = option_set( o, optlist[result] )
	    deletelist << result if result != ''
	  end
	end
      end
      # delete option from ARGV.
      deletelist.each do |n|
	ARGV.delete( n )
      end
    end
    
  end # class App
end # module Cmdlib
