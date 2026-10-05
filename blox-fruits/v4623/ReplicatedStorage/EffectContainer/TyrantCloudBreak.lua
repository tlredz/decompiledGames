local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(78, 46, 138)
return function(instance)
	local cFrame = instance.CFrame

	if typeof(cFrame) ~= "CFrame" then
		return
	end

	local v = typeof(instance.Size) ~= "Vector3" and createVector(48, 16, 48) or instance.Size
	local v2 = math.max(v.X, v.Z) * 0.5
	local folder = Instance.new("Folder")
	folder.Name = "TyrantCloudBreak"
	folder.Parent = workspace.CurrentCamera
	Debris:AddItem(folder, 1.45)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.25
	part.Size = createVector(1, 1, 1) * (v2 * 0.4)
	part.CFrame = cFrame
	part.Parent = folder
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 6
	pointLight.Range = v2 * 2.5
	pointLight.Parent = part
	TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = createVector(1, 1, 1) * v2 * 1.8
	}):Play()
	TweenService:Create(pointLight, TweenInfo.new(0.45), {
		Brightness = 0
	}):Play()
end