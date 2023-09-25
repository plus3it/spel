# OpenSSH and FIPS on EL8

Red Hat 8 (and derivatives/forks) implement a new version of the OpenSSH service. The new service deprecates support for SSH keys that leverage signing-algorithms less modern than SHA2. As such, when one attempts to login to a freshly-launched, spel-BASED VM, the administator may find that the server rejects their SSH key. In order for a key to be recognized for login purposes:

* A SHA2 signing-method be used for all RSAv2 keys[^1]
* RSAv2 keys should be at least 2048-bits long[^2]


## Generating Compatible Keys

There are a couple ways to ensure a suitable key:

* Instead of using `-t rsa`, use `-t rsa-sha2-256` or `-t rsa-sha2-512` when using OpenSSH's `ssh-keygen` to generate the key[^3]
* Use `ssh-keygen` on a FIPS-enabled RHEL 8+ system to generate the key
* Use AWS EC2's `Key Pairs` &raquo; `Create Key Pair` option in AWS commercial regions[^4]

## Symptoms

Depending on the SSH client, the key may silently fail to work or it may print an error. If an error is printed, it will usually be something like:

```bash
Load key "/path/to/key-file": error in libcrypto
```

With or without the printing of the error, the key will be disqualified and the server will request the client move on to the next-available authentication-metho (usually password).

If one is able to access the system logs, one will usually find errors similar to:

```bash
Feb 09 12:10:50 ip-0a00dc73 sshd[2939]: input_userauth_request: invalid user ec2-user [preauth]
```

Or

```bash
Feb 09 12:10:50 ip-0a00dc73 sshd[2939]: input_userauth_pubkey: key type ssh-rsa not in PubkeyAcceptedKeyTypes [preauth]
```

In the `/var/log/secure` logs.

**Note:** Keys that are rejected for login-authentication typically will not be rejected for key-forwarding. If one has configured key-forwarding, the rejected key _should_ still show up in the output of `ssh-keygen -l` when executed on the remote system.

[^1]: SHA512 preferred for future-proofing)
[^2]: 4096 or even 8192-bits preferred for future-proofing)
[^3]: This works for both the Linux OpenSSH and PowerShell OpenSSH tooling)
[^4]: Other regions _may_ work, but have not been tested
