if exists("loaded_manvim")
    finish
endif

if !exists('g:man_map_enable')
    let g:man_map_enable = 1
endif

let loaded_manvim = 1

fun! <SID>ReadManAux(man_word, count)
    let scr_bufnum = bufnr("__man__")
    if scr_bufnum == -1
        silent exe "vnew __man__"
    else
        " Scratch buffer is already created. Check whether it is open
        " in one of the windows
        let scr_winnum = bufwinnr(scr_bufnum)
        if scr_winnum != -1
            " Jump to the window which has the scratch buffer if we are not
            " already in that window
            if winnr() != scr_winnum
                exe scr_winnum . "wincmd w"
            endif
        else
            " Create a new scratch buffer
            exe "vsplit +buffer" . scr_bufnum
        endif
        normal ggdG
    endif
    let scr_bufnum = bufnr("__man__")

    ":vnew __man__
    " Assign current word under cursor to a script variable:
    :set buftype=nofile
    :set bufhidden=hide
    :setlocal noswapfile
    :setlocal nobuflisted
    :setlocal nowrap
    :set ft=man
    :set ts=8
    :map <buffer> q :bd<CR>
    :map <buffer> p p

    for i in [1,2,3,4,5,6,7,8]
        exe ":map <buffer> ".i." :call <SID>ReadManAux('".a:man_word."', ".i.")<CR>"
    endfor

    "exe setbufvar(scr_bufnum, 'man_name', "bla")

    let $GROFF_NO_SGR=1
    " Read in the manpage for man_word (col -b is for formatting):
    if a:count == 0
        :silent exe ":r!env man " . a:man_word . " | col -b"
    else
        :silent exe ":r!env man " . a:count . " " . a:man_word . " | col -b"
    endif
    " Goto first line...
    :exe ":goto"
    " and delete it:
    :exe ":delete"
endfun

fun! ReadMan()
    let s:man_word = expand('<cword>')
    let s:count=v:count
    call <SID>ReadManAux(s:man_word, s:count)
endfun

runtime! ftplugin/man.vim

if g:man_map_enable == 1
    " Map the K key to the ReadMan function:
    map <silent>  :<C-U>call ReadMan()<CR>
endif

