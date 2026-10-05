local MoonlightRay = {}
game:GetService("ContentProvider")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContextActionService")
game:GetService("UserInputService")
game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("rodmusic")
Random.new()

function MoonlightRay:SpawnBeam(p: number)
	local clone = script.warning:Clone()
	local laser = clone.laser
	local absoluteSize = self.reel.Parent.AbsoluteSize
	local absolutePosition = self.reel.Parent.AbsolutePosition
	local absolutePosition2 = self.reel.AbsolutePosition
	local v = absoluteSize.Y - absolutePosition.Y - absolutePosition2.Y
	clone.Size = UDim2.new(self.config.BeamWidth, 0, 0, absoluteSize.Y + GuiService:GetGuiInset().Y)
	clone.Position = UDim2.new(p, 0, 0, v)
	clone.Parent = self.laserContainer
	laser.detail1.Position = UDim2.fromScale(0.5, 0)
	laser.detail2.Position = UDim2.fromScale(0.5, 0)
	laser.detail3.Position = UDim2.fromScale(0.5, -2)
	self.current.logicTweens:CreateAndPlay(laser.detail1, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0.5, -2)
	})
	self.current.logicTweens:CreateAndPlay(laser.detail2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0.5, -2)
	})
	self.current.logicTweens:CreateAndPlay(laser.detail3, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0.5, 0)
	})
	self.current:DelayLogic(0.25, function()
		for _, child in laser:GetChildren() do
			self.current.renderTweens:CreateAndPlay(child, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			})
		end
	end)
	fx:PlaySound(script.LaserSound, self.reel, false, "FishingSound")
	self.current:AddProgress(self.config.ProgressGain)
	self.current.core.fish:DelayNextMovement(self.config.FlingTime)

	if not self.config.DisableCenterFling then
		self.current.core.fish:ForceMoveTo(0.5, self.config.FlingTime, 0.5 - self.current.fishPosition)
	end

	self.current:WaitLogic(0.7)
	clone:Destroy()
end

function MoonlightRay:Morph(parent, object2)
	self.laserContainer = script.laserContainer:Clone()
	self.laserContainer.Parent = parent
	local random = object2:GetRandom(92)
	self.reelTrove:Add(task.spawn(function()
		object2:WaitUntilReady()
		local metronomeBuff = self.config.UseMetronomeTiming and object2:FindFirstPassive("MetronomeBuff")

		if metronomeBuff then
			local count = 0
			local integer = random:NextInteger(self.config.MinInterval, self.config.MaxInterval)
			self.reelTrove:Add(metronomeBuff.MetronomeDirectionChanged:Connect(function()
				if not object2.active or object2.isPaused or object2.logicPaused then
					return
				end

				if math.floor((metronomeBuff:GetCurrentBeat())) % 4 == 0 then
					count += 1

					if integer <= count then
						count = 0
						integer = random:NextInteger(self.config.MinInterval, self.config.MaxInterval)
						self:SpawnBeam(object2.fishPosition)
					end
				end
			end))
		else
			while object2.active do
				object2:WaitLogic(random:NextNumber(self.config.MinInterval, self.config.MaxInterval))

				if not object2.active then
					return
				end

				self:SpawnBeam(object2.fishPosition)
			end
		end
	end))
end

setmetatable(MoonlightRay, module)
return MoonlightRay