# Package

version       = "0.1.1"
author        = "Gabben"
description   = "I2P SAM Protocol without any IO"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "examples"]

# Dependencies

requires "nim >= 1.0.0"


task docs, "Generate docs":
  rmDir "docs"
  exec "nimble doc2 --outdir:docs --project --git.url:https://github.com/gabbhack/sam_protocol --git.commit:master --index:on src/sam_protocol"

task tests, "Run tests":
  exec "nimble test"
  exec "nimble test -d:release"
  exec "nimble test -d:release -d:danger"

  when (NimMajor, NimMinor) >= (1, 2):
    exec "nimble test --gc:arc"
    exec "nimble test --gc:arc -d:release"
    exec "nimble test --gc:arc -d:release -d:danger"

  when (NimMajor, NimMinor) >= (1, 4):
    exec "nimble test --gc:arc"
    exec "nimble test --gc:arc -d:release"
    exec "nimble test --gc:arc -d:release -d:danger"
