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

For demonstration of options constructor, create application that says 'Hello'.
```
require 'cmdlib.rb'

# Create CLI handler.
handler = Cmdlib::Handler.new
handler.usage << 'This program say hello.'
handler.usage << ''
handler.usage << '  Usage: ruby hello.rb [OPTIONS...]'

# Create options object.
opt_name = Cmdlib::Option.new( 'n', 'name', 'Option set name for hello message.', true )

# Add objects to handler.
handler.addopt opt_name

# Run CLI handler.
handler.run

# Create output string
hello = "Hello"

# If value do not contain nil, those option is present.
# Parameter of option can be set as: -nJohn or -n=John or -n John
hello += " #{opt_name.value}" if opt_name.value != nil

puts hello
```
Create CLI handler object `Cmdlib::Handler.new`, then create options object `Cmdlib::Option.new`.
The option constructor takes the following values:
* Short option name: -...
* Long option name: --...
* String with brief information about option (default => false).
* This sign tells the parser that the option has a parameter, example: --opt=... (default => false).

Add to handler options objects.

Now we can run 'Hello' program with arguments: `ruby hello.rb help` or `ruby hello.rb -h` or `ruby hello.rb --help`, 
also we can use option `-n` to set name: `ruby hello.rb -nMyName` or `ruby hello.rb -n MyName` or `ruby hello.rb -n=MyName`.

For demonstration of commands handler constructor, create application that calculation square and cube on input number.
```
require 'cmdlib.rb'

# Create handler for 'square' command.
class CLISquare < Cmdlib::Command
  # Redefine default handler
  def handler
    # if value do not contain nil, those option is present.
    numb = ARGV[1].to_i
    if $opt_verbose.value != nil then
      puts "Square of #{numb} => #{numb * numb}"
    else
      puts "#{numb * numb}"
    end
  end
end

# Create handler for 'cube' command.
class CLICube < Cmdlib::Command
  # Redefine default handler
  def handler
    # if value do not contain nil, those option is present.
    numb = ARGV[1].to_i
    if $opt_verbose.value != nil then
      puts "Cube of #{numb} => #{numb * numb * numb}"
    else
      puts "#{numb * numb * numb}"
    end
  end
end

# Create CLI handler.
handler = Cmdlib::Handler.new
handler.usage << 'Calculation square and cube of number.'
handler.usage << ''
handler.usage << '  Usage: ruby calc.rb <command> [OPTIONS...]'

# Create object of 'square' command handler.
square = CLISquare.new
square.describe.oname = 'square'
square.describe.brief = 'Calculation square of number.'
square.describe.details << 'Command call format: ruby calc.rb square <number>.'
square.describe.example << 'ruby calc.rb square 2'
# Set numbers of parameters for this command.
square.argnum = 1

# Create object of 'cube' command handler.
cube = CLICube.new
cube.describe.oname = 'cube'
cube.describe.brief = 'Calculation cube of number.'
cube.describe.details << 'Command call format: ruby calc.rb cube <number>.'
cube.describe.example << 'ruby calc.rb cube 2'
# Set numbers of parameters for this command.
cube.argnum = 1

# Create options object.
$opt_verbose = Cmdlib::Option.new( 'v', 'verbose', 'Option enable verbose mode.' )

# Add objects to handler.
handler.addcmd square
handler.addcmd cube
handler.addopt $opt_verbose

# Run CLI handler.
handler.run

# Handler to runing without arguments.
puts 'fatal error: too few arguments for program.'
```
Also, application can display details information bout command: `ruby calc.rb help cube`.
Run application:
    $ ruby calc.rb cube 10
or, in verbose mode:
    $ ruby calc.rb cube 10 -v

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cmdlib. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

