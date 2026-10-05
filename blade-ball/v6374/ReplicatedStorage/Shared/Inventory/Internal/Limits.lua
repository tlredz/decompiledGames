local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
return {
	Sword = 5000,
	Explosion = 5000,
	Emote = 5000,
	Ability = 1000,
	Booth = 1000
}