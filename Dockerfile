FROM ubuntu

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get install -qy curl python ca-certificates gnupg2 build-essential --no-install-recommends && \
    apt-get clean

# Install rvm
RUN gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s && \
    /bin/bash -l -c ". /etc/profile.d/rvm.sh"
# Install ruby 2.1.2, as this is the one used to build the website
RUN /bin/bash -l -c "rvm install ruby-2.1.2"

WORKDIR /usr/workspace

COPY Gemfile .
COPY Gemfile.lock .
RUN /bin/bash -l -c "bundle install"

ENTRYPOINT ["/bin/bash", "-l", "-c"]