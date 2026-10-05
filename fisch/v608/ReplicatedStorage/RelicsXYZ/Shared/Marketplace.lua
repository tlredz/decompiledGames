local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = script.Parent.Parent.Packages
local Marketplace = require(packages.Marketplace)
Marketplace.AddMockEconomyCheck("RelicsDemoPlace", function()
	return ReplicatedStorage:HasTag("__RELICSXYZ_DEMO_PLACE_INTERNAL_ONLY__")
end)
return Marketplace