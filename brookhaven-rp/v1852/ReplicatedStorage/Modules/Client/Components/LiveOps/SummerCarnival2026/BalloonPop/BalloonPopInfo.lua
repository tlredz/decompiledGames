local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local BalloonPopMinigame = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.BalloonPop.BalloonPopMinigame)
local BalloonPopConstants = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.BalloonPop.BalloonPopConstants)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local BalloonPopSeat = require(script.Parent.BalloonPopSeat)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "BalloonPopInfo"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._seatJanitor = self._Janitor:Add(Janitor.new())
	local exit = self.Instance.Exit
	self._cooldownFrame = exit.Cooldown
	self._barFrame = self._cooldownFrame.Bar
	local gameInfo = exit.GameInfo
	self._scoreLabel = gameInfo.ScoreInfo.Score
	self._timeInfoFrame = gameInfo.TimeInfo
	self._timeRemainingLabel = self._timeInfoFrame.TimeRemaining
	self._timeInfoFrame.Visible = false
end

function v:_setScore(text: number)
	self._scoreLabel.Text = text
end

function v:_setTimeRemaining(text: number)
	self._timeInfoFrame.Visible = text > 0
	self._timeRemainingLabel.Text = text
end

function v:_onShot(_)
	self._barFrame.Size = UDim2.fromScale(0, 1)
	self._cooldownFrame.Visible = true
	TweenService:Create(self._barFrame, TweenInfo.new(BalloonPopConstants.SHOOT_COOLDOWN, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(1, 1)
	}):Play()
	self._seatJanitor:Add(task.delay(BalloonPopConstants.SHOOT_COOLDOWN, function()
		self._cooldownFrame.Visible = false
	end))
end

function v:_onSatInSeat(object2)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		object2.Instance,
		"BalloonPopMinigame",
		BalloonPopMinigame
	)
	assert(
		waitForAncestorComponent,
		(`BalloonPopInfo: BalloonPopMinigame ancestor not found from seat {object2.Instance:GetFullName()}`)
	)
	self:_setScore(0)
	self._timeInfoFrame.Visible = false
	self._seatJanitor:Add(self.Instance.Exit.MouseButton1Click:Connect(function()
		object2:ForceExitSeat()
	end))
	self._seatJanitor:Add(object2.Shot:Connect(function(...)
		self:_onShot(...)
	end))
	self._seatJanitor:Add(waitForAncestorComponent.ScoreUpdated:Connect(function(p: number)
		self:_setScore(p)
	end))
	self._seatJanitor:Add(waitForAncestorComponent.TimeRemainingUpdated:Connect(function(p: number)
		self:_setTimeRemaining(p)
	end))
end

function v:_onExitedSeat()
	self._seatJanitor:Cleanup()
	self._timeInfoFrame.Visible = false
end

function v:Start()
	if BalloonPopSeat.CurrentLocalSeat then
		task.spawn(function()
			self:_onSatInSeat(BalloonPopSeat.CurrentLocalSeat)
		end)
	end

	self._Janitor:Add(BalloonPopSeat.LocalSatInSeat:Connect(function(...)
		self:_onSatInSeat(...)
	end))
	self._Janitor:Add(BalloonPopSeat.LocalExitedSeat:Connect(function(...)
		self:_onExitedSeat(...)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v