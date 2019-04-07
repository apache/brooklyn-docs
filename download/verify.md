---
layout: website-normal
title: Verify the Integrity of Downloads
---

You can verify the integrity of the downloaded files using their PGP (GPG) signatures or SHA256 checksums.

## Verifying Hashes

To verify the downloads, first get the GPG signatures and SHA256 hashes using these links. 
Note that all links are for first-class Apache Software Foundation mirrors 
so there is already reduced opportunity for anyone maliciously tampering with these files.

<table class="table">
<tr>
<th>Artifact</th>
<th colspan="2">Hashes</th>
</tr>
<tr>
<td>Release Manager's public keys</td>
<td colspan="2"><a href="https://www.apache.org/dist/brooklyn/KEYS">KEYS</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-bin.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-bin.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-bin.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-classic.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-classic.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-classic.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-classic.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-classic.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-classic.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-1.noarch.rpm</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-1.noarch.rpm.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-1.noarch.rpm.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-src.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-src.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-src.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-src.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-src.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-client-cli-linux.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-linux.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-linux.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-client-cli-linux.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-linux.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-linux.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-client-cli-macosx.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-macosx.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-macosx.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-client-cli-macosx.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-macosx.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-macosx.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-client-cli-windows.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-windows.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-windows.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-1.0.0-M1-client-cli-windows.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-windows.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-1.0.0-M1/apache-brooklyn-1.0.0-M1-client-cli-windows.zip.sha256">sha256</a></td>
</tr>

<tr>
<td>apache-brooklyn-0.12.0-bin.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-bin.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-bin.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-classic.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-classic.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-classic.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-classic.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-classic.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-classic.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-1.noarch.rpm</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-1.noarch.rpm.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-1.noarch.rpm.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-src.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-src.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-src.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-src.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-src.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-client-cli-linux.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-linux.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-linux.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-client-cli-linux.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-linux.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-linux.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-client-cli-macosx.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-macosx.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-macosx.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-client-cli-macosx.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-macosx.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-macosx.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-client-cli-windows.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-windows.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-windows.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.12.0-client-cli-windows.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-windows.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.12.0/apache-brooklyn-0.12.0-client-cli-windows.zip.sha256">sha256</a></td>
</tr>

<tr>
<td>apache-brooklyn-0.11.0-bin.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-bin.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-bin.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-karaf.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-karaf.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-karaf.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-karaf.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-karaf.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-karaf.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-1.noarch.rpm</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-1.noarch.rpm.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-1.noarch.rpm.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-src.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-src.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-src.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-src.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-src.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-client-cli-linux.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-linux.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-linux.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-client-cli-linux.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-linux.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-linux.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-client-cli-macosx.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-macosx.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-macosx.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-client-cli-macosx.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-macosx.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-macosx.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-client-cli-windows.tar.gz</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-windows.tar.gz.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-windows.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.11.0-client-cli-windows.zip</td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-windows.zip.asc">pgp</a></td>
<td><a href="https://www.apache.org/dist/brooklyn/apache-brooklyn-0.11.0/apache-brooklyn-0.11.0-client-cli-windows.zip.sha256">sha256</a></td>
</tr>

<tr>
<td>apache-brooklyn-0.10.0-bin.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-bin.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-bin.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-karaf.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-karaf.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-karaf.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-karaf.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-karaf.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-karaf.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-1.noarch.rpm</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-1.noarch.rpm.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-1.noarch.rpm.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-src.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-src.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-src.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-src.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-src.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-client-cli-linux.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-linux.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-linux.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-client-cli-linux.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-linux.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-linux.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-client-cli-macosx.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-macosx.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-macosx.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-client-cli-macosx.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-macosx.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-macosx.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-client-cli-windows.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-windows.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-windows.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.10.0-client-cli-windows.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-windows.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.10.0/apache-brooklyn-0.10.0-client-cli-windows.zip.sha256">sha256</a></td>
</tr>

<tr>
<td>apache-brooklyn-0.9.0-bin.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-bin.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-bin.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-1.noarch.rpm</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-1.noarch.rpm.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-1.noarch.rpm.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-src.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-src.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-src.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-src.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-src.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-client-cli-linux.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-linux.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-linux.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-client-cli-linux.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-linux.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-linux.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-client-cli-macosx.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-macosx.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-macosx.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-client-cli-macosx.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-macosx.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-macosx.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-client-cli-windows.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-windows.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-windows.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.9.0-client-cli-windows.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-windows.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-client-cli-windows.zip.sha256">sha256</a></td>
</tr>

<tr>
<td>apache-brooklyn-0.8.0-incubating-bin.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.8.0-incubating-bin.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-bin.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.8.0-incubating-src.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-src.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.8.0-incubating-src.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-src.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.8.0-incubating/apache-brooklyn-0.8.0-incubating-src.zip.sha256">sha256</a></td>
</tr>

<tr>
<td>apache-brooklyn-0.7.0-incubating-bin.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-bin.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-bin.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.7.0-incubating-bin.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-bin.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-bin.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.7.0-incubating-src.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-src.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-src.tar.gz.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.7.0-incubating-src.zip</td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-src.zip.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/apache-brooklyn-0.7.0-incubating/apache-brooklyn-0.7.0-incubating-src.zip.sha256">sha256</a></td>
</tr>
<tr>
<td>apache-brooklyn-0.7.0-M2-incubating.tar.gz</td>
<td><a href="https://archive.apache.org/dist/brooklyn/0.7.0-M2-incubating/apache-brooklyn-0.7.0-M2-incubating.tar.gz.asc">pgp</a></td>
<td><a href="https://archive.apache.org/dist/brooklyn/0.7.0-M2-incubating/apache-brooklyn-0.7.0-M2-incubating.tar.gz.sha256">sha256</a></td>
</tr>
</table>


You can verify the SHA256 hashes easily by placing the files in the same folder as the download artifact and
then running `shasum`, which is included in most UNIX-like systems:

{% highlight bash %}
shasum -c apache-brooklyn-{{ site.brooklyn-stable-version }}.tar.gz.sha256
{% endhighlight %}


In order to validate the release signature, download both the release `.asc` file for the release, and the `KEYS` file
which contains the public keys of key individuals in the Apache Brooklyn project.

Verify the signatures using one of the following commands:

{% highlight bash %}
pgpk -a KEYS
pgpv brooklyn-{{ site.brooklyn-stable-version }}-dist.tar.gz.asc
{% endhighlight %}

or

{% highlight bash %}
pgp -ka KEYS
pgp brooklyn-{{ site.brooklyn-stable-version }}-dist.zip.asc
{% endhighlight %}

or

{% highlight bash %}
gpg --import KEYS
gpg --verify brooklyn-{{ site.brooklyn-stable-version }}-dist.tar.gz.asc
{% endhighlight %}
