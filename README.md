# webserver
apt-get update

# Install Nginx Web server
apt-get install nginx
sudo systemctl enable nginx
systemctl start nginx


# Install Varnish
apt-get install varnish
sudo systemctl enable varnish
systemctl start varnish
# Use a web browser and ensure that host:6081 is listening

# Let's configure varnish
systemctl stop varnish
systemctl stop nginx
curl  > /lib/systemd/system/varnish.service
# By default Memallocation is set to 256. Edit that in the file if you need more.
systemctl daemon-reload
cd /etc/varnish
mkdir sites-enabled

# Curl the appliciable templates
curl  > sites-enabled/yourdomainname.com.vcl  # Wordpress Template

# Setup NGINX



# Install Certbot
apt-get install Certbot
cd /opt
wget https://dl.eff.org/certbot-auto
chmod a+x ./certbot-auto
./certbot-auto --install-only
chmod +x certbot-auto
curl > renew-certs.sh