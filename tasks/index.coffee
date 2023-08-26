import * as T from "@dashkite/genie"

# Define build explicitly so that we can use genie-files
# to define the reusable build tasks

import * as M from "@dashkite/masonry"
import { coffee } from "@dashkite/masonry/coffee"

T.define "clean", M.rm "build"

T.define "build", M.start [
  M.glob "{src,test}/**/*.coffee", "."
  M.read
  M.tr coffee.node {}
  M.extension ".js"
  M.write "build/node"
]