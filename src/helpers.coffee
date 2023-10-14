import $FS from "node:fs/promises"
import $Path from "node:path"
import EventEmitter from "node:events"
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

Event =
  normalize: ( event ) ->
    switch event
      when "unlink" then name: "rm", type: "file"
      when "addDir" then name: "add", type: "directory"
      when "unlinkDir" then name: "rm", type: "directory"
      else name: event, type: "file"

  # transform event arguments
  # allows us to go from binary to unary handler
  map: ( emitter, events ) ->
    result = new EventEmitter
    for name, handler of events
      emitter.on name, ( args... ) ->
        result.emit name, handler args...
    result

export { Template, Path, Event }