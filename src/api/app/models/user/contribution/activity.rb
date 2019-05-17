class User
  module Contribution
    class Activity
      def initialize(day:, week:, values:, percentiles:, first_day:)
        @day = day
        @week = week
        @values = values
        @percentiles = percentiles
        @first_day = first_day
      end

      def contributions
        @_contributions ||= values.fetch(date, 0)
      end

      def date
        @_date ||= first_day + week * 7 + day
      end

      def percentile
        percentiles.calc(contributions)
      end

      def last_week?
        current_day > last_day
      end

      private

        attr_accessor :day, :week, :values, :percentiles, :first_day
    end
  end
end