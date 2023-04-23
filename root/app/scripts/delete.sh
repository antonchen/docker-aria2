#!/bin/bash
_TASK_GID=$1
_FILE_NUM=$2
_FILE_PATH=$3
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

DeleteTask ()
{
    _prc_uri="http://localhost:$_RPC_PORT/jsonrpc"
    _rpc_payload='{"jsonrpc":"2.0","method":"aria2.removeDownloadResult","id":"Script","params":["token:'$_RPC_SECRET'","'$_TASK_GID'"]}'
    curl $_prc_uri -fsSd $_rpc_payload
}

DeleteDotFile ()
{
    if [ -f "${_FILE_PATH}.aria2" ]; then
        rm -f "${_FILE_PATH}.aria2"
    else
        _task_info=$(GetTaskInfo)
        _task_dir=$(echo "$_task_info"|jq -r .result.dir)
        _task_name=$(echo "$_task_info"|jq -r .result.bittorrent.info.name)
        if [ -f "${_task_dir}/${_task_name}.aria2" ]; then
            rm -f "${_task_dir}/${_task_name}.aria2"
        fi
    fi
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

DeleteTaskFile ()
{
    _task_info=$(GetTaskInfo)
    _task_status=$(echo $_task_info|jq -r .result.status)
    if [ "$_task_status" == "removed" ]; then
        echo $_task_info|grep -q bittorrent
        if [ $? -eq 0 ]; then
            _task_dir=$(echo "$_task_info"|jq -r .result.dir)
            _task_name=$(echo "$_task_info"|jq -r .result.bittorrent.info.name)
            if [ -e "${_task_dir}/${_task_name}" ]; then
                rm -rf "${_task_dir}/${_task_name}"
            fi
        else
            _task_file=$(echo $_task_info|jq -r .result.files[0].path)
            if [ -f "$_task_file" ]; then
                rm -f "$_task_file"
            fi
        fi
        DeleteTask
    fi
}

DeleteDotFile
DeleteTorrentFile
DeleteTaskFile
