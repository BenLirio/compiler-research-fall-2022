
# Compiler Research

**Student**: Ben Lirio

**Professor**: Eric Koskinen

## Background
When performing program analysis on decompiled binaries, it is useful to decompile the source executable into IR before a decompiling into a higher level language such as C. In the case of DarkSea, once the source x86 executable has been transformed into the target language C via an LLVM IR, DarkSea can perform program analysis. While this method has achieved state of the art results, it can be improved by transforming running static analysis on the IR. This research project explores that idea by creating and implementing rewrite rules for LLVM code.

## Run
Generate running instance with
```
docker build -t compiler-research-fall-2022 .
docker container run -it compiler-research-fall-2022
```
In a second window run
```
docker container cp [path-to-key] [container-name]:/ida-src.key
```
Within the container run
```
python3 /scripts/bootstrap.py /ida-src.key
```

### Why is bootstraping necessary?

This application uses IDA pro – proprietary software – and hence can not build all the dependencies into the docker image. As a work around, this application downloads and decrypts the proprietary software at runtime using a key not included in the docker image or repo.

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
