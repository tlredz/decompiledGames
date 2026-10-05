local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = 0
local v2 = {}
local maid = nil
local v3 = {}
local v4 = nil

local function getPanelKey(p: string, p2: string)
	return p .. "::" .. p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addClosablePanel(p: string, p2: string)
	local v5 = p .. "::" .. p2
	v3[v5] = (v3[v5] or 0) + 1
end

local function removeClosablePanel(p: string, p2: string)
	local v5 = p .. "::" .. p2
	local v6 = v3[v5]

	if not v6 then
		return
	end

	local v7 = v6 - 1

	if v7 <= 0 then
		v3[v5] = nil
	else
		v3[v5] = v7
	end
end

local function removePanelFromStack(p: string, p2: string)
	for i = #v2, 1, -1 do
		local v5 = v2[i]

		if not (v5.context == p and v5.name == p2) then
			continue
		end

		table.remove(v2, i)
		break
	end
end

local function startGlobalPanelTracking()
	if maid then
		return
	end

	maid = Janitor.new()
	maid:Add(PanelController.OnPanelOpened:Connect(function(context: string, name: string)
		if not v3[context .. "::" .. name] then
			return
		end

		removePanelFromStack(context, name)
		table.insert(v2, {
			context = context,
			name = name
		})
	end))
	maid:Add(PanelController.OnPanelClosed:Connect(function(p: string, p2: string)
		removePanelFromStack(p, p2)
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGlobalPanelTracking()
	if maid then
		maid:Destroy()
		maid = nil
	end

	table.clear(v2)
end

local v5 = Component.new({
	Tag = "ClosePanelButton"
})

function v5:Construct()
	self._Janitor = Janitor.new()
	self._hasBackActionBinding = false
	local PanelController2 = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	PanelController = PanelController2
end

function v5:IsInstanceClickable()
	return self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")
end

function v5:Start()
	self._hasBackActionBinding = false

	if not self:IsInstanceClickable() then
		return
	end

	self.Instance.SelectionOrder = 10000
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if self.Instance:GetAttribute("TargetCloseContext") or self.Instance:GetAttribute("TargetCloseName") then
			self:CloseFromAttributes()
		else
			self:CloseFromHierarchy()
		end
	end))
	local v6, v7 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

	if v6 and not v7 or self.Instance:GetAttribute("NoConsoleGlyph") then
		return
	end

	local X = self.Instance:FindFirstChild("X")

	if X and X:IsA("ImageLabel") then
		if typeof(X:GetAttribute("ConsoleGlyphKeyCode")) ~= "string" then
			X:SetAttribute("ConsoleGlyphKeyCode", "ButtonB")
		end

		if not X:HasTag("ConsoleGlyphImage") then
			X:AddTag("ConsoleGlyphImage")
		end
	end

	v += 1
	self._hasBackActionBinding = true

	if v == 1 then
		startGlobalPanelTracking()
		v4 = BackActionRouter.Bind(function()
			local v8 = v2[#v2]

			if not v8 then
				return
			end

			PanelController.Close(v8.context, v8.name)
		end, function()
			return v2[#v2] ~= nil
		end)
	end

	self._trackedPanels = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function trackPanel(context: string, name: string)
		addClosablePanel(context, name) -- equivalent call inferred; original call site unknown
		table.insert(self._trackedPanels, {
			context = context,
			name = name
		})
	end

	local targetCloseContext = self.Instance:GetAttribute("TargetCloseContext")
	local targetCloseName = self.Instance:GetAttribute("TargetCloseName")

	if targetCloseContext and targetCloseName then
		trackPanel(targetCloseContext, targetCloseName) -- equivalent call inferred; original call site unknown
	else
		local success, result = pcall(function()
			local panelContext = PanelController.GetPanelContextByInstance(self.Instance)
			local panel = PanelController.GetPanelByInstance(self.Instance)

			if panelContext and panel then
				trackPanel(panelContext.Name, panel.Name) -- equivalent call inferred; original call site unknown
			end
		end)

		if not success then
			warn("ClosePanelButton failed to resolve parent panel:", result)
		end
	end
end

function v5:CloseFromHierarchy()
	local name = PanelController.GetPanelContextByInstance(self.Instance).Name
	local name2 = PanelController.GetPanelByInstance(self.Instance).Name

	if name2 then
		PanelController.Close(name, name2)
	else
		warn("No panel name found for button", self.Instance)
	end
end

function v5:CloseFromAttributes()
	local targetCloseContext = self.Instance:GetAttribute("TargetCloseContext")
	local targetCloseName = self.Instance:GetAttribute("TargetCloseName")

	if targetCloseName and targetCloseContext then
		PanelController.Close(targetCloseContext, targetCloseName)
	else
		warn("Tried to close using provided attributes:", targetCloseContext, targetCloseName)
	end
end

function v5:Stop()
	if self._trackedPanels then
		for _, _trackedPanel in self._trackedPanels do
			local v6 = _trackedPanel.context .. "::" .. _trackedPanel.name
			local v7 = v3[v6]

			if v7 then
				local v8 = v7 - 1

				if v8 <= 0 then
					v3[v6] = nil
				else
					v3[v6] = v8
				end
			end

			removePanelFromStack(_trackedPanel.context, _trackedPanel.name)
		end

		self._trackedPanels = nil
	end

	if self:IsInstanceClickable() and self._hasBackActionBinding then
		v -= 1

		if v <= 0 then
			v = 0

			if v4 then
				v4()
				v4 = nil
			end

			stopGlobalPanelTracking() -- equivalent call inferred; original call site unknown
		end
	end

	self._hasBackActionBinding = false
	self._Janitor:Destroy()
end

return v5