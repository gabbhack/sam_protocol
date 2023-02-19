{.experimental: "caseStmtMacros".}
import std/[net]
import fusion/matching  # nimble install fusion

import sam_protocol


const
  SAM_HOST = "127.0.0.1"
  SAM_PORT = Port(7656)
  NICKNAME = "server"


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

    echo "Destination generating..."
    controlSocket.send(Message.destGenerate.build())

    let destAnswer = Answer.fromString(controlSocket.recvLine())

    case destAnswer:
    of DestReply(dest: @dest):
        echo "My public dest: ", dest.pub

    echo "Session creating..."
    controlSocket.send(
      Message.sessionCreate(
        Stream,
        NICKNAME,
        destAnswer.dest.priv
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

    echo "Waiting client..."

    withSocket socket:
      socket.send(Message.hello.build())
      discard socket.recvLine()

      socket.send(
        Message.streamAccept(NICKNAME)
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

      # Client dest
      discard socket.recvLine()

      echo "Client connected! Waiting letter..."

      while true:
        echo "Client: ", socket.recvLine()
        stdout.write "> "
        socket.send(stdin.readLine() & '\n')

when isMainModule:
  main()
