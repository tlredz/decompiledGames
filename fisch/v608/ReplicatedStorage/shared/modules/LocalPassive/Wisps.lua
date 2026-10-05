local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.shared.modules.library.rods)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
local world = ReplicatedStorage:WaitForChild("world")
local random = Random.new()
local Wisps = {
	SpawnWisp = function(self)
		local unitVector = random:NextUnitVector()

		if unitVector.Y > 0 then
			unitVector *= createVector(1, -1, 1)
		end

		local v = (unitVector + createVector(0, -0.25, 0)) * 16
		local clone = self.IsNight and script.DarkWisp:Clone() or script.Wisp:Clone()
		local primaryPart = clone.PrimaryPart
		local maid = self.reelTrove:Extend()
		maid:Add(clone)
		local wispAnimTime = self.config.WispAnimTime
		local v2 = wispAnimTime + 0.2
		local cframe = CFrame.new(0, -25, 0)
		primaryPart.PivotOffset = CFrame.new(v) * CFrame.fromOrientation(0, math.rad((random:NextNumber(-180, 180))), 0)
		local cFrame = nil
		clone:PivotTo(CFrame.new(self.BobberMouth.WorldPosition) * cframe)
		clone.Parent = workspace.active.debrisfx
		maid:Add(self.current:DelayLogic(self.config.WispAnimTime + 0.2, function()
			self.current:AddProgress(self.IsNight and self.config.WispDamageNight or self.config.WispDamage)
		end))
		local children = script.appearSounds:GetChildren()
		local v3 = children[math.random(1, #children)]
		maid:Add(self.current:DelayLogic(self.config.WispAnimTime * 0.25, function()
			fx:PlaySound(v3, primaryPart, true, "FishingSound", localPlayer)
		end))
		local total = 0
		maid:Add(self.current.OnRenderStep:Connect(function(p)
			if not (self.BobberMouth and self.BobberMouth.Parent) then
				maid:Clean()
				return
			end

			total += p

			if total < wispAnimTime then
				local value = TweenService:GetValue(
					math.clamp(math.map(total, 0, wispAnimTime, 0, 1), 0, 1),
					Enum.EasingStyle.Quart,
					Enum.EasingDirection.Out
				)
				clone:PivotTo((CFrame.new(self.current.fishPos or self.BobberMouth.WorldPosition) * cframe):Lerp(
					CFrame.new(self.current.fishPos or self.BobberMouth.WorldPosition),
					value
				) * CFrame.fromOrientation(0, math.rad(value * 360), 0))
			else
				if not cFrame then
					cFrame = primaryPart.CFrame
					primaryPart.PivotOffset = CFrame.identity
				end

				local value = TweenService:GetValue(
					math.clamp(math.map(total, wispAnimTime, v2, 0, 1), 0, 1),
					Enum.EasingStyle.Quart,
					Enum.EasingDirection.In
				)
				clone:PivotTo(cFrame:Lerp(CFrame.new(self.current.fishPos or self.BobberMouth.WorldPosition), value))
			end

			if total - v2 > 1 then
				maid:Clean()
			end
		end))
	end,
	SpawnWispWave = function(self)
		fx:PlaySound(script.mainSound, self.BobberMouth, false, "FishingSound", localPlayer)

		for _ = 1, self.Random:NextInteger(self.config.WispCountMin, self.config.WispCountMax) do
			self:SpawnWisp()
			self.current:WaitLogic(0.08333333333333333)
		end
	end,
	Morph = function(self, _, object2)
		self.IsNight = world.cycle.Value == "Night"
		self.Random = object2:GetRandom(61)
		task.spawn(function()
			if not object2.rod then
				warn("no rod, no wisps for you")
				return
			end

			self.BobberMouth = object2.rod:WaitForChild("bobber"):WaitForChild("mouth0")
			object2:WaitUntilReady()

			while object2.active do
				local v = object2.resilience / 50
				local v2 = v < 0.1 and 0.1 or v
				object2:WaitLogic(self.Random:NextNumber(self.config.WispIntervalMin, self.config.WispIntervalMax) / (v2 * self.config.ResilienceFactor))

				if not object2.active then
					break
				end

				self:SpawnWispWave()
			end
		end)
	end
}
setmetatable(Wisps, module)
return Wisps