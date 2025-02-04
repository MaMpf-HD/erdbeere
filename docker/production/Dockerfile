
FROM ruby:3.3.7

ENV RAILS_ENV=production

EXPOSE 3000

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# https://github.com/nodesource/distributions#installation-instructions
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Add PostgreSQL Apt repository and key for client-13
RUN echo "deb [signed-by=/usr/share/keyrings/pgdg-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
      gpg --dearmor -o /usr/share/keyrings/pgdg-archive-keyring.gpg

RUN apt-get update && apt-get install -y nodejs pkg-config postgresql-client-13 --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tmp

# Download, extract, compile PicoSAT with trace enabled
RUN wget  https://raw.githubusercontent.com/MaMpf-HD/software-dependencies/main/picosat-965.tar.gz && \
    tar -xzvf picosat-965.tar.gz && \
    cd picosat-965 && \
    ./configure.sh --trace && \
    make

# Copy the binary to /usr/local/bin and ensure it's executable
RUN cp /tmp/picosat-965/picosat /usr/local/bin/ && \
    chmod +x /usr/local/bin/picosat

RUN groupadd -g 501 app && useradd -g 501 -u 501 -m -d /usr/src/app app

WORKDIR /usr/src/app
USER app
COPY --chown=app:app ./Gemfile /usr/src/app
COPY --chown=app:app ./Gemfile.lock /usr/src/app
RUN bundle install
COPY --chown=app:app ./ /usr/src/app
