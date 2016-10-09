module EmailBills
  module Recurring
    class Payment
      attr_reader :value, :date

      def initialize(value, date)
        @value = value
        @date = date
      end

      def value?
        !value.nil?
      end
    end
  end
end
