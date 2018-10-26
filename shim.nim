# Userify shim
# Copyright (c) 2018 Userify Corp

import times, strutils, random, os, posix

let lineSpacer = "\n******************************"
let shimVersion = "04012016-1"

type
  InstanceMetadata = tuple[
    instanceType: string,
    hostname: string,
    amiId: string,
    mac: string,
    system: string,
    node: string,
    release: string,
    version: string,
    machine: string,
  ]

  Creds = tuple[
    apiKey: string,
    apiId: string,
    companyName: string,
    projectName: string
  ]

  UserifyConfig = tuple[
    debug: bool,
    dryRun: bool,
    shimHost: string,
    staticHost: string,
    selfSigned: bool
  ]

proc getInstanceMetadata(): InstanceMetadata =
  var md: InstanceMetadata
  var uts = posix.Utsname()
  let unameExitCode = posix.uname(uts)
  md.system = uts.sysname.join().strip(chars={'\x00'})
  md.node = uts.nodename.join().strip(chars={'\x00'})
  md.release = uts.release.join().strip(chars={'\x00'})
  md.version = uts.version.join().strip(chars={'\x00'})
  md.machine = uts.machine.join().strip(chars={'\x00'})
  return md

proc retrieveHttpsProxy(): tuple[host: string, port: int] =
  var httpsProxy = ""
  var httpsProxyPort = "443"
  let envHttpsProxy = os.getEnv("https_proxy").strip()
  if envHttpsProxy.len() > 0:
    httpsProxy = envHttpsProxy
    if httpsProxy.startsWith("http"):
      httpsProxy = httpsProxy.replace("https://")
      httpsProxy = httpsProxy.replace("http://")
      if httpsProxy.find(':') >= 0:
        var hostPort = httpsProxy.split(':', 1)
        httpsProxy = hostPort[0]
        httpsProxyPort = ""
        for character in hostPort[1]:
          if isDigit(character):
            httpsProxyPort.add(character)
  return (httpsProxy, parseInt(httpsProxyPort))

proc parsePasswd(): seq[seq[string]] =
  var passwds: seq[seq[string]] = @[]
  for line in lines("/etc/passwd"):
    var passwdFields = line.split(":")
    if len(passwdFields) == 6:
      passwdFields.add("")
    passwds.add(passwdFields)
  return passwds

proc parseUserifyConfig(): UserifyConfig =
  var config: UserifyConfig
  for line in lines("./userify_config.py"):
    let keyVal = line.split("=", 1)
    if keyVal[0] == "debug":
      if keyVal[1] == "0":
        config.debug = false
      else:
        config.debug = true
    elif keyVal[0] == "dry_run":
      if keyVal[1] == "0":
        config.dryRun = false
      else:
        config.dryRun = true
    elif keyVal[0] == "shim_host":
      config.shimHost = keyVal[1][1..^2]
    elif keyVal[0] == "static_host":
      config.staticHost = keyVal[1][1..^2]
    elif keyVal[0] == "selfSigned":
      if keyVal[1] == "0":
        config.dryRun = false
      else:
        config.dryRun = true
  return config

proc parseCreds(): Creds =
  var creds: Creds
  for line in lines("./creds.py"):
    let keyVal = line.split("=", 1)
    if keyVal[0] == "api_key":
      creds.apiKey = keyVal[1][1..^2]
    elif keyVal[0] == "api_id":
      creds.apiId = keyVal[1][1..^2]
    elif keyVal[0] == "company_name":
      creds.companyName = keyVal[1][1..^2]
    elif keyVal[0] == "project_name":
      creds.projectName = keyVal[1][1..^2]
  return creds

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
  let elapsed = toInt(times.cpuTime() - startTime)
  if elapsed < timeToWait:
    echo("[shim] sleeping: ", timeToWait - elapsed)
    sleep(1000 * (timeToWait - elapsed))
