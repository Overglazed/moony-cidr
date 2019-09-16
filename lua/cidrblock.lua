local bit = require("bit")
local lshift = bit.lshift
local bnot = bit.bnot
local band = bit.band
local _M = {
  _VERSION = "0.21"
}
local ip2long
ip2long = function(ip)
  if ip == nil then
    local _ = nil
  end
  local o1, o2, o3, o4 = string.match(ip, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
  local num = 2 ^ 24 * o1 + 2 ^ 16 * o2 + 2 ^ 8 * o3 + o4
  return num
end
local unsign
unsign = function(bin)
  if bin < 0 then
    return 4294967296 + bin
  end
  return bin
end
local ip_in_cidr
ip_in_cidr = function(ip, cidr)
  local ip_ip = ip2long(ip)
  local net, mask = string.match(cidr, "(.*)%/(.*)")
  if net == nil then
    net = cidr
  end
  local ip_net = ip2long(net)
  if mask then
    local mask_num = tonumber(mask)
    if mask_num > 32 or mask_num < 0 then
      return nil, "Invalid prefix: /" .. tonumber(mask)
    end
    local ip_mask = bnot(lshift(1, 32 - mask) - 1)
    local ip_ip_net = unsign(band(ip_ip, ip_mask))
    return ip_ip_net == ip_net
  else
    return ip_ip == ip_net
  end
end
local ip_in_cidrs
ip_in_cidrs = function(ip, cidrs)
  if type(cidrs) ~= "table" then
    local _ = nil, "Invalid CIDRs"
  end
  for cidr in ipairs(cidrs) do
    if ip_in_cidr(ip, cidr) then
      return true
    end
  end
  return false
end
_M.ip_in_cidrs = ip_in_cidrs
return _M