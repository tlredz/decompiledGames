local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PlayerLocalizationConstants = require(ReplicatedStorage.Modules.Shared.Player.PlayerLocalizationConstants)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "CountrySelectorPanel"
})

function v:OnConfirmButtonClicked()
	PanelController.Close("MainGUIHandler", "CountrySelectorPanel")
end

function v:OnCountryButtonClicked(p, lastSelectedCountry)
	if self.lastSelectedCountry then
		self.lastSelectedCountry.GreenCheckMark.Visible = false
	end

	lastSelectedCountry.GreenCheckMark.Visible = true
	self.lastSelectedCountry = lastSelectedCountry
	self.callback(p)
end

function v:AddButtonToList(p, layoutOrder: number)
	local clone = self.templateButton:Clone()
	local title = clone:WaitForChild("Title")
	title.Text = p.Country
	clone.Name = p.Code
	clone.LayoutOrder = layoutOrder
	clone.Parent = self.scrollingFrame
	clone.Visible = true
	self._Janitor:Add(clone.Activated:Connect(function()
		self:OnCountryButtonClicked(p, clone)
	end))
	table.insert(self.buttonList, clone)
end

function v:InitCountryList()
	local countryRegion = PlayerLocalizationController:GetCountryRegion()
	local v2 = 1

	for _, v3 in PlayerLocalizationConstants.CountryRegion do
		if v3.Code ~= countryRegion then
			continue
		end

		self:AddButtonToList(v3, v2)
		break
	end

	for _, v3 in PlayerLocalizationConstants.CountryRegion do
		if v3.Code == countryRegion then
			continue
		end

		self:AddButtonToList(v3, v2)
		v2 += 1
	end

	self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.listLayout.AbsoluteContentSize.Y)
end

function v:FilterText()
	local text = string.lower(self.textFilter.Text)

	if self.lastFilter == text then
		return
	end

	self.lastFilter = text
	local children = self.scrollingFrame:GetChildren()
	local visible = true

	for _, button in children do
		if not button:IsA("ImageButton") then
			continue
		end

		local title = button.Title

		if not (title ~= nil and title:IsA("TextLabel")) then
			continue
		end

		if text == "" then
			button.Visible = true
			visible = false
		else
			local localizedText = string.lower(title.LocalizedText or title.Text)

			if string.find(localizedText, text) then
				button.Visible = true
				visible = false
			else
				button.Visible = false
			end
		end
	end

	self.noFilterResults.Visible = visible
	self.scrollingFrame.CanvasPosition = Vector2.new(0, 0)
end

function v:GetReferences()
	if self.isInitialized then
		return
	end

	local panel = self.Instance:WaitForChild("Panel")
	self.textFilter = panel:WaitForChild("Search"):WaitForChild("TextArea"):WaitForChild("TextFilter")
	local container = panel:WaitForChild("Container")
	self.noFilterResults = container:WaitForChild("NoResults")
	self.scrollingFrame = container:WaitForChild("ScrollingFrame")
	self.listLayout = self.scrollingFrame:WaitForChild("UIListLayout")
	self.templateButton = self.scrollingFrame:WaitForChild("CountryTemplateButton")
	self.templateButton.Visible = false
	self.confirmButton = panel:WaitForChild("ConfirmButton")
	self._Janitor:Add(self.confirmButton.Activated:Connect(function()
		self:OnConfirmButtonClicked()
	end))
	self:InitCountryList()
	self._Janitor:Add(self.textFilter:GetPropertyChangedSignal("Text"):Connect(function()
		self:FilterText()
	end))
	self.textFilter.Text = ""
	self:FilterText()
	self.templateButton:Destroy()
	self.isInitialized = true
	self._Janitor:Add(self.listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.listLayout.AbsoluteContentSize.Y)
	end))
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.buttonList = {}
	self.isInitialized = false
end

function v.Start(_) end

function v:Init(callback, name: string)
	self:GetReferences()
	self.callback = callback

	if name == "" then
		if self.lastSelectedCountry then
			name = self.lastSelectedCountry.Name
		else
			name = PlayerLocalizationController:GetCountryRegion()
		end
	end

	self.lastSelectedCountry = nil

	for _, lastSelectedCountry in self.buttonList do
		if lastSelectedCountry.Name == name then
			lastSelectedCountry.GreenCheckMark.Visible = true
			self.lastSelectedCountry = lastSelectedCountry
		else
			lastSelectedCountry.GreenCheckMark.Visible = false
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v