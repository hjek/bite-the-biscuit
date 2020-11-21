#!/usr/bin/env liquidsoap
output.icecast(%vorbis,
     host = "localhost", port = 8080,
     password = "hackme", mount = "liquid.ogg",
     input.pulseaudio())
