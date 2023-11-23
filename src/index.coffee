import FS from "node:fs/promises"
import $Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import { Template, Path } from "./helpers"

assign = ( key, f ) -> 
  Fn.tee ( context ) -> context[ key ] = await f context

read = Fn.memoize ( path ) ->
  await FS.readFile path, "utf8"

glob = ( targets ) -> ->
  for target, builds of targets
    for build in builds
      build.root ?= "."
      build.preset ?= target
      for path in await Path.glob build.glob, cwd: build.root
        yield {
          root: build.root # backward compatibility
          source: Path.parse path
          build: { build..., target }
          module: module
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
      try
        await FS.rm path, recursive: true
      catch error
        unless error.message.startsWith "ENOENT"
          throw error

export default { glob, extension, copy, write, rm }
export { glob, extension, copy, write, rm }