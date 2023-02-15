import std/[
  strformat,
  options,
  parseutils,
  strutils
]

type
  ParseError* = object of CatchableError

  StyleType* = enum
    Stream = "STREAM"
    Datagram = "DATAGRAM"
    Raw = "RAW"
    Primary = "PRIMARY"
    Master = "MASTER"

  SignatureType* = enum
    DSA_SHA1
    ## Legacy Router Identities and Destinations
    ECDSA_SHA256_P256
    ## Recent Destinations
    ECDSA_SHA384_P384
    ## Rarely used for Destinations
    ECDSA_SHA512_P521
    ## Rarely used for Destinations
    RSA_SHA256_2048
    ## Offline signing, never used for Router Identities or Destinations
    RSA_SHA384_3072
    ## Offline signing, never used for Router Identities or Destinations
    RSA_SHA512_4096
    ## Offline signing, never used for Router Identities or Destinations
    EdDSA_SHA512_Ed25519
    ## Recent Router Identities and Destinations
    EdDSA_SHA512_Ed25519ph
    ## Offline signing, never used for Router Identities or Destinations
    RedDSA_SHA512_Ed25519
    ## For Destinations and encrypted leasesets only, never used for Router Identities

  ResultType* = enum
    Ok = "OK"
    ## Operation completed successfully
    Noversion = "NOVERSION"
    ## SAM bridge cannot find a suitable version
    I2PError = "I2P_ERROR"
    ## A generic I2P error (e.g. I2CP disconnection, etc.)
    DuplicatedID = "DUPLICATED_ID"
    ## The specified nickname is already in use
    DuplicatedDest = "DUPLICATED_DEST"
    ## The specified Destination is already in use
    InvalidKey = "INVALID_KEY"
    ## The specified key is not valid (bad format, etc.)
    InvalidID = "INVALID_ID"
    ## The specified nickname is not valid (bad format, etc.)
    CantReachPeer = "CANT_REACH_PEER"
    ## The peer exists, but cannot be reached
    Timeout = "TIMEOUT"
    ## Timeout while waiting for an event (e.g. peer answer)
    KeyNotFound = "KEY_NOT_FOUND"
    ## The naming system can't resolve the given name
    PeerNotFound = "PEER_NOT_FOUND"
    ## The peer cannot be found on the network

  AnswerType* = enum
    HelloReply = "HELLO REPLY"
    SessionStatus = "SESSION STATUS"
    StreamStatus = "STREAM STATUS"
    NamingReply = "NAMING REPLY"
    DestReply = "DEST REPLY"
    Ping = "PING"
    Pong = "PONG"
    DatagramReceived = "DATAGRAM RECEIVED"
    RawReceived = "RAW RECEIVED"

  HelloAnswer* = object
    case kind*: ResultType
    of Ok:
      version*: string
    of I2PError:
      message*: string
    else:
      discard

  SessionAnswer* = object
    case kind*: ResultType
    of Ok:
      destination*: string
    of I2PError:
      message*: string
    else:
      discard

  StreamAnswer* = object
    kind*: ResultType
  
  NamingAnswer* = object
    name*: string
    case kind*: ResultType
    of Ok:
      value*: string
    of I2PError:
      message*: string
    else:
      discard
  
  DestAnswer* = object
    pub*: string
    priv*: string

  PingAnswer* = object
    text: Option[string]
  
  PongAnswer* = object
    text: Option[string]

  DatagramAnswer* = object
    destination*: string
    size*: int
    fromPort*: Option[int]
    toPort*: Option[int]
    data*: seq[byte]
  
  RawAnswer* = object
    size*: int
    fromPort*: Option[int]
    toPort*: Option[int]
    protocol*: Option[int]
    data*: seq[byte]

  Answer* = object
    case kind*: AnswerType
    of HelloReply:
      hello*: HelloAnswer
    of SessionStatus:
      session*: SessionAnswer
    of StreamStatus:
      stream*: StreamAnswer
    of NamingReply:
      naming*: NamingAnswer
    of DestReply:
      dest*: DestAnswer
    of Ping:
      ping*: PingAnswer
    of Pong:
      pong*: PongAnswer
    of DatagramReceived:
      datagram*: DatagramAnswer
    of RawReceived:
      raw*: RawAnswer

  Message* = object

  HelloString* = distinct string

  SessionCreateString* = distinct string
  SessionAddString* = distinct string
  SessionRemoveString* = distinct string

  StreamConnectString* = distinct string
  StreamAcceptString* = distinct string
  StreamForwardString* = distinct string

  NamingLookupString* = distinct string

  DestGenerateString* = distinct string

  PingString* = distinct string
  PongString* = distinct string

  BuilderStringTypes* =
    HelloString |
    SessionCreateString |
    SessionAddString |
    SessionRemoveString |
    StreamConnectString |
    StreamAcceptString |
    StreamForwardString |
    NamingLookupString |
    DestGenerateString |
    PingString |
    PongString


