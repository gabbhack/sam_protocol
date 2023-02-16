{.experimental: "caseStmtMacros".}
import std/net
import fusion/matching

import sam_protocol


proc main() =
  let socket = newSocket()
  socket.connect("127.0.0.1", Port(7656))
  socket.send(Message.hello.build())

  let helloAnswer = Answer.fromString(socket.recvLine())

  case helloAnswer:
  of HelloReply(hello: @hello):
    case hello:
    of Ok(version: @version):
      echo "SAM version: ", version
  
  socket.send(Message.sessionCreate(Stream, "test", TRANSIENT_DESTINATION).build())

  let sessionCreateAnswer = Answer.fromString(socket.recvLine())

  case sessionCreateAnswer:
  of SessionStatus(session: @session):
    case session:
    of Ok(destination: @destination):
      echo "Destination: " & destination

when isMainModule:
  main()
