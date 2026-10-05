local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Panel"
})
local v2 = nil
local v3 = { "ScreenGui", "SurfaceGui" }
local v4 = { "Frame", "ScrollingFrame" }
v.__index = v
v.Events = {
	Opening = "Opening",
	Closing = "Closing"
}

function v:Construct()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v2 = PanelController
	self._Janitor = Janitor.new()
	self._Listeners = {}
	local instance = self.Instance
	local v5 = false

	for _, className in v4 do
		if not instance:IsA(className) then
			continue
		end

		v5 = true
		break
	end

	if not v5 then
		warn("[Panel]", instance:GetFullName(), "Panel is not allowed to be used!")
		return
	end

	local panelContext = nil

	for _, className in v3 do
		panelContext = instance:FindFirstAncestorOfClass(className)

		if panelContext then
			break
		end
	end

	if not panelContext then
		return
	end

	self.panelContext = panelContext
end

function v.GetContext(p)
	return p.panelContext
end

function v.GetInstance(p)
	return p.Instance
end

function v.IsOpen(p)
	return p.Instance.Visible
end

function v:Open()
	self:NotifyEvent(self.Events.Opening, {})

	if self.Instance.Visible then
		return false
	end

	self.Instance.Visible = true
	return true
end

function v:Close()
	self:NotifyEvent(self.Events.Closing, {})

	if not self.Instance.Visible then
		return false
	end

	self.Instance.Visible = false
	return true
end

function v:RegisterListener(p2, p3: string, callback)
	if not self._Listeners[p2] then
		self._Listeners[p2] = {}
	end

	self._Listeners[p2][p3] = callback
end

function v:UnregisterListener(p2, p3: string)
	if not (self._Listeners[p2] and self._Listeners[p2][p3]) then
		return
	end

	self._Listeners[p2][p3] = nil
end

function v:HasListeners()
	return next(self._Listeners) ~= nil
end

function v:NotifyEvent(p: string, p2)
	if not self:HasListeners() then
		return
	end

	for _, _Listener in self._Listeners do
		for k, v5 in _Listener do
			if k ~= p then
				continue
			end

			local v6 = v5
			task.spawn(function()
				v6(p2)
			end)
		end
	end
end

function v.RegisterPanel(p)
	if RunService:IsServer() then
		return
	end

	local playerGui = Players.LocalPlayer.PlayerGui

	if not p.Instance:IsDescendantOf(playerGui) then
		return
	end

	v2.RegisterPanel(p)
end

function v:Start()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Parent"):Connect(function()
		self:RegisterPanel()
	end))
	self:RegisterPanel()
end

function v:Stop()
	v2.UnregisterPanel(self)
	self._Janitor:Destroy()
end

return v