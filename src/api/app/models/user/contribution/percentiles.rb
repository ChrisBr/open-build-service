class User
  module Contribution
    class Percentiles
      def initialize(values)
        @values = values.sort
        @length = values.length
      end

      def calc(value)
        if activity == 0
          :zero
        elsif activity <= zero_dot_five
          :zero_dot_five
        elsif activity <= zero_dot_eight
          :zero_dot_eight
        elsif activity <= zero_dot_ninty_five
          :zero_dot_ninty_five
        else
          :high
        end
      end

      private

        attr_accessor :values, :length

        def zero_dot_five
          @_zero_dot_five ||= contributions_values[percentil(0.5)]
        end

        def zero_dot_eight
          @zero_dot_eight ||= contributions_values[percentil(0.8)]
        end

        def zero_dot_ninty_five
          @_zero_dot_ninty_five ||= contributions_values[percentil(0.95)]
        end

        def percentil(ratio)
          (length * ratio).round - 1
        end
    end
  end
end
