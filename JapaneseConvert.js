/**
 * 片假名转平假名。
 */
function katakana2hiragana(src) {
    return src.replace(/[\u30a1-\u30f6]/g, function(match) {
        var chr = match.charCodeAt(0) - 0x60;
        return String.fromCharCode(chr);
    });
}

/**
 * 平假名转片假名。
 */
function hiragana2katagana(src) {
    return src.replace(/[\u3041-\u3096]/g, function(match) {
        var chr = match.charCodeAt(0) + 0x60;
        return String.fromCharCode(chr);
    });
}
