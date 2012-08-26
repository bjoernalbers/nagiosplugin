require "optparse"

module NagiosPlugin
  class Plugin
    class << self
      def parse_options(options, &blk2)
        OptionParser.new do |opts|
          opts.banner  = "% #{$0} [options]"
          opts.separator ""
          opts.separator "Specific options:"
          opts.separator ""

          opts.on('-h', '--help', 'Display this help.') do
            abort "#{opts}"
          end

          opts.on('-r', '--reverse', 'Reverse thresholds.') do |b|
            options[:reverse] = b
          end

          opts.on('-w', '--warn <n>', 'Warning threshold.') do |s|
            options[:warn] = s.to_i
          end

          opts.on('-c', '--crit <n>', 'Critical threshold.') do |s|
            options[:crit] = s.to_i
          end

          blk2.call(opts)

          begin
            opts.parse!
          rescue => e
            abort "#{e}\n\n#{opts}"
          end
        end

        options
      end

      # Create new instance and run it.
      def run(*args)
        self.new(*args).run
      end

    private

      # @macro [status] message
      #   @method $1(message)
      #   Raise $1 StatusError with message
      #   @param [String] message the exeption message
      def make(status)
        define_method(status) do |message|
          raise StatusError.new(status, message)
        end
      end
    end

    make :ok
    make :warning
    make :critical
    make :unknown

    def initialize(options={})
      @warn = options[:warn] if options[:warn]
      @crit = options[:crit] if options[:crit]
      @reverse = options[:reverse] if options[:reverse]
    end


    # Overwrite this check method and call a status method within.
    def check
      unknown 'please overwrite the `check` method in your class'
    end

    # Return the service name, which will be displayed on stdout.
    #
    # By default this will be the upcased class name. If you want
    # to name your service different than the class then overwrite
    # this method.
    #
    # @return [String] the service name
    def service
      self.class.name.upcase
    end

    # Run check and return result in a nagios-compatible format.
    #
    # It will...
    # - execute your check method
    # - output the result in a nagios-compatible format (SERVICE STATUS: Message)
    # - exit according to the status
    def run
      check
    rescue StatusError => e
    rescue => e
      e = StatusError.new(:unknown, ([e.to_s, nil] + e.backtrace).join("\n"))
    else
      e = StatusError.new(:unknown, 'no status method was called')
    ensure
      puts [service, e.to_s].join(' ')
      exit e.to_i
    end

  end
end
