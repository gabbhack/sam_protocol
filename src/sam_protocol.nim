import std/strformat

type
  StyleType* = enum
    Stream = "STREAM"
    Datagram = "DATAGRAM"
    Raw = "RAW"

  SignatureType* = enum
    DSA_SHA1 = "DSA-SHA1"
    ## Legacy Router Identities and Destinations
    ECDSA_SHA256_P256 = "ECDSA_SHA256_P256"
    ## Recent Destinations
    ECDSA_SHA384_P384 = "ECDSA_SHA384_P384"
    ## Rarely used for Destinations
    ECDSA_SHA512_P521 = "ECDSA_SHA512_P521"
    ## Rarely used for Destinations
    RSA_SHA256_2048 = "RSA_SHA256_2048"
    ## Offline signing, never used for Router Identities or Destinations
    RSA_SHA384_3072 = "RSA_SHA384_3072"
    ## Offline signing, never used for Router Identities or Destinations
    RSA_SHA512_4096 = "RSA_SHA512_4096"
    ## Offline signing, never used for Router Identities or Destinations
    EdDSA_SHA512_Ed25519 = "EdDSA_SHA512_Ed25519"
    ## Recent Router Identities and Destinations
    EdDSA_SHA512_Ed25519ph = "EdDSA_SHA512_Ed25519ph"
    ## Offline signing, never used for Router Identities or Destinations
    RedDSA_SHA512_Ed25519 = "RedDSA_SHA512_Ed25519"
    ## For Destinations and encrypted leasesets only, never used for Router Identities

  Message* = object

  HelloString* = distinct string

  BuilderStringTypes* = HelloString


template tempString[T](startValue: string): var T =
  var temp = startValue
  T(temp)

func build*(str: var BuilderStringTypes): lent string =
  string(str).add '\n'
  string(str)

# HELLO
template hello*(selfTy: typedesc[Message]): var HelloString =
  ## Returns distinct string with "HELLO VERSION" as the start value
  ## 
  ## Use `with*` methods to add more data and `build` to get the final string
  tempString[HelloString]("HELLO VERSION")

func withMinVersion*(str: var HelloString, minVersion: sink string): var HelloString =
  string(str).add fmt" MIN={minVersion}"
  str

func withMaxVersion*(str: var HelloString, maxVersion: sink string): var HelloString =
  string(str).add fmt" MAX={maxVersion}"
  str

func withUser*(str: var HelloString, user: sink string): var HelloString =
  string(str).add fmt" USER={user}"
  str

func withPassword*(str: var HelloString, password: sink string): var HelloString =
  string(str).add fmt" PASSWORD={password}"
  str
