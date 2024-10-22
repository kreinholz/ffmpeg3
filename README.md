# Custom FreeBSD Port: ffmpeg-3.0.2

This is a quick-and-dirty custom Port of ffmpeg-3.0.2 that I created for use with PPSSPP.

As documented in numerous places by the PPSSPP devs, any version of ffmpeg over 3.0.2 starts to break PPSSPP's normally excellent PSP game compatibility:

https://github.com/hrydgard/ppsspp/issues/15308#issuecomment-1030655799

https://github.com/hrydgard/ppsspp/issues/17336

https://github.com/hrydgard/ppsspp/issues/6663

https://github.com/hrydgard/ppsspp/issues/15969

https://github.com/hrydgard/ppsspp/issues/15788

https://github.com/hrydgard/ppsspp/issues/11490#issuecomment-782735810

https://github.com/Homebrew/homebrew-core/issues/84737

Philosophical discussions about "The Right Way" to port software, or the risks involved with running oudated versions of software, aside, I like PPSSPP to play games containing FMVs without randomly crashing. The following games crash to the point of being unplayable using the FreeBSD Ports or official packages version of PPSSPP, built against current ffmpeg (6.x branch), but are playable all the way through with ppsspp-1.17.1 when forced to use ffmpeg-3.0.2 instead of current ffmpeg 6.x:

Persona

Crisis Core Final Fantasy VII

The Legend of Nayuta: Boundless Trails

Ys Seven

...and many more!

This was tested on amd64 FreeBSD 14.1, when built against the following versions of shared libs required by ffmpeg-3.0.2:

        libx264.so.164
        libva.so.2

It can be built directly from source utilizing the command `make install clean` or integrated into a synth or poudriere build with some creativity.

ffmpeg-3.0.2 does not conflict with either ffmpeg4 or ffmpeg installed from FreeBSD Ports or packages, as it installs all libraries, headers, and shared data in /usr/local/ffmpeg3.

Its primary purpose is to serve as a dependency for PPSSPP, unbreaking compatibility with games containing FMVs after ~ 2016.

I highly recommend leaving the `make config` options alone, as I attempted to minimize dependencies since only a small subset of ffmpeg's capabilities are actually needed to playing FMVs in PSP games.

As of the latest revision, I've stopped building the ffmpeg programs, opting instead to build only the minimum libraries and headers required by emulators/ppsspp. This is in part to discourage running outdated and potentially insecure binaries, and also to make it clear this is not intended as an alternative to either multimedia/ffmpeg4 or multimedia/ffmpeg. Its sole purpose is to build emulators/ppsspp in such a way that PSP game compatibility is not broken where in-game FMVs are concerned.
