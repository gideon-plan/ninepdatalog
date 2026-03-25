## fact_fs.nim -- Read/write facts as files.
{.experimental: "strict_funcs".}
import std/strutils

type
  BridgeError* = object of CatchableError

import basis/code/choice
type
  QueryFn* = proc(predicate: string, args: seq[string]): Choice[seq[seq[string]]] {.raises: [].}
  AssertFn* = proc(predicate: string, args: seq[string]): Choice[bool] {.raises: [].}
  ListFactsFn* = proc(predicate: string): Choice[seq[string]] {.raises: [].}
proc read_fact*(list_fn: ListFactsFn, predicate: string): Choice[string] =
  let facts = list_fn(predicate)
  if facts.is_bad: return bad[string](facts.err)
  good(facts.val.join("\n"))
proc write_fact*(assert_fn: AssertFn, predicate: string,
                 data: string): Choice[bool] =
  let args = data.strip().split(",")
  var trimmed: seq[string]
  for a in args: trimmed.add(a.strip())
  assert_fn(predicate, trimmed)
