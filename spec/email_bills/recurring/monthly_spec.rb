require 'spec_helper'

describe EmailBills::Recurring::Monthly do
  subject { EmailBills::Recurring::Monthly.new('test', 10, bill_date, from: from, to: today) }
  let(:from) { DateTime.new(2015, 8, 15) }

  context 'on October 15th' do
    let(:today) { DateTime.new(2015, 10, 15) }

    context 'with a billing date of the 15th' do
      let(:bill_date) { 15 }

      it 'will include the days bills' do
        expect(subject.receipts.count).to eq 3
        expect(subject.receipts.last.date).to eq from
        expect(subject.receipts.first.date).to eq today
      end
    end

    context 'with a billing date of the 16th' do
      let(:bill_date) { 16 }

      it 'will not include the latest bill' do
        expect(subject.receipts.count).to eq 2
        expect(subject.receipts.last.date).to eq DateTime.new(2015, 8, 16)
        expect(subject.receipts.first.date).to eq DateTime.new(2015, 9, 16)
      end
    end

    context 'with a billing date of the 14th' do
      let(:bill_date) { 14 }

      it 'will not include the earliest bill' do
        expect(subject.receipts.count).to eq 2
        expect(subject.receipts.last.date).to eq DateTime.new(2015, 9, 14)
        expect(subject.receipts.first.date).to eq DateTime.new(2015, 10, 14)
      end
     end
  end
end
