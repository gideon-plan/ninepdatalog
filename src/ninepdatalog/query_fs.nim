## query_fs.nim -- Write query, read result.
{.experimental: "strict_funcs".}
import lattice
type
  EvalQueryFn* = proc(query_str: string): Result[string, BridgeError] {.raises: [].}
  QueryState* = object
    last_query*: string
    last_result*: string
proc submit_query*(state: var QueryState, query: string, eval_fn: EvalQueryFn): Result[void, BridgeError] =
  state.last_query = query
  let r = eval_fn(query)
  if r.is_bad: return Result[void, BridgeError].bad(r.err)
  state.last_result = r.val
  Result[void, BridgeError](ok: true)
proc read_result*(state: QueryState): string = state.last_result
