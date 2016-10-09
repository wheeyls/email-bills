module EmailBills
  module Receipts
    class Comcast < Base
      def value
        parsed[1].to_f
      end

      def number_finder
        /\$([0-9]+\.[0-9]{2})/
      end
    end
  end
end
