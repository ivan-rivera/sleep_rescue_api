# mock_requests.sh
# This script is meant to be used interactively -- run it and use the functions it provides
# make sure that your backend is running

BACKEND=http://localhost:4000

# needs an email and a password
function create_user {
  http POST $BACKEND/api/v1/registration \
  user:="{\"email\": \"$1\", \"password\": \"$2\", \"password_confirmation\": \"$2\"}"
}

function confirm_email {
  http GET $BACKEND/api/v1/confirm/$1
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

function delete_user {
  http DELETE $BACKEND/api/v1/user \
  "Authorization: $1" current_password=$2
}

function change_email {
  http PATCH $BACKEND/api/v1/user \
  "Authorization: $1" current_password=$2 email=$3
}

function change_password {
  http PATCH $BACKEND/api/v1/user \
  "Authorization: $1" current_password=$2 password=$3 password_confirmation=$4
}

function get_reset_password_token {
  http POST $BACKEND/api/v1/password/reset email=$1
}

function set_password_via_reset_token {
  http PATCH $BACKEND/api/v1/password/update/$1 password=$2 password_confirmation=$3
}

SFMyNTY.NDhmMGY3MDYtOGVlMi00NjA3LWFjOWItNDY1MWRlNDNmODFm.sav1BZL8OQX_XjEswp3iQqvTTrMZbeYUAP8fB4eUbHg
