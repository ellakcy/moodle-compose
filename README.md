Moodle with mysql deployment recipe

##Installation
Just run on your command line:

```````
cd ^path that you cloned your project^
./scripts/install.sh

```````

After that you can start the moodle via:

``````
./^SITES_URL^/start.sh

``````

And you stop with:

``````
./^SITES_URL^/stop.sh

``````
Where ^SITES_URL^ is the url specified on the instalation script when it asks for. Look below for more info.

##Info regarding the moodle's url

Most of the times the moodle may need to run behind an http reverse proxy. In this case set the value for the url that the end user will type in his/her browser. )Otherwise set the value http://0.0.0.0:8082

##Nginx vhost as reverse proxy

The recomended way to use it is using ssl and set the following:

`````
server {
	listen 80;
	server_name *site_url*;
	rewrite ^ https://$server_name$request_uri? permanent;
}

server {

	listen 443 ssl;

        ssl_certificate     *path to certificate*;
       	ssl_certificate_key *path to certificate key*;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
	server_name ellak.org;

	location / {

		proxy_http_version 1.1;
       		proxy_set_header Upgrade $http_upgrade;
       		proxy_set_header Connection 'upgrade';
       		proxy_set_header Host $host;
       		proxy_set_header X-Real-IP $remote_addr;
       		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       		proxy_set_header X-Forwarded-Proto $scheme;
       		proxy_cache_bypass $http_upgrade;

        	proxy_pass http://0.0.0.0:8082;
	}

}

`````

Please replace the values with *italics* to the apropriate values. For ssl certificate we recomend the letencrpypt's certbot.
