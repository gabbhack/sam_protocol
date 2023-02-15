{.experimental: "caseStmtMacros".}
import std/net
import fusion/matching

import sam_protocol


proc main() =
  let socket = newSocket()
  socket.connect("127.0.0.1", Port(7656))
  socket.send(Message.hello.build())

  let answer = Answer.fromString(socket.recvLine())

  case answer:
  of HelloReply(hello: @hello):
    case hello:
    of Ok(version: @version):
      echo "SAM version: ", version

when isMainModule:
  main()
