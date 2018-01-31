# Userify shim
# Copyright (c) 2018 Userify Corp
# import httpclient
import os
import osproc
import md5
import random
import times
import nativesockets # hostname
import distros
import strutils
import tables
import parsecfg
import json
import post_data_to_server

# python-style string concatenation
template `+` (x, y: string): string = x & y

type
  User = object
    username: string
    perm: string
    name: string
    preferred_shell: string
    ssh_public_key: string
  Creds = tuple[api_id, api_key: string]
  Server = tuple[hostname, configure_path: string]
  Config = object
    server: Server
    creds: Creds

var config: Config
config.creds = ("","")
config.server = ("","")

proc readConfig(): int {.discardable.} =
  let config_dict = loadConfig("/opt/userify/creds.py")
  config.creds = (config_dict.getSectionValue("", "api_id"), config_dict.getSectionValue("", "api_key"))
  let creds_dict = loadConfig("/opt/userify/userify_config.py")
  config.server = (creds_dict.getSectionValue("", "shim_host"), "/api/userify/configure")

proc parseJson(bodyJS: JsonNode): seq[User] =
  var usersJS = bodyJS["users"]
  var users: seq[User]
  users = @[]
  for username, userJS in usersJS.fields:
    var user: User
    user.username = username
    user.perm = $userJs["perm"]
    user.name = $userJs["name"]
    user.preferred_shell = $userJs["preferred_shell"]
    user.ssh_public_key = $userJs["ssh_public_key"]
    users.add user
  return users

when isMainModule:
  var t = cpuTime()
  echo "[shim] Version: " & " | Start: " & $t & " | Processors: " & $osproc.countProcessors()
  readConfig()
  let bodyJS = postDataToServer(config, "{\"data\": \"{}\"}")
  let users = parseJson(bodyJS)
  echo $users
echo $bodyJS.fields
