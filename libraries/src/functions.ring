/*
    SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

# ============================================================
# FUNCTIONS
# ============================================================

func ringtest_list2str aList
    cResult = ""
    for i = 1 to len(aList)
        if isString(aList[i])
            cResult += '"' + aList[i] + '"'
        elseif isNumber(aList[i])
            cResult += "" + aList[i]
        else
            cResult += "?"
        ok
        if i < len(aList)
            cResult += ", "
        ok
    next
    return cResult

func ringtest_str value
    if isString(value) return '"' + value + '"' ok
    if isNumber(value) return "" + value ok
    if isList(value) return ringtest_list2str(value) ok
    if isNULL(value) return "NULL" ok
    return "(unknown)"

func ringtest_fabs n
    if n < 0 return -n ok
    return n

func ringtest_padRight cStr, nLen
    cResult = cStr
    while len(cResult) < nLen
        cResult += " "
    end
    return cResult

func ringtest_escapeJSON cStr
    cStr = substr(cStr, '"', '\"')
    cStr = substr(cStr, nl, '\n')
    return cStr

func ringtest_formatDuration nSecs
    if nSecs < 0.001
        return "" + (nSecs * 1000000) + "us"
    elseif nSecs < 1
        return "" + (nSecs * 1000) + "ms"
    else
        return "" + nSecs + "s"
    ok

func ringtest_formatBenchTime nSecs
    if nSecs < 0.000001
        return "" + ringtest_round(nSecs * 1000000000, 2) + "ns"
    elseif nSecs < 0.001
        return "" + ringtest_round(nSecs * 1000000, 2) + "us"
    elseif nSecs < 1
        return "" + ringtest_round(nSecs * 1000, 2) + "ms"
    else
        return "" + ringtest_round(nSecs, 4) + "s"
    ok

func ringtest_round nVal, nDecimals
    nMult = 1
    for i = 1 to nDecimals
        nMult *= 10
    next
    return floor(nVal * nMult + 0.5) / nMult
