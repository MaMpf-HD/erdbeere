
FROM ruby:3.3.7

ENV RAILS_ENV=production

EXPOSE 3000

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# https://github.com/nodesource/distributions#installation-instructions
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

RUN apt-get update && apt-get install -y nodejs pkg-config sqlite3 nano --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN groupadd -g 501 app && useradd -g 501 -u 501 -m -d /usr/src/app app
# Set working directory
WORKDIR /tmp

# Download, extract, compile PicoSAT with trace enabled
RUN wget http://fmv.jku.at/picosat/picosat-965.tar.gz && \
    tar -xzvf picosat-965.tar.gz && \
    cd picosat-965 && \
    ./configure.sh --trace && \
    make

# Copy the binary to /usr/local/bin and ensure it's executable
RUN cp /tmp/picosat-965/picosat /usr/local/bin/ && \
    chmod +x /usr/local/bin/picosat

WORKDIR /usr/src/app
USER app
COPY --chown=app:app ./Gemfile /usr/src/app
COPY --chown=app:app ./Gemfile.lock /usr/src/app
RUN bundle install
COPY --chown=app:app ./ /usr/src/app
