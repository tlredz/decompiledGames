local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)

local function assertRoles(items)
	assert(type(items) == "table")

	for k, item in items do
		local v

		if type(k) == "string" then
			v = tonumber(k) and tonumber(k) % 1 == 0
		else
			v = false
		end

		assert(v)
		assert(item == "Owner" or item == "Admin" or item == "Developer")
	end

	return items
end

local v = {
	Enabled = FastFlags.Replicated("Game.Staff.TagsEnabled", Asserts.Boolean, true),
	Roles = FastFlags.Replicated("Game.Staff.TagRoles", assertRoles, {
		["3889785873"] = "Admin",
		["10751598093"] = "Owner",
		["2735356267"] = "Owner",
		["4613024122"] = "Owner",
		["1927880506"] = "Owner",
		["2790707588"] = "Owner",
		["89659291"] = "Developer",
		["82806501"] = "Developer",
		["14277028"] = "Developer",
		["37474696"] = "Developer",
		["23370881"] = "Developer"
	})
}
local bindableEvent = Instance.new("BindableEvent")
v.Enabled.Changed:Connect(function()
	bindableEvent:Fire()
end)
v.Roles.Changed:Connect(function()
	bindableEvent:Fire()
end)
v.Changed = bindableEvent.Event
return table.freeze(v)