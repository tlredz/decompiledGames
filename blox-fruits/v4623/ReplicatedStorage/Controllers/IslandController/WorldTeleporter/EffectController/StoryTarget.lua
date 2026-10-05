local createVector = vector.create
local Players = game:GetService("Players")
local color = Color3.fromRGB(215, 197, 154)
local color2 = Color3.fromRGB(58, 118, 196)
local color3 = Color3.fromRGB(64, 66, 92)
local v = {
	{
		Name = "Head",
		Size = createVector(2, 1, 1),
		Offset = createVector(0, 1.5, 0),
		Color = color
	},
	{
		Name = "Torso",
		Size = createVector(2, 2, 1),
		Offset = createVector(0, 0, 0),
		Color = color2
	},
	{
		Name = "Left Arm",
		Size = createVector(1, 2, 1),
		Offset = createVector(-1.5, 0, 0),
		Color = color
	},
	{
		Name = "Right Arm",
		Size = createVector(1, 2, 1),
		Offset = createVector(1.5, 0, 0),
		Color = color
	},
	{
		Name = "Left Leg",
		Size = createVector(1, 2, 1),
		Offset = createVector(-0.5, -2, 0),
		Color = color3
	},
	{
		Name = "Right Leg",
		Size = createVector(1, 2, 1),
		Offset = createVector(0.5, -2, 0),
		Color = color3
	}
}

function buildPart(name: string, size: Vector3, cFrame: CFrame, color4: Color3, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cFrame
	part.Color = color4
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function getStandCFrame(pVInstance)
	local teleporterVFX = pVInstance:FindFirstChild("TeleporterVFX")
	local base

	if teleporterVFX then
		base = teleporterVFX:FindFirstChild("Base")
	else
		base = pVInstance:FindFirstChild("Base", true)
	end

	local position = createVector(0, 0, 0)

	if base and base:IsA("BasePart") then
		position = base.CFrame.Position + Vector3.new(0, base.Size.Y / 2, 0)
	elseif pVInstance:IsA("PVInstance") then
		position = pVInstance:GetPivot().Position
	end

	local v2 = position + createVector(0, 3, 0)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return CFrame.new(v2.X, v2.Y, v2.Z)
	end

	local position2 = currentCamera.CFrame.Position
	local vector2 = Vector3.new(position2.X, v2.Y, position2.Z)

	if (vector2 - v2).Magnitude < 0.01 then
		return CFrame.new(v2.X, v2.Y, v2.Z)
	end

	return CFrame.lookAt(v2, vector2)
end

function clearLeftovers()
	for _, child in workspace:GetChildren() do
		if child.Name == "WorldTeleporterDebugDummy" then
			child:Destroy()
		end
	end
end

function buildDummy(p)
	clearLeftovers()
	local standCFrame = getStandCFrame(p)
	local model = Instance.new("Model")
	model.Name = "WorldTeleporterDebugDummy"
	local part = buildPart("HumanoidRootPart", createVector(2, 2, 1), standCFrame, color2, model)
	part.Transparency = 1
	model.PrimaryPart = part

	for _, v2 in v do
		local part2 = buildPart(
			v2.Name,
			v2.Size,
			standCFrame * CFrame.new(v2.Offset.X, v2.Offset.Y, v2.Offset.Z),
			v2.Color,
			model
		)

		if v2.Name ~= "Head" then
			continue
		end

		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Head
		specialMesh.Scale = createVector(1.25, 1.25, 1.25)
		specialMesh.Parent = part2
	end

	model.Parent = workspace
	return model
end

return {
	get = function(instance)
		local player = instance:FindFirstChild("Player") or Players.LocalPlayer and Players.LocalPlayer.Character

		if player then
			return player, function() end
		end

		warn((`no "Player" model inside {instance:GetFullName()} and no local character, using a debug dummy`))
		local dummy = buildDummy(instance)
		return dummy, function()
			dummy:Destroy()
		end
	end
}