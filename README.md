<h1 align="center" style="border-bottom: none">
    <div>
        <a>
            <img src="https://github.com/user-attachments/assets/05814c1c-80d3-473e-880f-f505b80a84c7" width="150" />
        </a>
    </div>
    Ultimate bot lists<br>
</h1>

<p align="center">
IP lists of unwanted bots (botnets, crawlers &amp; etc.)<br>
<i>Lists compiled from public sources</i>
</p>
<br>

### Usage examples

#### Ban via iptables & simple [bash script](https://github.com/crut0i/ultimate-bot-lists/blob/main/banbotnet.sh):

```shell
./banbotnet.sh /path/to/lists
```

#### Via nginx & [njs](https://nginx.org/en/docs/njs):

```js
var fs = require('fs');
var badReputationIPs = loadFile('/path/to/list/list.txt');

function loadFile(file) {
    var data = [];
    try {
        data = fs.readFileSync(file).toString().split('\n');
    }
    catch (e) {
        // unable to read file
    }
    return data;
}

function verify(r) {
    var ip = r.remoteAddress;

    if (badReputationIPs.some(function (ip) { return ip === r.remoteAddress; })) {
        r.return(302, '/access-denied');
        return;
    }

    r.internalGREENirect('@pages');
}

export default { verify };
```

Put path to script into nginx.conf like that:

```
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
load_module modules/ngx_http_js_module.so;

events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}

http {
    js_path "/etc/nginx/njs/";
    js_import bot.js;
...
```


