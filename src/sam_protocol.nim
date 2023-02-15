import std/strformat

type
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

  Message* = object

  HelloString* = distinct string
  SessionCreateString* = distinct string
  StreamConnectString* = distinct string
  StreamAcceptString* = distinct string
  StreamForwardString* = distinct string

  BuilderStringTypes* =
    HelloString |
    SessionCreateString |
    StreamConnectString |
    StreamAcceptString |
    StreamForwardString


{.push inline.}

template tempString[T](startValue: string): var T =
  var temp = startValue
  T(temp)

func build*(str: var BuilderStringTypes): lent string =
  ## Test foo bar kek
  string(str).add '\n'
  string(str)


# General
func withPort*[T: SessionCreateString | StreamForwardString](str: var T, port: int): var T =
  string(str).add fmt" PORT={port}"
  str

func withHost*[T: SessionCreateString | StreamForwardString](str: var T, host: sink string): var T =
  string(str).add fmt" HOST={host}"
  str

func withFromPort*[T: SessionCreateString | StreamConnectString](str: var T, fromPort = 0): var T =
  string(str).add fmt" FROM_PORT={fromPort}"
  str

func withToPort*[T: SessionCreateString | StreamConnectString](str: var T, toPort = 0): var T=
  string(str).add fmt" TO_PORT={toPort}"
  str

func withSilent*[T: StreamAcceptString | StreamConnectString | StreamForwardString](str: var T, silent = false): var T =
  string(str).add fmt" SILENT={silent}"
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

func withSignatureType*(str: var SessionCreateString, signatureType: SignatureType = DSA_SHA1): var SessionCreateString =
  ## SAM 3.1 or higher only, for DESTINATION=TRANSIENT only, default DSA_SHA1
  string(str).add fmt" SIGNATURE_TYPE={signatureType}"
  str

func withProtocol*(str: var SessionCreateString, protocol = 18): var SessionCreateString =
  ## SAM 3.2 or higher only, for STYLE=RAW only, default 18
  string(str).add fmt" PROTOCOL={protocol}"
  str

func withHeader*(str: var SessionCreateString, header = false): var SessionCreateString =
  ## SAM 3.2 or higher only, for STYLE=RAW only, default false
  string(str).add fmt" HEADER={header}"
  str

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


# 
{.pop.}
