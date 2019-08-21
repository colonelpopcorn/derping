import os, sets, cligen, cligen/[mfile, mslice] #mSlices MSlice Splitr

proc cols(input="/dev/stdin", delim="white", output="/dev/stdout", sepOut=" ",
          blanksOk=false, cut=false, origin=1, colNums: seq[int]) =
    ##Write just some columns of input to output; Memory map input if possible.
    var outFile = open(output, fmWrite)
    var colSet = initSet[int](rightSize(len(colNums)))
    if cut:
        for c in colNums: colSet.incl(c)
    let splitr = initSplitr(delim)
    var cols: seq[MSlice] = @[ ]
    for line in mSlices(input, eat='\0'):   #RO mmap | slices from stdio
        var wroteSomething = false
        splitr.split(line, cols)
        if cut:
            var ith = 0
            for j, f in cols:
                if (origin + j) in colSet or (origin + j - cols.len) in colSet:
                  continue
                if ith != 0: outFile.write sepOut
                outFile.write f
                wroteSomething = true
                inc(ith)
        else:
            for ith, i in colNums:
                let j = if i < 0: i + cols.len else: i - origin
                if j < 0 or j >= cols.len:
                    continue
                if ith != 0: outFile.write sepOut
                outFile.write cols[j]
                wroteSomething = true
        if wroteSomething or blanksOk:
            outFile.write "\n"

when isMainModule:
    dispatch(cols, help = {
             "input"   : "path to mmap|read as input",
             "delim"   : "inp delim chars; Any repeats => fold",
             "output"  : "path to write output file",
             "sepOut"  : "output field separator",
             "blanksOk": "allow blank output rows",
             "cut"     : "cut/censor specified columns, not keep",
             "origin"  : "origin for colNums; 0=>signed indexing" })
