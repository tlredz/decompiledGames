local WaveTransition = require(script.WaveTransition)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local parent = script.Parent
local frame = parent.Frame
local v = WaveTransition.new(parent)
v:Update(0)

function BuildUpSqure()
	local numberValue = Instance.new("NumberValue")
	_G.PU:Dust(numberValue, 5)
	numberValue.Value = 0
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Value = 1
		}
	)
	local tween2 = TweenService:Create(
		numberValue,
		TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Value = 0
		}
	)
	tween:Play()
	task.spawn(function()
		tween.Completed:Wait()
		task.wait(0.5)
		frame.Rotation = 180
		tween2:Play()
		tween2.Completed:Wait()
		numberValue:SetAttribute("ForceFinish")
	end)
	PeodizService.HeartbeatWait({
		Time = 5
	}, function(_)
		if numberValue and numberValue:GetAttribute("ForceFinish") then
			v:Update(0)
			return true
		else
			v:Update(numberValue.Value)
		end
	end)
end

BuildUpSqure()