
FROM ruby:3.0.7

ENV RAILS_ENV=production

EXPOSE 3000

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# https://github.com/nodesource/distributions#installation-instructions
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -


RUN apt-get update && apt-get install -y nodejs pkg-config sqlite3 nano picosat --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Upgrade RubyGems to version 3.3.22
# RUN gem update --system 3.3.22

RUN groupadd -g 501 app && useradd -g 501 -u 501 -m -d /usr/src/app app
WORKDIR /usr/src/app
USER app
COPY --chown=app:app ./Gemfile /usr/src/app
COPY --chown=app:app ./Gemfile.lock /usr/src/app
RUN bundle install
COPY --chown=app:app ./ /usr/src/app
