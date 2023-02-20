import std/[
  options
]

import sam_protocol


block:
  template checkTemp(typ: typedesc) =
    var temp: typ
    doAssert temp.build == "\n"

  checkTemp(HelloString)
  checkTemp(SessionCreateString)
  checkTemp(StreamConnectString)
  checkTemp(StreamAcceptString)
  checkTemp(StreamForwardString)
  checkTemp(SessionAddString)
  checkTemp(SessionRemoveString)
  checkTemp(NamingLookupString)
  checkTemp(DestGenerateString)
  checkTemp(PingString)
  checkTemp(PongString)

doAssert $StyleType.Stream == "STREAM"
doAssert $StyleType.Datagram == "DATAGRAM"
doAssert $StyleType.Raw == "RAW"
doAssert $StyleType.Primary == "PRIMARY"
doAssert $StyleType.Master == "MASTER"

doAssert Message.hello.string == "HELLO VERSION"
doAssert Message.hello.withMinVersion("1.0").string == "HELLO VERSION MIN=1.0"
doAssert Message.hello.withMaxVersion("1.0").string == "HELLO VERSION MAX=1.0"
doAssert Message.hello.withUser("user").string == "HELLO VERSION USER=user"
doAssert Message.hello.withPassword("password").string == "HELLO VERSION PASSWORD=password"

doAssert Message.sessionCreate(Stream, "user", "xxx").string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx"
doAssert Message.sessionCreate(Stream, "user", "xxx").withSignatureType(DSA_SHA1).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx SIGNATURE_TYPE=DSA_SHA1"
doAssert Message.sessionCreate(Stream, "user", "xxx").withPort(1234).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx PORT=1234"
doAssert Message.sessionCreate(Stream, "user", "xxx").withHost("host").string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx HOST=host"
doAssert Message.sessionCreate(Stream, "user", "xxx").withFromPort(1234).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx FROM_PORT=1234"
doAssert Message.sessionCreate(Stream, "user", "xxx").withToPort(1234).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx TO_PORT=1234"
doAssert Message.sessionCreate(Stream, "user", "xxx").withProtocol(1234).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx PROTOCOL=1234"
doAssert Message.sessionCreate(Stream, "user", "xxx").withHeader(true).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx HEADER=true"
doAssert Message.sessionCreate(Stream, "user", "xxx").withInboundLength(2).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx inbound.length=2"
doAssert Message.sessionCreate(Stream, "user", "xxx").withOutboundLength(2).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx outbound.length=2"
doAssert Message.sessionCreate(Stream, "user", "xxx").withInboundQuantity(2).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx inbound.quantity=2"
doAssert Message.sessionCreate(Stream, "user", "xxx").withOutboundQuantity(2).string == "SESSION CREATE STYLE=STREAM ID=user DESTINATION=xxx outbound.quantity=2"

doAssert Message.streamConnect("user", "xxx").string == "STREAM CONNECT ID=user DESTINATION=xxx"
doAssert Message.streamConnect("user", "xxx").withSilent(true).string == "STREAM CONNECT ID=user DESTINATION=xxx SILENT=true"
doAssert Message.streamConnect("user", "xxx").withFromPort(1234).string == "STREAM CONNECT ID=user DESTINATION=xxx FROM_PORT=1234"
doAssert Message.streamConnect("user", "xxx").withToPort(1234).string == "STREAM CONNECT ID=user DESTINATION=xxx TO_PORT=1234"

doAssert Message.streamAccept("user").string == "STREAM ACCEPT ID=user"
doAssert Message.streamAccept("user").withSilent(true).string == "STREAM ACCEPT ID=user SILENT=true"

doAssert Message.streamForward("user", 1234).string == "STREAM FORWARD ID=user PORT=1234"
doAssert Message.streamForward("user", 1234).withHost("host").string == "STREAM FORWARD ID=user PORT=1234 HOST=host"
doAssert Message.streamForward("user", 1234).withSilent(true).string == "STREAM FORWARD ID=user PORT=1234 SILENT=true"
doAssert Message.streamForward("user", 1234).withSSL(true).string == "STREAM FORWARD ID=user PORT=1234 SSL=true"

