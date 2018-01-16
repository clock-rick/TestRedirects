require 'selenium-webdriver'
require 'csv'
require 'chromedriver/helper'
require 'colorize'

=begin
 This test will open two csv files, the first with original urls
 and the second with the redirects. The test will compare take the
 original url and record the redirect in browser. Then compare it to
the url from the second csv. The results will be displayed in the output screen.
The failures will be recorded into a new csv.
=end
class Redirects
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  driver = Selenium::WebDriver::Driver.for :chrome, options: options
  url_hash = {}
  csv_array = []
  row_counter = 2 # Change this value to 1 if your csv does not have a header.

=begin
This section reads the redirects csv and places each row of information into the array.
Since both the 'to url' and the 'from url' are contained within the same row, they both are contained
in the value of each array key. You will need to either update the path and csv name to what you want or edit the
csv itself with your new redirects.
=end
  CSV.foreach('Redirects.csv', headers: true) { |row| csv_array << row.to_s}

=begin
This section iterates through the csv array and splits the from url and to url into a new array
so each url is associated to its own key then that the values are associated from the new array to a new hash called
'url_hash'. In the hash the from url is the key and the to url is the value.
=end
  csv_array.each { |word|
    @my_word = word.split(',')
    url_hash[@my_word[0]] = @my_word[1]}
=begin
In this section we direct the driver to proceed to the 'from_url'. If the redirect is in place by the developer than
the redirect will initiate automatically and direct the driver to the 'to_url'. The 'redirected_to' variable grabs
the current url which should be the where the driver was redirected to. We then compare that 'redirected_to' url to
the 'to_url' from the redirects spreadsheet and do a compare. If it's a pass then the snippet prints out
the 'from_url' and to_url and marks it as a Pass. If it does not match, we print the 'from_url' and 'to_url' and the
'redirected_url' and we mark it as a fail. All fails are captured into a new csv. You should go into the snippet and
name the new csv to something relevant to the project. After the run is complete the driver quits.
=end

  url_hash.each { |from_url, to_url|
    driver.navigate.to from_url
    driver.manage.timeouts.page_load = 1000
    redirected_to = driver.current_url.to_s.downcase
    from_actual = from_url.to_s.downcase.strip
    to_actual = to_url.to_s.downcase.strip
    if redirected_to == to_actual
      puts "ROW #{row_counter}: PASS ".green + from_actual + ' >>> '.green + to_actual
    else
      puts "ROW #{row_counter}: Fail ".red + from_actual + ' >>> '.red + to_actual + ' Redirected to '.red + redirected_to
      CSV.open('RedirectFails.csv', 'a') { |csv| csv << [from_actual, to_actual, redirected_to]}
    end
    row_counter += 1
  }
  driver.quit
rescue StandardError => e
  puts e
end