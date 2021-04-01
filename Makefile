.PHONY: backend
backend:
	iex -S mix phx.server

.PHONY: client
client:
	cd web_client && yarn dev && cd ..
