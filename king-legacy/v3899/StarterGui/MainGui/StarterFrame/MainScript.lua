local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character

if not character then
	character = localPlayer.CharacterAdded:Wait()
end

repeat
	wait(0.1)
until localPlayer:FindFirstChild("DataLoaded")

local playerStats = localPlayer:WaitForChild("PlayerStats")
local material = playerStats.Material
local parent = script.Parent
local statsFrame = parent:WaitForChild("StatsFrame")
local passiveScenceFrame = parent.PassiveScenceFrame
local frame = statsFrame.PassivePage.Frame
local confirmFrame = frame:WaitForChild("ConfirmFrame")
frame:WaitForChild("ScrollingFrame")
local hide = frame:WaitForChild("Hide")
local information = confirmFrame:WaitForChild("Information")
local passiveRateButton = confirmFrame:WaitForChild("PassiveRateButton")
local passiveRateList = confirmFrame:WaitForChild("PassiveRateList")
local passiveBagFrame = frame:WaitForChild("PassiveBagFrame")
local slotInfoFrame = frame:WaitForChild("SlotInfoFrame")
playerStats:WaitForChild("PassiveStore")
local passiveBag = playerStats:WaitForChild("PassiveBag")
local bag = frame:WaitForChild("Bag")
local reroll = frame:WaitForChild("Reroll")
local WorldsId = require(ReplicatedStorage.Chest.Modules:WaitForChild("WorldsId"))
local PeoUtils = require(ReplicatedStorage.Chest.Modules:WaitForChild("PeoUtils"))
local CustomNames = require(ReplicatedStorage.Chest.Modules:WaitForChild("CustomNames"))
local CharacterPassiveRates = require(ReplicatedStorage.Chest.Modules:WaitForChild("CharacterPassiveRates"))
local v = {
	[WorldsId.Testing.GoldenArena] = true,
	[WorldsId.KingLegacy.GoldenArena] = true
}
local PassiveList = require(ReplicatedStorage.Chest.Modules.PassiveList)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
Instance.new("Camera")
local currentCamera = workspace.CurrentCamera
local count = 0
local flag = nil
local name = nil
local flag2 = nil
local flag3 = nil
local flag4 = nil
local flag5 = nil

for _, _ in pairs(SwordList) do
	count += 1
end

bag.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	flag = true
	task.delay(0.1, function()
		flag = nil
	end)
	_G.ClickFrameEffect({
		Sound = true
	})
	task.spawn(function()
		if passiveBagFrame.Visible then
			passiveBagFrame.Close.Visible = nil
			task.wait(0.1)
			passiveBagFrame.Visible = nil
		else
			passiveBagFrame.Close.Visible = true
			passiveBagFrame.Visible = true
		end
	end)
end)
bag.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = bag,
		Circle = true,
		CornerRadius = UDim.new(0.3, 0)
	})
	bag.Size = UDim2.new(0.29, 0, 0.135, 0)
	TweenService:Create(bag, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.33349999999999996, 0, 0.15525, 0)
	}):Play()
end)
bag.MouseLeave:Connect(function()
	TweenService:Create(bag, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.29, 0, 0.135, 0)
	}):Play()
end)

if not workspace:FindFirstChild("Island") then
	return
end

local enchantCutscene = workspace:WaitForChild("Island").EnchantCutscene
local cFramesByName = {}

if not v[game.PlaceId] then
	for _, model in pairs(enchantCutscene.Books:GetChildren()) do
		if model:IsA("Model") then
			cFramesByName[model.Name] = model.PrimaryPart.CFrame
		end
	end
end

local v2 = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}
local v3 = {
	Common = 0,
	Curse = 1,
	Paradox = 2,
	Iconic = 3,
	Celestial = 4
}
local v4 = {
	Common = Color3.fromRGB(255, 255, 255),
	Iconic = Color3.fromRGB(255, 255, 0),
	Celestial = Color3.fromRGB(0, 255, 255),
	Curse = Color3.fromRGB(129, 0, 0),
	Paradox = Color3.fromRGB(0, 170, 0)
}

function StopAnims(object)
	for _, v5 in pairs(object:GetPlayingAnimationTracks()) do
		v5:Stop(0)
	end
end

function ResetBooks()
	for _, child in pairs(enchantCutscene.Books:GetChildren()) do
		if not cFramesByName[child.Name] then
			continue
		end

		local animationController = child:FindFirstChildOfClass("AnimationController")

		if animationController then
			StopAnims(animationController)
		end

		child:PivotTo(cFramesByName[child.Name])
	end
end

local circle = passiveScenceFrame.SpecialFrame:WaitForChild("Circle")
local bigCircle = passiveScenceFrame.SpecialFrame:WaitForChild("BigCircle")
local fadeCircle = passiveScenceFrame.SpecialFrame:WaitForChild("FadeCircle")
local fadeCircle2 = passiveScenceFrame.SpecialFrame:WaitForChild("FadeCircle2")
local star = passiveScenceFrame.SpecialFrame:WaitForChild("Star")
local shape = passiveScenceFrame.SpecialFrame:WaitForChild("Shape")
local line = passiveScenceFrame.SpecialFrame:WaitForChild("Line")

function Reset(p)
	circle.Visible = nil
	bigCircle.Visible = nil
	fadeCircle.Visible = nil
	fadeCircle2.Visible = nil
	star.Visible = nil
	shape.Visible = nil
	line.Visible = nil
	circle.Rotation = 0
	bigCircle.Rotation = 0
	fadeCircle.Rotation = 0
	star.Rotation = 0
	shape.Rotation = 0
	line.Rotation = 0
	circle.ImageTransparency = 1
	circle.Size = UDim2.new(0, 0, 0, 0)
	bigCircle.ImageTransparency = 1
	bigCircle.Size = UDim2.new(0, 0, 0, 0)
	star.Size = UDim2.new(0, 0, 0, 0)
	line.Size = UDim2.new(0, 0, 0.25, 0)
	shape.ImageTransparency = 0
	fadeCircle.ImageTransparency = 1
	star.ImageColor3 = Color3.fromRGB(255, 255, 255)
	shape.ImageColor3 = Color3.fromRGB(255, 255, 255)

	if p then
		if p == "Iconic" then
			star.ImageColor3 = Color3.fromRGB(255, 255, 0)
			shape.ImageColor3 = Color3.fromRGB(255, 255, 0)
		elseif p == "Celestial" then
			star.ImageColor3 = Color3.fromRGB(0, 255, 255)
			shape.ImageColor3 = Color3.fromRGB(0, 255, 255)
		end
	end
