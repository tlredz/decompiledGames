local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BackgroundSelection = require(script.BackgroundSelection)
require(ReplicatedStorage.Modules.SerData.PlayerProfile)
local React = require(ReplicatedStorage.Packages.React)
local Content = require(script.Content)
local ProfileSettings = require(script.ProfileSettings)
local StatisticsSelection = require(script.StatisticsSelection)
local StatusSelection = require(script.StatusSelection)
require(script.Types)
require(ReplicatedStorage.React.Components.Inventory.Types)
local createElement = React.createElement
return function(props)
	local fragment = React.Fragment
	local statisticsSelection

	if props.StatSelectionVisible then
		statisticsSelection = createElement(StatisticsSelection, {
			SelectedStatSlotId = props.SelectedStatSlotId,
			SetSelectedStatSlotId = props.SetSelectedStatSlotId,
			LoadedPlayer = props.LoadedPlayer,
			Stats = props.Stats,
			SetStatSelectionVisible = props.SetStatSelectionVisible,
			SetLoadedPlayer = props.SetLoadedPlayer,
			PatchProfileData = props.PatchProfileData
		})
	end

	local statusSelection

	if props.StatusSelectionVisible then
		statusSelection = createElement(StatusSelection, {
			LoadedPlayer = props.LoadedPlayer,
			SetLoadedPlayer = props.SetLoadedPlayer,
			PatchProfileData = props.PatchProfileData,
			SetStatusSelectionVisible = props.SetStatusSelectionVisible
		})
	end

	local backgroundSelection

	if props.BackgroundSelectionVisible then
		backgroundSelection = createElement(BackgroundSelection, {
			LoadedPlayer = props.LoadedPlayer,
			SetLoadedPlayer = props.SetLoadedPlayer,
			PatchProfileData = props.PatchProfileData,
			ClearNewBackground = props.ClearNewBackground,
			SetBackgroundSelectionVisible = props.SetBackgroundSelectionVisible
		})
	end

	local profileSettings

	if props.SettingsVisible then
		profileSettings = createElement(ProfileSettings, {
			LoadedPlayer = props.LoadedPlayer,
			SetSettingsVisible = props.SetSettingsVisible,
			SetLoadedPlayer = props.SetLoadedPlayer,
			PatchProfileData = props.PatchProfileData
		})
	end

	local content

	if props.IsOpen then
		content = createElement(Content, {
			SetIsOpen = props.SetIsOpen,
			OnExit = props.OnExit,
			LoadedPlayer = props.LoadedPlayer,
			IsLoading = props.IsLoading,
			Category = props.Category,
			SetSelectedCategory = props.SetCategory,
			SettingsVisible = props.SettingsVisible,
			SetSettingsVisible = props.SetSettingsVisible,
			StatSelectionVisible = props.StatSelectionVisible,
			SetStatSelectionVisible = props.SetStatSelectionVisible,
			SetLoadedPlayer = props.SetLoadedPlayer,
			PatchProfileData = props.PatchProfileData,
			InventoryItems = props.InventoryItems,
			SetSelectedStatSlotId = props.SetSelectedStatSlotId,
			StatusSelectionVisible = props.StatusSelectionVisible,
			SetStatusSelectionVisible = props.SetStatusSelectionVisible,
			SetBackgroundSelectionVisible = props.SetBackgroundSelectionVisible
		})
	end

	return createElement(fragment, nil, {
		statisticsSelection = statisticsSelection,
		statusSelection = statusSelection,
		backgroundSelection = backgroundSelection,
		profileSettings = profileSettings,
		content = content
	})
end