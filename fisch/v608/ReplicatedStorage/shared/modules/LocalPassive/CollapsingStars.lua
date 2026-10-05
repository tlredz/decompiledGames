local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("RunService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.shared.modules.library.rods)
require(ReplicatedStorage.shared.modules.fx)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local emit = require(ReplicatedStorage.packages.emit)
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
ReplicatedStorage:WaitForChild("world")
local CollapsingStars = {}
Random.new()

function CollapsingStars:SpawnOrb()
	emit.emit(self.VfxModel)

	for _, sound in self.VfxModel:GetDescendants() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end

	local v = fish[self.current.fish.Name]
	local v2

	if v.ForcedProgressEfficiency == nil then
		v2 = false
	else
		v2 = v.ForcedProgressEfficiency < 1
	end

	if v2 then
		if self.current.onbar then
			self.current:AddProgress(self.config.ProgressGain)
		else
			self.current:AddProgress(self.config.ProgressGainOffBar)
		end
	elseif self.current.onbar then
		self.current:AddProgress(self.config.ProgressGain_NonFPF)
	else
		self.current:AddProgress(self.config.ProgressGainOffBar_NonFPF)
	end

	self.NextPullCheck += self.config.Cooldown
	local total = 0

	repeat
		self.current.core.fish.CurrentTarget = self.current.barPosition
		self.current.core.fish.CurrentMoveTime = 1 / self.config.PullPower
		total += self.current:WaitLogic(0)
	until self.config.PullTime <= total
end

function CollapsingStars:Morph(_, object2)
	if self.config.ForcedProgressFishOnly ~= nil then
		local v = fish[object2.fish.Name]
		local v2

		if v.ForcedProgressEfficiency == nil then
			v2 = false
		else
			v2 = v.ForcedProgressEfficiency < 1
		end

		if v2 ~= self.config.ForcedProgressFishOnly then
			return
		end
	end

	self.Random = object2:GetRandom(98)
	task.spawn(function()
		if not object2.rod then
			warn("no rod, no stars for you")
			return
		end

		local mouth0 = object2.rod:WaitForChild("bobber"):WaitForChild("mouth0")
		local clone = script.VfxModels:WaitForChild(self.config.VfxName or "Default"):Clone()
		clone:PivotTo(CFrame.new(object2.fishPos or mouth0.WorldPosition))
		self.reelTrove:Add(clone)
		clone.Parent = workspace.active.debrisfx
		self.VfxModel = clone
		object2:WaitUntilReady()
		self.NextPullCheck = self.config.ChanceInterval
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
			if not self.current or not self.current.active or self.current.isPaused then
				return
			end

			self.NextPullCheck -= p

			if self.NextPullCheck <= 0 then
				self.NextPullCheck += self.config.ChanceInterval

				if self.Random:NextNumber(0, 100) < self.config.Chance then
					clone:PivotTo(CFrame.new(object2.fishPos or mouth0.WorldPosition))
					self:SpawnOrb()
				end
			end
		end))
	end)
end

setmetatable(CollapsingStars, module)
return CollapsingStars