end

local flag6 = nil

function SpecialScene(p)
	Reset(p)
	passiveScenceFrame.SpecialFrame.Visible = true
	local lastTime = tick()
	circle.Visible = true
	TweenService:Create(circle, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(circle, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
		Size = UDim2.new(0.35, 0, 0.35, 0)
	}):Play()
	local lastTime2 = tick()
	local lastTime3 = tick()
	local thread = task.spawn(function()
		local lastTime4 = tick()

		while task.wait() and not (tick() - lastTime4 >= 15) and passiveScenceFrame.SpecialFrame.Visible do
			local v5 = 1 + (tick() - lastTime3) / 1.25
			circle.Rotation += 0.3 * v5

			if bigCircle.Visible then
				bigCircle.Rotation -= 0.15 * v5
			end

			if fadeCircle.Visible then
				local v6 = math.abs((math.sin((tick() - lastTime) * 1.5))) * 0.2
				fadeCircle.ImageTransparency = 1 - v6
				fadeCircle.Rotation += 0.6 * v5
				fadeCircle2.ImageTransparency = 1 - v6 / 3
				fadeCircle2.Rotation -= 0.6 * v5
			end

			if not star.Visible then
				continue
			end

			star.Rotation -= 0.75 * (1 + (tick() - lastTime2) * 1)
			shape.Rotation = star.Rotation
			line.Rotation = star.Rotation
		end
	end)
	local v5 = nil
	local thread2 = task.spawn(function()
		local WAIT_INTERVAL = 1
		task.wait(0.5)
		bigCircle.Visible = true
		TweenService:Create(bigCircle, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(bigCircle, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Size = UDim2.new(0.6, 0, 0.6, 0)
		}):Play()
		task.wait(WAIT_INTERVAL)
		fadeCircle.Visible = true
		fadeCircle2.Visible = true
		lastTime = tick()
		task.wait(1.5)
		lastTime2 = tick()
		star.Visible = true
		shape.Visible = true
		line.Visible = true
		TweenService:Create(star, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
			Size = UDim2.new(0.35, 0, 0.35, 0),
			ImageTransparency = 0
		}):Play()
		TweenService:Create(shape, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
			Size = UDim2.new(2, 0, 2, 0)
		}):Play()
		TweenService:Create(shape, TweenInfo.new(3, Enum.EasingStyle.Exponential), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(line, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Size = UDim2.new(1, 0, 0.35, 0)
		}):Play()
		TweenService:Create(line, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			ImageTransparency = 1
		}):Play()
		task.wait(3)
		TweenService:Create(star, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {
			Size = UDim2.new(15, 0, 15, 0)
		}):Play()
		task.wait(WAIT_INTERVAL)
		Reset()
		passiveScenceFrame.SpecialFrame.BackgroundFrame.Visible = true
		task.cancel(thread)
		task.wait(WAIT_INTERVAL)
		passiveScenceFrame.SpecialFrame.Visible = nil
		passiveScenceFrame.SpecialFrame.BackgroundFrame.Visible = nil
		v5 = true
		local clone = ReplicatedStorage.Chest.Etc.CrackFX:Clone()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2)
		clone.Parent = workspace

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 0)
			end
		end

		_G.CameraShake:ShakeOnce(5, 8.5, 0, 1, createVector(0, -1.2, 0))
		local RunService2 = game:GetService("RunService")
		local renderSteppedConnection = RunService2.RenderStepped:Connect(function(_)
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2)
		end)
		task.spawn(function()
			wait(3)
			renderSteppedConnection:Disconnect()
			clone:Destroy()
		end)
	end)

	while task.wait() do
		if not (flag6 or v5) then
			continue
		end

		local gotSpecialPassiveSound = workspace.Effects:FindFirstChild("GotSpecialPassiveSound")

		if not gotSpecialPassiveSound then
			break
		end

		gotSpecialPassiveSound.Name = "DestroyingSound"
		TweenService:Create(gotSpecialPassiveSound, TweenInfo.new(0.5), {
			Volume = 0
		}):Play()
		_G.PU:Dust(gotSpecialPassiveSound, 1)
		task.delay(1, function()
			gotSpecialPassiveSound = nil
		end)
		break
	end

	task.cancel(thread)

	if not flag6 then
		return
	end

	task.cancel(thread2)
	Reset()
end

passiveScenceFrame.SkipLabel.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	flag6 = true
	local passiveOpenBookSound = workspace.Effects:FindFirstChild("PassiveOpenBookSound")

	if passiveOpenBookSound then
		passiveOpenBookSound:Destroy()
	end
end)
passiveScenceFrame.SkipLabel.MouseEnter:Connect(function()
	passiveScenceFrame.SkipLabel.Size = UDim2.new(0.25, 0, 0.08, 0)
	TweenService:Create(passiveScenceFrame.SkipLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.2875, 0, 0.092, 0)
	}):Play()
end)
passiveScenceFrame.SkipLabel.MouseLeave:Connect(function()
	TweenService:Create(passiveScenceFrame.SkipLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.25, 0, 0.08, 0)
	}):Play()
end)

