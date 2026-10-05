local PanelController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
local PanelGroups = require(ReplicatedStorage.Modules.Client.UI.PanelGroups)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LazyPanels = require(ReplicatedStorage.Modules.Client.UI.LazyPanels)
PanelController.MAIN_VIEW = "MainView"
PanelController.PanelRegistration = Signal.new()
PanelController.OnPanelOpened = Signal.new()
PanelController.OnPanelClosed = Signal.new()
PanelController.OnGroupClosed = Signal.new()
PanelController.OnGroupOpened = Signal.new()
local v = RunService:IsStudio() and 5 or 30
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local v2 = {}
local v3 = {}
local v4 = {}

local function warno(...)
	print(debug.traceback())
	warn("[PanelController]", ...)
end

function PanelController.OpenPanelByContext(p: string, p2: string, ...)
	PanelController.ToggleGroup(PanelController.MAIN_VIEW, false)
	PanelController.Open(p, p2)
end

function PanelController.ToggleGroup(p: string, flag: boolean)
	for k, v5 in PanelGroups[p] do
		for k2, _ in v5 do
			if not PanelController.IsUnloadedLazyPanel(k, k2) then
				(flag and PanelController.Open or PanelController.Close)(k, k2)
			end
		end
	end

	if flag then
		PanelController.OnGroupOpened:Fire(p)
	else
		PanelController.OnGroupClosed:Fire(p)
	end
end

function PanelController.TogglePanelByGroup(p: string, p2: string, p3: string)
	if PanelController.IsOpen(p, p2) then
		PanelController.Close(p, p2)
		return
	end

	PanelController.ToggleGroup(p3, false)
	PanelController.OpenPanelByContext(p, p2)
end

function PanelController.RegisterPanel(panel)
	local context = panel:GetContext()

	if not context then
		warno("Panel has no context")
		return
	end

	if v2[context.Name] ~= nil and v2[context.Name].panels[panel.Instance.Name] ~= nil and v2[context.Name].panels[panel.Instance.Name].panel ~= nil then
		error("Duplicate panel, context: " .. context.Name .. ", name: " .. panel.Instance.Name)
	end

	local v5 = v2[context.Name]

	if v5 == nil or v5.latch:getCount() > 0 then
		if v3[context.Name] then
			if v3[context.Name] and v3[context.Name] ~= context then
				warno("Context with name " .. tostring(context.Name) .. " already exists and is different from the current context!")
			end
		else
			v3[context.Name] = context
		end

		local maid = Janitor.new()
		v4[context] = maid
		maid:Add(context.Destroying:Connect(function()
			if not v4[context] then
				return
			end

			if v3[context.Name] == context then
				v3[context.Name] = nil
			end

			v2[context.Name] = nil
			v4[context]:Destroy()
			v4[context] = nil
		end))

		if v5 == nil then
			v2[context.Name] = {
				latch = CountDownLatch.new(0),
				panels = {}
			}
		else
			v5.latch:countDown()
		end
	end

	local panel2 = v2[context.Name].panels[panel.Instance.Name]

	if panel2 then
		panel2.panel = panel
		panel2.latch:countDown()
	else
		v2[context.Name].panels[panel.Instance.Name] = {
			latch = CountDownLatch.new(0),
			panel = panel
		}
	end

	PanelController.PanelRegistration:Fire(context.Name, panel.Instance.Name)
end

function PanelController.UnregisterPanel(object)
	local context = object:GetContext()

	if not context then
		warno("Panel has no context")
		return
	end

	if not v2[context.Name] then
		return
	end

	v2[context.Name].panels[object.Instance.Name] = nil
end

function PanelController.IsRegistered(p: string, p2: string)
	return v2[p] ~= nil and v2[p].panels[p2] ~= nil
end

function PanelController.GetContextByName(p: string)
	if v2[p] == nil then
		v2[p] = {
			latch = CountDownLatch.new(1),
			panels = {}
		}
	end

	v2[p].latch:await()
	return v3[p]
end

function PanelController.GetAncestorPanelByInstance(p)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(p, "Panel", Panel)

	if waitForAncestorComponent then
		return waitForAncestorComponent
	end

	if RunService:IsStudio() then
		warno("No panel component found in the ancestry of the instance", p)
	end

	return nil
end

function PanelController.WaitForPanel(p: string, p2: string)
	if PanelController.IsUnloadedLazyPanel(p, p2) then
		PanelController.LoadLazy(p, p2, true)
	end

	if v2[p] == nil then
		v2[p] = {
			latch = CountDownLatch.new(1),
			panels = {}
		}
	end

	if not v2[p].latch:await(v) then
		warno("Panel context not loaded after " .. v .. " secs", p, p2)
		return nil
	end

	v2[p].latch:await()

	if v2[p].panels[p2] == nil then
		v2[p].panels[p2] = {
			latch = CountDownLatch.new(1),
			panel = nil
		}
	end

	if v2[p].panels[p2].latch:await(v) then
		v2[p].panels[p2].latch:await()
		return v2[p].panels[p2].panel
	end

	warno("Panel not loaded after " .. v .. " secs", p, p2)
	return nil
end

