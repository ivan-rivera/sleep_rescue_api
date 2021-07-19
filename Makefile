.PHONY: backend
backend:
	iex -S mix phx.server

.PHONY: pbackend
pbackend:
	MIX_ENV=prod iex -S mix phx.server

.PHONY: seed
seed:
	mix run priv/repo/seeds.exs

.PHONY: plogs
plogs:
	heroku logs --tail -a sleep-rescue-api

.PHONY: prun
prun:
	heroku run -a sleep-rescue-api "POOL_SIZE=2 iex -S mix"

.PHONY: pmigrate
pmigrate:
	heroku run -a sleep-rescue-api "POOL_SIZE=2 mix ecto.migrate"
