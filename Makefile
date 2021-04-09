.PHONY: backend
backend:
	iex -S mix phx.server

.PHONY: seed
seed:
	mix run priv/repo/seeds.exs
