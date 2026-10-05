local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local Network = require(ReplicatedStorage.Modules.Network)
local Data = require(ReplicatedStorage.Assets.Data.Wheel.Data)
local skinNames = Data.Rewards.Skins.SkinNames
local titleNames = Data.Rewards.Titles.TitleNames
local _ = Data.Rewards.Credits.CreditAmounts
local Skins = require(ReplicatedStorage.Assets.Data.Store.Skins)
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui
local parent = script.Parent
local background = parent:WaitForChild("Background")
local frame = parent:WaitForChild("Frame")
local wheel = frame:WaitForChild("Wheel")
frame:WaitForChild("Arrow")
local finish = frame:WaitForChild("Finish")
local glow = frame:WaitForChild("Glow")
local money = frame:WaitForChild("Money")
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Name = "SpinWheelBlur"
blurEffect.Enabled = true
blurEffect.Parent = game.Lighting
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Brightness = 0.05
colorCorrectionEffect.Contrast = 0.1
colorCorrectionEffect.Saturation = 0.5
colorCorrectionEffect.Enabled = false
colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
colorCorrectionEffect.Name = "SpinWheelColorCorrection"
colorCorrectionEffect:SetAttribute("Ignore", true)
colorCorrectionEffect.Parent = game.Lighting
local size = frame.Size
local position = frame.Position
local size2 = parent.Interaction.Size
local position2 = parent.Interaction.Position
local tween = TweenService:Create(glow, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {
	Size = UDim2.fromScale(0.7, 0.85)
})
local sounds = {}
local flag = false
local v = false

for k, soundId in pairs({
	OPEN_SOUND = "rbxassetid://2198217232",
	SPIN_SOUND = "rbxassetid://5406934065",
	REWARD_SOUND = "rbxassetid://1169806635"
}) do
	sounds[k] = Instance.new("Sound")
	sounds[k].SoundId = soundId
end

local v2 = {}

for _, v3 in pairs(sounds) do
	table.insert(v2, v3)
end

ContentProvider:PreloadAsync(v2)

local function shuffle(list)
	for i = #list, 1, -1 do
		local v3 = math.random(i)
		local v4 = list[i]
		list[i] = list[v3]
		list[v3] = v4
	end
end

local function collidewith(p, p2)
	local absolutePosition = p.AbsolutePosition
	local v3 = p.AbsolutePosition + p.AbsoluteSize
	local absolutePosition2 = p2.AbsolutePosition
	local v4 = p2.AbsolutePosition + p2.AbsoluteSize
	return absolutePosition.x < v4.x and v3.x > absolutePosition2.x and absolutePosition.y < v4.y and v3.y > absolutePosition2.y
end

local function Map(p, p2, p3, p4, p5)
	return p4 + (p - p2) / (p3 - p2) * (p5 - p4)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function createMoney()
	local clone = money:Clone()
	local _ = clone.Size
	clone.BackgroundTransparency = 1
	clone.Rotation = math.random(-80, 80)
	clone.Visible = true
	clone.Parent = frame
	return clone
end

local function moneyFountain()
	for _ = 1, math.random(30, 32) do
		local clone = money:Clone()
		local _ = clone.Size
		clone.BackgroundTransparency = 1
		clone.Rotation = math.random(-80, 80)
		clone.Visible = true
		clone.Parent = frame
		clone.Position = UDim2.fromScale(math.random(45, 55) / 100, 1.2)
		local uDim = UDim2.fromScale(math.random(-2, 2) / 1, math.random(-85, -75) / 10)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(math.random(250, 400) / 20, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Position = uDim
			}
		)
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(clone, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0, 0)
		}):Play()
		tween2:Play()
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
		task.wait(0.02)
	end
end

local function closeWheel()
	flag = false
	local tween2 = TweenService:Create(background, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	})
	tween2:Play()
	tween2.Completed:Once(function()
		background.Visible = false
	end)
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, -1)
	}):Play()
	TweenService:Create(parent.Interaction, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	TweenService:Create(parent.Interaction, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, -1)
	}):Play()
	TweenService:Create(blurEffect, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = 0
	}):Play()
	local tween3 = TweenService:Create(
		colorCorrectionEffect,
		TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	)
	tween3:Play()
	tween3.Completed:Wait()
	colorCorrectionEffect.Enabled = false
end

