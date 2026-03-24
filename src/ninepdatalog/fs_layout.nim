## fs_layout.nim -- File tree schema for datalog.
{.experimental: "strict_funcs".}
import std/strutils
proc predicate_dir*(root, predicate: string): string = root & "/db/" & predicate
proc fact_path*(root, predicate: string, id: int): string = root & "/db/" & predicate & "/" & $id
proc query_path*(root: string): string = root & "/query"
proc result_path*(root: string): string = root & "/query/result"
proc parse_fact_path*(root, path: string): tuple[predicate: string, id: int, valid: bool] =
  if not path.startsWith(root & "/db/"): return (predicate: "", id: 0, valid: false)
  let rest = path[root.len + 4 ..< path.len]
  let parts = rest.split("/")
  if parts.len == 2:
    try: return (predicate: parts[0], id: parseInt(parts[1]), valid: true)
    except ValueError: return (predicate: parts[0], id: 0, valid: false)
  elif parts.len == 1:
    return (predicate: parts[0], id: -1, valid: true)  # directory listing
  (predicate: "", id: 0, valid: false)
