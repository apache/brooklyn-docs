---
title: Paths breakdown
---

Based on the installation method you choose, the paths to the installed components of Apache Brooklyn will be different. The
following table will help you to easily locate these:

<table class="table">
    <thead>
        <tr>
            <th>Installation method</th>
            <th>Brooklyn Home</td>
            <th>Brooklyn Logs</th>
            <th>Brooklyn Configuration</th>
            <th>Brooklyn Persisted state</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>RPM Package</td>
            <td><code>/opt/booklyn</code> (symlink to <code>/opt/booklyn-&lt;version&gt;</code>)</td>
            <td><code>/var/log/booklyn</code> (symlink to <code>/opt/booklyn-&lt;version&gt;/data/log</code>)</td>
            <td><code>/etc/booklyn</code></td>
            <td><code>/var/lib/booklyn</code></td>
        </tr>
        <tr>
            <td>DEB Package</td>
            <td><code>/opt/booklyn</code> (symlink to <code>/opt/booklyn-&lt;version&gt;</code>)</td>
            <td><code>/var/log/booklyn</code> (symlink to <code>/opt/booklyn-&lt;version&gt;/data/log</code>)</td>
            <td><code>/etc/booklyn</code></td>
            <td><code>/var/lib/booklyn</code></td>
        </tr>
        <tr>
            <td>Vagrant</td>
            <td><code>/opt/booklyn</code> (symlink to <code>/opt/booklyn-&lt;version&gt;</code>)</td>
            <td><code>/var/log/booklyn</code> (symlink to <code>/opt/booklyn-&lt;version&gt;/data/log</code>)</td>
            <td><code>/etc/booklyn</code></td>
            <td><code>/var/lib/booklyn</code></td>
        </tr>
        <tr>
            <td>Tarball Zip Package</td>
            <td><code>/path/of/untar/archive</code></td>
            <td><code>/path/of/untar/archive/data/log</code></td>
            <td><code>/path/of/untar/archive/etc</code></td>
            <td><code>~/.brooklyn/brooklyn-persisted-state</code></td>
        </tr>
    </tbody>
</table>