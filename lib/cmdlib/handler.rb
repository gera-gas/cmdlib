module Cmdlib
  # Class with methods for handled commands
  # from CLI application.
  class Handler
    OPTION_PREFIX_SHORT = '-'
    OPTION_PREFIX_LONG  = '--'

    # This array contain information to use application.
    attr_accessor :usage

    def initialize
      @usage = []
      @cmdlist = []
      @optlist = []
    end

    # Add CLICommand object to CLIHandler.
    def addcmd ( cmd )
      raise TypeError, 'Incorrectly types for command object.' unless
	cmd.respond_to? :describe and
	cmd.respond_to? :handler and
	cmd.describe.instance_of? Describe

      @cmdlist << cmd
    end

    # Add CLICommand object to CLIHandler.
    def addopt ( opt )
      raise TypeError, 'Incorrectly types for option object.' unless
	opt.respond_to? :brief and
	opt.respond_to? :shortname and
	opt.respond_to? :longname and
	opt.respond_to? :value and
	opt.respond_to? :param and
	opt.brief.instance_of? String

      @optlist << opt
    end

    # Main handler method, execute command handler.
    def run
      # parsing options.
      optparser

      # handled position arguments.
      if ARGV.size > 0 then
	if ARGV[0] == 'help' or ARGV[0] == '--help' or ARGV[0] == '-h' then
	  # display help specificly command.
	  if ARGV.size == 2 then
	    @cmdlist.each do |e|
	      if ARGV[1] == e.describe.oname then
		e.describe.display
		exit
	      end
	    end
	    puts "fatal error: unknown command with name - #{ARGV[1]}"
	  # display usage help.
	  else
	    puts
	    # dislpay usage information.
	    @usage.each do |e|
	      puts e
	    end
	    if @cmdlist.size > 0 then
	      puts
	      puts '** COMMANDS:'
	      maxlen = 0
	      # dislpay command list.
	      @cmdlist.each do |e|
		maxlen = e.describe.oname.length if e.describe.oname.length > maxlen
	      end
	      @cmdlist.each do |e|
		print '  ' + e.describe.oname
		print "#{' ' * (maxlen - e.describe.oname.length)}  -- "
		puts e.describe.brief
	      end
	      puts
	      puts '  For details type: help <command>'
	    end
            puts
	    # display options list.
	    if @optlist.size > 0 then
	      puts '** OPTIONS:'
	      maxlen = 0
	      # make shortname to string with option names.
	      listout = []
	      @optlist.each do |e|
		optnames = ''
		if e.shortname.length == 0
		  optnames += '  ' 
		else
		  optnames += OPTION_PREFIX_SHORT + e.shortname
		end
		optnames += ','
		if e.longname.length != 0
		  optnames += OPTION_PREFIX_LONG + e.longname
		end
		listout << optnames
		maxlen = optnames.length if optnames.length > maxlen
	      end
	      # make longname to string with option names.
	      @optlist.each_with_index do |e,i|
		print '  ' + listout[i]
		print "#{' ' * (maxlen - listout[i].length)}  -- "
		puts e.brief
	      end
              puts
	    end
	  end
	else
	  # handling input command.
	  @cmdlist.each do |e|
	    if ARGV[0] == e.describe.oname then
              # check arguments numbers.
              if e.argnum != nil then
                if (ARGV.size - 1) != e.argnum then
	          puts 'fatal error: wrong arguments for program.'
                  exit
                end
              end
              # run handler of command.
	      e.handler
	      exit
	    end
	  end
	  puts "fatal error: unknown command with name - #{ARGV[0]}"
	end
	# exit, after handled all arguments.
	exit
      end
    end

    # Check input arguments on equal option syntax.
    # Return option name if success, else return ''.
    def getopt ( opt )
      if opt.length > OPTION_PREFIX_LONG.length then
	return opt[OPTION_PREFIX_LONG.length, opt.length] if opt[0, OPTION_PREFIX_LONG.length] == OPTION_PREFIX_LONG
      end
      if opt.length > OPTION_PREFIX_SHORT.length then
	return opt[OPTION_PREFIX_SHORT.length, opt.length] if opt[0, OPTION_PREFIX_SHORT.length] == OPTION_PREFIX_SHORT
      end
      return ''
    end

    # parse command line on the option exist.
    def optparser
      options = []
      # search option in option list. 
      ARGV.each_with_index do |opt,i|
	r = getopt( opt )
	options << i if r != '' and r != 'h' and r != 'help'
      end
      # handling each option in list.
      options.each do |oi|
	# find option in CLIHandler list.
	@optlist.each do |opt|
	  argval = getopt( ARGV[oi] )
	  # if option has a parameter.
	  if opt.param then
	    # if option-value set in next argument.
	    if argval == opt.longname or
	       argval == opt.shortname then
	      # argument is not set.
	      if oi.next >= ARGV.size then
                puts "fatal error: unable to find argument for option '#{ARGV[oi]}'."
                exit
	      end
              # if next argument option.
              if getopt( ARGV[oi.next] ) != '' then
                puts "fatal error: miss argument for option '#{ARGV[oi]}'."
                exit
              end
              opt.value = ARGV[oi.next]
	      options << oi.next
	      next
	    end
	    # if option-value built-in option.
	    oname = opt.shortname
	    oname = opt.longname if ARGV[oi][0, OPTION_PREFIX_LONG.length] == OPTION_PREFIX_LONG
	    if argval[0, oname.length] == oname then
	      opt.value = argval[oname.length, argval.length - oname.length]
              # delete assign symbols.
              opt.value = opt.value[1, opt.value.length - 1] if opt.value[0] == '='
	    end
	  # single (toggle) option.
	  else
	    if argval == opt.longname or
	       argval == opt.shortname then
	      opt.value = true
	    end
	  end
	end
      end
      # delete option from ARGV.
      onamelist = []
      options.each do |oi|
	onamelist << ARGV[oi]
      end
      onamelist.each do |oname|
	ARGV.delete( oname )
      end
    end
  end # class Handler

end # module Cmdlib
