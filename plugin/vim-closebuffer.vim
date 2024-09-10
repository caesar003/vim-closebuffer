" Vim-CloseBuffer Plugin
" Author: Caesar003
" Email: caesarmuksid@gmail.com
" Repo: https://github.com/caesar003/vim-closebuffer
" Last Modified: 2024-09-09
"
" Description:
" I find it frustrating that `:bd` not only destroys the current active buffer
" but also disrupts split windows. This plugin fixes that by switching to 
" another buffer before closing the current one. 
"
" The plugin also checks for unsaved modified buffers and prompts the user 
" to save, discard, or cancel the buffer close operation.
"
" Usage:
" - Call `:CloseBuffer` to safely close the current buffer.
" - Handles unsaved buffers with a user prompt.


" Check if a buffer is modified
" {{{ IsBufferModified
function! s:IsBufferModified(buf)
  return getbufvar(a:buf, '&modified') == 1
endfunction
" }}}

" Force close the specified buffer with a message
" {{{ ForceCloseBuffer
function! s:ForceCloseBuffer(buffer_number, message)
  execute 'bdelete!' a:buffer_number
  echohl InfoMsg | echom a:message | echohl None
endfunction
" }}}

" Helper function to switch to the previous buffer
" {{{ SwitchBuffer
function! s:SwitchBuffer()
  " Check if the alternate buffer exists and is loaded
  if bufnr('#') != -1 && bufloaded(bufnr('#'))
    " Switch to the alternate buffer
    execute 'buffer#'
    return
  endif
  " Switch to the previous buffer in the buffer list
  execute 'bprevious'
endfunction
" }}}

" Helper function to close a buffer after switching
" {{{ CloseCurrentBuffer
function! s:CloseCurrentBuffer(message)
  if len(filter(getbufinfo(), 'v:val.listed')) > 1
    call s:SwitchBuffer()
    call s:ForceCloseBuffer('#', a:message)
    return
  endif
  call s:ForceCloseBuffer('%', a:message)
endfunction
" }}}

" {{{ CloseBuffer
function! CloseBuffer()
  " Define constants for user choices
  let s:SAVE_OPTION = 'y'
  let s:DONT_SAVE_OPTION = 'n'
  let s:CANCEL_OPTION = 'c'

  " Define messages and prompts
  let s:UNSAVED_CHANGES_PROMPT = "Current buffer has unsaved changes. Do you want to save it? [y]es, [n]o, [C]ancel: "
  let s:ENTER_FILE_NAME_PROMPT = "Enter a name for the new file (leave blank to discard changes): "
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
  if !s:IsBufferModified(current_buf)
    " Close the buffer immediately since it's not modified
    call s:CloseCurrentBuffer(current_buf_name . s:CLOSED_MSG)
    return
  endif
  " }}}

  " Prompt the user if the buffer has unsaved changes
  " {{{ Buffer has unsaved changes
  echo s:UNSAVED_CHANGES_PROMPT
  let choice = nr2char(getchar())

  " {{{ Save and close
  if tolower(choice) == s:SAVE_OPTION
    " Check if the buffer is unnamed
    if current_buf_name == '[Unnamed]'
      " Prompt for a file name
      echo s:ENTER_FILE_NAME_PROMPT
      let file_name = input('')

      " If user provides a file name, save and close
      if file_name != ''
        execute 'write ' . file_name
        call s:CloseCurrentBuffer(file_name . s:SAVED_AND_CLOSED_MSG)
        return
      endif

      " If no name is given, discard changes and close
      call s:CloseCurrentBuffer(current_buf_name . s:CLOSED_WITHOUT_SAVING_MSG)
      return
    endif

    " Save the named buffer and close it
    execute 'write'
    call s:CloseCurrentBuffer(current_buf_name . s:SAVED_AND_CLOSED_MSG)
    return
  endif
  " }}}

  " {{{ Discard and close
  if tolower(choice) == s:DONT_SAVE_OPTION
    " Discard the changes and close the buffer
    call s:CloseCurrentBuffer(current_buf_name . s:CLOSED_WITHOUT_SAVING_MSG)
    return
  endif
  " }}}

  " If user chooses to cancel
  echohl InfoMsg | echom s:CLOSE_CANCELED_MSG | echohl None
  " }}}
endfunction
" }}}

" Create a command to trigger the CloseBuffer function
command! CloseBuffer call CloseBuffer()

