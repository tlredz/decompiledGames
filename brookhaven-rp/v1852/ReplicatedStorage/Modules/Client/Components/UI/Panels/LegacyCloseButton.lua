local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = 0
local instances = {}
local v2 = {}
local v3 = nil

local function removePanelFromStack(instance)
	for i = #instances, 1, -1 do
		if instances[i] ~= instance then
			continue
		end

		table.remove(instances, i)
		break
	end
end

local function getTopClosablePanel()
	while #instances > 0 do
		local v4 = instances[#instances]

		if v4 and v4.Parent and v2[v4] and v4.Visible then
			return v4
		else
			table.remove(instances, #instances)
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncPanelStack(instance)
	if v2[instance] and instance.Parent and instance.Visible then
		removePanelFromStack(instance)
		table.insert(instances, instance)
	else
		removePanelFromStack(instance)
	end
end

local function addClosablePanel(p)
	v2[p] = (v2[p] or 0) + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeClosablePanel(_trackedPanel)
	local v4 = v2[_trackedPanel]

	if not v4 then
		return
	end

	local v5 = v4 - 1

	if v5 <= 0 then
		v2[_trackedPanel] = nil
		removePanelFromStack(_trackedPanel)
	else
		v2[_trackedPanel] = v5
		syncPanelStack(_trackedPanel) -- equivalent call inferred; original call site unknown
	end
end

local v4 = Component.new({
	Tag = "LegacyCloseButton"
})

function v4:Construct()
	self._Janitor = Janitor.new()
	self._panelJanitor = Janitor.new()
	self._Janitor:Add(self._panelJanitor)
	self._hasBackActionBinding = false
end

function v4:IsInstanceClickable()
	return self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")
end

function v4:GetPanelValueObject()
	local panel = self.Instance:FindFirstChild("Panel")

	if panel and panel:IsA("ObjectValue") then
		return panel
	end

	for _, objectValue in self.Instance:GetChildren() do
		if objectValue:IsA("ObjectValue") then
			return objectValue
		end
	end

	return nil
end

function v4:SetTrackedPanel(trackedPanel)
	if self._trackedPanel == trackedPanel then
		if trackedPanel then
			syncPanelStack(trackedPanel) -- equivalent call inferred; original call site unknown
		end
	else
		if self._trackedPanel then
			removeClosablePanel(self._trackedPanel) -- equivalent call inferred; original call site unknown
		end

		self._panelJanitor:Cleanup()
		self._trackedPanel = nil

		if not trackedPanel then
			return
		end

		self._trackedPanel = trackedPanel
		v2[trackedPanel] = (v2[trackedPanel] or 0) + 1
		syncPanelStack(trackedPanel) -- equivalent call inferred; original call site unknown
		self._panelJanitor:Add(trackedPanel:GetPropertyChangedSignal("Visible"):Connect(function()
			syncPanelStack(trackedPanel) -- equivalent call inferred; original call site unknown
		end))
		self._panelJanitor:Add(trackedPanel:GetPropertyChangedSignal("Parent"):Connect(function()
			syncPanelStack(trackedPanel) -- equivalent call inferred; original call site unknown
		end))
	end
end

function v4:ClosePanel()
	local _trackedPanel = self._trackedPanel

	if not (_trackedPanel and _trackedPanel.Parent) then
		_trackedPanel = self:GetPanelFromValueObject()
	end

	if _trackedPanel then
		_trackedPanel.Visible = false
	else
		warn("LegacyCloseButton has no valid panel reference", self.Instance)
	end
end

function v4:GetPanelFromValueObject()
	if not self._panelValueObject then
		return nil
	end

	local value = self._panelValueObject.Value

	if value and value:IsA("GuiObject") then
		return value
	end

	return nil
end

function v4:Start()
	self._hasBackActionBinding = false

	if not self:IsInstanceClickable() then
		return
	end

	self.Instance.SelectionOrder = 10000
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:ClosePanel()
	end))
	local v5, v6 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

	if v5 and not v6 then
		return
	end

	if not self.Instance:GetAttribute("NoConsoleGlyph") then
		local X = self.Instance:FindFirstChild("X")

		if X and X:IsA("ImageLabel") then
			if typeof(X:GetAttribute("ConsoleGlyphKeyCode")) ~= "string" then
				X:SetAttribute("ConsoleGlyphKeyCode", "ButtonB")
			end

			if not X:HasTag("ConsoleGlyphImage") then
				X:AddTag("ConsoleGlyphImage")
			end
		end
	end

	v += 1
	self._hasBackActionBinding = true

	if v == 1 then
		v3 = BackActionRouter.Bind(function()
			local topClosablePanel = getTopClosablePanel()

			if not topClosablePanel then
				return
			end

			topClosablePanel.Visible = false
		end, function()
			return getTopClosablePanel() ~= nil
		end)
	end

	self._panelValueObject = self:GetPanelValueObject()

	if not self._panelValueObject then
		warn("LegacyCloseButton expected an ObjectValue child named 'Panel'", self.Instance)
		return
	end

	self._Janitor:Add(self._panelValueObject:GetPropertyChangedSignal("Value"):Connect(function()
		self:SetTrackedPanel(self:GetPanelFromValueObject())
	end))
	self:SetTrackedPanel(self:GetPanelFromValueObject())
end

function v4:Stop()
	if self._trackedPanel then
		removeClosablePanel(self._trackedPanel) -- equivalent call inferred; original call site unknown
		self._trackedPanel = nil
	end

	self._panelJanitor:Cleanup()

	if self:IsInstanceClickable() and self._hasBackActionBinding then
		v -= 1

		if v <= 0 then
			v = 0

			if v3 then
				v3()
				v3 = nil
			end

			table.clear(instances)
			table.clear(v2)
		end
	end

	self._hasBackActionBinding = false
	self._Janitor:Destroy()
end

return v4