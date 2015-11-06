FROM ubuntu
MAINTAINER Truong LD version: 1.0
RUN sed -i '$ a\deb http://mirror-fpt-telecom.fpt.net/ubuntu/ trusty main' /etc/apt/sources.list
RUN sed -i '$ a\deb-src http://mirror-fpt-telecom.fpt.net/ubuntu/ trusty main' /etc/apt/sources.list
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y build-essential g++ curl libssl-dev apache2-utils sshfs openssh-server libmysqlclient-dev python-dev tcl8.5 redis-server libxml2-dev libxslt1-dev git
RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py
RUN python /tmp/get-pip.py
ADD ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
# port for python
EXPOSE 8000
# port for ssh: 22
EXPOSE 22
service ssh start
# open port and run redis server
EXPOSE 6379
RUN /usr/bin/redis-server /etc/redis/redis.conf

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
    
# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 3000
EXPOSE 3333

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["node", "/cloud9/server.js", "--listen","0.0.0.0","--port","3333","-w","/workspace",">/dev/null","2>&1"]
