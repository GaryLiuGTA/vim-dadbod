function! db#adapter#bigquery#auth_input() abort
  return v:false
endfunction

function! s:command_for_url(url, subcmd) abort
  let cmd = ['bq']
  let parsed = db#url#parse(a:url)
  if has_key(parsed, 'opaque')
    let host_targets = split(substitute(parsed.opaque, '/', '', 'g'), ':')

    " If the host is specified as bigquery:project:dataset, then parse
    " the optional (project, dataset) to supply them to the CLI.
    if len(host_targets) == 2
      call add(cmd, '--project_id=' . host_targets[0])
      call add(cmd, '--dataset_id=' . host_targets[1])
    elseif len(host_targets) == 1
      call add(cmd, '--project_id=' . host_targets[0])
    endif
  endif
  " let available_query_flags = [
  "       \ "use_legacy_sql",
  "       \ "allow_large_results",
  "       \ "append_table",
  "       \ "batch",
  "       \ "clustering_fields",
  "       \ "continuous",
  "       \ "connection_property",
  "       \ "destination_kms_key",
  "       \ "destination_schema",
  "       \ "destination_table",
  "       \ "dry-run",
  "       \ "external-table-definition",
  "       \ "flatten_results",
  "       \ "label",
  "       \ "max_rows",
  "       \ "max_bytes_billed",
  "       \ "max_statement_results",
  "       \ "max_completion_ratio",
  "       \ "parameter",
  "       \ "range_partitioning",
  "       \ "replace",
  "       \ "require_cache",
  "       \ "require_partition_filter",
  "       \ "reservation_id",
  "       \ "rpc",
  "       \ "schedule",
  "       \ "schema_update_option",
  "       \ "stat_row",
  "       \ "target_database",
  "       \ "time_partitioning_expiration",
  "       \ "time_partitioning_field",
  "       \ "time_partitioning_type",
  "       \ "udf_resource",
  "       \ "use_cache",
  "       \ "job_timeout_ms"
  "       \ ]
  let query_flags = []
  echo g:db_adapter_bigquery_query_flags
  for [k, v] in items(parsed.params)
    let op = '--'.k.'='.v
    if index(g:db_adapter_bigquery_query_flags, k) >= 0
      echo k
      call add(query_flags, op)
    else
      call add(cmd, op)
    endif
  endfor
  let final = cmd + [a:subcmd]
  if a:subcmd == "query" && len(query_flags) >= 0
    for flag in query_flags
      call add(final, flag)
    endfor
  endif
  echo final
  return final
  " return cmd + [a:subcmd]
endfunction

function! db#adapter#bigquery#filter(url) abort
  return s:command_for_url(a:url, 'query')
endfunction

function! db#adapter#bigquery#interactive(url) abort
  return s:command_for_url(a:url, 'shell')
endfunction
