## query_fs.nim -- Write query, read result.
{.experimental: "strict_funcs".}
import basis/code/choice
type
  EvalQueryFn* = proc(query_str: string): Choice[string] {.raises: [].}
  QueryState* = object
    last_query*: string
    last_result*: string
proc submit_query*(state: var QueryState, query: string, eval_fn: EvalQueryFn): Choice[bool] =
  state.last_query = query
  let r = eval_fn(query)
  if r.is_bad: return bad[bool](r.err)
  state.last_result = r.val
  good(true)
proc read_result*(state: QueryState): string = state.last_result
