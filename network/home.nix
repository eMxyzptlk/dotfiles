let

  region = "us-west-1";
  accessKeyId = "personal";
  keyPair = "aws_global";
  ami = "ami-07aa7f56d612ddd38";

in {
  network.description = "Network at home, including my VPN on EC2";
  network.enableRollback = true;

  resources = {
    ec2SecurityGroups = {
      "ssh-in" = {
        inherit accessKeyId region;
        description = "Allow incoming SSH connection from anywhere";
        rules = [
          {fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "0.0.0.0/0"; }
          # TODO(low): https://github.com/NixOS/nixops/issues/683
          # {fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "::/0"; }
        ];
      };

      "vpn-in" = {
        inherit accessKeyId region;
        description = "Allow incoming VPN connection from anywhere";
        rules = [
          {fromPort = 1194; toPort = 1194; protocol = "udp"; sourceIp = "0.0.0.0/0"; }
          # TODO(low): https://github.com/NixOS/nixops/issues/683
          # {fromPort = 1194; toPort = 1194; protocol = "udp"; sourceIp = "::/0"; }
        ];
      };
    };
  };

  zeus = {
    imports = [ ../hosts/zeus/configuration.nix ];
    deployment.targetHost = "zeus.home.nasreddine.com";
  };

  staurn = {
    imports = [ ../hosts/staurn/configuration.nix ];
    deployment.targetHost = "staurn.home.nasreddine.com";
  };

  vpn-nasreddine = { resources, ... }: {
    imports = [ ../hosts/vpn-nasreddine/configuration.nix ];
    deployment = {
      targetEnv = "ec2";
      ec2 = {
        inherit accessKeyId region keyPair ami;

        instanceType = "t2.nano";

        securityGroups = [
          resources.ec2SecurityGroups.ssh-in
          resources.ec2SecurityGroups.vpn-in
        ];
      };
    };
  };
}
