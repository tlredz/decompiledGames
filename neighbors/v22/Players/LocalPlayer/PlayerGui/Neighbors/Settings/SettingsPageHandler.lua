local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local settingsList = parent.SettingsList
local _ = settingsList.Parent.Parent.Parent
local Settings = require(game.ReplicatedStorage.Assets.Data.UIData.Settings)
local Network = require(ReplicatedStorage.Modules.Network)
local UI = require(ReplicatedStorage.Modules.UI)
local Server = require(ReplicatedStorage.Modules.Server)
local Utility = require(ReplicatedStorage.Modules.Utility)
local tweenInfo = TweenInfo.new(0.25)
local uDim = UDim2.fromScale(0.25, 0.5)
local uDim2 = UDim2.fromScale(0.75, 0.5)
local color = Color3.fromRGB(212, 52, 47)
local color2 = Color3.fromRGB(52, 212, 47)
local color3 = Color3.fromRGB(238, 238, 238)
local color4 = Color3.fromRGB(29, 29, 29)
local attributesBySettingName = Network:invoke("FetchSettings")
local v = {
	"Gameplay",
	"Privacy",
	"Performance",
	"Audio"
}
local v2 = {}
local failSafeFunction = Utility:FailSafeFunction(function()
	return Players.LocalPlayer:GetRankInGroup(15109848)
end, 5)
parent.Close.MouseButton1Click:Connect(function()
	parent.Visible = false
end)

local function CreateSettingsCategory(p: number, name: string)
	local layoutOrder = math.floor(p * 4)
	v2[name] = layoutOrder
	local clone = settingsList.Category:Clone()
	clone.Name = name
	clone.LayoutOrder = layoutOrder
	clone.Visible = true
	clone.Container.Title.Text = name:upper()
	clone.Parent = settingsList
	return clone
end

local function CreateToggleSetting(setting, flag: boolean)
	local clone = settingsList.Toggle:Clone()
	clone.Setting.Text = setting.Display
	clone.LayoutOrder = v2[setting.Category]
	local attribute = flag or false
	local now = 0
	local switch = clone.Switch
	local ball = switch.Ball

	local function Animate()
		TweenService:Create(ball, tweenInfo, {
			Position = attribute and uDim2 or uDim
		}):Play()
		TweenService:Create(switch, tweenInfo, {
			BackgroundColor3 = attribute and color2 or color
		}):Play()
	end

	clone.Switch.Button.MouseButton1Click:Connect(function()
		if setting.Cooldown and os.clock() - now < setting.Cooldown then
			return
		end

		now = os.clock()
		attribute = not attribute
		Network:fire("ChangeSetting", setting.SettingName, attribute)
		attributesBySettingName[setting.SettingName] = attribute
		Animate()
	end)
	Players.LocalPlayer:GetAttributeChangedSignal(setting.SettingName):Connect(function()
		attribute = Players.LocalPlayer:GetAttribute(setting.SettingName)
		attributesBySettingName[setting.SettingName] = attribute
		Animate()
	end)
	Animate()
	UI:Bind(clone.Switch.Button)
	return clone
end

local function CreateButtonSetting(setting)
	local clone = settingsList.Button:Clone()
	clone.Setting.Text = setting.Display

	if setting.Clicked then
		clone.Button.MouseButton1Click:Connect(function()
			return setting.Clicked(clone)
		end)
	end

	Players.LocalPlayer:GetAttributeChangedSignal(setting.SettingName):Connect(function()
		if setting.Updated then
			setting.Updated(clone, Players.LocalPlayer:GetAttribute(setting.SettingName))
		end
	end)
	UI:Bind(clone.Button)

	if setting.Updated then
		setting.Updated(clone, Players.LocalPlayer:GetAttribute(setting.SettingName))
	end

	return clone
end

