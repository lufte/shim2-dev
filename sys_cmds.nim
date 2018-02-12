#import strutils
#import os
#import osproc

# python-style string concatenation
#template `+` (x, y: string): string = x & y

type
  dynStringArray = seq[string]
  App = tuple[passwd: seq[dynStringArray]]

var 
  f: File
  app: App

proc parsepasswd(): int {.discardable.} =
  app.passwd = @[]
  if open(f, "/etc/passwd"):
    for l in f.readAll().strip().split("\n"):
      var indiv: dynStringArray
      indiv = @[]
      for i in l.split(":"):
        indiv.add($i.strip())
      if len(indiv) > 4:
        if len(indiv) < 6:
          indiv = @[]
      app.passwd.add(@indiv)

proc execCmdWrapper(cmd:string, cmdArgs: varargs[string]): int {.discardable.} =
  var
    constructedCmd: string
    errC: int

  constructedCmd = cmd
  for i in items(cmdArgs):
    constructedCmd &= " " & i
  
  #hold on... do not execute for time being
  #errC = execCmd($constructedCmd)
  echo "executing cmd: " + $constructedCmd
  errC = 0
  if errC != 0:
    echo "error executing cmd " + cmd

proc fullchown(username,path: string): int {.discardable} =
  execCmdWrapper("chown", "-R", username+":"+username, path)

proc userdel(username: string, permanent: bool=false): int {.discardable.} =
  # removes user and renames homedir
  var
    removed_dir, home_dir: string

  removed_dir = "/home/deleted:" + username
  home_dir = "/home/" + username
  if not permanent:
    if dirExists(removed_dir):
      execCmdWrapper("/bin/rm", "-Rf", removed_dir)
    # try multiple pkill formats until one works
    # Debian, Ubuntu:
    execCmdWrapper("/usr/bin/pkill", "--signal", "9", "-u", username)
    # RHEL, CentOS, and Amazon Linux:
    execCmdWrapper("/usr/bin/pkill", "-9", "-u", username)
    execCmdWrapper("/usr/sbin/userdel", username)
    execCmdWrapper("/bin/mv", home_dir, removed_dir)
  else:
    execCmdWrapper("/usr/sbin/userdel", "-r", username)
  parsepasswd()

proc useradd(name,username,preferred_shell: string): int {.discardable.}  =
  var
    removed_dir, home_dir, useradd_suffix: string

  removed_dir = "/home/deleted:" + username
  home_dir = "/home/" + username

  #restore removed home directory
  if not dirExists(home_dir) and dirExists(removed_dir):
    execCmdWrapper("/bin/mv", removed_dir, home_dir)
  if dirExists(home_dir):
    useradd_suffix = ""
  else:
    useradd_suffix = "-m"
  execCmdWrapper("/usr/sbin/useradd", useradd_suffix,
                             # UsePAM no should be in /etc/ssh/sshd_config
                             "--comment", "userify-" + name,
                             "-s",  if (preferred_shell != ""): preferred_shell else: "/bin/bash",
                             "--user-group", username)
  fullchown(username,home_dir)
  parsepasswd()

proc system_usernames(): dynStringArray =
  #echo "returns all usernames in /etc/passwd"
  var userNames: dynStringArray
  userNames = @[]
  for i,users in app.passwd:
    userNames.add($users[0])
  return userNames

# TODO 
# current_userify_users only supports returning username
# not entire users depending on passed bool param
# not currently done as return value changes depending on
# passed param.
proc current_userify_users(): dynStringArray =
  #echo "get only usernames created by userify"
  var userify_users: dynStringArray
  userify_users = @[]
  for i,users in app.passwd:
    if (users[4].startswith("userify-")):
      userify_users.add($users[0])
  return userify_users