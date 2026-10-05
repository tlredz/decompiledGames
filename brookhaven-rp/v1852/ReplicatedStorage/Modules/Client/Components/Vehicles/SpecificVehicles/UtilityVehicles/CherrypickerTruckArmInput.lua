local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CherrypickerTruckArmInput"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.clicker = self._Janitor:Add(Instance.new("ClickDetector"))
	self.clicker.MaxActivationDistance = 15
	self.clicker.Parent = self.Instance
	self.activationAction = self.Instance:GetAttribute("Action")
	assert(self.activationAction, "ActivationAction attribute not found on " .. self.Instance:GetFullName())
	self.actionAmount = tonumber(self.Instance:GetAttribute("Amount"))
	assert(self.actionAmount, "Amount attribute not found on " .. self.Instance:GetFullName())
end

function v:ObtainTruckComponentInstance()
	local instance = self.Instance

	while instance and not instance:HasTag("CherrypickerTruckArm") do
		instance = instance.Parent
	end

	return instance
end

function v:Start()
	self._Janitor:Add(self.clicker.MouseClick:Connect(function(_)
		Remotes.fireServerComponentUnreliable(
			self:ObtainTruckComponentInstance(),
			self.activationAction,
			self.actionAmount
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v