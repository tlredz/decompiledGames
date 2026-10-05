game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
game:GetService("ContextActionService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AvatarEditorSearch"
})
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Signal = require(ReplicatedStorage.Packages.Signal)

local function getDropdownItemDisplayText(instance, childName: string, p: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return p
	end

	local itemText = child:FindFirstChild("ItemText")

	if itemText == nil or not itemText:IsA("TextLabel") or itemText.Text == "" then
		return p
	end

	return itemText.Text
end

function v:ResetUserSearchOptions()
	self.hasManuallySetSortOptions = false
	self.userSearchOptions = {
		SearchType = "Keyword / ID",
		SearchTerm = "",
		SortType = "Relevance",
		PriceMin = 0,
		PriceMax = 2147483647,
		SortAggregation = "AllTime"
	}
	self:SyncSearchOptionsUI()
end

function v:SyncSearchOptionsUI()
	local container = self.Instance:WaitForChild("Container")
	local menu = container:WaitForChild("SearchMenu"):WaitForChild("Menu")
	local textBox = menu:WaitForChild("SearchBar"):WaitForChild("TextBox")
	local searchType = menu:WaitForChild("SearchType")
	local dropdown = searchType:WaitForChild("Dropdown")
	local menu2 = container:WaitForChild("OptionsMenu"):WaitForChild("Menu")
	local sortType = menu2:WaitForChild("SortType")
	local dropdown2 = sortType:WaitForChild("Dropdown")
	local timeframe = menu2:WaitForChild("Timeframe")
	local dropdown3 = timeframe:WaitForChild("Dropdown")
	local timeframeLabel = menu2:FindFirstChild("TimeframeLabel")
	textBox.Text = self.userSearchOptions.SearchTerm
	dropdown.Visible = false
	searchType.CurrentType.Text = self.userSearchOptions.SearchType
	dropdown2.Visible = false
	local currentType = sortType.CurrentType
	local sortType2 = self.userSearchOptions.SortType
	local sortType3 = self.userSearchOptions.SortType
	local child = dropdown2:FindFirstChild(sortType2)

	if child ~= nil then
		local itemText = child:FindFirstChild("ItemText")

		if itemText ~= nil and itemText:IsA("TextLabel") and itemText.Text ~= "" then
			sortType3 = itemText.Text
		end
	end

	currentType.Text = sortType3
	local visible = self.userSearchOptions.SortType == "Bestselling" or self.userSearchOptions.SortType == "MostFavorited"
	dropdown3.Visible = false
	local currentType2 = timeframe.CurrentType
	local child2 = dropdown3:FindFirstChild(self.userSearchOptions.SortAggregation)
	local text

	if child2 == nil then
		text = "All Time"
	else
		local itemText = child2:FindFirstChild("ItemText")
		text = (itemText == nil or not itemText:IsA("TextLabel") or itemText.Text == "") and "All Time" or itemText.Text
	end

	currentType2.Text = text
	timeframe.Visible = visible

	if timeframeLabel ~= nil then
		timeframeLabel.Visible = visible
	end
end

function v:ApplyDefaultSortOptions(sortType: string, p: string)
	self.userSearchOptions.SortType = sortType
	self.userSearchOptions.SortAggregation = sortType ~= "Bestselling" and sortType ~= "MostFavorited" and "AllTime" or p
	self:SyncSearchOptionsUI()
end

function v:HookupSearchBarPanel()
	local searchMenu = self.Instance:WaitForChild("Container"):WaitForChild("SearchMenu")
	local openClose = searchMenu:WaitForChild("OpenClose")
	local menu = searchMenu:WaitForChild("Menu")
	local textBox = menu:WaitForChild("SearchBar"):WaitForChild("TextBox")
	local searchType = menu:WaitForChild("SearchType")
	local dropdown = searchType:WaitForChild("Dropdown")
	openClose.Activated:Connect(function()
		menu.Visible = not menu.Visible
		self.SearchOpenClosed:Fire(menu.Visible)
	end)
	textBox.FocusLost:Connect(function(flag: boolean)
		if flag or UserInputService.GamepadEnabled then
			self.userSearchOptions.SearchTerm = textBox.Text
			self.UserSearchOptionsChanged:Fire(self.userSearchOptions)
		end
	end)
	searchType.Activated:Connect(function()
		local visible = not dropdown.Visible
		dropdown.Visible = visible

		if visible then
			searchType.NextSelectionDown = nil
			searchType.NextSelectionUp = nil
			searchType.SelectionGroup = true
			searchType.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			searchType.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			searchType.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			searchType.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			RunService.RenderStepped:Wait()
			local v3 = false

			while not v3 and dropdown.Visible do
				local v4 = UserInputService.InputEnded:Wait()

				if not (v4.UserInputType == Enum.UserInputType.MouseButton1 or v4.UserInputType == Enum.UserInputType.Touch) then
					continue
				end

				task.defer(function()
					dropdown.Visible = false
				end)
				v3 = true
			end
		else
			searchType.NextSelectionDown = openClose
			searchType.NextSelectionUp = openClose
			searchType.SelectionGroup = false
		end
	end)

	for _, button in dropdown:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v2 = button
		button.Activated:Connect(function()
			searchType.CurrentType.Text = v2.ItemText.Text
			dropdown.Visible = false
			self.userSearchOptions.SearchType = v2.Name
			self.UserSearchOptionsChanged:Fire(self.userSearchOptions)
		end)
	end

	menu.Visible = false
end

function v:HookupSearchOptionsPanel()
	local optionsMenu = self.Instance:WaitForChild("Container"):WaitForChild("OptionsMenu")
	local openClose = optionsMenu:WaitForChild("OpenClose")
	local menu = optionsMenu:WaitForChild("Menu")
	local sortType = menu:WaitForChild("SortType")
	local dropdown = sortType:WaitForChild("Dropdown")
	local timeframe = menu:WaitForChild("Timeframe")
	local timeframeLabel = menu:WaitForChild("TimeframeLabel")
	local dropdown2 = timeframe:WaitForChild("Dropdown")
	openClose.Activated:Connect(function()
		menu.Visible = not menu.Visible
		self.SearchOptionsOpenClosed:Fire(menu.Visible)
	end)
	sortType.Activated:Connect(function()
		local visible = not dropdown.Visible
		dropdown.Visible = visible

		if visible then
			sortType.NextSelectionDown = nil
			sortType.NextSelectionUp = nil
			sortType.SelectionGroup = true
			sortType.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			sortType.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			sortType.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			sortType.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			RunService.RenderStepped:Wait()
			local v3 = false

			while not v3 and dropdown.Visible do
				local v4 = UserInputService.InputEnded:Wait()

				if not (v4.UserInputType == Enum.UserInputType.MouseButton1 or v4.UserInputType == Enum.UserInputType.Touch) then
					continue
				end

				task.defer(function()
					dropdown.Visible = false
				end)
				v3 = true
			end
		else
			sortType.NextSelectionDown = timeframe
			sortType.NextSelectionUp = timeframe
			sortType.SelectionGroup = false
		end
	end)

	for _, button in dropdown:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v2 = button
		button.Activated:Connect(function()
			sortType.CurrentType.Text = v2.ItemText.Text
			dropdown.Visible = false
			self.hasManuallySetSortOptions = true
			self.userSearchOptions.SortType = v2.Name

			if self.userSearchOptions.SortType == "Bestselling" or self.userSearchOptions.SortType == "MostFavorited" then
				timeframe.Visible = true
				timeframeLabel.Visible = true
			else
				timeframe.CurrentType.Text = "All Time"
				self.userSearchOptions.SortAggregation = "AllTime"
				dropdown2.Visible = false
				timeframe.Visible = false
				timeframeLabel.Visible = false
			end

			self.UserSearchOptionsChanged:Fire(self.userSearchOptions)
		end)
	end

	timeframe.Activated:Connect(function()
		local visible = not dropdown2.Visible
		dropdown2.Visible = visible

		if visible then
			timeframe.NextSelectionDown = nil
			timeframe.NextSelectionUp = nil
			timeframe.SelectionGroup = true
			timeframe.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			timeframe.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			timeframe.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			timeframe.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			RunService.RenderStepped:Wait()
			local v3 = false

			while not v3 and dropdown2.Visible do
				local v4 = UserInputService.InputEnded:Wait()

				if not (v4.UserInputType == Enum.UserInputType.MouseButton1 or v4.UserInputType == Enum.UserInputType.Touch) then
					continue
				end

				task.defer(function()
					dropdown2.Visible = false
				end)
				v3 = true
			end
		else
			timeframe.NextSelectionDown = sortType
			timeframe.NextSelectionUp = sortType
			timeframe.SelectionGroup = false
		end
	end)

	for _, button in dropdown2:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v2 = button
		button.Activated:Connect(function()
			timeframe.CurrentType.Text = v2.ItemText.Text
			dropdown2.Visible = false
			self.hasManuallySetSortOptions = true
			self.userSearchOptions.SortAggregation = v2.Name
			self.UserSearchOptionsChanged:Fire(self.userSearchOptions)
		end)
	end

	timeframe.Visible = false
	timeframeLabel.Visible = false
	menu.Visible = false
end

function v.HookOnSubcategoryChanged(p)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		p.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	local menu = p.Instance:WaitForChild("Container"):WaitForChild("OptionsMenu"):WaitForChild("Menu")

	if not waitForAncestorComponent then
		return
	end

	waitForAncestorComponent.OnSubcategoryChanged:Connect(function(instance, _)
		if instance and instance:GetAttribute("DisplayName") then
			menu.TitleLabel.Text = `Search Options: {instance:GetAttribute("DisplayName")}`
		else
			menu.TitleLabel.Text = "Search Options"
		end
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.SearchOpenClosed = Signal.new()
	self.SearchOptionsOpenClosed = Signal.new()
	self.UserSearchOptionsChanged = Signal.new()
	self:ResetUserSearchOptions()
	self:HookupSearchBarPanel()
	self:HookupSearchOptionsPanel()
	task.spawn(self.HookOnSubcategoryChanged, self)
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v