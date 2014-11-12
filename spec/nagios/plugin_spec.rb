require 'spec_helper'

module Nagios
  describe Plugin do
    let(:plugin) { Plugin.new }

    describe '.run!' do
      before do
        allow(plugin).to receive_messages(
          output: '',
          status: :unknown,
          check: nil)
        allow(Plugin).to receive_messages(
          puts: nil,
          exit: nil,
          new: plugin)
      end

      it 'displays the plugin output on stdout' do
        allow(plugin).to receive(:output).and_return('chunky bacon')
        Plugin.run!
        expect(Plugin).to have_received(:puts).with('chunky bacon')
      end

      it 'exits with exit code 3 when plugin status unknown' do
        allow(plugin).to receive(:status).and_return(:unknown)
        Plugin.run!
        expect(Plugin).to have_received(:exit).with(3)
      end

      it 'exits with exit code 2 when plugin status critical' do
        allow(plugin).to receive(:status).and_return(:critical)
        Plugin.run!
        expect(Plugin).to have_received(:exit).with(2)
      end

      it 'exits with exit code 1 when plugin status warning' do
        allow(plugin).to receive(:status).and_return(:warning)
        Plugin.run!
        expect(Plugin).to have_received(:exit).with(1)
      end

      it 'exits with exit code 0 when plugin status ok' do
        allow(plugin).to receive(:status).and_return(:ok)
        Plugin.run!
        expect(Plugin).to have_received(:exit).with(0)
      end

      it 'forwards any arguments to the plugin initializer' do
        Plugin.run!(42, fancy: true)
        expect(Plugin).to have_received(:new).with(42, fancy: true)
      end

      it 'calls the plugin check callback before fetching the status' do
        Plugin.run!
        expect(plugin).to have_received(:check).ordered
        expect(plugin).to have_received(:status).ordered
      end

      context 'when an exception was raised' do
        let(:exception) { StandardError.new('Oops!') }

        before do
          allow(Plugin).to receive(:new).and_raise(exception)
        end

        it 'rescues the exception' do
          expect { Plugin.run! }.to_not raise_error
        end

        it 'exits with status 3' do
          Plugin.run!
          expect(Plugin).to have_received(:exit).with(3)
        end

        it 'displays the exception and backtrace on stdout' do
          allow(StandardError).to receive(:new).and_return(exception)
          allow(exception).to receive(:backtrace).and_return(%w(Chunky Bacon))
          Plugin.run!
          expect(Plugin).to have_received(:puts).
            with("PLUGIN UNKNOWN: Oops!\n\nChunky\nBacon")
        end
      end
    end

    describe '#name' do
      it 'returns the upcased class name' do
        class Foo < Plugin; end
        plugin = Foo.new
        expect(plugin.name).to eq('FOO')
      end

      it 'strips "Nagios" prefix from the class name' do
        class Nagios::Bar < Plugin; end
        plugin = Nagios::Bar.new
        expect(plugin.name).to eq('BAR')
      end
    end

    describe '#status' do
      it 'returns :unknown when status not critical, not warning and not ok' do
        allow(plugin).to receive_messages(
          critical?: false,
          warning?:  false,
          ok?:       false)
        expect(plugin.status).to eq(:unknown)
      end

      it 'returns :critical when status critical' do
        allow(plugin).to receive_messages(
          critical?: true,
          warning?:  true,
          ok?:       true)
        expect(plugin.status).to eq(:critical)
      end

      it 'returns :warning when status not critical but warning' do 
        allow(plugin).to receive_messages(
          critical?: false,
          warning?:  true,
          ok?:       true)
        expect(plugin.status).to eq(:warning)
      end

      it 'returns :ok when when status not critical, not warning but ok' do
        allow(plugin).to receive_messages(
          critical?: false,
          warning?:  false,
          ok?:       true)
        expect(plugin.status).to eq(:ok)
      end
    end

    describe '#output' do
      before do
        allow(plugin).to receive_messages(
          name: 'chunkybacon',
          status: 'tasty')
      end

      context 'without a message' do
        before do
          allow(plugin).to receive(:message).and_return(nil)
        end

        it 'returns the name and status' do
          expect(plugin.output).to eq('CHUNKYBACON TASTY')
        end
      end

      context 'with an empty message' do
        before do
          allow(plugin).to receive(:message).and_return('')
        end

        it 'returns the name and status' do
          expect(plugin.output).to eq('CHUNKYBACON TASTY')
        end
      end

      context 'with a message' do
        before do
          allow(plugin).to receive(:message).and_return(42)
        end

        it 'returns the name, status and message' do
          expect(plugin.output).to eq('CHUNKYBACON TASTY: 42')
        end
      end
    end
  end
end
