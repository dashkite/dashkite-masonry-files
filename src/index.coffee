import FS from "node:fs/promises"
import * as Fn from "@dashkite/joy/function"
import { Template, Path } from "./helpers"

assign = ( key, f ) -> 
  Fn.tee ( context ) -> context[ key ] = await f context

glob = ( targets ) -> ->
  for target, builds of targets
    for build in builds
      root = build.root ? "."
      build.preset ?= target
      for path in await Path.glob build.glob, cwd: root
        yield {
          root
          source: Path.parse path
          build: { build..., target }
        }

extension = ( extension ) ->
  assign "extension", ( context ) ->
    Template.expand extension, context

copy = ( target ) ->
  Fn.tee ( context ) ->
    FS.copyFile ( Path.source context ),
      ( await Path.expand target, context )

write = ( target ) ->
  Fn.tee ( context ) ->
    do ({ path } = {}) ->
      path = await Path.expand target, context
      FS.writeFile path, context.output

rm = ( target ) ->
  Fn.tee ( context ) ->
    do ({ path } = {}) ->
      path = await Path.expand target, context
      FS.rm path, recursive: true

export default { glob, extension, copy, write, rm }
export { glob, extension, copy, write, rm }