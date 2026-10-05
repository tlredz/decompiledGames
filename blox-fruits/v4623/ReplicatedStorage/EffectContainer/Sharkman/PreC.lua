local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local _WorldOrigin = workspace._WorldOrigin
return function(p)
	local direction = p.Direction

	if (direction.p - workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
		return
	end

	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)

	for i = 1, 6 do
		local v = i
		spawn(function()
			local clone = script.FishmanC:Clone()
			clone:SetPrimaryPartCFrame(direction * cframe)
			clone.Parent = _WorldOrigin
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 0.33 do
				local v2 = tick() - lastTime
				clone:SetPrimaryPartCFrame(direction * CFrame.new(0, 0, -450 * v2) * cframe * CFrame.Angles(
					0,
					-v2 * 20,
					0
				))
				count += 1

				if count % 3 == 0 and v % 3 == 0 then
					for i2, child in pairs(clone:GetChildren()) do
						if child.Name ~= "Clone" then
							continue
						end

						local clone2 = child:Clone()
						clone2.Parent = _WorldOrigin
						local tween = TweenService:Create(
							clone2,
							TweenInfo.new(0.2 + math.random() * 0.2, Enum.EasingStyle.Quad),
							{
								Size = clone2.Size * createVector(2, 0, 2) * (v / 40 + 1),
								CFrame = clone2.CFrame * CFrame.Angles(
									0,
									3.141592653589793 * math.sign(math.random() - 0.5),
									0
								),
								Transparency = 1
							}
						)
						tween.Completed:Connect(function()
							clone2:Destroy()
						end)
						tween:Play()
					end
				end

				RunService.RenderStepped:Wait()
			end

			for i2, child in pairs(clone:GetChildren()) do
				local tween = TweenService:Create(
					child,
					TweenInfo.new(0.15 + math.random() * 0.1, Enum.EasingStyle.Quad),
					{
						Size = child.Size * Vector3.new(),
						CFrame = child.CFrame * CFrame.new(0, -25, 7)
					}
				)
				local v2 = child
				tween.Completed:Connect(function()
					v2:Destroy()
				end)
				tween:Play()
			end

			wait(1)
			clone:Destroy()
		end)
		wait()
		wait()
	end
end