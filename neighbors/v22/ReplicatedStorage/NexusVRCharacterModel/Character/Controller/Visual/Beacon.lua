local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Beacon = {}
Beacon.__index = Beacon

function Beacon.new()
	setmetatable({}, Beacon)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Size = createVector(0.5, 0.5, 0.5)
	part.Shape = Enum.PartType.Ball
	part.Parent = Workspace.CurrentCamera
	local imageHandleAdornment = Instance.new("ImageHandleAdornment")
	imageHandleAdornment.Adornee = part
	imageHandleAdornment.Size = Vector2.new(2, 2)
	imageHandleAdornment.Image = "rbxasset://textures/ui/VR/VRPointerDiscBlue.png"
	imageHandleAdornment.Visible = false
	imageHandleAdornment.Parent = part
	local imageHandleAdornment2 = Instance.new("ImageHandleAdornment")
	imageHandleAdornment2.Adornee = part
	imageHandleAdornment2.Size = Vector2.new(2, 2)
	imageHandleAdornment2.Image = "rbxasset://textures/ui/VR/VRPointerDiscBlue.png"
	imageHandleAdornment2.Visible = false
	imageHandleAdornment2.Parent = part
	return (setmetatable({
		Sphere = part,
		ConstantRing = imageHandleAdornment,
		MovingRing = imageHandleAdornment2
	}, Beacon))
end

function Beacon.Update(data, cframe: CFrame, instance)
	local v = -math.cos(tick() * 2 * 2) / 8 + 0.4
	local v2 = 2 * (tick() * 2 % 3.141592653589793) / 3.141592653589793
	data.Sphere.CFrame = cframe * CFrame.new(0, v, 0)
	data.ConstantRing.CFrame = CFrame.new(0, -v, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	data.MovingRing.CFrame = CFrame.new(0, -v, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	data.MovingRing.Transparency = v2 / 2
	data.MovingRing.Size = Vector2.new(v2, v2)
	local color = Color3.fromRGB(0, 170, 0)

	if instance then
		local vRBeaconColor = instance:FindFirstChild("VRBeaconColor")

		if vRBeaconColor then
			color = vRBeaconColor.Value
		elseif (instance:IsA("Seat") or instance:IsA("VehicleSeat")) and not instance.Disabled then
			color = Color3.fromRGB(0, 170, 255)
		end
	end

	data.Sphere.Color = color
	data.Sphere.Transparency = 0
	data.ConstantRing.Visible = true
	data.MovingRing.Visible = true
end

function Beacon.Hide(data)
	data.Sphere.Transparency = 1
	data.ConstantRing.Visible = false
	data.MovingRing.Visible = false
end

function Beacon:Destroy()
	self.Sphere:Destroy()
end

return Beacon