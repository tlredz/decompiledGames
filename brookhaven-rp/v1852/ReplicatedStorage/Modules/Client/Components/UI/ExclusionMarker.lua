local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ExclusionMarker"
})
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local exclusionMarkerTemplate = nil

function v:Construct()
	self._Janitor = Janitor.new()
	self._markerJanitor = Janitor.new()
	exclusionMarkerTemplate = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("ExclusionMarkerTemplate")
	v5 = v5 or require(ReplicatedStorage.Modules.Shared.DB.Exclusion.ExclusionConfig)
	v2 = v2 or require(ReplicatedStorage.Modules.Client.Exclusion.ExclusionController)
	v3 = v3 or require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v4 = v4 or require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
	local ancestorPanel = v3.GetAncestorPanelByInstance(self.Instance)

	if ancestorPanel then
		self._panel = ancestorPanel
	else
		warn("No panel found in the ancestry of the instance", self.Instance)
	end
end

function v:ApplyMarkers()
	self:RemoveMarkers()

	for _, child in self.Instance:GetChildren() do
		local name = child.Name
		local group = v5.GetGroupById(name)

		if not (group and v2.IsGroupExcluded(group)) then
			continue
		end

		local clone = exclusionMarkerTemplate:Clone()
		clone.LayoutOrder = 1000
		clone.Parent = child
		self._markerJanitor:Add(clone)
	end
end

function v:RemoveMarkers()
	self._markerJanitor:Cleanup()
end

function v:Start()
	if self._panel:IsOpen() then
		self:ApplyMarkers()
	end

	self._panel:RegisterListener(self, "Opening", function()
		self:ApplyMarkers()
	end)
	self._panel:RegisterListener(self, "Closing", function()
		self:RemoveMarkers()
	end)
	self._Janitor:Add(v2.OnPlayerExclusionGroupsChanged:Connect(function()
		if self._panel:IsOpen() then
			self:ApplyMarkers()
		end
	end))
	self._Janitor:Add(v2.OnPlayerExclusionGroupsCleared:Connect(function()
		if self._panel:IsOpen() then
			self:RemoveMarkers()
		end
	end))
end

function v:Stop()
	if self._panel then
		self._panel:UnregisterListener(self, "Opening")
		self._panel:UnregisterListener(self, "Closing")
	end

	self._Janitor:Destroy()
	self._markerJanitor:Destroy()
end

return v