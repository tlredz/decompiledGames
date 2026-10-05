local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local packages = ReplicatedStorage.packages
require(packages.Net)
local Trove = require(packages.Trove)
local playerSettings = require(ReplicatedStorage.shared.playerSettings)
require(ReplicatedStorage.shared.playerSettings.Types)
require("@self/Types")
local module = require("@self/GroupInfo")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
local SettingsController = require(legacyControllers.SettingsController)
local DataController = require(legacyControllers.DataController)
local menu2 = Players.LocalPlayer.PlayerGui:WaitForChild("hud").safezone.menu2
local mainframe = menu2.mainframe
local settings = mainframe.selectedpage.settings
local _ = mainframe.selectedpage.stats
local _ = mainframe.selectedpage.titles
local settingTabs = mainframe.selection.settingTabs
local absoluteSize = menu2.AbsoluteSize
local templateGroup = script:WaitForChild("templateGroup")
local templateHeader = script:WaitForChild("templateHeader")
local Settings = {}
local maid = Trove.new()
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local zero = Vector2.zero
local flag = false
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint)

local function updateHighlightedTab()
	local v5 = settings.options.CanvasPosition.Y + 10
	local name = "settings"
	local v6 = -1
	local v7 = nil

	for _, frame in mainframe.selectedpage:GetChildren() do
		if frame:IsA("Frame") and frame.Visible then
			name = frame.Name
		end
	end

	for k, v9 in module do
		if v9.PageName ~= name then
			continue
		end

		if v9.PageName == "settings" then
			if v3[k] and v3[k].Visible then
				local v10 = v4[k]

				if v10 and not (v5 < v10) and v6 < v10 then
					v7 = k
					v6 = v10
				end
			end
		else
			v7 = k
			break
		end
	end

	for k, v9 in v2 do
		local transparency = k == v7 and 0 or 0.61

		if v9.border.Transparency == transparency then
			continue
		end

		if GuiService.ReducedMotionEnabled then
			v9.border.Transparency = transparency
		else
			TweenService:Create(v9.border, tweenInfo, {
				Transparency = transparency
			}):Play()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScrollPositions()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		local v5 = settings.options.AbsolutePosition.Y - settings.options.CanvasPosition.Y

		for k, v6 in v3 do
			v4[k] = v6.AbsolutePosition.Y - v5
		end

		updateHighlightedTab()
	end)
end

local function updateSearch()
	local v5 = mainframe.searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
	local v6 = {}

	for _, v7 in v do
		local clone = table.clone(v7.Config.Aliases or table.create(2))
		table.insert(clone, v7.Config.Name)
		table.insert(clone, v7:GetLocalizedName() or v7.Config.Name)
		local visible = v5 == ""

		for _, v9 in clone do
			if visible then
				break
			end

			if v9:lower():gsub("<.->", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", ""):find(v5, 1, true) == nil then
				visible = false
			else
				visible = true
			end
		end

		if visible then
			v6[v7.Config.Group] = true
		end

		v7.GuiObject.Visible = visible
	end

	for k, v7 in v2 do
		local v8 = v3[k]
		local visible = v6[k] or module[k].PageName ~= "settings"

		if v8 then
			v8.Visible = visible
		end

		local v10 = visible and 0 or 0.5
		v7.ImageTransparency = v10
		v7.icon.ImageTransparency = v10
		v7.label.TextTransparency = v10
	end
end

function Settings.loadSetting(data)
	local child = script.SettingComponents:FindFirstChild(data.Type)

	if not child then
		warn((`Unknown setting type "{data.Type}"`))
		return nil
	end

	local module2 = require(child)
	local v5 = module2.new(data, SettingsController:GetSettingValue(data.Id))

	if not v5 then
		return nil
	end

	maid:Add(v5, "Destroy")
	table.insert(v, v5)
	maid:Add(v5.GuiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScrollPositions))
	maid:Add(v5.GuiObject:GetPropertyChangedSignal("Visible"):Connect(updateScrollPositions))

	if absoluteSize.X < 400 then
		for _, descendant in v5.GuiObject:GetDescendants() do
			if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				continue
			end

			descendant.TextSize /= 2
		end
	end

	v5.GuiObject.LayoutOrder += module[data.Group].Order * 1000
	v5.GuiObject.Parent = settings.options
	return v5
