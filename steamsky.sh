#!/bin/sh

prefix=`dirname $0`
cd "$prefix"
prefix=`pwd`

if [ -d lib ]; then
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$prefix/lib
   export GDK_PIXBUF_MODULE_FILE=$prefix/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
   export GDK_PIXBUF_MODULEDIR=$prefix/lib/gdk-pixbuf-2.0/2.10.0/loaders/
   export FONTCONFIG_FILE=$prefix/etc/fonts/fonts.conf
   export XDG_DATA_DIRS=$XDG_DATA_DIRS:$prefix/share
   export GSETTINGS_BACKEND=memory
else
   eval `gtkada-env.sh --print-only`
fi

bin/steamsky "$@"
