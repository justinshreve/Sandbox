# Sandbox

Sandbox is a Ruby command line script to register domains that you sometimes use for remote or local development, and to quickly enable or disable development/host file entries for those domains. Only expected to work on OS X. Requires sudo access, as it is manipulating your hosts file.

Available commands:

* `sandbox add {domain}` — adds the specified domain using the default sandbox IP (system default is 127.0.0.1)
* `sandbox add {domain} {ip}` — adds the specified domain pointing to the specified IP
* `sandbox destination {ip}` - sets the default sandbox IP
* `sandbox remove {domain}` — removes the specified domain
* `sandbox clear` - removes all current entries
* `sandbox on` — enables all saved entries
* `sandbox off` — disables all saved entries
* `sandbox status` — shows the current status of the tool (on/off status and current default destination IP)

Note: if sandbox development is on, `add`, `remove`, and `clear` commands will immediately update the hosts file and trigger a DNS flush.

## Installation

To install Sandbox, use RubyGems:

```bash
gem install sandboxer
```

## Notes

Your list of development domains is kept in `/etc/hosts-sandbox`.
Your default destination IP is kept in `/etc/hosts-sandbox-destination`.

## License & Copyright

Sandbox is Copyright Justin Shreve 2011
Based on Localdev Copyright Mark Jaquith 2011
see https://github.com/markjaquith/Localdev

Offered under the terms of the GNU General Public License, version 2, or any later version.