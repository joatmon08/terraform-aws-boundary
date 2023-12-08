setup_test:
	cd tests/setup && terraform apply

clean:
	cd tests/setup && terraform destroy