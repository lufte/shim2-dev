# Userify shim
# Copyright (c) 2018 Userify Corp

import times, strutils

let line_spacer = "\n******************************"
let shim_version = "04012016-1"

proc parsePasswd(): seq[seq[string]] =
  var passwds: seq[seq[string]] = @[]
  for line in lines("/etc/passwd"):
    var passwdFields = line.split(":")
    if len(passwdFields) == 6:
      passwdFields.add("")
    passwds.add(passwdFields)
  return passwds

proc main(): int =
  let passwds = parsePasswd()
  return 1

when isMainModule:
  echo(line_spacer)
  echo("[shim] $1 start: $2" % [shim_version, $(times.now())])
  let s = times.cpuTime()
  let timeToWait = main()
