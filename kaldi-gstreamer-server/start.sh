#!/bin/bash

MASTER="localhost"
PORT=9998

usage(){
  echo "Creates a worker and connects it to a master.";
  echo "If the master address is not given, a master will be created at localhost:80";
  echo "Usage: $0 -y yaml_file [-m master address] [-p port number]";
}

while getopts "h?m:p:y:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    m)  MASTER=$OPTARG
        ;;
    p)  PORT=$OPTARG
        ;;
    y)  YAML=$OPTARG
        ;;
    esac
done

#yaml file must be specified
if [ -z "$YAML" ] || [ ! -f "$YAML" ] ; then
  usage;
  exit 1;
fi;


if [ "$MASTER" == "localhost" ] ; then
  # start a local master
  python2 ./kaldigstserver/master_server.py --port=$PORT 2>> ../log/master.log &
fi

#start worker and connect it to the master
export GST_PLUGIN_PATH=/data/xfding/asr/gst-kaldi-nnet2-online/src/:/home/xfding/kaldi/src/gst-plugin/

for i in {1..5}; do
#for i in 1; do
	python2 ./kaldigstserver/worker.py -c $YAML -u ws://$MASTER:$PORT/worker/ws/speech 2>> ../log/worker$i.log &
done