{.push inline.}

template tempString[T](startValue: string): var T =
  var temp = startValue
  T(temp)

func build*(str: var BuilderStringTypes): lent string =
  ## Test foo bar kek
  string(str).add '\n'
  string(str)


# General
func withPort*[T: SessionCreateString | StreamForwardString | SessionAddString](str: var T, port: int): var T =
  string(str).add fmt" PORT={port}"
  str

func withHost*[T: SessionCreateString | StreamForwardString | SessionAddString](str: var T, host: sink string): var T =
  string(str).add fmt" HOST={host}"
  str

func withFromPort*[T: SessionCreateString | StreamConnectString | SessionAddString](str: var T, fromPort = 0): var T =
  string(str).add fmt" FROM_PORT={fromPort}"
  str

func withToPort*[T: SessionCreateString | StreamConnectString | SessionAddString](str: var T, toPort = 0): var T=
  string(str).add fmt" TO_PORT={toPort}"
  str

func withSilent*[T: StreamAcceptString | StreamConnectString | StreamForwardString](str: var T, silent = false): var T =
  string(str).add fmt" SILENT={silent}"
  str

func withProtocol*[T: SessionCreateString | SessionAddString](str: var T, protocol = 18): var T =
  string(str).add fmt" PROTOCOL={protocol}"
  str

func withHeader*[T: SessionCreateString | SessionAddString](str: var T, header = false): var T =
  string(str).add fmt" HEADER={header}"
  str

func withSignatureType*[T: SessionCreateString | DestGenerateString](str: var T, signatureType: SignatureType = DSA_SHA1): var T =
  string(str).add fmt" SIGNATURE_TYPE={signatureType}"
  str


# HELLO
template hello*(selfTy: typedesc[Message]): var HelloString =
  ## Returns distinct string with "HELLO VERSION" as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[HelloString]("HELLO VERSION")

func withMinVersion*(str: var HelloString, minVersion: sink string): var HelloString =
  ## Optional as of SAM 3.1, required for 3.0 and earlier
  string(str).add fmt" MIN={minVersion}"
  str

func withMaxVersion*(str: var HelloString, maxVersion: sink string): var HelloString =
  ## Optional as of SAM 3.1, required for 3.0 and earlier
  string(str).add fmt" MAX={maxVersion}"
  str

func withUser*(str: var HelloString, user: sink string): var HelloString =
  ## As of SAM 3.2, required if authentication is enabled, see below
  string(str).add fmt" USER={user}"
  str

func withPassword*(str: var HelloString, password: sink string): var HelloString =
  ## As of SAM 3.2, required if authentication is enabled, see below
  string(str).add fmt" PASSWORD={password}"
  str


# SESSION CREATE
template sessionCreate*(selfTy: typedesc[Message], style: StyleType, nickname, destination: string): var SessionCreateString =
  ## Returns distinct string with "SESSION CREATE STYLE=... ID=... DESTINATION=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[SessionCreateString]("SESSION CREATE STYLE=" & $style & " ID=" & nickname & " DESTINATION=" & destination)

func withInboundLength*(str: var SessionCreateString, inboundLength = 3): var SessionCreateString =
  ## Number of hops of an inbound tunnel. 3 by default; lower value is faster but dangerous
  string(str).add fmt" inbound.length={inboundLength}"
  str

func withOutboundLength*(str: var SessionCreateString, outboundLength = 3): var SessionCreateString =
  ## Number of hops of an outbound tunnel. 3 by default; lower value is faster but dangerous
  string(str).add fmt" outbound.length={outboundLength}"
  str

func withInboundQuantity*(str: var SessionCreateString, inboundQuantity = 5): var SessionCreateString =
  ## Number of inbound tunnels. 5 by default
  string(str).add fmt" inbound.quantity={inboundQuantity}"
  str

func withOutboundQuantity*(str: var SessionCreateString, outboundQuantity = 5): var SessionCreateString =
  ## Number of outbound tunnels. 5 by default
  string(str).add fmt" outbound.quantity={outboundQuantity}"
  str


# STREAM CONNECT
template streamConnect*(selfTy: typedesc[Message], nickname, destination: string): var StreamConnectString =
  ## This establishes a new virtual connection from the local session whose ID is $nickname to the specified peer. 
  ##
  ## Returns distinct string with "STREAM CONNECT ID=... DESTINATION=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[StreamConnectString]("STREAM CONNECT ID=" & nickname & " DESTINATION=" & destination)


# STREAM ACCEPT
template streamAccept*(selfTy: typedesc[Message], nickname: string): var StreamAcceptString =
  ## Returns distinct string with "STREAM ACCEPT ID=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[StreamAcceptString]("STREAM ACCEPT ID=" & nickname)

# STREAM FORWARD
template streamForward*(selfTy: typedesc[Message], nickname: string, port: int): var StreamForwardString =
  ## Returns distinct string with "STREAM FORWARD ID=... DESTINATION=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[StreamForwardString]("STREAM FORWARD ID=" & nickname & " PORT=" & $port)

