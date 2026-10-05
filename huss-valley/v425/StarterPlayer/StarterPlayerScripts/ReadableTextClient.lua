local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {}
local connections = {}
local flag = true

local function proximityPresentation(parent)
	while parent do
		if parent:GetAttribute("SelfManagedText") == true or parent.Name == "ProximityPrompts" or parent:GetAttribute("ProximityPromptUI") == true then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function loadingPresentation(instance)
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

	if not screenGui then
		return screenGui
	end

	if screenGui.Name == "ScreenOverlay" or screenGui.Name == "TeleportOverlay" then
		screenGui = true
	elseif screenGui.Name == "Notifications" then
		screenGui = instance:FindFirstAncestor("NotificationsF") ~= nil
	else
		screenGui = false
	end

	return screenGui
end

local function shopTab(instance)
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui then
		if screenGui.Name == "ValleyArmory" then
			screenGui = instance:FindFirstAncestor("Tabs") ~= nil
		else
			screenGui = false
		end
	end

	return screenGui
end

local function largeScreen()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		if currentCamera.ViewportSize.X >= 700 then
			currentCamera = currentCamera.ViewportSize.Y >= 500
		else
			currentCamera = false
		end
	end

	return currentCamera
end

local function resize(instance, state)
	if state.updating then
		return
	end

	state.updating = true
	local v2 = instance:FindFirstAncestor("UpdatesShade") ~= nil or instance:FindFirstAncestorWhichIsA("ScreenGui") and (instance:FindFirstAncestorWhichIsA("ScreenGui").Name == "HitboxComparison" or instance:FindFirstAncestorWhichIsA("ScreenGui").Name == "HitReplayStatus")
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui then
		if screenGui.Name == "ValleyArmory" then
			screenGui = instance:FindFirstAncestor("Tabs") ~= nil
		else
			screenGui = false
		end
	end

	local v3 = not (screenGui or v2)

	if v3 then
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			if currentCamera.ViewportSize.X >= 700 then
				currentCamera = currentCamera.ViewportSize.Y >= 500
			else
				currentCamera = false
			end
		end

		v3 = currentCamera and instance:IsDescendantOf(playerGui) and not (instance:FindFirstAncestorWhichIsA("BillboardGui") or instance:FindFirstAncestorWhichIsA("SurfaceGui"))
	end

	instance.TextScaled = not v3
	state.appliedSize = v3 and math.clamp(math.round(state.authored * 1.12), 12, 40) or state.authored
	instance.TextSize = state.appliedSize
	state.updating = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forget(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil

	for _, connection in v2.connections do
		connection:Disconnect()
	end
end

local function apply(descendant)
	if flag then
		local screenGui = descendant:FindFirstAncestorWhichIsA("ScreenGui")

		if screenGui then
			if screenGui.Name == "ScreenOverlay" or screenGui.Name == "TeleportOverlay" then
				screenGui = true
			elseif screenGui.Name == "Notifications" then
				screenGui = descendant:FindFirstAncestor("NotificationsF") ~= nil
			else
				screenGui = false
			end
		end

		if not (screenGui or proximityPresentation(descendant)) then
			if descendant:IsA("UITextSizeConstraint") then
				descendant:Destroy()
				return
			end

			if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) or v[descendant] then
				return
			end

			local v2 = {
				authored = descendant:GetAttribute("ReadableAuthoredSize") or descendant.TextSize,
				connections = {}
			}
			v[descendant] = v2
			descendant:SetAttribute("ReadableAuthoredSize", v2.authored)
			table.insert(v2.connections, descendant:GetPropertyChangedSignal("TextScaled"):Connect(function()
				resize(descendant, v2)
			end))
			table.insert(v2.connections, descendant:GetPropertyChangedSignal("TextSize"):Connect(function()
				if v2.updating or descendant.TextSize == v2.appliedSize then
					return
				end

				v2.authored = descendant.TextSize
				descendant:SetAttribute("ReadableAuthoredSize", v2.authored)
				resize(descendant, v2)
			end))
			table.insert(v2.connections, descendant.Destroying:Connect(function()
				forget(descendant) -- equivalent call inferred; original call site unknown
			end))
			resize(descendant, v2)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	for k, v2 in v do
		resize(k, v2)
	end
end

local viewportSizeChangedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraChanged()
	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
	end

	refresh() -- equivalent call inferred; original call site unknown
end

for _, folder in { playerGui, workspace } do
	table.insert(connections, folder.DescendantAdded:Connect(apply))
	table.insert(connections, folder.DescendantRemoving:Connect(forget))

	for _, descendant in folder:GetDescendants() do
		apply(descendant)
	end
end

table.insert(connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged))
cameraChanged() -- equivalent call inferred; original call site unknown
script.Destroying:Connect(function()
	flag = false

	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	local v2 = {}

	for k in v do
		table.insert(v2, k)
	end

	for _, v3 in v2 do
		forget(v3) -- equivalent call inferred; original call site unknown
	end
end)