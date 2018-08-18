# ISLE IIIF Image Service

## Part of the ISLE Islandora 7.x Docker Images
Designed as an IIIF compliant image server for ISLE.

Based on:  
 - [ISLE-ubuntu-basebox](https://hub.docker.com/r/benjaminrosner/isle-ubuntu-basebox/)
    - Ubuntu 18.04 "Bionic"
    - General Dependencies (@see [ISLE-ubuntu-basebox](https://hub.docker.com/r/benjaminrosner/isle-ubuntu-basebox/))
    - Oracle Java
 - [Cantaloupe 3.4.3](https://medusa-project.github.io/cantaloupe/) an IIIF comliant open-source dynamic image server

Contains and Includes:
  - [ImageMagick 7](https://www.imagemagick.org/)
    - Features: Cipher DPC HDRI OpenMP 
    - Delegates (built-in): bzlib djvu mpeg fontconfig freetype jbig jng jpeg lcms lqr lzma openexr openjp2 png ps raw rsvg tiff webp wmf x zlib
  - [OpenJPEG](http://www.openjpeg.org/)
  - [FFmepg](https://www.ffmpeg.org/) 

Size: 887MB

Important Paths:
  - $CANTALOUPE_HOME is `/usr/local/cantaloupe`
  - $JAVA_HOME is `/usr/lib/jvm/java-8-oracle`

## Java Options
  - $JAVA_OPTS are `-Djava.awt.headless=true -server -Xmx8G -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxGCPauseMillis=200`

## Generic Usage

```
docker run -it -p "8182:8182" --rm benjaminrosner/isle-imageservice:development bash
```

## Cantaloupe Default Admin User

Login at http://{IP}:8182/admin  
Username: admin  
Password: isle_admin  
