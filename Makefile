all:
	@echo "Run specific stages or clean\n"
	@echo "Stages:"
	@echo "\tsetup\t\tstart GoCD server "
	@echo "\tup\t\tstart all containers"
	@echo "\tdown\t\tdestroy all containers"
	@echo "\tclean\t\tcleanup everything (delete data)"

.PHONY: setup server cluster down clean up summary agent wait

setup: server agent .agentAutoRegisterKey .agent_env cluster summary

up: cluster summary

down: .agent_env
	@docker-compose down

agent:
	@docker build -f docker/Dockerfile.elastic -t playground-base-agent:latest .

server: .gohome/ssh/id_rsa*
	@mkdir -p godata/plugins/external
	@echo "downloading plugins..."
	@wget -P godata/plugins/external https://github.com/gocd-contrib/script-executor-task/releases/download/0.3/script-executor-0.3.0.jar
	@wget -P godata/plugins/external https://github.com/gocd-contrib/docker-elastic-agents/releases/download/v0.9.0/docker-elastic-agents-0.9.0-129.jar
	@touch .agent_env
	@docker-compose up -d --scale agent=0
	@rm -f .agent_env

wait:
	@echo "waiting for the server to come up..."
	@while ( ! curl -sf -o /dev/null http://localhost:8153/go/api/admin/config.xml ); do sleep 5; done

summary: wait
	@echo "\n##################################################"
	@echo "Your cluster is ready. \(^.^)/"
	@echo "##################################################"
	@echo "Management:"
	@echo "  GoCD Web interface: http://localhost:8153/go/"
	@echo "  Gogs Repos:         http://localhost:3000/\n"
	@echo "Public SSH key for repo access:"
	@echo "  ./gohome/.ssh/id_rsa.pub"
	@echo "##################################################"

.agentAutoRegisterKey: wait
	@curl -sf http://localhost:8153/go/api/admin/config.xml | grep .agentAutoRegisterKey | sed -e 's/.*agentAutoRegisterKey="\([^"]*\).*/\1/' \
		> .agentAutoRegisterKey

cluster:
	@docker-compose up -d --scale agent=1

.agent_env:
	$(eval KEY := $(shell cat .agentAutoRegisterKey))
	@echo "AGENT_AUTO_REGISTER_KEY=${KEY}" > .agent_env

.gohome/ssh/id_rsa*:
	@ssh-keygen -t rsa -N "" -f gohome/.ssh/id_rsa

clean: down
	@rm -f  .agent_env
	@rm -f  .agentAutoRegisterKey
	@rm -rf gogs/git
	@rm -rf gogs/gogs/log
	@rm -rf gogs/gogs/data
	@rm -rf gogs/ssh
	@rm -rf godata
	@rm -f  gohome/.ssh/id_rsa*
