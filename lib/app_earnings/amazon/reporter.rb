module AppEarnings::Amazon
  # Generates a report based on the data provided
  class Reporter
    AVAILABLE_FORMATS = %w(json text csv)
    attr_accessor :data

    def initialize(data)
      @payments_amount, @data = 0.0, data
      @payments_data = @data.find { |r| r[:report_type] == :payments }
      @earnings_data = (@data - [@payments_data]).first
      @exchange_info = fetch_exchange_info
    end

    def fetch_exchange_info
      @payments_data[:summary].reduce({}) do |all_info, data|
        all_info[data[:marketplace]] = data[:fx_rate]
        @payments_amount += data[:total_payment].gsub(/,/, '').to_f
        all_info
      end
    end

    def full_amount
      @reports.reduce(0.0) { |a, e| a + e.amount.to_f } - refunds
    end

    def refunds
      @earnings_data[:summary].reduce(0.0) do |sum, marketplace|
        currency = marketplace[:marketplace]
        amount = marketplace[:refunds].gsub(/\(|\)/, '').to_f
        amount = amount * @exchange_info[currency].to_f if currency != 'USD'
        sum + amount
      end
    end

    def generate
      @reports = []
      @data.each do |raw_data|
        if raw_data[:report_type] == :earnings
          by_apps = raw_data[:details].group_by { |element| element[:app] }
                                      .sort_by { |app| app }
          by_apps.each do |key, application|
            @reports << AmazonReport.new(key, application, @exchange_info)
          end
        end
      end
    end

    def report_as(format = 'text')
      unless AVAILABLE_FORMATS.include?(format)
        fail "#{format} Not supported. Available formats are: " +
             " #{AVAILABLE_FORMATS.join(", ")}"
      end

      generate
      render_as(format)
    end

    def render_as(format = 'text')
      case format
      when 'text'
        as_text
      when 'json'
        as_json
      when 'csv'
        as_csv
      end
    end

    def validate_date_range
      period = @payments_data[:summary].first[:earnings_period]
      start_date, end_date = period.gsub(/\s+/, '').split('-').map do |date|
        Date.strptime(date, '%m/%d/%Y')
      end
      transaction = @earnings_data[:details].first[:date]
      transaction_date = Date.strptime(transaction, '%m/%d/%Y')
      if transaction_date < start_date ||
         transaction_date > end_date
        "Invalid dates: #{period} does not include #{transaction}"
      end
    end

    def as_text
      amount = AppEarnings::Report.formatted_amount('USD', full_amount)
      refund = AppEarnings::Report.formatted_amount('USD', refunds)
      payments = AppEarnings::Report.formatted_amount('USD', @payments_amount)
      puts @reports
      puts "Total of refunds: #{refund}"
      puts "Total of all transactions: #{amount}"
      puts "Total from Payment Report: #{payments}" if amount != payments
      puts validate_date_range if validate_date_range
      @reports
    end

    def as_json
      puts JSON.generate(apps: @reports.map(&:to_json),
                         currency: 'USD',
                         total: full_amount)
    end

    def as_csv
      amount = AppEarnings::Report.amount_for_csv('USD', full_amount)
      refund = AppEarnings::Report.amount_for_csv('USD', refunds)
      payments = AppEarnings::Report.amount_for_csv('USD', @payments_amount)
      @reports.each { |report| puts report.to_csv }
      puts %Q("Total of refunds:","#{refund}")
      puts %Q("Total of all transactions:","#{amount}")
      puts %Q("Total from Payment Report:","#{payments}") if amount != payments
      puts %Q("validate_date_range") if validate_date_range
      @reports
    end
  end
end
