#!/usr/bin/env sh
# shellcheck disable=SC2034
dns_Technitium_info='Technitium DNS Server

Site: https://technitium.com/dns/
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi2#dns_technitium
Options:
 Technitium_Server Server Address
 Technitium_Token API Token
Issues: github.com/acmesh-official/acme.sh
Author: Henning Reich <acmesh@qupfer.de>
'

#This file name is "dns_myapi.sh"
#So, here must be a method   dns_myapi_add()
#Which will be called by acme.sh to add the txt record to your api system.
#returns 0 means success, otherwise error.

########  Public functions #####################

# Please Read this guide first: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Dev-Guide

#Usage: dns_myapi_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_technitium_add() {
  fulldomain=$1
  txtvalue=$2
  _Technitium_account
  _info "Using Technitium"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  response="$(_get "$Technitium_Server/api/zones/records/add?token=$Technitium_Token&domain=$fulldomain&type=TXT&text=${txtvalue}")"
  if _contains "$response" '"status":"ok"'; then
    return 0
  fi
  _err "Could not add txt record."
  return 1
}

#Usage: fulldomain txtvalue
#Remove the txt record after validation.
dns_technitium_rm() {
  fulldomain=$1
  txtvalue=$2
  _info "Using Technitium"
  response="$(_get "$Technitium_Server/api/zones/records/delete?token=$Technitium_Token&domain=$fulldomain&type=TXT&text=${txtvalue}")"
  if _contains "$response" '"status":"ok"'; then
    return 0
  fi
  _err "Could not remove txt record"
  return 1
}

####################  Private functions below ##################################

_Technitium_account() {
  Technitium_Server="${Technitium_Server:-$(_readaccountconf_mutable Technitium_Server)}"
  Technitium_Token="${Technitium_Token:-$(_readaccountconf_mutable Technitium_Token)}"
  if [ -z "$Technitium_Server" ] || [ -z "$Technitium_Token" ]; then
    Technitium_Server=""
    Technitium_Token=""
    _err "You don't specify Technitium Server and Token yet."
    _err "Please create your Token and add server address and try again."
    return 1
  fi

  #save the credentials to the account conf file.
  _saveaccountconf_mutable Technitium_Server "$Technitium_Server"
  _saveaccountconf_mutable Technitium_Token "$Technitium_Token"
}