{.experimental: "caseStmtMacros".}
import std/[net]
import fusion/matching  # nimble install fusion

import sam_protocol


const
  SAM_HOST = "127.0.0.1"
  SAM_PORT = Port(7656)
  NICKNAME = "client"


template withSocket(socketName, body: untyped): untyped =
  block:
    let socketName = newSocket()
    socketName.connect(SAM_HOST, SAM_PORT)
    body
    socketName.close()


proc main() =
  withSocket controlSocket:
    controlSocket.send(
      Message.hello
      .withMinVersion("3.1")
      .withMaxVersion("3.1")
      .build()
    )

    echo "Handshake..."

    let helloAnswer = Answer.fromString(controlSocket.recvLine())
    doAssert helloAnswer.hello.kind == Ok

    echo "Session creating..."
    controlSocket.send(
      Message.sessionCreate(
        Stream,
        NICKNAME,
        TRANSIENT_DESTINATION
      )
      .build()
    )

    let sessionCreateAnswer = Answer.fromString(controlSocket.recvLine())


    case sessionCreateAnswer:
    of SessionStatus(session: @session):
      case session:
      of Ok():
        discard
      else:
        echo session
        quit(1)
    else:
      echo sessionCreateAnswer
      quit(1)

    withSocket socket:
      socket.send(Message.hello.build())
      discard socket.recvLine()

      stdout.write "Server dest: "
      let serverDest = stdin.readLine()

      echo "Connecting..."

      socket.send(
        Message.streamConnect(
          NICKNAME,
          serverDest
        )
        .build()
      )

      let answer = Answer.fromString(socket.recvLine())

      case answer:
      of StreamStatus(stream: @stream):
        case stream:
        of Ok():
          discard
        else:
          echo stream
          quit(1)
      else:
        echo answer
        quit(1)

      echo "Connected!"

      while true:
        stdout.write "> "
        socket.send(stdin.readLine() & '\n')
        echo "Server: ", socket.recvLine()


when isMainModule:
  main()
