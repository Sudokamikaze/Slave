.PHONY: install
install: all

all:
	@ansible-playbook playbooks/inventory_gen.yml
	@ansible-playbook --ask-become-pass playbooks/slave_deploy.yml
	@echo "Done!"