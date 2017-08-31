require 'selenium-webdriver'
require 'csv'
require 'chromedriver/helper'

=begin
 This test will open two csv files, the first with original urls
 and the second with the redirects. The test will compare take the
 original url and record the redirect in browser. Then compare it to
the url from the second csv. The results will be displayed in the output screen.
The failures will be recorded into a new csv.
=end

class Redirects
  driver = Selenium::WebDriver::Driver.for :firefox
  col_data1 = []
  col_data2 = []
  i = -1
  t = -1

  CSV.foreach('Workbook1.csv', headers: true ) { |row| col_data1 << row[0]}
  CSV.foreach('Workbook2.csv', headers: true) {|row| col_data2 << row[0]}
  col_data1.each{|from_url|
    driver.navigate.to from_url
    driver.manage.timeouts.page_load = 1000
    redirected_to = driver.current_url.to_s.downcase
    to_actual = col_data2[i += 1]
    from_actual = col_data1[t += 1]
    from_actual = from_actual.downcase.strip
    to_actual = to_actual.downcase.strip
    if redirected_to == to_actual
      puts from_actual + ' >>> ' + to_actual + ' PASS'
    else
      puts from_actual + ' XXX ' + to_actual + ' FAIL Redirected to ' + redirected_to
      CSV.open('DunnBrosRedirectFails.csv', 'a') { |csv| csv << [from_actual, to_actual, redirected_to]}
    end
  }
  driver.quit
rescue StandardError => e
  puts e

end