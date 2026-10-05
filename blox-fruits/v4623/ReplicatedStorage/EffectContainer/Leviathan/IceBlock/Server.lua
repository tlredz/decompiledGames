local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
return function(p)
	local HRP = p.HRP

	if HRP then
		local clone = FX:WaitForChild("Leviathan").IceBlock.IceBlock:Clone()
		clone.Transparency = 0.5
		clone.Size = clone.Size * createVector(1, 1.3, 1) * (p.HRP.Size.X / 2)
		clone.CanCollide = false
		clone.CanQuery = false
		clone.Anchored = false
		clone.Massless = true
		clone.IceFlakes.Enabled = false
		clone.Parent = HRP
		local weld = Instance.new("Weld", clone)
		weld.Part0 = p.HRP
		weld.Part1 = clone
		local objectValue = Instance.new("ObjectValue", HRP.Parent)
		objectValue.Name = "IceBlock"
		objectValue.Value = clone
		p.IceBlock = objectValue
		objectValue.Changed:Once(function()
			task.delay(5, function()
				clone:Destroy()
				objectValue:Destroy()
			end)
		end)
	end
end