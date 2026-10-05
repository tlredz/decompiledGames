local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = nil

local function build(parent)
	local sammyPortraitRig = ReplicatedStorage.Assets.UI.Notifs:FindFirstChild("SammyPortraitRig")

	if not sammyPortraitRig then
		return nil
	end

	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "SammyViewport"
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.Ambient = Color3.fromRGB(180, 205, 180)
	viewportFrame.LightColor = Color3.fromRGB(217, 255, 212)
	viewportFrame.LightDirection = createVector(-1, -0.4, -1)
	viewportFrame.ZIndex = 6
	viewportFrame.Parent = parent
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local clone = sammyPortraitRig:Clone()
	clone.Parent = worldModel
	clone:PivotTo(CFrame.identity)
	local head = clone:FindFirstChild("Head")
	local vector2 = Vector3.new(0, not head and 6.2 or head.Position.Y + 0.2, 0)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 24
	camera.CFrame = CFrame.lookAt(vector2 + createVector(0, 2.4, -32), vector2)
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local track = nil
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local animator

	if humanoid then
		animator = humanoid:FindFirstChildOfClass("Animator")
	else
		animator = nil
	end

	local idle = clone:FindFirstChild("Idle")

	if animator and idle and idle:IsA("Animation") then
		local success, result = pcall(function()
			return animator:LoadAnimation(idle)
		end)

		if success then
			result.Looped = true
			result.Priority = Enum.AnimationPriority.Idle
			track = result
		end
	end

	viewportFrame.Destroying:Connect(function()
		if v and v.Viewport == viewportFrame then
			v = nil
		end
	end)
	return {
		Viewport = viewportFrame,
		Model = clone,
		Track = track,
		Owner = parent
	}
end

return {
	Mount = function(p)
		if not v then
			v = build(p)
		end

		local v2 = v

		if not v2 then
			return function() end, function() end
		end

		v2.Owner = p
		v2.Viewport.Parent = p
		v2.Viewport.Visible = true
		v2.Model:PivotTo(CFrame.Angles(0, -1.7453292519943295, 0))

		if v2.Track then
			v2.Track:Play(0.15, 1, 0.8)
		end

		local flag = false

		local function step(p2: number)
			if flag or v2.Owner ~= p then
				return
			end

			local v3 = math.clamp(p2 / 0.62, 0, 1)
			local v4 = v3 - 1
			local v5 = (1 - (v4 * 2.15 * v4 * v4 + 1 + v4 * 1.15 * v4)) * -100

			if v3 >= 1 then
				v5 = math.sin((p2 - 0.62) * 0.8) * 2
			end

			v2.Model:PivotTo(CFrame.Angles(0, math.rad(v5), 0))
		end

		local function stop()
			if flag then
				return
			end

			flag = true

			if v2.Owner ~= p then
				return
			end

			if v2.Track then
				v2.Track:Stop(0)
			end

			v2.Viewport.Visible = false
			v2.Viewport.Parent = nil
			v2.Owner = nil
		end

		return step, stop
	end
}