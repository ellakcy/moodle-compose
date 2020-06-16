# Deployment recipe for ellakcy's docker moodle images

A recipe/boilerplate in order to get the images from community's [moodle](https://github.com/ellakcy/docker-moodle) repo up and running.

## Installation
Run the following commands:

```bash
git clone git@github.com:ellakcy/moodle-compose.git
ln -s ^correct_moodle_compose.yml^ docker-compose.yml
```

On the last command above replace the `^correct_moodle_compose.yml^` with one of the following table:

Database | apache | alpine fpm | lts
--- | --- | --- | ---
Mysql | `docker-compose_mysql_apache.yml`  |  `docker-compose_postgresql_alpine_fpm.yml` | no
mariadb | `docker-compose_maria_apache.yml` | `docker-compose_maria_alpine_fpm.yml` | no
postgresql | `docker-compose_postgresql_apache.yml` | `docker-compose_postgresql_alpine_fpm.yml` | no


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

Most of the times the moodle may need to run behind an http reverse proxy. In this case set the value for the url that the end user will type in his/her browser. Otherwise set the value http://0.0.0.0:8082

### In case you want to change port that docker delivered nginx webserver listens

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
	return 301 https://$server_name$request_uri;
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

Please replace the values that are between `^` with apropriate ones. For ssl certificate we recomend the letencrpypt's certbot. Also the reverse proxy should **NEVER** forward the `Host` http header. For more info you can consult the [nginx configuration](https://raw.githubusercontent.com/ellakcy/docker-moodle/master/conf/nginx/nginx_ssl_reverse.conf) delivered by us.

## Migrations from fpm to apache

You can easily migrate from fpm ones into apache ones, but theese concers should be followed:

* The database layer should be the same eg. if you select `mysql` variant stick to that.
* Remove the `docker-compse.yml` and link with the aqpache variant.
* The opposite shoulde be plausible as well.

## I made my own image how can I play with?

Is reccomended to link the appropriate yml file and replace the `image` at `moodle` section with your own. For example let suppose we a `foo/moodle` image based on `ellakcy/moodle:mysql_maria_apache` then we will run the following commands:

```bash
ln -s docker-compose_mysql_apache.yml docker-compose.yml
```

Then we will edit the `docker-compose.yml`:

```bash
nano docker-compose.yml
```

And we will put the following content:


```yaml

version: '2'

services:

  moodle_db:
    image: mysql
    volumes:
      - './data/db:/var/lib/mysql'
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
      MYSQL_ONETIME_PASSWORD: "yes"
      MYSQL_DATABASE: $MOODLE_DB_NAME
      MYSQL_USER: $MOODLE_DB_USER
      MYSQL_PASSWORD: $MOODLE_DB_PASSWORD

  moodle:
    image: foo/moodle
    volumes:
      - './data/moodle:/var/moodledata'
    ports:
      - '8082:80'
    links:
      - moodle_db
    environment:
      MOODLE_URL: $MOODLE_URL
      MOODLE_ADMIN: $MOODLE_ADMIN
      MOODLE_ADMIN_PASSWORD: $MOODLE_ADMIN_PASSWORD
      MOODLE_ADMIN_EMAIL: $MOODLE_ADMIN_EMAIL
      MOODLE_DB_TYPE: "mariadb"
      MOODLE_DB_HOST: "moodle_db"
      MOODLE_DB_USER: $MOODLE_DB_USER
      MOODLE_DB_PASSWORD: $MOODLE_DB_PASSWORD
      MOODLE_DB_NAME: $MOODLE_DB_NAME
      MOODLE_REVERSE_LB: $MOODLE_REVERSE_LB
      MOODLE_SSL: $MOODLE_SSL
      MOODLE_EMAIL_TYPE_QMAIL: $MOODLE_EMAIL_TYPE_QMAIL
      MOODLE_EMAIL_HOST: $MOODLE_EMAIL_HOST
```
