module AppEarnings::Apple
  # Generates a report based on the data provided
  class Reporter
    AVAILABLE_FORMATS = %w(json text csv)
    attr_accessor :data, :config, :payments_amount, :exchange_info

    def initialize(config, data)
      @config = config
      @data = data
      @payments_data = @data.find { |r| r[:report_type] == :payments }
      @earnings = @data - [@payments_data]
      @earnings_data = @earnings.reduce([]) { |a, e| a << e[:details] }
      @earnings_data.flatten!
      @exchange_info = fetch_exchange_info
    end

    def fetch_exchange_info
      @payments_amount = 0.0
      @payments_data[:details].reduce({}) do |all_info, data|
        all_info[data[:currency].strip] = data[:fx_rate].to_f
        @payments_amount += data[:payment].gsub(/,/, '').to_f
        all_info
      end
    end

    def tax
      @payments_data[:details].reduce(0.0) do |sum, data|
        sum += data[:withholding_tax].to_f * data[:fx_rate].to_f
        sum
      end.abs
    end

    def full_amount
      @reports.reduce(0.0) { |a, e| a + e.amount.to_f } - tax
    end

    def transactions_by_app
      apps = Hash.new { |h, k| h[k] = [] }
      @config.each do |app, in_apps|
        @earnings_data.each do |transaction|
          if transaction[:vendor_identifier] == app ||
            in_apps.include?(transaction[:vendor_identifier])
            apps[app] << transaction
          end
        end
      end
      apps
    end

    def missing_reports
      found = transactions_by_app.reduce([]) do |a, e|
        a << e[1]
      end.flatten
      @earnings_data - found
    end

    def generate
      @reports = []
      by_apps = transactions_by_app.sort_by { |app| app }

      by_apps.each do |key, application|
        @reports << AppleReport.new(key, application, @exchange_info)
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

    def as_text
      amount = AppEarnings::Report.formatted_amount('USD', full_amount)
      payments = AppEarnings::Report.formatted_amount('USD', @payments_amount)
      taxes =  AppEarnings::Report.formatted_amount('USD', tax)
      not_found = missing_reports.map { |tr| tr[:vendor_identifier] }.uniq
      puts @reports
      puts "Apps missing: #{not_found.join(", ")}" unless not_found.empty?
      puts "Total of taxes: #{taxes}"
      puts "Total of all transactions: #{amount}"
      puts "Total from Payment Report: #{payments}" if amount != payments
      @reports
    end

    def as_json
      puts JSON.generate(apps: @reports.map(&:to_json),
                         currency: 'USD',
                         total: full_amount.round(2))
    end

    def as_csv
      amount = AppEarnings::Report.amount_for_csv('USD', full_amount)
      payments = AppEarnings::Report.amount_for_csv('USD', @payments_amount)
      taxes =  AppEarnings::Report.formatted_amount('USD', tax)
      missing = missing_reports.map { |tr| tr[:vendor_identifier] }.uniq
      @reports.each { |report| puts report.to_csv }
      puts %Q("Apps missing:","#{not_found.join(", ")}") unless missing.empty?
      puts %Q("Total of taxes:","#{taxes}")
      puts %Q("Total of all transactions:",#{amount}")
      puts %Q("Total from Payment Report:",#{payments}") if amount != payments
      @reports
    end
  end
end
