# frozen_string_literal: true

require "rails_helper"

RSpec.describe Callable do
  describe ".call" do
    let(:test_class) do
      Class.new do
        def call; end
      end.include(described_class)
    end

    it "creates an instance of the class" do
      allow(test_class).to receive(:new).and_call_original
      test_class.call
      expect(test_class).to have_received(:new)
    end

    it %(calls the instance's #call method) do
      test_double = instance_double(test_class, call: nil)
      allow(test_class).to receive(:new).and_return(test_double)
      test_class.call
      expect(test_double).to have_received(:call)
    end

    it %(returns the instance's #call method's return value) do
      expected_result = instance_double String
      test_double = instance_double(test_class, call: expected_result)
      allow(test_class).to receive(:new).and_return(test_double)
      expect(test_class.call).to be(expected_result)
    end

    context "given positional arguments" do
      let(:test_class) do
        Class.new do
          def initialize(*_args); end
          def call; end
        end.include(described_class)
      end

      let(:args) do
        Array.new(rand(1..3)) { Faker::Lorem.unique.word }
      end

      it "passes the arguments to the class's constructor" do
        allow(test_class).to receive(:new).and_call_original
        test_class.call(*args)
        expect(test_class).to have_received(:new).with(*args)
      end

      it %(does not pass the arguments to the instance's #call method) do
        test_double = instance_double(test_class, call: nil)
        allow(test_class).to receive(:new).and_return(test_double)
        test_class.call(*args)
        expect(test_double).to have_received(:call).with(no_args)
      end
    end

    context "given keyword arguments" do
      let(:test_class) do
        Class.new do
          def initialize(**_kwargs); end
          def call; end
        end.include(described_class)
      end

      let(:kwargs) do
        rand(1..3).times.to_h { |index| ["kwarg#{index}".to_sym, Faker::Lorem.unique.word] }
      end

      it "passes the arguments to the class's constructor" do
        allow(test_class).to receive(:new).and_call_original
        test_class.call(**kwargs)
        expect(test_class).to have_received(:new).with(**kwargs)
      end

      it %(does not pass the arguments to the instance's #call method) do
        test_double = instance_double(test_class, call: nil)
        allow(test_class).to receive(:new).and_return(test_double)
        test_class.call(**kwargs)
        expect(test_double).to have_received(:call).with(no_args)
      end
    end

    context "given a block" do
      let(:test_class) do
        Class.new do
          def initialize
            yield("from #initialize") if block_given?
          end

          def call
            yield("from #call") if block_given?
          end
        end.include(described_class)
      end

      it "passes the block to the class's constructor and instance's #call method" do
        expect { |b| test_class.call(&b) }.to yield_successive_args("from #initialize", "from #call")
      end
    end
  end

  describe ".with" do
    let(:test_class) do
      Class.new.include(described_class.with(verb)).tap do |klass|
        klass.define_method(verb) { nil }
      end
    end

    let(:verb) { "v#{SecureRandom.hex(1)}".to_sym }

    context "when the given verb is invoked on the including class" do
      it "creates an instance of the class" do
        allow(test_class).to receive(:new).and_call_original
        test_class.public_send(verb)
        expect(test_class).to have_received(:new)
      end

      it %(calls the instance's "verb" method) do
        test_double = instance_double(test_class, verb => nil)
        allow(test_class).to receive(:new).and_return(test_double)
        test_class.public_send(verb)
        expect(test_double).to have_received(verb)
      end
    end
  end
end
