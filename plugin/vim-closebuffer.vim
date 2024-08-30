" Check if a buffer is modified
function! IsBufferModified(buf)
  return getbufvar(a:buf, '&modified') == 1
endfunction

" Helper function to close the current buffer
function! CloseBuffer(force)
  if a:force
    execute 'bdelete!'
  else
    execute 'bdelete'
  endif
endfunction

" Helper function to switch to the previous active buffer and close the current one
function! SwitchAndCloseBuffer(force)
  " Check if a previous active buffer exists
  if bufnr('#') > 0
    " Switch to the previous active buffer
    execute 'buffer#'
  else
    " Fall back to the previous listed buffer if no previous active buffer
    execute 'bprevious'
  endif
  
  " Close the current buffer
  if a:force
    execute 'bdelete!'
  else
    execute 'bdelete'
  endif
endfunction

" Handle buffer close with options to save, discard, or cancel
function! HandleCloseBuffer()
  " Get the list of buffers and the current buffer
  let buffers = filter(getbufinfo(), 'v:val.listed')
  let current_buf = bufnr('%')
  let current_buf_name = bufname(current_buf) != '' ? bufname(current_buf) : '[Unnamed]'

  " Check if the current buffer is modified
  if IsBufferModified(current_buf)
    echo "Current buffer has unsaved changes. Do you want to save it? [y]es, [n]o, [C]ancel: "
    let choice = nr2char(getchar())

    if tolower(choice) == 'y'
      execute 'write'  " Save the buffer
      if len(buffers) > 1
        call SwitchAndCloseBuffer(0)
      else
        call CloseBuffer(0)
      endif
      echohl InfoMsg | echom current_buf_name . " saved and closed." | echohl None

    elseif tolower(choice) == 'n'
      if len(buffers) > 1
        call SwitchAndCloseBuffer(1)
      else
        call CloseBuffer(1)
      endif
      echohl WarningMsg | echom current_buf_name . " closed without saving." | echohl None

    else
      echohl InfoMsg | echom "Buffer close canceled." | echohl None
    endif

  else
    if len(buffers) > 1
      call SwitchAndCloseBuffer(0)
    else
      call CloseBuffer(0)
    endif
    echohl InfoMsg | echom current_buf_name . " closed." | echohl None
  endif
endfunction

" Create a Vim command to trigger the HandleBufferClose function
command! HandleCloseBuffer call HandleCloseBuffer()
