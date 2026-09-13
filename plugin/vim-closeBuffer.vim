" Vim-CloseBuffer Plugin
" Author: Caesar003
" Email: caesarmuksid@gmail.com
" Repo: https://github.com/caesar003/vim-closebuffer
" Last Modified: 2026-07-22
"
" Description:
" This plugin provides an improved buffer closing mechanism that preserves
" split windows, unlike Vim's standard ':bd' command. It intelligently switches
" to another buffer before closing the current one and handles unsaved changes.
"
" Usage:
" - :CloseBuffer              - Close the current buffer
" - :CloseBuffer 3 5 7        - Close buffers 3, 5, and 7
" - :CloseBufferExceptCurrent - Close all buffers except the current one
"
" Recommended mapping:
" nnoremap <Leader>x :CloseBuffer<CR>
" nnoremap <Leader>X :CloseBufferExceptCurrent<CR>
"
" Configuration:
" let g:close_buffer_no_confirm = 0  " Set to 1 to force-close modified buffers without prompting
" let g:close_buffer_quiet = 0       " Set to 1 to disable messages

" Constants for user choices
let s:SAVE_OPTION = 'y'
let s:DONT_SAVE_OPTION = 'n'
let s:CANCEL_OPTION = 'c'
let s:ALL_OPTION = 'a'

" Batch choice for "apply to all" during batch close operations
let s:batch_choice = ''

" Constants for messages and prompts
let s:UNSAVED_CHANGES_PROMPT = " has unsaved changes. [y]es, [n]o, a[ll], [c]ancel: "
let s:ENTER_FILE_NAME_PROMPT = "Enter a name for the new file (leave blank to discard changes): "
let s:SAVED_AND_CLOSED_MSG = " saved and closed."
let s:CLOSED_WITHOUT_SAVING_MSG = " closed without saving."
let s:CLOSED_MSG = " closed."
let s:CLOSE_CANCELED_MSG = "Buffer close canceled."
let s:INVALID_BUFFER_MSG = "Invalid buffer number: "

" Check if quiet mode is enabled
function! s:IsQuietMode()
  return exists('g:close_buffer_quiet') && g:close_buffer_quiet == 1
endfunction

" Display a message if not in quiet mode
"{{{
function! s:EchoMsg(message, highlight)
  if !s:IsQuietMode()
    execute 'echohl ' . a:highlight
    echom a:message
    echohl None
  endif
endfunction
"}}}

" Check if a buffer is modified
" {{{
function! s:IsBufferModified(buf)
  return getbufvar(a:buf, '&modified') == 1
endfunction
" }}}

" Force close the specified buffer with a message
" {{{
function! s:ForceCloseBuffer(buffer_number, message)
  try
    execute 'bdelete!' a:buffer_number
    call s:EchoMsg(a:message, 'InfoMsg')
  catch
    call s:EchoMsg('Error closing buffer ' . a:buffer_number . ': ' . v:exception, 'ErrorMsg')
  endtry
endfunction
" }}}

" Helper function to find a suitable buffer to switch to
" {{{
function! s:FindTargetBuffer(current_buf)
  " First try the alternate buffer
  if bufnr('#') != -1 && bufloaded(bufnr('#')) && bufnr('#') != a:current_buf
    return bufnr('#')
  endif
  
  " Otherwise, find the first listed buffer that isn't the current one
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != a:current_buf')
  return len(buffers) > 0 ? buffers[0] : -1
endfunction
" }}}

" Helper function to switch to another buffer before closing the current one
" {{{
function! s:SwitchBuffer(current_buf)
  let target_buf = s:FindTargetBuffer(a:current_buf)
  
  if target_buf != -1
    try
      execute 'buffer ' . target_buf
      return 1
    catch
      call s:EchoMsg('Error switching to buffer ' . target_buf . ': ' . v:exception, 'ErrorMsg')
      return 0
    endtry
  endif
  
  return 0
endfunction
" }}}

" Helper function to close a buffer after switching
" {{{
function! s:CloseCurrentBuffer(buffer_number, message)
  if a:buffer_number == bufnr('%')
    " We're closing the current buffer
    let switched = s:SwitchBuffer(a:buffer_number)
    if switched
      call s:ForceCloseBuffer(a:buffer_number, a:message)
    else
      " Last buffer, create a new empty one before closing
      enew!
      call s:ForceCloseBuffer(a:buffer_number, a:message)
    endif
  else
    " We're closing a different buffer
    call s:ForceCloseBuffer(a:buffer_number, a:message)
  endif
endfunction
" }}}

