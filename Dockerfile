FROM juajim/homestead:1.1
MAINTAINER Andy Juarez <andy@juajim.info>

# install more system tools
RUN dnf -y --setopt=deltarpm=false tar

# install git for source control
RUN dnf -y --setopt=deltarpm=false install git

# install supervisor to run processes
RUN dnf -y --setopt=deltarpm=false install supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Delete ssh login blocking file...
RUN rm /run/nologin

# Include the nginx enabled sites from modular conf directory...
COPY sites.conf /etc/nginx/conf.d/sites.conf

## Install Node required packages
RUN npm -g install grunt-cli karma bower

#########################################
#ADD serve.sh /serve.sh
#ADD run.sh /run.sh

#RUN chmod +x /*.sh

#RUN ./provision.sh

EXPOSE 80 22 35729 9876
#CMD ["/run.sh"]
#########################################

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