function StartCutscene(value, p)
	ResetBooks()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://16980280151",
		Volume = 0.5,
		Name = "PassiveOpenBookSound"
	})
	_G.PU:Dust(sound, 15)
	sound.Parent = workspace.Effects
	sound:Play()
	local book = enchantCutscene.Books[value or "Fate Book"]
	local fakePageStack = book:FindFirstChild("FakePageStack")
	local fistPage = book:FindFirstChild("FistPage")
	local secondPage = book:FindFirstChild("SecondPage")

	if fakePageStack and fistPage and secondPage then
		if p then
			fakePageStack.Material = "Neon"
			fistPage.Material = "Neon"
			secondPage.Material = "Neon"

			if p == "Iconic" then
				fakePageStack.Color = Color3.fromRGB(255, 255, 0)
				fistPage.Color = Color3.fromRGB(255, 255, 0)
				secondPage.Color = Color3.fromRGB(255, 255, 0)
			elseif p == "Celestial" then
				fakePageStack.Color = Color3.fromRGB(0, 255, 255)
				fistPage.Color = Color3.fromRGB(0, 255, 255)
				secondPage.Color = Color3.fromRGB(0, 255, 255)
			end
		else
			fakePageStack.Material = Enum.Material.SmoothPlastic
			fistPage.Material = Enum.Material.SmoothPlastic
			secondPage.Material = Enum.Material.SmoothPlastic
			fakePageStack.Color = Color3.fromRGB(255, 255, 255)
			fistPage.Color = Color3.fromRGB(255, 255, 255)
			secondPage.Color = Color3.fromRGB(255, 255, 255)
		end
	end

	book:PivotTo(enchantCutscene.CutscenePart.CFrame)
	enchantCutscene.CameraRig:PivotTo(enchantCutscene.CutscenePart.CFrame)
	StopAnims(book.AnimationController)
	StopAnims(enchantCutscene.CameraRig.AnimationController)
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = enchantCutscene.CutscenePart.CFrame
	local track = book.AnimationController:LoadAnimation(enchantCutscene["Book Open"])
	local track2 = enchantCutscene.CameraRig.AnimationController:LoadAnimation(enchantCutscene.Cutscene)
	track:Play(0)
	track2:Play(0)
	track2:AdjustSpeed(0)
	track:AdjustSpeed(0)
	track2.TimePosition = 0.1
	flag6 = nil
	local flag7 = nil

	local function BackgroundScene(value2, p2)
		if flag7 then
			return
		end

		flag7 = true
		local v5 = p2 or TweenInfo.new(0.4)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(passiveScenceFrame.BackgroundFrame, v5, {
			BackgroundTransparency = value2 or 1
		}):Play()
	end

	passiveScenceFrame.BackgroundFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TweenService:Create(passiveScenceFrame.SkipLabel, TweenInfo.new(0.5), {
		Position = UDim2.new(0.5, 0, 0.85, 0)
	}):Play()
	PeodizService.new({
		Time = 3
	}, function(p2)
		track2.TimePosition = math.max(track2.Length * p2, 0.1)

		if p2 < 0.95 then
			track.TimePosition = track.Length * p2
		end

		if p2 >= 0.88 then
			BackgroundScene(0)
		end

		if flag6 then
			BackgroundScene(0)
			return true
		else
			currentCamera.CFrame = enchantCutscene.CameraRig.CameraHead.CFrame
		end
	end)
	flag7 = nil
	track:Stop(0)
	track2:Stop(0)
	wait()
	ResetBooks()

	if p and not flag6 then
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.Linear,
			SoundId = "rbxassetid://16982785109",
			Volume = 2,
			Name = "GotSpecialPassiveSound"
		})
		_G.PU:Dust(sound2, 15)
		sound2.Parent = workspace.Effects
		sound2:Play()
		task.wait(0.5)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(passiveScenceFrame.BackgroundFrame, TweenInfo.new(0.75), {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}):Play()
		task.wait(0.75)
		passiveScenceFrame.BackgroundFrame.Transparency = 1
		SpecialScene(p)
		passiveScenceFrame.SpecialFrame.Visible = nil
	end

	TweenService:Create(passiveScenceFrame.SkipLabel, TweenInfo.new(0.5), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	}):Play()
	BackgroundScene(1, TweenInfo.new(0.8))
	currentCamera.CameraType = Enum.CameraType.Custom
end

