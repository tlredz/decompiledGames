local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MovingPlatform"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._moveTime = self.Instance:GetAttribute("MoveTime")
	self._prevPosition = self.Instance.Position
end

function v:Start()
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("GoalCFrame"):Connect(function()
		local goalCFrame = self.Instance:GetAttribute("GoalCFrame")

		if goalCFrame then
			self:UpdateGoalCFrame(goalCFrame)
		end
	end))

	if self.Instance:GetAttribute("GoalCFrame") then
		self:UpdateGoalCFrame(self.Instance:GetAttribute("GoalCFrame"))
	end
end

function v:UpdateGoalCFrame(cframe: CFrame)
	local tweenInfo = TweenInfo.new(self._moveTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	TweenService:Create(self.Instance, tweenInfo, {
		CFrame = cframe
	}):Play()
end

function v:SteppedUpdate(p: number)
	local position = self.Instance.Position
	local assemblyLinearVelocity = (position - self._prevPosition) / p
	self._prevPosition = position
	self.Instance.AssemblyLinearVelocity = assemblyLinearVelocity
end

function v:Stop()
	self._Janitor:Destroy()
end

return v