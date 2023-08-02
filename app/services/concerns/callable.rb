# frozen_string_literal: true

#
# Supports the Service Object pattern. Adds a class "call" method that
# instantiates a new instance of the class using the given parameters, and
# calls the instance's "call" method. Use Callable.with(:some_verb) to use
# "some_verb" instead of "call".
#
module Callable
  class << self
    def included(base)
      base.extend with(:call)
    end

    def with(verb) # rubocop:disable Metrics/MethodLength
      callable_modules[verb.to_sym] ||= Module.new do
        def self.included(base)
          base.extend self
        end

        class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
          def #{verb}(...)                            # def the_verb(...)
            new(...).#{verb} { |*args| yield(*args) } #   new(...).the_verb { |*args| yield(*args) }
          end                                         # end

          def to_proc                                 # def to_proc
            method("#{verb}").to_proc                 #   method("the_verb").to_proc
          end                                         # end
        RUBY
      end
    end

    def callable_modules
      @callable_modules ||= {}
    end
  end
end
