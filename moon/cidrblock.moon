bit = require "bit"
lshift = bit.lshift
bnot = bit.bnot
band = bit.band

_M = _VERSION: "0.21"

ip2long = (ip) ->
 if ip == nil
   nil
 o1,o2,o3,o4 = string.match(ip, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
 num = 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
 num


unsign = (bin) ->
  if bin < 0
    return 4294967296 + bin
  return bin


ip_in_cidr = (ip, cidr) ->
  ip_ip = ip2long(ip)
  net, mask = string.match(cidr, "(.*)%/(.*)")
  if net == nil
    net = cidr
  ip_net = ip2long(net)
  if mask
    mask_num = tonumber(mask)
    if mask_num > 32 or mask_num < 0
      return nil, "Invalid prefix: /"..tonumber(mask)
    ip_mask = bnot(lshift(1, 32 - mask) - 1 )
    ip_ip_net = unsign(band(ip_ip, ip_mask))
    return ip_ip_net == ip_net
  else
    return ip_ip == ip_net

ip_in_cidrs = (ip, cidrs) ->
 if type(cidrs) ~= "table"
   nil, "Invalid CIDRs"
 for cidr in ipairs(cidrs) do
   if ip_in_cidr(ip, cidr)
     return true
 false

_M.ip_in_cidrs = ip_in_cidrs
return _M