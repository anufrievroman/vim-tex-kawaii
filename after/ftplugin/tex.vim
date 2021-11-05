" MINIMAL FOLDS STYLE

set foldmethod=marker
set foldmarker=<<<,>>>
function! MyFoldTextLatex()
    let line = getline(v:foldstart)
    let folded_line_num = v:foldend - v:foldstart
    let line_text = substitute(line, '^%<\+', '', 'g')
    return '‣'.  line_text   
endfunction
set foldtext=MyFoldTextLatex()
set fillchars=fold:\ 
let g:vim_markdown_override_foldtext = 1
let g:vim_markdown_folding_style_pythonic = 1

" FOLDINGS OF LATEX ENVIRONMENTS
" This is fork of tex-fold plugin (https://github.com/matze/vim-tex-fold) with some changes for better look.

if !exists('g:tex_fold_sec_char')
    let g:tex_fold_sec_char = '‣'
endif

if !exists('g:tex_fold_env_char')
    let g:tex_fold_env_char = '☘'
endif

if !exists('g:tex_fold_override_foldtext')
    let g:tex_fold_override_foldtext = 1
endif

if !exists('g:tex_fold_allow_marker')
    let g:tex_fold_allow_marker = 1
endif

if !exists('g:tex_fold_additional_envs')
    let g:tex_fold_additional_envs = []
endif

if !exists('g:tex_fold_use_default_envs')
    let g:tex_fold_use_default_envs = 1
endif

if !exists('g:tex_fold_ignore_envs')
    let g:tex_fold_ignore_envs = 0
endif

setlocal foldmethod=expr
setlocal foldexpr=TeXFold(v:lnum)

if g:tex_fold_override_foldtext
    setlocal foldtext=TeXFoldText()
endif

function! TeXFold(lnum)
    let line = getline(a:lnum)
    let default_envs = g:tex_fold_use_default_envs?
        \['frame', 'table', 'figure', 'equation', 'align', 'lstlisting', 'abstract']: []
    let envs = '\(' . join(default_envs + g:tex_fold_additional_envs, '\|') . '\)'

    if line =~ '^\s*\\section'
        return '>1'
    endif

    if line =~ '^\s*\\documentclass'
        return '>1'
    endif

    if line =~ '^\s*\\subsection'
        return '>2'
    endif

    if line =~ '^\s*\\subsubsection'
        return '>3'
    endif

    if !g:tex_fold_ignore_envs
        if line =~ '^\s*\\begin{' . envs
            return 'a1'
        endif

        if line =~ '^\s*\\end{' . envs
            return 's1'
        endif
    endif

    if g:tex_fold_allow_marker
        if line =~ '^[^%]*%[^{]*{{{'
            return 'a1'
        endif

        if line =~ '^[^%]*%[^}]*}}}'
            return 's1'
        endif
    endif

    return '='
endfunction

function! TeXFoldText()
    let fold_line = getline(v:foldstart)

    if fold_line =~ '^\s*\\\(sub\)*section'
        let pattern = '\\\(sub\)*section\*\={\([^}]*\)}'
        let repl = '' . g:tex_fold_sec_char . ' \2'
    elseif fold_line =~ '^\s*\\begin'
        let pattern = '\\begin{\([^}]*\)}'
        let repl = '' . g:tex_fold_env_char . ' \1'
    elseif fold_line =~ '^\s*\\\(sub\)*documentclass{'
        let pattern = '\\*documentclass\*\={\([^}]*\)}'
        let repl = '' . g:tex_fold_sec_char . ' Header'
    elseif fold_line =~ '^\s*\\\(sub\)*documentclass\['
        let pattern = '\\*documentclass\[[^}]*}'
        let repl = '' . g:tex_fold_sec_char . ' Header'
    elseif fold_line =~ '^[^%]*%[^{]*{{{'
        let pattern = '^[^{]*{' . '{{\([.]*\)'
        let repl = '\1'
    endif

    let g:trailing_char = ''
    if fold_line =~ '^\s*\\subsubsection'
        let g:trailing_char = '  '
    elseif fold_line =~ '^\s*\\subsection'
        let g:trailing_char = ' '
    endif
    endif

    let line = substitute(fold_line, pattern, repl, '') . ' '
    " return '' . v:folddashes . line
    return '' . g:trailing_char . line
