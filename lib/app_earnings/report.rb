module AppEarnings
  # Base class for reports
  module Report
    attr_accessor :name, :transactions, :amount, :currency

    def extract_amount(name, transactions)
      @name = name
      @transactions = transactions
      @total_amount = amount_from_transactions(@transactions)
      @currency = @total_amount[:currency]
      @amount = @total_amount[:amount]
    end

    def transactions_by_type
      transactions.group_by do |transaction|
        transaction[:transaction_type] || transaction[:sales_or_return]
      end
    end

    def transactions_from_in_app_purchases
      transactions.reject do |tr|
        tr[:sku_id].nil? &&
        tr[:vendor_sku].nil?
      end
    end

    def transactions_from_in_app_purchases_by_id_and_name
      transactions_from_in_app_purchases.group_by do |tr|
        [tr[:sku_id] || tr[:vendor_sku] || tr[:vendor_identifier],
         tr[:item_name] || tr[:product_title] || tr[:title]]
      end
    end

    def transactions_count_by_type
      transaction_count = {}
      transactions_by_type.each do |type, transactions|
        transaction_count[type] = transactions.length
      end
      transaction_count
    end

    def transactions_from_product
      transactions - transactions_from_in_app_purchases
    end

    def total_from_in_app_purchases
      transactions_from_in_app_purchases_by_id_and_name.map do |iap, tr|
        {
          id: iap.first,
          name: iap.last
        }.merge(amount_from_transactions(tr))
      end
    end

    def formatted_transactions_count_by_type
      transactions_count_by_type.sort_by { |name, _| name }.map do |tr|
        tr.join(': ')
      end
    end

    def formatted_total_by_products
      total_from_in_app_purchases.sort_by { |product| product[:id] }
        .map do |app|
          total_amount = Report.formatted_amount(app[:currency], app[:amount])
          "#{app[:id]} - #{app[:name]}: #{total_amount}"
        end
    end

    def self.formatted_amount(currency, amount)
      symbol = ISO4217::Currency.from_code(currency).symbol
      "#{currency} #{symbol}#{sprintf('%.2f', amount)}"
    end

    def to_json
      {
        id: @name,
        name: @description,
        transactions_types: transactions_count_by_type,
        total: @amount.round(2),
        currency: @currency,
        subtotals: total_from_in_app_purchases
      }
    end

    def to_s
      %Q(#{@name} #{@description}
Transactions: #{formatted_transactions_count_by_type.join(", ")}
Total:
#{Report.formatted_amount(@currency, @amount)}

Sub totals by IAP:
#{formatted_total_by_products.join("\n")}

)
    end
  end
end
