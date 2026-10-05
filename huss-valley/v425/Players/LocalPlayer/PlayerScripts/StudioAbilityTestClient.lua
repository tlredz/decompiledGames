local createVector = vector.create
local RunService = game:GetService("RunService")

if not RunService:IsStudio() and game.PlaceId ~= 130574217370467 then
	return
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local gear = chickenOrHero:WaitForChild("Gear")
local GearCatalog = require(gear:WaitForChild("GearCatalog"))
local ValleyPanels = require(chickenOrHero.Presentation:WaitForChild("ValleyPanels"))
local gearEvent = gear:WaitForChild("GearEvent")
local GearPredictionClient = require(gear:WaitForChild("GearPredictionClient"))

local function dashDirection()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local moveDirection = humanoid and humanoid.MoveDirection or createVector(0, 0, 0)

	if moveDirection.Magnitude > 0.05 then
		return moveDirection.Unit
	end

	local currentCamera = workspace.CurrentCamera
	local lookVector = currentCamera and currentCamera.CFrame.LookVector or createVector(0, 0, 0)
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude > 0.01 then
		return vector2.Unit
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.CFrame.LookVector or createVector(0, 0, 1)
end

local session = chickenOrHero.Game:WaitForChild("Session")
local screen = ValleyPanels.screen(localPlayer, "StudioAbilityTests", 80)
screen:SetAttribute("TestOnlyUI", true)
screen.Enabled = localPlayer:GetAttribute("TestUIHidden") ~= true
local button = ValleyPanels.button(screen, "Toggle", "TEST · ABILITIES + ITEMS", 18, 154, 230, 32)
local v = ValleyPanels.make("Frame", screen, "Panel", {
	Position = UDim2.fromOffset(18, 193),
	Size = UDim2.fromOffset(270, 485),
	BackgroundColor3 = ValleyPanels.Ink,
	BorderSizePixel = 0,
	Visible = false
})
ValleyPanels.corner(v, 12)
ValleyPanels.stroke(v, ValleyPanels.Gold, 0.4)
local v2 = ValleyPanels.make("UIScale", v, "Scale", {})
local text_2 = ValleyPanels.text(v, "Heading", "SESSION-ONLY TEST LOADOUT", 12, 10, 246, 23, 12, ValleyPanels.Gold)
text_2.Font = Enum.Font.GothamBold
local count = 0
local buttons = {}

for _, v3 in GearCatalog.Order do
	local v4 = GearCatalog.get(v3)

	if v4.Kind ~= "Ability" then
		continue
	end

	count += 1
	local v5 = (v4.UseRole == "Runner" and "R · " or "C · ") .. v4.Name
	local button2 = ValleyPanels.button(v, v3, v5, 12, (count - 1) * 34 + 36, 246, 29)
	button2.TextSize = 11
	local v6 = v3
	button2.Activated:Connect(function()
		gearEvent:FireServer("StudioEquipAbility", v6)
	end)
	buttons[v3] = button2
end

local v3 = math.max(0, count - 6) * 34
local text = ValleyPanels.text(v, "Status", "Choose an ability above.", 12, 245, 246, 42, 12, ValleyPanels.Paper)
local button2 = ValleyPanels.button(v, "Use", "USE ABILITY", 12, 291, 120, 31)
local button3 = ValleyPanels.button(v, "Reset", "RESET TIMER", 138, 291, 120, 31)
button2.TextSize = 11
button3.TextSize = 11
local button4 = ValleyPanels.button(v, "Clear", "RESTORE NORMAL LOADOUT", 12, 329, 246, 28)
button4.TextSize = 11
local text2 = ValleyPanels.text(
	v,
	"Notice",
	"Lobby: select any ability, then USE. R/C only matter in real matches.",
	12,
	363,
	246,
	34,
	10,
	ValleyPanels.Muted
)
ValleyPanels.text(v, "ItemsHeading", "ITEMS · CLICK TO TEST IN LOBBY", 12, 402, 246, 20, 11, ValleyPanels.Gold)
local buttons2 = {}

