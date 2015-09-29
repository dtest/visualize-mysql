#!/bin/bash

#!/bin/bash
docker-env ple15

echo "Running slap"
docker exec -it mysql mysqlslap -hmysql -uroot -pple15 --create-schema="world" --no-drop --concurrency=8 --iterations=10000 \
  --query="SELECT City.Name AS city, Country.Name AS country, continent FROM City INNER JOIN Country ON CountryCode=Country.code WHERE City.Name='Amsterdam';"
