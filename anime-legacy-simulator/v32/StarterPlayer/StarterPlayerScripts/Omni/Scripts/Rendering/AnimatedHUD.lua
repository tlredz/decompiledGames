local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local currentCamera = workspace.CurrentCamera
local playerGui = module.Instance:WaitForChild("PlayerGui")
local v = {}
local v2 = 0
local v3 = nil
local freecamEnabledChangedConnection = nil
local v4 = false
local v5 = nil
local v6 = nil
local AnimatedHUD = {}

local function GetTitleReference()
	if v5 and v5.Parent then
		return v5
	end

	local frames = module.Interface:FindFirstChild("Frames")

	if not frames then
		return
	end

	local frame = Instance.new("Frame")
	frame.Name = "Emitter2DTitleReference"
	frame.Size = frames.Size
	frame.SizeConstraint = frames.SizeConstraint
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Archivable = false
	frame.Parent = module.Interface
	local parent = frame

	for _, childName in {
		"Profile",
		"Main",
		"Profile",
		"Title"
	} do
		frames = frames:FindFirstChild(childName)

		if not (frames and frames:IsA("GuiObject")) then
			frame:Destroy()
			return
		end

		local frame2 = Instance.new("Frame")
		frame2.Name = childName
		frame2.Size = frames.Size
		frame2.SizeConstraint = frames.SizeConstraint
		frame2.BackgroundTransparency = 1
		frame2.Interactable = false
		local uIAspectRatioConstraint = frames:FindFirstChildWhichIsA("UIAspectRatioConstraint")

		if uIAspectRatioConstraint then
			local clone = uIAspectRatioConstraint:Clone()
			clone.Parent = frame2
		end

		frame2.Parent = parent
		parent = frame2
	end

	v6 = frame
	v5 = parent
	return v5
end

local function IsValidSize(udim: UDim2)
	local v7 = udim.X.Scale + udim.X.Offset
	local v8 = udim.Y.Scale + udim.Y.Offset
	return v7 > 0 and v8 > 0
end

local function WaitForValidSize(billboardGui)
	local size = billboardGui:GetAttribute("Size") or billboardGui.Size
	local v7 = size.X.Scale + size.X.Offset
	local v8 = size.Y.Scale + size.Y.Offset
	local v9

	if v7 > 0 then
		v9 = v8 > 0
	else
		v9 = false
	end

	if v9 then
		return size
	end

	local lastTime = os.clock()

	while os.clock() - lastTime < 5 do
		local size2 = billboardGui:GetAttribute("Size") or billboardGui.Size
		local v10 = size2.X.Scale + size2.X.Offset
		local v11 = size2.Y.Scale + size2.Y.Offset
		local v12

		if v10 > 0 then
			v12 = v11 > 0
		else
			v12 = false
		end

		if v12 then
			return billboardGui.Size
		else
			task.wait()
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetAdorneePosition(adornee)
	if not adornee then
		return
	end

	if adornee:IsA("BasePart") then
		return adornee.Position
	end

	if adornee:IsA("Model") then
		return adornee:GetPivot().Position
	end

	return nil
end

function AnimatedHUD.RefreshFreecam()
	local freecam = playerGui:FindFirstChild("Freecam")
	local freecamScript = freecam and freecam:FindFirstChild("FreecamScript")

	if freecamScript ~= v3 then
		if freecamEnabledChangedConnection then
			freecamEnabledChangedConnection:Disconnect()
			freecamEnabledChangedConnection = nil
		end

		v3 = freecamScript

		if v3 then
			freecamEnabledChangedConnection = v3:GetAttributeChangedSignal("FreecamEnabled"):Connect(AnimatedHUD.RefreshFreecam)
		end
	end

	local v7

	if v3 == nil then
		v7 = false
	else
		v7 = v3:GetAttribute("FreecamEnabled") == true
	end

	if v4 == v7 then
		return
	end

	v4 = v7

	if not v4 then
		return
	end

	for k, v8 in v do
		k.Enabled = false
		v8.Opened = false
		v8.IsOpen:set(false)
		v8.AnimationProgress:set(0)
		v8.AnimationProgressSpring:setPosition(0)
		v8.AnimationProgressSpring:setVelocity(0)
	end
end