function UpdatePlayerBook()
	local jSONDecode = HttpService:JSONDecode(material.Value)

	for _, button in pairs(confirmFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		button.Visible = nil
		local v5 = jSONDecode[button.Name] or 0

		if not (v5 > 0) then
			continue
		end

		button.Amount.Text = "x" .. v5
		button.Visible = true
	end
end

local thread = nil

function ShowNewPassives(list, p)
	confirmFrame.Visible = nil
	hide.Visible = confirmFrame.Visible
	frame.Visible = nil
	local tier = nil

	for _, v5 in pairs(list) do
		local v6 = PassiveList[v5.PassiveName]

		if v6 and (v6.Tier == "Iconic" or v6.Tier == "Celestial") then
			tier = v6.Tier
		end
	end

	_G.VisibleGui(nil)
	local flag7 = nil

	if not flag7 and statsFrame.Visible then
		statsFrame.Visible = nil
		flag7 = true
	end

	if thread then
		task.cancel(thread)
		thread = nil
	end

	StartCutscene(p, tier)
	_G.VisibleGui(true)

	if flag7 then
		statsFrame.Visible = true
	end

	frame.Visible = true
	table.sort(list, function(a, b)
		return (a.PassiveLevel or 100) < (b.PassiveLevel or 100)
	end)

	for _, frame2 in pairs(frame.ScrollingFrame:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	local v5 = flag6 and 3 or 1.5
	thread = task.spawn(function()
		for _, v6 in pairs(list) do
			local paradox = PassiveList[v6.PassiveName]

			if v6.Paradox then
				paradox = PassiveList.Paradox

				if paradox then
					paradox = table.clone(paradox)
					local v7 = _G.ProcessName(v6.PassiveName)
					paradox.Info = paradox.Info and paradox.Info:format(CustomNames[v7] or v7)
				end
			end

			if not paradox then
				continue
			end

			local clone = script.Passive:Clone()
			local imageLabel = clone.ImageLabel
			local passiveName = clone.PassiveName
			local info = clone.Info
			local rarityBackground = clone.RarityBackground
			imageLabel.Size = UDim2.new(2.5, 0, 2.5, 0)
			imageLabel.ImageTransparency = 1
			imageLabel.Image = paradox.Image or ""
			local v7 = v6.Paradox and SwordList[v6.PassiveName]

			if v7 then
				imageLabel.Image = v7.Image or ""
			end

			clone.Name = v6.PassiveName
			clone.Visible = true
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.Gui.ShineFrame:Clone()
				_G.PU:Dust(clone2, 1)
				clone2.ZIndex = 2
				clone2.Size = UDim2.fromScale(1, 1)
				local shine = clone2.Shine
				shine.ImageColor3 = v4[paradox.Tier] or Color3.fromRGB(255, 255, 255)
				shine.Position = UDim2.fromScale(-0.35, 0.5)
				shine.UIAspectRatioConstraint:Destroy()
				TweenService:Create(shine, TweenInfo.new(3 / v5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = UDim2.fromScale(1.5, 0.5)
				}):Play()
				clone2.Parent = clone
			end)
			passiveName.TextTransparency = 1
			passiveName.TextStrokeTransparency = 1
			passiveName.TextColor3 = Color3.fromRGB(255, 255, 255)
			passiveName.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			info.TextTransparency = 1
			info.TextStrokeTransparency = 1
			info.TextColor3 = Color3.fromRGB(255, 255, 255)
			info.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			info.Text = paradox.Info
			passiveName.Text = CustomNames[v6.PassiveName] or v6.PassiveName
			passiveName.Text = _G.ProcessName(passiveName.Text)
			passiveName.TextColor3 = v4[paradox.Tier] or Color3.fromRGB(255, 255, 255)
			rarityBackground.ImageColor3 = Color3.fromRGB(188, 188, 188)
			local color = Color3.fromRGB(255, 255, 255)
			local soundId = "rbxassetid://9065073444"
			local volume = 0.5
			local v11 = 1

			if paradox.Tier == "Curse" then
				color = Color3.fromRGB(170, 0, 0)
				rarityBackground.ImageColor3 = Color3.fromRGB(170, 0, 0)
				passiveName.TextColor3 = Color3.fromRGB(170, 0, 0)
				passiveName.Text ..= " <font color=\"#640000\">(CURSE)</font>"
				soundId = "rbxassetid://75213214992269"
				volume = 0.5
				v11 = 2.5
			elseif paradox.Tier == "Iconic" then
				color = Color3.fromRGB(255, 255, 127)
				rarityBackground.ImageColor3 = Color3.fromRGB(255, 255, 127)
				passiveName.TextColor3 = Color3.fromRGB(255, 255, 127)
				passiveName.Text ..= " <font color=\"#ffb700\">(ICONIC)</font>"
				soundId = "rbxassetid://6947277163"
				volume = 0.5
				v11 = 2.5
			elseif paradox.Tier == "Celestial" then
				color = Color3.fromRGB(170, 255, 255)
				rarityBackground.ImageColor3 = Color3.fromRGB(170, 255, 255)
				passiveName.TextColor3 = Color3.fromRGB(170, 255, 255)
				passiveName.Text ..= " <font color=\"#00d0ff\">(CELESTIAL)</font>"
				soundId = "rbxassetid://6875009415"
				volume = 1
				v11 = 2.5
			elseif paradox.Tier == "Paradox" then
				color = Color3.fromRGB(70, 255, 122)
				rarityBackground.ImageColor3 = Color3.fromRGB(70, 255, 122)
				passiveName.TextColor3 = Color3.fromRGB(70, 255, 122)
				passiveName.Text ..= " <font color=\"#2fac50\">(PARADOX)</font>"
				soundId = "rbxassetid://122776947852644"
				volume = 0.5
				v11 = 2.5
			else
				local clone_2 = script.NormalGD:Clone()
				clone_2.Parent = imageLabel
			end

			clone.Size = UDim2.new(0.95, 0, 0, frame.ScrollingFrame.AbsoluteSize.Y * 0.4)
			coroutine.wrap(function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = soundId,
					Volume = volume,
					PlaybackSpeed = 1,
					Name = "PassiveAppearFrame"
				})
				_G.PU:Dust(sound, v11)
				sound.Parent = workspace.Effects
				sound:Play()
			end)()

			if paradox.PassiveBuff then
				for k, v12 in pairs(paradox.PassiveBuff) do
					if not v6.PassiveLevel then
						continue
					end

					local v13 = v12[v6.PassiveLevel]

					if v13 then
						info.Text = info.Text:gsub(k, v13) .. "%"
					end
				end
			end

			clone.Parent = frame.ScrollingFrame

			if v6.PassiveLevel and v2[v6.PassiveLevel] then
				passiveName.Text ..= " " .. v2[v6.PassiveLevel]
			end

			frame.ScrollingFrame.CanvasSize = UDim2.new(
				0,
				0,
				0,
				frame.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
			)
			TweenService:Create(frame.ScrollingFrame, TweenInfo.new(0.5 / v5), {
				CanvasPosition = Vector2.new(0, frame.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
			}):Play()
			task.spawn(function()
				TweenService:Create(imageLabel, TweenInfo.new(0.5 / v5), {
					ImageTransparency = 0,
					Size = UDim2.new(0.8, 0, 0.8, 0)
				}):Play()
				TweenService:Create(passiveName, TweenInfo.new(0.5 / v5), {
					TextTransparency = 0,
					TextStrokeTransparency = 0
				}):Play()
				TweenService:Create(info, TweenInfo.new(0.5 / v5), {
					TextTransparency = 0
				}):Play()
				task.wait(0.1 / v5)
				TweenService:Create(passiveName, TweenInfo.new(0.1 / v5), {
					TextColor3 = color
				}):Play()
				TweenService:Create(info, TweenInfo.new(0.1 / v5), {
					TextStrokeTransparency = 0
				}):Play()
				task.wait(0.2 / v5)
				TweenService:Create(passiveName, TweenInfo.new(0.75 / v5), {
					TextStrokeColor3 = Color3.fromRGB()
				}):Play()
				TweenService:Create(info, TweenInfo.new(0.75 / v5), {
					TextStrokeColor3 = Color3.fromRGB()
				}):Play()
			end)
			wait(0.7 / v5)
		end
	end)
end