func withSSL*(str: var StreamForwardString, ssl = false): var StreamForwardString =
  ## SAM 3.2 or higher only, default false
  string(str).add fmt" SSL={ssl}"
  str


# SESSION ADD
template sessionAdd*(selfTy: typedesc[Message], style: StyleType, nickname: string): var SessionAddString =
  ## Returns distinct string with "SESSION ADD STYLE=... ID=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[SessionAddString]("SESSION ADD STYLE=" & $style & " ID=" & nickname)

func withListenPort*(str: var SessionAddString, listenPort = 0): var SessionAddString =
  ## For inbound traffic, default is the FROM_PORT value.
  string(str).add fmt" LISTEN_PORT={listenPort}"
  str

func withListenProtocol*(str: var SessionAddString, listenProtocol = 18): var SessionAddString =
  string(str).add fmt" LISTEN_PROTOCOL={listenProtocol}"
  str


# SESSION REMOVE
template sessionRemove*(selfTy: typedesc[Message], nickname: string): var SessionRemoveString =
  ## Returns distinct string with "SESSION REMOVE ID=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[SessionRemoveString]("SESSION REMOVE ID=" & nickname)


# NAMING LOOKUP
template namingLookup*(selfTy: typedesc[Message], name: string): var NamingLookupString =
  ## Returns distinct string with "NAMING LOOKUP NAME=..." as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[NamingLookupString]("NAMING LOOKUP NAME=" & name)


# DEST GENERATE
template destGenerate*(selfTy: typedesc[Message]): var DestGenerateString =
  ## Returns distinct string with "DEST GENERATE" as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[DestGenerateString]("DEST GENERATE")


# PING/PONG
template ping*(selfTy: typedesc[Message]): var PingString =
  ## Returns distinct string with "PING" as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[PingString]("PING")

template pong*(selfTy: typedesc[Message]): var PongString =
  ## Returns distinct string with "PONG" as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[PongString]("PONG")

func withText*[T: PingString | PongString](self: var T, text: sink string): var T =
  string(self).add fmt" {text}"
  self


# Parsing
# Adopted from strutils
# https://github.com/nim-lang/Nim/blob/7fa782e3a085ff9ec79273164d7305210a738b90/lib/pure/strutils.nim#L363
template stringHasSep(s: string, index: int, sep: char): bool =
  s[index] == sep

template isWhitespace(s: string, index: int): bool =
  s[index] in Whitespace

iterator keyValueSplit(s: string, sep: char, startFrom: int): (tuple[start: int, finish: int], tuple[start: int, finish: int]) =
  ## Common code for split procs
  var last = startFrom
  const sepLen = 1

  var
    keyStartIndex = -1
    keyEndIndex = -1
    valueStartIndex = -1
    valueEndIndex = -1

  while last <= len(s):
    var first = last
    while last < len(s) and not stringHasSep(s, last, sep) and not isWhitespace(s, last):
      inc(last)

    if keyStartIndex == -1 and keyEndIndex == -1:
      keyStartIndex = first
      keyEndIndex = last-1
    elif valueStartIndex == -1 and valueEndIndex == -1:
      valueStartIndex = first
      valueEndIndex = last-1
      yield ((keyStartIndex, keyEndIndex), (valueStartIndex, valueEndIndex))
      keyStartIndex = -1
      keyEndIndex = -1
      valueStartIndex = -1
      valueEndIndex = -1
    inc(last, sepLen)

template isKeyEqualTo(pattern: static[string]): bool {.dirty.} =
  text.toOpenArray(key.start, key.finish) == pattern

template getValueString(): string {.dirty.} =
  text[value.start..value.finish]

func fromString*(selfTy: typedesc[Answer], text: sink string): Answer {.raises:[ParseError, ValueError].} =
  const
    HELLO_REPLY = "HELLO REPLY "

  if text.skip(HELLO_REPLY) != 0:
    var
      resultType: ResultType
      errorMessage: Option[string]
      version: Option[string]

    for key, value in keyValueSplit(text, '=', HELLO_REPLY.len):
      if isKeyEqualTo("RESULT"):
        resultType = parseEnum[ResultType](getValueString())
      elif isKeyEqualTo("MESSAGE"):
        errorMessage = some getValueString()
      elif isKeyEqualTo("VERSION"):
        version = some getValueString()

    return
      case resultType
      of Ok:
        Answer(kind: AnswerType.HelloReply, hello: HelloAnswer(kind: Ok, version: version.get()))
      of I2PError:
        Answer(kind: AnswerType.HelloReply, hello: HelloAnswer(kind: I2PError, message: errorMessage.get()))
      else:
        Answer(kind: AnswerType.HelloReply, hello: HelloAnswer(kind: resultType))
  else:
    raise newException(ParseError, "Unknown command: " & text)

{.pop.}
