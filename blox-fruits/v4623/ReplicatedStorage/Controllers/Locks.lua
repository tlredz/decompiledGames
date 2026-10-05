local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local frozen = table.freeze({
	CORE_PLAYER_LIST_LOCK = "CORE_PLAYER_LIST_LOCK",
	NOTIFICATIONS_SCREEN_LOCK = "NOTIFICATIONS_SCREEN_LOCK",
	TOUCH_GUI_LOCK = "TOUCH_GUI_LOCK",
	HUD_LOCK = "MenuHidden",
	NPC_INTERACTION_LOCK = "NPC_INTERACTION_LOCK",
	HOT_BAR_LOCK = "HOT_BAR_LOCK"
})

local function connectBackpack()
	local Players2 = game:GetService("Players")
	local backpack = Players2.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Backpack")

	if backpack and backpack:IsA("ScreenGui") then
		local function update()
			backpack.Enabled = not (AttributeCounter.get(localPlayer, frozen.HOT_BAR_LOCK) > 0)
		end

		backpack.Enabled = not (AttributeCounter.get(localPlayer, frozen.HOT_BAR_LOCK) > 0)
		AttributeCounter.connect(localPlayer, frozen.HOT_BAR_LOCK, update)
	end
end

local function connectNotifications()
	local Players2 = game:GetService("Players")
	local notifications = Players2.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notifications")

	if notifications and notifications:IsA("ScreenGui") then
		local function update()
			notifications.Enabled = not (AttributeCounter.get(localPlayer, frozen.NOTIFICATIONS_SCREEN_LOCK) > 0)
		end

		notifications.Enabled = not (AttributeCounter.get(localPlayer, frozen.NOTIFICATIONS_SCREEN_LOCK) > 0)
		AttributeCounter.connect(localPlayer, frozen.NOTIFICATIONS_SCREEN_LOCK, update)
	end
end

local function connectTouchGUI()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local v = AttributeCounter.get(localPlayer, frozen.TOUCH_GUI_LOCK) > 0
		local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")

		if not (touchGui and touchGui:IsA("ScreenGui")) then
			touchGui = nil
		end

		if touchGui then
			touchGui.Enabled = not v
			local GuiService = game:GetService("GuiService")
			GuiService.TouchControlsEnabled = touchGui.Enabled
		end
	end

	update() -- equivalent call inferred; original call site unknown
	AttributeCounter.connect(localPlayer, frozen.TOUCH_GUI_LOCK, update)
end

local function connectCoreGuiTypePlayerList()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local v = AttributeCounter.get(localPlayer, frozen.CORE_PLAYER_LIST_LOCK) > 0
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not v)
	end

	update() -- equivalent call inferred; original call site unknown
	AttributeCounter.connect(localPlayer, frozen.CORE_PLAYER_LIST_LOCK, update)
end

return {
	Attributes = frozen,
	SpinnerLock = AttributeCounter.extendedLock(localPlayer, {
		frozen.CORE_PLAYER_LIST_LOCK,
		frozen.HUD_LOCK,
		frozen.TOUCH_GUI_LOCK,
		frozen.NOTIFICATIONS_SCREEN_LOCK,
		frozen.NPC_INTERACTION_LOCK,
		frozen.HOT_BAR_LOCK
	}),
	SceneLock = AttributeCounter.extendedLock(localPlayer, {
		frozen.HUD_LOCK,
		frozen.TOUCH_GUI_LOCK,
		frozen.NPC_INTERACTION_LOCK,
		frozen.HOT_BAR_LOCK
	}),
	GachaWindowLock = AttributeCounter.extendedLock(
		localPlayer,
		{ frozen.CORE_PLAYER_LIST_LOCK, frozen.NPC_INTERACTION_LOCK }
	),
	OnStart = function(_)
		task.spawn(connectBackpack)
		task.spawn(connectNotifications)
		task.spawn(connectTouchGUI)
		task.spawn(connectCoreGuiTypePlayerList)
	end
}