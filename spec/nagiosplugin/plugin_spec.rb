require 'spec_helper'

module NagiosPlugin
  describe Plugin do
    let(:plugin) { Plugin.new }

    describe '.check' do
      before do
        allow(plugin).to receive_messages(
          nagios_plugin_exit_code:  nil,
          nagios_plugin_output:     nil)
        allow(Plugin).to receive_messages(
          puts: nil,
          exit: nil,
          new: plugin)
      end

      it 'displays the plugin output on stdout' do
        allow(plugin).to receive(:nagios_plugin_output).
          and_return('chunky bacon')
        Plugin.check
        expect(Plugin).to have_received(:puts).with('chunky bacon')
      end

      it 'exits with the status exit code' do
        allow(plugin).to receive(:nagios_plugin_exit_code).and_return(42)
        Plugin.check
        expect(Plugin).to have_received(:exit).with(42)
      end

      context 'when an exception was raised' do
        let(:exception) { StandardError.new('Oops!') }

        before do
          allow(Plugin).to receive(:new).and_raise(exception)
        end

        it 'rescues the exception' do
          expect { Plugin.check }.to_not raise_error
        end

        it 'exits with exit code unknown' do
          Plugin.check
          expect(Plugin).to have_received(:exit).with(3)
        end

        it 'displays the exception and backtrace on stdout' do
          allow(StandardError).to receive(:new).and_return(exception)
          allow(exception).to receive(:backtrace).and_return(%w(Chunky Bacon))
          Plugin.check
          expect(Plugin).to have_received(:puts).
            with("PLUGIN UNKNOWN: Oops!\n\nChunky\nBacon")
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
        allow(plugin).to receive_messages(
          critical?: false,
          warning?:  false,
          ok?:       false)
        expect(plugin.send(:nagios_plugin_status)).to eq(:unknown)
      end

      it 'returns critical when critical' do
        allow(plugin).to receive_messages(
          critical?: true,
          warning?:  true,
          ok?:       true)
        expect(plugin.send(:nagios_plugin_status)).to eq(:critical)
      end

      it 'returns warning when warning but not critical' do 
        allow(plugin).to receive_messages(
          critical?: false,
          warning?:  true,
          ok?:       true)
        expect(plugin.send(:nagios_plugin_status)).to eq(:warning)
      end

      it 'returns ok when ok but not critical or warning' do
        allow(plugin).to receive_messages(
          critical?: false,
          warning?:  false,
          ok?:       true)
        expect(plugin.send(:nagios_plugin_status)).to eq(:ok)
      end

      it 'caches the status' do
        [:critical?, :warning?, :ok?].each do |check|
          allow(plugin).to receive(check).once.and_return(false)
        end
        expect(plugin.send(:nagios_plugin_status)).to eq(:unknown)
        expect(plugin.send(:nagios_plugin_status)).to eq(:unknown)
      end
    end

    describe '#nagios_plugin_exit_code' do
      it 'returns 3 when unknown' do
        allow(plugin).to receive(:nagios_plugin_status).and_return(:unknown)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(3)
      end

      it 'returns 2 when critical' do
        allow(plugin).to receive(:nagios_plugin_status).and_return(:critical)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(2)
      end

      it 'returns 1 when warning' do
        allow(plugin).to receive(:nagios_plugin_status).and_return(:warning)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(1)
      end
      
      it 'returns 0 when ok' do
        allow(plugin).to receive(:nagios_plugin_status).and_return(:ok)
        expect(plugin.send(:nagios_plugin_exit_code)).to eq(0)
      end
    end

    describe '#nagios_plugin_output' do
      before do
        allow(plugin).to receive(:nagios_plugin_status)
      end

      it 'joins the service name and the upcased status' do
        allow(plugin).to receive(:nagios_plugin_service).and_return('FRIED')
        allow(plugin).to receive(:nagios_plugin_status).and_return(:chicken)
        expect(plugin.send(:nagios_plugin_output)).to match(/^FRIED CHICKEN$/)
      end

      it 'includes a custom plugin message if present' do
        allow(plugin).to receive(:message).and_return('ALL U CAN EAT!')
        expect(plugin.send(:nagios_plugin_output)).to match(/: ALL U CAN EAT!$/)
      end

      it 'does not append message if message is empty' do
        allow(plugin).to receive(:message).and_return('')
        expect(plugin.send(:nagios_plugin_output)).not_to match(/:/)
      end

    end
  end
end
