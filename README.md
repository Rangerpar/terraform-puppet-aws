# terraform-puppet-aws

## SSH hung with no error after applying
**Symptom:** `ssh -i ~/.ssh/tf-lab ubuntu@<ip>` hung ~30s, then timed out.
Instance showed running in the console.
**Assumed:** key pair problem, wrong file, wrong permissions, or the
public key never landed on the box.
**Actual:** no security group attached, so the instance inherited the
default VPC security group, which allows no inbound SSH from the internet.
Key pair was fine.
**Principle:** timeout vs. refused is the first diagnostic. A hang means
packets dropped silently, firewall. "Connection refused" means something
answered and said no, service down or wrong port. I was debugging the
wrong layer for 20 minutes because I didn't make that distinction.