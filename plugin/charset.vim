" Vim global plugin for setting charset of read document
" Last change: 2002 Feb 04
" Maintainer: Tomas Zellerin <zellerin@volny.cz>

" Standard way of preventing its loading
if exists("loaded_charset_plugin")
	finish
endif
let loaded_charset_plugin=1

" Careful user will move following into relevant ftplugins and set
" charset_calls_in_ftplugin variable. Less careful user will be satisfied with
" this

if !exists("charset_calls_in_ftplugin")
	" When editing text file, look for charset at last line.
	au BufReadPost *.txt call ReloadWhenCharsetSet('$')

	" For html files, try to find line with charset in a special way.
	let s:htmlhint='\cContent=['."\'\"".']text/html;\s*charset=\(\%(\w\|-\)*\)'
	au BufReadPost *.html call ReloadWhenHtmlCharsetSet(s:htmlhint, "5", "bW")

	let s:xmlhint='encoding=["'."'" .']\(\%(\w\|-\)*\)'
	au BufReadPost *.xml call ReloadWhenHtmlCharsetSet(s:xmlhint, "/<?xml/+1", "bW")
endif

" function below tries to find "charset=<character set>" on given line; if
" this is found, file is reloaded with ++enc=<character set>
"
" First parameter: number (in a way getline() thinks about it, so, e.g., "$" is
" allowed) of line that we should look for charset.
" Optional second parameter: pattern to match (see its usage for exact
" 	meaning; should contain returned charset in \(\)
" 
" TODO: check whether <charset>=<fileencoding>?
function ReloadWhenCharsetSet(line, ...)
if a:0==0
	let pattern='\c\vcharset\s*\=(%(\w|\-)*)' " default value
else
	let pattern=a:1
endif
let firstline = getline(a:line) " line that is subject to inquiry
let magic = matchstr(firstline, pattern)
if ""==magic
	return
endif
let charset = substitute(magic, pattern, '\1', '')
silent exec 'edit! ++enc=' . charset . ' %'
endf

" First parameter: regexp pattern to use
" Second parameter: what to do before search (e.g., jump to position)
" Third parameter: flags for search (e.g., backward only & dont wrap)
function ReloadWhenHtmlCharsetSet(pattern, before, sflags)
execute a:before
let ln=search(a:pattern, a:sflags)
call ReloadWhenCharsetSet(ln, a:pattern)
endf