local function CreateMultiselectSetting(setting)
	if not setting.Values then
		return
	end

	local clone = settingsList.Multiselect:Clone()
	clone.Setting.Text = setting.Display

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDisplay()
		clone.Button.Text = Players.LocalPlayer:GetAttribute(setting.SettingName) or "N/A"
	end

	clone.Button.MouseButton1Click:Connect(function()
		local v3 = table.find(setting.Values, Players.LocalPlayer:GetAttribute(setting.SettingName)) + 1
		local v4 = #setting.Values < v3 and 1 or v3
		Network:fire("ChangeSetting", setting.SettingName, setting.Values[v4])
	end)
	Players.LocalPlayer:GetAttributeChangedSignal(setting.SettingName):Connect(function()
		updateDisplay() -- equivalent call inferred; original call site unknown
	end)
	UI:Bind(clone.Button)
	updateDisplay() -- equivalent call inferred; original call site unknown
	return clone
end

local function CreateDropdownSetting(setting, p: number)
	if typeof(setting.Type) ~= "table" then
		return
	end

	local clone = settingsList.Dropdown:Clone()
	clone.Info.Setting.Text = setting.Display
	clone.LayoutOrder = v2[setting.Category] + 1
	local visible = false

	for k, v4 in setting.Type do
		local clone2 = clone.Content.Option:Clone()
		clone2.Label.Text = v4.Name
		clone2.Icon.Image = v4.Icon
		clone2.Parent = clone.Content
		clone2.Visible = true

		local function Animate()
			for i, frame in clone.Content:GetChildren() do
				if not (frame:IsA("Frame") and frame.Visible) then
					continue
				end

				TweenService:Create(frame.Button, TweenInfo.new(0.25), {
					BackgroundColor3 = color3
				}):Play()
				TweenService:Create(frame.Label, TweenInfo.new(0.25), {
					TextColor3 = color4
				}):Play()
				TweenService:Create(frame.Icon, TweenInfo.new(0.25), {
					ImageColor3 = color4
				}):Play()
			end

			TweenService:Create(clone2.Button, TweenInfo.new(0.25), {
				BackgroundColor3 = color4
			}):Play()
			TweenService:Create(clone2.Label, TweenInfo.new(0.25), {
				TextColor3 = color3
			}):Play()
			TweenService:Create(clone2.Icon, TweenInfo.new(0.25), {
				ImageColor3 = color3
			}):Play()
		end

		local v6 = k
		local Animate2 = Animate
		clone2.Button.MouseButton1Click:Connect(function()
			Network:fire("ChangeSetting", setting.SettingName, v6)
			p = v6
			Animate2()
		end)

		if k == p then
			Animate()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateDropdown()
		TweenService:Create(clone.Info.Arrow, tweenInfo, {
			Rotation = visible and 180 or 0
		}):Play()
		clone.Content.Visible = visible
	end

	clone.Info.Button.MouseButton1Click:Connect(function()
		visible = not visible
		UpdateDropdown() -- equivalent call inferred; original call site unknown
	end)
	parent:GetPropertyChangedSignal("Visible"):Connect(function()
		visible = false
		UpdateDropdown() -- equivalent call inferred; original call site unknown
	end)
	UI:Bind(clone.Info.Button)
	return clone
end

local function CreateSettingList()
	for k, name in v do
		local layoutOrder = math.floor(k * 4)
		v2[name] = layoutOrder
		local clone = settingsList.Category:Clone()
		clone.Name = name
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		clone.Container.Title.Text = name:upper()
		clone.Parent = settingsList
	end

	for _, setting in Settings do
		if setting.ExcludedServers and table.find(setting.ExcludedServers, Server:GetServerType()) or setting.MinimumRank and failSafeFunction < setting.MinimumRank then
			continue
		end

		local v3 = attributesBySettingName[setting.SettingName]
		local v4 = nil

		if setting.Type == "Toggle" then
			v4 = CreateToggleSetting(setting, v3)
		elseif setting.Type == "Button" then
			v4 = CreateButtonSetting(setting)
		elseif setting.Type == "Multiselect" then
			v4 = CreateMultiselectSetting(setting)
		elseif typeof(setting.Type) == "table" then
			v4 = CreateDropdownSetting(setting, v3)
		end

		v4.Parent = settingsList
		v4.Visible = true

		if setting.Callback then
			setting.Callback(v4)
		end
	end

	local absoluteContentSize = settingsList.UIListLayout.AbsoluteContentSize
	settingsList.CanvasSize = UDim2.fromOffset(0, absoluteContentSize.Y)
end

UI:RegisterScrollingFrame(settingsList, { script.Parent.Parent.UIScale })
CreateSettingList()