import net
import httpclient
import base64
import json
import tables

# How to post data to a server.
# Covers a key part of shim.py that actually connects to the Userify server (configure.userify.com, or whatever)
# via HTTPS and initiates the connection. (Please note: this was not updated for the TLS features for self-signed servers that
# have been rolled into Nim core.)

proc postDataToServer*(config: object, post_body: string=""): JsonNode =

  let post_body = post_body
  let authstr = config.creds.api_id + ":" + config.creds.api_key
  let auth = "basic " + base64.encode(authstr, newline="")

  # var new_ssl_context = newContext(
  #  protVersion=protTLSv1,
  #  verifyMode = CVerifyPeer,
  #  certFile="/etc/ssl/cert.pem"
  # )

  let client = newHttpClient(
   # sslContext=new_ssl_context,
   proxy=nil,
   userAgent="Userify Shim 2.0",
  )

  client.headers = newHttpHeaders({
    "Authorization": auth,
    "Accept": "text/plain, */json",
    "X-Local-IP": "192.168.1.1"
  })

  let response = client.request(
    url="https://" + config.server.hostname + config.server.configure_path,
    httpMethod="POST",
    body=post_body
  )

  if response.status != "200 OK":

    echo "HTTP error: " + response.status
    echo response.headers[]
    # error status is the actual http error code:
    quit(response.status[0..2])
  
  # return the parsed body:
  result = parseJson(response.body)
