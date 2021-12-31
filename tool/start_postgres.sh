docker run --rm --name some-postgres \
  -e POSTGRES_USER=username \
  -e POSTGRES_PASSWORD=password \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -v /Users/xavier/_data/some-postgres:/var/lib/postgresql/data \
  --publish 5434:5432 \
  postgres:13.5
