local FX = require(game.ReplicatedStorage.FX)
local createCone = FX:WaitForChild("Meme").CreateCone
local Effect = require(game.ReplicatedStorage.Effect)

local function CreateCone(part, parent, p)
	local clone = createCone.cone:Clone()
	local model = Instance.new("Model")
	model.Name = "ConeModel"
	model.Parent = parent
	clone.Parent = model
	clone.CFrame = part.CFrame
	clone.Anchored = false
	clone.Weld.Part1 = part
	clone.Weld.Enabled = true
	clone.Weld.C0 *= CFrame.Angles(0, 1.5707963267948966, 0)

	if p then
		clone.Weld.C0 *= p
	end

	model.PrimaryPart = clone
	return {
		Model = model,
		Part = clone,
		SetScale = function(_, p2)
			model:ScaleTo((math.max(p2, 0.05)))
		end,
		Shrink = function(_)
			local position = clone.Position
			model:Destroy()
			task.wait(0.05)
			Effect.new("Chests.Despawn"):play({
				CFrame = CFrame.new(position)
			})
		end
	}
end

return CreateCone