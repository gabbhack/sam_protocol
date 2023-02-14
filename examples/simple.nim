# TODO
import std/net

proc main() =
  let socket = newSocket()
  socket.connect("127.0.0.1", Port(7656))

  while true:
    write stdout, "> "
    let line = stdin.readLine()
    socket.send(line & '\n')
    echo socket.recvLine()

when isMainModule:
  main()
