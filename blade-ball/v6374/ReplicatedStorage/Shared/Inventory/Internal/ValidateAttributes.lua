local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(script.Parent.Parent.InventoryTypes)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = {
	Id = "string",
	Name = "string",
	TradeLock = "table",
	Serial = "number",
	CreatedAt = "number"
}
local v3 = {
	Sword = {
		Accessory = "boolean",
		Finisher = "boolean",
		Kills = "number"
	},
	Ability = {
		Upgrade = "number"
	}
}

local function validateAttributes(p, items)
	local v4 = v3[p] or {}

	for k, item in items do
		if item == v.None then
			continue
		end

		if not (v2[k] or v4[k]) then
			warn((`Unsupported attribute {k} for {p}!`))
			return false
		end

		if v2[k] and v2[k] ~= typeof(item) then
			warn((`Invalid attribute {k} - expected {v2[k]}, received {typeof(item)} ({item})!`))
			return false
		end

		if not (v4[k] and v4[k] ~= typeof(item)) then
			continue
		end

		warn((`Invalid attribute {k} - expected {v4[k]}, received {typeof(item)} ({item})!`))
		return false
	end

	return true
end

return validateAttributes