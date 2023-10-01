#!/bin/bash
SOURCE_DIR=. # mojo project dir on your personal computer
DEST_DIR=src/project # relative path remote server (should match structure on personal computer), replace path to your desired project structure
HOST={replace with your ip} # ie. 10.0.3.2

fswatch -r "$SOURCE_DIR" | while read f; do
  rsync -rvz "$SOURCE_DIR" "$HOST:$DEST_DIR"
done
