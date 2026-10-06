local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
return function(data, _)
	local _ = data.char
	local target = data.target

	for i = 1, 3 do
		local child = target:FindFirstChild("AT" .. i, true)
		local clone = replicatedStorage.Chest.FruitEffect.String.webshoot:Clone()
		clone.CFrame = data.att.WorldCFrame
		clone.Parent = target
		local manualWeld = Instance.new("ManualWeld")
		manualWeld.Parent = clone
		manualWeld.Part0 = data.att.Parent
		manualWeld.Part1 = clone
		task.spawn(function()
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript(data.att, child)
		end)
	end

	local clone = replicatedStorage.Chest.FruitEffect.String.CloneFX:Clone()
	clone.Parent = workspace.Effects
	clone:SetPrimaryPartCFrame(target.PrimaryPart.CFrame)
	local ModuleScript = require(clone.ModuleScript)
	ModuleScript()
	_G.PU:Dust(clone, 5)
end