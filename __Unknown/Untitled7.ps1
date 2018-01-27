$port = 80
$ip = "192.168.1.1"
$socket = New-Object System.Net.Sockets.TcpClient($ip, $port)
If($socket.Connected) {
    "$ip listening to port $port"
    $socket.Close()
}