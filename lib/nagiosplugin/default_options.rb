require "optparse"

module NagiosPlugin
  module DefaultOptions
    def parse_num(s)
      if s.include? "."
        s.to_f
      else
        s.to_i
      end
    end

    def parse_start_num(s)
      if s.include? '~'
        s.delete!('~')
        Float::MIN
      else
        parse_num(s)
      end
    end
    def parse_reverse(s)
      if s.include? '@'
        s.delete!('@')
        @options[:invert] = true
      end
    end

    def parse_nagios_style(s)
      parse_reverse(s)

      if not s.include? ':'
        s = ":" + s
      end

      start, stop = s.split(':')
      if start.empty?
        # :m
        start = 0
        stop = parse_num(stop)
      elsif stop.empty?
        # n:
        start = parse_start_num(start)
        stop = Float::MAX
      else
        # n:m
        start = parse_start_num(start)
        stop = parse_num(stop)
      end
      start..stop
    end

    def default_options
      lambda do |opts|
        opts.separator ""
        opts.separator "Default options:"
        opts.separator ""

        opts.on('-h', '--help', 'Display this help.') do
          puts "#{opts}"
          exit(3)
        end

        opts.on('-V', '--version', 'Print version.') do |s|
          puts "#{File.basename($0)} #{VERSION}"
          exit(3)
        end

        opts.on('-w', '--warn <n:m>', 'Warning threshold.') do |s|
          @options[:warn] = parse_nagios_style(s)
        end

        opts.on('-c', '--crit <n:m>', 'Critical threshold.') do |s|
          @options[:crit] = parse_nagios_style(s)
        end
      end
    end
  end
end
