# Userify shim
# Copyright (c) 2018 Userify Corp
# import httpclient

# This is a very, very early start on porting shim.py (https://github.com/userify/shim)
# to Nim. First pursuing feature parity. Achieving feature parity and working in the same way
# will be a great proof of concept that to prove that Nim can do the job and be easier to convert
# in phase 2 to a more efficient design.
# (Note: the resultant shim couldn't be used in production, even if feature complete, because the
# python script is only 18kb, which is downloaded every 90 seconds; even compressed with upx,
# a static nim shim will be probably 50x the size)

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
#import sys_cmds 

# python-style string concatenation
template `+` (x, y: string): string = x & y

include sys_cmds 

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

proc checkIfValExistsInArr(param: string, arr: openArray[string]): int =
  for i in arr:
    if i == param:
      return 1
  return 0

proc process_users(defined_users: seq[User]): int {.discardable.} =

  for i in defined_users:

    # if the user already exists on the system and we didn't create it, skip.
    if (checkIfValExistsInArr(i.username,system_usernames()) == 1) and (checkIfValExistsInArr(i.username,current_userify_users())==0):
      echo "ERROR: Ignoring username " + $i.username + " which conflicts with an" +
                "existing non-Userify user on this system!" +
                "To allow the shim to take over this user account, please run:\n" +
                "'sudo usermod -c userify-" + $i.username + " " + $i.username + " '"
      continue
    
    # if the username doesn't exist, create it:
    if checkIfValExistsInArr(i.username, system_usernames()) == 0:
      useradd(i.name,i.username,i.preferred_shell)
      #echo i.username & " not in current system; adding user"

when isMainModule:
  var t = cpuTime()
  echo "[shim] Version: " & " | Start: " & $t & " | Processors: " & $osproc.countProcessors()
  readConfig()
  let bodyJS = postDataToServer(config, "{\"data\": \"{}\"}")
  let users = parseJson(bodyJS)
  #echo $users
  parse_passwd()
  process_users(users)
echo $bodyJS.fields
