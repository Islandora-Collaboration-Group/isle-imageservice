# ISLE IIIF Image Service

## Part of the ISLE Islandora 7.x Docker Images
Designed as an IIIF compliant image server for ISLE.

**ALPHA RELEASE**

Based on:  
 - Ubuntu 18.04 "Bionic"
 - [Cantaloupe 3.4.3](https://medusa-project.github.io/cantaloupe/) an IIIF comliant open-source dynamic image server
 - Oracle Java 8.x latest (via APT repo.)

Contains and Includes:
  - [S6 Overlay](https://github.com/just-containers/s6-overlay) to manage services
  - [ImageMagick 7](https://www.imagemagick.org/)
    - Features: Cipher DPC HDRI OpenMP 
    - Delegates (built-in): bzlib cairo djvu fontconfig freetype jbig jng jp2 jpeg lcms lqr lzma openexr png raw rsvg tiff webp wmf zlib
  - [OpenJPEG](http://www.openjpeg.org/)
  - [FFmepg](https://www.ffmpeg.org/) 

  ~~- `cron` and `tmpreaper` to clean /tmp~~

Important Paths:
  - $CANTALOUPE_HOME is `/usr/local/cantaloupe`
  - $JAVA_HOME is `/usr/lib/jvm/java-8-oracle`

## Java Options
  - STILL TBD, currently:
  - $JAVA_OPTS are `-Djava.awt.headless=true -server -Xmx4096M -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxGCPauseMillis=200`

## Generic Usage

```
docker run -it -p "8182:8182" --rm benjaminrosner/isle-imageservice:development bash
```

## Cantaloupe Default Admin User

Login at http://{IP}:8182/admin  
Username: admin
Password: isle_admin  
