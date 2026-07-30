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

## Couldn't create EC2 Instance after creating VPC
**Symptom:** apply failed on instance creation with an unsupported-instance-type error.
**Assumed:** bad instance type or a region problem. 
**Actual:** the subnet had no AZ, AWS chose a legacy one, and the instance inherited it.
**Principle:** subnets are AZ-scoped and everything in them inherits that placement and 
error messages sometimes point at the wrong resource, since the failure surfaced 
on the instance while the cause was in the subnet.

## Coudln't start the puppet server due to limited ram
**Symptom:** systemctl start failed with a generic "control process exited" message. No useful detail.
**Diagnosis:** journalctl -u puppetserver showed the JVM failing to commit 2147483648 bytes.
**Cause:** the package's default heap is -Xms2g -Xmx2g; the instance has 2GB total, so nothing was left for the OS.
**Fix:** reduced heap to 512m, ample for two agents. Also had to reset-failed because systemd had rate-limited restarts.
**Principle:** vendor defaults target production scale. systemctl status tells you that something failed; journalctl -u tells you why. 
That escalation is the first move for any service that won't start.

## Puppet server ca list wouldn't run
**Symptom:** puppetserver ca list failed with getaddrinfo: Name or service not known for the server's own hostname.
**Assumed:** Puppet misconfiguration, or the server not listening. ss -tlnp showed java bound on 8140, which ruled that out.
**Actual:** enable_dns_hostnames defaults to false on custom VPCs, so Amazon's resolver wouldn't answer for *.ec2.internal. Nothing to do with Puppet.
**Principle:** Puppet identifies nodes by certificate, and certificates are issued to hostnames, so DNS is load-bearing infrastructure, not a convenience. 
Also: a name resolution error is a name resolution error, whatever tool surfaces it. The stack under the error message matters more than the tool reporting it.