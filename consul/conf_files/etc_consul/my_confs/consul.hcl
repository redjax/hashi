datacenter = "lab1"
data_dir = "/opt/consul"
# Generate encryption key with $ consul keygen
encrypt = ""
# Note: below configuration is for a single-node setup
retry_join = ["127.0.0.1"]
bind_addr = "0.0.0.0"
# Set to your server's IP
advertise_addr = "192.168.1.xxx"