function AnimatedHUD:Create()
	if not (self and self:IsA("BillboardGui")) then
		return
	end

	AnimatedHUD.RefreshFreecam()

	if v4 then
		self.Enabled = false
	end

	local originalSize2 = WaitForValidSize(self)

	if not originalSize2 then
		return
	end

	local main = self:FindFirstChild("Main")
	local title = main and main:FindFirstChild("Title")
	local v8 = title and GetTitleReference()

	if title and title:IsA("GuiObject") and v8 then
		local v9 = title:FindFirstChild("Emitter2DReference")

		if not v9 then
			v9 = Instance.new("ObjectValue")
			v9.Name = "Emitter2DReference"
			v9.Archivable = false
			v9.Parent = title
		end

		if v9:IsA("ObjectValue") then
			v9.Value = v8
		end
	end

	local v9 = {
		OriginalSize = originalSize2,
		OriginalOffset = self:GetAttribute("StudsOffset") or self.StudsOffset,
		Enabled = self:GetAttribute("Enabled") ~= false,
		Opened = nil,
		SizeHandler = self:FindFirstChild("SizeHandler", true),
		MaxDistance = self.MaxDistance / 2,
		Scope = fusion.scoped(fusion)
	}
	v9.IsOpen = v9.Scope:Value(false)
	v9.AnimationProgress = v9.Scope:Value(0)
	v9.AnimationProgressSpring = v9.Scope:Spring(v9.AnimationProgress, 10, 1)
	v9.Scope:Observer(v9.AnimationProgressSpring):onBind(function()
		local originalSize = v9.OriginalSize
		local animationProgressSpring = v9.Scope.peek(v9.AnimationProgressSpring)

		if not animationProgressSpring then
			return
		end

		if v9.SizeHandler then
			v9.SizeHandler.Scale = animationProgressSpring
		else
			self.Size = UDim2.new(
				originalSize.X.Scale * animationProgressSpring,
				originalSize.X.Offset * animationProgressSpring,
				originalSize.Y.Scale * animationProgressSpring,
				originalSize.Y.Offset * animationProgressSpring
			)
		end

		self.StudsOffset = v9.OriginalOffset - Vector3.new(
			0,
			(1.5 + originalSize.Y.Scale / 2) * (1 - animationProgressSpring),
			0
		)
		self.Enabled = not v4 and animationProgressSpring > 0
	end)
	v9.Scope:Observer(v9.IsOpen):onBind(function()
		local isOpen = v9.Scope.peek(v9.IsOpen)

		if isOpen == nil then
			return
		end

		if isOpen then
			v9.AnimationProgress:set(1)
		else
			v9.AnimationProgress:set(0)
		end
	end)
	v9.Connections = {}
	v9.Connections.MaxDistance = self:GetPropertyChangedSignal("MaxDistance"):Connect(function()
		v9.MaxDistance = self.MaxDistance / 2
	end)
	v9.Connections.Attributes = self.AttributeChanged:Connect(function(p: string)
		if p == "Size" then
			local size = self.Size
			local v10 = size.X.Scale + size.X.Offset
			local v11 = size.Y.Scale + size.Y.Offset
			local v12

			if v10 > 0 then
				v12 = v11 > 0
			else
				v12 = false
			end

			if not v12 then
				return
			end

			v9.OriginalSize = self:GetAttribute("Size") or self.Size
		elseif p == "StudsOffset" then
			v9.OriginalOffset = self:GetAttribute("StudsOffset") or self.StudsOffset
		elseif p == "Enabled" then
			v9.Enabled = self:GetAttribute("Enabled") ~= false
		end
	end)
	v9.Connections.Destroyed = self.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			for _, connection in v9.Connections do
				connection:Disconnect()
			end

			table.clear(v9.Connections)
			v9.Scope:doCleanup()
			v[self] = nil
		end
	end)
	v[self] = v9
	return v9
end

AnimatedHUD.RefreshFreecam()
script.Destroying:Connect(function()
	if freecamEnabledChangedConnection then
		freecamEnabledChangedConnection:Disconnect()
		freecamEnabledChangedConnection = nil
	end

	if v6 then
		v6:Destroy()
		v6 = nil
		v5 = nil
	end
end)
module.Utils.Instance:ObserveTaggedObject("AnimatedHUD", function(billboardGui)
	if billboardGui and billboardGui:IsA("BillboardGui") then
		AnimatedHUD.Create(billboardGui)
	end
end)
module.Services.RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v2 < 0.03333333333333333 then
		return
	end

	v2 = now
	AnimatedHUD.RefreshFreecam()

	for k, v7 in v do
		local adornee = k.Adornee or k.Parent
		local adorneePosition = GetAdorneePosition(adornee) -- equivalent call inferred; original call site unknown

		if not adorneePosition then
			continue
		end

		local v9 = adorneePosition + v7.OriginalOffset
		local opened = (currentCamera.CFrame.Position - v9).Magnitude < v7.MaxDistance

		if v4 or not v7.Enabled then
			opened = false
		end

		if v7.Opened == opened then
			continue
		end

		v7.Opened = opened
		v7.IsOpen:set(opened)
	end
end)
return AnimatedHUD