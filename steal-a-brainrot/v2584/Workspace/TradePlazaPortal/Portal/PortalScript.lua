if not script:IsDescendantOf(workspace) then
	return
end

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local portal = script.Parent:WaitForChild("Portal")
local playerGui = Players.LocalPlayer.PlayerGui
local portalGui = script.PortalGui
portalGui.Parent = playerGui
portalGui.Adornee = portal
local portal2 = portalGui:WaitForChild("Portal")
local clone = portalGui:Clone()
clone.Name = "PortalGuiBack"
clone.Face = Enum.NormalId.Back
clone.Adornee = portal
clone.Parent = playerGui
local portal3 = clone:WaitForChild("Portal")
local viewportFrame = portal2:WaitForChild("ViewportFrame")
local viewportFrame2 = portal3:WaitForChild("ViewportFrame")
local depthLines = portal2:WaitForChild("DepthLines")
local tradeIcon = viewportFrame.WorldModel.TradeIcon
local tradeIcon2 = viewportFrame2.WorldModel.TradeIcon
local cFrame = tradeIcon.CFrame
local v = tradeIcon2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
local flag = false
local v2 = false
local v3 = {}
local v4 = {}

local function addLayer(instance, p)
	if instance:IsA("GuiObject") and not instance:IsA("ViewportFrame") then
		p[instance] = {
			position = instance.Position,
			depth = instance:GetAttribute("ParallaxDepth") or 0
		}
	end
end

local function removeLayer(p, p2)
	p2[p] = nil
end

local function updateLayers(items, vector)
	for k, item in items do
		local uDim = UDim2.fromScale(vector.X * item.depth, vector.Y * item.depth)
		k.Position = item.position + uDim
	end
end

local function spawnDepthLine(portal4, p)
	local clone2 = depthLines:Clone()
	clone2.Visible = true
	clone2:SetAttribute("ParallaxDepth", depthLines:GetAttribute("ParallaxDepth") or 0)
	clone2.Parent = portal4
	addLayer(clone2, p)
	local tween = TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(0, 0),
		ImageTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		p[clone2] = nil
		clone2:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startDepthLines()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while flag do
			spawnDepthLine(portal2, v3)
			spawnDepthLine(portal3, v4)
			task.wait(0.4)
		end
	end)
end

local function stopDepthLines()
	flag = false

	for _, v5 in { portal2, portal3 } do
		for _, child in v5:GetChildren() do
			if child.Name == "DepthLines" and child ~= depthLines then
				child:Destroy()
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActive(flag2: boolean)
	if v2 == flag2 then
		return
	end

	v2 = flag2

	if not flag2 then
		stopDepthLines()
		return
	end

	startDepthLines() -- equivalent call inferred; original call site unknown
end

local isDescendant = script:IsDescendantOf(workspace)
script.AncestryChanged:Connect(function()
	isDescendant = script:IsDescendantOf(workspace)
end)

local function update()
	local currentCamera = workspace.CurrentCamera
	local v5 = currentCamera.CFrame.Position - portal.Position
	local enabled

	if portal.CFrame.LookVector:Dot(v5) > 0 then
		enabled = isDescendant
	else
		enabled = false
	end

	portalGui.Enabled = enabled
	clone.Enabled = not enabled

	if (currentCamera.CFrame.Position - portal.Position).Magnitude >= 200 then
		setActive(false) -- equivalent call inferred; original call site unknown
	else
		setActive(true) -- equivalent call inferred; original call site unknown
		local v7 = portal.Size.Y / portal.Size.X
		local unit = (portal.Position - currentCamera.CFrame.Position).Unit
		local vectorToObjectSpace = portal.CFrame:VectorToObjectSpace(unit)
		local vector = Vector3.new(vectorToObjectSpace.X, vectorToObjectSpace.Y / v7, 0)
		updateLayers(v3, vector)
		updateLayers(v4, vector)
		local v8 = os.clock() * 90
		local vector2 = Vector3.new(0, math.sin(os.clock() * 1) * 1, 0)
		tradeIcon.CFrame = cFrame * CFrame.Angles(0, math.rad(v8), 0) + vector2
		tradeIcon2.CFrame = v * CFrame.Angles(0, math.rad(v8), 0) + vector2
	end
end

local function initialize()
	portal2.ChildAdded:Connect(function(child)
		if child.Name == "DepthLines" then
			return
		end

		addLayer(child, v3)
	end)
	portal3.ChildAdded:Connect(function(child)
		if child.Name == "DepthLines" then
			return
		end

		addLayer(child, v4)
	end)

	for _, child in portal2:GetChildren() do
		addLayer(child, v3)
	end

	for _, child in portal3:GetChildren() do
		addLayer(child, v4)
	end

	RunService.RenderStepped:Connect(update)
end

initialize()