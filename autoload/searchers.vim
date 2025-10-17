function! s:UrlEncode(str)
  let encoded = ''
  let i = 0
  while i < len(a:str)
    let char = a:str[i]
    let charcode = char2nr(char)
    " Keep unreserved characters: A-Z a-z 0-9 - _ . ~
    if (charcode >= 65 && charcode <= 90) || 
          \ (charcode >= 97 && charcode <= 122) || 
          \ (charcode >= 48 && charcode <= 57) ||
          \ char ==# '-' || char ==# '_' || char ==# '.' || char ==# '~'
      let encoded .= char
    else
      " Handle multi-byte UTF-8 characters
      let bytes = []
      if charcode < 128
        let bytes = [charcode]
      else
        " Get the actual bytes of the character
        let byte_str = iconv(char, &encoding, 'utf-8')
        for j in range(len(byte_str))
          call add(bytes, char2nr(byte_str[j]))
        endfor
      endif
      " Percent-encode each byte
      for byte in bytes
        let encoded .= printf('%%%02X', byte)
      endfor
    endif
    let i += 1
  endwhile
  return encoded
endfunction

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
  let url = shellescape(a:prefix . s:UrlEncode(@@) . a:suffix)
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
