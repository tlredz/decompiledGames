local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local BalloonPopSeat = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.BalloonPop.BalloonPopSeat)
local BalloonPopConstants = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.BalloonPop.BalloonPopConstants)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "BalloonPopMinigame"
})

local function playShootEffect(instance)
	local cork = instance:FindFirstChild("Cork")

	if not cork then
		warn((`BalloonPopMinigame: Cork not found on {instance:GetFullName()}`))
		return
	end

	local shoot = cork:FindFirstChild("Shoot")

	if shoot then
		shoot:Play()
	else
		warn((`BalloonPopMinigame: Shoot sound not found on {cork:GetFullName()}`))
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._seatJanitor = self._Janitor:Add(Janitor.new())
	self.ScoreUpdated = Signal.new()
	self.TimeRemainingUpdated = Signal.new()
	self._balloonsFolder = self.Instance:FindFirstChild("Balloons")
	assert(self._balloonsFolder, (`BalloonPopMinigame: Balloons folder not found on {self.Instance:GetFullName()}`))
end

function v:_inflateBalloon(instance)
	local attribute = instance:GetAttribute(BalloonPopConstants.BALLOON_INFLATED_SIZE_ATTRIBUTE)

	if typeof(attribute) ~= "Vector3" then
		return
	end

	TweenService:Create(instance, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Size = attribute
	}):Play()
	local inflate = instance:WaitForChild("Inflate", 1)

	if inflate then
		inflate:Play()
	end
end

function v:Start()
	for _, child in self._balloonsFolder:GetChildren() do
		local v2 = child
		task.spawn(function()
			self:_inflateBalloon(v2)
		end)
	end

	self._Janitor:Add(self._balloonsFolder.ChildAdded:Connect(function(child)
		self:_inflateBalloon(child)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ShootEffect", function(p)
		playShootEffect(p)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ScoreUpdated", function(p: number)
		self.ScoreUpdated:Fire(p)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "TimeRemainingUpdated", function(p: number)
		self.TimeRemainingUpdated:Fire(p)
	end))
	self._Janitor:Add(BalloonPopSeat.LocalSatInSeat:Connect(function(object2)
		self._seatJanitor:Add(object2.Shot:Connect(function(p)
			playShootEffect(object2:GetGun())
			Remotes.fireServerComponent(self.Instance, "Shot", p)
		end))
	end))
	self._Janitor:Add(BalloonPopSeat.LocalExitedSeat:Connect(function()
		self._seatJanitor:Cleanup()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v