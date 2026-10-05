local UserInputService = game:GetService("UserInputService")
local touchEnabled = UserInputService.TouchEnabled
local v = {}
local color3Value = Instance.new("Color3Value", script)

function evalCS(sequence, p)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v2 = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value:lerp(keypoint2.Value, v2)
	end
end

function GetParticle(p)
	if v[1] and not p then
		local v2 = v[1]
		table.remove(v, 1)
		return v2
	else
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = "rbxassetid://9608875194"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(0, 0)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
		imageLabel.ZIndex = -100
		imageLabel.Parent = script.Parent
		color3Value.Changed:Connect(function()
			imageLabel.ImageColor3 = color3Value.Value
		end)

		if p then
			table.insert(v, imageLabel)
		end

		return imageLabel
	end
end

local uDim = UDim2.fromScale(7, 7)
local uDim2 = UDim2.fromScale(0, 0)

function CreateParticle()
	local v2 = math.random() * 0.8 + 0.2
	local v3 = GetParticle()
	local v4 = math.rad(90 + math.random() * 5 - 2.5)
	v3.Size = uDim
	v3.Position = UDim2.fromScale(math.random(), math.random())
	local vector = Vector2.new(2 * v2 * math.cos(v4), 25 * v2 * math.sin(v4))
	local uDim3 = UDim2.fromScale(v3.Position.X.Scale - vector.X, v3.Position.Y.Scale - vector.Y)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(v3, TweenInfo.new(v2, Enum.EasingStyle.Linear), {
		Position = uDim3,
		Size = uDim2
	}):Play()
	task.delay(v2, function()
		table.insert(v, v3)
	end)
end

local v2 = 1
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function(dt)
	if script.Parent:GetAttribute("ParticleEnabled") then
		local Global = require(game.ReplicatedStorage.Global)

		if Global.FastMode then
			v2 += 1

			if v2 == 2 then
				return
			else
				v2 = 1
			end
		end

		local v3 = os.clock() % 3 / 3
		color3Value.Value = Color3.fromHSV(v3, 1, 1)
		local v4

		if touchEnabled then
			v4 = 100
		else
			local Global2 = require(game.ReplicatedStorage.Global)
			v4 = Global2.FastMode and 100 or 200
		end

		for _ = 1, math.floor(dt * v4 * v2) do
			CreateParticle()
		end
	end
end)
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
playerGui:WaitForChild("RaceEnergyUI", 99):WaitForChild("RaceEnergy"):GetPropertyChangedSignal("Position"):Connect(function()
	script.Parent.Position = playerGui:WaitForChild("RaceEnergyUI", 99):WaitForChild("RaceEnergy").Position
end)