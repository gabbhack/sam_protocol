# Package

version       = "0.1.0"
author        = "Gabben"
description   = "I2P SAM Protocol without any IO"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.0.0"


task docs, "Generate docs":
  rmDir "docs"
  exec "nimble doc2 --outdir:docs --project --git.url:https://github.com/gabbhack/sam_protocol --git.commit:master --index:on src/sam_protocol"
