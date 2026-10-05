local Util = {}
local module = require("./Config")

function Util.GetDefaultValue(_, p: string)
	if module[p] then
		return module[p].DefaultValue
	end

	return nil
end

function Util.GetConfigData(_, p: string)
	return module[p]
end

function Util:GetValueOrDefault(p, p2)
	if p == nil then
		return p2
	end

	return p
end

function Util.ParseValue(_, p: string, p2)
	local v = module[p]

	if not v then
		return p2
	end

	if v.Options and not table.find(v.Options, p2) then
		return v.DefaultValue
	end

	return Util:GetValueOrDefault(p2, v.DefaultValue)
end

return Util