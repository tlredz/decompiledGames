local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Interface = require(ReplicatedStorage.Modules.Shared.Utils.Interface)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "FilterMenu"
})
local Filterable = require(ReplicatedStorage.Modules.Client.Components.UI.Filter.Filterable)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local filterable = self.Instance:WaitForChild("Filterable")
	assert(filterable:IsA("ObjectValue"))
	self.component = Interface.GetImplementation(filterable, Filterable)
	self.type = self.component.Instance:GetAttribute("ItemType") or self.component.Instance:GetAttribute("LoadableEntriesModuleName")

	if self.component.OnFilterChanged then
		self:UpdateFilters()
		self._Janitor:Add(self.component.OnFilterChanged:Connect(function()
			self:UpdateFilters()
		end))
	end

	for _, child in self.Instance:GetChildren() do
		self:AddChild(child)
	end

	self._Janitor:Add(self.Instance.ChildAdded:Connect(function(child)
		self:AddChild(child)
	end))
end

function v:Reset()
	if self._currentGroup ~= nil then
		local checkmark = self._currentGroup:WaitForChild("Checkmark")
		checkmark.Visible = false
		self._currentGroup = nil

		if self.component ~= nil then
			self.component.Instance:SetAttribute("CurrentFilter", nil)
			self.component:FilterGroup(nil)
		end
	end
end

function v:UpdateFilters()
	local filters = self.component:GetFilters()

	if filters then
		for _, button in self.Instance:GetChildren() do
			if button:IsA("GuiButton") then
				button.Visible = filters[button.Name] and true or false
			end
		end
	else
		for _, button in self.Instance:GetChildren() do
			if button:IsA("GuiButton") then
				button.Visible = true
			end
		end
	end
end

function v:AddChild(button)
	if not button:IsA("GuiButton") then
		return
	end

	button.SelectionOrder = 2000
	self._Janitor:Add(button.Activated:Connect(function()
		if self._currentGroup == button then
			local checkmark = self._currentGroup:WaitForChild("Checkmark")
			checkmark.Visible = false
			self._currentGroup = nil
			self.component:FilterGroup(nil)
			self.component.Instance:SetAttribute("CurrentFilter", nil)
			TelemetryController.SendClientInteraction("filterSelected", {
				filter = nil,
				itemType = self.type
			})
		else
			if self._currentGroup ~= nil then
				local checkmark_2 = self._currentGroup:WaitForChild("Checkmark")
				checkmark_2.Visible = false
			end

			local checkmark_3 = button:WaitForChild("Checkmark")
			checkmark_3.Visible = true
			self._currentGroup = button
			TelemetryController.SendClientInteraction("filterSelected", {
				filter = button.Name,
				itemType = self.type
			})
			self.component.Instance:SetAttribute("CurrentFilter", button.Name)

			if button.Name == "Gamepass" then
				self.component:FilterGamepasses()
			else
				self.component:FilterGroup(button.Name)
			end
		end

		Platform.Select(self.component.Instance)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v