## quantum (https://github.com/bhajneet/quantum)
## by Bhajneet S.K.
## Based on base16 methodology by Chris Kempson (chriskempson.com)

%sh{
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
        face value ${base09}
        face type ${base0A}+b
        face identifier ${base08}
        face string ${base0B}
        face keyword ${base0E}
        face operator ${base05}
        face attribute ${base0C}
        face comment ${base03}
        face meta ${base0D}
        face builtin ${base0D}+b
    "

    ## markup
    echo "
        face title ${base0D}+b
        face header ${base0D}+b
        face bold ${base0A}+b
        face italic ${base0E}
        face mono ${base0B}
        face block ${base0C}
        face link ${base09}
        face bullet ${base08}
        face list ${base08}
    "

    ## builtin
    echo "
        face Default ${base05},${base00}
        face PrimarySelection default,${base02}
        face SecondarySelection default,${base01}
        face PrimaryCursor ${base00},${base05}
        face SecondaryCursor ${base07},${base04}
        face LineNumbers ${base02},${base00}
        face LineNumbersWrapped ${base00},default
        face LineNumberCursor ${base0A},${base00}
        face MenuForeground ${base00},${base0D}
        face MenuBackground ${base00},${base0C}
        face MenuInfo ${base02}
        face Information ${base00},${base0A}
        face Error ${base00},${base08}
        face StatusLine ${base04},${base01}
        face StatusLineMode ${base0B}
        face StatusLineInfo ${base0D}
        face StatusLineValue ${base0C}
        face StatusCursor ${base00},${base05}
        face Prompt ${base0D},${base01}
        face MatchingChar ${base06},${base02}+b
        face BufferPadding ${base03},${base00}
    "
}
