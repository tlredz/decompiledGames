local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "BowArrowProjectile"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self.Instance:AddTag("OrientPartToVelocity")
	local _ = { "rbxassetid://77797904619226", "rbxassetid://118975295665431", "rbxassetid://129243328337789" }
	self._Janitor:Add(instance:GetPropertyChangedSignal("Anchored"):Connect(function()
		if not instance.Anchored then
			return
		end

		self.Instance:RemoveTag("OrientPartToVelocity")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v