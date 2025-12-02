import socket
import json

PORT = 15894
HOST = '127.0.0.1'

request = {
    "command": "type",
    "params": {
        "file": "/home/namin/sources/purescript/src/Bill/Components/BillEditor.purs",
        "search": "Bill"
    }
}

try:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(json.dumps(request).encode('utf-8') + b'\n')
        data = s.recv(4096)
    print(f"Received: {data.decode('utf-8')}")
except Exception as e:
    print(f"Error: {e}")
