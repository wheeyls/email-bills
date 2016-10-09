module EmailBills
  class View
    attr_reader :vendor, :split

    def initialize(vendor, split = 3)
      @vendor = vendor
      @split = split
    end

    def render
      puts "#{vendor.title}"
      puts "-----------------"

      puts "Billed Date	Amount"
      vendor.receipts.each do |receipt|
        puts "#{receipt.date.strftime('%b %d %Y')}	#{receipt.value.round(2)}" if receipt.value?
      end

      puts ""
      puts "#{vendor.title} total:	#{vendor.total.round(2)}"
      puts "#{vendor.title} total each:	#{(vendor.total / 3).round(2)}"
      puts ""
      puts ""
      puts ""
    end
  end
end
