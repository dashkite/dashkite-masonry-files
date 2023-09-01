import Path from "node:path"
import Crypto from "node:crypto"
import * as Fn from "@dashkite/joy/function"
import * as It from "@dashkite/joy/iterable"
import Zephyr from "@dashkite/zephyr"
import * as Glob from "fast-glob"

glob = ( patterns, options ) ->
  Glob.glob patterns, options

hash = ( it ) ->
  result = Crypto.createHash "sha1"
  for text from it
    result.update text
  result.digest "hex"

Hash =

    generate: Fn.tee ( context ) ->
      context.source.hash = hash [ context.input ]
    
    store: Fn.tee ( context ) ->
      Zephyr.update ".genie/hashes.yaml", ( hashes ) ->
        hashes[ context.source.path ] = context.source.hash
      
    changed: Fn.tee ( context ) ->
      { data } = await Zephyr.read ".genie/hashes.yaml"
      context.changed =
        ( data[ context.source.path ] != context.source.hash )
      
File =

  hash: It.map Hash.generate

  store: It.map Hash.store

  changed: Fn.flow [
    It.resolve It.map Fn.flow [
      Hash.generate
      Hash.changed
    ]
    It.select ( context ) -> context.changed
    It.tap Hash.store
  ]

# TODO combinator for dealing with a whole project

parse = parse = (path) ->
  {dir, name, ext} = Path.parse path
  path: path
  directory: dir
  name: name
  extension: ext

Files =

  hash: ->
    # run "git ls-files 
    #         -cmo 
    #         --exclude-standard 
    #         --deduplicate 
    #       | tr '\\n' '\\0' 
    #       | xargs -0 ls -1df 2>/dev/null 
    #       | git hash-object --stdin-paths 
    #       | git hash-object --stdin"



  targets: ( description ) ->
    ->
      root = description.root ? "."
      for target, builds of description
        for build in builds
          for path in await glob build.glob, cwd: root
            yield {
              root
              source: parse path
              build: { build..., target }
            }

export { File, Files }