" Handle a single buffer close operation
" {{{
function! s:HandleBufferClose(buffer_number)
  " Validate buffer number
  if !bufexists(a:buffer_number)
    call s:EchoMsg(s:INVALID_BUFFER_MSG . a:buffer_number, 'ErrorMsg')
    return
  endif
  
  let buffer_name = bufname(a:buffer_number) != '' ? bufname(a:buffer_number) : '[Unnamed]'
  
  " Check if the buffer is modified
  if !s:IsBufferModified(a:buffer_number)
    call s:CloseCurrentBuffer(a:buffer_number, buffer_name . s:CLOSED_MSG)
    return
  endif
  
  " Only prompt for confirmation if closing the current buffer
  if a:buffer_number != bufnr('%')
    " Switch to the buffer we want to close
    let current_buf = bufnr('%')
    execute 'buffer ' . a:buffer_number
    let result = s:HandleModifiedBuffer(a:buffer_number)
    " Switch back if we didn't close the buffer. Use 'buffer!' since the
    " target buffer may still be modified (e.g. a failed save); force-
    " switching preserves its unsaved content.
    if result == 0 && bufexists(a:buffer_number)
      execute 'buffer! ' . current_buf
    endif
    return
  endif
  
  " Handle modified buffer
  call s:HandleModifiedBuffer(a:buffer_number)
endfunction
" }}}

" Save a buffer, prompting for a name if it's unnamed, then close it.
" Returns 1 when the buffer was closed, 0 when saving failed or was skipped.
" a:prompt_for_name enables the file-name prompt for unnamed buffers; when
" disabled (batch "save all"), unnamed buffers are left open with an error
" message instead of being force-closed (to avoid silent data loss).
" {{{
function! s:SaveAndCloseBuffer(buffer_number, prompt_for_name)
  let buffer_name = bufname(a:buffer_number) != '' ? bufname(a:buffer_number) : '[Unnamed]'

  if buffer_name == '[Unnamed]'
    if !a:prompt_for_name
      call s:EchoMsg('Cannot save unnamed buffer ' . a:buffer_number . '; leaving it open.', 'ErrorMsg')
      return 0
    endif

    echo s:ENTER_FILE_NAME_PROMPT
    let file_name = input('')

    if file_name != ''
      try
        execute 'write ' . file_name
        call s:CloseCurrentBuffer(a:buffer_number, file_name . s:SAVED_AND_CLOSED_MSG)
        return 1
      catch
        call s:EchoMsg('Error saving file: ' . v:exception, 'ErrorMsg')
        return 0
      endtry
    endif

    call s:CloseCurrentBuffer(a:buffer_number, buffer_name . s:CLOSED_WITHOUT_SAVING_MSG)
    return 1
  endif

  try
    execute 'write'
    call s:CloseCurrentBuffer(a:buffer_number, buffer_name . s:SAVED_AND_CLOSED_MSG)
    return 1
  catch
    call s:EchoMsg('Error saving file: ' . v:exception, 'ErrorMsg')
    return 0
  endtry
endfunction
" }}}

" Handle a modified buffer
" {{{
function! s:HandleModifiedBuffer(buffer_number)
  let buffer_name = bufname(a:buffer_number) != '' ? bufname(a:buffer_number) : '[Unnamed]'

  " g:close_buffer_no_confirm — force-close without prompting
  if exists('g:close_buffer_no_confirm') && g:close_buffer_no_confirm == 1
    call s:CloseCurrentBuffer(a:buffer_number, buffer_name . s:CLOSED_WITHOUT_SAVING_MSG)
    return 1
  endif

  " s:batch_choice — apply the saved choice from a previous "all" response
  if s:batch_choice == s:SAVE_OPTION
    return s:SaveAndCloseBuffer(a:buffer_number, 0)
  elseif s:batch_choice == s:DONT_SAVE_OPTION
    call s:CloseCurrentBuffer(a:buffer_number, buffer_name . s:CLOSED_WITHOUT_SAVING_MSG)
    return 1
  endif

  echo buffer_name . s:UNSAVED_CHANGES_PROMPT
  let choice = nr2char(getchar())
  echo "\n"

  if tolower(choice) == s:SAVE_OPTION || tolower(choice) == s:ALL_OPTION
    if tolower(choice) == s:ALL_OPTION
      let s:batch_choice = s:SAVE_OPTION
    endif
    return s:SaveAndCloseBuffer(a:buffer_number, 1)
  elseif tolower(choice) == s:DONT_SAVE_OPTION
    " Close without saving
    call s:CloseCurrentBuffer(a:buffer_number, buffer_name . s:CLOSED_WITHOUT_SAVING_MSG)
    return 1
  else
    " Cancel close operation
    call s:EchoMsg(s:CLOSE_CANCELED_MSG, 'InfoMsg')
    return 0
  endif
endfunction
" }}}

" Main function to close buffer(s)
" {{{
function! CloseBuffer(...)
  let s:batch_choice = ''
  " Process arguments
  if a:0 > 0
    " Close specific buffer numbers provided as arguments
    for i in range(a:0)
      call s:HandleBufferClose(str2nr(a:{i+1}))
    endfor
  else
    " Close current buffer
    call s:HandleBufferClose(bufnr('%'))
  endif
endfunction
" }}}

" Function to close all buffers except the current one
" {{{
function! CloseBufferExceptCurrent()
  let s:batch_choice = ''
  let current = bufnr('%')
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != current')
  
  for buf in buffers
    call s:HandleBufferClose(buf)
  endfor
  
  call s:EchoMsg("Closed all buffers except current", 'InfoMsg')
endfunction
" }}}

" Create commands to trigger the functions
command! -nargs=* CloseBuffer call CloseBuffer(<f-args>)
command! CloseBufferExceptCurrent call CloseBufferExceptCurrent()