end

function Settings.open()
	maid:Clean()
	DataController.PlayerDataReplicator:WaitForLoaded()
	local fetched = legacyLocalPlayerData.fetch()
	maid:Add(function()
		table.clear(v4)
		table.clear(v)
		table.clear(v3)
		table.clone(v2)
	end)

	for _, v5 in module do
		local v6 = maid:Add(templateGroup:Clone())
		v6.LayoutOrder = v5.Order
		v6.Name = v5.Id
		v6.Image = v5.ButtonBackground
		v6.icon.Image = v5.Icon
		v6.icon.ImageRectOffset = v5.IconRectOffset or Vector2.zero
		v6.icon.ImageRectSize = v5.IconRectSize or Vector2.zero
		v6.label.Text = v5.Name

		if v5.PageName == "settings" then
			local v7 = maid:Add(templateHeader:Clone())
			v7.Name = v5.Id
			v7.LayoutOrder = v5.Order * 1000
			v7.detail.title.Text = v5.Name
			v7.detail.icon.Image = v5.Icon
			v7.detail.icon.ImageRectOffset = v5.IconRectOffset or Vector2.zero
			v7.detail.icon.ImageRectSize = v5.IconRectSize or Vector2.zero
			v3[v5.Id] = v7
			v7.Parent = settings.options
		end

		v2[v5.Id] = v6
		local v7 = v5
		maid:Add(v6.Activated:Connect(function()
			for i, frame in mainframe.selectedpage:GetChildren() do
				if frame:IsA("Frame") then
					frame.Visible = frame.Name == v7.PageName
				end
			end

			if v7.PageName ~= "settings" then
				updateHighlightedTab()
				return
			end

			if not v3[v7.Id].Visible then
				return
			end

			local vector = Vector2.new(0, v4[v7.Id] or 0)

			if GuiService.ReducedMotionEnabled then
				settings.options.CanvasPosition = vector
			else
				TweenService:Create(settings.options, tweenInfo, {
					CanvasPosition = vector
				}):Play()
			end
		end))
		v6.Parent = settingTabs
	end

	for _, playerSetting in playerSettings do
		if not playerSetting.IsVisible or playerSetting.IsVisible(DataController.PlayerDataReplicator.Data, fetched) then
			Settings.loadSetting(playerSetting)
		end
	end

	maid:Add(settings.options:GetPropertyChangedSignal("CanvasPosition"):Connect(updateHighlightedTab))
	maid:Add(mainframe.searchBox:GetPropertyChangedSignal("Text"):Connect(updateSearch))
	updateSearch()
	updateScrollPositions() -- equivalent call inferred; original call site unknown
	local flag2 = false

	for _, v6 in v do
		if not v6.GuiObject.Visible then
			continue
		end

		flag2 = true
		break
	end

	if flag2 then
		settings.options.CanvasPosition = zero
	else
		mainframe.searchBox.Text = ""
	end

	maid:Add(menu2.Close.Activated:Connect(function()
		menu2.Visible = false
	end))

	if not menu2.Visible then
		menu2.Visible = true
	end
end

function Settings.close()
	zero = settings.options.CanvasPosition

	if menu2.Visible then
		menu2.Visible = false
	end

	maid:Clean()
end

function Settings.init()
	menu2:GetPropertyChangedSignal("Visible"):Connect(function()
		if menu2.Visible then
			Settings.open()
		else
			Settings.close()
		end
	end)
	absoluteSize = menu2.AbsoluteSize
	menu2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		absoluteSize = menu2.AbsoluteSize
	end)

	for _, moduleScript in script.ExtraPages:GetChildren() do
		local module2 = require(moduleScript)
		module2.init()
	end
end

return Settings