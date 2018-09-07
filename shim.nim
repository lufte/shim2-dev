# Userify shim
# Copyright (c) 2018 Userify Corp

import times, strutils, random, os

let lineSpacer = "\n******************************"
let shimVersion = "04012016-1"

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
  echo(lineSpacer)
  echo("[shim] $1 start: $2" % [shimVersion, $(times.now())])
  let startTime = times.cpuTime()
  var timeToWait = 0
  try:
    timeToWait = main()
  except:
    echo(lineSpacer)
    echo("Error: ", getCurrentExceptionMsg())
    echo(lineSpacer)
    timeToWait = toInt(30.0 + 60.0 * rand(1.0))
  let elapsed = times.cpuTime() - startTime
  if elapsed < timeToWait:
    echo("[shim] sleeping: ", timeToWait - elapsed)
    sleep(1000 * (timeToWait - elapsed))
