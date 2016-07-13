module Cmdlib
  class Describe

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
    
  end # class Describe
end # module Cmdlib
