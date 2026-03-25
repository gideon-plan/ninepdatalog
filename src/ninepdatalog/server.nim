## server.nim -- 9P server for datalog file tree.
{.experimental: "strict_funcs".}
import basis/code/choice, fs_layout, fact_fs, query_fs
type
  DatalogServer* = object
    root*: string
    list_fn*: ListFactsFn
    assert_fn*: AssertFn
    eval_fn*: EvalQueryFn
    query_state*: QueryState
    ops*: int
proc new_server*(root: string, list_fn: ListFactsFn, assert_fn: AssertFn,
                 eval_fn: EvalQueryFn): DatalogServer =
  DatalogServer(root: root, list_fn: list_fn, assert_fn: assert_fn, eval_fn: eval_fn)
proc handle_read*(s: var DatalogServer, path: string): Choice[string] =
  inc s.ops
  if path == result_path(s.root):
    return good(read_result(s.query_state))
  let parsed = parse_fact_path(s.root, path)
  if parsed.valid: return read_fact(s.list_fn, parsed.predicate)
  bad[string]("ninepdatalog", "invalid path: " & path)
proc handle_write*(s: var DatalogServer, path: string, data: string): Choice[bool] =
  inc s.ops
  if path == query_path(s.root):
    return submit_query(s.query_state, data, s.eval_fn)
  let parsed = parse_fact_path(s.root, path)
  if parsed.valid: return write_fact(s.assert_fn, parsed.predicate, data)
  bad[bool]("ninepdatalog", "invalid path: " & path)