doAssert Message.sessionAdd(Stream, "user").string == "SESSION ADD STYLE=STREAM ID=user"
doAssert Message.sessionAdd(Stream, "user").withPort(1234).string == "SESSION ADD STYLE=STREAM ID=user PORT=1234"
doAssert Message.sessionAdd(Stream, "user").withHost("host").string == "SESSION ADD STYLE=STREAM ID=user HOST=host"
doAssert Message.sessionAdd(Stream, "user").withFromPort(1234).string == "SESSION ADD STYLE=STREAM ID=user FROM_PORT=1234"
doAssert Message.sessionAdd(Stream, "user").withToPort(1234).string == "SESSION ADD STYLE=STREAM ID=user TO_PORT=1234"
doAssert Message.sessionAdd(Stream, "user").withProtocol(1234).string == "SESSION ADD STYLE=STREAM ID=user PROTOCOL=1234"
doAssert Message.sessionAdd(Stream, "user").withListenPort(1234).string == "SESSION ADD STYLE=STREAM ID=user LISTEN_PORT=1234"
doAssert Message.sessionAdd(Stream, "user").withListenProtocol(1234).string == "SESSION ADD STYLE=STREAM ID=user LISTEN_PROTOCOL=1234"
doAssert Message.sessionAdd(Stream, "user").withHeader(true).string == "SESSION ADD STYLE=STREAM ID=user HEADER=true"

doAssert Message.sessionRemove("user").string == "SESSION REMOVE ID=user"

doAssert Message.namingLookup("reg.i2p").string == "NAMING LOOKUP NAME=reg.i2p"

doAssert Message.destGenerate.string == "DEST GENERATE"
doAssert Message.destGenerate.withSignatureType(DSA_SHA1).string == "DEST GENERATE SIGNATURE_TYPE=DSA_SHA1"

doAssert Message.ping.string == "PING"
doAssert Message.ping.withText("123").string == "PING 123"
doAssert Message.pong.string == "PONG"
doAssert Message.pong.withText("123").string == "PONG 123"

block:
  let answer = Answer.fromString("HELLO REPLY RESULT=OK VERSION=3.1")
  doAssert answer.kind == HelloReply
  doAssert answer.hello.kind == Ok
  doAssert answer.hello.version == "3.1"

block:
  let answer = Answer.fromString("HELLO REPLY RESULT=NOVERSION")
  doAssert answer.kind == HelloReply
  doAssert answer.hello.kind == Noversion

block:
  let answer = Answer.fromString("HELLO REPLY RESULT=I2P_ERROR MESSAGE=\"BAD\"")
  doAssert answer.kind == HelloReply
  doAssert answer.hello.kind == I2PError
  doAssert answer.hello.message == "BAD"

block:
  let answer = Answer.fromString("SESSION STATUS RESULT=OK DESTINATION=KEK")
  doAssert answer.kind == SessionStatus
  doAssert answer.session.kind == Ok
  doAssert answer.session.destination == "KEK"

block:
  let answer = Answer.fromString("SESSION STATUS RESULT=DUPLICATED_ID")
  doAssert answer.kind == SessionStatus
  doAssert answer.session.kind == DuplicatedId

block:
  let answer = Answer.fromString("SESSION STATUS RESULT=DUPLICATED_DEST")
  doAssert answer.kind == SessionStatus
  doAssert answer.session.kind == DuplicatedDest

block:
  let answer = Answer.fromString("SESSION STATUS RESULT=INVALID_KEY")
  doAssert answer.kind == SessionStatus
  doAssert answer.session.kind == InvalidKey

block:
  let answer = Answer.fromString("SESSION STATUS RESULT=I2P_ERROR MESSAGE=\"BAD\"")
  doAssert answer.kind == SessionStatus
  doAssert answer.session.kind == I2PError
  doAssert answer.session.message == "BAD"

block:
  let answer = Answer.fromString("DATAGRAM RECEIVED DESTINATION=xxx SIZE=100")
  doAssert answer.kind == DatagramReceived
  doAssert answer.datagram.destination == "xxx"
  doAssert answer.datagram.size == 100
  doAssert answer.datagram.fromPort == none int
  doAssert answer.datagram.toPort == none int

