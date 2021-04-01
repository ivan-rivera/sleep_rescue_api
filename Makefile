.PHONY: backend
backend:
	iex -S mix phx.server

.PHONY: client
client:
	cd web_client && yarn dev && cd ..

.PHONY: seed
seed:
	mix run priv/repo/seeds.exs
