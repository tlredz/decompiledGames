local createVector = vector.create
local StickerController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local screenGui = nil
local stickerMenu = nil
local stickers = nil
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utils"):WaitForChild("spr"))
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClientUI"):WaitForChild("MyDataController"))
local Stickers = require(ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("Stickers"))
local SpriteClip2 = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("External"):WaitForChild("SpriteClip2"))
local StickerAnimations = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("StickerAnimations"))
local StickerNotificationUI = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("StickerNotificationUI"))
local AdminUsers = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("AdminUsers"))
local InputService = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("InputService"))
local CameraAuthority = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("CameraAuthority"))
local MenuManager = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("MenuManager"))
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))
local SettingsFlags = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("SettingsFlags"))
local Universe = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Universe"))
local GameContext = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("GameContext"))
local sticker = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sticker")
local uDim = UDim2.fromScale(7, 7)
local uDim2 = UDim2.fromScale(0.5, 0.5)
local uDim3 = UDim2.fromScale(1, 0.1)
local uDim4 = UDim2.fromScale(0.5, 1)
local vector2 = Vector2.new(0.5, 1)

local function getStickerWorldOffset()
	if Universe:IsGame() then
		return createVector(0, 4.1, 0)
	end

	return createVector(0, 2.6, 0)
end

local useSticker = ReplicatedStorage:WaitForChild("UseSticker")
local v = false
local v2 = nil
local v3 = nil
local v4 = table.find(AdminUsers.Devs, localPlayer.UserId) ~= nil
local v5 = v4 and 1 or 10
local tweenInfo = TweenInfo.new(v5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local numberValue = Instance.new("NumberValue")
numberValue.Value = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function isDevCooldownBypassed()
	return v4 and localPlayer:GetAttribute("DevStickerCooldownBypass") == true
end

local v6 = false
local now = 0
local v7 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(childName: string)
	local sound = screenGui:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		sound:Stop()
		sound:Play()
	elseif childName == "Click" then
		local sound2 = Instance.new("Sound")
		sound2.Name = "Click"
		sound2.SoundId = "rbxassetid://552900451"
		sound2.Volume = 0.5
		sound2.Parent = screenGui
		sound2:Play()
	elseif childName == "Hover" then
		local sound2 = Instance.new("Sound")
		sound2.Name = "Hover"
		sound2.SoundId = "rbxassetid://6895079853"
		sound2.Volume = 0.3
		sound2.Parent = screenGui
		sound2:Play()
	end
end

local v8 = {
	up = 1,
	upright = 2,
	right = 3,
	downright = 4,
	down = 5,
	downleft = 6,
	left = 7,
	upleft = 8
}
local rBXGeneral = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local v9 = nil

local function updateStickers(stickersEquipped, p)
	for i = 1, 8 do
		stickerMenu.Options[tostring(i)].Sticker.Image = ""
		stickerMenu.Options[tostring(i)].Sticker.Label.Text = ""
		stickerMenu.Options[tostring(i)].Sticker.Label.AnchorPoint = Vector2.new(0.5, 1)
		stickerMenu.Options[tostring(i)].Sticker.Label.Position = UDim2.fromScale(0.5, 0.95)
	end

	for i = 1, 8 do
		local v10 = stickersEquipped[(p - 1) * 8 + i]

		if not (v10 and v10 ~= "" and v10 ~= nil) then
			continue
		end

		local sticker2 = Stickers[v10]

		if not sticker2 then
			continue
		end

		local displayImage = sticker2.DisplayImage or sticker2.Image or ""
		stickerMenu.Options[tostring(i)].Sticker.Image = displayImage
		stickerMenu.Options[tostring(i)].Sticker.Label.Text = sticker2.Text

		if not (displayImage == "" or displayImage == nil) then
			continue
		end

		stickerMenu.Options[tostring(i)].Sticker.Label.AnchorPoint = Vector2.new(0.5, 0.5)
		stickerMenu.Options[tostring(i)].Sticker.Label.Position = UDim2.fromScale(0.5, 0.5)
	end
end

local function toggleMenu(flag: boolean)
	v = flag
	InputService:SetContextEnabled("StickerWheel", v)

	if v then
		if not v2 then
			v2 = InputService:RequestContext("MenuNav")
		end
	elseif v2 then
		v2()
		v2 = nil
	end

	if v then
		if InputService:GetPreferredInput() == "Gamepad" then
			CameraAuthority.setRotationEnabled("StickerWheel", false)
		end
	else
		CameraAuthority.setRotationEnabled("StickerWheel", true)
	end

	if v then
		stickerMenu.Visible = true
	end

	spr.target(stickerMenu.UIScale, v and 0.55 or 1, v and 2 or 3, {
		Scale = v and 1 or 0
	})

	if not v then
		task.delay(0.3, function()
			if not v then
				stickerMenu.Visible = false
			end
		end)
	end
end

function StickerController.ForceCloseWheel()
	if v or v6 then
		print("[STICKER-FC] force-closing sticker wheel")
		v6 = false
		toggleMenu(false)
	end
end

local v10 = 0

local function isWheelBlocked()
	return v10 > 0 or GameContext.skillchecking == true
end

function StickerController.IsWheelBlocked()
	return v10 > 0 or GameContext.skillchecking == true
end

function StickerController.IsOpen()
	return v
end

function StickerController.GetMenu()
	return stickerMenu
end

function StickerController.CloseWheel()
	if v then
		toggleMenu(false)
	end
end

function StickerController.SuppressWheel()
	v10 += 1
	StickerController.ForceCloseWheel()
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		v10 = math.max(0, v10 - 1)
	end
end

local function isSettingsOpen()
	return MenuManager:IsOpen("SettingsController")
end

function StickerController.init()
	screenGui = playerGui:WaitForChild("ScreenGui")
	stickerMenu = screenGui:WaitForChild("StickerMenu")
	stickers = screenGui:WaitForChild("Stickers")
	v9 = MyDataController:waitForReplica()
	local settings = screenGui:FindFirstChild("Settings")

	if settings then
		settings:GetPropertyChangedSignal("Visible"):Connect(function()
			if settings.Visible and v then
				toggleMenu(false)
			end
		end)
	end

	stickers.Activated:Connect(function()
		if numberValue.Value > 0 and (not v4 or localPlayer:GetAttribute("DevStickerCooldownBypass") ~= true) or not v and MenuManager:IsOpen("SettingsController") then
			return
		end

		if not v and (v10 > 0 or GameContext.skillchecking == true) then
			print("[STICKER-FC] wheel open blocked (skillcheck/arcade active)")
			return
		end

		playSound("Click") -- equivalent call inferred; original call site unknown
		toggleMenu(not v)
	end)
	local v11 = 1
	local pageNum = stickerMenu:FindFirstChild("PageNum")
	local prev = stickerMenu:FindFirstChild("Prev")
	local next = stickerMenu:FindFirstChild("Next")

	if not (pageNum and prev and next) then
		warn("StickerController: Required UI elements not found in StickerMenu")
		return
	end

	local v12 = true
	stickerMenu:SetAttribute("Page", v11)
	stickerMenu:SetAttribute("LastPage", v11)

	local function hasExtraStickerSlotsGamepass()
		local myReplica = MyDataController:getMyReplica()

		if not (myReplica and myReplica.Data.Achievements) then
			return false
		end

		for _, achievement in pairs(myReplica.Data.Achievements) do
			if achievement[1] == "ExtraStickersPass" then
				return true
			end
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLocked()
		local locked = stickerMenu:GetAttribute("Locked") == true
		stickerMenu:SetAttribute("LastPage", locked and 2 or 4)
	end

	local function updateGamepassChanged()
		local v13 = hasExtraStickerSlotsGamepass() == true
		stickerMenu:SetAttribute("Locked", not v13)
	end

	stickerMenu:GetAttributeChangedSignal("LastPage"):Connect(function()
		local lastPage = stickerMenu:GetAttribute("LastPage") or 1
		prev.Visible = true
		next.Visible = true
		pageNum.Visible = true
		pageNum.Text = string.format("%d/%d", v11, lastPage)
	end)
	stickerMenu:GetAttributeChangedSignal("Locked"):Connect(function()
		updateLocked() -- equivalent call inferred; original call site unknown
	end)
	task.spawn(function()
		while not MyDataController:getMyReplica() do
			task.wait(1)
		end

		stickerMenu:SetAttribute("Locked", hasExtraStickerSlotsGamepass() ~= true)
	end)
	updateStickers(v9.Data.StickersEquipped, v11)
	v9:ListenToChange("StickersEquipped", function()
		updateStickers(v9.Data.StickersEquipped, v11)
	end)
	v9:ListenToArrayInsert("StickersEquipped", function()
		updateStickers(v9.Data.StickersEquipped, v11)
	end)
	v9:ListenToArrayRemove("StickersEquipped", function()
		updateStickers(v9.Data.StickersEquipped, v11)
	end)
	stickerMenu:GetAttributeChangedSignal("Page"):Connect(function()
		local v13 = math.clamp(tonumber(stickerMenu:GetAttribute("Page")) or 1, 1, 4)
		v11 = v13
		spr.target(stickerMenu.UIScale, 0.55, 2, {
			Scale = 0.6
		})
		spr.target(stickerMenu, 0.55, 2, {
			Rotation = v12 and 5 or -5
		})
		spr.target(prev, 0.55, 2, {
			AnchorPoint = Vector2.new(0, 0.5)
		})
		spr.target(next, 0.55, 2, {
			AnchorPoint = Vector2.new(1, 0.5)
		})
		task.delay(0.05, function()
			if v11 == v13 then
				spr.target(stickerMenu.UIScale, 0.55, 2, {
					Scale = 1
				})
				spr.target(stickerMenu, 0.55, 2, {
					Rotation = 0
				})
				spr.target(prev, 0.55, 2, {
					AnchorPoint = Vector2.new(0.5, 0.5)
				})
				spr.target(next, 0.55, 2, {
					AnchorPoint = Vector2.new(0.5, 0.5)
				})
			end
		end)
		local lastPage = stickerMenu:GetAttribute("LastPage") or 1
		pageNum.Text = string.format("%d/%d", v11, lastPage)
		updateStickers(v9.Data.StickersEquipped, v11)
	end)

	local function pageLeft()
		if not prev.Visible or stickerMenu.UIScale.Scale < 0.5 then
			return
		end

		playSound("Click") -- equivalent call inferred; original call site unknown
		v12 = false
		local lastPage = stickerMenu:GetAttribute("LastPage") or 1
		local v13 = stickerMenu

		if v11 > 1 then
			lastPage = v11 - 1 or lastPage
		end

		v13:SetAttribute("Page", lastPage)
	end

	local function pageRight()
		if not next.Visible or stickerMenu.UIScale.Scale < 0.5 then
			return
		end

		playSound("Click") -- equivalent call inferred; original call site unknown
		v12 = true
		local lastPage = stickerMenu:GetAttribute("LastPage") or 1
		stickerMenu:SetAttribute("Page", v11 < lastPage and v11 + 1 or 1)
	end

	prev.Activated:Connect(function()
		if not prev.Visible or stickerMenu.UIScale.Scale < 0.5 then
			return
		end

		playSound("Click") -- equivalent call inferred; original call site unknown
		v12 = false
		local lastPage = stickerMenu:GetAttribute("LastPage") or 1
		local v13 = stickerMenu

		if v11 > 1 then
			lastPage = v11 - 1 or lastPage
		end

		v13:SetAttribute("Page", lastPage)
	end)
	next.Activated:Connect(function()
		if not next.Visible or stickerMenu.UIScale.Scale < 0.5 then
			return
		end

		playSound("Click") -- equivalent call inferred; original call site unknown
		v12 = true
		local lastPage = stickerMenu:GetAttribute("LastPage") or 1
		stickerMenu:SetAttribute("Page", v11 < lastPage and v11 + 1 or 1)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function selectStickerIndex(p: number)
		useSticker:FireServer((v11 - 1) * 8 + p)
	end

	InputService:OnReady(function()
		InputService:OnAction("StickerMenu", function()
			if InputService:IsTyping() or not v and MenuManager:IsOpen("SettingsController") then
				return
			end

			if not v and (v10 > 0 or GameContext.skillchecking == true) then
				print("[STICKER-FC] wheel open blocked (skillcheck/arcade active)")
			elseif InputService:GetPreferredInput() == "Gamepad" then
				v6 = true
				now = os.clock()

				if not v then
					v3 = nil
					v7 = 0
					toggleMenu(true)
				end
			else
				toggleMenu(not v)
			end
		end)
		InputService:OnActionReleased("StickerMenu", function()
			if not (InputService:GetPreferredInput() == "Gamepad" and v6) then
				return
			end

			v6 = false

			if not v then
				return
			end

			if v3 and v7 > 0.5 and (numberValue.Value <= 0 or isDevCooldownBypassed()) then
				selectStickerIndex(tonumber(v3)) -- equivalent call inferred; original call site unknown
			end

			toggleMenu(false)
		end)
		InputService:OnAction("StickerPageLeft", pageLeft)
		InputService:OnAction("StickerPageRight", pageRight)
		InputService:OnAction("MenuConfirm", function()
			if not v or numberValue.Value > 0 and (not v4 or localPlayer:GetAttribute("DevStickerCooldownBypass") ~= true) then
				return
			end

			if v3 then
				selectStickerIndex(tonumber(v3)) -- equivalent call inferred; original call site unknown
				toggleMenu(false)
			end
		end)
		InputService:OnAction("MenuBack", function()
			if not v then
				return
			end

			toggleMenu(false)
		end)
	end)
	InputService.GameplayInterrupted:Connect(StickerController.ForceCloseWheel)
	local inputHint = prev:FindFirstChild("InputHint")
	local inputHint2 = next:FindFirstChild("InputHint")

	if inputHint then
		inputHint:SetAttribute("Action", "StickerPageLeft")
	end

	if inputHint2 then
		inputHint2:SetAttribute("Action", "StickerPageRight")
	end

	UserInputService.InputChanged:Connect(function(input, _: boolean)
		if not v then
			return
		end

		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			if input.KeyCode == Enum.KeyCode.Thumbstick2 then
				if not v then
					return
				end

				local X = input.Position.X
				local Y = input.Position.Y
				v7 = math.sqrt(X * X + Y * Y)
				local v13 = X > 0.5 and "right" or X < -0.5 and "left" or ""
				local v14 = (Y > 0.5 and "up" or Y < -0.5 and "down" or "") .. v13

				if v8[v14] then
					v3 = v8[v14]
				elseif v7 < 0.5 then
					v3 = nil
				end

				for _, child in stickerMenu.Options:GetChildren() do
					child.UIStroke.Color = v3 == tonumber(child.Name) and Color3.fromRGB(131, 255, 135) or Color3.fromRGB(
						0,
						0,
						0
					)
				end
			end
		else
			for _, child in stickerMenu.Options:GetChildren() do
				child.UIStroke.Color = Color3.fromRGB(0, 0, 0)
			end
		end
	end)

	for _, child in stickerMenu.Options:GetChildren() do
		local v13 = child
		child.Activated:Connect(function()
			if numberValue.Value > 0 and (not v4 or localPlayer:GetAttribute("DevStickerCooldownBypass") ~= true) then
				return
			end

			playSound("Click") -- equivalent call inferred; original call site unknown
			toggleMenu(false)
			selectStickerIndex(tonumber(v13.Name)) -- equivalent call inferred; original call site unknown
		end)
		local v14 = child
		child.MouseEnter:Connect(function()
			playSound("Hover") -- equivalent call inferred; original call site unknown
			spr.target(v14.Sticker.UIScale, 0.7, 2, {
				Scale = 1.3
			})
			spr.target(v14.Sticker, 0.5, 2, {
				Rotation = math.random(-15, 15),
				Position = UDim2.fromScale(0.5, 0.45)
			})
		end)
		local v15 = child
		child.MouseLeave:Connect(function()
			spr.target(v15.Sticker.UIScale, 0.7, 2, {
				Scale = 1
			})
			spr.target(v15.Sticker, 0.5, 2, {
				Rotation = 0,
				Position = UDim2.fromScale(0.5, 0.5)
			})
		end)
	end

	stickerMenu.Close.Activated:Connect(function()
		playSound("Click") -- equivalent call inferred; original call site unknown
		toggleMenu(false)
	end)
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		stickers.CooldownText.Visible = numberValue.Value > 0
		stickers.CooldownText.Text = numberValue.Value > 0 and string.format("%.1f", numberValue.Value) or ""
		stickers.CooldownFrame.Size = UDim2.fromScale(1, numberValue.Value / v5)
	end)
	useSticker.OnClientEvent:Connect(function(player, image: string?, text: string, data, data2, flag: boolean?, p: string?)
		local WAIT_INTERVAL = 0.125
		local character = nil
		local name = nil
		local userId = nil
		local v13 = nil

		if typeof(player) == "Instance" and player:IsA("Player") then
			character = player.Character
			name = player.Name
			userId = player.UserId
			v13 = player == localPlayer
		elseif type(player) == "string" then
			local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
			character = inGamePlayers and inGamePlayers:FindFirstChild(player)
			name = player
			v13 = false
		end

		if not character then
			return
		end

		local stickerSettings = v9.Data and v9.Data.Settings and v9.Data.Settings.StickerSettings

		if SettingsFlags:GetEffective(stickerSettings and stickerSettings.ShowWindow, "StickerSettings.ShowWindow") ~= false then
			StickerNotificationUI.ShowNotification(name, userId, image, text, p, data)
		end

		if type(player) == "string" and text and flag then
			pcall(function()
				rBXGeneral:DisplaySystemMessage(name .. ": " .. text)
			end)
		end

		if v13 then
			if text and flag then
				rBXGeneral:SendAsync(text)
			end

			task.defer(function()
				numberValue.Value = v5
				local tween = TweenService:Create(numberValue, tweenInfo, {
					Value = 0
				})
				tween.Completed:Connect(function()
					tween:Destroy()
					tween = nil
				end)
				tween:Play()
			end)
		end

		if data and data.enabled and image and image ~= "" then
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = "AnimatedSticker"
			billboardGui.Adornee = character:FindFirstChild("StickerOverride", true)
			billboardGui.Size = uDim
			billboardGui.ClipsDescendants = false
			billboardGui.StudsOffset = createVector(0, 0, 0)
			billboardGui.StudsOffsetWorldSpace = Universe:IsGame() and createVector(0, 4.1, 0) or createVector(
				0,
				2.6,
				0
			)
			billboardGui.AlwaysOnTop = true
			billboardGui.Parent = character.HumanoidRootPart
			local frame = Instance.new("Frame")
			frame.Name = "Frame"
			frame.Size = UDim2.fromScale(1, 1)
			frame.Position = UDim2.fromScale(0.5, 0.5)
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BackgroundTransparency = 1
			frame.Parent = billboardGui
			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 0
			uIScale.Parent = frame
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Icon"
			imageLabel.Size = uDim2
			imageLabel.Position = uDim4
			imageLabel.AnchorPoint = vector2
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = image
			imageLabel.ScaleType = Enum.ScaleType.Crop
			imageLabel.Parent = frame

			if text then
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "Label"
				textLabel.Size = uDim3
				textLabel.Position = UDim2.fromScale(0.5, 0.85)
				textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = text
				textLabel.TextScaled = true
				textLabel.TextColor3 = Color3.new(1, 1, 1)
				textLabel.Font = Enum.Font.SourceSansBold
				textLabel.TextStrokeTransparency = 0
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.Parent = frame
			end

			if data2 and data2.IntroAnimation then
				local introAnimation = StickerAnimations.IntroAnimations[data2.IntroAnimation.type]

				if introAnimation then
					introAnimation(frame, uIScale, data2.IntroAnimation)
				else
					spr.target(uIScale, 0.5, 2, {
						Scale = 1
					})
				end
			else
				spr.target(uIScale, 0.5, 2, {
					Scale = 1
				})
			end

			task.wait()
			imageLabel.ImageRectSize = Vector2.new(256, 256)
			imageLabel.ImageRectOffset = Vector2.new(0, 0)
			local imageSprite = SpriteClip2.ImageSprite.new({
				adornee = imageLabel,
				spriteSheetId = image,
				spriteSize = Vector2.new(256, 256),
				spriteCount = 4,
				columnCount = 2,
				frameRate = data.frameRate or 10,
				isLooped = true
			})
			imageSprite:Play()

			if data.sequence then
				imageSprite:Pause()
				local sequence = data.sequence
				local v14 = 1
				task.spawn(function()
					while billboardGui.Parent and imageSprite do
						imageSprite:SetFrame(sequence[v14])
						v14 += 1

						if v14 > #sequence then
							v14 = 1
						end

						task.wait(0.1)
					end
				end)
			end

			local v14 = {}
			local v15 = {}

			if data2 then
				if data2.Sounds and data2.Sounds.intro then
					Audio:Play(data2.Sounds.intro, {
						Volume = data2.Sounds.volume or 0.5,
						Parent = character.HumanoidRootPart
					})
				end

				local humanoidRootPart = data2.PointLight and data2.PointLight.enabled and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local pointLight = Instance.new("PointLight")
					pointLight.Brightness = data2.PointLight.brightness or 2
					pointLight.Color = data2.PointLight.color or Color3.new(1, 1, 1)
					pointLight.Range = data2.PointLight.range or 10
					pointLight.Parent = humanoidRootPart
					table.insert(v15, pointLight)
					local lightAnimation = StickerAnimations.LightAnimations[data2.PointLight.animationType or "default"]
					local v16 = lightAnimation and lightAnimation(pointLight, data2.PointLight)

					if v16 then
						table.insert(v14, v16)
					end
				end

				if data2.Particles and data2.Particles.enabled then
					local attachment = Instance.new("Attachment")
					attachment.Parent = character.HumanoidRootPart
					attachment.Position = createVector(0, 2, 0)
					local particleEmitter = Instance.new("ParticleEmitter")
					particleEmitter.Rate = data2.Particles.rate or 5
					particleEmitter.Lifetime = data2.Particles.lifetime or NumberRange.new(1, 2)
					particleEmitter.Speed = data2.Particles.speed or NumberRange.new(2, 4)
					particleEmitter.Color = data2.Particles.color or ColorSequence.new(Color3.new(1, 1, 1))
					particleEmitter.Size = data2.Particles.size or NumberSequence.new(1)
					particleEmitter.Texture = data2.Particles.texture or "rbxasset://textures/particles/sparkles_main.dds"
					particleEmitter.EmissionDirection = data2.Particles.emissionDirection or Enum.NormalId.Top
					particleEmitter.SpreadAngle = data2.Particles.spreadAngle or Vector2.new(45, 45)
					particleEmitter.Parent = attachment
					table.insert(v15, attachment)
				end

				if data2.MovementAnimation and data2.MovementAnimation.type ~= "none" then
					local movementAnimation = StickerAnimations.MovementAnimations[data2.MovementAnimation.type]
					local v16 = movementAnimation and movementAnimation(frame, data2.MovementAnimation)

					if v16 then
						table.insert(v14, v16)
					end
				end
			end

			task.wait(3)

			for _, connection in ipairs(v14) do
				if connection and connection.Connected then
					connection:Disconnect()
				end
			end

			if data2 and data2.ExitAnimation then
				local exitAnimation = StickerAnimations.ExitAnimations[data2.ExitAnimation.type]

				if exitAnimation then
					exitAnimation(frame, uIScale, data2.ExitAnimation, function()
						if imageSprite then
							imageSprite:Stop()
						end

						for _, v16 in ipairs(v15) do
							v16:Destroy()
						end

						billboardGui:Destroy()
					end)
				else
					spr.target(uIScale, 1, 2, {
						Scale = 0
					})
					task.wait(WAIT_INTERVAL)

					if imageSprite then
						imageSprite:Stop()
					end

					for _, v16 in ipairs(v15) do
						v16:Destroy()
					end

					billboardGui:Destroy()
				end
			else
				spr.target(uIScale, 1, 2, {
					Scale = 0
				})
				task.wait(WAIT_INTERVAL)

				if imageSprite then
					imageSprite:Stop()
				end

				for _, v16 in ipairs(v15) do
					v16:Destroy()
				end

				billboardGui:Destroy()
			end
		else
			local clone = sticker:Clone()
			clone.Adornee = character:FindFirstChild("StickerOverride", true)
			clone.Size = uDim
			clone.StudsOffsetWorldSpace = Universe:IsGame() and createVector(0, 4.1, 0) or createVector(0, 2.6, 0)
			clone.ClipsDescendants = false
			clone.Frame.Icon.Image = image or ""
			clone.Frame.Icon.Size = uDim2
			clone.Frame.Label.Text = (text == nil or not text) and "" or text
			clone.Frame.Label.Size = uDim3

			if image == "" then
				clone.Frame.Label.Position = UDim2.fromScale(0.5, 0.5)
				clone.Frame.Label.AnchorPoint = Vector2.new(0.5, 0.5)
			end

			clone.Parent = character:FindFirstChild("HumanoidRootPart")
			local frame = clone.Frame
			local uIScale = frame.UIScale

			if data2 and data2.IntroAnimation then
				local introAnimation = StickerAnimations.IntroAnimations[data2.IntroAnimation.type]

				if introAnimation then
					introAnimation(frame, uIScale, data2.IntroAnimation)
				else
					spr.target(uIScale, 0.5, 2, {
						Scale = 1
					})
				end
			else
				spr.target(uIScale, 0.5, 2, {
					Scale = 1
				})
			end

			local v14 = {}
			local v15 = {}

			if data2 then
				if data2.Sounds and data2.Sounds.intro then
					Audio:Play(data2.Sounds.intro, {
						Volume = data2.Sounds.volume or 0.5,
						Parent = character.HumanoidRootPart
					})
				end

				local humanoidRootPart = data2.PointLight and data2.PointLight.enabled and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local pointLight = Instance.new("PointLight")
					pointLight.Brightness = data2.PointLight.brightness or 2
					pointLight.Color = data2.PointLight.color or Color3.new(1, 1, 1)
					pointLight.Range = data2.PointLight.range or 10
					pointLight.Parent = humanoidRootPart
					table.insert(v15, pointLight)
					local lightAnimation = StickerAnimations.LightAnimations[data2.PointLight.animationType or "default"]
					local v16 = lightAnimation and lightAnimation(pointLight, data2.PointLight)

					if v16 then
						table.insert(v14, v16)
					end
				end

				if data2.Particles and data2.Particles.enabled then
					local attachment = Instance.new("Attachment")
					attachment.Parent = character.HumanoidRootPart
					attachment.Position = createVector(0, 2, 0)
					local particleEmitter = Instance.new("ParticleEmitter")
					particleEmitter.Rate = data2.Particles.rate or 5
					particleEmitter.Lifetime = data2.Particles.lifetime or NumberRange.new(1, 2)
					particleEmitter.Speed = data2.Particles.speed or NumberRange.new(2, 4)
					particleEmitter.Color = data2.Particles.color or ColorSequence.new(Color3.new(1, 1, 1))
					particleEmitter.Size = data2.Particles.size or NumberSequence.new(1)
					particleEmitter.Texture = data2.Particles.texture or "rbxasset://textures/particles/sparkles_main.dds"
					particleEmitter.EmissionDirection = data2.Particles.emissionDirection or Enum.NormalId.Top
					particleEmitter.SpreadAngle = data2.Particles.spreadAngle or Vector2.new(45, 45)
					particleEmitter.Parent = attachment
					table.insert(v15, attachment)
				end

				if data2.MovementAnimation and data2.MovementAnimation.type ~= "none" then
					local movementAnimation = StickerAnimations.MovementAnimations[data2.MovementAnimation.type]
					local v16 = movementAnimation and movementAnimation(frame, data2.MovementAnimation)

					if v16 then
						table.insert(v14, v16)
					end
				end
			end

			task.wait(3)

			for _, connection in ipairs(v14) do
				if connection and connection.Connected then
					connection:Disconnect()
				end
			end

			if data2 and data2.ExitAnimation then
				local exitAnimation = StickerAnimations.ExitAnimations[data2.ExitAnimation.type]

				if exitAnimation then
					exitAnimation(frame, uIScale, data2.ExitAnimation, function()
						for _, v16 in ipairs(v15) do
							v16:Destroy()
						end

						clone:Destroy()
					end)
				else
					spr.target(uIScale, 1, 2, {
						Scale = 0
					})
					task.wait(WAIT_INTERVAL)

					for _, v16 in ipairs(v15) do
						v16:Destroy()
					end

					clone:Destroy()
				end
			else
				spr.target(uIScale, 1, 2, {
					Scale = 0
				})
				task.wait(WAIT_INTERVAL)

				for _, v16 in ipairs(v15) do
					v16:Destroy()
				end

				clone:Destroy()
			end
		end
	end)
end

return StickerController