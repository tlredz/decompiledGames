local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local v = {
	TouchGui = true
}
local v2 = {
	VoteFrame = true,
	Menu = {
		SkillCheckFrame = true,
		SpaceBarPromptText = true,
		Calibrate = true,
		SkillCheckMessage = true,
		StopGenerator = true
	}
}
local v3 = {
	PopUp = true
}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local CameraModeController = {}
local v4 = nil
local flag = false
local flag2 = false
local screenGuis = {}
local connections = {}
local v5 = {}

local function suppress(child)
	if v5[child] then
		return
	end

	local v6 = {
		wasVisible = child.Visible
	}
	v5[child] = v6
	child.Visible = false
	v6.conn = child:GetPropertyChangedSignal("Visible"):Connect(function()
		if not child.Visible then
			return
		end

		child.Visible = false
	end)
end

local function decide(guiObject, p)
	if not guiObject:IsA("GuiObject") then
		return "skip"
	end

	for tag in pairs(v3) do
		if CollectionService:HasTag(guiObject, tag) then
			return "keep"
		end
	end

	local v6 = p[guiObject.Name]

	if v6 == true then
		return "keep"
	end

	if type(v6) == "table" then
		return "recurse", v6
	end

	return "suppress"
end

local applyWhitelist

applyWhitelist = function(instance, p)
	for _, child in ipairs(instance:GetChildren()) do
		local v6, v7 = decide(child, p)

		if v6 == "recurse" then
			applyWhitelist(child, v7)
		elseif v6 == "suppress" then
			suppress(child)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function filterGameHud(screenGui)
	applyWhitelist(screenGui, v2)
	local watch

	watch = function(instance, items)
		connections[#connections + 1] = instance.ChildAdded:Connect(function(child)
			local v6, v7 = decide(child, items)

			if v6 == "recurse" then
				applyWhitelist(child, v7)
			elseif v6 == "suppress" then
				suppress(child)
			end
		end)

		for childName, item in pairs(items) do
			if type(item) ~= "table" then
				continue
			end

			local child = instance:FindFirstChild(childName)

			if child then
				watch(child, item)
			end
		end
	end

	watch(screenGui, v2)
end

local function releaseSuppressed()
	for k, v6 in pairs(v5) do
		if v6.conn then
			v6.conn:Disconnect()
		end

		if k.Parent then
			k.Visible = v6.wasVisible
		end
	end

	table.clear(v5)
end

local function wireReturn(instance)
	if flag then
		return
	end

	local returnButton = instance:FindFirstChild("ReturnButton", true)

	if not (returnButton and returnButton:IsA("GuiButton")) then
		warn(("[CameraModeController] %s.%s missing or not a button; camera mode would have no way out"):format(
			"CameraMode",
			"ReturnButton"
		))
		return
	end

	returnButton.Selectable = true
	returnButton.Activated:Connect(function()
		CameraModeController.Exit()
	end)
	InputService:RegisterActivation(returnButton, function()
		CameraModeController.Exit()
	end)
	flag = true
end

local function resolveGui()
	if v4 and v4.Parent == playerGui then
		return v4
	end

	flag = false
	v4 = nil
	local cameraMode = playerGui:FindFirstChild("CameraMode")

	if cameraMode and cameraMode:IsA("ScreenGui") then
		v4 = cameraMode
	else
		local starterGuiClone = ReplicatedStorage:FindFirstChild("StarterGuiClone")
		local cameraMode2 = starterGuiClone and starterGuiClone:FindFirstChild("CameraMode")

		if cameraMode2 and cameraMode2:IsA("ScreenGui") then
			local clone = cameraMode2:Clone()
			clone.Parent = playerGui
			v4 = clone
		end
	end

	if not v4 then
		return nil
	end

	v4.Enabled = flag2
	wireReturn(v4)
	return v4
end

function CameraModeController.Init()
	if not resolveGui() then
		warn(("[CameraModeController] no %s ScreenGui in PlayerGui or ReplicatedStorage.StarterGuiClone; the Toggle HUD row will do nothing in this place"):format("CameraMode"))
	end
end

function CameraModeController.IsActive()
	return flag2
end

function CameraModeController.Enter()
	if flag2 then
		return
	end

	local gui = resolveGui()

	if not gui then
		warn(("[CameraModeController] cannot enter camera mode: no %s ScreenGui found"):format("CameraMode"))
		return
	end

	flag2 = true
	table.clear(screenGuis)
	local isGame = Universe:IsGame()

	for _, screenGui in ipairs(playerGui:GetChildren()) do
		if screenGui == gui or not screenGui:IsA("ScreenGui") or not screenGui.Enabled or v[screenGui.Name] then
			continue
		end

		if isGame and screenGui.Name == "ScreenGui" then
			filterGameHud(screenGui) -- equivalent call inferred; original call site unknown
		else
			screenGui.Enabled = false
			screenGuis[#screenGuis + 1] = screenGui
		end
	end

	gui.Enabled = true
	connections[#connections + 1] = localPlayer.CharacterAdded:Connect(function()
		CameraModeController.Exit()
	end)
	connections[#connections + 1] = localPlayer:GetAttributeChangedSignal("InLobby"):Connect(function()
		if localPlayer:GetAttribute("InLobby") == true then
			CameraModeController.Exit()
		end
	end)
end

function CameraModeController.Exit()
	if not flag2 then
		return
	end

	flag2 = false

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	releaseSuppressed()

	if v4 and v4.Parent == playerGui then
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v4) then
			GuiService.SelectedObject = nil
		end

		v4.Enabled = false
	end

	for _, v6 in ipairs(screenGuis) do
		if v6.Parent then
			v6.Enabled = true
		end
	end

	table.clear(screenGuis)
end

return CameraModeController