function ShowPassives()
	for _, frame2 in pairs(frame.ScrollingFrame:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	local character2 = HttpService:JSONDecode(playerStats.Passives.Value).Character

	if not character2 then
		return
	end

	table.sort(character2, function(a, b)
		return (a.PassiveLevel or 100) < (b.PassiveLevel or 100)
	end)

	for _, v5 in pairs(character2) do
		local paradox = PassiveList[v5.PassiveName]

		if v5.Paradox then
			paradox = PassiveList.Paradox

			if paradox then
				paradox = table.clone(paradox)
				local v6 = _G.ProcessName(v5.PassiveName)
				paradox.Info = paradox.Info and paradox.Info:format(CustomNames[v6] or v6)
			end
		end

		if not paradox then
			continue
		end

		local color = Color3.fromRGB(255, 255, 255)
		local clone = script.Passive:Clone()
		local passiveName = clone.PassiveName
		local info = clone.Info
		clone.ImageLabel.Image = paradox.Image or ""
		clone.Name = v5.PassiveName
		clone.Visible = true
		local v6 = v5.Paradox and SwordList[v5.PassiveName]

		if v6 then
			clone.ImageLabel.Image = v6.Image or ""
		end

		passiveName.TextColor3 = Color3.fromRGB(255, 255, 255)
		info.TextColor3 = Color3.fromRGB(255, 255, 255)
		info.Text = paradox.Info
		passiveName.Text = CustomNames[v5.PassiveName] or v5.PassiveName
		passiveName.Text = _G.ProcessName(passiveName.Text)
		passiveName.TextColor3 = v4[paradox.Tier] or Color3.fromRGB(255, 255, 255)

		if paradox.Tier == "Curse" then
			color = Color3.fromRGB(170, 0, 0)
			passiveName.Text ..= " <font color=\"#640000\">(CURSE)</font>"
		elseif paradox.Tier == "Iconic" then
			color = Color3.fromRGB(255, 255, 127)
			passiveName.Text ..= " <font color=\"#ffb700\">(ICONIC)</font>"
		elseif paradox.Tier == "Celestial" then
			color = Color3.fromRGB(164, 231, 255)
			passiveName.Text ..= " <font color=\"#00d0ff\">(CELESTIAL)</font>"
		elseif paradox.Tier == "Paradox" then
			color = Color3.fromRGB(70, 255, 122)
			passiveName.Text ..= " <font color=\"#2fac50\">(PARADOX)</font>"
		else
			local clone_2 = script.NormalGD:Clone()
			clone_2.Parent = clone.ImageLabel
		end

		clone.Size = UDim2.new(0.95, 0, 0, frame.ScrollingFrame.AbsoluteSize.Y * 0.4)
		clone.RarityBackground.ImageColor3 = color
		clone.PassiveName.TextColor3 = color

		if paradox.PassiveBuff then
			for k, v7 in pairs(paradox.PassiveBuff) do
				if not v5.PassiveLevel then
					continue
				end

				local v8 = v7[v5.PassiveLevel]

				if v8 then
					info.Text = info.Text:gsub(k, v8) .. "%"
				end
			end
		end

		clone.Parent = frame.ScrollingFrame

		if v5.PassiveLevel and v2[v5.PassiveLevel] then
			passiveName.Text ..= " " .. v2[v5.PassiveLevel]
		end
	end

	frame.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, frame.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end

UpdatePlayerBook()
ShowPassives()
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
end)

function FormatChance(p)
	return p % 1 == 0 and string.format("%d", p) or string.format("%.1f", p)
end

function TweenInfomationIn(p)
	local characterPassiveRate = CharacterPassiveRates[p.Name]

	if not characterPassiveRate then
		return
	end

	local v5 = not characterPassiveRate.Iconic and "???" or FormatChance(characterPassiveRate.Iconic[1] / characterPassiveRate.Iconic[2] * 100) or "???"
	local v6 = not characterPassiveRate.Celestial and "???" or FormatChance(characterPassiveRate.Celestial[1] / characterPassiveRate.Celestial[2] * 100) or "???"
	local paradox = characterPassiveRate.Paradox or "???"
	local v7 = not characterPassiveRate.Curse and "???" or FormatChance(characterPassiveRate.Curse[1] / characterPassiveRate.Curse[2] * 100) or "???"
	local common = characterPassiveRate.Common or "???"
	information.PassiveRateFrame.Iconic.Text = v5 .. "%"
	information.PassiveRateFrame.Celestial.Text = v6 .. "%"
	information.PassiveRateFrame.Paradox.Text = "+" .. paradox
	information.PassiveRateFrame.Curse.Text = v7 .. "%"
	information.PassiveRateFrame.Common.Text = "+" .. common
	information.NameText.Text = p.Name
	information.Icon.Image = p.ImageLabel.Image
	information.Position = UDim2.new(0.8, 0, 0.5, 0)
	information.Visible = true
	TweenService:Create(information, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
		Position = UDim2.new(1.175, 0, 0.5, 0)
	}):Play()
end

function TweenInfomationOut()
	TweenService:Create(information, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
		Position = UDim2.new(0.8, 0, 0.5, 0)
	}):Play()
	task.wait(0.1)
	information.Visible = false
end

function Deselected()
	for _, button in pairs(confirmFrame.ScrollingFrame:GetChildren()) do
		if button:IsA("ImageButton") then
			button.Highlight.Visible = false
		end
	end
end

for _, button in pairs(confirmFrame.ScrollingFrame:GetChildren()) do
	if not button:IsA("ImageButton") then
		continue
	end

	local v5 = button
	button.MouseButton1Click:Connect(function()
		if passiveRateList.Visible then
			return
		end

		_G.ClickFrameEffect({
			Sound = true
		})

		if name == v5.Name then
			name = nil
			Deselected()
			task.spawn(function()
				TweenInfomationOut()
			end)
		else
			name = v5.Name
			Deselected()
			TweenInfomationIn(v5)
			v5.Highlight.Visible = true
			local imageLabel = v5:FindFirstChild("ImageLabel")

			if imageLabel then
				imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				TweenService:Create(
					imageLabel,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						ImageColor3 = Color3.fromRGB()
					}
				):Play()
			end
		end
	end)
end

confirmFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if not confirmFrame.Visible and name and not _G.CheckMaterialClient(localPlayer, name) then
		name = nil
		Deselected()
		task.spawn(function()
			TweenInfomationOut()
		end)
	end
