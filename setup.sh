#!/bin/bash

work_path=$(dirname $(readlink -f $0))

apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-ugly  \
    libatlas3-base \
    libgstreamer1.0-dev \
    libtool-bin \
    python3 \
    python-pip \
    python-yaml \
    python-simplejson \
    python-setuptools \
    python-gi \
    build-essential \
    python-dev \
    zlib1g-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    pip install ws4py==0.3.2 && \
    pip install tornado==4.5.3 && \
    pip install futures && \
    ln -s -f bash /bin/sh

cd $work_path

bunzip2 -c jansson-2.7.tar.bz2 | tar xf -  && \
    cd $work_path/jansson-2.7 && \
    ./configure && make -j $(nproc) && make check &&  make install && \
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/jansson.conf && ldconfig && \
    rm $work_path/jansson-2.7.tar.bz2 && rm -rf $work_path/jansson-2.7

cd $work_path

git clone https://github.com/kaldi-asr/kaldi && \
    cd $work_path/kaldi/tools && \
    make -j $(nproc) && \
    ./install_portaudio.sh && \
    $work_path/kaldi/tools/extras/install_mkl.sh && \
    cd $work_path/kaldi/src && ./configure --shared && \
    sed -i '/-g # -O0 -DKALDI_PARANOID/c\-O3 -DNDEBUG' kaldi.mk && \
    make clean -j $(nproc) && make -j $(nproc) depend && make -j $(nproc) && \
    cd $work_path/kaldi/src/online && make depend -j $(nproc) && make -j $(nproc) && \
    cd $work_path/kaldi/src/gst-plugin && sed -i 's/-lmkl_p4n//g' Makefile && make depend -j $(nproc) && make -j $(nproc) && \
    cd $work_path/gst-kaldi-nnet2-online/src && \
    sed -i '/KALDI_ROOT?=\/home\/tanel\/tools\/kaldi-trunk/c\KALDI_ROOT?=$work_path\/kaldi' Makefile && \
    make depend -j $(nproc) && make -j $(nproc) && \
    find $work_path/gst-kaldi-nnet2-online/src/ -type f -not -name '*.so' -delete && \
    rm -rf $work_path/kaldi/.git && \
    rm -rf $work_path/kaldi/egs/ $work_path/kaldi/windows/ $work_path/kaldi/misc/ && \
    find $work_path/kaldi/src/ -type f -not -name '*.so' -delete && \
    find $work_path/kaldi/tools/ -type f \( -not -name '*.so' -and -not -name '*.so*' \) -delete && \
    cd $work_path

