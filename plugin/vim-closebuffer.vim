" HandleBufferClose
" I feel it pretty annoying that everytime I do :bd, that action doesn't only
" destroys my current active buffer but it also ruins my split windows
"
" the fix is actually pretty straighforward, by knowing that split will be
" untouched if the buffer we're attempting to close is not the active one, so
" we'll good simply by doing :b# (or :bn, :bp, and any other buffer switch
" command) followed by :bd# to delete that previously active buffer
"
"
" And this plugin simply does that, move it to another buffer and close that
" buffer (previously active one)
"
" Beside that, I also implement convenient check for unsaved modified buffers 
"

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

" Helper function to switch to the previous buffer and close the current one
function! SwitchAndCloseBuffer(force)
  " Switch to the previous buffer
  execute 'bprevious'
  if a:force
    " Force close the previously active buffer
    execute 'bdelete!#'
  else
    " Close the previously active buffer
    execute 'bdelete#'
  endif
endfunction

" Handle buffer close with options to save, discard, or cancel
function! HandleCloseBuffer()
  " Define constants for user choices
  let s:SAVE_OPTION = 'y'
  let s:DONT_SAVE_OPTION = 'n'
  let s:CANCEL_OPTION = 'c'

  " Get the list of buffers and the current buffer
  let buffers = filter(getbufinfo(), 'v:val.listed')
  let current_buf = bufnr('%')
  let current_buf_name = bufname(current_buf) != '' ? bufname(current_buf) : '[Unnamed]'

  " Check if the current buffer is modified
  if IsBufferModified(current_buf)
    echo "Current buffer has unsaved changes. Do you want to save it? [y]es, [n]o, [C]ancel: "
    let choice = nr2char(getchar())

    if tolower(choice) == s:SAVE_OPTION
      " Save the buffer
      execute 'write'  
      if len(buffers) > 1
        call SwitchAndCloseBuffer(0)
      else
        call CloseBuffer(0)
      endif
      echohl InfoMsg | echom current_buf_name . " saved and closed." | echohl None

    elseif tolower(choice) == s:DONT_SAVE_OPTION
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
