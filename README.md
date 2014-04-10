app_earnings
============

Process App Store monthly "raw" CSV files into a report by Application and IAP. 
Currently supports Google Play and Amazon Android marketplace data.

## Background

Egghead Games is an independent app developer who has to provide monthly royalties to various licensors based on sales. 
None of the existing tools like Distimo or App Annie provided data that was sufficiently accurate to make payments. 
The stores provide data files (usually CSV) with the raw data, but processing these by hand or spreadsheet is painful.
This command utility takes the CSV files and outputs sales by app and in-app purchase within the app. 
It takes into account refunds and currency conversions, so that the amounts given should exactly correspond to the payments
made by the app store.

## Description

The Google Play and Amazon Android Marketplaces provide monthly earning reports in the form of CSV files.

This command line utility processes the transactions, groups them by app and in-app purchase (IAP), and produces the net dollar amount for each app. It includes the following features:

 * handles returns 
 * provides sub-totals for IAPs, so you can see how much individual IAPs are earning.
 * uses Amazon exchange rates to ensure that all amounts are in your final currency
 * should handle non-USD Google Wallet accounts (though this is untested)
 * JSON output is available, to make further processing simpler

By default, it provides simple text output.

## Installation

Install it yourself as:

    $ gem install app_earnings

## Usage

This will show the full set of current commands and options:

	app_earnings help

### Google Play Marketplace

To process a Google Play monthly earnings report csv file into a text sales report:

	app_earnings play PlayApps_201401.csv

Alternatively, you can get a JSON version of the data with:

	app_earnings play PlayApps_201401.csv --format json

### Amazon Android Marketplace

To process Amazon monthly earnings report files into a text sales report:

	app_earnings amazon EarningsReport-Jan-1-2014-Jan-31-2014.csv PaymentReport-Feb-1-2014-Mar-1-2014.csv

Note that the payment report must be for the month after, as Amazon payments happen a month in arrears.

Alternatively, you can get a JSON version of the data with:

	app_earnings amazon EarningsReport-Jan-1-2014-Jan-31-2014.csv PaymentReport-Feb-1-2014-Mar-1-2014.csv --format json


## Contributing

1. Fork it ( http://github.com/eggheadgames/app_earnings/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
