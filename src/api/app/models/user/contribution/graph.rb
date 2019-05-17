class User
  module Contribution
    class Graph
      include Enumerable
      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def each
        week_days.each do |week_day|
          weeks.each do |week|
            yield Activity.new(day: week_day, week: week, activity_hash: activity_hash)
          end
        end
      end

      def contributions
        @_total ||= activity_hash.values.sum
      end

      private

      def percentiles
        @_percentiles ||= Percentiles.new(activity_hash: activity_hash)
      end

      def first_day
        1.year.ago.beginning_of_week
      end

      def last_day
      @_last_day = Time.zone.today
      end

      def week_days
        7.times
      end

      def weeks
        53.times
      end

      def activity_hash
        @_activity_hash ||= merge_hashes([requests_created, comments, reviews_done])
      end

      def requests_created
        user.requests_created.where('created_at > ?', first_day).group('date(created_at)').count
      end

      def comments
        user.comments.where('created_at > ?', first_day).group('date(created_at)').count
      end

      def reviews_done
        # User.reviews are by_user, we want also by_package and by_group reviews accepted/declined
        Review.where(reviewer: user.login, state: [:accepted, :declined]).where('created_at > ?', first_day).group('date(created_at)').count
      end

      def merge_hashes(hashes_array)
        hashes_array.inject { |h1, h2| h1.merge(h2) { |_, value1, value2| value1 + value2 } }
      end
    end
  end
end
