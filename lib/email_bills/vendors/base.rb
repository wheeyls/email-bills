module EmailBills
  module Vendors
    class Base
      attr_reader :from, :checker

      def initialize(from:, checker: EmailBills::GmailChecker.new)
        @from = from
        @checker = checker
      end

      def receipts
        @messages ||= messages.map { |i| receipt_klass.new(i) }
      end

      def total
        receipts.reduce(0.0) do |memo, receipt|
          memo += receipt.value if receipt.value?
          memo
        end
      end

      def title
        mailbox
      end
      
      private

      def messages
        @messages ||= checker.get_since(from, mailbox)
      end

      def mailbox
        fail NotImplementedError
      end

      def receipt_klass
        name = self.class.name.match(/::([^:]+)$/)[1]
        EmailBills::Receipts.const_get name
      end
    end
  end
end