block:
  let answer = Answer.fromString("DATAGRAM RECEIVED DESTINATION=xxx SIZE=100 FROM_PORT=123 TO_PORT=123")
  doAssert answer.kind == DatagramReceived
  doAssert answer.datagram.destination == "xxx"
  doAssert answer.datagram.size == 100
  doAssert answer.datagram.fromPort == some 123
  doAssert answer.datagram.toPort == some 123

block:
  let answer = Answer.fromString("DATAGRAM RECEIVED DESTINATION=xxx SIZE=100")
  doAssert answer.kind == DatagramReceived
  doAssert answer.datagram.destination == "xxx"
  doAssert answer.datagram.size == 100
  doAssert answer.datagram.fromPort == none int
  doAssert answer.datagram.toPort == none int

block:
  let answer = Answer.fromString("RAW RECEIVED SIZE=100")
  doAssert answer.kind == RawReceived
  doAssert answer.raw.size == 100
  doAssert answer.raw.fromPort == none int
  doAssert answer.raw.toPort == none int
  doAssert answer.raw.protocol == none int

block:
  let answer = Answer.fromString("RAW RECEIVED SIZE=100 FROM_PORT=123 TO_PORT=123 PROTOCOL=123")
  doAssert answer.kind == RawReceived
  doAssert answer.raw.size == 100
  doAssert answer.raw.fromPort == some 123
  doAssert answer.raw.toPort == some 123
  doAssert answer.raw.protocol == some 123

block:
  let answer = Answer.fromString("NAMING REPLY RESULT=INVALID_KEY NAME=identiguy1.i2p")
  doAssert answer.kind == NamingReply
  doAssert answer.naming.kind == InvalidKey
  doAssert answer.naming.name == "identiguy1.i2p"

block:
  let answer = Answer.fromString("NAMING REPLY RESULT=OK NAME=identiguy.i2p VALUE=XXX")
  doAssert answer.kind == NamingReply
  doAssert answer.naming.kind == Ok
  doAssert answer.naming.name == "identiguy.i2p"
  doAssert answer.naming.value == "XXX"

block:
  let answer = Answer.fromString("NAMING REPLY RESULT=KEY_NOT_FOUND NAME=identiguy.i2p")
  doAssert answer.kind == NamingReply
  doAssert answer.naming.kind == KeyNotFound
  doAssert answer.naming.name == "identiguy.i2p"

block:
  let answer = Answer.fromString("NAMING REPLY RESULT=I2P_ERROR MESSAGE=\"BAD\" NAME=identiguy.i2p")
  doAssert answer.kind == NamingReply
  doAssert answer.naming.kind == I2PError
  doAssert answer.naming.message == "BAD"
  doAssert answer.naming.name == "identiguy.i2p"

block:
  let answer = Answer.fromString("DEST REPLY PUB=XXX PRIV=YYY")
  doAssert answer.kind == DestReply
  doAssert answer.dest.pub == "XXX"
  doAssert answer.dest.priv == "YYY"

block:
  let answer = Answer.fromString("DEST REPLY PUB=XX=X PRIV=YY=Y")
  doAssert answer.kind == DestReply
  doAssert answer.dest.pub == "XX=X"
  doAssert answer.dest.priv == "YY=Y"

block:
  let answer = Answer.fromString("PONG")
  doAssert answer.kind == Pong
  doAssert answer.pong.text == none string

block:
  let answer = Answer.fromString("PONG TEST")
  doAssert answer.kind == Pong
  doAssert answer.pong.text == some "TEST"

block:
  let answer = Answer.fromString("PING")
  doAssert answer.kind == Ping
  doAssert answer.ping.text == none string

block:
  let answer = Answer.fromString("PING TEST")
  doAssert answer.kind == Ping
  doAssert answer.ping.text == some "TEST"

block:
  let answer = Answer.fromString("STREAM STATUS RESULT=OK")
  doAssert answer.kind == StreamStatus
  doAssert answer.stream.kind == Ok

block:
  let answer = Answer.fromString("STREAM STATUS RESULT=I2P_ERROR MESSAGE=\"BAD\"")
  doAssert answer.kind == StreamStatus
  doAssert answer.stream.kind == I2PError
  doAssert answer.stream.message == "BAD"
