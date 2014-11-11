module Nagios
  class Plugin
    VERSION = '3.0.1'

    EXIT_CODE =
      { unknown:  3,
        critical: 2,
        warning:  1,
        ok:       0 }

    def self.run!(*args)
      plugin = new(*args)
      plugin.check if plugin.respond_to?(:check)
      puts plugin.output
      exit EXIT_CODE[plugin.status]
    rescue => e
      puts "PLUGIN UNKNOWN: #{e.message}\n\n" << e.backtrace.join("\n")
      exit EXIT_CODE[:unknown]
    end

    def output
      s = "#{name.upcase} #{status.upcase}"
      s << ": #{message}" if ( respond_to?(:message) && !message.to_s.empty? )
      s
    end

    def status
      return :critical if critical?
      return :warning  if warning?
      return :ok       if ok?
      :unknown
    end

    def name
      self.class.name.split('::').last.upcase
    end

    def to_s
      output
    end
  end
end