end)
reroll.MouseButton1Click:Connect(function()
	if v[game.PlaceId] or confirmFrame.Visible then
		return
	end

	_G.ClickFrameEffect({
		Sound = true
	})
	confirmFrame.Visible = not confirmFrame.Visible
	hide.Visible = confirmFrame.Visible
end)
reroll.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = reroll,
		Circle = true,
		CornerRadius = UDim.new(0.3, 0)
	})
	reroll.Size = UDim2.new(0.29, 0, 0.135, 0)
	TweenService:Create(reroll, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.33349999999999996, 0, 0.15525, 0)
	}):Play()
end)
reroll.MouseLeave:Connect(function()
	TweenService:Create(reroll, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.29, 0, 0.135, 0)
	}):Play()
end)
confirmFrame.Cancel.MouseButton1Click:Connect(function()
	if not confirmFrame.Visible or passiveRateList.Visible then
		return
	end

	_G.ClickFrameEffect({
		Sound = true
	})
	confirmFrame.Visible = false
	hide.Visible = confirmFrame.Visible
end)
confirmFrame.Cancel.MouseEnter:Connect(function()
	confirmFrame.Cancel.Size = UDim2.new(0.318, 0, 0.15, 0)
	TweenService:Create(confirmFrame.Cancel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.36569999999999997, 0, 0.1725, 0)
	}):Play()
end)
confirmFrame.Cancel.MouseLeave:Connect(function()
	TweenService:Create(confirmFrame.Cancel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.318, 0, 0.15, 0)
	}):Play()
end)

function SelectBookAlert()
	local message = playerStats.Language.Value == "TH" and "กรุณาเลือก<font color='#ff0000'>สมุด</font> ก่อน" or "Please select a <font color='#ff0000'>book</font> first"
	ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
		Name = "Pls Select Passive Book",
		Overlay = true,
		Message = message,
		Color = Color3.fromRGB(255, 255, 255)
	})
end

local v5 = true
confirmFrame.Confirm.MouseButton1Click:Connect(function()
	if not confirmFrame.Visible or passiveRateList.Visible then
		return
	end

	pcall(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)

	if not name then
		SelectBookAlert()
		return
	end

	if not v5 then
		return
	end

	v5 = nil
	local success, result = pcall(function()
		local v6, v7, v8 = ReplicatedStorage.Chest.Remotes.Functions.Enchant:InvokeServer(name)

		if v6 then
			ShowNewPassives(v7, v8)
		end
	end)

	if not success then
		warn(result)
	end

	task.wait(0.1)
	v5 = true
end)
confirmFrame.Confirm.MouseEnter:Connect(function()
	confirmFrame.Confirm.Size = UDim2.new(0.318, 0, 0.15, 0)
	TweenService:Create(confirmFrame.Confirm, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.36569999999999997, 0, 0.1725, 0)
	}):Play()
end)
confirmFrame.Confirm.MouseLeave:Connect(function()
	TweenService:Create(confirmFrame.Confirm, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.318, 0, 0.15, 0)
	}):Play()
end)
local clonesByTier = {}
local v6 = {}
local v7 = nil
passiveRateList.ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	if not v7 then
		return
	end

	v7 = nil
end)

function LoadPassiveRates()
	for k, v8 in pairs(PassiveList) do
		local tier = v8.Tier

		if not tier then
			continue
		end

		local clone = passiveRateList.ScrollingFrame:FindFirstChild(tier)

		if not clone then
			clone = script.Files.PassiveTierFrame:Clone()
			clone.Name = tier
			clone.Parent = passiveRateList.ScrollingFrame
			clone.LayoutOrder = v3[tier] or 0
			clonesByTier[tier] = clone
		end

		v6[tier] = v6[tier] or {}
		local clone2 = script.Files.PassiveRateFrame:Clone()
		clone2.Name = k
		clone2.InnerFrame.PassiveRate.TextColor3 = v4[tier] or Color3.fromRGB(255, 255, 255)
		clone2.InnerFrame.PassiveName.Text = k
		clone2.InnerFrame.PassiveIcon.Image = v8.Image or ""

		if tier == "Common" then
			local clone_2 = script.NormalGD:Clone()
			clone_2.Parent = clone2.InnerFrame.PassiveIcon
		end

		local v10 = k
		clone2.MouseEnter:Connect(function()
			if v7 then
				return
			end

			local percentage = clone2:GetAttribute("Percentage")

			if not percentage then
				return
			end

			v7 = v10
			local clone3 = parent.LocalScript.File.RateLabel:Clone()
			clone3.Text = percentage
			clone3.TextColor3 = clone2.InnerFrame.PassiveRate.TextColor3

			-- equivalent calls inferred from this helper; original call sites unknown
			local function UpdatePosition()
				local mouseLocation = UserInputService:GetMouseLocation()
				clone3.Position = UDim2.new(
					0,
					mouseLocation.X + clone3.AbsoluteSize.X / 2,
					0,
					mouseLocation.Y - clone3.AbsoluteSize.Y
				)
			end

			clone3.Parent = parent
			UpdatePosition() -- equivalent call inferred; original call site unknown

			while v7 == v10 do
				RunService.Heartbeat:Wait()
				UpdatePosition() -- equivalent call inferred; original call site unknown
			end

			clone3:Destroy()
		end)
		clone2.MouseLeave:Connect(function()
			v7 = nil
		end)
		clone2.Parent = clone.Lists

		if k == "Paradox" then
			clone2.InnerFrame.PassiveRate.Position = UDim2.new(0.7, 0, 0.5, 0)
			clone2.InnerFrame.PassiveRate.Size = UDim2.new(0.3, 0, 1, 0)
			clone2.InnerFrame.PassiveName.Position = UDim2.new(0.05, 0, 0.5, 0)
			clone2.InnerFrame.PassiveName.Size = UDim2.fromScale(0.65, 1)
			clone2.InnerFrame.PassiveName.Text = "Chance to get your desired fruit/sword/fighting style:"
		end

		table.insert(v6[tier], clone2)
	end
end

function FormatPercentage(value)
	if not (type(value) == "number" and value ~= 0) then
		return "???"
	end

	local function Truncate(p, value2)
		local v8 = 10 ^ (value2 or 0)
		return math.floor(p * v8) / v8
	end

	local v8 = math.floor(value * 100000) / 100000
	return (string.format("%.5f", v8))
