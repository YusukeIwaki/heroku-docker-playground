require 'sinatra'

get '/' do
  'browse /puppeteer?q=xxxx'
end
get '/puppeteer' do
  if params['q']
    require 'puppeteer'

    options = {
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
      executable_path: ENV['PUPPETEER_EXECUTABLE_PATH'],
    }

    titles = []
    Puppeteer.launch(**options) do |browser|
      page = browser.pages.first || browser.new_page
      page.goto("https://www.google.com/")
      page.click('input[name="q"]')
      page.keyboard.type_text(params['q'])
      await_all(
        page.async_wait_for_navigation,
        page.keyboard.async_press("Enter"),
      )

      titles = page.SS("#search h3").map do |item|
        item.evaluate("a => a.textContent")
      end
    end

    titles.join(",")
  else
    "browser with ?q=xxx"
  end
end
