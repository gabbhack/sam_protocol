{.experimental: "caseStmtMacros".}
import std/net
import fusion/matching

import sam_protocol


proc main() =
  let socket = newSocket()
  socket.connect("127.0.0.1", Port(7656))
  socket.send(
    Message.hello
    .withMinVersion("3.1")
    .withMaxVersion("3.1")
    .build()
  )

  echo "Handshake..."

  let helloAnswer = Answer.fromString(socket.recvLine())
  doAssert helloAnswer.hello.kind == Ok

  echo "Dest generating..."
  socket.send(Message.destGenerate.build())

  let destAnswer = Answer.fromString(socket.recvLine())

  echo "Session creating..."

  socket.send(
    Message.sessionCreate(
      Stream,
      "test",
      destAnswer.dest.priv
    )
    .build()
  )

  let sessionCreateAnswer = Answer.fromString(socket.recvLine())
  doAssert sessionCreateAnswer.session.kind == Ok

  echo "Done"

when isMainModule:
  main()
