local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage2:WaitForChild("SharedUtils"):WaitForChild("InputService"))
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local CircleSkillCheckHandler = require(ReplicatedStorage.Modules.Gameplay.CircleSkillCheckHandler)
local TreadmillTapSkillCheck = require(ReplicatedStorage.Modules.Gameplay.TreadmillTapSkillCheck)
local DebuffConfig = require(ReplicatedStorage.Modules.Gameplay.DebuffConfig)
local CooldownAcceleration = require(ReplicatedStorage.Modules.Gameplay.CooldownAcceleration)
local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local ShieldSourceIcon = require(ReplicatedStorage.SharedUtils.ShieldSourceIcon)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true)
local v = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v2 = { "HeartShield", "ShieldHeart", "Glow" }
local CharacterStatsController = {}

function CharacterStatsController.init() end

function CharacterStatsController.setupAll()
	local gui = GameContext.Gui
	local player = GameContext.Player

	local function chain(child, ...)
		for _, childName in ipairs({ ... }) do
			child = child:WaitForChild(childName)
		end

		return child
	end

	local itemMessage = gui:WaitForChild("ItemMessage")
	local bottomLeftCorner = gui:WaitForChild("Menu"):WaitForChild("BottomLeftCorner")
	local v3 = chain(bottomLeftCorner, "Trinkets", "TrinketSlot1")
	local v4 = chain(bottomLeftCorner, "Trinkets", "TrinketSlot2")
	local v5 = chain(bottomLeftCorner, "Status", "Bottom", "StaminaBin")
	local v6 = chain(v5, "StaminaFrameBG", "StaminaFrame")
	local v7 = chain(v5, "InfoBin", "PointBin", "PointFrame")
	local v8 = chain(v5, "InfoBin", "HealthBin")
	local parent2 = chain(v8, "Bar", "Content")
	local viewStat = v8:WaitForChild("ViewStat")
	local inputHint = viewStat:FindFirstChild("InputHint")

	if inputHint then
		inputHint:SetAttribute("Action", "OpenStats")
		CollectionService:AddTag(inputHint, "InputHintUI")
	end

	local position = itemMessage.Position

	local function updateStaminaGui(stats)
		local currentStamina = stats:WaitForChild("CurrentStamina")
		local stamina = stats:WaitForChild("Stamina")
		local v10 = not (stamina.Value > 0) and 0 or currentStamina.Value / stamina.Value
		v6.Message.Text = "Stamina: " .. math.round(currentStamina.Value) .. "/" .. stamina.Value
		local character = player.Character
		local staminaFatigued = character and character:GetAttribute("StaminaFatigued") or false
		local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

		if staminaFatigued then
			TweenService:Create(v6.CurrentAmount, tweenInfo2, {
				Size = UDim2.new(math.clamp(v10, 0, 1), 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			}):Play()
		else
			TweenService:Create(v6.CurrentAmount, tweenInfo2, {
				Size = UDim2.new(math.clamp(v10, 0, 1), 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(150, 150, 150)
			}):Play()
		end
	end

	local function growHeartBar(p)
		local v10 = math.min(p, 8)
		local layoutOrder = 0
		local v12 = 0
		local v13 = nil

		for _, frame in ipairs(parent2:GetChildren()) do
			local v14 = frame:IsA("Frame") and tonumber(frame.Name:match("%d+"))

			if not v14 then
				continue
			end

			layoutOrder = math.max(layoutOrder, frame.LayoutOrder)

			if not (v12 < v14) then
				continue
			end

			v13 = frame
			v12 = v14
		end

		if not v13 then
			return
		end

		for i = v12 + 1, v10 do
			local clone = v13:Clone()
			clone.Name = "Heart" .. i
			layoutOrder += 1
			clone.LayoutOrder = layoutOrder
			clone.Visible = false
			clone:SetAttribute("Active", nil)
			clone:SetAttribute("Pulsing", nil)

			for _, childName in ipairs(v2) do
				local child = clone:FindFirstChild(childName, true)

				while child do
					child:Destroy()
					child = clone:FindFirstChild(childName, true)
				end
			end

			local imageLabel = clone:FindFirstChild("ImageLabel")

			if imageLabel then
				imageLabel.ImageTransparency = 1
				imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				imageLabel.Size = UDim2.fromScale(1, 1)
			end

			local pulse = clone:FindFirstChild("Pulse")

			if pulse then
				pulse.Visible = false
			end

			clone.Parent = parent2
		end
	end

	local function updateHealthGui(stats, humanoid)
		local tweenInfo2 = TweenInfo.new(1.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
		local tweenInfo4 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		local tweenInfo5 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		local tweenInfo6 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local fieldOfView = workspace.CurrentCamera.FieldOfView
		local uDim = UDim2.fromScale(1, 1)
		local uDim2 = UDim2.fromScale(1.3, 1.3)
		local v10 = true

		local function HurtTween(p)
			task.spawn(function()
				p.ImageLabel.Image = "rbxassetid://16790556185"
				p.ImageLabel.Size = uDim
				TweenService:Create(p.ImageLabel, tweenInfo3, {
					Size = uDim2
				}):Play()
				TweenService:Create(p.ImageLabel, tweenInfo2, {
					ImageTransparency = 1
				}):Play()

				if not v10 and gui.Damage.Playing ~= true then
					Audio:PlayOne("Sounds.UI.Combat.Damage")
				end
			end)
			workspace.CurrentCamera.FieldOfView = fieldOfView * 0.9
			TweenService:Create(workspace.CurrentCamera, tweenInfo6, {
				FieldOfView = fieldOfView
			}):Play()
		end

		local function HealTween(p)
			p.ImageLabel.Image = "rbxassetid://16790556042"
			TweenService:Create(p.ImageLabel, tweenInfo5, {
				ImageTransparency = 0
			}):Play()
			p.ImageLabel.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(p.ImageLabel, tweenInfo4, {
				Size = uDim
			}):Play()

			if not v10 and gui.Heal.Playing ~= true then
				Audio:PlayOne("Sounds.UI.Combat.Heal")
			end
		end

		local v11

		if humanoid == nil then
			v11 = false
		else
			v11 = stats:WaitForChild("MainCharacter").Value == true
		end

		local shieldHearts = humanoid and humanoid.Parent and humanoid.Parent:GetAttribute("ShieldHearts")

		if type(shieldHearts) == "number" and shieldHearts > 0 then
			growHeartBar(humanoid.MaxHealth + (v11 and 1 or 0) + 1)
		end

		local frames = {}

		for _, frame in pairs(parent2:GetChildren()) do
			if not frame:IsA("Frame") then
				continue
			end

			local v12 = tonumber(frame.Name:match("%d"))

			if not v12 then
				continue
			end

			frames[v12] = frame

			if v[frame] then
				continue
			end

			v[frame] = {}
			frame:SetAttribute("Active", humanoid and v12 <= humanoid.MaxHealth)
			frame:SetAttribute("Pulsing", false)
			local pulse = frame.Pulse
			local v13 = nil
			local v14 = frame
			v[frame].ActiveListener = frame:GetAttributeChangedSignal("Active"):Connect(function()
				if v14:GetAttribute("Active") == true then
					HealTween(v14)
				else
					HurtTween(v14)
				end
			end)
			local v15 = frame
			v[frame].PulsingListener = frame:GetAttributeChangedSignal("Pulsing"):Connect(function()
				if v13 then
					v13:Cancel()
				end

				local pulsing = v15:GetAttribute("Pulsing")
				pulse.Visible = pulsing == true

				if pulsing then
					pulse.Size = uDim
					v13 = TweenService:Create(pulse, tweenInfo, {
						Size = uDim2
					})
					v13:Play()
				end
			end)
		end

		local function ensureHeartShield(parent)
			local heartShield = parent:FindFirstChild("HeartShield")

			if heartShield then
				return heartShield
			end

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "HeartShield"
			imageLabel.BackgroundTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(1, 0)
			imageLabel.Position = UDim2.fromScale(1.05, -0.1)
			imageLabel.Size = UDim2.fromScale(0.55, 0.55)
			local imageLabel2 = parent:FindFirstChild("ImageLabel")
			imageLabel.ZIndex = (imageLabel2 and imageLabel2.ZIndex or 1) + 3
			imageLabel.Visible = false
			imageLabel.Parent = parent
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "HeartShieldCount"
			textLabel.BackgroundTransparency = 1
			textLabel.AnchorPoint = Vector2.new(1, 1)
			textLabel.Position = UDim2.fromScale(1.1, 1.1)
			textLabel.Size = UDim2.fromScale(0.7, 0.7)
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextStrokeTransparency = 0.3
			textLabel.ZIndex = imageLabel.ZIndex + 1
			textLabel.Visible = false
			textLabel.Parent = imageLabel
			return imageLabel
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function paintHeartShield(parent, p2, p3, image)
			local heartShield = ensureHeartShield(parent)
			heartShield.Visible = p2 and image ~= nil

			if image then
				heartShield.Image = image
			end

			local heartShieldCount = heartShield:FindFirstChild("HeartShieldCount")

			if heartShieldCount then
				heartShieldCount.Visible = heartShield.Visible and p3 > 1
				heartShieldCount.Text = heartShield.Visible and tostring(p3) or ""
			end
		end

		local color = Color3.fromRGB(96, 140, 210)
		local color2 = Color3.fromRGB(180, 210, 255)
		local tweenInfo7 = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tweenInfo8 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 4)
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2124, 1),
			NumberSequenceKeypoint.new(0.213548, 0),
			NumberSequenceKeypoint.new(0.334099, 0),
			NumberSequenceKeypoint.new(0.336395, 1),
			NumberSequenceKeypoint.new(0.402985, 1),
			NumberSequenceKeypoint.new(0.405281, 0),
			NumberSequenceKeypoint.new(0.461538, 0),
			NumberSequenceKeypoint.new(0.464983, 1),
			NumberSequenceKeypoint.new(1, 1)
		})

		local function ensureShieldHeart(imageLabel)
			local shieldHeart = imageLabel:FindFirstChild("ShieldHeart")

			if shieldHeart then
				return shieldHeart
			end

			local imageLabel2 = Instance.new("ImageLabel")
			imageLabel2.Name = "ShieldHeart"
			imageLabel2.BackgroundTransparency = 1
			imageLabel2.Image = "rbxassetid://121908174722814"
			imageLabel2.ImageColor3 = color2
			imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel2.Size = UDim2.fromScale(1, 1)
			imageLabel2.ZIndex = imageLabel.ZIndex + 1
			imageLabel2.Visible = false
			imageLabel2.Parent = imageLabel
			local clone = imageLabel2:Clone()
			clone.Name = "Shine"
			clone.Image = "rbxassetid://77637387117626"
			clone.ZIndex = imageLabel2.ZIndex + 1
			clone.Visible = true
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Transparency = numberSequence
			uIGradient.Rotation = 10
			uIGradient.Offset = Vector2.new(-0.5, 0)
			uIGradient.Parent = clone
			clone.Parent = imageLabel2
			TweenService:Create(uIGradient, tweenInfo8, {
				Offset = Vector2.new(1, 0)
			}):Play()
			local clone2 = imageLabel2:Clone()
			clone2:ClearAllChildren()
			clone2.Name = "Glow"
			clone2.Image = "rbxassetid://96980091742348"
			clone2.ImageColor3 = Color3.fromRGB(255, 255, 255)
			clone2.ZIndex = imageLabel2.ZIndex - 1
			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 2
			uIScale.Parent = clone2
			clone2.Parent = imageLabel
			imageLabel2:GetPropertyChangedSignal("Visible"):Connect(function()
				clone2.Visible = imageLabel2.Visible
			end)
			imageLabel2:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
				clone2.ImageTransparency = imageLabel2.ImageTransparency
			end)
			TweenService:Create(uIScale, tweenInfo7, {
				Scale = 4
			}):Play()
			return imageLabel2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setShieldHeartTransparency(shieldHeart, imageTransparency)
			shieldHeart.ImageTransparency = imageTransparency
			local shine = shieldHeart:FindFirstChild("Shine")

			if shine then
				shine.ImageTransparency = imageTransparency
			end
		end

		local function paintGuardHeart(instance, visible)
			local imageLabel = instance:FindFirstChild("ImageLabel")

			if not imageLabel then
				instance.Visible = visible
				return
			end

			local shieldHeart = ensureShieldHeart(imageLabel)

			if visible then
				instance.Visible = true
				imageLabel.Image = "rbxassetid://16790556042"
				imageLabel.ImageColor3 = color
				imageLabel.ImageTransparency = 1
				shieldHeart.Visible = true
				setShieldHeartTransparency(shieldHeart, 0) -- equivalent call inferred; original call site unknown

				if not object[instance] then
					object[instance] = true
					imageLabel.Size = UDim2.new(0, 0, 0, 0)
					TweenService:Create(imageLabel, tweenInfo3, {
						Size = uDim
					}):Play()
				end
			elseif object[instance] then
				object[instance] = nil
				local tween = TweenService:Create(shieldHeart, tweenInfo5, {
					ImageTransparency = 1
				})
				local shine = shieldHeart:FindFirstChild("Shine")

				if shine then
					TweenService:Create(shine, tweenInfo5, {
						ImageTransparency = 1
					}):Play()
				end

				tween.Completed:Connect(function()
					if not object[instance] then
						instance.Visible = false
						shieldHeart.Visible = false
						imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					end
				end)
				tween:Play()
			else
				instance.Visible = false
				shieldHeart.Visible = false
				imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			end
		end

		local function UpdateHealth(p)
			frames[1].HeartIchor.Visible = p == true
			local v12 = humanoid.Health + (p and 1 or 0)
			local v13 = humanoid.MaxHealth + (p and 1 or 0)
			local parent = humanoid.Parent
			local shieldHearts2 = parent and parent:GetAttribute("ShieldHearts")
			local v14

			if type(shieldHearts2) == "number" then
				v14 = shieldHearts2 > 0
			else
				v14 = false
			end

			local image = v14 and ShieldSourceIcon.Get(parent) or nil
			local parent3 = frames[v13 + 1]

			for k, v17 in pairs(frames) do
				if p then
					k = k - 1 or k
				end

				if v17 == parent3 then
					continue
				end

				local imageLabel = v17:FindFirstChild("ImageLabel")

				if imageLabel and object[v17] then
					object[v17] = nil
					imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					imageLabel.ImageTransparency = 0
					local shieldHeart = imageLabel:FindFirstChild("ShieldHeart")

					if shieldHeart then
						shieldHeart.Visible = false
					end
				end

				v17.Visible = k <= humanoid.MaxHealth
			end

			for i = 1, v13 do
				local parent4 = frames[i]

				if not parent4 then
					continue
				end

				parent4:SetAttribute("Active", i <= v12)
				parent4:SetAttribute("Pulsing", i == v12)
				paintHeartShield(parent4, v14 and not parent3 and i == v12, shieldHearts2 or 0, image) -- equivalent call inferred; original call site unknown
			end

			if parent3 then
				paintGuardHeart(parent3, v14)
				paintHeartShield(parent3, v14, shieldHearts2 or 0, image) -- equivalent call inferred; original call site unknown
			end
		end

		if humanoid then
			if not humanoid:GetAttribute("LastHP") then
				humanoid:SetAttribute("LastHP", humanoid.Health)
			end

			UpdateHealth(v11)
			humanoid:SetAttribute("LastHP", humanoid.Health)
			v10 = false
		end
	end

	local v10 = {}
	GameContext.updateStaminaGui = updateStaminaGui
	GameContext.updateHealthGui = updateHealthGui

	function GameContext.setupStats()
		local character = GameContext.Character or player.Character or player.CharacterAdded:Wait()
		local playerStat = workspace.Info.PlayerStats[player.Name]
		playerStat:WaitForChild("Ichor")
		local survivalPoints = playerStat:WaitForChild("SurvivalPoints")
		local position2 = v7.Position
		local margin = gui.CurrencyFrames.HolidayFrame.Margin
		local uDim = UDim2.fromScale(-1, 0)
		local child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
		local HolidayEventConfig = require(game.ReplicatedStorage.SharedData.HolidayEventConfig)
		local child2 = nil

		if HolidayEventConfig.ENABLED then
			local seasonal = child:FindFirstChild("Seasonal")

			if not seasonal then
				warn("[GMM] Seasonal folder not found - waiting for replication")
				seasonal = child:WaitForChild("Seasonal", 10)
			end

			if seasonal then
				local currencyKey = HolidayEventConfig.CurrencyKey or HolidayEventConfig.CURRENT_EVENT
				local child3

				if HolidayEventConfig.HOLIDAY_KEY then
					child3 = seasonal:FindFirstChild(HolidayEventConfig.HOLIDAY_KEY)

					if not child3 then
						warn(
							"[GMM] Holiday folder not found:",
							HolidayEventConfig.HOLIDAY_KEY,
							"- waiting for replication"
						)
						child3 = seasonal:WaitForChild(HolidayEventConfig.HOLIDAY_KEY, 10)
					end
				end

				if child3 then
					child2 = child3:FindFirstChild(currencyKey)

					if not child2 then
						warn("[GMM] Holiday currency not found:", currencyKey, "- waiting for replication")
						child2 = child3:WaitForChild(currencyKey, 10)
					end
				end
			end

			if not child2 then
				warn("[GMM] Failed to load holiday currency after waiting - feature disabled")
			end
		end

		pcall(function()
			local HolidayCurrencyModule = require(game.ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("HolidayCurrencyModule"))
			local uIDisplayInfo = HolidayCurrencyModule.GetUIDisplayInfo()

			if uIDisplayInfo.isActive and uIDisplayInfo.showHUDIndicator then
				local matchBonus = margin:FindFirstChild("MatchBonus")

				if matchBonus then
					matchBonus.Visible = true
				end
			else
				local matchBonus = margin:FindFirstChild("MatchBonus")

				if matchBonus then
					matchBonus.Visible = false
				end
			end
		end)
		v6.Visible = true
		gui.Slot1.Visible = true
		gui.Slot2.Visible = true
		gui.Slot3.Visible = true
		gui.Slot4.Visible = false
		gui.Ability1.Visible = false
		gui.Ability1.CooldownFrame.Visible = false
		gui.Ability1.CooldownText.Visible = false
		gui.Ability1.TapeLabel.Visible = false
		gui.Ability1.AbilityCost.Visible = false
		v3.Visible = true
		v4.Visible = true
		v7.Visible = true
		margin.Visible = HolidayEventConfig.ENABLED and HolidayEventConfig.UIVisible
		v8.Visible = true
		v6.Parent.Visible = true
		local radio = workspace.Elevators:WaitForChild("Elevator"):WaitForChild("DandyStore"):WaitForChild("Radio")
		local musicToggle = child:FindFirstChild("MusicToggle")

		if musicToggle and musicToggle.Value == true then
			for _, sound in pairs(radio:GetDescendants()) do
				if sound:IsA("Sound") then
					sound.Volume = 0
				end
			end
		end

		local value = survivalPoints.Value
		v7.TextLabel.Text = math.round(survivalPoints.Value)
		local uDim2 = UDim2.new(-1, 0, uDim.Y.Scale, 0)
		local uDim3 = UDim2.new(0, 0, uDim.Y.Scale, 0)
		local value2

		if HolidayEventConfig.ENABLED and child2 then
			value2 = child2.Value
			margin.TextLabel.Text = math.round(child2.Value)
		else
			value2 = nil
		end

		if HolidayEventConfig.ENABLED and child2 then
			child2.Changed:Connect(function(p)
				local humanoid = character and character:FindFirstChild("Humanoid")

				if humanoid and humanoid.Health > 0 then
					local v11 = math.round(p - value2)
					local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
					local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
					value2 = p
					gui.HolidayEarnedFrame.TextLabel.Text = "+" .. v11
					margin.Parent.Visible = true
					margin.Position = uDim2
					gui.HolidayEarnedFrame.Position = UDim2.new(0.451, 0, 0.543, 0)
					gui.HolidayEarnedFrame.Size = UDim2.new(0.042, 0, 0.035, 0)
					gui.HolidayEarnedFrame.Visible = true
					TweenService:Create(gui.HolidayEarnedFrame, tweenInfo2, {
						Position = UDim2.new(0.451, 0, 0.543, 0),
						Size = UDim2.new(0.098, 0, 0.082, 0)
					}):Play()
					TweenService:Create(margin, tweenInfo3, {
						Position = uDim3
					}):Play()
					Audio:PlayOne("Sounds.UI.Money.MoneyPopup")
					task.wait(0.75)
					local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
					local uDim4 = UDim2.fromScale(
						margin.AbsolutePosition.X / margin.Parent.Parent.Parent.AbsoluteSize.X,
						margin.AbsolutePosition.Y / margin.Parent.Parent.Parent.AbsoluteSize.Y
					)
					local tween = TweenService:Create(gui.HolidayEarnedFrame, tweenInfo4, {
						Position = uDim4
					})
					tween:Play()
					tween.Completed:Wait()
					gui.HolidayEarnedFrame.Visible = false

					if v11 > 0 then
						Audio:PlayOne("Sounds.UI.Money.SPCollected")
						local currencyPickupSound = HolidayEventConfig.GetCurrencyPickupSound()

						if currencyPickupSound then
							Audio:PlayOne(currencyPickupSound, {
								PlaybackSpeed = math.random(92, 108) / 100
							})
						end
					else
						Audio:PlayOne("Sounds.UI.Money.MoneySpent")
					end

					margin.ParticleEmitter.Enabled = true
					margin.Position = uDim3 + UDim2.new(0, 0, 0, 0)
					local tween2 = TweenService:Create(
						margin,
						TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false),
						{
							Position = uDim3
						}
					)
					tween2:Play()
					margin.TextLabel.Text = math.round(child2.Value)
					task.wait(0.15)
					margin.ParticleEmitter.Enabled = false
					tween2.Completed:Wait()
					local tween3 = TweenService:Create(
						margin,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
						{
							Position = uDim2
						}
					)
					tween3:Play()
					tween3.Completed:Wait()
					margin.Parent.Visible = false
				end
			end)
		end

		survivalPoints.Changed:Connect(function(_)
			v7.TextLabel.Text = math.round(survivalPoints.Value)
			TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
			v7.Position = position2 + UDim2.new(0, 0, -0.25, 0)
			TweenService:Create(v7, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false), {
				Position = position2
			}):Play()

			if value < survivalPoints.Value then
				Audio:PlayOne("Sounds.UI.Money.SPCollected")
			else
				Audio:PlayOne("Sounds.UI.Money.MoneySpent")
			end

			value = survivalPoints.Value
		end)
		local humanoid = character:WaitForChild("Humanoid", 5)

		if not humanoid then
			return
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

		if not humanoidRootPart then
			return
		end

		character.DescendantAdded:Connect(function(descendant)
			if (descendant:IsA("BodyGyro") or descendant:IsA("BodyVelocity")) and descendant.Name ~= "SpeedController" then
				descendant:Destroy()
				ReplicatedStorage.Events.AntiCheatTrigger:FireServer(999, "Instant")
			end
		end)

		for _, part in character:GetDescendants() do
			if not part:IsA("BasePart") or CollectionService:HasTag(part, "IgnoreChangingCollision") then
				continue
			end

			local v11 = part
			part:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
				if v11.CollisionGroup ~= "Player" then
					v11.CollisionGroup = "Player"
				end
			end)
		end

		humanoidRootPart:GetPropertyChangedSignal("CanCollide"):Connect(function()
			if humanoidRootPart.CanCollide == false then
				humanoidRootPart.CanCollide = true
				ReplicatedStorage.Events.AntiCheatTrigger:FireServer(5)
			end
		end)
		humanoidRootPart:GetPropertyChangedSignal("CanQuery"):Connect(function()
			if humanoidRootPart.CanQuery == false then
				humanoidRootPart.CanQuery = true
				ReplicatedStorage.Events.AntiCheatTrigger:FireServer(5)
			end
		end)
		humanoidRootPart:GetPropertyChangedSignal("CanTouch"):Connect(function()
			if humanoidRootPart.CanTouch == false then
				humanoidRootPart.CanTouch = true
				ReplicatedStorage.Events.AntiCheatTrigger:FireServer(5)
			end
		end)
		local stats = character:WaitForChild("Stats", 5)

		if not stats then
			return
		end

		updateStaminaGui(stats)
		local decoding = character:WaitForChild("Decoding", 5)

		if not decoding then
			return
		end

		GameContext.decodechanged = decoding:GetPropertyChangedSignal("Value"):Connect(function()
			if decoding.Value == nil then
				GameContext.currentgenerator = nil
				GameContext.skillchecking = false

				if GameContext.renderstep then
					GameContext.renderstep:Disconnect()
				end

				gui.Menu.StopGenerator.Visible = false
				CircleSkillCheckHandler.CleanUp(player)
				TreadmillTapSkillCheck.CleanUp()

				if GameContext.hideAllSkillCheckUI then
					GameContext.hideAllSkillCheckUI()
				end

				if GameContext.updateSkillCheckPromptText then
					GameContext.updateSkillCheckPromptText("default")
				end

				local viewStats = UserInputService.TouchEnabled and gui:FindFirstChild("ViewStats")

				if viewStats then
					viewStats.Visible = true
				end
			else
				local value3 = decoding.Value

				if value3 and value3:GetAttribute("MinigameType") == "Barnaby" then
					gui.Menu.StopGenerator.Visible = false
				else
					gui.Menu.StopGenerator.Visible = true
				end

				local viewStats = UserInputService.TouchEnabled and gui:FindFirstChild("ViewStats")

				if viewStats then
					viewStats.Visible = false
				end
			end
		end)
		local trinkets = character:WaitForChild("Trinkets", 5)

		if not trinkets then
			return
		end

		local trinket1 = trinkets:WaitForChild("Trinket1")
		local trinket2 = trinkets:WaitForChild("Trinket2")
		local v11 = {
			"Health",
			"CurrentStamina",
			"Stamina",
			"MainCharacter",
			"IsSprinting",
			"Sprinting",
			"HoldingSprint",
			"OriginalStamina",
			"Skin",
			"InElevator"
		}
		local v12 = {
			WalkSpeed = 1,
			RunSpeed = 2,
			SpeedModifier = 3,
			RunSpeedModifier = 4,
			StaminaModifier = 5,
			StaminaRegenModifier = 6,
			DecodeSpeed = 7,
			DecodeSpeedModifier = 8,
			SkillCheckChance = 9,
			SkillCheckValue = 10,
			BoundarySize = 11,
			BoundarySizeModifier = 12,
			SkillCheckSpeed = 13,
			SkillCheckSpeedModifier = 14,
			Stealth = 15,
			StealthModifier = 16,
			BlackoutChance = 17,
			IchorLeakChance = 18,
			IcedOverChance = 19,
			SpringFeverChance = 20,
			HauntedGalaChance = 21
		}
		local v13 = {
			DecodeSpeed = "ExtractionSpeed",
			DecodeSpeedModifier = "ExtractionSpeedMultiplier",
			StaminaModifier = "StaminaMultiplier",
			StaminaRegenModifier = "StaminaRegenMultiplier",
			SpeedModifier = "WalkSpeedMultiplier",
			RunSpeedModifier = "RunSpeedMultiplier",
			StealthModifier = "StealthMultiplier",
			BoundarySize = "SkillCheckSize",
			BoundarySizeModifier = "SkillCheckSizeMultiplier",
			SkillCheckSpeed = "SkillCheckSpeed",
			SkillCheckSpeedModifier = "SkillCheckSpeedMultiplier"
		}
		local v14 = {
			SpeedModifier = "PosOrNeg",
			RunSpeedModifier = "PosOrNeg",
			DecodeSpeedModifier = "PosOrNeg",
			StaminaModifier = "PosOrNeg",
			StaminaRegenModifier = "PosOrNeg",
			StealthModifier = "PosOrNeg",
			BoundarySizeModifier = "PosOrNeg",
			SkillCheckSpeed = "Integer",
			SkillCheckSpeedModifier = "PosOrNeg",
			SkillCheckChance = "Percent",
			WalkSpeed = "Format",
			RunSpeed = "Format",
			DecodeSpeed = "Format",
			Stealth = "Format",
			BoundarySize = "Format",
			BlackoutChance = "Percent",
			IchorLeakChance = "Percent",
			IcedOverChance = "Percent",
			SpringFeverChance = "Percent",
			HauntedGalaChance = "Percent",
			SkillCheckValue = "Format"
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fixNegativeZero(p)
			if math.abs(p) < 1e-7 then
				return 0
			end

			return p
		end

		local function createStat(numberValue)
			if table.find(v11, numberValue.Name) then
				return
			end

			local clone = gui.StatsFrame.ScrollingFrame.Template:Clone()
			clone.Parent = gui.StatsFrame.ScrollingFrame
			clone.Name = numberValue.Name
			clone.Stat.Text = tostring(numberValue.Name .. ":")

			if v13[clone.Name] then
				clone.Stat.Text = tostring(v13[clone.Name] .. ":")
			end

			if v12[clone.Name] then
				clone.LayoutOrder = v12[clone.Name]
			end

			local diedConnection = nil
			local changedConnection = nil
			local destroyingConnection = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function disconnectAll()
				if changedConnection then
					changedConnection:Disconnect()
					changedConnection = nil
				end

				if diedConnection then
					diedConnection:Disconnect()
					diedConnection = nil
				end

				if destroyingConnection then
					destroyingConnection:Disconnect()
					destroyingConnection = nil
				end
			end

			local function updateDisplay()
				local statValue = clone:FindFirstChild("StatValue")

				if statValue then
					if v14[clone.Name] and numberValue:IsA("NumberValue") then
						if v14[clone.Name] == "PosOrNeg" then
							local v16 = fixNegativeZero((numberValue.Value - 1) * 100) -- equivalent call inferred; original call site unknown
							statValue.Text = string.format("%.1f", v16) .. "%"
						elseif v14[clone.Name] == "Percent" then
							statValue.Text = string.format("%.1f", numberValue.Value) .. "%"
						elseif v14[clone.Name] == "Format" then
							statValue.Text = string.format("%.2f", numberValue.Value)
						elseif v14[clone.Name] == "Integer" then
							statValue.Text = tostring((math.floor(numberValue.Value)))
						end
					else
						statValue.Text = tostring(numberValue.Value)
					end
				else
					disconnectAll() -- equivalent call inferred; original call site unknown
				end
			end

			updateDisplay()

			if not table.find(v11, clone.Name) then
				clone.Visible = true
			end

			diedConnection = humanoid.Died:Connect(disconnectAll)
			destroyingConnection = clone.Destroying:Connect(disconnectAll)
			changedConnection = numberValue.Changed:Connect(updateDisplay)
		end

		for _, frame in pairs(gui.StatsFrame.ScrollingFrame:GetChildren()) do
			if frame:IsA("Frame") and frame.Name ~= "Template" then
				frame:Destroy()
			end
		end

		for _, child3 in pairs(stats:GetChildren()) do
			local v15 = child3
			local success, result = pcall(function()
				createStat(v15)
			end)

			if not success then
				warn("Failed to update stat, " .. result)
			end
		end

		createStat(workspace.Info.BlackoutChance)
		createStat(workspace.Info.IchorLeakChance)

		if HolidayEventConfig.ENABLED and HolidayEventConfig.ContentFlag == "Christmas" and workspace.Info:FindFirstChild("IcedOverChance") then
			createStat(workspace.Info.IcedOverChance)
			local icedOverChance = gui.StatsFrame.ScrollingFrame:FindFirstChild("IcedOverChance")

			if icedOverChance then
				local color = Color3.fromRGB(100, 180, 255)

				if icedOverChance:FindFirstChild("Stat") then
					icedOverChance.Stat.TextColor3 = color
				end

				if icedOverChance:FindFirstChild("StatValue") then
					icedOverChance.StatValue.TextColor3 = color
				end
			end
		end

		if HolidayEventConfig.ENABLED and (HolidayEventConfig.ContentFlag == "Easter" or HolidayEventConfig.CURRENT_EVENT and HolidayEventConfig.CURRENT_EVENT:match("Easter")) and workspace.Info:FindFirstChild("SpringFeverChance") then
			createStat(workspace.Info.SpringFeverChance)
			local springFeverChance = gui.StatsFrame.ScrollingFrame:FindFirstChild("SpringFeverChance")

			if springFeverChance then
				local color = Color3.fromRGB(255, 160, 210)

				if springFeverChance:FindFirstChild("Stat") then
					springFeverChance.Stat.TextColor3 = color
				end

				if springFeverChance:FindFirstChild("StatValue") then
					springFeverChance.StatValue.TextColor3 = color
				end
			end
		end

		if HolidayEventConfig.ENABLED and (HolidayEventConfig.ContentFlag == "Halloween" or HolidayEventConfig.CURRENT_EVENT and HolidayEventConfig.CURRENT_EVENT:match("Halloween")) and workspace.Info:FindFirstChild("HauntedGalaChance") then
			createStat(workspace.Info.HauntedGalaChance)
			local hauntedGalaChance = gui.StatsFrame.ScrollingFrame:FindFirstChild("HauntedGalaChance")

			if hauntedGalaChance then
				local color = Color3.fromRGB(255, 150, 60)

				if hauntedGalaChance:FindFirstChild("Stat") then
					hauntedGalaChance.Stat.TextColor3 = color
				end

				if hauntedGalaChance:FindFirstChild("StatValue") then
					hauntedGalaChance.StatValue.TextColor3 = color
				end
			end
		end

		local uIScale = gui.StatsFrame:FindFirstChild("UIScale")

		if uIScale then
			uIScale:Destroy()
		end

		local scrollingFrame = gui.StatsFrame.ScrollingFrame
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
		scrollingFrame.ScrollingEnabled = true
		scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		scrollingFrame.ScrollBarThickness = 6
		local template = scrollingFrame:FindFirstChild("Template")

		if template then
			template.Size = UDim2.new(1, 0, 0.06, 0)
			local stat = template:FindFirstChild("Stat")
			local statValue = template:FindFirstChild("StatValue")

			if stat then
				stat.TextScaled = true
				stat.RichText = true
			end

			if statValue then
				statValue.TextScaled = true
				statValue.RichText = true
			end
		end

		for _, frame in pairs(scrollingFrame:GetChildren()) do
			if not (frame:IsA("Frame") and frame.Name ~= "Template") then
				continue
			end

			local stat = frame:FindFirstChild("Stat")
			local statValue = frame:FindFirstChild("StatValue")

			if stat then
				stat.TextScaled = true
				stat.RichText = true
			end

			if not statValue then
				continue
			end

			statValue.TextScaled = true
			statValue.RichText = true
		end

		local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout") or scrollingFrame:FindFirstChildOfClass("UIGridLayout")

		if uIListLayout then
			if uIListLayout:IsA("UIListLayout") then
				uIListLayout.FillDirection = Enum.FillDirection.Vertical
				uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				uIListLayout.Wraps = false
				uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
				uIListLayout.Padding = UDim.new(0, 0)
				uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.None
				uIListLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
			end

			local function updateStatsCanvasSize()
				local count = 0

				for _, frame in pairs(scrollingFrame:GetChildren()) do
					if frame:IsA("Frame") and frame.Visible and frame.Name ~= "Template" then
						count += 1
					end
				end

				local v15 = scrollingFrame.AbsoluteSize.Y * 0.06
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * v15)
			end

			scrollingFrame.ChildAdded:Connect(updateStatsCanvasSize)
			scrollingFrame.ChildRemoved:Connect(updateStatsCanvasSize)
			updateStatsCanvasSize()
		end

		local modifiersFrame = gui:FindFirstChild("ModifiersFrame")

		if modifiersFrame then
			modifiersFrame:Destroy()
		end

		local v15 = {
			SpeedModifier = "WalkSpd×",
			RunSpeedModifier = "RunSpd×",
			StaminaModifier = "Stamina×",
			StaminaRegenModifier = "StamRegen×",
			BoundarySize = "SkillSize",
			BoundarySizeModifier = "SkillSize×",
			DecodeSpeedModifier = "ExtractSpd×",
			StealthModifier = "Stealth×"
		}
		local v16 = {
			WalkSpeed = "WalkSpd",
			RunSpeed = "RunSpd",
			Stealth = "Stealth",
			BoundarySize = "SkillSize",
			SkillCheckChance = "SkillChance",
			DecodeSpeed = "ExtractSpd",
			SpeedModifier = "WalkSpd+",
			RunSpeedModifier = "RunSpd+"
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getModifierColor(p)
			if p >= 1 then
				return Color3.fromRGB(100, 200, 120)
			end

			return Color3.fromRGB(240, 100, 100)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getAdditiveColor(p)
			if p >= 0 then
				return Color3.fromRGB(120, 180, 220)
			end

			return Color3.fromRGB(220, 140, 100)
		end

		local v17 = {}
		local v18 = {
			IchorPuddle = "Ichor Puddle",
			IchorPuddle_Linger = "Ichor (Lingering)",
			Slow_1 = "Slowness I",
			Slow_2 = "Slowness II",
			Slow_3 = "Slowness III",
			Tired_1 = "Tiredness I",
			Tired_2 = "Tiredness II",
			Tired_3 = "Tiredness III",
			Confused_1 = "Confusion I",
			Confused_2 = "Confusion II",
			Confused_3 = "Confusion III",
			Illness_1 = "Illness I",
			Illness_2 = "Illness II",
			Illness_3 = "Illness III",
			TreadmillDazed = "Treadmill",
			Admin_Slow_1 = "Admin",
			Admin_Slow_2 = "Admin",
			Admin_Slow_3 = "Admin",
			Admin_Tired_1 = "Admin",
			Admin_Tired_2 = "Admin",
			Admin_Tired_3 = "Admin",
			Admin_Confused_1 = "Admin",
			Admin_Confused_2 = "Admin",
			Admin_Confused_3 = "Admin",
			Admin_Illness_1 = "Admin",
			Admin_Illness_2 = "Admin",
			Admin_Illness_3 = "Admin",
			Admin_TreadmillDazed_1 = "Admin"
		}
		local v19 = {
			GourdyTrickOrTreat = "Gourdy (Trick or Treat)",
			ToodlesLuck = "Toodles (Luck)",
			TishaTidyUp = "Tisha (Tidy Up)",
			ShellyInspiration = "Shelly (Inspiration)",
			RudieAntlerCharge = "Rudie (Antler Charge)",
			PebbleSpeak = "Pebble (Speak)",
			FlutterFloatyDash = "Flutter (Floaty Dash)",
			SoulvesterBurst = "Soulvester (Guard Burst)",
			SoulvesterEscort = "Soulvester (Guard Escort)",
			SoulvesterDash = "Soulvester (Guard Dash)",
			SoulvesterHurtBurst = "Soulvester (Hurt Burst)",
			SoulvesterGuardStance = "Soulvester (Guard Stance)",
			SoulvesterLabSpeed = "Soulvester (Lab Speed)",
			EclipseWerewolf = "Eclipse (Werewolf)",
			Gourdy_Elevator = "Gourdy (Sugar Rush)",
			Gourdy_Panic = "Gourdy (Sugar Rush)",
			LooeyHeartOfHelium = "Looey (Heart of Helium)",
			SpringFever = "Spring Fever (Energized II)",
			EmberRecharge = "Waxwell (Ember Trail)",
			FlameTrailWalk = "Waxwell (Ember Trail)",
			EmberVeil = "Waxwell (Ember Trail)",
			KindleRally = "Kindle",
			DandyCorn = "Dandy Corn"
		}

		local function getSourceDisplayName(childName)
			if v18[childName] then
				return v18[childName]
			end

			if v19[childName] then
				return v19[childName]
			end

			if string.match(childName, "^FlyteGust_") then
				return "Flyte (Gust)"
			end

			if string.match(childName, "^Gourdy_") then
				return "Gourdy (Sugar Rush)"
			end

			if string.match(childName, "^TrickOrTreat_") then
				return "Trick or Treat"
			end

			if string.match(childName, "^Admin_") then
				return "Admin"
			end

			if v17[childName] ~= nil then
				return v17[childName]
			end

			local trinketData = ReplicatedStorage:FindFirstChild("TrinketData")
			local child3 = trinketData and trinketData:FindFirstChild(childName)

			if child3 then
				local success, result = pcall(function()
					local module = require(child3)
					return module.Name
				end)

				if success and result then
					v17[childName] = result
					return result
				end
			end

			v17[childName] = childName
			return childName
		end

		local function updateModifiersInStats()
			local scrollingFrame2 = gui.StatsFrame.ScrollingFrame

			if not scrollingFrame2 then
				return
			end

			local template2 = scrollingFrame2:FindFirstChild("Template")

			if not template2 then
				return
			end

			for _, child3 in pairs(scrollingFrame2:GetChildren()) do
				if child3.Name:match("^ModEntry_") or child3.Name == "ModifiersHeader" or child3.Name == "ModifiersSeparator" then
					child3:Destroy()
				end
			end

			local v20 = {}

			for _, v22 in ipairs({
				"SpeedModifier",
				"RunSpeedModifier",
				"StaminaModifier",
				"StaminaRegenModifier",
				"BoundarySize",
				"BoundarySizeModifier",
				"DecodeSpeedModifier",
				"StealthModifier"
			}) do
				local attribute = character:GetAttribute("StatMod_" .. v22 .. "_Sources")

				if not (attribute and attribute ~= "") then
					continue
				end

				for k in string.gmatch(attribute, "[^,]+") do
					local v23 = string.gsub(k, "^%s+", "")
					local source, v25 = string.match(v23, "(.+)%(x([%d%.]+)%)")

					if not (source and v25) then
						continue
					end

					local v26 = v15[v22] or v22:gsub("Modifier", "")
					local v27 = tonumber(v25) or 1
					local v28 = (v27 - 1) * 100
					local v29 = v28 >= 0 and string.format("+%.1f%%", v28) or string.format("%.1f%%", v28)
					local v30 = {
						name = v26 .. ":",
						value = v29 .. " (" .. getSourceDisplayName(source) .. ")",
						color = 0,
						source = 0
					}
					local modifierColor = getModifierColor(v27) -- equivalent call inferred; original call site unknown
					v30.color = modifierColor
					v30.source = source
					table.insert(v20, v30)
				end
			end

			for _, v22 in ipairs({
				"WalkSpeed",
				"RunSpeed",
				"Stealth",
				"BoundarySize",
				"SkillCheckChance",
				"DecodeSpeed",
				"SpeedModifier",
				"RunSpeedModifier"
			}) do
				local attribute = character:GetAttribute("StatAdd_" .. v22 .. "_Sources")

				if not (attribute and attribute ~= "") then
					continue
				end

				for k in string.gmatch(attribute, "[^,]+") do
					local v23 = string.gsub(k, "^%s+", "")
					local source, v25, v26 = string.match(v23, "(.+)%(([%+%-])([%d%.]+)%)")

					if not (source and v26) then
						continue
					end

					local v27 = v16[v22] or v22
					local v28 = tonumber(v26) or 0

					if v25 == "-" then
						v28 = -v28
					end

					local v29

					if v22 == "SpeedModifier" or v22 == "RunSpeedModifier" then
						local v30 = v28 * 100
						v29 = v30 >= 0 and string.format("+%.0f%%", v30) or string.format("%.0f%%", v30)
					else
						v29 = v28 >= 0 and string.format("+%.2f", v28) or string.format("%.2f", v28)
					end

					local v30 = {
						name = v27 .. ":",
						value = v29 .. " (" .. getSourceDisplayName(source) .. ")",
						color = 0,
						source = 0
					}
					local additiveColor = getAdditiveColor(v28) -- equivalent call inferred; original call site unknown
					v30.color = additiveColor
					v30.source = source
					table.insert(v20, v30)
				end
			end

			local managedNames = DebuffConfig.GetManagedNames()
			local v22 = {}

			for _, managedName in ipairs(managedNames) do
				local v23 = DebuffConfig.Get(managedName)
				local v24

				if v23 then
					v24 = v23.displayName or managedName
				else
					v24 = managedName
				end

				v22[managedName] = v24
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function formatDebuffTime(p)
				if p > 100 then
					return "Active"
				end

				if p >= 60 then
					local v23 = math.floor(p / 60)
					local v24 = math.floor(p % 60)
					return string.format("%dm %ds", v23, v24)
				else
					return string.format("%.1fs", p)
				end
			end

			for _, managedName in ipairs(managedNames) do
				local attribute = character:GetAttribute("Debuff_" .. managedName .. "_EndTime")
				local attribute2 = character:GetAttribute("Debuff_" .. managedName .. "_Strength")

				if attribute and attribute2 then
					local v23 = math.max(0, attribute - workspace:GetServerTimeNow())

					if v23 > 0 then
						local v24 = v22[managedName] or managedName
						local attribute3 = character:GetAttribute("Debuff_" .. managedName .. "_Source") or managedName .. "_" .. attribute2
						local sourceDisplayName = getSourceDisplayName(attribute3)
						local v25 = {
							name = v24 .. " " .. attribute2 .. ":",
							value = 0,
							color = 0,
							source = 0,
							isDebuff = true,
							isActive = true
						}
						local v26 = formatDebuffTime(v23) -- equivalent call inferred; original call site unknown
						v25.value = v26 .. " (" .. sourceDisplayName .. ")"
						v25.color = Color3.fromRGB(255, 120, 120)
						v25.source = attribute3
						table.insert(v20, v25)
					end
				end

				local attribute3 = character:GetAttribute("Debuff_" .. managedName .. "_Pending")

				if not (attribute3 and attribute3 ~= "") then
					continue
				end

				for k in string.gmatch(attribute3, "[^,]+") do
					local v23, v24, source = string.match(k, "(%d+):([%d%.]+):(.+)")

					if not (v23 and v24) then
						continue
					end

					local v26 = tonumber(v23)
					local v27 = math.max(0, tonumber(v24) - workspace:GetServerTimeNow())

					if not (v27 > 0) then
						continue
					end

					local v28 = v22[managedName] or managedName
					local sourceDisplayName = getSourceDisplayName(source or managedName .. "_" .. v26)
					local v29 = {
						name = v28 .. " " .. v26 .. ":",
						value = 0,
						color = 0,
						source = 0,
						isDebuff = true,
						isActive = false
					}
					local v30 = formatDebuffTime(v27) -- equivalent call inferred; original call site unknown
					v29.value = v30 .. " (" .. sourceDisplayName .. ") [Queued]"
					v29.color = Color3.fromRGB(200, 100, 100)
					v29.source = source
					table.insert(v20, v29)
				end
			end

			local v23 = {}

			for _, stringValue in ipairs(character:GetChildren()) do
				if not stringValue:IsA("StringValue") then
					continue
				end

				local v24 = DebuffConfig.Get(stringValue.Name)

				if not v24 or v24.managedByManager or not DebuffConfig.ShowsInStatsPanel(stringValue.Name) then
					continue
				end

				local v25 = nil

				for k, v27 in pairs(stringValue:GetAttributes()) do
					if v27 ~= true then
						continue
					end

					v25 = k
					break
				end

				local name = (v24.displayName or stringValue.Name) .. ":"
				local v28 = not v25 and "Active" or "Active (" .. getSourceDisplayName(v25) .. ")" or "Active"
				local v29 = name .. v28

				if v23[v29] then
					continue
				end

				v23[v29] = true
				table.insert(v20, {
					name = name,
					value = v28,
					color = v24.isBuff and Color3.fromRGB(100, 200, 120) or Color3.fromRGB(255, 120, 120),
					source = v25 or stringValue.Name,
					isDebuff = not v24.isBuff,
					isActive = true
				})
			end

			local attribute = character:GetAttribute(CooldownAcceleration.Attribute)

			if type(attribute) == "number" and attribute > 1 then
				local v24 = {
					name = "Ability Recharge:",
					value = string.format("%gx faster", attribute),
					color = 0,
					source = 0
				}
				local modifierColor = getModifierColor(attribute) -- equivalent call inferred; original call site unknown
				v24.color = modifierColor
				v24.source = CooldownAcceleration.Attribute
				table.insert(v20, v24)
			end

			if #v20 > 0 then
				local frame = Instance.new("Frame")
				frame.Name = "ModifiersSeparator"
				frame.Size = UDim2.new(0.95, 0, 0, 1)
				frame.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				frame.BackgroundTransparency = 0.5
				frame.BorderSizePixel = 0
				frame.LayoutOrder = 100
				frame.Parent = scrollingFrame2
				local clone = template2:Clone()
				clone.Name = "ModifiersHeader"
				clone.LayoutOrder = 101
				clone.Visible = true
				clone.Stat.Text = "Active Modifiers"
				clone.Stat.TextColor3 = Color3.fromRGB(255, 200, 100)
				clone.StatValue.Text = ""
				clone.Parent = scrollingFrame2

				for i, v24 in ipairs(v20) do
					local clone2 = template2:Clone()
					clone2.Name = "ModEntry_" .. i
					clone2.LayoutOrder = 101 + i
					clone2.Visible = true
					clone2.ClipsDescendants = true
					clone2.Stat.Size = UDim2.new(0.35, 0, 1, 0)
					clone2.Stat.Text = v24.name
					clone2.Stat.TextColor3 = v24.color
					clone2.StatValue.Size = UDim2.new(0.65, 0, 1, 0)
					clone2.StatValue.Position = UDim2.new(0.35, 0, 0, 0)
					clone2.StatValue.Text = v24.value
					clone2.StatValue.TextColor3 = v24.color
					clone2.StatValue.TextScaled = true
					clone2:SetAttribute("Source", v24.source)
					clone2.Parent = scrollingFrame2
				end
			end
		end

		updateModifiersInStats()
		task.spawn(function()
			while character and character.Parent do
				if gui.StatsFrame.Visible then
					updateModifiersInStats()
					task.wait(0.25)
				else
					task.wait(0.5)
				end
			end
		end)
		local connections = {}

		for _, v20 in ipairs({
			"SpeedModifier",
			"RunSpeedModifier",
			"StaminaModifier",
			"StaminaRegenModifier",
			"BoundarySize",
			"BoundarySizeModifier",
			"DecodeSpeedModifier",
			"StealthModifier"
		}) do
			table.insert(
				connections,
				(character:GetAttributeChangedSignal("StatMod_" .. v20 .. "_Sources"):Connect(function()
					if gui.StatsFrame.Visible then
						updateModifiersInStats()
					end
				end))
			)
		end

		for _, v20 in ipairs({
			"WalkSpeed",
			"RunSpeed",
			"Stealth",
			"BoundarySize",
			"SkillCheckChance",
			"DecodeSpeed",
			"SpeedModifier",
			"RunSpeedModifier"
		}) do
			table.insert(
				connections,
				(character:GetAttributeChangedSignal("StatAdd_" .. v20 .. "_Sources"):Connect(function()
					if gui.StatsFrame.Visible then
						updateModifiersInStats()
					end
				end))
			)
		end

		local managedNames = DebuffConfig.GetManagedNames()

		for _, managedName in ipairs(managedNames) do
			table.insert(
				connections,
				(character:GetAttributeChangedSignal("Debuff_" .. managedName .. "_EndTime"):Connect(function()
					if gui.StatsFrame.Visible then
						updateModifiersInStats()
					end
				end))
			)
			table.insert(
				connections,
				(character:GetAttributeChangedSignal("Debuff_" .. managedName .. "_Strength"):Connect(function()
					if gui.StatsFrame.Visible then
						updateModifiersInStats()
					end
				end))
			)
			table.insert(
				connections,
				(character:GetAttributeChangedSignal("Debuff_" .. managedName .. "_Pending"):Connect(function()
					if gui.StatsFrame.Visible then
						updateModifiersInStats()
					end
				end))
			)
		end

		table.insert(connections, (character.ChildAdded:Connect(function(stringValue)
			if stringValue:IsA("StringValue") and gui.StatsFrame.Visible then
				updateModifiersInStats()
			end
		end)))
		table.insert(connections, (character.ChildRemoved:Connect(function(stringValue)
			if stringValue:IsA("StringValue") and gui.StatsFrame.Visible then
				updateModifiersInStats()
			end
		end)))
		table.insert(
			connections,
			(character:GetAttributeChangedSignal(CooldownAcceleration.Attribute):Connect(function()
				if gui.StatsFrame.Visible then
					updateModifiersInStats()
				end
			end))
		)
		humanoid.Died:Once(function()
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
		end)
		local MasteryManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("MasteryManager"))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showMasteryInfo(p)
			MasteryManager.register(p, child)
		end

		showMasteryInfo(game.Workspace:WaitForChild("Elevators"):WaitForChild("Elevator"):WaitForChild("TVCart"):WaitForChild("Screen"):WaitForChild("SurfaceGui")) -- equivalent call inferred; original call site unknown
		local v20 = nil

		local function isSettingsOpen()
			return MenuManager:IsOpen("SettingsController")
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeStats()
			gui.StatsFrame.Visible = false
			gui.MasteryFrame.Visible = false

			if v20 then
				v20()
			end
		end

		local settings = gui:FindFirstChild("Settings")

		if settings then
			settings:GetPropertyChangedSignal("Visible"):Connect(function()
				if settings.Visible and gui.StatsFrame.Visible then
					closeStats() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		gui.ViewStats.Activated:Connect(function()
			if gui.StatsFrame.Visible == false then
				if MenuManager:IsOpen("SettingsController") then
					return
				end

				gui.StatsFrame.Visible = true
				gui.MasteryFrame.Visible = true
				updateModifiersInStats()
				showMasteryInfo(gui) -- equivalent call inferred; original call site unknown
				v20 = nil
				Audio:PlayOne("Sounds.UI.Buttons.Click")
			else
				closeStats() -- equivalent call inferred; original call site unknown
				Audio:PlayOne("Sounds.UI.Buttons.Click")
			end
		end)
		local names = {}

		for _, moduleScript in pairs(game.ReplicatedStorage.TrinketData:GetChildren()) do
			local module = require(moduleScript)

			if module.TrinketType == "Toggle" then
				table.insert(names, moduleScript.Name)
			end
		end

		if table.find(names, trinket1.Value) then
			local active = trinket1:WaitForChild("Active")
			v3.TextLabel.Visible = true

			if active.Value == true then
				v3.ItemImage.ImageTransparency = 0
				v3.TextLabel.Text = "Active"
			else
				v3.ItemImage.ImageTransparency = 0.5
				v3.TextLabel.Text = "Inactive"
			end

			active.Changed:Connect(function()
				if active.Value == true then
					v3.ItemImage.ImageTransparency = 0
					v3.TextLabel.Text = "Active"
				else
					v3.ItemImage.ImageTransparency = 0.5
					v3.TextLabel.Text = "Inactive"
				end
			end)
		end

		if table.find(names, trinket2.Value) then
			local active = trinket2:WaitForChild("Active")
			v4.TextLabel.Visible = true

			if active.Value == true then
				v4.ItemImage.ImageTransparency = 0
				v4.TextLabel.Text = "Active"
			else
				v4.ItemImage.ImageTransparency = 0.5
				v4.TextLabel.Text = "Inactive"
			end

			active.Changed:Connect(function()
				if active.Value == true then
					v4.ItemImage.ImageTransparency = 0
					v4.TextLabel.Text = "Active"
				else
					v4.ItemImage.ImageTransparency = 0.5
					v4.TextLabel.Text = "Inactive"
				end
			end)
		end

		GameContext.sprintchanged = stats:WaitForChild("CurrentStamina"):GetPropertyChangedSignal("Value"):Connect(function()
			updateStaminaGui(stats)
		end)
		GameContext.sprintchanged2 = stats:WaitForChild("Stamina"):GetPropertyChangedSignal("Value"):Connect(function()
			updateStaminaGui(stats)
		end)
		local character2 = player.Character

		if character2 then
			GameContext.fatiguechanged = character2.AttributeChanged:Connect(function(p)
				if p == "StaminaFatigued" then
					updateStaminaGui(stats)
				end
			end)
		end

		if UserInputService.TouchEnabled then
			humanoid.JumpPower = 0
			viewStat.Visible = false
		else
			viewStat.Visible = true
		end

		updateHealthGui(stats, humanoid)
		GameContext.healthchanged = humanoid.HealthChanged:Connect(function()
			updateHealthGui(stats, humanoid)
		end)

		if GameContext.shieldchanged then
			GameContext.shieldchanged:Disconnect()
		end

		local parent = humanoid.Parent

		if parent then
			GameContext.shieldchanged = parent:GetAttributeChangedSignal("ShieldHearts"):Connect(function()
				updateHealthGui(stats, humanoid)
			end)
		end

		humanoid:GetPropertyChangedSignal("HipHeight"):Connect(function() end)
		GameContext.setUpAbility(character)
		gui.Stickers.Visible = true
		local inventory = character:WaitForChild("Inventory", 5)

		if not inventory then
			return
		end

		local slot1 = inventory:WaitForChild("Slot1")
		local slot2 = inventory:WaitForChild("Slot2")
		local slot3 = inventory:WaitForChild("Slot3")
		local slot4

		if inventory:FindFirstChild("Slot4") then
			slot4 = inventory:WaitForChild("Slot4")
			gui.Slot4.Visible = true
		else
			slot4 = nil
		end

		local lastTime = tick()
		local v21 = nil
		local v22 = nil
		local v23 = false
		local v24 = {}
		local v25 = {}

		local function ItemInfo(data)
			gui.ItemInfo.Visible = true
			gui.ItemMessage.Visible = false
			gui.MessageText.Visible = false
			lastTime = tick()
			gui.ItemInfo.TextStrokeTransparency = 0
			gui.ItemInfo.TextTransparency = 0
			local itemInfo = gui.ItemInfo
			local tweenInfo2 = TweenInfo.new(1)
			v21 = TweenService:Create(itemInfo, tweenInfo2, {
				TextStrokeTransparency = 1
			})
			v22 = TweenService:Create(itemInfo, tweenInfo2, {
				TextTransparency = 1
			})
			gui.ItemInfo.TextStrokeTransparency = 0
			gui.ItemInfo.TextTransparency = 0
			gui.ItemInfo.Text = data.Name .. ": " .. data.Description .. " (Rarity: " .. data.Rarity .. ")"
			local message = gui.SelectionFrame:FindFirstChild("Message")

			if message then
				message.Text = data.Name .. ": " .. data.Description .. " (Rarity: " .. data.Rarity .. ")"
			end

			task.spawn(function()
				task.wait(5)

				if tick() - lastTime >= 5 then
					v21:Play()
					v22:Play()
					task.delay(1, function()
						if v23 == false then
							gui.ItemInfo.Visible = false
						end
					end)
				end
			end)
		end

		local function Update_Slot(instance)
			local uDim4 = UDim2.new(0.058, 0, 0.114, 0)
			local uDim5 = UDim2.new(0.045, 0, 0.088, 0)
			local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
			gui[instance.Name].Size = uDim5
			TweenService:Create(gui[instance.Name], tweenInfo2, {
				Size = uDim4
			}):Play()

			if instance.Value == "None" then
				gui[instance.Name].ItemImage.Visible = false
				gui[instance.Name].ChargeText.Visible = false

				if v24[instance] then
					v24[instance] = nil
				end

				if v25[instance] then
					v25[instance] = nil
				end
			else
				local child3 = ReplicatedStorage.ItemModules:FindFirstChild(instance.Value)

				if child3 then
					local module = require(child3)
					gui[instance.Name].ItemImage.Image = module.Icon

					if v21 then
						v21:Pause()
						v21:Destroy()
						v23 = true
					end

					if v22 then
						v22:Pause()
						v22:Destroy()
						v23 = true
					end

					ItemInfo(module)

					if module.HasCharges then
						local charges = instance:WaitForChild("Charges")
						local current = instance:WaitForChild("Current")
						gui[instance.Name].ChargeText.Text = current.Value .. "/" .. charges.Value
						gui[instance.Name].ChargeText.Visible = true
						v24[instance] = current:GetPropertyChangedSignal("Value"):Connect(function()
							gui[instance.Name].ChargeText.Text = current.Value .. "/" .. charges.Value
						end)
						v25[instance] = current.Destroying:Connect(function()
							gui[instance.Name].ChargeText.Visible = false

							if v24[instance] then
								v24[instance] = nil
							end

							if v25[instance] then
								v25[instance] = nil
							end
						end)
					else
						gui[instance.Name].ChargeText.Visible = false

						if v24[instance] then
							v24[instance] = nil
						end

						if v25[instance] then
							v25[instance] = nil
						end
					end
				else
					local icon = instance:GetAttribute("Icon")

					if icon then
						gui[instance.Name].ItemImage.Image = icon

						if v21 then
							v21:Pause()
							v21:Destroy()
							v23 = true
						end

						if v22 then
							v22:Pause()
							v22:Destroy()
							v23 = true
						end

						ItemInfo({
							Name = instance.Value,
							Description = instance:GetAttribute("Description") or "",
							Rarity = instance:GetAttribute("Rarity") or "",
							Icon = icon
						})
					end

					gui[instance.Name].ChargeText.Visible = false

					if v24[instance] then
						v24[instance] = nil
					end

					if v25[instance] then
						v25[instance] = nil
					end
				end

				gui[instance.Name].ItemImage.Visible = true
				Audio:PlayOne("Sounds.UI.ItemPickup")

				if not Audio:IsOnePlaying("Sounds.UI.Woosh") then
					Audio:PlayOne("Sounds.UI.Woosh", {
						PlaybackSpeed = 2
					})
				end
			end
		end

		gui.Slot1.MouseEnter:Connect(function()
			local child3 = slot1.Value ~= "None" and ReplicatedStorage.ItemModules:FindFirstChild(slot1.Value)

			if child3 then
				local module = require(child3)
				ItemInfo(module)
			end
		end)
		gui.Slot2.MouseEnter:Connect(function()
			local child3 = slot2.Value ~= "None" and ReplicatedStorage.ItemModules:FindFirstChild(slot2.Value)

			if child3 then
				local module = require(child3)
				ItemInfo(module)
			end
		end)
		gui.Slot3.MouseEnter:Connect(function()
			local child3 = slot3.Value ~= "None" and ReplicatedStorage.ItemModules:FindFirstChild(slot3.Value)

			if child3 then
				local module = require(child3)
				ItemInfo(module)
			end
		end)

		if slot4 then
			gui.Slot4.MouseEnter:Connect(function()
				local child3 = slot4.Value ~= "None" and ReplicatedStorage.ItemModules:FindFirstChild(slot4.Value)

				if child3 then
					local module = require(child3)
					ItemInfo(module)
				end
			end)
		end

		GameContext.slot1changed = slot1.Changed:Connect(function()
			Update_Slot(slot1)
		end)
		GameContext.slot2changed = slot2.Changed:Connect(function()
			Update_Slot(slot2)
		end)
		GameContext.slot3changed = slot3.Changed:Connect(function()
			Update_Slot(slot3)
		end)

		if slot4 then
			GameContext.slot4changed = slot4.Changed:Connect(function()
				Update_Slot(slot4)
			end)
		end

		Update_Slot(slot1)
		Update_Slot(slot2)
		Update_Slot(slot3)

		if slot4 then
			Update_Slot(slot4)
		end

		local flag = false
		local lastTime2 = tick()

		local function UseItem(p)
			if InputService:IsGameplaySuspended() or flag or not p then
				return
			end

			flag = true
			local success, result = pcall(function()
				return ReplicatedStorage.Events.ItemEvent:InvokeServer(character, p)
			end)
			flag = false

			if not success then
				warn("[GMM] Item use error:", result)
			elseif result then
				if result[1] == "Empty" then
					warn("No item in " .. p.Name)
				elseif result[1] == "Used" then
					Audio:PlayOne("Sounds.UI.Combat.Use")
				elseif result[1] == "CantUse" then
					gui.ItemMessage.Text = tostring(result[2])
					gui.ItemInfo.Visible = false
					gui.MessageText.Visible = false
					local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
					local position3 = position + UDim2.new(0, 0, -0.075, 0)
					gui.ItemMessage.Position = position3
					gui.ItemMessage.Visible = true
					Audio:PlayOne("Sounds.UI.Combat.CantUse")
					TweenService:Create(gui.ItemMessage, tweenInfo2, {
						Position = position
					}):Play()
					lastTime2 = tick()
					task.delay(1.05, function()
						if tick() - lastTime2 >= 1 then
							gui.ItemMessage.Visible = false
						end
					end)
				end
			end
		end

		for _, connection in ipairs(v10) do
			connection:Disconnect()
		end

		table.clear(v10)
		v10[#v10 + 1] = gui.Slot1.Activated:Connect(function()
			local inventory2 = character and character:FindFirstChild("Inventory")

			if inventory2 then
				UseItem(inventory2:FindFirstChild("Slot1"))
			end
		end)
		v10[#v10 + 1] = gui.Slot2.Activated:Connect(function()
			local inventory2 = character and character:FindFirstChild("Inventory")

			if inventory2 then
				UseItem(inventory2:FindFirstChild("Slot2"))
			end
		end)
		v10[#v10 + 1] = gui.Slot3.Activated:Connect(function()
			local inventory2 = character and character:FindFirstChild("Inventory")

			if inventory2 then
				UseItem(inventory2:FindFirstChild("Slot3"))
			end
		end)
		v10[#v10 + 1] = gui.Slot4.Activated:Connect(function()
			local inventory2 = character and character:FindFirstChild("Inventory")

			if inventory2 then
				UseItem(inventory2:FindFirstChild("Slot4"))
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function menuIsOpen()
			return gui.StickerMenu.UIScale.Scale > 0.5
		end

		local function toggleStats()
			if gui.StatsFrame.Visible == false then
				gui.StatsFrame.Visible = true
				gui.MasteryFrame.Visible = true
				updateModifiersInStats()
				showMasteryInfo(gui) -- equivalent call inferred; original call site unknown
				v20 = nil
				Audio:PlayOne("Sounds.UI.Buttons.Click")
			else
				closeStats() -- equivalent call inferred; original call site unknown
				Audio:PlayOne("Sounds.UI.Buttons.Click")
			end
		end

		v10[#v10 + 1] = InputService:OnAction("OpenStats", function()
			if character.Parent ~= workspace.InGamePlayers or InputService:IsTyping() then
				return
			end

			if gui.StatsFrame.Visible or not MenuManager:IsOpen("SettingsController") then
				toggleStats()
			end
		end)

		local function useSlot(childName)
			if character.Parent ~= workspace.InGamePlayers or InputService:IsTyping() or menuIsOpen() and InputService:GetPreferredInput() == "Gamepad" then
				return
			end

			local inventory2 = character and character:FindFirstChild("Inventory")

			if inventory2 then
				UseItem(inventory2:FindFirstChild(childName))
			end
		end

		v10[#v10 + 1] = InputService:OnAction("Item1", function()
			useSlot("Slot1")
		end)
		v10[#v10 + 1] = InputService:OnAction("Item2", function()
			useSlot("Slot2")
		end)
		v10[#v10 + 1] = InputService:OnAction("Item3", function()
			useSlot("Slot3")
		end)
		v10[#v10 + 1] = InputService:OnAction("Item4", function()
			useSlot("Slot4")
		end)
	end
end

return CharacterStatsController