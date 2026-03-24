## fact_fs.nim -- Read/write facts as files.
{.experimental: "strict_funcs".}
import std/strutils
import lattice
type
  QueryFn* = proc(predicate: string, args: seq[string]): Result[seq[seq[string]], BridgeError] {.raises: [].}
  AssertFn* = proc(predicate: string, args: seq[string]): Result[void, BridgeError] {.raises: [].}
  ListFactsFn* = proc(predicate: string): Result[seq[string], BridgeError] {.raises: [].}
proc read_fact*(list_fn: ListFactsFn, predicate: string): Result[string, BridgeError] =
  let facts = list_fn(predicate)
  if facts.is_bad: return Result[string, BridgeError].bad(facts.err)
  Result[string, BridgeError].good(facts.val.join("\n"))
proc write_fact*(assert_fn: AssertFn, predicate: string,
                 data: string): Result[void, BridgeError] =
  let args = data.strip().split(",")
  var trimmed: seq[string]
  for a in args: trimmed.add(a.strip())
  assert_fn(predicate, trimmed)
