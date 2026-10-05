local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local presentation = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation")
local session = presentation.Parent:WaitForChild("Game"):WaitForChild("Session")
local CreatorPolicy = require(presentation:WaitForChild("CreatorPolicy"))
local HudNavigation = require(presentation:WaitForChild("HudNavigation"))
local CreatorVisibility = require(presentation:WaitForChild("CreatorVisibility"))
local v = CreatorVisibility.new(localPlayer)
local CreatorView = require(presentation:WaitForChild("CreatorView"))
local v2 = CreatorView.new(localPlayer)
local v3 = false
local v4 = false
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function on(object, p)
	table.insert(connections, object:Connect(p))
end

if localPlayer:GetAttribute("CreatorCameraSpeed") == nil then
	localPlayer:SetAttribute("CreatorCameraSpeed", 0.65)
end

if localPlayer:GetAttribute("CreatorFOV") == nil then
	localPlayer:SetAttribute("CreatorFOV", 60)
end

local function render()
	v2:render(
		v3,
		CreatorPolicy.authorized(localPlayer) and localPlayer:GetAttribute("ClientReady") == true,
		CreatorPolicy.lobby(localPlayer, session),
		localPlayer:GetAttribute("CreatorCameraActive") == true,
		v.hidden,
		localPlayer:GetAttribute("CreatorCameraSpeed") or 0.65,
		localPlayer:GetAttribute("CreatorFOV") or 60,
		UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	)
end

local function panel(p)
	if p then
		if not CreatorPolicy.authorized(localPlayer) or localPlayer:GetAttribute("ClientReady") ~= true then
			return
		end

		v:setHidden(false)
		HudNavigation.opening("CreatorStudio")
	end

	v3 = p
	localPlayer:SetAttribute("CreatorPanelOpen", p or nil)
	render()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restore()
	v:setHidden(false)
	render()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function camera()
	if not CreatorPolicy.authorized(localPlayer) then
		return
	end

	restore() -- equivalent call inferred; original call site unknown
	v3 = false
	localPlayer:SetAttribute("CreatorPanelOpen", nil)
	render()
	HudNavigation.activate("CreatorCamera")
end

local function clean()
	if v.hidden then
		v:setHidden(false)
	else
		if not CreatorPolicy.lobby(localPlayer, session) then
			return
		end

		v3 = false
		localPlayer:SetAttribute("CreatorPanelOpen", nil)
		render()
		HudNavigation.opening("CreatorCapture")
		v:setHidden(true)
	end

	render()
end

local function refresh()
	local creatorCameraActive = localPlayer:GetAttribute("CreatorCameraActive") == true

	if not CreatorPolicy.lobby(localPlayer, session) then
		restore() -- equivalent call inferred; original call site unknown

		if v3 then
			v3 = false
			localPlayer:SetAttribute("CreatorPanelOpen", nil)
			render()
		end
	end

	if v4 and not creatorCameraActive then
		restore() -- equivalent call inferred; original call site unknown
	end

	v4 = creatorCameraActive
	render()
end

table.insert(connections, v2.commands.Activated:Connect(function()
	restore() -- equivalent call inferred; original call site unknown
	v3 = false
	localPlayer:SetAttribute("CreatorPanelOpen", nil)
	render()
	presentation.Parent.Admin.AdminEvent:FireServer("Command", ";help")
end))
table.insert(connections, v2.open.Activated:Connect(function()
	panel(not v3)
end))
table.insert(connections, v2.close.Activated:Connect(function()
	v3 = false
	localPlayer:SetAttribute("CreatorPanelOpen", nil)
	render()
end))
on(v2.camera.Activated, camera) -- equivalent call inferred; original call site unknown
on(v2.hide.Activated, clean) -- equivalent call inferred; original call site unknown
on(v2.restore.Activated, restore) -- equivalent call inferred; original call site unknown

for _, speed in v2.speeds do
	local v5 = speed
	table.insert(connections, speed.button.Activated:Connect(function()
		localPlayer:SetAttribute("CreatorCameraSpeed", v5.value)
		render()
	end))
end

for _, lens in v2.lenses do
	local v5 = lens
	table.insert(connections, lens.button.Activated:Connect(function()
		localPlayer:SetAttribute("CreatorFOV", v5.value)
		render()
	end))
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Escape and v.hidden then
		restore() -- equivalent call inferred; original call site unknown
	else
		if not CreatorPolicy.authorized(localPlayer) or gameProcessed or UserInputService:GetFocusedTextBox() or GuiService.MenuIsOpen then
			return
		end

		if input.KeyCode == Enum.KeyCode.F4 then
			panel(not v3)
		elseif input.KeyCode == Enum.KeyCode.F6 then
			camera() -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.F8 then
			clean()
		end
	end
end))
on(GuiService.MenuOpened, restore) -- equivalent call inferred; original call site unknown
table.insert(connections, HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "CreatorStudio" and v3 then
		v3 = false
		localPlayer:SetAttribute("CreatorPanelOpen", nil)
		render()
	end
end))

for _, v5 in {
	"CreatorAuthorized",
	"ClientReady",
	"GameRole",
	"CreatorCameraActive",
	"CreatorFOV",
	"CreatorCameraSpeed"
} do
	on(localPlayer:GetAttributeChangedSignal(v5), refresh) -- equivalent call inferred; original call site unknown
end

for _, playerBlocker in CreatorPolicy.PlayerBlockers do
	on(localPlayer:GetAttributeChangedSignal(playerBlocker), refresh) -- equivalent call inferred; original call site unknown
end

for _, v5 in { "MapChanging", "GlobalPaused" } do
	on(session:GetAttributeChangedSignal(v5), refresh) -- equivalent call inferred; original call site unknown
end

table.insert(connections, localPlayer.CharacterRemoving:Connect(function()
	restore() -- equivalent call inferred; original call site unknown
	v3 = false
	localPlayer:SetAttribute("CreatorPanelOpen", nil)
	render()
end))
on(UserInputService.LastInputTypeChanged, render) -- equivalent call inferred; original call site unknown
refresh()
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	v:destroy()
	localPlayer:SetAttribute("CreatorPanelOpen", nil)
	v2:destroy()
end)