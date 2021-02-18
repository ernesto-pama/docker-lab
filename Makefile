.PHONY: setup

setup:
	cd container && docker-compose up -d

setup-dev:
	-docker volume create www-data
	make build-dev setup
	docker exec -it www make _install

shell:
	docker exec -it www bash

destroy:
	cd container && docker-compose down

migration:
	make cc
	bin/console doctrine:migrations:diff

migrate:
	bin/console doctrine:migrations:migrate -q

data:
	bin/console doctrine:fixtures:load --append

build-dev:
	cd container && docker -D build --tag ernestopama/www:latest .

push:
	docker push ernestopama/www:latest

lint:
	vendor/bin/php-cs-fixer --config=.php_cs.dist --allow-risky=yes fix -vvv

check:
	vendor/bin/php-cs-fixer --dry-run --allow-risky=yes --config=.php_cs.dist fix -vvv

scan:
	make check
	vendor/bin/phpstan analyze -l 8 --memory-limit 2G src

_install:
	composer install
	yarn install

test-coverage:
	php -d extension=xdebug.so -d xdebug.profiler_enable=on ././bin/phpunit --testsuite unit --stop-on-failure --coverage-text=coverage/unitreport.txt --coverage-html public/coverage
	cat coverage/unitreport.txt

test-acceptance:
	vendor/bin/codecept run

chromedriver:
	bin/chromedriver --url-base=/wd/hub

selenium:
	vendor/bin/codecept run

security:
	bin/console security:check

test-unit:
	./bin/phpunit --testsuite unit -vvv

test-functional:
	-bin/console doctrine:database:drop --force --env test
	bin/console doctrine:database:create --env test
	bin/console doctrine:migrations:migrate -q --env test
	bin/console doctrine:fixtures:load --append -q --env test
	bin/phpunit

cc:
	bin/console c:c
	bin/console doctrine:cache:clear-metadata

clean:
	git clean checkout .
	git clean -df
	docker volume rm -f www-data
	make setup
	docker exec -it www make _install
