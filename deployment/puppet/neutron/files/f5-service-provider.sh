#!/bin/bash

neutron_cfg=/etc/neutron/neutron.conf

#old_f5_pprovider=$(grep '^service_provider=LOADBALANCER:F5' /etc/neutron/neutron.conf)
old_f5_provider=$(grep '^service_provider=LOADBALANCER:F5' $neutron_cfg)

if [[ -z $old_f5_provider ]]; then
  ## should set service_provider
  echo "service_provider for LOADBALANCER:F5 is not defined"
  echo "Need to configure service_provider for LOADBALANCER:F5"
  exit 0
else
  echo "service_provider for LOADBALANCER:F5 EXISTS"
  echo $old_f5_provider
  exit 1
fi
