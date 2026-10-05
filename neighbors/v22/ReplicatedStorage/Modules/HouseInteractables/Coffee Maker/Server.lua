local CoffeeMaker = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Types)

function CoffeeMaker.Action(p)
	if p.State == false then
		local clone = script.Coffee:Clone()
		clone.Parent = p.Player.Backpack
	end
end

return CoffeeMaker