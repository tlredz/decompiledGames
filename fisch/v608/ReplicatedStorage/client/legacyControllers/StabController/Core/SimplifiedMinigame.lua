local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.packages.Trove)
local Signal = require(ReplicatedStorage.packages.Signal)
local spears = require(ReplicatedStorage.shared.modules.library.spears)
require("../Types")
require("./SimplifiedInput")
local SimplifiedMinigame = {}
SimplifiedMinigame.__index = SimplifiedMinigame

function SimplifiedMinigame.new(current)
	local object = setmetatable({}, SimplifiedMinigame)
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	object.NoFail = false
	object.PiercingRandom = current:GetRandom(-1)
	object.BaseClickGain = 1
	object.BaseDecayRate = 3
	object.MinBarSize = 0
	object.MaxBarSize = 1
	object.nextSimFishMove = 0
	object.OnPiercing = object.trove:Add(Signal.new())
	return object
end

function SimplifiedMinigame:Start()
	if not self.current.isSimplified then
		self:Disable()
		return
	end

	self.current:AddCleanupDelay(1)
	local simplifiedInput = self.current.core.simplifiedInput
	self.ProgressModifier = self.current:CreateModifier("progress", "add")

	if simplifiedInput then
		self.trove:Add(simplifiedInput.OnCorrectInput:Connect(function(p)
			self:OnCorrectClick(p)
		end))
		self.trove:Add(simplifiedInput.OnIncorrectInput:Connect(function(p, p2)
			self:OnIncorrectClick(p, p2)
		end))
	end

	self.current.reel_bar.fish.Visible = false
	self.current.reel_progress.Visible = false
	self.current.reel_progspeed.Visible = true
	self.current.reel_progspeed.Position = self.current.reel_progspeed.Position - UDim2.fromScale(0, 0.3)
	self.current.barPosition = 0.5
	self.ProgressModifier.Value += self.current.stats.StartingProgress
	self:UpdateBarSize()
end

function SimplifiedMinigame:CalculateClickGain()
	local v = math.clamp(self.current.resilience, 20, 500) / 50
	local v2 = math.max(self.current.progressefficiency, 0.2)
	local halfPower = self.current.power / 2
	return self.BaseClickGain * v * v2 * halfPower
end

function SimplifiedMinigame:CalculateDecayRate(p2)
	local v = 1 / math.max(self.current.progressefficiency, 0.15)
	local simplifiedInput = self.current.core.simplifiedInput

	if p2 then
		simplifiedInput.LastCorrectInput -= p2
	end

	local v2 = (tick() - simplifiedInput.LastCorrectInput) / math.max(
		(0.3 + self.current.handling / 100) * (math.clamp(self.current.resilience, 15, 500) / 50),
		0.01
	)
	local v3 = v * (self.current.progressLossMultiplier * v2)
	return self.BaseDecayRate * v3
end

function SimplifiedMinigame:UpdateBarSize()
	local v = self.MinBarSize + (self.MaxBarSize - self.MinBarSize) * self.current.reel_progress.bar.Size.X.Scale
	self.current.reel_playerbar.Size = UDim2.fromScale(v, self.current.reel_playerbar.Size.Y.Scale)
end

function SimplifiedMinigame:OnCorrectClick(_: string)
	if self.Disabled or not self.current.active then
		return
	end

	local clickGain = self:CalculateClickGain()

	if self.current.piercing > 0 then
		local v = self.current.piercing // 100
		local spear = spears[self.current.rodName]

		if self.PiercingRandom:NextNumber(0, 100) < self.current.piercing % 100 then
			v += 1
		end

		if v > 0 then
			clickGain *= 3 * v
			self.OnPiercing:Fire(v, clickGain)
			self.current.OnSlash:Fire("rod", "Piercing", clickGain)

			for i = 1, v do
				task.delay((i - 1) * 0.15, function()
					self.current.fx:Slash({
						Color = spear.Color,
						IconColor = spear.Color
					})
				end)
			end
		end
	end

	self.ProgressModifier.Value += clickGain / 3
	self:UpdateBarSize()

	if not self.current.onbar then
		self.current.onbar = true
		self.current.OnFishEnterBar:Fire()
	end

	if self.current.progress >= 100 then
		self.Disabled = true
		local uDim = UDim2.fromScale(self.MaxBarSize, self.current.reel_playerbar.Size.Y.Scale)
		local tween = TweenService:Create(
			self.current.reel_playerbar,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			self.current:EndMinigame(true)
		end)
	end
end

function SimplifiedMinigame:OnIncorrectClick(_: string, _: string)
	if self.Disabled or not self.current.active then
		return
	end

	local v = self:CalculateDecayRate(0.1) * 0.25
	self.ProgressModifier.Value -= v / 3
	self:UpdateBarSize()
	self.current.perfect = false
	self.current.fx:SpawnShake(self.current.reel_bar, 0.25, 0.1, 0.01, true, 0.8)
end

function SimplifiedMinigame:Disable()
	self.Disabled = true
end

function SimplifiedMinigame.Stop(p)
	p.trove:Clean()
end

function SimplifiedMinigame:Tick(p: number)
	if self.Disabled then
		return
	end

	if not self.current.active or self.current.core.simplifiedInput.LastCorrectInput == 0 then
		self:UpdateBarSize()
		return
	end

	self.nextSimFishMove -= p / math.max(self.current.resilience, 20)

	if self.nextSimFishMove <= 0 then
		self.current.OnFishMove:Fire(0, 0)
		self.nextSimFishMove += 0.1
	end

	local v = self:CalculateDecayRate() * p
	self.ProgressModifier.Value -= v / 3
	self:UpdateBarSize()
	local simplifiedInput = self.current.core.simplifiedInput

	if simplifiedInput and tick() - simplifiedInput.LastCorrectInput > self.current.handling / 100 + 0.3 and self.current.onbar then
		self.current.onbar = false
		self.current.OnFishExitBar:Fire()
		self.current.perfect = false
	end

	if self.current.progress >= 100 then
		self.current:EndMinigame(true)
	elseif self.current.progress <= 0 and not self.NoFail then
		self.current:EndMinigame(false)
	end
end

return SimplifiedMinigame