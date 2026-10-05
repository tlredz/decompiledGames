local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Gears = require(ReplicatedStorage.Shared.Gears)
local v = {}

for _, v2 in Gears.TradableOrder do
	table.insert(v, v2)
end

return Conch.register_type("Gear", Conch.args.enum_new(v))