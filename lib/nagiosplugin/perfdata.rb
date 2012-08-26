module NagiosPlugin
  module Perfdata
    _perfdata = Struct.new :val, :warn, :crit, :min, :max, :uom
    PerfData = _perfdata

    def get_perfdata
      if @perfdata.class == PerfData
        @perfdata.select {|e| e}.join(';')
      else
        @perfdata.map do |k,v|
          "#{k}=" + v.select {|e| e}.join(';')
        end.join(' ')
      end
    end

    # Run check and return result in a nagios-compatible format.
    #
    # It will...
    # - execute your check method
    # - output the result in a nagios-compatible format (SERVICE STATUS: Message)
    # - exit according to the status
    def run
      t1 = Time.now
      check
    rescue StatusError => e
    rescue => e
      e = StatusError.new(:unknown, ([e.to_s, nil] + e.backtrace).join("\n"))
    else
      e = StatusError.new(:unknown, 'no status method was called')
    ensure
      t2 = Time.now
      msg = [service, e.to_s].join(' ')
      perfdata = get_perfdata
      t = t2 - t1
      puts "#{msg}|time=#{t} #{perfdata}"
      exit e.to_i
    end

  end
end
