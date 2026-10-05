local createVector = vector.create
local util = game.ReplicatedStorage:WaitForChild("Util")
local Sound = require(util.Sound)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local lightSword = game.ReplicatedStorage.Assets.Models.LightSword
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map

local function ScaleParticle(p, p2)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, p.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p2, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function func(data)
	local HRP = data.HRP
	local scale = data.Scale
	local holding = data.Holding
	local mousePos = data.MousePos
	local value = mousePos.Value

	for i = 1, 100 do
		if i >= 15 and not holding.Value then
			break
		end

		if i % 4 == 0 then
			Sound:Play("DiscFire3", HRP.Position)
		end

		value = value:Lerp(mousePos.Value, 0.1)

		for i2 = 1, 2 do
			local v = math.sin(i / 3.3) * 20
			local v2 = (i + i2 / 2) * 3.141592653589793 * 0.75
			local v3 = value - HRP.Position

			if v3.Magnitude > 300 then
				v3 = CFrame.new(HRP.Position, value).LookVector * 120
			end

			local module = require(util)
			local _, v4, _ = module.Ray(HRP.Position, v3, { workspace.Characters, workspace.Enemies })
			local v5 = CFrame.new(v4) * CFrame.new(math.sin(v2) * v, 44, math.cos(v2) * v)
			local cframe = CFrame.new(v5.p, v5.p - createVector(0, 10, 0))
			local clone = lightSword:Clone()
			clone.Transparency = 1
			clone.Size = createVector(0.05, 0.05, 0.05)
			clone.CFrame = cframe
			clone.Parent = _WorldOrigin
			clone.Attachment.Star.Size = ScaleParticle(clone.Attachment.Star, scale * 0.9)
			clone.Attachment.Star_Color.Size = ScaleParticle(clone.Attachment.Star_Color, scale * 0.9)
			clone.Attachment.Star:Emit(1)
			clone.Attachment.Star_Color:Emit(1)
			local pointLight = Instance.new("PointLight")
			pointLight.Brightness = 1
			pointLight.Range = 10
			pointLight.Color = Color3.new(1, 1, 0)
			pointLight.Parent = clone.Attachment
			local tween = TweenService:Create(pointLight, TweenInfo.new(0.2), {
				Brightness = 0
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		task.wait(0.03333333333333333)
	end
end

return func