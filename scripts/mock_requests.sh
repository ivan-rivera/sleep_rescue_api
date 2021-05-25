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

function update_night {
  http PATCH $BACKEND/api/v1/night \
  "Authorization: $1" \
  date=$2 \
  night:="{ \"slept\": $3, \"sleep_attempt_timestamp\": $4, \"final_awakening_timestamp\": $5, \"up_timestamp\": $6, \"falling_asleep_duration\": $7, \"night_awakenings_duration\": $8, \"rating\": $9 }"
}

function show_night {
  http GET $BACKEND/api/v1/night/$2 \
  "Authorization: $1"
}

SFMyNTY.YjE1NzkwZmUtMjA4My00NzcwLWI0MzItYWNmZTJlYWE0M2Ex.1ThEFGvRyoHqOkmYQ3l881ni6a9ybea_yy6nQ33Bf_k
