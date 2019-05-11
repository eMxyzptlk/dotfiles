let
  lib = (import <nixpkgs> {}).lib;
  secrets = import /yl/private/network-secrets/shabka/network/work.nix;
in {
  network.description = "Network at work";
  network.enableRollback = true;

  resources.vpc.nixops = {
    inherit (secrets) accessKeyId cidrBlock region;

    enableDnsSupport = true;

    tags = {
      Source = "NixOps";
    };
  };

  resources.vpcSubnets =
    let
      subnet = {cidr, zone}:
        { resources, ... }:
        {
          inherit (secrets) accessKeyId region zone;
          vpcId = resources.vpc.nixops;
          cidrBlock = cidr;
          mapPublicIpOnLaunch = true;
          tags = {
            Source = "NixOps";
          };
        };
    in
    {
      subnet-a = subnet { inherit (secrets) zone; cidr = secrets.cidrBlock; };
    };

  resources.vpcRouteTables =
    {
      route-table =
        { resources, ... }:
        {
          inherit (secrets) region accessKeyId;
          vpcId = resources.vpc.nixops;
        };
    };

  resources.vpcRouteTableAssociations =
    let
      subnets = ["subnet-a"];
      association = subnet:
        { resources, ... }:
        {
          inherit (secrets) region accessKeyId;
          subnetId = resources.vpcSubnets."${subnet}";
          routeTableId = resources.vpcRouteTables.route-table;
        };
    in
      (builtins.listToAttrs (map (s: lib.nameValuePair "association-${s}" (association s) ) subnets));

  resources.vpcRoutes = {
    igw-route =
      { resources, ... }:
      {
        inherit (secrets) region accessKeyId;
        routeTableId = resources.vpcRouteTables.route-table;
        destinationCidrBlock = "0.0.0.0/0";
        gatewayId = resources.vpcInternetGateways.igw;
      };
  };

  resources.vpcInternetGateways.igw =
    { resources, ... }:
    {
      inherit (secrets) region accessKeyId;
      vpcId = resources.vpc.nixops;
    };

  resources.ec2SecurityGroups = {
    ssh-in = { resources, ... }: {
      inherit (secrets) accessKeyId region;
      vpcId = resources.vpc.nixops;
      description = "Allow incoming SSH connection from anywhere";
      rules = [
        {fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "0.0.0.0/0"; }
        # TODO(low): https://github.com/NixOS/nixops/issues/683
        # {fromPort = 22; toPort = 22; protocol = "tcp"; sourceIp = "::/0"; }
      ];
    };
  };

  demeter = { resources, ... }: {
    imports = [ ../hosts/demeter/configuration.nix ];
    deployment = {
      targetEnv = "ec2";
      ec2 = {
        inherit (secrets) accessKeyId ami keyPair region;

        subnetId = resources.vpcSubnets.subnet-a;

        instanceType = "t3.2xlarge";
        ebsInitialRootDiskSize = 1024;
        associatePublicIpAddress = true;

        securityGroupIds = [ resources.ec2SecurityGroups.ssh-in.name ];

        tags = {
          Source = "NixOps";
          Owner = "wael";
        };
      };
    };
  };
}
