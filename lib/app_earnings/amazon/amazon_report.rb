require 'yaml'
require 'iso4217'

module AppEarnings::Amazon
  # Converts a csv file to a hash.
  class AmazonReport
    include AppEarnings::Report

    attr_accessor :exchange_info

    def initialize(name, transactions, exchange_info)
      @exchange_info = exchange_info
      extract_amount(name, transactions)
    end

    def convert_amounts(amounts)
      amounts.reduce(0.0) do |sum, (marketplace, amount)|
        amount = amount * @exchange_info[marketplace].to_f
        sum + amount
      end
    end

    def amount_from_transactions(transactions)
      amounts = transactions.reduce({}) do |sum, transaction|
        marketplace = transaction[:marketplace]
        sum[marketplace] ||= 0.0
        sum[marketplace] += transaction[:gross_earnings_or_refunds].to_f
        sum
      end

      {
        currency: 'USD',
        amount: convert_amounts(amounts).round(2)
      }
    end
  end
end
