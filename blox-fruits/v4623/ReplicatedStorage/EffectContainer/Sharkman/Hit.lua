local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local position = p.Position

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	local mul = p.Mul or 1
	sound:Play("WaterSplash2", position)

	for _ = 1, _G.FastMode and 4 * mul or 6 * mul do
		local color = math.random() > 0.5 and Color3.fromRGB(110, 153, 202) or Color3.fromRGB(82, 124, 174)
		local v = (15 + math.random() * 10) * mul
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
		specialMesh.Scale = createVector(1, 1, 1) * v
		specialMesh.Parent = part
		part.Parent = _WorldOrigin
		local tween = TweenService:Create(specialMesh, TweenInfo.new(0.15 + math.random() * 0.15), {
			Scale = Vector3.new(),
			Offset = Vector3.new(0, 0, -math.random(30, 45))
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
	end
end