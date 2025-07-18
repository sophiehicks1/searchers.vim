function! s:OpenUrl(url)
  if executable('vimb')
    call system("vimb " . a:url . " &")
  elseif executable('firefox')
    call system("firefox -new-tab " . a:url . " &")
  else
    call system("open " . a:url)
  endif
endfunction

function! s:SearchOperator(prefix, suffix, type)
  let saved_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let url = shellescape(a:prefix . @@ . a:suffix)
  call s:OpenUrl(url)
  let @@ = saved_register
  redraw!
endfunction

function! s:MakeSearchOperator(search)
  execute "function! s:" . a:search.name . "Operator(type) \n call s:SearchOperator('" .
        \ a:search.prefix . "', '" .
        \ (has_key(a:search, 'suffix') ? a:search.suffix : ''). "', a:type) \n endfunction"
endfunction

function! searchers#make_binding(search)
  call s:MakeSearchOperator(a:search)
  execute "nnoremap " . a:search.binding . " :set operatorfunc=<SID>" .
        \ a:search.name . "Operator<cr>g@"
  execute "vnoremap " . a:search.binding . " :<c-u>call <SID>" . a:search.name
        \ . "Operator(visualmode())<cr>"
endfunction