endfunction

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl foldexpr< foldmethod< foldtext<"
else
  let b:undo_ftplugin = "setl foldexpr< foldmethod< foldtext<"
endif



" CONCEAL LATEX MATH

let g:tex_conceal="abdmgs"
set conceallevel=2
" syn region texStatement start='\\ref{' end='}' transparent contains=myStart,myEnd
" syn match myStart '\\ref{\ze\w\+' contained conceal cchar=[
" syn match myEnd '\(\\ref{\w\+\)\@<=\zs}' contained conceal cchar=]

" syn region texStatement start='\\cite{' end='}' transparent contains=myStart,myEnd
" syn match myStart '\\cite{' contained conceal cchar=[
" syn match myEnd '}' contained conceal cchar=]

" hi link texStatement Conceal
" hi texStatement ctermbg=NONE ctermfg=Magenta

" Additional conceal replacements
" Original file is https://github.com/wjakob/wjakob.vim/blob/master/after/syntax/tex.vim


if has('conceal')
  " Conceal references and citations:
  syn region texStatement start='\\bibliography{' end='}' contained conceal cchar=📚
  syn region texStatement start='\\cite{' end='}' contained conceal cchar=※
  syn region texStatement start='\\ref{' end='}' contained conceal cchar=𝕏

  " Random replacements:
  syn match texStatement '\\%'          contained conceal cchar=%
  syn match texMathSymbol '\\pathspace' contained conceal cchar=Ω
  syn match texMathSymbol '\\surfaces'  contained conceal cchar=𝓜

  " Arrows etc:
  syn match texMathSymbol '\\Rightarrow\>' contained conceal cchar=⇒
  syn match texMathSymbol '\\Leftarrow\>'  contained conceal cchar=⇐
  syn match texMathSymbol '\\rightarrow\>' contained conceal cchar=→
  syn match texMathSymbol '\\leftarrow\>'  contained conceal cchar=←
  syn match texMathSymbol '\\emptyset\>'   contained conceal cchar=Ø
  syn match texMathSymbol '\\varphi\>'     contained conceal cchar=φ
  syn match texMathSymbol '\\phi\>'        contained conceal cchar=Φ
  syn match texMathSymbol '\\langle\>\s*'  contained conceal cchar=⟨
  syn match texMathSymbol '\s*\\rangle\>'  contained conceal cchar=⟩
  syn match texMathSymbol '\\\\' contained conceal

  " Include space after greek letters:
  syn match texMathSymbol '\\Delta\> ' contained conceal cchar=Δ

  " Use regular greek letters when subscript/superscript not available:
  syn match texStatement '{\\textmu}'      contained conceal cchar=μ
  syn match texSubscripts '\\mu\>'         contained conceal cchar=μ
  syn match texSuperscripts '\\mu\>'       contained conceal cchar=μ
  syn match texSuperscripts '\\rho\>'      contained conceal cchar=ᵖ

  " Simple number super/sub-scripts
  syn match texMathSymbol '\^0' contained conceal cchar=⁰
  syn match texMathSymbol '\^1' contained conceal cchar=¹
  syn match texMathSymbol '\^2' contained conceal cchar=²
  syn match texMathSymbol '\^3' contained conceal cchar=³
  syn match texMathSymbol '\^4' contained conceal cchar=⁴
  syn match texMathSymbol '\^5' contained conceal cchar=⁵
  syn match texMathSymbol '\^6' contained conceal cchar=⁶
  syn match texMathSymbol '\^7' contained conceal cchar=⁷
  syn match texMathSymbol '\^8' contained conceal cchar=⁸
  syn match texMathSymbol '\^9' contained conceal cchar=⁹
  syn match texMathSymbol '^o'  contained conceal cchar=ᵒ

  syn match texMathSymbol '\^{-1}'         contained conceal contains=texSuperscripts
  syn match texMathSymbol '\^\\mathrm{T}'  contained conceal contains=texSuperscripts
  syn match texMathSymbol '\^\\mathrm{-T}' contained conceal contains=texSuperscripts
  syn match texSuperscripts '1'            contained conceal cchar=¹
  syn match texSuperscripts '-'            contained conceal cchar=⁻
  syn match texSuperscripts 'T'            contained conceal cchar=ᵀ
  syn match texSubscripts '='              contained conceal cchar=₌
  syn match texSubscripts ','              contained conceal cchar=,
  syn match texSubscripts '\\nu\>'         contained conceal cchar=ᵥ
  syn match texSuperscripts '\\nu\>'       contained conceal cchar=ᵛ


  syn match texMathSymbol '_0' contained conceal cchar=₀
  syn match texMathSymbol '_1' contained conceal cchar=₁
  syn match texMathSymbol '_2' contained conceal cchar=₂
  syn match texMathSymbol '_3' contained conceal cchar=₃
  syn match texMathSymbol '_4' contained conceal cchar=₄
  syn match texMathSymbol '_5' contained conceal cchar=₅
  syn match texMathSymbol '_6' contained conceal cchar=₆
  syn match texMathSymbol '_7' contained conceal cchar=₇
  syn match texMathSymbol '_8' contained conceal cchar=₈
  syn match texMathSymbol '_9' contained conceal cchar=₉
  syn match texMathSymbol '_i' contained conceal cchar=ᵢ
  syn match texMathSymbol '^i' contained conceal cchar=ⁱ
  syn match texMathSymbol '_o' contained conceal cchar=ₒ
  syn match texMathSymbol '*'  contained conceal cchar=·


  " logical symbols
  syn match texMathSymbol '\\lor\>'      contained conceal cchar=∨
  syn match texMathSymbol '\\land\>'     contained conceal cchar=∧
  syn match texMathSymbol '\\lnot\>'     contained conceal cchar=¬
  syn match texMathSymbol '\\implies\>'  contained conceal cchar=⇒
  syn match texMathSymbol '\\geqslant\>' contained conceal cchar=⩾
  syn match texMathSymbol '\\leqslant\>' contained conceal cchar=⩽

  " \mathbb characters
  syn match texMathSymbol '\\mathbb{A}' contained conceal cchar=𝔸
  syn match texMathSymbol '\\mathbb{B}' contained conceal cchar=𝔹
  syn match texMathSymbol '\\mathbb{C}' contained conceal cchar=ℂ
  syn match texMathSymbol '\\mathbb{D}' contained conceal cchar=𝔻
  syn match texMathSymbol '\\mathbb{E}' contained conceal cchar=𝔼
  syn match texMathSymbol '\\mathbb{F}' contained conceal cchar=𝔽
  syn match texMathSymbol '\\mathbb{G}' contained conceal cchar=𝔾
  syn match texMathSymbol '\\mathbb{H}' contained conceal cchar=ℍ
  syn match texMathSymbol '\\mathbb{I}' contained conceal cchar=𝕀
  syn match texMathSymbol '\\mathbb{J}' contained conceal cchar=𝕁
  syn match texMathSymbol '\\mathbb{K}' contained conceal cchar=𝕂
  syn match texMathSymbol '\\mathbb{L}' contained conceal cchar=𝕃
  syn match texMathSymbol '\\mathbb{M}' contained conceal cchar=𝕄
  syn match texMathSymbol '\\mathbb{N}' contained conceal cchar=ℕ
  syn match texMathSymbol '\\mathbb{O}' contained conceal cchar=𝕆
  syn match texMathSymbol '\\mathbb{P}' contained conceal cchar=ℙ
  syn match texMathSymbol '\\mathbb{Q}' contained conceal cchar=ℚ
  syn match texMathSymbol '\\mathbb{R}' contained conceal cchar=ℝ
  syn match texMathSymbol '\\mathbb{S}' contained conceal cchar=𝕊
  syn match texMathSymbol '\\mathbb{T}' contained conceal cchar=𝕋
  syn match texMathSymbol '\\mathbb{U}' contained conceal cchar=𝕌
  syn match texMathSymbol '\\mathbb{V}' contained conceal cchar=𝕍
  syn match texMathSymbol '\\mathbb{W}' contained conceal cchar=𝕎
  syn match texMathSymbol '\\mathbb{X}' contained conceal cchar=𝕏
  syn match texMathSymbol '\\mathbb{Y}' contained conceal cchar=𝕐
  syn match texMathSymbol '\\mathbb{Z}' contained conceal cchar=ℤ

  syn match texBoldMathText '\\mA\>' contained conceal cchar=A
  syn match texBoldMathText '\\mB\>' contained conceal cchar=B
  syn match texBoldMathText '\\mC\>' contained conceal cchar=C
  syn match texBoldMathText '\\mD\>' contained conceal cchar=D
  syn match texBoldMathText '\\mE\>' contained conceal cchar=E
  syn match texBoldMathText '\\mF\>' contained conceal cchar=F
  syn match texBoldMathText '\\mG\>' contained conceal cchar=G
  syn match texBoldMathText '\\mH\>' contained conceal cchar=H
  syn match texBoldMathText '\\mI\>' contained conceal cchar=I
  syn match texBoldMathText '\\mJ\>' contained conceal cchar=J
  syn match texBoldMathText '\\mK\>' contained conceal cchar=K
  syn match texBoldMathText '\\mL\>' contained conceal cchar=L
  syn match texBoldMathText '\\mM\>' contained conceal cchar=M
  syn match texBoldMathText '\\mN\>' contained conceal cchar=N
  syn match texBoldMathText '\\mO\>' contained conceal cchar=O
  syn match texBoldMathText '\\mP\>' contained conceal cchar=P
  syn match texBoldMathText '\\mQ\>' contained conceal cchar=Q
  syn match texBoldMathText '\\mR\>' contained conceal cchar=R
  syn match texBoldMathText '\\mS\>' contained conceal cchar=S
  syn match texBoldMathText '\\mT\>' contained conceal cchar=T
  syn match texBoldMathText '\\mU\>' contained conceal cchar=U
  syn match texBoldMathText '\\mV\>' contained conceal cchar=V
  syn match texBoldMathText '\\mW\>' contained conceal cchar=W
  syn match texBoldMathText '\\mX\>' contained conceal cchar=X
  syn match texBoldMathText '\\mY\>' contained conceal cchar=Y
  syn match texBoldMathText '\\mZ\>' contained conceal cchar=Z

  syn match texBoldMathText '\\va\>' contained conceal cchar=a
  syn match texBoldMathText '\\vb\>' contained conceal cchar=b
  syn match texBoldMathText '\\vc\>' contained conceal cchar=c
  syn match texBoldMathText '\\vd\>' contained conceal cchar=d
  syn match texBoldMathText '\\ve\>' contained conceal cchar=e
  syn match texBoldMathText '\\vf\>' contained conceal cchar=f
  syn match texBoldMathText '\\vg\>' contained conceal cchar=g
  syn match texBoldMathText '\\vh\>' contained conceal cchar=h
  syn match texBoldMathText '\\vi\>' contained conceal cchar=i
  syn match texBoldMathText '\\vj\>' contained conceal cchar=j
  syn match texBoldMathText '\\vk\>' contained conceal cchar=k
  syn match texBoldMathText '\\vl\>' contained conceal cchar=l
  syn match texBoldMathText '\\vm\>' contained conceal cchar=m
  syn match texBoldMathText '\\vn\>' contained conceal cchar=n
  syn match texBoldMathText '\\vo\>' contained conceal cchar=o
  syn match texBoldMathText '\\vp\>' contained conceal cchar=p
  syn match texBoldMathText '\\vq\>' contained conceal cchar=q
  syn match texBoldMathText '\\vr\>' contained conceal cchar=r
  syn match texBoldMathText '\\vs\>' contained conceal cchar=s
  syn match texBoldMathText '\\vt\>' contained conceal cchar=t
  syn match texBoldMathText '\\vu\>' contained conceal cchar=u
  syn match texBoldMathText '\\vv\>' contained conceal cchar=v
  syn match texBoldMathText '\\vw\>' contained conceal cchar=w
  syn match texBoldMathText '\\vx\>' contained conceal cchar=x
  syn match texBoldMathText '\\vy\>' contained conceal cchar=y
  syn match texBoldMathText '\\vz\>' contained conceal cchar=z
  " syn match texBoldMathText '\\bar\>' contained conceal cchar=‾

  " \mathcal characters
  syn match texMathSymbol '\\mathscr{A}' contained conceal cchar=𝓐
  syn match texMathSymbol '\\mathscr{B}' contained conceal cchar=𝓑
  syn match texMathSymbol '\\mathscr{C}' contained conceal cchar=𝓒
  syn match texMathSymbol '\\mathscr{D}' contained conceal cchar=𝓓
  syn match texMathSymbol '\\mathscr{E}' contained conceal cchar=𝓔
  syn match texMathSymbol '\\mathscr{F}' contained conceal cchar=𝓕
  syn match texMathSymbol '\\mathscr{G}' contained conceal cchar=𝓖
  syn match texMathSymbol '\\mathscr{H}' contained conceal cchar=𝓗
  syn match texMathSymbol '\\mathscr{I}' contained conceal cchar=𝓘
  syn match texMathSymbol '\\mathscr{J}' contained conceal cchar=𝓙
  syn match texMathSymbol '\\mathscr{K}' contained conceal cchar=𝓚
  syn match texMathSymbol '\\mathscr{L}' contained conceal cchar=𝓛
  syn match texMathSymbol '\\mathscr{M}' contained conceal cchar=𝓜
  syn match texMathSymbol '\\mathscr{N}' contained conceal cchar=𝓝
  syn match texMathSymbol '\\mathscr{O}' contained conceal cchar=𝓞
  syn match texMathSymbol '\\mathscr{P}' contained conceal cchar=𝓟
  syn match texMathSymbol '\\mathscr{Q}' contained conceal cchar=𝓠
  syn match texMathSymbol '\\mathscr{R}' contained conceal cchar=𝓡
  syn match texMathSymbol '\\mathscr{S}' contained conceal cchar=𝓢
  syn match texMathSymbol '\\mathscr{T}' contained conceal cchar=𝓣
  syn match texMathSymbol '\\mathscr{U}' contained conceal cchar=𝓤
  syn match texMathSymbol '\\mathscr{V}' contained conceal cchar=𝓥
  syn match texMathSymbol '\\mathscr{W}' contained conceal cchar=𝓦
  syn match texMathSymbol '\\mathscr{X}' contained conceal cchar=𝓧
  syn match texMathSymbol '\\mathscr{Y}' contained conceal cchar=𝓨
  syn match texMathSymbol '\\mathscr{Z}' contained conceal cchar=𝓩

  syn match texStatement '``'            contained conceal cchar="
  syn match texStatement '\'\''          contained conceal cchar="
  syn match texStatement '\\item\>'      contained conceal cchar=•
  syn match texMathSymbol '\\dd'         contained conceal cchar=d
  syn match texDelimiter '\\{'           contained conceal cchar={
  syn match texDelimiter '\\}'           contained conceal cchar=}
  syn match texMathSymbol '\\setminus\>' contained conceal cchar=\
  syn match texMathSymbol '\\coloneqq\>' contained conceal cchar=≔
  syn match texMathSymbol '\\,'          contained conceal
  syn match texMathSymbol '\\ '          contained conceal
  syn match texMathSymbol '\\quad'       contained conceal
  syn match texMathSymbol '\\sqrt'       contained conceal cchar=√
  syn match texMathSymbol '\\where\>'    contained conceal cchar=|
  syn match texMathSymbol '\\\!'         contained conceal
  "syn match texStatement '\\\['          contained conceal cchar=⟦
  "syn match texStatement '\\\]'          contained conceal cchar=⟧

  " hide \text delimiter etc inside math mode
  if !exists("g:tex_nospell") || !g:tex_nospell
    syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=mathrm\)\s*{'     end='}' concealends keepend contains=@texFoldGroup containedin=texMathMatcher
    syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=text\|mbox\)\s*{' end='}' concealends keepend contains=@texFoldGroup,@Spell containedin=texMathMatcher
  else
    syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=text\|mbox\|mathrm\)\s*{' end='}' concealends keepend contains=@texFoldGroup containedin=texMathMatcher
  endif

  syn region texBoldMathText matchgroup=texStatement start='\\\(mathbf\|bm\|symbf\){' end='}' concealends contains=@texMathZoneGroup containedin=texMathMatcher
  syn cluster texMathZoneGroup add=texBoldMathText

  syn region texBoldItalStyle     matchgroup=texTypeStyle start="\\emph\s*{" end="}" concealends contains=@texItalGroup
  syn region texItalStyle  matchgroup=texTypeStyle start="\\emph\s*{" end="}" concealends contains=@texItalGroup

  set ambiwidth=single
  " hi texBoldMathText cterm=bold gui=bold
endif