end

function UpdateRarityPassives(p)
	for k, v8 in pairs(clonesByTier) do
		local v9 = p and p[k]
		local v10 = nil

		if v9 and typeof(v9) == "table" then
			v10 = v9[1] / v9[2] * 100
		elseif v9 and typeof(v9) == "number" then
			v8.InnerFrame.Tier.Text = `{k} - 100% (+{v9})`
			continue
		end

		v8.InnerFrame.Tier.Text = `{k} - {FormatChance(v10) or "???"}%`
	end

	for k, list in pairs(v6) do
		local v8 = p and p[k]
		local v9 = nil

		if v8 and typeof(v8) == "table" then
			v9 = v8[1] / v8[2] * 100 / #list
		elseif v8 and typeof(v8) == "number" then
			v9 = v8 / #list

			if k == "Paradox" then
				v9 = 1 / count * 100
			elseif k == "Common" then
				v9 = 1 / #list * 100
			end
		end

		local text = not v9 and "???%" or `{FormatPercentage(v9)}%` or "???%"

		for _, v11 in ipairs(list) do
			v11.InnerFrame.PassiveRate.Text = text
			v11:SetAttribute("Percentage", (`{v9}%`))
			v11:SetAttribute("FormatPercentage", text)
		end
	end
end

function UpdateTierFrameSize()
	local v8 = passiveRateList.ScrollingFrame.AbsoluteSize - Vector2.new(
		passiveRateList.ScrollingFrame.ScrollBarThickness,
		0
	)

	for k, v9 in pairs(clonesByTier) do
		local v10 = v8.Y * 0.125
		local v11 = v8.X * 0.5
		local v12 = v8.Y * 0.15
		v9.InnerFrame.Size = UDim2.new(0.975, 0, 0, v10)
		v9.InnerFrame.Tier.Text = k
		v9.InnerFrame.Tier.TextColor3 = v4[k] or v4.Common
		v9.Lists.Position = UDim2.fromOffset(0, v10 + 5)
		v9.Lists.UIGridLayout.CellSize = UDim2.fromOffset(v11, v12)
		v9.Size = UDim2.new(1, 0, 0, v10 + 5 + math.ceil((#v9.Lists:GetChildren() - 1) / 2) * v12 + 5)
	end
end

LoadPassiveRates()
UpdateTierFrameSize()
passiveRateList:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTierFrameSize)
passiveRateButton.MouseButton1Click:Connect(function()
	if not confirmFrame.Visible then
		return
	end

	pcall(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)

	if not name then
		SelectBookAlert()
		return
	end

	UpdateRarityPassives(CharacterPassiveRates[name])
	passiveRateList.Visible = true
end)
passiveRateButton.MouseEnter:Connect(function()
	passiveRateButton.Size = UDim2.new(0.245, 0, 0.15, 0)
	TweenService:Create(passiveRateButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.28175, 0, 0.1725, 0)
	}):Play()
end)
passiveRateButton.MouseLeave:Connect(function()
	TweenService:Create(passiveRateButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.245, 0, 0.15, 0)
	}):Play()
end)
material.Changed:Connect(function()
	wait()
	UpdatePlayerBook()
end)
ReplicatedStorage.Chest.Remotes.Events.PassiveUpdater.OnClientEvent:Connect(function()
	wait()
	ShowPassives()
end)
local name2 = nil

function UpdateSlotInfoPassive()
	if not name2 then
		return
	end

	local v8 = ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("GetPassiveInSlot", {
		Slot = name2
	}) or {}

	for _, frame2 in pairs(slotInfoFrame.ScrollingFrame:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	local child = passiveBagFrame.ScrollingFrame:FindFirstChild(name2)

	if child then
		slotInfoFrame.NameBorder.NameLabel.Text = child.Text
	end

	if #v8 <= 0 then
		return
	end

	table.sort(v8, function(a, b)
		return (a.PassiveLevel or 100) < (b.PassiveLevel or 100)
	end)

	for _, v9 in pairs(v8) do
		local paradox = PassiveList[v9.PassiveName]

		if v9.Paradox then
			paradox = PassiveList.Paradox

			if paradox then
				paradox = table.clone(paradox)
				local v10 = _G.ProcessName(v9.PassiveName)
				paradox.Info = paradox.Info and paradox.Info:format(CustomNames[v10] or v10)
			end
		end

		if not paradox then
			continue
		end

		local color = Color3.fromRGB(255, 255, 255)
		local clone = script.Passive:Clone()
		local passiveName = clone.PassiveName
		local info = clone.Info
		clone.ImageLabel.Image = paradox.Image or ""
		clone.Name = v9.PassiveName
		clone.Visible = true
		local v10 = v9.Paradox and SwordList[v9.PassiveName]

		if v10 then
			clone.ImageLabel.Image = v10.Image or ""
		end

		passiveName.TextColor3 = Color3.fromRGB(255, 255, 255)
		info.TextColor3 = Color3.fromRGB(255, 255, 255)
		info.Text = paradox.Info
		passiveName.Text = CustomNames[v9.PassiveName] or v9.PassiveName
		passiveName.Text = _G.ProcessName(passiveName.Text)
		passiveName.TextColor3 = v4[paradox.Tier] or Color3.fromRGB(255, 255, 255)

		if paradox.Tier == "Curse" then
			color = Color3.fromRGB(170, 0, 0)
			passiveName.Text ..= " <font color=\"#640000\">(CURSE)</font>"
		elseif paradox.Tier == "Iconic" then
			color = Color3.fromRGB(255, 255, 127)
			passiveName.Text ..= " <font color=\"#ffb700\">(ICONIC)</font>"
		elseif paradox.Tier == "Celestial" then
			color = Color3.fromRGB(164, 231, 255)
			passiveName.Text ..= " <font color=\"#00d0ff\">(CELESTIAL)</font>"
		elseif paradox.Tier == "Paradox" then
			color = Color3.fromRGB(70, 255, 122)
			passiveName.Text ..= " <font color=\"#2fac50\">(PARADOX)</font>"
		else
			local clone_2 = script.NormalGD:Clone()
			clone_2.Parent = clone.ImageLabel
		end

		clone.Size = UDim2.new(0.95, 0, 0, frame.ScrollingFrame.AbsoluteSize.Y * 0.4)
		clone.RarityBackground.ImageColor3 = color
		clone.PassiveName.TextColor3 = color

		if paradox.PassiveBuff then
			for k, v11 in pairs(paradox.PassiveBuff) do
				if not v9.PassiveLevel then
					continue
				end

				local v12 = v11[v9.PassiveLevel]

				if v12 then
					info.Text = info.Text:gsub(k, v12) .. "%"
				end
			end
		end

		clone.Parent = slotInfoFrame.ScrollingFrame

		if v9.PassiveLevel and v2[v9.PassiveLevel] then
			passiveName.Text ..= " " .. v2[v9.PassiveLevel]
		end
	end

	slotInfoFrame.ScrollingFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		slotInfoFrame.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
	)
