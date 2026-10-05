local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local v = {}

for k in Assets.Directory do
	table.insert(v, k)
end

table.sort(v)
local v2 = {}
local displayNames = {}

for _, v3 in v do
	local displayName = Assets.Directory[v3].DisplayName

	if not (type(displayName) == "string" and displayName ~= "" and v2[displayName] == nil) then
		continue
	end

	v2[displayName] = v3
	table.insert(displayNames, displayName)
end

for _, _ in v do

end

table.sort(displayNames)
return function(registry)
	local enumType = registry.Cmdr.Util.MakeEnumType("AssetDisplayName", displayNames)
	registry:RegisterType("assetDisplayName", {
		Validate = enumType.Validate,
		Autocomplete = enumType.Autocomplete,
		Parse = function(p)
			return v2[enumType.Parse(p)]
		end
	})
end