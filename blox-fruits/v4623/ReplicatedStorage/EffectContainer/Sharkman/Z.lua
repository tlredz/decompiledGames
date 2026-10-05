local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local direction = p.Direction

	if (direction.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	for i = 1, 12 do
		for i2 = 1, math.random(math.ceil(i / 4 - 0.5), (math.ceil(i / 2 - 0.5))) do
			local cframe = CFrame.new(
				(math.random() - 0.5) * (i * 2 + 18),
				p.Floor and math.random() * (i + 10) or (math.random() - 0.5) * (i * 2 + 18),
				-i * math.random(9, math.ceil(i / 5) + 9)
			)
			local clone = script.WaterPalm:Clone()
			clone:SetPrimaryPartCFrame(direction * cframe)
			clone.Parent = _WorldOrigin

			for _, child in pairs(clone:GetChildren()) do
				if child.Name == "Root" then
					local tween = TweenService:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
						Size = child.Size * createVector(3.5, 3.5, 0.1),
						CFrame = child.CFrame * CFrame.new(0, 0, -8),
						Transparency = 1
					})
					local v = child
					tween.Completed:Connect(function()
						v:Destroy()
					end)
					tween:Play()
				elseif child.Name == "Ring" then
					local tween = TweenService:Create(child, TweenInfo.new(0.23, Enum.EasingStyle.Quad), {
						Size = child.Size * createVector(4, 2, 4),
						CFrame = child.CFrame * CFrame.new(0, -15, 0),
						Transparency = 1
					})
					local v = child
					tween.Completed:Connect(function()
						v:Destroy()
					end)
					tween:Play()
				elseif child.Name == "Spin" then
					local tween = TweenService:Create(
						child,
						TweenInfo.new(0.4 + math.random() * 0.25, Enum.EasingStyle.Quad),
						{
							Size = child.Size * createVector(3.5, 4, 3.5),
							CFrame = child.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(
								0,
								math.sign(math.random() - 0.5) * 3.141592653589793,
								0
							),
							Transparency = 1
						}
					)
					local v = child
					tween.Completed:Connect(function()
						v:Destroy()
					end)
					tween:Play()
				end
			end

			delay(0.75, function()
				clone:Destroy()
			end)

			if i2 == 1 then
				Util.Sound:Play("WaterSplash3_2", direction * cframe)
			end
		end

		local lastTime = tick()

		repeat
			RunService.RenderStepped:Wait()
		until tick() - lastTime > 0.025
	end
end