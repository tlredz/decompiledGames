local ReplicatedStorage = game:GetService("ReplicatedStorage")
local eggLuck = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("EggLuck")
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local EggLuckBillboard = {}
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))

function EggLuckBillboard.FormatLuck(p)
	return PetAging.FormatSpeed(p)
end

function EggLuckBillboard.Attach(parent, p, value)
	if not parent then
		return nil
	end

	local egg = Eggs[p]

	if egg and egg.Luck then
		local eggLuck2 = parent:FindFirstChild("EggLuck")

		if not eggLuck2 then
			eggLuck2 = eggLuck:Clone()
			eggLuck2.Parent = parent
		end

		local v = math.round(egg.Luck * (value or 1))
		eggLuck2.Luck.Text = EggLuckBillboard.FormatLuck(v)
		return eggLuck2
	else
		local eggLuck2 = parent:FindFirstChild("EggLuck")

		if eggLuck2 then
			eggLuck2:Destroy()
		end

		return nil
	end
end

return EggLuckBillboard