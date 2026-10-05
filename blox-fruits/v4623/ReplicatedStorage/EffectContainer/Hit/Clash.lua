local createVector = vector.create
local util = game.ReplicatedStorage:WaitForChild("Util")
local Debris = require(util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Effect)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function func(p)
	local position = p.Position
	assert(position, "Position not found.")
	local v = p.Long and 13 or 8
	local v2 = p.Long and 1 or 0.5

	for _ = 1, p.Long and 12 or 6 do
		local color = Color3.new(1, 0.6, 0.1)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = CFrame.new(position) * CFrame.Angles(
			3.141592653589793 * (math.random() - 0.5) * 2,
			3.141592653589793 * (math.random() - 0.5) * 2,
			3.141592653589793 * (math.random() - 0.5) * 2
		)
		part.Size = createVector(1, 1, 1)
		part.Color = color
		part.Transparency = 0
		part.Material = "Neon"
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = "Sphere"
		specialMesh.Scale = math.random(1, 2) == 1 and createVector(1, 1, 1) * v2 or Vector3.new(
			1,
			1,
			math.random(10, 14)
		) * v2
		specialMesh.Parent = part
		part.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(specialMesh, TweenInfo.new(0.15 + math.random() * 0.15), {
			Scale = Vector3.new(),
			Offset = Vector3.new(0, 0, -5 - v * (1 + math.random() * 0.5))
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
	end

	local clone = script.Attachments.Clash:Clone()
	clone.Position = position
	clone.Parent = workspace.Terrain
	clone.Ring:Emit(1)

	for _ = 1, 5 do
		local clone2 = script.ClashTrail:Clone()
		clone2.CFrame = CFrame.new(position)
		clone2.Velocity = Vector3.new(math.random() - 0.5, math.random() * 0.8, math.random() - 0.5) * 110
		clone2.Parent = workspace._WorldOrigin
		Debris:AddItem(clone2, 0.5)
	end

	Debris:AddItem(clone, 0.5)
	Sound:Play(p.Long and "LongClash" or "ShortClash", position)
end

return func