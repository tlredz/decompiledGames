workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = {}
RunService:BindToRenderStep("IceBodyRender", 10000, function(_)
	for k, v2 in pairs(v) do
		local main = v2.Main

		if main and main.Parent and main:IsDescendantOf(_WorldOrigin) then
			main.CFrame = CFrame.new(v2.Part.CFrame * v2.OriginOffset) * v2.Offset
		else
			table.remove(v, k)
		end
	end
end)
local v2 = {
	LeftLowerArm = true,
	RightLowerArm = true,
	LeftUpperLeg = true,
	RightUpperLeg = true,
	HumanoidRootPart = true
}

local function fn(character, direction, p)
	local parts = {}

	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") and v2[part.Name] then
			table.insert(parts, part)
		end
	end

	local count = 0

	for _, part in pairs(parts) do
		if count >= 20 then
			break
		end

		for _ = 1, part.Size.Magnitude * 0.5 do
			count += 1
			local width = (0.6 + math.random()) * (0.9 + part.Size.X * 0.7)
			local length = (2 + math.random() * 3) * (0.9 + part.Size.X * 0.7)
			local offset = CFrame.new(Vector3.new(), direction) * CFrame.Angles(
				(math.random() - 0.5) * 0.4,
				(math.random() - 0.5) * 0.4,
				3.141592653589793 * math.random() * 2
			) * CFrame.new(0, 0, -length / 3) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local clone = game.ReplicatedStorage.Assets.Models.Icicle:Clone()
			clone.Transparency = 1
			clone.Size = Vector3.new(0, length, 0)
			clone.Parent = _WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 0,
				Size = Vector3.new(width, length, width)
			})
			tween.Completed:Connect(function()
				wait((math.max(0, p - 0.2)))
				local tween2 = TweenService:Create(clone, TweenInfo.new(0.2), {
					Transparency = 1,
					Size = Vector3.new(0, length, 0)
				})
				tween2.Completed:Connect(function()
					clone:Destroy()
				end)
				tween2:Play()
			end)
			tween:Play()
			table.insert(v, {
				Main = clone,
				Part = part,
				OriginOffset = Vector3.new(
					part.Size.X * (math.random() - 0.5),
					part.Size.Y * (math.random() - 0.5),
					part.Size.Z * (math.random() - 0.5)
				),
				Offset = offset,
				Width = width,
				Length = length
			})
		end
	end
end

return function(player)
	local character = player.Character
	local direction = player.Direction
	local duration = player.Duration
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 300 then
		return
	end

	local v3 = math.max(duration - (masterClock:GetTime() - player.Timestamp), 0)

	if v3 > 0.2 then
		fn(character, direction, v3)
	end
end