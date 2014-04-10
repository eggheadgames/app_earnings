require 'spec_helper'

describe AppEarnings::Report do
  let(:google_fee) { { product_title: "one", transaction_type: "Google Fee", merchant_currency: "USD", amount_merchant_currency: 10.0, sku_id: '1' } }
  let(:charge) { { product_title: "two", transaction_type: "Charge", merchant_currency: "USD", amount_merchant_currency: 20.0 } }
  let(:charge_eur) { { product_title: "two", transaction_type: "Charge", merchant_currency: "EUR", amount_merchant_currency: 20.0 } }
  let(:transactions) { [ google_fee, charge, google_fee, charge_eur ] }

  before(:each) do
    @report = AppEarnings::GooglePlay::PlayReport.new("Product one", transactions)
  end

  it "should return count of transactions by type" do
    expect(@report.transactions_count_by_type).to include( { "Google Fee" => 2 }, { "Charge" => 2 })
  end

  it "should group transactions by type" do
    expect(@report.transactions_by_type.keys).to include("Google Fee", "Charge")
  end

  it "should not include transactions made for IAP" do
    expect(@report.transactions_from_product.all? { |tr| tr[:sku_id].nil? }).to be_true
  end

  it "should not include transactions made from product" do
    expect(@report.transactions_from_in_app_purchases.all? { |tr| !tr[:sku_id].nil? }).to be_true
  end

  it "should group transactions by product title (IAP)" do
    transactions_by_product = @report.transactions_from_in_app_purchases_by_id_and_name
    counter = transactions_by_product.map { |product, transactions| [ product, transactions.length] }
    expect(counter).to include([["1", "one"], 2])
  end

  it "should retrieve amount from a list of transactions" do
    amount = @report.amount_from_transactions(transactions)
    expect(amount).to include({ currency: "USD", amount: 40.00 })
  end

  it "should retrieve totals by product title" do
    amounts = @report.total_from_in_app_purchases
    expect(amounts).to include({ id: "1", name: "one", currency: "USD", amount: 20.00})
  end
end
