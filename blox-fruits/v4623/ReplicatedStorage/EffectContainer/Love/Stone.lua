local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
return function(player)
	local character = player.Character
	local duration = player.Duration or 1

	if not character or (character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local v = {}

	for _, part in pairs(character:GetChildren()) do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local part2 = Instance.new("Part")
		part2.Material = "Slate"
		part2.Size = part.Size + createVector(0.225, 0.225, 0.225)
		part2.CanCollide = false
		part2.Massless = true
		part2.Anchored = false
		part2.TopSurface = 0
		part2.BottomSurface = 0
		part2.CFrame = part.CFrame
		local weld = Instance.new("Weld")
		weld.Name = "Weld"
		weld.Part0 = part2
		weld.Part1 = part
		weld.C1 = CFrame.Angles(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
		weld.Parent = part2
		part2.Parent = workspace._WorldOrigin
		table.insert(v, part2)
	end

	local v2 = duration - (Util.MasterClock:GetTime() - player.Timestamp)

	if v2 > 0 then
		wait(v2)
	end

	for _, v3 in pairs(v) do
		local v4 = v3
		pcall(function()
			v4.Weld:Destroy()
		end)
		local v5 = v3
		pcall(function()
			v5.Velocity = Vector3.new(math.random() - 0.5, math.random() * 0.5, math.random() - 0.5).unit * 33
			v5.RotVelocity = v5.Velocity * 0.33
			local tween = TweenService:Create(v5, TweenInfo.new(0.4 + math.random() * 0.2), {
				Size = createVector(0.05, 0.05, 0.05)
			})
			tween.Completed:Connect(function()
				v5:Destroy()
			end)
			tween:Play()
		end)
	end
end