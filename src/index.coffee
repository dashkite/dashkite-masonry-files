import FS from "node:fs/promises"
import * as It from "@dashkite/joy/iterable"
import { Template, Path } from "./helpers"

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
  It.resolve It.tap ( context ) ->
    context.extension = Template.expand extension, context

copy = ( target ) ->
  It.resolve It.tap ( context ) ->
    FS.copyFile ( Path.source context ),
      ( await Path.expand target, context )

# TODO separate into a flow: target, write, store-hash
# store-hash is distinct from the File.store / Hash.store
write = ( target ) ->
  It.resolve It.tap ( context ) ->
    do ({ path } = {}) ->
      path = await Path.expand target, context
      FS.writeFile path, context.output

export default { glob, extension, copy, write }
export { glob, extension, copy, write }