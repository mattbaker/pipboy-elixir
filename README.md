# PipParser

This is an Elixir version of a parser for the [Fallout 4 Pipboy protocol](https://github.com/mattbaker/pipboy-explorations). It's also my attempt at learning Elixir.

It's by no means complete, but it does successfully parse messages from a binary stream, and will additionally parse messages of type 3 (data updates).

## Running it

PipParser takes input from STDIN. Below, we pipe a captured binary dump of some Pipboy traffic to PipParser.

```
$ mix run -e PipParser.run < test.bin
%PipUpdate{contents: "$General", id: 32140, type: :string}
%PipUpdate{contents: 72, id: 32156, type: :sint32}
%PipUpdate{contents: "Locations Discovered", id: 32155, type: :string}
%PipUpdate{contents: true, id: 32157, type: :bool}
%PipUpdate{contents: {[{32156, "value"}, {32155, "text"},
   {32157, "showIfZero"}], []}, id: 32154, type: :dict_update}
%PipUpdate{contents: 19, id: 32160, type: :sint32}
%PipUpdate{contents: "Locations Cleared", id: 32159, type: :string}
%PipUpdate{contents: true, id: 32161, type: :bool}
%PipUpdate{contents: {[{32160, "value"}, {32159, "text"},
   {32161, "showIfZero"}], []}, id: 32158, type: :dict_update}
%PipUpdate{contents: 24, id: 32164, type: :sint32}
%PipUpdate{contents: "Days Passed", id: 32163, type: :string}
```

## Code

### PipValues
A set of macros to provide short-hand syntax for various data types relevant to the Pipboy binary protocol (uint8, float32, etc).

### PipStream
A custom Stream that pulls from STDIN, then extracts and emits tuples representing individual messages.

### PipUpdate
Parsing functions for parsing Pipboy messages of type 3 a.k.a. data updates. Data updates are the most interesting form of data the Pipboy sends, and also the most complicated to parse.

### PipParser

Right now there's a single `run` function in PipParser that shows a pipeline streaming data from STDIN, selecting messages of type 3, parsing the data upates, and printing them.
