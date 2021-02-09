<h1 align="center">
	<a href="https://github.com/WolfSoftware">
		<img src="https://raw.githubusercontent.com/WolfSoftware/branding/master/images/general/banners/64/black-and-white.png" alt="Wolf Software Logo" />
	</a>
	<br>
	TCP Wrapper Multiplexer
</h1>


<p align="center">
	<a href="https://travis-ci.com/SecOpsToolbox/tcp-wrapper-multiplexer">
		<img src="https://img.shields.io/travis/com/SecOpsToolbox/tcp-wrapper-multiplexer/master?style=for-the-badge&logo=travis" alt="Build Status">
	</a>
	<a href="https://github.com/SecOpsToolbox/tcp-wrapper-multiplexer/releases/latest">
		<img src="https://img.shields.io/github/v/release/SecOpsToolbox/tcp-wrapper-multiplexer?color=blue&style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release" alt="Release">
	</a>
	<a href="https://github.com/SecOpsToolbox/tcp-wrapper-multiplexer/releases/latest">
		<img src="https://img.shields.io/github/commits-since/SecOpsToolbox/tcp-wrapper-multiplexer/latest.svg?color=blue&style=for-the-badge&logo=github&logoColor=white" alt="Commits since release">
	</a>
	<a href="LICENSE.md">
		<img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" alt="Software License">
	</a>
	<br>
	<a href=".github/CODE_OF_CONDUCT.md">
		<img src="https://img.shields.io/badge/Code%20of%20Conduct-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
	<a href=".github/CONTRIBUTING.md">
		<img src="https://img.shields.io/badge/Contributing-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
	<a href=".github/SECURITY.md">
		<img src="https://img.shields.io/badge/Report%20Security%20Concern-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
	<a href=".github/SUPPORT.md">
		<img src="https://img.shields.io/badge/Get%20Support-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
</p>

## Overview

This is a [TCP wrapper](https://en.wikipedia.org/wiki/TCP_Wrappers) which acts as a multiplexer allowing multiple TCP Wrapper filters to be executed in sequence.

Unlike our specific filters, this wrapper do not provide any logic for allowing or denying connections itself, but simply bubbles up the allow/deny from the filters it calls.

It will call each filter in turn and only progress to the next if the current filter do **not** deny the connection. If all filters have been run and no **deny** has happened it will return an implicit **allow**. This follows the same logic as the individual filters.

### Security

The use of TCP wrappers does not eliminate the need for a properly configured firewall. This script should be seen as **part** of your security solution, **not** the whole of it.

### Prerequisites

Although there are no specific prerequisites, the wrapper will do nothing unless you install one of our [TCP Wrapper filters](https://github.com/SecOpsToolbox?q=in%3Aname+tcp+wrapper+filter&type=&language=).

#### Install the multiplexer

Copy the [script](src/multiplexer.sh) to /usr/local/sbin/multiplexer (and ensure that it is executable [*chmod +x]*).

Out of the box the [`FILTERS`](src/multiplexer.sh#L19) list is empty so the effect at this point is to return 0 (allow connection) and no implicit deny was found.

#### Adding filters

To add filters to the list, add them to the [`FILTERS`](src/multiplexer.sh#L19) variable. This is a space (or comma) separated list of filter name. The filter name is the name of the `executable` as defined in the filter documentation. E.g. asn-filter or country-filter. This will be prefixed with the [`FILTER_PATH`](src/multiplexer.sh#L20) to ensure the filter is accessed correctly.

> You can add as many filters as you wish and they are run **IN ORDER**

#### Process Ordering

In Linux/Unix based systems the processing order for TCP wrappers is as follows:

1. hosts.allow
2. hosts.deny

This means that anything that is not handled (allowed / denied) by hosts.allow will be handled by hosts.deny.

#### /etc/hosts.allow

The following configuration will tell the system to pass all IPs, for ssh connections, to the country-filter. The return code of the filter specifies the action to be taken.

1. 0 = Success - allow the connection.
2. 1 = Failure - deny the connection.

```shell
sshd: ALL: aclexec /usr/local/sbin/multiplexer %a 
```

> aclexec tells the system to execute the following script and %a is replace by the current IP address.

#### /etc/hosts.deny

The following configuration will tell the system to deny all ssh connections. 

```shell
sshd: ALL
```

> This should never be reached because all cases should be handled by the country filter, but as with all security configurations **protection in depth** is key and having a safe / secure fallback position is preferable.

## TCP Filters

We provide a number of different [TCP Wrapper filters](https://github.com/SecOpsToolbox?q=in%3Aname+tcp+wrapper+filter&type=&language=), all of which will work with this multiplexer.

## Contributors

<p>
	<a href="https://github.com/TGWolf">
		<img src="https://img.shields.io/badge/Wolf-black?style=for-the-badge" />
	</a>
</p>

## Show Support

<p>
	<a href="https://ko-fi.com/wolfsoftware">
		<img src="https://img.shields.io/badge/Ko%20Fi-blue?style=for-the-badge&logo=ko-fi&logoColor=white" />
	</a>
</p>
