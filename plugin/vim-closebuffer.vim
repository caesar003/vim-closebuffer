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

" Force close the specified buffer with a message
function! ForceCloseBuffer(buffer_number, message)
  execute 'bdelete!' a:buffer_number
  echohl InfoMsg | echom a:message | echohl None
endfunction

" Helper function to switch to the previous buffer
function! SwitchBuffer()
  " Check if the alternate buffer exists
  if bufnr('#') != -1
    " Switch to the alternate buffer
    execute 'buffer#'
  else
    " Switch to the previous buffer in the buffer list
    execute 'bprevious'
  endif
endfunction

function! HandleCloseBuffer()
  " Define constants for user choices
  let s:SAVE_OPTION = 'y'
  let s:DONT_SAVE_OPTION = 'n'
  let s:CANCEL_OPTION = 'c'

  " Get the list of buffers and the current buffer
  let buffers = filter(getbufinfo(), 'v:val.listed')
  let current_buf = bufnr('%')
  let current_buf_name = bufname(current_buf) != '' ? bufname(current_buf) : '[Unnamed]'

  " Check if the current buffer is not modified
  if !IsBufferModified(current_buf)
    " Close the buffer immediately since it's not modified
    if len(buffers) > 1
      call SwitchBuffer()
      call ForceCloseBuffer('#', current_buf_name . " closed.")
      return
    endif
    call ForceCloseBuffer('%', current_buf_name . " closed.")
    return
  endif

  " Prompt the user if the buffer has unsaved changes
  echo "Current buffer has unsaved changes. Do you want to save it? [y]es, [n]o, [C]ancel: "
  let choice = nr2char(getchar())

  if tolower(choice) == s:SAVE_OPTION
    " Save the buffer
    execute 'write'
    if len(buffers) > 1
      call SwitchBuffer()
      call ForceCloseBuffer('#', current_buf_name . " saved and closed.")
      return
    endif
      call ForceCloseBuffer('%', current_buf_name . " saved and closed.")
    return
  endif

  if tolower(choice) == s:DONT_SAVE_OPTION
    if len(buffers) > 1
      call SwitchBuffer()
      call ForceCloseBuffer('#', current_buf_name . " closed without saving.")
      return
    endif
    call ForceCloseBuffer('%', current_buf_name . " closed without saving.")
    return
  endif

  " If user chooses to cancel
  echohl InfoMsg | echom "Buffer close canceled." | echohl None
endfunction

" Create a Vim command to trigger the HandleCloseBuffer function
command! HandleCloseBuffer call HandleCloseBuffer()

