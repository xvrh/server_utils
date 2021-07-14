docker exec -it some-postgres psql -d postgres -U username <<-EOSQL \
  select 1 \
EOSQL