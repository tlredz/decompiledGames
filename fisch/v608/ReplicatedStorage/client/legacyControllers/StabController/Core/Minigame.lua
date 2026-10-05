game:GetService("UserInputService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.shared.modules.Hook)
require(ReplicatedStorage.shared.modules.library.fish)
require("../Types")
local Minigame = {}
Minigame.__index = Minigame

function Minigame.new(current)
	local object = setmetatable({}, Minigame)
	object.current = current
	object.trove = current.trove:Extend()
	object._progressModifier = current:CreateModifier("progress", "add")
	return object
end

function Minigame:Start()
	self._progressModifier.Value = self.current.stats.StartingProgress / self.current.trueprogressefficiency
	local count = 0
	self.trove:Add(self.current.OnSlash:Connect(function()
		count += 1
	end))
	self.trove:Add(self.current.BuildEndingData:Bind(function(p)
		p.SlashCount = count
		return p
	end))
end

function Minigame:Disable()
	self.Disabled = true
end

function Minigame.Stop(p)
	p.trove:Clean()
end

function Minigame:Tick(p: number)
	if self.Disabled or not self.current.active then
		return
	end

	local onbar = self.current.onbar
	self.current.onbar = self.current:IsInBar(self.current.fishPosition, 0.01)

	if self.current.onbar then
		if not onbar then
			self.current.OnFishEnterBar:Fire()
		end

		self._progressModifier.Value += 0.2 * self.current.progressefficiency * (p * 60)
	else
		if onbar then
			self.current.OnFishExitBar:Fire()
		end

		self.current.perfect = false
		self._progressModifier.Value -= p * 60 * 0.2 * self.current.progressLossMultiplier / self.current.trueprogressefficiency
	end

	if self.current.progress <= 0 and not self.NoFail or self.current.progress >= 100 then
		self.current:EndMinigame()
	end
end

return Minigame