module Cmdlib
  # Create class with describe information
  # of any objects.
  class Describe

    # This string have should text with object name.
    attr_accessor :oname

    # This string have should text with brief information.
    attr_accessor :brief

    # This array string have should text with details information.
    attr_accessor :details

    # This array string have should text with examples information.
    attr_accessor :example

    # This array string have should text with tags information.
    attr_accessor :options

    def initialize
      @oname = ''
      @brief = ''
      @details = []
      @example = []
      @options = []
    end

    # Display title in follow format: *** [title] ***.
    def self.outtitle ( str )
      if( str.length < (80-4) ) then
	borderlen = 80 - str.length - 4
	print '*' * (borderlen/2)
	print '[ '
	print str
	print ' ]'
	puts '*' * (borderlen/2)
      else
	puts str
      end
    end

    # Display all information about object.
    def display
      puts
      Describe.outtitle( @oname )
      puts
      puts ' ' + @brief
      puts
      puts '** DESCRIBE:'
      @details.each do |line|
	puts ' ' + line
      end
      puts
      puts '** EXAMPLE:'
      @example.each do |line|
	puts ' ' + line
      end
      puts
    end
  end # class Describe

end # module Cmdlib
