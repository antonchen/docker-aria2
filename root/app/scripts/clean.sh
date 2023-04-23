#!/bin/bash
_TASK_GID=$1
_ARIA2_CONF="/config/aria2.conf"
_RPC_PORT=$(awk -F'=' '/^rpc-listen-port/ {print $2}' $_ARIA2_CONF)
_RPC_SECRET=$(awk -F'=' '/^rpc-secret/ {print $2}' $_ARIA2_CONF)
if [ $# -eq 0 ]; then
    exit
fi

GetTaskInfo ()
{
    _prc_uri="http://localhost:$_RPC_PORT/jsonrpc"
    _rpc_payload='{"jsonrpc":"2.0","method":"aria2.tellStatus","id":"Script","params":["token:'$_RPC_SECRET'","'$_TASK_GID'"]}'
    curl $_prc_uri -fsSd $_rpc_payload
}

DeleteTorrentFile ()
{
    _task_info=$(GetTaskInfo)
    _task_dir=$(echo "$_task_info"|jq -r .result.dir)
    _task_hash=$(echo "$_task_info"|jq -r .result.infoHash)
    _torrent_file="${_task_dir}/${_task_hash}.torrent"
    if [ -f $_torrent_file ]; then
        rm -f $_torrent_file
    fi
}

DeleteMagnetTask ()
{
    GetTaskInfo|jq -r .result.files[0].path|grep -q '^\[METADATA\]'
    if [ $? -eq 0 ]; then
        _prc_uri="http://localhost:$_RPC_PORT/jsonrpc"
        _rpc_payload='{"jsonrpc":"2.0","method":"aria2.removeDownloadResult","id":"Script","params":["token:'$_RPC_SECRET'","'$_TASK_GID'"]}'
        curl $_prc_uri -fsSd $_rpc_payload
    else
        DeleteTorrentFile
    fi
}

DeleteMagnetTask
