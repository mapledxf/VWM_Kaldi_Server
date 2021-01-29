FROM kaldiasr/kaldi:latest
MAINTAINER Xuefeng Ding <xfding@vw-mobvoi.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    procps \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-ugly  \
    libatlas3-base \
    libgstreamer1.0-dev \
    libtool-bin \
    python-pip \
    python-yaml \
    python-simplejson \
    python-setuptools \
    python-gi \
    build-essential \
    python-dev \
    zlib1g-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y 

RUN pip install ws4py==0.3.2 && \
    pip install tornado==4.5.3 && \
    pip install futures && \
    ln -s -f bash /bin/sh

WORKDIR /opt

RUN cd /opt && \
    git clone https://github.com/mapledxf/VWM_Kaldi_Server.git && \
    cd VWM_Kaldi_Server && \
    bunzip2 -c jansson-2.7.tar.bz2 | tar xf -  && \
    cd jansson-2.7 && \
    ./configure && make && make check &&  make install && \
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/jansson.conf && ldconfig && \
    cd /opt && \
    rm /opt/VWM_Kaldi_Server/jansson-2.7.tar.bz2 && rm -rf /opt/VWM_Kaldi_Server.git/jansson-2.7


RUN cd /opt/kaldi/tools && ./install_portaudio.sh

RUN cd /opt/kaldi/src/online && make depend -j $(nproc) && make -j $(nproc)

RUN cd /opt/kaldi/src/gst-plugin && sed -i 's/-lmkl_p4n//g' Makefile && make depend -j $(nproc) && make -j $(nproc) 

RUN cd /opt/VWM_Kaldi_Server/gst-kaldi-nnet2-online/src && \
    sed -i '/KALDI_ROOT?=\/home\/tanel\/tools\/kaldi-trunk/c\KALDI_ROOT?=\/opt\/kaldi' Makefile && \
    make depend -j $(nproc) && make -j $(nproc) && \
    find /opt/VWM_Kaldi_Server/gst-kaldi-nnet2-online/src/ -type f -not -name '*.so' -delete 

RUN rm -rf /opt/kaldi/.git && \
    rm -rf /opt/kaldi/egs/ /opt/kaldi/windows/ /opt/kaldi/misc/ && \
    find /opt/kaldi/src/ -type f -not -name '*.so' -delete && \
    find /opt/kaldi/tools/ -type f \( -not -name '*.so' -and -not -name '*.so*' \) -delete 

RUN mkdir -p /opt/model/ && \
    cd /opt

RUN chmod +x /opt/VWM_Kaldi_Server/kaldi-gstreamer-server/start.sh && \
    chmod +x /opt/VWM_Kaldi_Server/kaldi-gstreamer-server/stop.sh

RUN ln /opt/VWM_Kaldi_Server/kaldi-gstreamer-server/start.sh . && \
    ln /opt/VWM_Kaldi_Server/kaldi-gstreamer-server/stop.sh .
