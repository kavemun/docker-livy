# docker-livy

A Docker image for [Livy, the REST Spark Server](https://github.com/cloudera/livy). This project borrows heavily from [Tobi's docker-livy](https://github.com/tobilg/docker-livy) with a few adjustment to install python packages which the python api's depend on.

## Running Livy Server 

The docker image must first be build by calling 

`docker build -t docker-livy .`

The image can be then i be run with 

`docker run -p 8998:8998 -d docker-livy`

which will expose the port `8998` on the Docker host for this image.


[The Official docs for Livy REST API can be found here](https://github.com/cloudera/livy#rest-api). 
