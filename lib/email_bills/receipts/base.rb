module EmailBills
  module Receipts
    class Base
      attr_reader :message

      def initialize(message)
        @message = message
      end

      def value
        parsed[0].to_f
      end

      def date
        message.received_date
      end

      def value?
        parsed
      end

      def parsed
        @parsed ||= content.match(number_finder)
      end

      def content
        message.body
      end

      def number_finder
        fail NotImplementedError
      end
    end
  end
end
