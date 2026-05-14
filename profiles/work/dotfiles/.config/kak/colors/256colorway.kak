# 256 Colorway

evaluate-commands %sh{
    base00='rgb:303030' # bg
    base01='rgb:444444' # bg-bright
    base02='rgb:585858'
    base03='rgb:6c6c6c'
    base04='rgb:9e9e9e'
    base05='rgb:b2b2b2' # base font
    base06='rgb:C6C6C6' # bold base font
    base07='rgb:DADADA'
    base08='rgb:D75F5F' # red
    base09='rgb:D7875F' # orange
    base0A='rgb:DFAF5F' # yellow
    base0B='rgb:87AF5F' # green
    base0C='rgb:5FD7AF' # cyan
    base0D='rgb:5FAFFF' # blue
    base0E='rgb:AF87D7' # magenta
    base0F='rgb:875F5F' # brown?

    echo "
	    # code
        face global value ${base09}
        face global type ${base0A}+b
		face global variable ${base08}
		face global module ${base0F}
		face global function ${base0D}
        face global string ${base0B}
        face global keyword ${base0E}+b
        face global operator ${base05}
        face global attribute ${base0C}
        face global comment ${base03}
        face global meta ${base0D}
        face global builtin ${base0D}+b

        # markup
        face global title ${base0D}+b
        face global header ${base0D}+b
        face global bold ${base0A}+b
        face global italic ${base0E}
        face global mono ${base0B}
        face global block ${base0C}
        face global link ${base09}
        face global bullet ${base08}
        face global list ${base08}

	    # builtin
        face global Default ${base05},default
        face global PrimarySelection default,${base02}+b
        face global SecondarySelection default,${base01}
        face global PrimaryCursor ${base00},${base06}+b
        face global SecondaryCursor ${base03},${base04}
        face global LineNumbers ${base02},${base00}
        face global LineNumberCursor ${base0A},${base00}
        face global LineNumbersWrapped ${base00},default
        face global MenuForeground ${base00},${base05}
        face global MenuBackground ${base00},${base06}
        face global MenuInfo ${base03}
        face global Information ${base00},${base0A}
        face global Error ${base07},${base08}
        face global StatusLine ${base04},${base01}
        face global StatusLineMode ${base0B}+r
        face global StatusLineInfo ${base0D}
        face global StatusLineValue ${base0C}
        face global StatusCursor ${base00},${base06}
        face global Prompt ${base0D},default
        face global MatchingChar default,default+bi
        face global BufferPadding ${base03},default
    "
}

################################################################################
# by Bhajneet S.K.
# Using base16 methodology by Chris Kempson (chriskempson.com)
# Only uses colors that are Xterm 256 compatible.
# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
