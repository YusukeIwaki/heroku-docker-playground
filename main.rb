require 'sinatra'
require 'securerandom'

get '/' do
  'browse /chrome?url=xxxx or /firefox?url=xxxx'
end
get '/chrome' do
  if params['url']
    require 'puppeteer'

    options = {
      product: 'chrome',
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
      executable_path: '/usr/bin/google-chrome',
    }

    image_name = "chrome-#{SecureRandom.hex(8)}.png"
    Puppeteer.launch(**options) do |browser|
      page = browser.new_page
      page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
      page.goto(params['url'])
      page.screenshot(path: "/tmp/#{image_name}")
      page.close
    end

    content_type 'image/png'
    send_file("/tmp/#{image_name}")
  else
    "browser with ?url=xxx"
  end
end
get '/firefox' do
  if params['url']
    require 'puppeteer'

    options = {
      product: 'firefox',
      headless: true,
      executable_path: '/usr/bin/firefox',
    }

    image_name = "firefox-#{SecureRandom.hex(9)}.png"
    Puppeteer.launch(**options) do |browser|
      page = browser.new_page
      page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
      page.goto(params['url'])
      page.screenshot(path: "/tmp/#{image_name}")
      page.close
    end

    content_type 'image/png'
    send_file("/tmp/#{image_name}")
  else
    "browser with ?url=xxx"
  end
end
