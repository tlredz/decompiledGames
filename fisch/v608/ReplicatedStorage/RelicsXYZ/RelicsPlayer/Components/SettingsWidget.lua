local parent = script.Parent.Parent
require(parent.Enums)
require(parent.State)
local shared = parent.Parent.Shared
local components = parent.Components
local ScrollFrame = require(components.ScrollFrame)
local React = require(shared.React)
local Settings = require(shared.Settings)
local Util = require(parent.Util)
local hooks = parent.Hooks
local useFeatures = require(hooks.useFeatures)
local useSettings = require(hooks.useSettings)
local SettingsItem = require(components.SettingsItem)

local function SettingsWidget(p)
	local v = useSettings()
	local v2 = useFeatures()
	local children = {}

	for k, setting in Settings.GetSettings() do
		local flag = true
		local v4 = v[k]
		local requiredFeatures = setting.RequiredFeatures

		if requiredFeatures then
			for k2 in requiredFeatures do
				if v2[k2] then
					continue
				end

				flag = false
				break
			end
		end

		if not flag then
			continue
		end

		local v5 = k
		local v6 = v4
		children[k] = React.createElement(SettingsItem, {
			Key = k,
			Value = v4,
			Setting = setting,
			OnActivated = function()
				Settings.ChangeSetting(v5, not v6)
			end
		})
	end

	return React.createElement(ScrollFrame, {
		[React.Tag] = Util.ClassNames("SettingItemsContainer", p[React.Tag]),
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}
	}, children, p.children)
end

return SettingsWidget