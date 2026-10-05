local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "CountdownButton"
})

local function onPanelOpen(state)
	local countdown = state.Instance:FindFirstChild("Countdown")

	if countdown == nil then
		return
	end

	local label = countdown:FindFirstChild("Label")
	state._wasOpened = true
	state.Instance.Interactable = false
	state._task = task.spawn(function()
		local lastTime = tick()

		while RunService:IsRunning() and tick() - lastTime < state._duration do
			local v2 = state._duration - (tick() - lastTime)
			label.Text = math.floor(v2 % 60)
			task.wait(1)
		end

		if state._destroyOnComplete then
			countdown:Destroy()
		end

		state.Instance.Interactable = true
		state._task = nil
	end)
end

function v:Construct()
	self._janitor = Janitor.new()
	self._duration = self.Instance:GetAttribute("CountdownDuration") or 5
	self._destroyOnComplete = self.Instance:GetAttribute("CountdownDestroyOnComplete") or true
	self._wasOpened = false
	self._task = nil
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)

	if waitForAncestorComponent == nil then
		warn("CountdownButton not inside valid panel")
		return
	end

	waitForAncestorComponent:RegisterListener(self, waitForAncestorComponent.Events.Opening, function()
		onPanelOpen(self)
	end)

	if waitForAncestorComponent:IsOpen() then
		onPanelOpen(self)
	end

	self._janitor:Add(function()
		waitForAncestorComponent:UnregisterListener(self, waitForAncestorComponent.Events.Opening)
	end, true)
end

function v:Stop()
	self._janitor:Destroy()

	if self._task ~= nil then
		task.cancel(self._task)
		self._task = nil
	end

	if self._wasOpened then
		self.Instance.Interactable = true
	end
end

return v