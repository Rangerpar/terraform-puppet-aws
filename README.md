# terraform-puppet-aws

Two-node lab demonstrating the Terraform-to-Puppet handoff on AWS.
Built to learn the stack; not production-ready. See Limitations below.

Terraform provisions a VPC, subnet, and two Ubuntu 24.04 EC2 instances.
One runs a Puppet server; the other enrolls as an agent and is configured
as an nginx web server without ever being logged into.

## Architecture

[ASCII or Mermaid diagram: laptop → Terraform → VPC containing
 puppet server + web node, with the 8140 arrow between them]

## Prerequisites
- AWS account and credentials configured
- Terraform >= 1.x
- An SSH keypair at ~/.ssh/tf-lab
- This repo public on GitHub (the server clones it at boot)

## Usage
[the commands, plus: ~$0.03/hour, run terraform destroy when done]

## Design decisions
- Terraform provisions, Puppet configures. No remote-exec provisioners; the handoff is user_data.
- Puppet Server heap tuned to 512m. Package default is 2GB on a 2GB instance. Chose to tune the app to the host rather than upsize, since two nodes don't need that heap.
- Agent points at private_dns, not an IP. Puppet authenticates via certificates issued to hostnames; an IP wouldn't match the cert.
- Security groups reference each other rather than CIDR blocks. Instance IPs change on every rebuild; group membership doesn't.
- Manifests deployed by git clone at boot. Not scp, so a rebuilt server comes up with current code.

## Limitations
- Certificate signing is manual, doesn't scale past a handful of nodes. The production answer is policy-based autosigning with a pre-shared token, and there's a real security tradeoff there.
- git clone at boot is a poor substitute for a control repo with r10k. No environment branches, no code versioning tied to deploys.
- Single public subnet, no private tier or NAT gateway, omitted for cost.
- Puppet server hostname is ephemeral, so rebuilding it invalidates every agent's trust. Production needs a stable DNS alias plus dns_alt_names on the cert.
- No remote state backend; state is local.
- node default in site.pp works with one node type but won't survive a second.

## Debugging log
See NOTES.md.


