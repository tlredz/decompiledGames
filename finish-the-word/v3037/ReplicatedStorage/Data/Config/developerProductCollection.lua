local import = _G.import("collection")
local import2 = _G.import("validUtil")
local MarketplaceService = game:GetService("MarketplaceService")
local v = {}
local v2 = import("DeveloperProduct", script)
v2:require(function(_, p)
	import2.assertFields(p, "Server")
	local module = p.Module
	p.Kind = module.Name
	p.Type = module.Parent.Name
end)

function v2.getProductInfo(_, p)
	return v[tostring(p)] or MarketplaceService:GetProductInfo(p, Enum.InfoType.Product)
end

task.spawn(function()
	for k, _ in pairs(v2.Data) do
		local v3 = string.sub(k, 2)
		local _, result = pcall(function()
			return MarketplaceService:GetProductInfo(tonumber(v3), Enum.InfoType.Product)
		end)

		if result then
			v[v3] = result
		end
	end
end)
return v2