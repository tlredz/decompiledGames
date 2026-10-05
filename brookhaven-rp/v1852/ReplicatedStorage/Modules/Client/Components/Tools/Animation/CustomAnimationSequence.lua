local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "CustomAnimationSequence",
	Extensions = { require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar) }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnAnimationNumberUpdated = Signal.new()
	self.count = self.Instance:GetAttribute("CustomAnimationSequence_Count")
end

function v.GetCurrentAnimation(p)
	return p.Instance:GetAttribute("CurrentAnimation")
end

function v.GetAllAnimations(p)
	return p.animations
end

function v.GetAnimationCount(p)
	return p.count
end

function v.CycleNextAnimation(p)
	Remotes.fireServerComponent(p.Instance, "CycleNextAnimation")
end

function v:Start()
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("CurrentAnimation"):Connect(function()
		self.OnAnimationNumberUpdated:Fire(self.Instance:GetAttribute("CurrentAnimation"))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v