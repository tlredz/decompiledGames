local ClickDetector = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local BindableEvent = require(script.Parent.BindableEvent)

if isServer then
	local Server = require(game.ServerScriptService.Server)
	Server.Events.GenericInteract:NetworkConnect(function(p, p2)
		local v = ClickDetector[p2]

		if v then
			v.Event:Fire(p)
		end
	end)
	Server.Events.EndGenericInteract:NetworkConnect(function(p, p2)
		local v = ClickDetector[p2]

		if v then
			v.EndedEvent:Fire(p)
		end
	end)
else
	local localPlayer = game.Players.LocalPlayer
	local Client = require(localPlayer.PlayerScripts.Client)
	Client.Events.GenericInteract:Connect(function(p)
		local v = ClickDetector[p]

		if v then
			v.Event:Fire(localPlayer)
		end
	end)
	Client.Events.EndGenericInteract:Connect(function(p)
		local v = ClickDetector[p]

		if v and v.EndedEvent then
			v.EndedEvent:Fire(localPlayer)
		end
	end)
end

function ClickDetector.new(p, p2: string, onEvent, onEndedEvent, p3)
	local self = setmetatable({}, {
		__index = ClickDetector
	})
	self.Item = p
	self.Item:SetAttribute("Interaction", isServer and "Server" or "Client")

	if p2 then
		self:SetLabel(p2)
	end

	self.Event = BindableEvent.new()
	self.EndedEvent = BindableEvent.new()

	if p3 and p3.TapToHold then
		self.TapToHold = true
		self.Item:SetAttribute("TapToHold", true)
	end

	local eventConnection

	if onEvent then
		eventConnection = self.Event:Connect(onEvent)
	end

	local endedEventConnection

	if onEndedEvent then
		endedEventConnection = self.EndedEvent:Connect(onEndedEvent)
	end

	ClickDetector[p] = self
	return self, eventConnection, endedEventConnection
end

function ClickDetector:SetLabel(mouseLabel)
	self.Item:SetAttribute("MouseLabel", mouseLabel)
end

function ClickDetector:Connect(onEvent)
	return self.Event:Connect(onEvent)
end

function ClickDetector:Destroy()
	self.Event:Destroy()
end

function ClickDetector.Enable(_)
	print("enable clickdetector")
end

function ClickDetector.Disable(_)
	print("disable clickdetector")
end

return ClickDetector