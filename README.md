# Cmdlib

Simple constructor of CLI (Command Line Interface) handler.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cmdlib'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cmdlib

## Usage
Gem have a three base types.
* Cmdlib::Option  -- Create options.
* Cmdlib::Command -- Create commands.
* Cmdlib::App     -- Create application.

Gem set (Cmdlib::App.new) default version value to '0.1.1'.
For modify version use:
```ruby
app = Cmdlib::App.new( 'myapp' )
app.version = '1.1.1'
```

#### Simple application example
Use `.default` method for create signle function application (Application don't have a commands).

```ruby
require 'cmdlib.rb'

# Create default command.
class Echo < Cmdlib::Command
  def handler ( global_options, args )
    line = ''
    args.each do |a|
      line += "#{a} "
    end
    puts line
  end
end

# Create CLI handler.
app = Cmdlib::App.new( 'echo' )
app.about << 'display a line of text.'

# Add default command.
app.default Echo.new

# Run CLI handler.
app.run
```
    $ ruby echo.rb Some Text!
    Some Text!

#### Global options example
Create global option `--name` for all commands in application. If option have a parameter,
then last argument in `Cmdlib::Option.new` should set in `true`.

```ruby
require 'cmdlib.rb'

# Create default command.
class Hello < Cmdlib::Command
  def handler ( global_options, args )
    hello = "Hello"
    # If value do not contain nil, those option is present.
    # Parameter of option can be set as: -nJohn or -n=John or -n John
    hello += " #{global_options[:name].value}" if global_options[:name].value != nil
    puts hello
  end
end

# Create CLI handler.
app = Cmdlib::App.new( 'hello' )
app.about << 'This program say hello.'
app.usage << 'ruby hello.rb [OPTIONS ...]'

# Create global options object.
app.addopt Cmdlib::Option.new( 'n', 'name', 'Option set name for hello message.', true )
# Add default command.
app.default Hello.new

# Run CLI handler.
app.run
```
    $ ruby hello.rb -h
                                 *** hello ***                                  
    ** ABOUT:
      This program say hello.

    ** USAGE:
      ruby hello.rb [OPTIONS ...]

    ** OPTIONS:
      -V,--version     # Display application version.
      -n,--name=[...]  # Option set name for hello message.

    $ ruby hello.rb
    Hello
      
    $ ruby hello.rb -nJohn
    Hello John

#### Commands example
Create application that calculation square and cube on input number.
```ruby
require 'cmdlib.rb'

# Create handler for 'square' command.
class Square < Cmdlib::Command
  # Redefine init to set command attribute.
  def init
    @name = 'square'
    @brief = 'Calculation square of number.'
    @details << 'Command call format: ruby pow.rb square <number>.'
    @example << 'ruby pow.rb square 2'
    # Set numbers of parameters for this command.
    @argnum = 1
  end
  
  # Redefine default handler
  def handler ( global_options, args )
    # if value do not contain nil, those option is present.
    numb = args[0].to_i
    if global_options[:verbose].value != nil then
      puts "Square of #{numb} => #{numb * numb}"
    else
      puts "#{numb * numb}"
    end
  end
end


# Create handler for 'cube' command.
class Cube < Cmdlib::Command
  # Redefine init to set command attribute.
  def init
    @name = 'cube'
    @brief = 'Calculation cube of number.'
    @details << 'Command call format: ruby pow.rb cube <number>.'
    @example << 'ruby pow.rb cube 2'
    # Set numbers of parameters for this command.
    @argnum = 1
  end

  # Redefine default handler
  def handler ( global_options, args )
    # if value do not contain nil, those option is present.
    numb = args[0].to_i
    if global_options[:verbose].value != nil then
      puts "Cube of #{numb} => #{numb * numb * numb}"
    else
      puts "#{numb * numb * numb}"
    end
  end
end


# Create CLI application.
app = Cmdlib::App.new( 'pow' )
app.about << 'Calculation square and cube of number.'
app.usage << 'ruby pow.rb COMMAND [OPTIONS...]'
app.version = '1.0.0'

# Create global options.
app.addopt Cmdlib::Option.new( 'v', 'verbose', 'Option enable verbose mode.' )

# Add commands to application.
app.addcmd Square.new
app.addcmd Cube.new

# Run CLI handler.
app.run
```

#### SubCommands example
Create command `remote` for create connectin to localhost and two subcommands: `tcp` and `domain`.
Subcommand `tcp` have a option `--port`.
```ruby
require 'cmdlib.rb'

# Subcommand class.
class ConnectTCP < Cmdlib::Command
  def init
    @name = 'tcp'
    @brief = 'Connection to server by IP address (default port: 1234).'
    @example << 'ruby remote.rb connect TCP [IP ADDRESS]'
    @argnum = 1
    
    # Add option for this subcmd.
    addopt Cmdlib::Option.new( 'p', 'port', 'Option set connection port.', true )
  end
  
  def handler ( global_options, args )
    address = args[0]
    address += ":#{@options[:port].value}" if @options[:port].value != nil
    puts "Connect to #{address}"
  end
end

# Subcommand class.
class ConnectDomain < Cmdlib::Command
  def init
    @name = 'domain'
    @brief = 'Connection to server by domain address.'
    @example << 'ruby remote.rb connect domain [DOMAIN]'
    @argnum = 1
  end
  
  # Redefine default handler
  def handler ( global_options, args )
    puts "Connect to #{args[0]}"
  end
end

# Main command class.
class Connect < Cmdlib::Command
  def init
    @name = 'remote'
    @brief = 'Create remote connection.'
    
    addcmd ConnectTCP.new
    addcmd ConnectDomain.new
  end
  # Redefine default handler
  def handler ( global_options, args )
    puts "Connect to localhost."
  end
end

app = Cmdlib::App.new( 'remote' )
app.about << 'Demo of Subcommand.'
app.addcmd Connect.new
app.run
```

#### Dynamic command list creation
Create CLI application and command `base` in main file `base.rb` and
add custom command from `addon` directory.
Directory tree:
[...]
 - base.rb
 + [addon]
   - addon.rb

__FILE:__ __base.rb__
```ruby
require 'cmdlib.rb'

# Create default command.
class Base < Cmdlib::Command
  def init
    @name  = 'base'
    @brief = 'Base command of application.'
  end
end

# Create CLI handler.
app = Cmdlib::App.new( 'addon' )
app.about << 'Demo for create dynamic command list.'

# Add default command.
app.addcmd Base.new

# Added custom command to application
# from ruby scripts in directory [addon].
require 'find'
list = []
fname = ''
Find.find( 'addon' ) do |path|
  list << path if path =~ /^[\w\/]+\.rb$/
end
list.each do |e|
  require "./#{e}"
  fname = File.basename( list[0].split('.')[0] )
  fname = fname[0].upcase + fname[1,fname.length]
  eval("app.addcmd #{fname}.new")
end

# Run CLI handler.
app.run
```
__FILE:__ __addon/addon.rb__
```ruby
# Create default command.
class Addon < Cmdlib::Command
  def init
    @name  = 'addon'
    @brief = 'Addon command of application.'
  end
end
```
    $ ruby base.rb -h
                                     *** addon ***                                  
    ** ABOUT:
      Demo for create dynamic command list.

    ** OPTIONS:
      -V,--version  # Display application version.

    ** COMMANDS:
      base   # Base command of application.
      addon  # Addon command of application.

    For details, type: help [COMMAND]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cmdlib. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

