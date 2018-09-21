##############################################################
#This file creates BE DB servers
##############################################################

#NSG Rules

module "AllowSSHFromBastiontoBEIn" {
  #Module source

  source = "github.com/dfrappart/Terra-AZModuletest//Modules//08-2 NSGRule with services tags"

  #Module variable
  RGName                          = "${module.ResourceGroup.Name}"
  NSGReference                    = "${module.NSG_BE_Subnet.Name}"
  NSGRuleName                     = "AllowSSHFromBastiontoBEIn"
  NSGRulePriority                 = 102
  NSGRuleDirection                = "Inbound"
  NSGRuleAccess                   = "Allow"
  NSGRuleProtocol                 = "Tcp"
  NSGRuleSourcePortRange          = "*"
  NSGRuleDestinationPortRange     = 22
  NSGRuleSourceAddressPrefix      = "${lookup(var.SubnetAddressRange, 2)}"
  NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 1)}"
}

module "AllowAllBEtoInternetOut" {
  #Module source

  source = "github.com/dfrappart/Terra-AZModuletest//Modules//08-2 NSGRule with services tags"

  #Module variable
  RGName                          = "${module.ResourceGroup.Name}"
  NSGReference                    = "${module.NSG_BE_Subnet.Name}"
  NSGRuleName                     = "AllowAllBEtoInternetOut"
  NSGRulePriority                 = 103
  NSGRuleDirection                = "Outbound"
  NSGRuleAccess                   = "Allow"
  NSGRuleProtocol                 = "*"
  NSGRuleSourcePortRange          = "*"
  NSGRuleDestinationPortRange     = "*"
  NSGRuleSourceAddressPrefix      = "${lookup(var.SubnetAddressRange, 1)}"
  NSGRuleDestinationAddressPrefix = "Internet"
}

#Availability set creation

module "AS_BE" {
  #Module source

  #source = "./Modules/13 AvailabilitySet"
  source = "github.com/dfrappart/Terra-AZModuletest//Modules//13 AvailabilitySet"

  #Module variables
  ASName              = "AS_BE"
  RGName              = "${module.ResourceGroup.Name}"
  ASLocation          = "${var.AzureRegion}"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#NIC Creation

module "NICs_BE" {
  #module source


  source = "github.com/dfrappart/Terra-AZModuletest//Modules//12-2 NICwithoutPIPwithCount"

  #Module variables

  NICcount            = "2"
  NICName             = "NIC_BE"
  NICLocation         = "${var.AzureRegion}"
  RGName              = "${module.ResourceGroup.Name}"
  SubnetId            = "${module.BE_Subnet.Id}"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#Datadisk creation

module "DataDisks_BE" {
  #Module source


  source = "github.com/dfrappart/Terra-AZModuletest//Modules//11 ManagedDiskswithcount"

  #Module variables

  Manageddiskcount    = "2"
  ManageddiskName     = "DataDisk_BE"
  RGName              = "${module.ResourceGroup.Name}"
  ManagedDiskLocation = "${var.AzureRegion}"
  StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 1)}"
  CreateOption        = "Empty"
  DiskSizeInGB        = "127"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}

#VM creation

module "VMs_BE" {
  #module source

  #source = "./Modules/14 LinuxVMWithCount"
  source = "github.com/dfrappart/Terra-AZModuletest//Modules//14 - 1 LinuxVMWithCount"

  #Module variables

  VMCount             = "2"
  VMName              = "BE"
  VMLocation          = "${var.AzureRegion}"
  VMRG                = "${module.ResourceGroup.Name}"
  VMNICid             = ["${module.NICs_BE.Ids}"]
  VMSize              = "${lookup(var.VMSize, 1)}"
  ASID                = "${module.AS_BE.Id}"
  VMStorageTier       = "${lookup(var.Manageddiskstoragetier, 1)}"
  VMAdminName         = "${var.VMAdminName}"
  VMAdminPassword     = "${var.VMAdminPassword}"
  DataDiskId          = ["${module.DataDisks_BE.Ids}"]
  DataDiskName        = ["${module.DataDisks_BE.Names}"]
  DataDiskSize        = ["${module.DataDisks_BE.Sizes}"]
  VMPublisherName     = "${lookup(var.PublisherName, 2)}"
  VMOffer             = "${lookup(var.Offer, 2)}"
  VMsku               = "${lookup(var.sku, 2)}"
  DiagnosticDiskURI   = "${module.DiagStorageAccount.PrimaryBlobEP}"
  PublicSSHKey        = "${var.AzurePublicSSHKey}"
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
  PasswordDisabled    = "false"
}

#VM Agent

#Network Watcher Agent

module "NetworkWatcherAgentForBEDB" {
  #Module Location
  #source = "./Modules/20 LinuxNetworkWatcherAgent"
  source = "github.com/dfrappart/Terra-AZModuletest//Modules//20 LinuxNetworkWatcherAgent"

  #Module variables
  AgentCount          = "2"
  AgentName           = "NetworkWatcherAgentForBE"
  AgentLocation       = "${var.AzureRegion}"
  AgentRG             = "${module.ResourceGroup.Name}"
  VMName              = ["${module.VMs_BE.Name}"]
  EnvironmentTag      = "${var.EnvironmentTag}"
  EnvironmentUsageTag = "${var.EnvironmentUsageTag}"
}
