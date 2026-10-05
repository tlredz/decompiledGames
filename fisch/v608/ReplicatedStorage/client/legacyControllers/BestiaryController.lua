local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local components = script:WaitForChild("Components")
local safeZone = HudController:GetSafeZone()
local bestiaryNEW = safeZone.bestiaryNEW
local header = bestiaryNEW.Header
local label = header.Label
local header2 = header.IgnoreList.Header2
local fish = header2.Fish
local rod = header2.Rod
local base = header.Base
local limited = header.Limited
local fish2 = bestiaryNEW.Fish
local rod2 = bestiaryNEW.Rod
local localPlayer = game.Players.LocalPlayer
local v = "Fish"

-- equivalent calls inferred from this helper; original call sites unknown
local function setTab(p: string)
	v = p
	local visible = p == "Fish"
	fish2.Visible = visible
	rod2.Visible = not visible
	label.Text = visible and "Bestiary" or "Rod Journal"
	base.Visible = visible
	limited.Visible = visible
end

local function updatePositions()
	local guiInset, v2 = GuiService:GetGuiInset()
	local v3 = v2 + Vector2.new(0, 90)
	bestiaryNEW.Size = UDim2.new(0.65, -guiInset.X - v3.X, 0.95, -guiInset.Y - v3.Y)
	bestiaryNEW.Position = UDim2.new(0.5, guiInset.X / 2 - v3.X / 2, 0.475, guiInset.Y / 2 - v3.Y / 2)
	local absoluteSize = safeZone.AbsoluteSize
	bestiaryNEW.UISizeConstraint.MaxSize = Vector2.new(
		math.max(800, (math.min(absoluteSize.X * 1, absoluteSize.Y * 0.55 * 1.71))),
		(math.max(800, absoluteSize.Y * 0.532))
	)
end

local BestiaryController = {}

function BestiaryController.SetTab(_, p: string)
	setTab(p) -- equivalent call inferred; original call site unknown
end

function BestiaryController.Start(_)
	while not SettingsController:GetSettingValue("newBestiary") do
		task.wait()
	end

	local assetsloaded = localPlayer:WaitForChild("assetsloaded")

	while not assetsloaded.Value do
		task.wait()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectComponent(moduleScript)
		if not moduleScript:IsA("ModuleScript") then
			return
		end

		local success, result = pcall(require, moduleScript)

		if not success then
			warn(result)
		elseif result.Init then
			result:Init()
		end
	end

	for _, child in components:GetChildren() do
		connectComponent(child) -- equivalent call inferred; original call site unknown
	end

	components.ChildAdded:Connect(connectComponent)
	v = "Fish"
	fish2.Visible = true
	rod2.Visible = false
	label.Text = "Bestiary"
	base.Visible = true
	limited.Visible = true
	fish.Activated:Connect(function()
		v = "Fish"
		fish2.Visible = true
		rod2.Visible = false
		label.Text = "Bestiary"
		base.Visible = true
		limited.Visible = true
	end)
	rod.Activated:Connect(function()
		v = "Rod"
		fish2.Visible = false
		rod2.Visible = true
		label.Text = "Rod Journal"
		base.Visible = false
		limited.Visible = false
	end)
	bestiaryNEW:GetPropertyChangedSignal("Visible"):Connect(updatePositions)
	safeZone:GetPropertyChangedSignal("AbsoluteSize"):Connect(updatePositions)
	updatePositions()
end

return BestiaryController