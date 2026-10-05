local AbilityController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage2.SharedUtils.InputService)
game:GetService("CollectionService")
game:GetService("ProximityPromptService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local TargetingVisual = require(ReplicatedStorage.Modules.ClientUI.TargetingVisual)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local CooldownAcceleration = require(ReplicatedStorage.Modules.Gameplay.CooldownAcceleration)
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local MaskIcons = require(ReplicatedStorage.Modules.ClientUI.MaskIcons)
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local v = nil

local function routeThroughMusicBus(p)
	if not (p and SoundGroupManager.AssignMusicSound(p)) then
		return
	end

	local group = SoundGroupManager.GetGroup("Music")

	if not group then
		return
	end

	group.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
end

local uDim = UDim2.fromScale(0.914, 0.918)
local uDim2 = UDim2.fromScale(0.18, 0.325)

-- equivalent calls inferred from this helper; original call sites unknown
local function maskSwingTemplate(instance)
	local playerGui = instance and instance:FindFirstChildOfClass("PlayerGui")
	local trickOrTreatFeed = playerGui and playerGui:FindFirstChild("TrickOrTreatFeed")
	local maskResult = trickOrTreatFeed and trickOrTreatFeed:FindFirstChild("MaskResult", true)
	return maskResult and maskResult:FindFirstChild("MaskSwing", true)
end

local function refreshMaskBadge(ability1, player, instance)
	local maskBadge = ability1:FindFirstChild("MaskBadge")
	local maskToon = instance and instance:GetAttribute("MaskToon")
	local v2

	if type(maskToon) == "string" and maskToon ~= "" and instance:GetAttribute("MaskStatsOnly") ~= true then
		v2 = instance:GetAttribute("MaskRevealPending") ~= true
	else
		v2 = false
	end

	if v2 then
		if maskBadge then
			return
		end

		local v3 = maskSwingTemplate(player) -- equivalent call inferred; original call site unknown

		if not v3 then
			warn("[AbilityController] mask badge skipped: no MaskSwing under PlayerGui.TrickOrTreatFeed.MaskResult")
			return
		end

		local clone = v3:Clone()
		clone.Name = "MaskBadge"
		clone.Size = uDim
		clone.Position = uDim2
		clone.Rotation = -27
		clone.ZIndex = 55
		clone.Visible = true
		MaskIcons.apply(clone, maskToon)
		clone.Parent = ability1
	elseif maskBadge then
		maskBadge:Destroy()
	end
end

function AbilityController.init(p)
	v = p
end

function AbilityController.setupAll()
	local gui = GameContext.Gui
	local player = GameContext.Player
	local healTargetController = v.HealTargetController
	local gingerPromptController = v.GingerPromptController
	local squirmHoldController = v.SquirmHoldController
	local position = gui.ItemMessage.Position
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getDragTouchPosition()
		if not v2 then
			return nil
		end

		local position2 = v2.Position
		local guiInset = GuiService:GetGuiInset()
		return Vector2.new(position2.X, position2.Y) + guiInset
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getPointerPosition()
		local dragTouchPosition = getDragTouchPosition() -- equivalent call inferred; original call site unknown
		return dragTouchPosition or UserInputService:GetMouseLocation()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resetDragVisuals()
		v2 = nil
		gui.AbilityIcon.Visible = false
		gui.AbilityCancelIcon.Visible = false
		gui.EndAbility.Visible = false
	end

	RunService.RenderStepped:Connect(function()
		if gui.AbilityIcon.Visible == true then
			local pointerPosition = getPointerPosition() -- equivalent call inferred; original call site unknown
			gui.AbilityIcon.Position = UDim2.new(0, pointerPosition.X, 0, pointerPosition.Y)
		end
	end)
	local character = GameContext.Character
	Players.LocalPlayer.CharacterAdded:Connect(function(character2)
		character = character2
	end)
	local lastTime = tick()

	local function showItemMessage(p)
		gui.ItemMessage.Text = tostring(p)
		gui.ItemInfo.Visible = false
		gui.MessageText.Visible = false
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
		local position2 = position + UDim2.new(0, 0, -0.075, 0)
		gui.ItemMessage.Position = position2
		gui.ItemMessage.Visible = true
		Audio:PlayOne("Sounds.UI.Combat.CantUse")
		TweenService:Create(gui.ItemMessage, tweenInfo, {
			Position = position
		}):Play()
		lastTime = tick()
		task.delay(1.05, function()
			if tick() - lastTime >= 1 then
				gui.ItemMessage.Visible = false
			end
		end)
	end

	Network:AddAction("ShowAbilityMessage", function(p)
		showItemMessage(p)
	end)
	local flag = false
	local now = 0
	ReplicatedStorage.Events.ClientAbilityEvent.OnClientEvent:Connect(function(moduleScript, p, ...)
		local module = require(moduleScript)
		module.ClientAbility(player, p, ...)
	end)

	local function UseAbility(p, cFrame, p2, p3, _)
		local v3 = ReplicatedStorage.Events.AbilityEvent:InvokeServer(p, cFrame, p2, p3)

		if v3 then
			if v3[1] == "Used" then
				if not gui.AbilitySound:GetAttribute("Exclusive") then
					Audio:PlayOne("Sounds.UI.Combat.Use")
				end

				local path = gui.AbilitySound:GetAttribute("Path")
				local v4

				if path then
					v4 = Audio:PlayOne(path)
				else
					v4 = Audio:PlayOne(gui.AbilitySound.SoundId, {
						PlaybackSpeed = gui.AbilitySound.PlaybackSpeed,
						Volume = gui.AbilitySound.Volume
					})
				end

				if gui.AbilitySound:GetAttribute("Music") and v4 then
					if not SoundGroupManager.AssignMusicSound(v4) then
						return
					end

					local group = SoundGroupManager.GetGroup("Music")

					if not group then
						return
					end

					group.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
				end
			else
				if v3[1] == "PromptCreated" then
					Audio:PlayOne("Sounds.UI.Combat.Use")
					return
				end

				if v3[1] == "Cancelled" then
					return
				end

				if v3[1] == "CantUse" then
					showItemMessage(tostring(v3[2]))
				end
			end
		end
	end

	local currentCamera = workspace.CurrentCamera
	local parts = {}
	workspace.CurrentRoom.ChildAdded:Connect(function(folder)
		if folder.Name == "Puddles" or folder.Name == "Zones" or not folder:WaitForChild("FreeArea", 5) then
			return
		end

		repeat
			task.wait(0.5)
		until workspace.Info.FloorActive.Value == true

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Transparency == 1 then
				table.insert(parts, part)
			end
		end
	end)
	workspace.CurrentRoom.ChildRemoved:Connect(function()
		parts = {}
	end)
	local v3 = {}

	local function CleanupAbilityConnections()
		for _, connection in pairs(v3) do
			if not connection then
				continue
			end

			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			elseif typeof(connection) == "table" and connection.Disconnect then
				connection.Disconnect()
			end
		end

		v3 = {}
	end

	local SetUpAbility

	SetUpAbility = function(folder)
		local v4 = folder or GameContext.Character or player.Character or player.CharacterAdded:Wait()
		CleanupAbilityConnections()

		if v4 then
			table.insert(v3, v4:GetAttributeChangedSignal("MaskToon"):Connect(function()
				task.defer(SetUpAbility, v4)
			end))
			table.insert(v3, v4:GetAttributeChangedSignal("MaskRevealPending"):Connect(function()
				task.defer(SetUpAbility, v4)
			end))
			table.insert(v3, v4:GetAttributeChangedSignal("MaskStatsOnly"):Connect(function()
				task.defer(SetUpAbility, v4)
			end))
		end

		local children = currentCamera:GetChildren()

		if folder and folder.Parent ~= nil then
			for _, descendant in pairs(folder:GetDescendants()) do
				table.insert(children, descendant)
			end
		end

		for _, child in pairs(workspace.Elevators:GetChildren()) do
			table.insert(children, child)
		end

		table.insert(v3, workspace.Elevators.ChildAdded:Connect(function(child)
			table.insert(children, child)
		end))
		healTargetController.init(folder)
		table.insert(v3, {
			Disconnect = function()
				healTargetController.cleanup()
			end
		})
		local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
		local selectedCharacter = child and child:FindFirstChild("SelectedCharacter")

		if selectedCharacter and selectedCharacter.Value == "Ginger" then
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local gingerHealPrompt = humanoidRootPart:FindFirstChild("GingerHealPrompt")

				if gingerHealPrompt and gingerHealPrompt:IsA("ProximityPrompt") then
					gingerHealPrompt.Enabled = false
				end

				table.insert(v3, humanoidRootPart.ChildAdded:Connect(function(proximityPrompt)
					if proximityPrompt.Name == "GingerHealPrompt" and proximityPrompt:IsA("ProximityPrompt") then
						proximityPrompt.Enabled = false
					end
				end))
			end
		else
			local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

			if inGamePlayers then
				for _, child2 in pairs(inGamePlayers:GetChildren()) do
					local humanoidRootPart = child2:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart then
						continue
					end

					local gingerHealPrompt = humanoidRootPart:FindFirstChild("GingerHealPrompt")

					if gingerHealPrompt and gingerHealPrompt:IsA("ProximityPrompt") then
						gingerHealPrompt.Enabled = false
					end
				end
			end

			local ProximityPromptService = game:GetService("ProximityPromptService")
			table.insert(v3, ProximityPromptService.PromptShown:Connect(function(p)
				if p.Name == "GingerHealPrompt" then
					p.Enabled = false
				end
			end))
		end

		local function MouseRaycast(p)
			local mouseLocation = UserInputService:GetMouseLocation()
			local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			local raycastParams = RaycastParams.new()

			if p then
				table.insert(children, p)
			end

			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = parts
			return (workspace:Raycast(viewportPointToRay.Origin, viewportPointToRay.Direction * 1000, raycastParams))
		end

		if not folder:WaitForChild("Config", 5) then
			return
		end

		gui.Ability1.Visible = false
		gui.Ability1.CooldownText.Visible = false
		gui.Ability1.CooldownFrame.Visible = false
		gui.Ability1.TapeLabel.Visible = false
		gui.Ability1.AbilityCost.Visible = false
		gui.HealCooldownIcon.Visible = false
		refreshMaskBadge(gui.Ability1, player, v4)
		local effectiveTower = TowerLUT:GetEffectiveTower(folder)

		if effectiveTower then
			local module = require(effectiveTower)
			local cooldown = nil
			local currentCooldown = nil

			if module.CameraMaxZoomDistance then
				game.Players.LocalPlayer.CameraMaxZoomDistance = module.CameraMaxZoomDistance
			end

			if module.CameraMinZoomDistance then
				game.Players.LocalPlayer.CameraMinZoomDistance = module.CameraMinZoomDistance
			end

			if module.ActiveAbility then
				local abilities = folder:WaitForChild("Abilities", 5)

				if not abilities then
					return
				end

				local ability1 = abilities:WaitForChild("Ability1", 5)

				if not ability1 then
					return
				end

				if module.CustomAbilitySound then
					local customAbilitySound = module.CustomAbilitySound
					local path

					if type(customAbilitySound) == "table" then
						path = customAbilitySound.Path or nil
					end

					gui.AbilitySound:SetAttribute("Path", path)
					gui.AbilitySound:SetAttribute(
						"Exclusive",
						type(customAbilitySound) == "table" and customAbilitySound.Exclusive == true or nil
					)
					gui.AbilitySound:SetAttribute(
						"Music",
						type(customAbilitySound) == "table" and customAbilitySound.Music == true or nil
					)

					if not path then
						gui.AbilitySound.SoundId = customAbilitySound.SoundId or customAbilitySound
						gui.AbilitySound.PlaybackSpeed = customAbilitySound.PlaybackSpeed or 1
						gui.AbilitySound.Volume = customAbilitySound.Volume or 1
					end
				else
					gui.AbilitySound:SetAttribute("Path", nil)
					gui.AbilitySound:SetAttribute("Exclusive", nil)
					gui.AbilitySound:SetAttribute("Music", nil)
					gui.AbilitySound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
					gui.AbilitySound.PlaybackSpeed = 1
					gui.AbilitySound.Volume = 0.5
				end

				gui.Ability1.Visible = v4:GetAttribute("MaskRevealPending") ~= true
				gui.Ability1.ItemImage.Image = module.AbilityIcon

				if module.AbilityCooldown then
					cooldown = ability1:WaitForChild("Cooldown", 5)
					currentCooldown = ability1:WaitForChild("CurrentCooldown", 5)

					if currentCooldown.Value == 0 then
						gui.Ability1.CooldownText.Visible = false
					else
						gui.Ability1.CooldownText.Visible = true
						gui.Ability1.CooldownText.Text = currentCooldown.Value
					end

					local v5 = nil
					local value = currentCooldown.Value
					table.insert(v3, currentCooldown.Changed:Connect(function()
						local v6 = math.clamp(currentCooldown.Value / cooldown.Value, 0, 1)

						if v5 then
							v5:Cancel()
							v5 = nil
						end

						local v7

						if value > 0 and currentCooldown.Value > 0 then
							v7 = currentCooldown.Value < value
						else
							v7 = false
						end

						value = currentCooldown.Value

						if v7 then
							gui.Ability1.CooldownFrame.Size = UDim2.new(1, 0, v6, 0)
						else
							if v6 == 1 then
								gui.Ability1.CooldownFrame.Size = UDim2.new(1, 0, 1, 0)
							end

							local tweenInfo = TweenInfo.new(
								0.15,
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out,
								0,
								false
							)
							v5 = TweenService:Create(gui.Ability1.CooldownFrame, tweenInfo, {
								Size = UDim2.new(1, 0, v6, 0)
							})
							v5:Play()
						end

						if currentCooldown.Value == 0 then
							gui.Ability1.ItemImage.ImageTransparency = 0
							gui.Ability1.CooldownFrame.Visible = false
							gui.Ability1.CooldownText.Visible = false
						else
							gui.Ability1.CooldownFrame.Visible = true
							gui.Ability1.CooldownText.Visible = true
							gui.Ability1.CooldownText.Text = string.format("%.1f", currentCooldown.Value)
							gui.Ability1.ItemImage.ImageTransparency = 0.5
						end
					end))
					local cooldownAccelIcon = gui.Ability1:FindFirstChild("CooldownAccelIcon")

					if cooldownAccelIcon then
						local label = cooldownAccelIcon:FindFirstChild("Label")
						local clock = cooldownAccelIcon:FindFirstChild("Clock")
						local handle = clock and clock:FindFirstChild("Handle")
						local glow = cooldownAccelIcon:FindFirstChild("Glow")
						local v6 = {}
						local v7 = false

						-- equivalent calls inferred from this helper; original call sites unknown
						local function stopAccelTweens()
							for i, v8 in ipairs(v6) do
								v8:Cancel()
								v6[i] = nil
							end
						end

						local function startAccelTweens()
							stopAccelTweens() -- equivalent call inferred; original call site unknown

							if handle then
								handle.Rotation = 0
								table.insert(
									v6,
									tweenHelpers.playTween(
										handle,
										TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
										{
											Rotation = 360
										}
									)
								)
							end

							if glow then
								glow.ImageTransparency = 0
								table.insert(
									v6,
									tweenHelpers.playTween(
										glow,
										TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
										{
											ImageTransparency = 1
										}
									)
								)
							end
						end

						local function updateAccelIcon()
							local attribute = folder:GetAttribute(CooldownAcceleration.Attribute)
							local visible = type(attribute) == "number" and attribute > 1 and currentCooldown.Value > 0

							if visible and label then
								label.Text = string.format("x%g", attribute)
							end

							if visible ~= v7 then
								v7 = visible

								if visible then
									startAccelTweens()
								else
									stopAccelTweens() -- equivalent call inferred; original call site unknown
								end
							end

							cooldownAccelIcon.Visible = visible
						end

						updateAccelIcon()
						table.insert(
							v3,
							folder:GetAttributeChangedSignal(CooldownAcceleration.Attribute):Connect(updateAccelIcon)
						)
						table.insert(v3, currentCooldown.Changed:Connect(updateAccelIcon))
						table.insert(v3, {
							Disconnect = function()
								stopAccelTweens() -- equivalent call inferred; original call site unknown
								cooldownAccelIcon.Visible = false
							end
						})
					end
				end

				if ability1:FindFirstChild("AbilityCost") then
					local abilityCost = ability1:WaitForChild("AbilityCost")

					-- equivalent calls inferred from this helper; original call sites unknown
					local function UpdateCost(text)
						gui.Ability1.AbilityCost.Text = text
					end

					gui.Ability1.TapeLabel.Visible = true
					gui.Ability1.AbilityCost.Visible = true
					table.insert(v3, abilityCost.Changed:Connect(function(text)
						UpdateCost(text) -- equivalent call inferred; original call site unknown
					end))
					UpdateCost(abilityCost.Value) -- equivalent call inferred; original call site unknown
				end

				local lastTime2 = tick()
				local v5 = false
				local v6 = nil
				local v7 = nil
				table.insert(v3, {
					Disconnect = function()
						TargetingVisual.Clear(v6, v7)
						v6 = nil
						v7 = nil
						v5 = nil
					end
				})

				local function getMousePosition()
					local dragTouchPosition = getDragTouchPosition() -- equivalent call inferred; original call site unknown
					return dragTouchPosition or UserInputService:GetMouseLocation()
				end

				local currentCamera2 = workspace.CurrentCamera

				if module.HealCooldown then
					table.insert(
						v3,
						workspace.Info.GameStats.HealCooldown:GetPropertyChangedSignal("Value"):Connect(function()
							if workspace.Info.GameStats.HealCooldown.Value == true then
								gui.HealCooldownIcon.Visible = true
							else
								gui.HealCooldownIcon.Visible = false
							end
						end)
					)
				end

				if module.PlayerAbility then
					local RunService2 = game:GetService("RunService")
					local CollectionService = game:GetService("CollectionService")
					local diedConnection = nil
					local renderSteppedConnection = RunService2.RenderStepped:Connect(function()
						local dragTouchPosition = getDragTouchPosition() -- equivalent call inferred; original call site unknown
						local v8 = dragTouchPosition or UserInputService:GetMouseLocation()

						if v8 then
							local humanoidRootPart = v4 and v4:FindFirstChild("HumanoidRootPart")

							if not humanoidRootPart then
								return
							end

							if module.ClearTargetDuringCooldown and currentCooldown and currentCooldown.Value > 0 then
								if v6 or v7 then
									TargetingVisual.Clear(v6, v7)
									v6 = nil
									v7 = nil
									v5 = nil
								end
							else
								local v9 = 9999
								local v10 = nil
								local v11 = false

								if module.GeneratorAbility then
									local tagged = CollectionService:GetTagged("Generator")

									if module.CanTargetStash then
										for _, v12 in ipairs(CollectionService:GetTagged("GigiStash")) do
											table.insert(tagged, v12)
										end
									end

									for _, v12 in pairs(tagged) do
										local v13 = v12 and module.CanTargetGenerator and not module.CanTargetGenerator(
											v12,
											player
										)

										if not v12 or not v12.PrimaryPart or v13 or not (not v4:FindFirstChild("Decoding") or v4.Decoding.Value == nil) then
											continue
										end

										local primaryPart = v12.PrimaryPart
										local worldToScreenPoint, v14 = currentCamera2:WorldToScreenPoint(primaryPart.Position)
										local magnitude = (Vector2.new(v8.X, v8.Y) - Vector2.new(
											worldToScreenPoint.X,
											worldToScreenPoint.Y
										)).magnitude
										local magnitude2 = (primaryPart.Position - humanoidRootPart.Position).Magnitude

										if not (v14 and magnitude < v9 and magnitude2 <= module.PlayerRadius) then
											continue
										end

										v10 = v12
										v9 = magnitude
										v11 = true
									end
								end

								local v12 = module.GeneratorOnlyAbility and {} or workspace.InGamePlayers:GetChildren()

								for _, v13 in pairs(v12) do
									local humanoidRootPart2

									if v13 then
										if v13 == v4 then
											humanoidRootPart2 = false
										else
											humanoidRootPart2 = v13:FindFirstChild("HumanoidRootPart")
										end
									else
										humanoidRootPart2 = v13
									end

									if humanoidRootPart2 and v13:GetAttribute("GuardedBy") == player.Name then
										humanoidRootPart2 = nil
									end

									if not humanoidRootPart2 then
										continue
									end

									local worldToScreenPoint, v14 = currentCamera2:WorldToScreenPoint(humanoidRootPart2.Position)
									local magnitude = (Vector2.new(v8.X, v8.Y) - Vector2.new(
										worldToScreenPoint.X,
										worldToScreenPoint.Y
									)).magnitude
									local magnitude2 = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude
									local v15 = true

									if module.HoldProximityAbility and not module.SelfTargetedAbility then
										local humanoid = v13:FindFirstChild("Humanoid")

										if humanoid then
											if humanoid.Health >= humanoid.MaxHealth then
												v15 = false
											end

											if humanoid.Health <= 0 then
												v15 = false
											end

											local child2 = workspace.Info.PlayerStats:FindFirstChild(player.Name)

											if child2 then
												local survivalPoints = child2:FindFirstChild("SurvivalPoints")
												local abilityCost = ability1 and ability1:FindFirstChild("AbilityCost")

												if survivalPoints and abilityCost and survivalPoints.Value < abilityCost.Value then
													v15 = false
												end
											end
										else
											v15 = false
										end
									end

									local v16 = module.HoldProximityAbility and magnitude2 or magnitude
									local holdProximityAbility = module.HoldProximityAbility or v14

									if not (v15 and holdProximityAbility and v16 < v9 and magnitude2 <= module.PlayerRadius * 1) then
										continue
									end

									v10 = v13
									v9 = v16
									v11 = false
								end

								if module.HoldProximityAbility and not module.SelfTargetedAbility and gingerPromptController.isChanneling() then
									return
								end

								if v10 then
									if v10 ~= v5 then
										v5 = v10
										TargetingVisual.Clear(v6, v7)
										v6, v7 = TargetingVisual.Show(module, v5, v11)
										lastTime2 = tick()
									end
								elseif tick() - lastTime2 >= 0.5 then
									TargetingVisual.Clear(v6, v7)
									v6 = nil
									v7 = nil
									v5 = nil
								end
							end
						end
					end)
					table.insert(v3, renderSteppedConnection)
					local humanoid = v4:WaitForChild("Humanoid", 5)

					if not humanoid then
						return
					end

					diedConnection = humanoid.Died:Connect(function()
						renderSteppedConnection:Disconnect()
						TargetingVisual.Clear(v6, v7)
						v6 = nil
						v7 = nil
						v5 = nil
						diedConnection:Disconnect()
					end)
					table.insert(v3, diedConnection)
					local v8 = false
					local v9 = false
					local v10 = false
					local v11 = false
					table.insert(v3, gui.Ability1.MouseEnter:Connect(function()
						v8 = true
					end))
					table.insert(v3, gui.Ability1.MouseLeave:Connect(function()
						v8 = false
					end))
					table.insert(v3, gui.AbilityCancelIcon.MouseEnter:Connect(function()
						v10 = true
						gui.AbilityCancelIcon.ImageColor3 = Color3.fromRGB(255, 100, 100)
					end))
					table.insert(v3, gui.AbilityCancelIcon.MouseLeave:Connect(function()
						task.wait()
						v10 = false
						gui.AbilityCancelIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					end))
					table.insert(v3, UserInputService.InputBegan:Connect(function(input)
						if module.HoldProximityAbility or InputService:IsGameplaySuspended() or currentCooldown and currentCooldown.Value ~= 0 then
							return
						end

						if input.UserInputType == Enum.UserInputType.Touch then
							if v2 then
								local userInputState = v2.UserInputState

								if userInputState ~= Enum.UserInputState.End and userInputState ~= Enum.UserInputState.Cancel then
									return
								end

								v9 = false
								resetDragVisuals() -- equivalent call inferred; original call site unknown
							end

							v9 = v8

							if not v9 then
								return
							end

							v2 = input
							local dragTouchPosition = getDragTouchPosition() -- equivalent call inferred; original call site unknown
							gui.AbilityIcon.Position = UDim2.new(0, dragTouchPosition.X, 0, dragTouchPosition.Y)
							gui.AbilityIcon.ItemImage.Image = gui.Ability1.ItemImage.Image
							gui.AbilityCancelIcon.Visible = true
							gui.EndAbility.Visible = true
							gui.AbilityIcon.Visible = true
						end
					end))
					table.insert(v3, UserInputService.InputEnded:Connect(function(input)
						if module.HoldProximityAbility then
							return
						end

						if input.UserInputType == Enum.UserInputType.Touch and v2 == input then
							v11 = v10

							if v9 and not v11 and not InputService:IsGameplaySuspended() and v4.PrimaryPart then
								flag = true
								now = tick()
								UseAbility(v4, v4.PrimaryPart.CFrame, v5, nil, module)
								flag = false
							end

							v11 = false
							v9 = false
							resetDragVisuals() -- equivalent call inferred; original call site unknown
						end
					end))
					table.insert(v3, InputService.GameplayInterrupted:Connect(function()
						if not v9 then
							return
						end

						v9 = false
						v11 = false
						resetDragVisuals() -- equivalent call inferred; original call site unknown
					end))
					table.insert(v3, {
						Disconnect = function()
							if not v2 then
								return
							end

							resetDragVisuals() -- equivalent call inferred; original call site unknown
						end
					})

					if module.HoldProximityAbility then
						local function SoftMessage(p)
							GameContext.TextMessage(p)
						end

						if module.SelfTargetedAbility then
							squirmHoldController.init(player, folder, gui, module, SoftMessage, UseAbility)
							table.insert(v3, {
								Disconnect = function()
									squirmHoldController.cleanup()
								end
							})
						else
							gingerPromptController.init(player, folder, gui, module, SoftMessage)
							table.insert(v3, {
								Disconnect = function()
									gingerPromptController.cleanup()
								end
							})
						end
					end
				end

				if module.HoldProximityAbility and module.SelfTargetedAbility and not module.PlayerAbility then
					local function SoftMessage(p)
						GameContext.TextMessage(p)
					end

					squirmHoldController.init(player, folder, gui, module, SoftMessage, UseAbility)
					table.insert(v3, {
						Disconnect = function()
							squirmHoldController.cleanup()
						end
					})
				end

				local function isValidButtonInput(p)
					return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch
				end

				table.insert(v3, InputService:OnAction("UseAbility", function()
					if InputService:IsTyping() or v4.Parent ~= workspace.InGamePlayers or module.HoldProximityAbility or UserInputService:GetFocusedTextBox() then
						return
					end

					local TextChatService = game:GetService("TextChatService")
					local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

					if chatInputBarConfiguration and chatInputBarConfiguration.IsFocused then
						return
					end

					if flag and tick() - now > 15 then
						flag = false
					end

					local soulvesterLabArmed = player:GetAttribute("SoulvesterLabArmed") == true

					if flag then
						if soulvesterLabArmed then
							print("[SoulvesterLab/client] F swallowed: the previous cast is still waiting on the server")
						end
					else
						if not v4.PrimaryPart then
							return
						end

						if soulvesterLabArmed then
							print(string.format(
								"[SoulvesterLab/client] F -> cast sent, aimed at %s, cooldown left %s",
								v5 and v5.Name or "nobody",
								currentCooldown and string.format("%.1f", currentCooldown.Value) or "?"
							))
						end

						flag = true
						now = tick()
						UseAbility(v4, v4.PrimaryPart.CFrame, v5, nil, module)
						flag = false
					end
				end))

				if not module.HoldProximityAbility then
					table.insert(v3, gui.Ability1.Activated:Connect(function()
						if v4.Parent ~= workspace.InGamePlayers or InputService:IsGameplaySuspended() then
							return
						end

						if flag and tick() - now > 15 then
							flag = false
						end

						if flag or not v4.PrimaryPart then
							return
						end

						flag = true
						now = tick()
						UseAbility(v4, v4.PrimaryPart.CFrame, v5, nil, module)
						flag = false
					end))
				end
			end

			if module.SpecialSetupClient then
				module.SpecialSetupClient(folder)
			end
		end
	end

	GameContext.setUpAbility = SetUpAbility
end

return AbilityController