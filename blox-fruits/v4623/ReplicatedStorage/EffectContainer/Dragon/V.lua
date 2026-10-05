local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local dragonTransformation = game.ReplicatedStorage.Assets.Models.DragonTransformation
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local model = data.Model
	local off = data.Off

	if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude > 1000 then
		return
	end

	if off then
		Util.Sound:Play("DragonDeactivate", model.HumanoidRootPart.CFrame.p)
	else
		Util.Sound:Play("DragonActivate", model.HumanoidRootPart)
	end

	local function groupTween(instance, tweenInfo, fn)
		for _, child in pairs(instance:GetChildren()) do
			TweenService:Create(child, tweenInfo, fn(child)):Play()
		end
	end

	if model then
		for _, part in pairs(model:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			if off then
				TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			else
				local transparency = part.Transparency
				part.Transparency = 1
				TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					Transparency = transparency
				}):Play()
			end
		end
	end

	local v = {}
	spawn(function()
		for i = 1, 8 do
			local v2 = model["Scale" .. i]
			local v3 = 3.141592653589793 * math.random() * 2
			local clone = dragonTransformation:Clone()
			clone:SetPrimaryPartCFrame(CFrame.new(0, -1000000, 0))
			clone.Parent = _WorldOrigin
			table.insert(v, { clone, v2, v3 })
			groupTween(clone, TweenInfo.new(off and 0.05 or 0.6, Enum.EasingStyle.Quad), function(p)
				return {
					Transparency = 0,
					Size = p.Size * createVector(1, 2.5, 1) * (off and 0.65 or 1) * (p.BrickColor == BrickColor.new("Alder") and 6 or 4)
				}
			end)
		end

		wait(off and 0.05 or 0.6)

		for _, v2 in pairs(v) do
			groupTween(
				v2[1],
				TweenInfo.new(off and 0.15 or 0.26666666666666666, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				function(p)
					return {
						Transparency = 1,
						Size = p.Size * 0
					}
				end
			)
		end

		wait(off and 0.15 or 0.26666666666666666)

		for _, v2 in pairs(v) do
			v2[1]:Destroy()
		end

		v = {}
	end)
	local lastTime = tick()
	local lastTime2 = tick()

	while tick() - lastTime < (off and 1 or 2) do
		local _ = tick() - lastTime2

		for _, v2 in pairs(v) do
			v2[1]:SetPrimaryPartCFrame(v2[2].CFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				v2[3] + (tick() - lastTime) * 20,
				0
			))
		end

		lastTime2 = tick()
		RunService.RenderStepped:Wait()
	end
end