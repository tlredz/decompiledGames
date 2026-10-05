workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(player)
	local _ = player.CFrame
	local cframe = CFrame.new(player.Character.HumanoidRootPart.Position, player.TargetCFrame.p)
	local targetCFrame = player.TargetCFrame
	local speed = player.Speed or 220

	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	sound:Play("TridentDoughZ1", cframe)
	local magnitude = (cframe.p - targetCFrame.p).magnitude
	local cframe2 = CFrame.new(cframe.p, targetCFrame.p)
	local _ = cframe2 * CFrame.new(0, 0, -magnitude)
	local v = math.max(magnitude / speed, 0.05)
	local lastTime = tick()

	while tick() - lastTime < v do
		local v2 = math.clamp((tick() - lastTime) / v, 0.001, 1)

		if player.Character:FindFirstChild("TridentGrabZ") then
			break
		end

		if game.Players.LocalPlayer.Character == player.Character then
			player.Character.HumanoidRootPart.CFrame = cframe:Lerp(targetCFrame, v2)
			player.Character.HumanoidRootPart.Velocity = Vector3.new()
		end

		local v3 = cframe2 * CFrame.new(0, 0, -15 - v2 * magnitude)
		local clone = script.MochiSwirl:Clone()
		clone:SetPrimaryPartCFrame(v3 * CFrame.Angles(1.5707963267948966, math.random() * 3.141592653589793 * 2, 0))
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			if child.Name == "Color1" then
				if math.random() < 0.25 then
					child:Destroy()
				else
					child.Transparency = math.random() * 0.7
					local v4 = 1.8 + math.random() * 1.8
					local tween = TweenService:Create(
						child,
						TweenInfo.new(
							0.1 + child.Size.Magnitude * 0.005 + math.random() * 0.1,
							Enum.EasingStyle.Circular
						),
						{
							Size = child.Size * Vector3.new(v4, 2, v4),
							CFrame = child.CFrame * CFrame.new(0, math.random(2, 10), 0),
							Transparency = 1
						}
					)
					local v5 = child
					tween.Completed:Connect(function()
						v5:Destroy()
					end)
					tween:Play()
				end
			elseif child.Name == "Color2" then
				child:Destroy()
			elseif child.Name == "FaintWind" then
				child:Destroy()
			end
		end

		task.delay(1, function()
			clone:Destroy()
		end)
		task.wait()
	end
end