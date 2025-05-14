# cURL Time
Use `cURL` to retrieve the time spent on the different phases of a network request.

## Installation

1. Clone this repository or download [curltime.sh](./curltime.sh).
2. Add executable permissions to `curltime.sh`.

```sh
$ chmod +x curltime.sh
```

## Usage

**Regular usage**

Regular mode uses `cURL` to create a CSV file containing details of the time spent at the different steps required to download a resource.

```sh
$ ./curltime.sh -o ~/Downloads/trace.csv http://example.com
```

**Simple mode**

Simple mode uses `cURL` to output high-level values  into the terminal.

```sh
$  ./curltime.sh -s http://example.com
|                    0.000000s
| time_namelookup    0.000860s
| time_connect       0.020277s
| time_appconnect    0.058761s
| time_pretransfer   0.058894s
| time_redirect      0.000000s
| time_starttransfer 0.351321s
| time_total         0.402555s
```

See help for usage instructions.
```sh
$ ./curltime.sh --help
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
Timestamp,Time Elapsed (us),Self Duration (us), Type,Phase,Description
12:12:10.818903,0,0,Info,DNS,"IPv6: 2600:1408:ec00:36::1736:7f24, ..."
12:12:10.818927,24,24,Info,TCP Connect,"Trying 96.7.128.198:80..."
12:12:10.819123,220,196,Info,SSL Handshake,"TLSv1.3 (OUT), TLS handshake, Client hello (1):"
```

![Screenshot of Google Sheets showing a table containing network data, a pivot table aggregating the data by phase, and a chart showing the loading progress](https://github.com/user-attachments/assets/f2eaf5e9-1780-41b9-8f55-da1cf0421bbe)

The preceding image is a screenshot of the [sample data as viewed in Google Sheets](https://docs.google.com/spreadsheets/d/1HwYeIzVMTOdoJCavkEWSJR_wl2m5rhLAWcdwSKQSetA/edit?usp=sharing).

## License and Copyright

This software is released under the terms of the [MIT license](https://github.com/kevinfarrugia/crux_csv/blob/main/LICENSE).
