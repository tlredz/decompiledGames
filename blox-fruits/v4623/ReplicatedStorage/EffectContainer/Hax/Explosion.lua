local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local function quickExplosion(p)
	if not p.Root then
		return
	end

	local position = p.Root.Position
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	Sound:Play("ExplosionHeavyFast", position)
	local folder = Instance.new("Folder")
	folder.Name = "QuickExplosion"
	folder.Parent = workspace._WorldOrigin
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 128, 0)
	part.Transparency = 0.15
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Parent = folder
	TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(36, 36, 36),
		Transparency = 1
	}):Play()

	for i = 1, 7 do
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.Material = Enum.Material.Neon
		part2.Color = Color3.fromRGB(255, math.random(0, 125), 0)
		part2.Transparency = 0.35
		part2.Size = createVector(1, 1, 1)
		part2.CFrame = CFrame.new(position)
		part2.Parent = folder
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.FileMesh
		specialMesh.MeshId = "rbxassetid://20329976"
		specialMesh.Scale = createVector(0, 0, 0)
		specialMesh.Parent = part2
		local v = math.rad((i - 1) / 7 * 360 + math.random(-18, 18))
		local v2 = math.rad((math.random(-25, 25)))
		local v3 = math.random(6, 11)
		local v4 = CFrame.Angles(0, v, 0) * CFrame.Angles(v2, 0, 0) * CFrame.new(0, 0, -v3)
		local cFrame = CFrame.new(position) * CFrame.Angles(
			math.rad((math.random(-40, 40))),
			math.rad((math.random(0, 360))),
			(math.rad((math.random(-40, 40))))
		) * v4
		local v6 = math.random(8, 14) / 10
		TweenService:Create(specialMesh, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = createVector(8, 12, 8) * v6
		}):Play()
		TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame,
			Transparency = 1
		}):Play()
		task.delay(0.08, function()
			TweenService:Create(specialMesh, TweenInfo.new(0.37, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(16, 20, 16) * v6
			}):Play()
		end)
	end

	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.Shape = Enum.PartType.Ball
	part2.Material = Enum.Material.Neon
	part2.Color = Color3.fromRGB(255, 0, 0)
	part2.Transparency = 0.5
	part2.Size = createVector(1, 0.3, 1)
	part2.CFrame = CFrame.new(position)
	part2.Parent = folder
	TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(18, 0.2, 18),
		Transparency = 1
	}):Play()
	Debris:AddItem(folder, 1)
end

return quickExplosion