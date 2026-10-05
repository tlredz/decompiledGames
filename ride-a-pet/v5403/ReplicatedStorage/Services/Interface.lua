local services = game.ReplicatedStorage.Services
local String = require(services:WaitForChild("String"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = {}
local Interface = {}

function Interface.StartTextCooldown(_, p: string, p2: number)
	local serverTimeNow = workspace:GetServerTimeNow()

	if not v[p] then
		v[p] = {}
	end

	for _, v2 in CollectionService:GetTagged("CooldownLabel") do
		if v[p][v2] then
			v[p][v2]:Disconnect()
			v[p][v2] = nil
		end

		if not (v2.Name == p or v2.Parent.Name == p) then
			continue
		end

		if not v2:GetAttribute("OriginalText") then
			v2:SetAttribute("OriginalText", v2.Text)
		end

		local renderSteppedConnection = nil
		local v3 = v2
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v4 = p2 - (workspace:GetServerTimeNow() - serverTimeNow)

			if v4 <= 0 then
				v[p][v3] = nil
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
				v3.TextColor3 = Color3.fromRGB(255, 255, 255)
				v3.Text = v3:GetAttribute("OriginalText")
			else
				v3.TextColor3 = Color3.fromRGB(255, 0, 0)
				v3.Text = string.format("%ss", String:FormatDecimal(v4, 1))
			end
		end)
		v[p][v2] = renderSteppedConnection
	end
end

function Interface.ScrollItemToTop(_, p)
	local parent = p.Parent
	local v2 = p.AbsolutePosition.Y - parent.AbsolutePosition.Y + parent.CanvasPosition.Y
	local total = 0
	local uIPadding = parent:FindFirstChildOfClass("UIPadding")

	if uIPadding then
		total += uIPadding.PaddingTop.Offset + uIPadding.PaddingTop.Scale * parent.AbsoluteSize.Y
	end

	local v3 = math.clamp(v2 - total, 0, (math.max(0, parent.AbsoluteCanvasSize.Y - parent.AbsoluteSize.Y)))
	TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(parent.CanvasPosition.X, v3)
	}):Play()
end

function Interface.OffsetToScale(_, udim: UDim2)
	local viewportSize = workspace.Camera.ViewportSize
	return UDim2.fromScale(udim.X.Offset / viewportSize.X, udim.Y.Offset / viewportSize.Y)
end

function Interface.ShowObjectInViewport(_, instance, parent, options)
	for _, child in parent:GetChildren() do
		child:Destroy()
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = parent
	local v2 = options or {}
	local rotated = v2.Rotated
	local cameraCFrame = v2.CameraCFrame
	local adjustment = v2.Adjustment
	local clone = instance:Clone()

	if game.ReplicatedStorage.Assets.Brainrots:FindFirstChild(clone.Name, true) then
		clone:AddTag("Brainrot")
	end

	clone.Parent = worldModel

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	local primaryPart = clone.PrimaryPart or clone:WaitForChild("HumanoidRootPart", 1) or clone:WaitForChild(
		"Handle",
		1
	)

	if primaryPart then
		primaryPart.Anchored = true
	end

	local camera = Instance.new("Camera")
	camera.Parent = parent
	camera.FieldOfView = 70
	camera.CFrame = cameraCFrame

	if adjustment then
		camera.CFrame *= CFrame.new(0, 0, -adjustment)
	end

	if rotated == true then
		camera.CFrame *= CFrame.Angles(0, 0, -0.7853981633974483)
		camera.CFrame *= CFrame.new(0, 0, -1)
	end

	parent.CurrentCamera = camera
	return clone
end

return Interface