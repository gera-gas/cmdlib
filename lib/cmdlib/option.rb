module Cmdlib
  # Class for create option object.
  class Option

    # Contain text with option short name (String).
    attr_accessor :shortname

    # Contain text with option long name (String).
    attr_accessor :longname

    # Contain text with describe option (String).
    attr_accessor :brief

    # Contain option value.
    attr_accessor :value

    # Contain parameter tag, the option can be have a parameter.
    attr_accessor :param

    # Set option shortname (sname) and longname (lname).
    def initialize ( sname, lname, brief = '', param = false )
      raise TypeError, 'Incorrectly types for option constructor.' unless
	sname.instance_of? String and
	lname.instance_of? String and
	brief.instance_of? String

      @shortname = sname
      @longname  = lname
      @brief = brief
      @value = nil
      @param = param
    end
    
  end # class Option

end # module Cmdlib
