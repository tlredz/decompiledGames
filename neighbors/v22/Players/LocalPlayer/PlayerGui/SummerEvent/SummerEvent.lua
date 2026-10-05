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
local spinText = frame:WaitForChild("SpinText")
local spinButton = frame:WaitForChild("SpinButton")
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Name = "SpinWheelBlur"
blurEffect.Enabled = true
blurEffect.Parent = game.Lighting
local sounds = {}

for k, soundId in pairs({
	OPEN_SOUND = "rbxassetid://2198217232",
	SPIN_SOUND = "rbxassetid://5406934065",
	REWARD_SOUND = "rbxassetid://1169806635"
}) do
	sounds[k] = Instance.new("Sound")
	sounds[k].SoundId = soundId
end

local v = {}

for _, v2 in pairs(sounds) do
	table.insert(v, v2)
end

ContentProvider:PreloadAsync(v)

local function shuffle(list)
	for i = #list, 1, -1 do
		local v2 = math.random(i)
		local v3 = list[i]
		list[i] = list[v2]
		list[v2] = v3
	end
end

local function collidewith(p, p2)
	local absolutePosition = p.AbsolutePosition
	local v2 = p.AbsolutePosition + p.AbsoluteSize
	local absolutePosition2 = p2.AbsolutePosition
	local v3 = p2.AbsolutePosition + p2.AbsoluteSize
	return absolutePosition.x < v3.x and v2.x > absolutePosition2.x and absolutePosition.y < v3.y and v2.y > absolutePosition2.y
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
		local tween = TweenService:Create(
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
		tween:Play()
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		task.wait(0.02)
	end
end

local function closeWheel()
	local tween = TweenService:Create(background, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		background.Visible = false
	end)
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, -1)
	}):Play()
	task.spawn(function()
		task.wait(1.1)
		ReplicatedStorage.Remotes.CollectWheelReward:FireServer()
	end)
end

local function spinWheel(_, label)
	task.wait(1)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://5406934065"
	sound.PlaybackSpeed = 0.55
	sound.Parent = localPlayer.Character.Head
	sound:Play()
	local v2 = 36

	while true do
		v2 = math.clamp(v2 - 0.015, 0.5, 5)
		wheel.Rotation += v2
		task.wait()
		local hidden = label.Parent.Hidden
		local v4 = finish
		local absolutePosition = hidden.AbsolutePosition
		local v5 = hidden.AbsolutePosition + hidden.AbsoluteSize
		local absolutePosition2 = v4.AbsolutePosition
		local v6 = v4.AbsolutePosition + v4.AbsoluteSize
		local v7

		if absolutePosition.x < v6.x and v5.x > absolutePosition2.x and absolutePosition.y < v6.y then
			v7 = v5.y > absolutePosition2.y
		else
			v7 = false
		end

		if not (v7 and v2 <= 1.2) then
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
		task.wait(3)
		closeWheel()
		TweenService:Create(blurEffect, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = 0
		}):Play()
		TweenService:Create(
			game.Lighting.ColorCorrection,
			TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				TintColor = Color3.fromRGB(255, 255, 255)
			}
		):Play()
		break
	end
end

local function openWheel()
	local tween = TweenService:Create(background, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	})
	background.BackgroundTransparency = 1
	background.Visible = true
	tween:Play()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://2198217232"
	sound.PlaybackSpeed = 1
	SoundService:PlayLocalSound(sound)
	TweenService:Create(blurEffect, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = 24
	}):Play()
	TweenService:Create(
		game.Lighting.ColorCorrection,
		TweenInfo.new(3.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			TintColor = Color3.fromRGB(79, 79, 79)
		}
	):Play()
	local size = frame.Size
	local position = frame.Position
	frame.Size = UDim2.fromScale(0, 0)
	frame.Position = UDim2.fromScale(0.5, -1)
	frame.Visible = true
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = size
	}):Play()
	TweenService:Create(frame, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = position
	}):Play()
	task.wait(1.3)
end

local v2 = nil
Network:listen("PromptWheelSpin", function(list)
	openWheel()
	v2 = TweenService:Create(spinText, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		ImageColor3 = Color3.fromRGB(140, 140, 140)
	})
	v2:Play()
	TweenService:Create(glow, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {
		Size = UDim2.fromScale(0.7, 0.85)
	}):Play()
	local v3 = 0
	RunService.RenderStepped:Connect(function(dt)
		glow.ImageColor3 = Color3.fromHSV(v3, 1, 1)
		v3 = (v3 + dt * 0.1) % 1
	end)

	for _, child in pairs(wheel.Labels:GetChildren()) do
		child.Size = UDim2.fromScale(0, 0)
	end

	local v4 = list[1]
	warn(list)
	local v5 = nil

	for _, v6 in pairs(list) do
		if tonumber(v6) then
			for _, child in pairs(wheel.Labels:GetChildren()) do
				if child.Name ~= "Credits" or child:GetAttribute("Set") then
					continue
				end

				child:SetAttribute("Set", true)
				child.Label.Text = `{v6}\nCredits`

				if v6 == v4 then
					v5 = child
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

				if v6 == v4 then
					v5 = child
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

				if v6 == v4 then
					v5 = child
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

	local v7 = false
	spinButton.MouseButton1Click:Connect(function()
		if not v7 then
			v7 = true
			v2:Cancel()
			TweenService:Create(spinText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			}):Play()
			spinWheel(list, v5.Label)
		end
	end)
end)