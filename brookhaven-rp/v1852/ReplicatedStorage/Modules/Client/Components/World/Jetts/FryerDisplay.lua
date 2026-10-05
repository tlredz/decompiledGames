local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Timer = require(ReplicatedStorage.Packages.Timer)
local JettsConfig = require(ReplicatedStorage.Modules.Shared.DB.World.JettsConfig)
local v = Component.new({
	Tag = "FryerDisplay"
})
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(30, 238, 44)
local color3 = Color3.fromRGB(238, 35, 35)

function v:Construct()
	self._Janitor = Janitor.new()
	self.dingPlayed = false
end

function v:EnableTimer()
	self.startFryingTime = workspace:GetServerTimeNow()

	if self.timerConnection then
		return
	end

	if not self.timer then
		self.timer = self._Janitor:Add(Timer.new(0.1))
	end

	self.timer:Start()
	local config = JettsConfig.GetConfig()
	self.timerConnection = self.timer.Tick:Connect(function()
		local v2 = workspace:GetServerTimeNow() - self.startFryingTime
		local v3, v4, v5

		if v2 < config.GoodFoodTime then
			self.indicatorLight.Color = color
			v3 = math.clamp(v2 / config.GoodFoodTime, 0, 1)
			self.dingPlayed = false
			v4 = 53
			v5 = 10
		elseif v2 < config.BurningTimer then
			self.indicatorLight.Color = color2
			v5 = 53
			v4 = 127
			v3 = math.clamp((v2 - config.GoodFoodTime) / (config.BurningTimer - config.GoodFoodTime), 0, 1)

			if not self.dingPlayed then
				self.dingSound:Play()
				self.dingPlayed = true
			end
		else
			self.indicatorLight.Color = color3
			v3 = math.clamp((v2 - config.BurningTimer) / (config.DisplayRotationEndTime - config.BurningTimer), 0, 1)
			v4 = 170
			v5 = 127
		end

		local rotation = v5 + v3 * (v4 - v5)
		self.arrowFrame.Rotation = rotation
	end)
	self._Janitor:Add(self.timerConnection)
end

function v:DisableTimer()
	if self.timerConnection then
		self._Janitor:Remove(self.timerConnection)
		self.timerConnection:Disconnect()
		self.timerConnection = nil
	end

	if self.timer ~= nil then
		self.timer:Stop()
	end

	self.indicatorLight.Color = color
	self.arrowFrame.Rotation = 10
end

function v:UpdateDisplay(p)
	if p then
		self:EnableTimer()
	else
		self:DisableTimer()
	end
end

function v:Start()
	local surfaceGui = self.Instance:FindFirstChild("SurfaceGui")

	if not surfaceGui then
		return
	end

	self.arrowFrame = surfaceGui:FindFirstChild("Arrow")
	self.arrowFrame.Rotation = 10
	self.indicatorLight = self.Instance:FindFirstChild("IndicatorLight")
	self.dingSound = self.indicatorLight:FindFirstChild("Ding")
	self.indicatorLight.Color = color
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "CurrentToolChanged", function(p)
		self:UpdateDisplay(p)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v