local function spinWheel(_, label)
	task.wait(1)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://5406934065"
	sound.PlaybackSpeed = 0.55
	sound.Parent = localPlayer.Character.Head
	sound:Play()
	local v3 = 36

	while true do
		v3 = math.clamp(v3 - 0.015, 0.5, 5)
		wheel.Rotation += v3
		task.wait()
		local hidden = label.Parent.Hidden
		local v5 = finish
		local absolutePosition = hidden.AbsolutePosition
		local v6 = hidden.AbsolutePosition + hidden.AbsoluteSize
		local absolutePosition2 = v5.AbsolutePosition
		local v7 = v5.AbsolutePosition + v5.AbsoluteSize
		local v8

		if absolutePosition.x < v7.x and v6.x > absolutePosition2.x and absolutePosition.y < v7.y then
			v8 = v6.y > absolutePosition2.y
		else
			v8 = false
		end

		if not (v8 and v3 <= 1.2) then
			continue
		end

		sound:Stop()
		TweenService:Create(label, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
		local sound2 = Instance.new("Sound")
		sound2.SoundId = "rbxassetid://1169806635"
		sound2.PlaybackSpeed = 1
		SoundService:PlayLocalSound(sound2)
		moneyFountain()
		task.spawn(function()
			task.wait(1.1)
			ReplicatedStorage.Remotes.CollectWheelReward:FireServer()
		end)
		parent:SetAttribute("Spinning", false)
		tween:Cancel()

		if v then
			v = false
			break
		end

		task.wait(3)
		closeWheel()
		break
	end
end

local function openWheel()
	if flag then
		return
	end

	flag = true
	colorCorrectionEffect.Enabled = false
	local tween2 = TweenService:Create(background, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	})
	background.BackgroundTransparency = 1
	background.Visible = true
	tween2:Play()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://2198217232"
	sound.PlaybackSpeed = 1
	SoundService:PlayLocalSound(sound)
	TweenService:Create(blurEffect, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = 24
	}):Play()
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(3.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		TintColor = Color3.fromRGB(79, 79, 79)
	}):Play()
	TweenService:Create(parent.Interaction, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = size2
	}):Play()
	TweenService:Create(parent.Interaction, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = position2
	}):Play()
	frame.Size = UDim2.fromScale(0, 0)
	frame.Position = UDim2.fromScale(0.5, -1)
	frame.Visible = true
	parent.Interaction.Size = UDim2.fromScale(0, 0)
	parent.Interaction.Position = UDim2.fromScale(0.5, -1)
	parent.Interaction.Visible = true
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = size
	}):Play()
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = position
	}):Play()
	tween:Play()
	task.wait(1.3)
end

local v3 = nil
local v4 = nil
Network:listen("LoadWheelData", function(p)
	for _, child in pairs(wheel.Labels:GetChildren()) do
		child.Size = UDim2.fromScale(0, 0)
	end

	v4 = p
	local v5 = v4[1]

	for _, child in pairs(wheel.Labels:GetChildren()) do
		child:SetAttribute("Set", nil)
	end

	for _, v6 in pairs(v4) do
		if tonumber(v6) then
			for _, child in pairs(wheel.Labels:GetChildren()) do
				if child.Name ~= "Credits" or child:GetAttribute("Set") then
					continue
				end

				child:SetAttribute("Set", true)
				child.Label.Text = `{v6}\nCredits`

				if v6 == v5 then
					v3 = child
				end

				child.Visible = true
				TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(0.175, 0.197)
				}):Play()
				break
			end
		elseif table.find(skinNames, v6) then
			for _, child in pairs(wheel.Labels:GetChildren()) do
				if child.Name ~= "Skin" or child:GetAttribute("Set") then
					continue
				end

				child:SetAttribute("Set", true)
				child.Label.Text = `{v6}\nSkin`
				child.Image = Skins[v6].Icon

				if v6 == v5 then
					v3 = child
				end

				child.Visible = true
				TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(0.175, 0.197)
				}):Play()
				child.Image = Skins[v6].Icon
				TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 0.5
				}):Play()
				break
			end
		elseif table.find(titleNames, v6) then
			for _, child in pairs(wheel.Labels:GetChildren()) do
				if child.Name ~= "Title" or child:GetAttribute("Set") then
					continue
				end

				child:SetAttribute("Set", true)
				child.Label.Text = `{v6}\nTitle`

				if v6 == v5 then
					v3 = child
				end

				child.Visible = true
				TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(0.175, 0.197)
				}):Play()
				break
			end
		end
	end

	local v6 = { 50, 100, 150 }

	for _, child in pairs(wheel.Labels:GetChildren()) do
		if not (string.len(child.Label.Text) < 3) then
			continue
		end

		child.Label.Text = `{v6[math.random(1, #v6)]}\nCredits`
		TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.175, 0.197)
		}):Play()
		break
	end
end)
Network:listen("PromptWheelSpin", function(p)
	parent:SetAttribute("Spinning", true)
	v = p

	if flag then
		tween:Play()
	else
		openWheel()
	end

	local v5 = 0
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		glow.ImageColor3 = Color3.fromHSV(v5, 1, 1)
		v5 = (v5 + dt * 0.1) % 1
	end)
	task.wait(0.25)
	spinWheel(v4, v3.Label)
	tween:Cancel()
	renderSteppedConnection:Disconnect()
end)
parent:WaitForChild("Open").Event:Connect(openWheel)
parent:WaitForChild("Close").Event:Connect(closeWheel)