# Init

`docker build -t slave:latest .`

`docker volume create slave_data`

`docker network create pipe-to-slave`

`docker run -v slave_data:/home/slave -p 2198:21 --name=Jenkins_slave --restart=always --network=pipe-to-slave slave:latest`

#### Then attach your jenkins to `pipe-to-slave` network