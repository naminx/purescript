const net = require('net');
const client = new net.Socket();
client.connect(15894, '127.0.0.1', function () {
    console.log('Connected');
    client.write(JSON.stringify({
        command: "type",
        params: {
            file: "/home/namin/sources/purescript/src/Bill/Components/BillEditor.purs",
            search: "Bill"
        }
    }) + '\n');
});
client.on('data', function (data) {
    console.log('Received: ' + data);
    client.destroy();
});
client.on('close', function () {
    console.log('Connection closed');
});
