# GoCD Test:

This is a small set of tools to test GoCD with pipelines as code.

# Components
* GoCD server
* GoCD agent (uses host's docker engine to build/run containers)
* Gitea Git repo server

# Setup
* Install Dependencies: Docker, Docker-compose
* Create ssh_key for your playground by running `ssh-keygen -t rsa -f gohome/.ssh/id_rsa` and chose empty passphrase
* Startup cluster
  * Run `docker-compose up -d --scale agent=0` to start up the containers (except agents - we will start them in a minute)
  * Copy the value for agentAutoRegisterKey from [the XML config](http://localhost:8153/go/admin/config_xml) and edit it in docker-compose.yaml for the agent
  * Run `docker-compose up -d --scale agent=2` to start the agents
* Create a new user on the [Gitea Server](http://localhost:3000)
* Create a new repo for pipeline code on Gitea
* Create some pipeline configuration inside the repo
   * You can use [this](https://github.com/tomzo/gocd-yaml-config-example/blob/master/ci.gocd.yaml) as a starting point
   * Any files matching `*.gocd.yaml*` will be used by GoCD by default
* Add the public key as publish key to the new git repo
* Configure the GoCD server to use your newly created repo as a pipeline config source
  * Insert this snippet in the [Config XML](http://localhost:8153/go/admin/config_xml/edit) right after the `<server>` entry
```
 <config-repos>
    <config-repo pluginId="yaml.config.plugin" id="ots-pipeline-code">
      <git url="http://gitea:3000/my-user/my-pipeline-code-repo.git" />
    </config-repo>
  </config-repos>
```
* Create a git repo on your production source control or reuse an existing one
* Configure your production GoCD similarly, but against the production source control pipeline repository
* Configure the production git repository as another git remote to your local clone of the pipeline repository

# Pipeline development workflow

* Edit the pipeline yaml as you see fit
* Commit locally and push to the Gitea git remote
  * The change should be applied by GoCD shortly
  * In case of failure, the previous version will be kept and any errors will be shown on the top right corner of the GoCD UI
* Iterate over the pipeline code locally with repeated commits (you can also amend the same commit) until you're happy with the configuration
* When ready, tidy up your local git history and push to the production git remote to update your production GoCD configuration


# Management:
* [GoCD Server](http://localhost:8153)
* [Gitea Repositories](http://localhost:3000)

# Resources:
* [CoCD YAML config plugin](https://github.com/tomzo/gocd-yaml-config-plugin)
* [Pipeline as Code](https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html)
* [Gitea](https://gitea.io)
