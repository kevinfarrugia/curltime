# cURL Time
Use `cURL` to retrieve the time spent on the different phases of a network request / response over HTTP(S).

## Installation

1. Clone this repository or download [curltime.sh](./curltime.sh).
2. Add executable permissions to `curltime.sh`.

```sh
$ chmod +x curltime.sh
```

## Usage

**Basic usage**
```sh
$ ./curltime http://example.com ~/Downloads/trace.csv
```

See help for usage instructions.
```sh
$ ./curltime --help
```


## Phases

| Phase         | Keywords in Description                                                               |
| ------------- | ------------------------------------------------------------------------------------- |
| DNS           | Trying, Trying IPv4, Trying IPv6, Trying ::, Trying [, Could not resolve, name lookup |
| TCP Connect   | Connected to, Connection, connect to, Trying, connected                               |
| SSL Handshake | TLS, SSL, ALPN, Cipher, Key, CAfile, Handshake, Using HTTP2                           |
| Request       | Send header, POST, GET, HEAD, PUT                                                     |
| Response      | Recv header, HTTP/, Status:                                                           |
| Transfer      | Upload, Download, Data, Received                                                      |
| Other         | fallback if no match                                                                  |

## Sample Output

```sh
Timestamp,Time Elapsed (us),Self Time (us), Type,Phase,Description
12:12:10.818903,0,0,Info,DNS,"IPv6: 2600:1408:ec00:36::1736:7f24, ..."
12:12:10.818927,24,24,Info,TCP Connect,"Trying 96.7.128.198:80..."
12:12:10.819123,220,196,Info,SSL Handshake,"TLSv1.3 (OUT), TLS handshake, Client hello (1):"
```

## License and Copyright

This software is released under the terms of the [MIT license](https://github.com/kevinfarrugia/crux_csv/blob/main/LICENSE).
