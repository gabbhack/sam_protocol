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
