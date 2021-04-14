# mock_requests.sh
# This script is meant to be used interactively -- run it and use the functions it provides
# make sure that your backend is running

BACKEND=http://localhost:4000

# needs an email and a password
function create_user {
  http POST $BACKEND/api/v1/registration \
  user:="{\"email\": \"$1\", \"password\": \"$2\", \"password_confirmation\": \"$2\"}"
}

# needs an email and a password
function log_in {
  http POST $BACKEND/api/v1/session \
  user:="{ \"email\": \"$1\", \"password\": \"$2\" }"
}

# needs access token
function log_out {
  http DELETE $BACKEND/api/v1/session \
  "Authorization: $1"
}

# needs refresh token
function renew_session {
  http POST $BACKEND/api/v1/session/renew \
  "Authorization: $1"
}

function get_user {
  http GET $BACKEND/api/v1/user \
  "Authorization: $1"
}