for k, v4 in { "BananaPeel", "RescueKit", "Adrenaline" } do
	local v5 = ({
		BananaPeel = "BANANA",
		RescueKit = "SELF RESCUE",
		Adrenaline = "ADRENALINE"
	})[v4]
	local button5 = ValleyPanels.button(v, v4, v5, 12 + (k - 1) * 84, 427, 78, 34)
	button5.TextSize = 10
	local v6 = v4
	button5.Activated:Connect(function()
		GearPredictionClient.request(v6, dashDirection(), "StudioUseItem")
	end)
	table.insert(buttons2, button5)
end

ValleyPanels.text(
	v,
	"ItemHelp",
	"Free demos. Self Rescue falls, then revives you.",
	12,
	465,
	246,
	16,
	10,
	ValleyPanels.Muted
)

for _, guiObject in v:GetChildren() do
	if not guiObject:IsA("GuiObject") or not (guiObject.Position.Y.Offset >= 245) or buttons[guiObject.Name] then
		continue
	end

	guiObject.Position += UDim2.fromOffset(0, v3)
end

v.Size += UDim2.fromOffset(0, v3)
button.Activated:Connect(function()
	v.Visible = not v.Visible
	button.Modal = v.Visible
end)
button2.Activated:Connect(function()
	local studioTestAbility = localPlayer:GetAttribute("StudioTestAbility")

	if type(studioTestAbility) == "string" and GearCatalog.get(studioTestAbility) then
		GearPredictionClient.request(
			studioTestAbility,
			dashDirection(),
			localPlayer:GetAttribute("InMatch") and "UseAbility" or "StudioUseAbility"
		)
	end
end)
button3.Activated:Connect(function()
	gearEvent:FireServer("StudioResetAbility")
end)
button4.Activated:Connect(function()
	gearEvent:FireServer("StudioClearAbility")
end)
local onClientEventConnection = gearEvent.OnClientEvent:Connect(function(p, text3)
	if p == "Notice" and type(text3) == "string" then
		text2.Text = text3
	end
end)
local total = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	local studioTestAbility = localPlayer:GetAttribute("StudioTestAbility")
	local v4 = GearCatalog.get(studioTestAbility)
	local gameRole = localPlayer:GetAttribute("GameRole")
	local v5 = math.max(0, (localPlayer:GetAttribute("AbilityReadyAt") or 0) - workspace:GetServerTimeNow())

	for k, v6 in buttons do
		v6.BackgroundColor3 = k == studioTestAbility and Color3.fromRGB(69, 66, 43) or Color3.fromRGB(36, 56, 70)
	end

	local v6 = localPlayer:GetAttribute("InMatch") ~= true

	for _, v7 in buttons2 do
		v7.Active = v6 and not (session:GetAttribute("GlobalPaused") or session:GetAttribute("MapChanging"))
		v7.TextTransparency = v7.Active and 0 or 0.5
	end

	text.Text = not v4 and "Choose a test ability. Your real loadout is preserved." or v6 and "LOBBY SANDBOX · press USE. Targets appear automatically. Roles stay unchanged." or gameRole ~= v4.UseRole and "Needs " .. (v4.UseRole == "Runner" and "RUNNER" or "CHASER") .. " role. Roles are not changed." or localPlayer:GetAttribute("RunState") ~= "Active" and "Wait until you are active on the field." or not (v5 > 0) and "Ready during an open crossing. Aim, then use." or string.format(
		"Cooldown: %.1fs · reset to try again.",
		v5
	) or "Ready during an open crossing. Aim, then use."
	button2.Active = v4 ~= nil and (not not v6 or gameRole == v4.UseRole and localPlayer:GetAttribute("RunState") == "Active" and v5 == 0) and not (session:GetAttribute("GlobalPaused") or session:GetAttribute("MapChanging"))
	button2.TextTransparency = button2.Active and 0 or 0.5
	v2.Scale = math.min(
		1,
		math.max(0.5, (screen.AbsoluteSize.Y - 210) / (v3 + 485)),
		(screen.AbsoluteSize.X - 36) / 270
	)
end)
script.Destroying:Connect(function()
	heartbeatConnection:Disconnect()
	onClientEventConnection:Disconnect()
	screen:Destroy()
end)