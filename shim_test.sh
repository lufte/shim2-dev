mkdir /opt/userify
cat << "EOF" > /opt/userify/creds.py
# public dev/testing credentials
api_key = "s3kvVb5QUw4sEGzuzyiYLMTTGVu2ifbGeedeg2ZULnDmJQhXYM"
api_id = "zhqcbwpxfakrg2yxnxavwz_user"
EOF
cat << "EOF" > /opt/userify/userify_config.py
debug = 1
dry_run = 1
shim_host = "configure.userify.com"
static_host = "static.userify.com"
self_signed = 0
EOF
# shim should use parsecfg to read config and creds
