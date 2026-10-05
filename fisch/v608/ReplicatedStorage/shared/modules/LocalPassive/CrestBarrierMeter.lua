local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
require(ReplicatedStorage.shared.utils.FischUtils)
local CrestBarrierMeter = {}
CrestBarrierMeter.__index = CrestBarrierMeter

function CrestBarrierMeter:Morph(_, object)
	local data = object.data

	if not (data and data.AbaiaStage) then
		return
	end

	object:Preload(script:GetChildren())
	local protectionMeter = script:FindFirstChild("ProtectionMeter")

	if not protectionMeter then
		return
	end

	local clone = protectionMeter:Clone()
	clone.Parent = object.reel_bar
	self.reelTrove:Add(clone)
	self.meter = clone
	self.meterFill = clone:FindFirstChild("fill")
	self.meterLabel = clone:FindFirstChild("LayersLeft")
	local abaiaStage = data.AbaiaStage
	local abaiaTotal = data.AbaiaTotal or abaiaStage

	if self.meterFill then
		self.meterFill.Size = UDim2.fromScale(1.008 * (abaiaStage / abaiaTotal), 0.653)
	end

	if self.meterLabel then
		self.meterLabel.Text = string.format("Layers Left: %d", abaiaStage)
	end

	self.reelTrove:Add(object.PreMinigameEnd:Once(function(flag: boolean)
		if not flag then
			return
		end

		local v = math.max(abaiaStage - 1, 0)

		if self.meterLabel then
			self.meterLabel.Text = string.format("Layers Left: %d", v)
		end

		if self.meterFill then
			object.renderTweens:Create(
				self.meterFill,
				TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					Size = UDim2.fromScale(1.008 * (v / abaiaTotal), 0.653)
				}
			):Play()
		end
	end))
end

setmetatable(CrestBarrierMeter, module)
return CrestBarrierMeter