workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")

local function fn(character, duration)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		for i = 1, 2 do
			local v = humanoidRootPart.Size.Y * (i / 2 + 3)
			local clone = game.ReplicatedStorage.Assets.Models.IceBox:Clone()
			clone.Anchored = false
			clone.CFrame = humanoidRootPart.CFrame
			clone.Massless = true
			clone.Material = "Neon"
			clone.Color = Color3.fromRGB(110, 153, 202):Lerp(Color3.new(), 0.1 + math.random() * 0.1)
			clone.Transparency = 1
			clone.Size = Vector3.new(v, v * 2, v) * 1.5
			clone.Parent = workspace._WorldOrigin
			local weld = Instance.new("Weld", clone)
			weld.Part0 = clone
			weld.Part1 = humanoidRootPart
			local tween = TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 0.4,
				Size = Vector3.new(v, v * 2, v)
			})
			tween.Completed:Connect(function()
				wait((math.max(0, duration - 0.2)))
				local tween2 = TweenService:Create(clone, TweenInfo.new(0.2), {
					Transparency = 1
				})
				tween2.Completed:Connect(function()
					clone:Destroy()
				end)
				tween2:Play()
			end)
			tween:Play()
		end
	end
end

return function(player)
	local character = player.Character
	local duration = player.Duration
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
		return
	end

	fn(character, duration)
end