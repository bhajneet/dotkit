## quantum (https://github.com/bhajneet/quantum)
## by Bhajneet S.K.
## Based on base16 methodology by Chris Kempson (chriskempson.com)

evaluate-commands %sh{
    base00='rgb:263238'
    base01='rgb:37474F'
    base02='rgb:455A64'
    base03='rgb:78909C'
    base04='rgb:bdbdbd'
    base05='rgb:d9d9d9'
    base06='rgb:f5f5f5'
    base07='rgb:ffffff'
    base08='rgb:F5AAAA'
    base09='rgb:ff9d77'
    base0A='rgb:F3B146'
    base0B='rgb:9CCC63'
    base0C='rgb:78CCC4'
    base0D='rgb:51C9FE'
    base0E='rgb:D8AEEE'
    base0F='rgb:d7b4a8'

    ## code
    echo "
        face global value ${base09}
        face global type ${base0A}+b
        face global identifier ${base08}
        face global string ${base0B}
        face global keyword ${base0E}
        face global operator ${base05}
        face global attribute ${base0C}
        face global comment ${base03}
        face global meta ${base0D}
        face global builtin ${base0D}+b
    "

    ## markup
    echo "
        face global title ${base0D}+b
        face global header ${base0D}+b
        face global bold ${base0A}+b
        face global italic ${base0E}
        face global mono ${base0B}
        face global block ${base0C}
        face global link ${base09}
        face global bullet ${base08}
        face global list ${base08}
    "

    ## builtin
    echo "
        face global Default ${base05},${base00}
        face global PrimarySelection default,${base02}
        face global SecondarySelection default,${base01}
        face global PrimaryCursor ${base00},${base05}
        face global SecondaryCursor ${base07},${base04}
        face global LineNumbers ${base02},${base00}
        face global LineNumbersWrapped ${base00},default
        face global LineNumberCursor ${base0A},${base00}
        face global MenuForeground ${base00},${base0D}
        face global MenuBackground ${base00},${base0C}
        face global MenuInfo ${base02}
        face global Information ${base00},${base0A}
        face global Error ${base00},${base08}
        face global StatusLine ${base04},${base01}
        face global StatusLineMode ${base0B}
        face global StatusLineInfo ${base0D}
        face global StatusLineValue ${base0C}
        face global StatusCursor ${base00},${base05}
        face global Prompt ${base0D},${base01}
        face global MatchingChar ${base06},${base02}+b
        face global BufferPadding ${base03},${base00}
    "
}
