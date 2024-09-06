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
" {{{ IsBufferModified
function! IsBufferModified(buf)
  return getbufvar(a:buf, '&modified') == 1
endfunction
" }}}

" Force close the specified buffer with a message
" {{{ ForceCloseBuffer
function! ForceCloseBuffer(buffer_number, message)
  execute 'bdelete!' a:buffer_number
  echohl InfoMsg | echom a:message | echohl None
endfunction
" }}}

" Helper function to switch to the previous buffer
" {{{ SwitchBuffer
function! SwitchBuffer()
  " Check if the alternate buffer exists and is loaded
  if bufnr('#') != -1 && bufloaded(bufnr('#'))
    " Switch to the alternate buffer
    execute 'buffer#'
  else
    " Switch to the previous buffer in the buffer list
    execute 'bprevious'
  endif
endfunction
" }}}

" Helper function to close a buffer after switching
" {{{ CloseCurrentBuffer
function! CloseCurrentBuffer(message)
  if len(filter(getbufinfo(), 'v:val.listed')) > 1
    call SwitchBuffer()
    call ForceCloseBuffer('#', a:message)
    return
  endif
  call ForceCloseBuffer('%', a:message)
endfunction
" }}}

" {{{ HandleCloseBuffer
function! HandleCloseBuffer()
  " Define constants for user choices
  let s:SAVE_OPTION = 'y'
  let s:DONT_SAVE_OPTION = 'n'
  let s:CANCEL_OPTION = 'c'

  " Define messages and prompts
  let s:UNSAVED_CHANGES_PROMPT = "Current buffer has unsaved changes. Do you want to save it? [y]es, [n]o, [C]ancel: "
  let s:SAVED_AND_CLOSED_MSG = " saved and closed."
  let s:CLOSED_WITHOUT_SAVING_MSG = " closed without saving."
  let s:CLOSED_MSG = " closed."
  let s:CLOSE_CANCELED_MSG = "Buffer close canceled."

  " Get the list of buffers and the current buffer
  let buffers = filter(getbufinfo(), 'v:val.listed')
  let current_buf = bufnr('%')
  let current_buf_name = bufname(current_buf) != '' ? bufname(current_buf) : '[Unnamed]'

  " Check if the current buffer is not modified
  " {{{ Buffer has no unsaved changes
  if !IsBufferModified(current_buf)
    " Close the buffer immediately since it's not modified
    call CloseCurrentBuffer(current_buf_name . s:CLOSED_MSG)
    return
  endif
  " }}}

  " Prompt the user if the buffer has unsaved changes
  " {{{ Buffer has unsaved changes
  echo s:UNSAVED_CHANGES_PROMPT
  let choice = nr2char(getchar())

  " {{{ Save and close
  if tolower(choice) == s:SAVE_OPTION
    " Save the buffer and close it
    execute 'write'
    call CloseCurrentBuffer(current_buf_name . s:SAVED_AND_CLOSED_MSG)
    return
  endif
  " }}}

  " {{{ Discard and close
  if tolower(choice) == s:DONT_SAVE_OPTION
    " Discard the changes and close the buffer
    call CloseCurrentBuffer(current_buf_name . s:CLOSED_WITHOUT_SAVING_MSG)
    return
  endif
  " }}}

  " If user chooses to cancel
  echohl InfoMsg | echom s:CLOSE_CANCELED_MSG | echohl None
  " }}}
endfunction
" }}}

" Create a Vim command to trigger the HandleCloseBuffer function
command! HandleCloseBuffer call HandleCloseBuffer()

