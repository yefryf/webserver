## WebServer container for PHP Application (All-in-one)

This is a docker container with full stack LAMP services that includes:
* nginx
* PHP-FPM
* MariaDB

It's possible to deploy any php application inside it.

## Usage

To run the container:

        docker run -d -p 8080:80 -e MYSQL_PASS=mypass --name webserver yefryf/webserver

In `MYSQL_PASS` change the value to the password that you want to give to admin user.

Now you can browse to `http://<DOCKER_HOST>:8080`

### Database

- Default DBUser: admin
- Default DBName: db_web
- Default DBName: that's you set using `MYSQL_PASS` variable

Note: If no `MYSQL_PASS` have been set, a random password will be generated. Use `docker logs <container_id>` to view it.


