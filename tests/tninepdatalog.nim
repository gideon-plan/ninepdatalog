{.experimental: "strict_funcs".}
import std/unittest
import ninepdatalog
suite "fs_layout":
  test "paths":
    check predicate_dir("/dl", "parent") == "/dl/db/parent"
    check fact_path("/dl", "parent", 0) == "/dl/db/parent/0"
    check query_path("/dl") == "/dl/query"
  test "parse fact path":
    let r = parse_fact_path("/dl", "/dl/db/parent/3")
    check r.valid
    check r.predicate == "parent"
    check r.id == 3
suite "query_fs":
  test "submit and read":
    let mock_eval: EvalQueryFn = proc(q: string): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("result: " & q)
    var qs: QueryState
    let r = qs.submit_query("ancestor(X,Y)?", mock_eval)
    check r.is_good
    check read_result(qs) == "result: ancestor(X,Y)?"
suite "server":
  test "handle read and write":
    let mock_list: ListFactsFn = proc(p: string): Result[seq[string], BridgeError] {.raises: [].} =
      Result[seq[string], BridgeError].good(@["parent(a,b)"])
    let mock_assert: AssertFn = proc(p: string, a: seq[string]): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    let mock_eval: EvalQueryFn = proc(q: string): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("ok")
    var s = new_server("/dl", mock_list, mock_assert, mock_eval)
    let w = s.handle_write("/dl/query", "test?")
    check w.is_good
    let r = s.handle_read("/dl/query/result")
    check r.is_good
    check r.val == "ok"
    check s.ops == 2
