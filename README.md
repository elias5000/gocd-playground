# GoCD Test:

This is a small set of tools to test GoCD with pipelines as code.

# Components
* GoCD server
* GoCD agent (uses host's docker engine to build/run containers)
* Gitea Git repo server

# Setup
* Install Dependencies: make, Docker, Docker-compose
* Run `Make setup`
  * creates files:
    * gohome/.ssh/id_rsa
    * gohome/.ssh/id_rsa.pub - ssh key used by GoCD to access repos for material fetching
    * agentAutoRegisterKey - contains the AutoRegister Key for GoCD agents
  * brings up:
    * GoCD server
    * Gitea server
    * GoCD agents
    
# Configuration
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

# Using elastic agents
## Plugin setup
* Go to the [plugins page](http://localhost:8153/go/admin/plugins) and open settings for the Docker Elastic Agent Plugin
  * Go Server URL: https://172.17.0.1:8154/go
    * edit with your hosts IP on the docker bridge network if required
    * the elastic agents will be connected to the default bridge network and have to connect to the playground endpoints via the forwarded ports on the server
  * Agent auto-register Timeout: between 1-3 minutes 
  * Docker URI: unix:///var/run/docker.sock
  * Use Private Registry: False

## Agent Profile setup
* Go to the [Elastic Agent Profiles](http://localhost:8153/go/admin/elastic_profiles) and add a new profile
  * Id: Chose a name to your liking
  * Docker image: e.g. playground-base-agent
    * this is built by make as part of the setup target and contains the required credentials for access to the gitea server
  * Host entries:
    * 172.17.0.1 gitea (edit with your host IP on the docker bridge network if required)
* In your pipeline reference the created agent profile
* If you want to create your own agent images base them on playground-base-agent to have the SSH keys created by the setup target built-in

# Management:
* [GoCD Server](http://localhost:8153)
* [Gitea Repositories](http://localhost:3000)

# Resources:
* [CoCD YAML config plugin](https://github.com/tomzo/gocd-yaml-config-plugin)
* [Elastic Agents Plugin](https://github.com/gocd-contrib/docker-elastic-agents)
* [Pipeline as Code](https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html)
* [Gitea](https://gitea.io)
