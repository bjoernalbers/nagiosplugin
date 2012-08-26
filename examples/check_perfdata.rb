require "nagiosplugin"
require "nagiosplugin/plugin"
require "nagiosplugin/perfdata"

class CheckPerfdata < NagiosPlugin::Plugin
  include NagiosPlugin::Perfdata

  def check
    sleep 0.4
    pd = PerfData.new
    pd.val = 40
    pd.warn = 25
    pd.crit = 50
    pd.min = 1
    pd.max = 90
    pd.uom = "%"

    @perfdata = {
      :pd => pd,
      :baz => PerfData.new(1),
      :foo => PerfData.new(1,2,3),
      :bar => PerfData.new(4,5,6,7,8),
    }
    ok('super perfdata')
    sleep 0.2
  end

end

CheckPerfdata.run
