import $FS from "node:fs/promises"
import $Path from "node:path"
import * as Glob from "fast-glob"

Template =

  # TODO migrate into Joy
  expand: ( template, context ) ->
    parameters = Object.keys context
    f = new Function "{#{ parameters }}", "return `#{ template }`"
    f context

Path =

  glob: ( patterns, options ) ->
    Glob.glob patterns, options

  parse: (path) ->
    {dir, name, ext} = $Path.parse path
    path: path
    directory: dir
    name: name
    extension: ext

  source: ({ root, source }) ->
    $Path.join ( root ? "." ), source.path
  
  expand: ( target, context ) ->
    do ({ source, extension } = context ) ->
      build = Template.expand target, context
      directory = $Path.join build, source.directory
      await $FS.mkdir directory, recursive: true
      name = source.name + ( extension ? source.extension )
      $Path.join directory, name

export { Template, Path }