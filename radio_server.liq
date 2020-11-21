#!/usr/bin/env liquidsoap

set("harbor.bind_addr","localhost")

live = input.harbor(
  "liquid.ogg",
  port=8080,
  password="hackme")

output.file(
  %vorbis,
  "radio.ogg",
  live,
  fallible=true)
