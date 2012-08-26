require 'spec_helper'

describe NagiosPlugin::Plugin do
  before do
    class MyPlugin < NagiosPlugin::Plugin; end
    @plugin = MyPlugin.new

    class MergedOptionsPlugin < NagiosPlugin::Plugin
      def initialize(options, &blk)
        super(options, &blk)
        @foo = options[:foo]
      end
      attr_reader :warn, :crit, :reverse, :foo
    end
    @plugin_with_options = MergedOptionsPlugin.new({:warn => 5, :crit => 1, :reverse => true, :foo => "bar"})  do |opts|
      opts.on('--foo <s>', 'A test option.') do |s|
        options[:foo] = s
      end
    end
  end

  describe '#initialize' do
    it "should have attributes" do
      @plugin_with_options.should satisfy { |o|
        o.warn == 5 and o.crit == 1 and o.reverse and o.foo == "bar"
      }
    end
  end

  describe '#run' do
    before do
      @plugin.stub(:puts)
      @plugin.stub(:exit)
    end

    it 'should run the check method' do
      @plugin.should_receive(:check).with(no_args)
      @plugin.run
    end

    it 'should output the servie name' do
      @plugin.stub(:service).and_return('MY_FUNKY_PLUGIN')
      @plugin.should_receive(:puts).with(/MY_FUNKY_PLUGIN/)
      @plugin.run
    end

    it 'should output an appropriate message when check was not overwritten' do
      @plugin.should_receive(:puts).with(/please overwrite the `check` method in your class/i)
      @plugin.run
    end

    context 'when an unknown exception was raised' do
      before do
        StandardError.any_instance.stub(:backtrace).and_return(%w[foo bar baz])
        def @plugin.check
          raise StandardError, 'Oops!'
        end
      end

      it 'should output the execptions message' do
        @plugin.should_receive(:puts).with(/Oops!/)
        @plugin.run
      end

      it 'should output the exceptions backtrace' do
        @plugin.should_receive(:puts).with(/foo\nbar\nbaz/)
        @plugin.run
      end

      it 'should exit unknown' do
        @plugin.should_receive(:exit).with(3)
        @plugin.run
      end
    end

    context 'when no exception was raised' do
      before { def @plugin.check; end }

      it 'should display a hint for the developer' do
        @plugin.should_receive(:puts).with(/no status method was called/i)
        @plugin.run
      end

      it 'should exit unknown' do
        @plugin.should_receive(:exit).with(3)
        @plugin.run
      end
    end

    context 'when a status error was raised' do
      before do
        def @plugin.check
          raise NagiosPlugin::StatusError.new(:ok, 'hello, world.')
        end
      end

      it 'should output the status type' do
        @plugin.should_receive(:puts).with(/OK/)
        @plugin.run
      end

      it 'should output the status message' do
        @plugin.should_receive(:puts).with(/hello, world\./)
        @plugin.run
      end

      it 'should exit with the exit status from status error' do
        @plugin.should_receive(:exit).with(0)
        @plugin.run
      end
    end
  end

  describe '#service' do
    it 'should return the upcased class name' do
      @plugin.service.should eql('MYPLUGIN')
    end
  end
end
