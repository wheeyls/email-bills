module EmailBills
  module Recurring
    class Monthly
      attr_reader :title, :value, :bill_day, :from, :to

      def initialize(title, value, bill_day, from:, to: DateTime.now)
        @title = title
        @value = value
        @bill_day = bill_day
        @from = from
        @to = to
      end

      def receipts
        receipts ||= billed_days.map { |day| EmailBills::Recurring::Payment.new(value, day) }
      end

      def total
        receipts.reduce(0.0) do |memo, receipt|
          memo += receipt.value if receipt.value?
          memo
        end
      end

      private

      def billed_days
        from.upto(to).select do |date|
          date.day == bill_day
        end.reverse
      end
    end
  end
end
