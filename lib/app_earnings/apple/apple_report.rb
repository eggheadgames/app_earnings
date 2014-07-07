require 'yaml'
require 'iso4217'

module AppEarnings::Apple
  # Converts a csv file to a hash.
  class AppleReport
    include AppEarnings::Report

    attr_accessor :exchange_info

    def initialize(name, transactions, exchange_info)
      @exchange_info = exchange_info
      extract_amount(name, transactions)
    end

    def transactions_from_in_app_purchases
      transactions.reject do |tr|
        tr[:product_type_identifier] == '1T'
      end
    end

    def convert_amounts(amounts)
      amounts.reduce(0.0) do |sum, (marketplace, amount)|
        amount = amount * @exchange_info[marketplace].to_f
        sum + amount
      end
    end

    def all_amounts(transactions)
      transactions.reduce({}) do |sum, transaction|
        marketplace = transaction[:partner_share_currency]
        sum[marketplace] ||= 0.0
        sum[marketplace] += transaction[:extended_partner_share].to_f
        sum
      end
    end

    def amount_from_transactions(transactions)
      total = all_amounts(transactions)

      {
        currency: 'USD',
        amount: convert_amounts(total).round(2)
      }
    end
  end
end
