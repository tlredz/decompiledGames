local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "Minions2026_Voicebox",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._lastClick = 0
end

function v:ActivatedButton(value: string, p: string)
	if p ~= "Activated" or (typeof(value) ~= "string" or value == "") then
		return
	end

	local now = os.clock()

	if now - self._lastClick < 3 then
		return
	end

	self._lastClick = now
	Remotes.fireServerComponent(self.Instance, "PlaySound", value)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v