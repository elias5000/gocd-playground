# GoCD Test:

This is a small set of tools to test GoCD with pipelines as code.

# Components
* GoCD server
* GoCD agent (uses host's docker engine to build/run containers)
* Gogs Git repo server

# Setup
* Install Dependencies: Docker, Docker-compose
* Create ssh_key for your playground by running `ssh-keygen -t rsa -f gohome/.ssh/id_rsa` and chose empty passphrase
* Startup cluster
  * Run `docker-compose up -d --scale agent=0` to start up the containers (except agents - we will start them in a minute)
  * Copy the value for agentAutoRegisterKey from [the XML config](http://localhost:8153/go/admin/config_xml) and edit it in docker-compose.yaml for the agent
  * Run `docker-compose up -d --scale agent=2` to start the agents
* Create new user on the [Gogs Server](http://localhost:3000)
* Create new repo for pipeline code
* Add the public key as publish key to the new repo
* Configure the GoCD server to use your newly created repo as pipeline config source

# Management:
* [GoCD Server](http://localhost:8153)
* [Gogs Repositories](http://localhost:3000)

# Resources:
* [CoCD YAML config plugin](https://github.com/tomzo/gocd-yaml-config-plugin)
* [Pipeline as Code](https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html)
