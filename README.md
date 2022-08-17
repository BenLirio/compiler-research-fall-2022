# Compiler Research
**Student**: Ben Lirio
**Professor**: Eric Koskinen

## Background
When performing program analysis on decompiled binaries, it is useful to decompile the source executable into IR before a decompiling into a higher level language such as C. In the case of DarkSea, once the source x86 executable has been transformed into the target language C via an LLVM IR, DarkSea can perform program analysis. While this method has achieved state of the art results, it can be improved by transforming running static analysis on the IR. This research project explores that idea by creating and implementing rewrite rules for LLVM code.

## Setup
### Binary to x86
Using IDA
### x86 to LLVM
Using McSema

## References
- Papers
    - [Proving LTL Properties of Bitvector Programs
and Decompiled Binaries](https://www.erickoskinen.com/papers/darksea.pdf)
- Repos
    - [DarkSea](https://github.com/cyruliu/darksea)
    - [McSema](https://github.com/lifting-bits/mcsema)
- Other
    - [IDA](https://hex-rays.com/ida-free/#download)
