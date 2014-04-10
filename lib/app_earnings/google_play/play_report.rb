module AppEarnings::GooglePlay
  # Represents the report.
  class PlayReport
    include AppEarnings::Report

    def initialize(name, transactions)
      extract_amount(name, transactions)
      unless transactions_from_product.first.nil?
        @description = transactions_from_product.first[:product_title]
      end
    end

    # It sums up to all available amounts, but it takes just the first one.
    # As it's usually just one.
    def amount_from_transactions(transactions)
      all_currencies = transactions.reduce({}) do |sum, transaction|
        currency = transaction[:merchant_currency]
        sum[currency] ||= 0.0
        sum[currency] += transaction[:amount_merchant_currency].to_f
        sum
      end.first

      {
        currency: all_currencies.first,
        amount: all_currencies.last.round(2)
      }
    end
  end
end