function PanelController.GetPanelContextByInstance(parent)
	while not (parent:IsA("PlayerGui") or parent:IsA("LayerCollector")) do
		parent = parent.Parent
	end

	return parent
end

function PanelController.GetPanelByInstance(parent)
	while not parent:HasTag("Panel") do
		parent = parent.Parent
	end

	return parent
end

function PanelController.GetPanelGroup(p: string)
	for k, panelGroup in PanelGroups do
		for _, v5 in panelGroup do
			if v5[p] then
				return k
			end
		end
	end

	return nil
end

function PanelController.IsInGroup(p: string, p2: string, p3: string)
	local panelGroup = PanelGroups[p]
	return panelGroup[p2] ~= nil and panelGroup[p2][p3] ~= nil
end

function PanelController.GetOpenPanelsByGroup(p: string)
	local result = {}

	for k, v5 in PanelGroups[p] do
		for k2, _ in v5 do
			if not (PanelController.IsRegistered(k, k2) and PanelController.IsOpen(k, k2)) then
				continue
			end

			table.insert(result, k2)
		end
	end

	return result
end

function PanelController.IsUnloadedLazyPanel(p: string, p2: string)
	local panel = LazyPanels.Panels[p]

	if panel ~= nil and panel[p2] ~= nil and (v2[p] == nil or v2[p].panels[p2] == nil) then
		return true
	end

	local manualPanel = LazyPanels.ManualPanels[p]
	return manualPanel ~= nil and manualPanel[p2] ~= nil and (v2[p] == nil or v2[p].panels[p2] == nil)
end

function PanelController.IsLazyPanel(p: string, p2: string)
	local panel = LazyPanels.Panels[p]
	return panel ~= nil and panel[p2] ~= nil
end

function PanelController.IsManualLazyPanel(p: string, p2: string)
	local manualPanel = LazyPanels.ManualPanels[p]
	return manualPanel ~= nil and manualPanel[p2] ~= nil
end

function PanelController.IsOpen(p: string, p2: string)
	if PanelController.IsUnloadedLazyPanel(p, p2) then
		return false
	end

	local v5 = PanelController.WaitForPanel(p, p2)

	if v5 then
		return v5:IsOpen()
	end

	return false
end

function PanelController:GetAttribute(p2: string, attributeName: string)
	local v5 = PanelController.WaitForPanel(self, p2)

	if v5 then
		return v5:GetInstance():GetAttribute(attributeName)
	end

	warno("Panel not found", p2, self)
end

function PanelController:SetAttribute(p2: string, p3: string, p4)
	local v5 = PanelController.WaitForPanel(self, p2)

	if v5 then
		v5:GetInstance():SetAttribute(p3, p4)
	else
		warno("Panel not found", p2, self)
	end
end

function PanelController.LoadLazy(p: string, p2: string, flag: boolean)
	if v2[p] == nil then
		v2[p] = {
			latch = CountDownLatch.new(1),
			panels = {}
		}
	end

	if v2[p].panels[p2] ~= nil then
		return false
	end

	v2[p].panels[p2] = {
		latch = CountDownLatch.new(1),
		panel = nil
	}
	Remotes.fireServer("LoadPanel", p, p2, flag)
	return true
end

function PanelController.Open(p: string, p2: string)
	if PanelController.IsManualLazyPanel(p, p2) and not PanelController.IsRegistered(p, p2) then
		return
	end

	local v5 = PanelController.WaitForPanel(p, p2)

	if not v5 then
		warno("Panel not found", p2, p)
		return
	end

	if v5:Open() then
		PanelController.OnPanelOpened:Fire(p, p2)
	end

	local dependency = LazyPanels.Dependencies[p]

	if dependency ~= nil and dependency[p2] ~= nil then
		for _, v6 in dependency[p2] do
			PanelController.LoadLazy(v6.context, v6.name, false)
		end
	end
end

function PanelController.Close(p: string, p2: string)
	if PanelController.IsManualLazyPanel(p, p2) and not PanelController.IsRegistered(p, p2) or PanelController.IsUnloadedLazyPanel(
		p,
		p2
	) then
		return
	end

	local v5 = PanelController.WaitForPanel(p, p2)

	if not v5 then
		warno("Panel not found", p2, p)
	elseif v5:Close() then
		PanelController.OnPanelClosed:Fire(p, p2)
	end
end

function PanelController.Toggle(p: string, p2: string)
	if PanelController.IsOpen(p, p2) then
		PanelController.Close(p, p2)
	else
		PanelController.Open(p, p2)
	end
end

function PanelController.GetPanel(p: string, p2: string)
	local v5 = PanelController.WaitForPanel(p, p2)

	if v5 then
		return v5
	end

	warno("Panel not found", p2, p)
end

function PanelController.FrameworkInit(_)
	local Panel2 = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
	Panel = Panel2
end

function PanelController.FrameworkStart(_)
	local Players = game:GetService("Players")
	Players.LocalPlayer.CharacterRemoving:Connect(function()
		PanelController.ToggleGroup("CloseOnRespawn", false)
	end)
end

if RunService:IsServer() then
	error("PANEL CONTROLLER IS BEING REQUIRED ON THE SERVER")
end

return PanelController