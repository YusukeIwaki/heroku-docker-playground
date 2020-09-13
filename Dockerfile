FROM ruby:2.6-slim-buster

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Firefox Nightly
RUN apt-get update \
    && apt-get install -y libdbus-glib-1-2 libxt6 \
    && wget -O nightly.tar.bz2 "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" \
    && tar xf nightly.tar.bz2 \
    && ln -s $(pwd)/firefox/firefox /usr/bin/firefox


RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
RUN bundle install
COPY main.rb /app/main.rb
CMD bundle exec ruby main.rb -p $PORT -o 0.0.0.0
