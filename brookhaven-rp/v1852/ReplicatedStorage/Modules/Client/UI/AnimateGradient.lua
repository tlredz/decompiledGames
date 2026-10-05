local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AnimateGradient"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local animateSpeed = self.Instance:GetAttribute("AnimateSpeed")
	assert(typeof(animateSpeed) == "number")
	local tweenInfo = TweenInfo.new(animateSpeed, Enum.EasingStyle.Linear)
	local v2 = nil
	local completedConnection = nil
	local onCompleted

	onCompleted = function()
		self.Instance.Rotation = 0
		v2 = TweenService:Create(self.Instance, tweenInfo, {
			Rotation = 360
		})
		completedConnection = v2.Completed:Once(onCompleted)
		v2:Play()
	end

	onCompleted()
	self._Janitor:Add(function()
		if completedConnection ~= nil then
			completedConnection:Disconnect()
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v