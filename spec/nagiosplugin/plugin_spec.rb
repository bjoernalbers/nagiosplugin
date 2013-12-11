require 'spec_helper'

module NagiosPlugin
  describe Plugin do
    let(:plugin) { Plugin.new }

    describe '.check' do
      before do
        plugin.stub(:nagios_plugin_exit_code  => nil,
                    :nagios_plugin_output     => nil)
        Plugin.stub(:puts                     => nil,
                    :exit                     => nil,
                    :new                      => plugin)
      end

      it 'displays the plugin output on stdout' do
        plugin.should_receive(:nagios_plugin_output).
          and_return('chunky bacon')
        Plugin.should_receive(:puts).with('chunky bacon')
        Plugin.check
      end

      it 'exits with the status exit code' do
        plugin.should_receive(:nagios_plugin_exit_code).and_return(42)
        Plugin.should_receive(:exit).with(42)
        Plugin.check
      end

      context 'when an exception was raised' do
        let(:exception) { StandardError.new }

        before do
          Plugin.stub(:new).and_return { raise 'Oops!' }
        end

        it 'rescues the exception' do
          expect { Plugin.check }.to_not raise_error
        end

        it 'exits with exit code unknown' do
          Plugin.should_receive(:exit).with(3)
          Plugin.check
        end

        it 'displays the exception and backtrace on stdout' do
          StandardError.any_instance.stub(:backtrace).
            and_return(%w(Chunky Bacon))
          Plugin.should_receive(:puts).
            with("PLUGIN UNKNOWN: Oops!\n\nChunky\nBacon")
          Plugin.check
        end
      end
    end

    describe '#nagios_plugin_service' do
      it 'returns the upcased class name' do
        class Foo < Plugin; end
        plugin = Foo.new
        expect(plugin.send(:nagios_plugin_service)).to eq('FOO')
      end

      it 'strips "Plugin" from the class name' do
        class BarPlugin < Plugin; end
        plugin = BarPlugin.new
        expect(plugin.send(:nagios_plugin_service)).to eq('BAR')
      end
    end

    describe '#nagios_plugin_status' do
      it 'returns unknown when not critical, warning or ok' do
        plugin.stub(:critical? => false, :warning? => false, :ok? => false)
        expect(plugin.send(:nagios_plugin_status)).to eq(:unknown)
      end

      it 'returns critical when critical' do
        plugin.stub(:critical? => true, :warning? => true, :ok? => true)
        expect(plugin.send(:nagios_plugin_status)).to eq(:critical)
      end

      it 'returns warning when warning but not critical' do 
        plugin.stub(:critical? => false, :warning? => true, :ok? => true)
        expect(plugin.send(:nagios_plugin_status)).to eq(:warning)
      end

      it 'returns ok when ok but not critical or warning' do
        plugin.stub(:critical? => false, :warning? => false, :ok? => true)
        expect(plugin.send(:nagios_plugin_status)).to eq(:ok)
      end

      it 'saves the status' do
        [:critical?, :warning?, :ok?].each do |check|
          plugin.should_receive(check).once.and_return(false)
        end
        expect(plugin.send(:nagios_plugin_status)).to eq(:unknown)
        expect(plugin.send(:nagios_plugin_status)).to eq(:unknown)
      end
    end

    describe '#nagios_plugin_exit_code' do
      it 'returns 3 when unknown' do
        plugin.should_receive(:nagios_plugin_status).and_return(:unknown)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(3)
      end

      it 'returns 2 when critical' do
        plugin.should_receive(:nagios_plugin_status).and_return(:critical)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(2)
      end

      it 'returns 1 when warning' do
        plugin.should_receive(:nagios_plugin_status).and_return(:warning)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(1)
      end
      
      it 'returns 0 when ok' do
        plugin.should_receive(:nagios_plugin_status).and_return(:ok)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(0)
      end
    end

    describe '#nagios_plugin_output' do
      before do
        plugin.stub(:nagios_plugin_status)
      end

      it 'joins the service name and the upcased status' do
        plugin.should_receive(:nagios_plugin_service).and_return('FRIED')
        plugin.should_receive(:nagios_plugin_status).and_return(:chicken)
        expect(plugin.send(:nagios_plugin_output)).to match(/^FRIED CHICKEN$/)
      end

      it 'includes a custom plugin message if present' do
        plugin.stub(:message => 'ALL U CAN EAT!')
        expect(plugin.send(:nagios_plugin_output)).to match(/: ALL U CAN EAT!$/)
      end

      it 'should not append message if message is empty' do
        plugin.stub(:message => '')
        expect(plugin.send(:nagios_plugin_output)).not_to match(/:/)
      end

    end
  end
end
