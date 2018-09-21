##############################################################
#This file creates BE DB servers
##############################################################

#NSG Rules

module "AllowSSHFromInternetBastionIn" {
  #Module source

  source = "github.com/dfrappart/Terra-AZModuletest//Modules//08-2 NSGRule with services tags"

  #Module variable
  RGName                          = "${module.ResourceGroup.Name}"
  NSGReference                    = "${module.NSG_Bastion_Subnet.Name}"
  NSGRuleName                     = "AllowSSHFromInternetBastionIn"
  NSGRulePriority                 = 101
  NSGRuleDirection                = "Inbound"
  NSGRuleAccess                   = "Allow"
  NSGRuleProtocol                 = "Tcp"
  NSGRuleSourcePortRange          = "*"
  NSGRuleDestinationPortRange     = 22
  NSGRuleSourceAddressPrefix      = "Internet"
  NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 2)}"
}

module "AllowAllBastiontoInternetOut" {
  #Module source

  source = "github.com/dfrappart/Terra-AZModuletest//Modules//08-2 NSGRule with services tags"

  #Module variable
  RGName                          = "${module.ResourceGroup.Name}"
  NSGReference                    = "${module.NSG_Bastion_Subnet.Name}"
  NSGRuleName                     = "AllowAllBastiontoInternetOut"
  NSGRulePriority                 = 104
  NSGRuleDirection                = "Outbound"
  NSGRuleAccess                   = "Allow"
  NSGRuleProtocol                 = "*"
  NSGRuleSourcePortRange          = "*"
  NSGRuleDestinationPortRange     = "*"
  NSGRuleSourceAddressPrefix      = "${lookup(var.SubnetAddressRange, 0)}"
  NSGRuleDestinationAddressPrefix = "Internet"
}

#Bastion public IP Creation

module "BastionPublicIP" {
  #Module source

  source = "github.com/dfrappart/Terra-AZModuletest//Modules//10 PublicIP"

  #Module variables
  PublicIPCount       = "1"
  PublicIPName        = "bastionpip"
  PublicIPLocation    = "${var.AzureRegion}"
  RGName              = "${module.ResourceGroup.Name}"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#Availability set creation

module "AS_Bastion" {
  #Module source


  source = "github.com/dfrappart/Terra-AZModuletest//Modules//13 AvailabilitySet"

  #Module variables
  ASName              = "AS_Bastion"
  RGName              = "${module.ResourceGroup.Name}"
  ASLocation          = "${var.AzureRegion}"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#NIC Creation

module "NICs_Bastion" {
  #module source


  source = "github.com/dfrappart/Terra-AZModuletest//Modules//12-1 NICwithPIPwithCount"

  #Module variables

  NICCount            = "1"
  NICName             = "NIC_Bastion"
  NICLocation         = "${var.AzureRegion}"
  RGName              = "${module.ResourceGroup.Name}"
  SubnetId            = "${module.Bastion_Subnet.Id}"
  PublicIPId          = ["${module.BastionPublicIP.Ids}"]
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#Datadisk creation

module "DataDisks_Bastion" {
  #Module source


  source = "github.com/dfrappart/Terra-AZModuletest//Modules//11 ManagedDiskswithcount"

  #Module variables

  Manageddiskcount    = "1"
  ManageddiskName     = "DataDisk_Bastion"
  RGName              = "${module.ResourceGroup.Name}"
  ManagedDiskLocation = "${var.AzureRegion}"
  StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 0)}"
  CreateOption        = "Empty"
  DiskSizeInGB        = "63"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#VM creation

module "VMs_Bastion" {
  #module source


  source = "github.com/dfrappart/Terra-AZModuletest//Modules//14 - 1 LinuxVMWithCount"

  #Module variables

  VMCount             = "1"
  VMName              = "Bastion"
  VMLocation          = "${var.AzureRegion}"
  VMRG                = "${module.ResourceGroup.Name}"
  VMNICid             = ["${module.NICs_Bastion.Ids}"]
  VMSize              = "${lookup(var.VMSize, 0)}"
  ASID                = "${module.AS_Bastion.Id}"
  VMStorageTier       = "${lookup(var.Manageddiskstoragetier, 0)}"
  VMAdminName         = "${var.VMAdminName}"
  VMAdminPassword     = "${var.VMAdminPassword}"
  DataDiskId          = ["${module.DataDisks_Bastion.Ids}"]
  DataDiskName        = ["${module.DataDisks_Bastion.Names}"]
  DataDiskSize        = ["${module.DataDisks_Bastion.Sizes}"]
  VMPublisherName     = "${lookup(var.PublisherName, 2)}"
  VMOffer             = "${lookup(var.Offer, 2)}"
  VMsku               = "${lookup(var.sku, 2)}"
  DiagnosticDiskURI   = "${module.DiagStorageAccount.PrimaryBlobEP}"
  PublicSSHKey        = "${var.AzurePublicSSHKey}"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

module "NetworkWatcherAgentForBastion" {
  #Module Location

  source = "github.com/dfrappart/Terra-AZModuletest//Modules//20 LinuxNetworkWatcherAgent"

  #Module variables
  AgentCount          = "1"
  AgentName           = "NetworkWatcherAgentForBastion"
  AgentLocation       = "${var.AzureRegion}"
  AgentRG             = "${module.ResourceGroup.Name}"
  VMName              = ["${module.VMs_Bastion.Name}"]
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}