end

function UpdateBagSize()
	local scrollingFrame = passiveBagFrame.ScrollingFrame
	local uIGridLayout = scrollingFrame.UIGridLayout

	for _, button in pairs(scrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		uIGridLayout.CellSize = UDim2.new(
			0,
			scrollingFrame.AbsoluteSize.X * 1 - scrollingFrame.ScrollBarThickness,
			0,
			scrollingFrame.AbsoluteSize.Y * 0.2
		)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end
end

function UpdateBag()
	local v8 = ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("GetPassiveSlotName") or {}

	for i = 1, passiveBag.Value do
		local child = passiveBagFrame.ScrollingFrame:FindFirstChild("Slot" .. i)

		if child then
			if v8["Slot" .. i] then
				child.Text = v8["Slot" .. i]
			end
		else
			local clone = script.BagSlot:Clone()
			clone.Name = "Slot" .. i
			clone.Text = "Slot" .. i

			if v8["Slot" .. i] then
				clone.Text = v8["Slot" .. i]
			end

			clone.LayoutOrder = i
			clone.MouseButton1Click:Connect(function()
				_G.ClickFrameEffect({
					Sound = true
				})

				if name2 == clone.Name then
					name2 = nil
					slotInfoFrame.Visible = nil
				else
					name2 = clone.Name
					UpdateSlotInfoPassive()
					slotInfoFrame.Visible = true
				end
			end)
			clone.Parent = passiveBagFrame.ScrollingFrame
		end
	end

	UpdateBagSize()
	local child = name2 and passiveBagFrame.ScrollingFrame:FindFirstChild(name2)

	if child then
		slotInfoFrame.NameBorder.NameLabel.Text = child.Text
	end
end

UpdateBag()
passiveBag.Changed:Connect(function()
	wait()
	UpdateBag()
end)
slotInfoFrame.Back.MouseButton1Click:Connect(function()
	name2 = nil
	slotInfoFrame.Visible = nil
end)
slotInfoFrame.Equip.MouseButton1Click:Connect(function()
	if not name2 then
		return
	end

	if flag2 then
		flag3 = true
		flag2 = nil
	else
		_G.ClickFrameEffect({
			Sound = true
		})
		flag3 = nil
		flag2 = true
		local lastTime = tick()

		while true do
			local v8 = math.ceil(3 - (tick() - lastTime))
			slotInfoFrame.Equip.Text = "CLICK AGAIN TO CONFIRM (" .. v8 .. ")"

			if tick() - lastTime > 3 or flag3 then
				break
			end

			task.wait()
		end

		if flag3 then
			slotInfoFrame.Equip.Text = "Equipping"

			if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipPassive", {
				Slot = name2
			}) then
				name2 = nil
				slotInfoFrame.Visible = nil
			end

			slotInfoFrame.Equip.Text = "Equip"
		else
			slotInfoFrame.Equip.Text = "Equip"
			flag3 = nil
			flag2 = nil
		end
	end
end)
slotInfoFrame.Store.MouseButton1Click:Connect(function()
	if not name2 then
		return
	end

	if flag4 then
		flag5 = true
		flag4 = nil
	else
		_G.ClickFrameEffect({
			Sound = true
		})
		flag5 = nil
		flag4 = true
		local lastTime = tick()

		while true do
			local v8 = math.ceil(3 - (tick() - lastTime))
			slotInfoFrame.Store.Text = "CLICK AGAIN TO CONFIRM (" .. v8 .. ")"

			if tick() - lastTime > 3 or flag5 then
				break
			end

			task.wait()
		end

		if flag5 then
			slotInfoFrame.Store.Text = "Storing"

			if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("StorePassive", {
				Slot = name2
			}) then
				UpdateSlotInfoPassive()
			end

			slotInfoFrame.Store.Text = "Store"
		else
			slotInfoFrame.Store.Text = "Store"
			flag5 = nil
			flag4 = nil
		end
	end
end)
passiveBagFrame.ScrollingFrame.Buy.MouseButton1Click:Connect(function()
	if playerStats.PassiveBag.Value >= 25 then
		return
	end

	_G.ClickFrameEffect({
		Sound = true
	})
	ReplicatedStorage.Chest.Remotes.Functions.Product:InvokeServer({
		ProductName = "PassiveBag",
		PurchaseType = "Transfer"
	})
end)
passiveBagFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	passiveBagFrame.Visible = nil
	slotInfoFrame.Visible = nil
	name2 = nil
end)
passiveBagFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = passiveBagFrame.Close,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	passiveBagFrame.Close.Size = UDim2.new(0.125, 0, 0.125, 0)
	TweenService:Create(passiveBagFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.14375, 0, 0.14375, 0)
	}):Play()
end)
passiveBagFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(passiveBagFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.125, 0, 0.125, 0)
	}):Play()
end)
frame.RenameFrame.Confirm.MouseButton1Click:Connect(function()
	if not name2 then
		return
	end

	_G.ClickFrameEffect({
		Sound = true
	})

	if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("RenamePassiveSlot", {
		Slot = name2,
		Text = frame.RenameFrame.TextBox.Text
	}) then
		frame.RenameFrame.Visible = nil
		UpdateBag()
	end
end)
frame.RenameFrame.Cancel.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	frame.RenameFrame.Visible = nil
end)
slotInfoFrame.Rename.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	frame.RenameFrame.Visible = true
end)