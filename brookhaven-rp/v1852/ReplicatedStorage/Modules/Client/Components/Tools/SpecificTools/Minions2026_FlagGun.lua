local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "Minions2026_FlagGun",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnAnimationNumberUpdated = self._Janitor:Add(Signal.new())
	local currentAnimation = self.Instance:GetAttribute("CurrentAnimation")
	self.currentAnimation = typeof(currentAnimation) ~= "number" and 1 or currentAnimation
end

function v.GetCurrentAnimation(p)
	return p.currentAnimation
end

function v.CycleNextAnimation(p)
	Remotes.fireServerComponent(p.Instance, "CycleNextAnimation")
end

function v:Start()
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("CurrentAnimation"):Connect(function()
		local currentAnimation = self.Instance:GetAttribute("CurrentAnimation")

		if typeof(currentAnimation) ~= "number" then
			return
		end

		self.currentAnimation = currentAnimation
		self.OnAnimationNumberUpdated:Fire(currentAnimation)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v