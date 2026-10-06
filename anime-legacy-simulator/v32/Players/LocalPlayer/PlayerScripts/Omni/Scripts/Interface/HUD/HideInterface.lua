local module = require("@game/ReplicatedStorage/Omni")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local v = {
	"Notifications",
	"Tutorial",
	"Ripple",
	"Billboards",
	"Rolling"
}
local v2 = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Backpack }
local instance = module.Instance
local playerGui = instance:WaitForChild("PlayerGui")
local topBarPlus = nil
local v3 = false
local flag = false
local v4 = {}
local connections = {}
local v5 = {}
local screenGuis = {}
local v6 = {}
local v7 = nil
local HideInterface = {}

local function HideTopbarIcon(object)
	if object == topBarPlus or (object.isDestroyed or object.parentIconUID) or not object.isEnabled then
		return
	end

	if object.isSelected and #object.dropdownIcons > 0 then
		object:deselect()
	end

	object:setEnabled(false)
	v5[object] = true
end

local function HideTopbarIcons()
	for _, v8 in module.Libs.TopBarPlus.getIcons() do
		if v8 == topBarPlus or (v8.isDestroyed or v8.parentIconUID) or not v8.isEnabled then
			continue
		end

		if v8.isSelected and #v8.dropdownIcons > 0 then
			v8:deselect()
		end

		v8:setEnabled(false)
		v5[v8] = true
	end

	table.insert(connections, module.Libs.TopBarPlus.iconAdded:Connect(function(p)
		task.defer(HideTopbarIcon, p)
	end))
end

local function ShowTopbarIcons()
	for k in v5 do
		if not k.isDestroyed then
			k:setEnabled(true)
		end
	end

	table.clear(v5)
end

local function HideScreenGuis()
	for _, childName in v do
		local screenGui = playerGui:FindFirstChild(childName)

		if not (screenGui and screenGui:IsA("ScreenGui") and screenGui.Enabled) then
			continue
		end

		screenGui.Enabled = false
		table.insert(screenGuis, screenGui)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowScreenGuis()
	for _, v8 in screenGuis do
		if v8.Parent then
			v8.Enabled = true
		end
	end

	table.clear(screenGuis)
end

local function HideCoreGuis()
	for _, v8 in v2 do
		if not StarterGui:GetCoreGuiEnabled(v8) then
			continue
		end

		StarterGui:SetCoreGuiEnabled(v8, false)
		table.insert(v6, v8)
	end

	local bubbleChatConfiguration = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")

	if bubbleChatConfiguration and bubbleChatConfiguration.Enabled then
		bubbleChatConfiguration.Enabled = false
		v7 = bubbleChatConfiguration
	end
end

local function ShowCoreGuis()
	for _, v8 in v6 do
		StarterGui:SetCoreGuiEnabled(v8, true)
	end

	table.clear(v6)

	if v7 then
		v7.Enabled = true
		v7 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideBillboard(billboardGui)
	if not billboardGui:IsA("BillboardGui") then
		return
	end

	billboardGui.PlayerToHideFrom = instance
end

local function HideBillboards()
	for _, folder in { workspace, playerGui } do
		for _, descendant in folder:GetDescendants() do
			HideBillboard(descendant) -- equivalent call inferred; original call site unknown
		end

		table.insert(connections, folder.DescendantAdded:Connect(HideBillboard))
	end
end

local function ShowBillboards()
	for _, folder in { workspace, playerGui } do
		for _, billboardGui in folder:GetDescendants() do
			if billboardGui:IsA("BillboardGui") and billboardGui.PlayerToHideFrom == instance then
				billboardGui.PlayerToHideFrom = nil
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisconnectHidden()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetHidden(flag2: boolean)
	if v3 == flag2 then
		return
	end

	v3 = flag2

	if flag2 then
		HideTopbarIcons()
		module.Frame:AddUIHider("HideInterface")
		HideScreenGuis()
		HideCoreGuis()
		HideBillboards()
		topBarPlus:setCaption("Show UI")
	else
		DisconnectHidden() -- equivalent call inferred; original call site unknown
		ShowBillboards()
		ShowCoreGuis()
		ShowScreenGuis() -- equivalent call inferred; original call site unknown
		module.Frame:RemoveUIHider("HideInterface")
		ShowTopbarIcons()
		topBarPlus:setCaption("Hide UI")
	end
end

function HideInterface.Destroy()
	flag = false

	if topBarPlus then
		SetHidden(false) -- equivalent call inferred; original call site unknown
		topBarPlus:destroy()
		topBarPlus = nil
	end

	for _, connection in v4 do
		connection:Disconnect()
	end

	table.clear(v4)
end

function HideInterface.Init()
	if flag then
		return
	end

	flag = true
	topBarPlus = module.Libs.TopBarPlus.new()
	topBarPlus:setName("HideInterface")
	topBarPlus:setImage("rbxassetid://6851126250", "Deselected")
	topBarPlus:setImage("rbxassetid://79812350174903", "Selected")
	topBarPlus:setCaption("Hide UI")
	topBarPlus:align("Left")
	topBarPlus:autoDeselect(false)
	topBarPlus:bindEvent("toggled", function(_, p)
		SetHidden(p == true)
	end)
	v4.Destroying = module.Interface.Destroying:Connect(HideInterface.Destroy)
end

return HideInterface