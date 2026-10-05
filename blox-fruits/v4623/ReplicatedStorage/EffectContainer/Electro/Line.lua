workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function Destroy(instance, duration)
	task.delay(duration, function()
		instance:Destroy()
	end)
end

local LightningBolt = require(game.ReplicatedStorage.Util.LightningBolt)
return function(p)
	local position = p.Part0.Position
	local part1 = p.Part1
	CFrame.new(part1.Position, position)

	if (workspace.CurrentCamera.CFrame.p - part1.CFrame.p).Magnitude < 600 then
		local clone = FX:WaitForChild("Electro").ElectroX:Clone()
		clone.CFrame = part1.CFrame
		clone.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(clone, 3)
		clone.Main2.WorldPosition = position
		local _ = (part1.Position - position).Magnitude

		for i = 1, 3 do
			TweenService:Create(clone:FindFirstChild("MainBeam" .. i), TweenInfo.new(0.175, Enum.EasingStyle.Quad), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		local main1 = clone.Main1
		local main2 = clone.Main2
		Util.Sound:Play("ElectroTackle", main2.WorldPosition, 30, nil, 0.05)

		for _, child in pairs(clone.Main3:GetChildren()) do
			child:Emit(3)
		end

		local v = LightningBolt.new(main2, main1, 1, 1, 12, Color3.new(0.562745, 0.943137, 1))
		v.PulseLength = 0.5
		v.PulseSpeed = 6
		v.Thickness = 1.75
		local v2 = LightningBolt.new(main2, main1, 1, 1, 8, Color3.new(0.562745, 0.943137, 1))
		v2.PulseLength = 0.5
		v2.PulseSpeed = 4
		v2.Thickness = 2.25
	end
end