const http = require("http");
const url = require("url");
const puppeteer = require("puppeteer-core");

//create a server object:
http
  .createServer((req, res) => {
    const requestUrl = url.parse(req.url, true);
    let keyword = requestUrl.query["q"];
    if (!keyword) {
      res.write("request with ?q=xxxx");
      res.end();
    } else {
      puppeteer
        .launch({
          args: ["--no-sandbox", "--disable-setuid-sandbox"],
          executablePath: process.env.PUPPETEER_EXECUTABLE_PATH,
        })
        .then(async (browser) => {
          const page = (await browser.pages())[0] || (await browser.newPage());

          // ここから自動操作
          await page.goto("https://google.com/");
          await page.type("input[name='q']", requestUrl.query["q"]);
          await Promise.all([
            page.waitForNavigation(),
            page.keyboard.press("Enter"),
          ]);

          let text = await page.evaluate(() => document.body.textContent);
          await page.close();

          res.write(text);
          res.end();
        });
    }
  })
  .listen(process.env.PORT);
