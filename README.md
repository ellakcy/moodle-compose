Moodle with mysql deployment recipe

## Installation
Run the following commands:

```bash
git clone git@github.com:ellakcy/moodle-compose.git
ln -s ^correct_moodle_compose.yml^ docker-compose.yml
```

On the last command above replace `^correct_moodle_compose.yml^` with one of the following table:

How to run php | Mysql | Mariadb | Postgresql
--- | --- | --- | ---
apache | `docker-compose_mysql_apache.yml` | `docker-compose_maria_apache.yml` | `docker-compose_postgresql_apache.yml`
fpm | `docker-compose_postgresql_alpine_fpm.yml` | `docker-compose_maria_alpine_fpm.yml` | `docker-compose_postgresql_alpine_fpm.yml`

Then edit the `.env` file accorditly, you will need to put some values in it please rest easy in in there are instructions in it regarding the values to fill. This can be done via a text editor:

```bash
nano .env
```

Or

```bash
vi .env
```

After that you can start the moodle via:

```bash
docker-compose up -d
```

And you stop with:

```bash
docker-compose stop
```

## Run newer version:

Just run the following command:

```bash
docker-compose stop && docker-compose rm && docker-compose pull && docker-compose up -d
```

With that we stopped removed the old images we fetched the new ones and we rerun the new containers

## Info regarding the moodle's url

Most of the times the moodle may need to run behind an http reverse proxy. In this case set the value for the url that the end user will type in his/her browser. )Otherwise set the value http://0.0.0.0:8082

### In case you ewant to change port that webserver listens

You should edit the following files:

* `./conf/nginx.conf` (In case of fpm)
* `docker-compose.yml` (As seen above we symlinked it into the appropriate file)
* `.env` In order to change the application's url (if the url something like http://0.0.0.0:^some_port^).

Please keep in mind that the `nginx` container must listen to the very same port that is mapped into. In any other case it may cause redirect loop.

## Nginx vhost as reverse proxy

The recomended way to use it is using ssl and set the following:

```nginx
server {
	listen 80;
	# Put the site's url
	server_name ^site_url^;
	rewrite ^ https://$server_name$request_uri? permanent;
}

server {

	listen 443 ssl;

        ssl_certificate     ^path to certificate^;
       	ssl_certificate_key ^path to certificate key^;
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

          # In case or running another port please replace the value bellow.
        	proxy_pass http://0.0.0.0:8082;
	}
}

```

Please replace the values that are between `^` with apropriate ones. For ssl certificate we recomend the letencrpypt's certbot.
