local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Emit = require(game.ReplicatedStorage.UserGenerated.VFX.Emit)
local folder = game.ReplicatedStorage.Assets.VFX.Sakura.Break
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local scramble = Remotes.Scramble
local ScrambleMotion = require(ReplicatedStorage.Shared.Util.ScrambleMotion)
local DroneVisual = require(script.DroneVisual)
local Hud = require(ReplicatedStorage.Client.Hud)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Save = require(ReplicatedStorage.Shared.Save)
local GameplayBalance = require(ReplicatedStorage.Shared.Flags.GameplayBalance)
local Gears = require(ReplicatedStorage.Data.Gears)
local BossEventFlags = require(ReplicatedStorage.Shared.Flags.BossEventFlags)
local ScrambleBossFlags = require(ReplicatedStorage.Shared.Flags.ScrambleBossFlags)
local RiftEligibility = require(ReplicatedStorage.Shared.Util.RiftEligibility)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local ScramblePickupMotion = require(ReplicatedStorage.Shared.Util.ScramblePickupMotion)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
return {
	Start = function()
		local scramble2 = ReplicatedStorage.Assets.UI:WaitForChild("Scramble")
		local Audio = require(ReplicatedStorage.Shared.Audio)
		local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
		local MusicDirector = require(ReplicatedStorage.Client.MusicDirector)
		local localPlayer = Players.LocalPlayer
		local VaultSequence = require(script.VaultSequence)
		local scramble3 = ReplicatedStorage.Assets.Models:WaitForChild("Scramble")
		local folder2 = Instance.new("Folder")
		folder2.Name = "ScrambleLocalVisuals"
		folder2.Parent = workspace
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local HitFeedback = require(script.HitFeedback)
		local v5 = HitFeedback.new(localPlayer:WaitForChild("PlayerGui"), scramble2.Label)
		local v6 = 0
		local v7 = nil
		local SleepingBrock = require(script.SleepingBrock)
		local v8 = SleepingBrock.new()
		local color = Color3.fromRGB(168, 244, 120)
		local colorSequence = ColorSequence.new(Color3.fromRGB(126, 66, 196), Color3.fromRGB(198, 146, 255))
		local colorSequence2 = ColorSequence.new(Color3.fromRGB(60, 255, 0), Color3.fromRGB(136, 255, 0))
		local color2 = Color3.fromRGB(38, 12, 76)
		local color3 = Color3.fromRGB(228, 200, 255)
		local color4 = Color3.fromRGB(11, 72, 0)
		local color5 = Color3.fromRGB(190, 255, 180)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function questAvailable()
			return v7 ~= nil and v7.Ready == true and v7.Enabled == true and v7.WorldReady == true and workspace:GetServerTimeNow() < (v7.EventEndsAt or 0)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateLive()
			return workspace:GetServerTimeNow() >= Constants.UPDATE_LIVE_AT
		end

		local function make(className: string, parent, items)
			local instance = Instance.new(className)

			for k, item in items do
				instance[k] = item
			end

			instance.Parent = parent
			return instance
		end

		local function label(billboardGui, text: string, p: number)
			local clone = scramble2.Label:Clone()
			clone.AnchorPoint = Vector2.zero
			local uDim = UDim2.fromOffset(0, 0)
			local uDim2 = UDim2.new(1, 0, 0, p)
			clone.Position = uDim
			clone.Size = uDim2
			clone.Text = text
			clone.TextScaled = true
			clone.TextWrapped = false
			clone.Parent = billboardGui
			return clone
		end

		local every = Hud.Every("ExperimentTimer")
		local every2 = Hud.Every("ExperimentTimerValue")
		local fn
		local v9 = 0
		local v10 = nil
		local v11 = -1
		local v12 = nil
		local v13 = -1
		local count = 0

		for _, v14 in every do
			v14.Visible = false
		end

		local function updateExperimentTimer(serverTimeNow: number)
			local window = v7 and v7.Window
			local timerMinSpeed = v7 and v7.TimerMinSpeed
			local v14 = window and window.Active == true
			local endsAt

			if window then
				if v14 then
					endsAt = window.EndsAt
				else
					endsAt = window.NextAt
				end
			else
				endsAt = window
			end

			local eventEndsAt = v7 and v7.EventEndsAt
			local v15 = Save.Peek()
			local speedPower = v15 and v15.SpeedPower
			local v16 = typeof(endsAt) ~= "number" and 0 or endsAt - serverTimeNow
			local visible

			if v7 == nil or v7.Enabled ~= true or v7.Ready ~= true or window == nil or window.Available ~= true or typeof(timerMinSpeed) ~= "number" or not (timerMinSpeed > 0) or not (timerMinSpeed < 1e999) or typeof(speedPower) ~= "number" or not (timerMinSpeed <= speedPower) or not (speedPower < 1e999) or typeof(endsAt) ~= "number" or typeof(eventEndsAt) ~= "number" or not (v14 or endsAt < eventEndsAt) or not (v16 > 0) then
				visible = false
			else
				visible = v14 or v16 <= 600
			end

			local v18

			if visible or localPlayer:GetAttribute("ScrambleCountdownReturningPlayer") ~= true or not ScrambleBossFlags.ContentEnabled:Get() or not ScrambleBossFlags.ScheduleEnabled:Get() or workspace:GetAttribute("Event_ScrambleBoss") == true then
				v18 = 0
			else
				local v19 = ScrambleBossFlags.ScheduleIntervalSeconds:Get()
				v18 = (math.floor(serverTimeNow / v19) + 1) * v19 - serverTimeNow

				if v18 > 0 then
					visible = true
				else
					visible = false
				end
			end

			if visible then
				if v18 > 0 then
					v16 = v18
				end

				local v19 = math.ceil(v16)
				local text = string.format(
					v18 > 0 and "in %dm %ds" or v14 and "Event ends in %dm %ds" or "in %dm %ds",
					v19 // 60,
					v19 % 60
				)

				for _, v21 in every2 do
					if v21.Text ~= text then
						v21.Text = text
					end
				end
			end

			for _, v19 in every do
				if v19.Visible ~= visible then
					v19.Visible = visible
				end
			end
		end

		local GUI = require(ReplicatedStorage.Client.GUI)
		local stolenVaultEvent = GUI.Get("StolenVaultEvent")
		local Interface = require(script.Interface)
		local v14 = Interface.new(function(p, p2, p3)
			return fn(p, p2, p3)
		end)
		local ShopInterface = require(script.ShopInterface)
		local v15 = ShopInterface.new(function(p, p2, p3)
			return fn(p, p2, p3)
		end)
		local MasteryInterface = require(script.MasteryInterface)
		local v16 = MasteryInterface.new(function(p, p2, p3)
			return fn(p, p2, p3)
		end, function()
			v15.Show()
		end)
		local Dialogue = require(script.Dialogue)
		local v17 = Dialogue.new()
		local v18 = false
		local every3 = Hud.Every("QuestlineButton")
		local every4 = Hud.Every("RiftButton")
		local v19 = {}

		local function applyEventButtonStyle(item, flag: boolean)
			local imageLabel = item:FindFirstChild("ImageLabel")
			local uIGradient = item:FindFirstChild("UIGradient")
			local uIStroke = item:FindFirstChild("UIStroke")
			local uIStrokeClr = item:FindFirstChild("UIStrokeClr")

			if imageLabel and imageLabel:IsA("ImageLabel") then
				imageLabel.Image = flag and "rbxassetid://98847011195862" or "rbxassetid://84787104764975"
			end

			if uIGradient and uIGradient:IsA("UIGradient") then
				local color6

				if flag then
					color6 = colorSequence2
				else
					color6 = colorSequence
				end

				uIGradient.Color = color6
			end

			if uIStroke and uIStroke:IsA("UIStroke") then
				local color6

				if flag then
					color6 = color4
				else
					color6 = color2
				end

				uIStroke.Color = color6
			end

			if uIStrokeClr and uIStrokeClr:IsA("UIStroke") then
				local color6

				if flag then
					color6 = color5
				else
					color6 = color3
				end

				uIStrokeClr.Color = color6
			end
		end

		local function scrambleHudRequested()
			if v7 ~= nil then
				return v7.ShowHUD == true
			end

			return workspace:GetAttribute("ScrambleHUDUnlocked") == true and workspace:GetAttribute("ScrambleHUDAwaitingSammyOutro") ~= true
		end

		local function volcanoSpeedReached()
			local v20 = Save.Peek()
			return v20 ~= nil and RiftEligibility.IsEligible(v20.SpeedPower)
		end

		local function riftHudAvailable()
			local v20 = BossEventFlags.ContentEnabled:Get()

			if not v20 then
				return v20
			end

			local v21 = Save.Peek()
			return v21 ~= nil and RiftEligibility.IsEligible(v21.SpeedPower)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateEventButtons()
			local visible

			if v7 == nil then
				if workspace:GetAttribute("ScrambleHUDUnlocked") == true then
					visible = workspace:GetAttribute("ScrambleHUDAwaitingSammyOutro") ~= true
				else
					visible = false
				end
			else
				visible = v7.ShowHUD == true
			end

			if visible then
				if v7 == nil or v7.Ready ~= true or v7.Enabled ~= true or v7.WorldReady ~= true then
					visible = false
				else
					visible = workspace:GetServerTimeNow() < (v7.EventEndsAt or 0)
				end

				if visible then
					local v21 = Save.Peek()

					if v21 == nil then
						visible = false
					else
						visible = RiftEligibility.IsEligible(v21.SpeedPower)
					end
				end
			end

			local visible2 = BossEventFlags.ContentEnabled:Get()

			if visible2 then
				local v22 = Save.Peek()

				if v22 == nil then
					visible2 = false
				else
					visible2 = RiftEligibility.IsEligible(v22.SpeedPower)
				end
			end

			for _, v22 in every3 do
				v22.Visible = visible
			end

			for _, v22 in every4 do
				v22.Visible = visible2
			end
		end

		local function bindEventButtons(items, flag: boolean)
			for _, item in items do
				item.Visible = false
				applyEventButtonStyle(item, flag)
				local badge = item:FindFirstChild("Badge")

				if badge and badge:IsA("GuiObject") then
					badge.Visible = false
				end

				table.insert(v19, ButtonFX(item, 1.08, function()
					if flag then
						local v20

						if v7 == nil then
							if workspace:GetAttribute("ScrambleHUDUnlocked") == true then
								v20 = workspace:GetAttribute("ScrambleHUDAwaitingSammyOutro") ~= true
							else
								v20 = false
							end
						else
							v20 = v7.ShowHUD == true
						end

						if v20 then
							local v21

							if v7 == nil or v7.Ready ~= true or v7.Enabled ~= true or v7.WorldReady ~= true then
								v21 = false
							else
								v21 = workspace:GetServerTimeNow() < (v7.EventEndsAt or 0)
							end

							if v21 then
								local v22 = Save.Peek()
								local v23

								if v22 == nil then
									v23 = false
								else
									v23 = RiftEligibility.IsEligible(v22.SpeedPower)
								end

								if v23 then
									if Tabs.IsActive("DrScrambleEvent") then
										v15.Close()
									elseif updateLive() then
										v16.Toggle()
									else
										v15.Show()
									end
								end
							end
						end
					else
						local v20 = BossEventFlags.ContentEnabled:Get()

						if v20 then
							local v21 = Save.Peek()

							if v21 == nil then
								v20 = false
							else
								v20 = RiftEligibility.IsEligible(v21.SpeedPower)
							end
						end

						if v20 then
							Tabs.Toggle("BossMastery")
						end
					end
				end))
			end
		end

		bindEventButtons(every3, true)
		bindEventButtons(every4, false)
		local Toast = require(ReplicatedStorage.Client.Notifications.Toast)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function toast(text: string)
			Toast.Show({
				Text = text,
				Seconds = 2.5,
				Color = color,
				SingleLine = true,
				Unique = true
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playerRoot(owner)
			local character = owner and owner.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				return (character:FindFirstChild("HumanoidRootPart"))
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function root()
			local character = localPlayer and localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				return (character:FindFirstChild("HumanoidRootPart"))
			end

			return nil
		end

		local function batIn(instance)
			for _, tool in instance:GetChildren() do
				if not tool:IsA("Tool") then
					continue
				end

				if tool:GetAttribute("IsBat") == true then
					return tool
				end

				local gearName = tool:GetAttribute("GearName")
				local v20

				if typeof(gearName) == "string" then
					v20 = Gears.Directory[gearName]
				end

				if v20 and (v20.BatControllerData ~= nil or v20.ToolController == "Slap") then
					return tool
				end
			end

			return nil
		end

		local function droneWithinAutoAttackRadius(position: Vector3)
			for k in v3 do
				local hitbox = k:FindFirstChild("Hitbox")
				local health = hitbox and hitbox:GetAttribute("Health")

				if hitbox and hitbox:IsA("BasePart") and typeof(health) == "number" and health > 0 and (hitbox.Position - position).Magnitude <= 12 then
					return true
				end
			end

			return false
		end

		local function updateAutoAttack()
			if VaultSequence.IsPlaying() or (not v7 or not v7.Window or v7.Window.Active ~= true) then
				return
			end

			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v20 = root() -- equivalent call inferred; original call site unknown

			if not (character and humanoid and v20 and droneWithinAutoAttackRadius(v20.Position)) then
				return
			end

			local v21 = batIn(character)

			if v21 then
				local serverTimeNow = workspace:GetServerTimeNow()
				local cooldownEndTime = v21:GetAttribute("CooldownEndTime")

				if typeof(cooldownEndTime) == "number" then
					v9 = math.max(v9, cooldownEndTime)
				end

				if serverTimeNow < v9 or v21:GetAttribute("CooldownActive") == true then
					return
				end

				v9 = serverTimeNow + math.max(
					GameplayBalance.BatClient.CLIENT_COOLDOWN,
					GameplayBalance.BatServer.PLAYER_COOLDOWN
				)
				v21:Activate()
			else
				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				local v22

				if backpack then
					v22 = batIn(backpack)
				end

				if not v22 then
					return
				end

				humanoid:EquipTool(v22)
				v9 = math.max(v9, workspace:GetServerTimeNow() + 0.1)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeDrop(p: string)
			local v20 = v[p]

			if not v20 then
				return
			end

			if v20.Observer then
				v6 -= 1
			end

			v20.Model:Destroy()
			v[p] = nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setHidden(state, hidden: boolean)
			if state.Hidden == hidden then
				return
			end

			state.Hidden = hidden

			for _, part in state.Parts do
				part.LocalTransparencyModifier = hidden and 1 or 0
			end

			if hidden and state.Floating then
				state.Model:PivotTo(state.BasePivot)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopQuestView(state)
			if state.IdleTrack then
				state.IdleTrack:Stop(0)
				state.IdleTrack:Destroy()
				state.IdleTrack = nil
			end

			if state.Prompt and not state.Floating then
				state.Prompt:Destroy()
			end
		end

		local function updateQuestIdle(state)
			local idleTrack = state.IdleTrack

			if not idleTrack then
				return
			end

			local currentCamera = workspace.CurrentCamera
			local idlePlaying = questAvailable() and not state.Hidden

			if idlePlaying then
				if currentCamera == nil then
					idlePlaying = false
				else
					idlePlaying = state.Model:IsDescendantOf(workspace) and (currentCamera.CFrame.Position - state.Model:GetPivot().Position).Magnitude <= 160
				end
			end

			if state.IdlePlaying == idlePlaying then
				return
			end

			state.IdlePlaying = idlePlaying

			if idlePlaying then
				idleTrack:Play(0.2)
			else
				idleTrack:Stop(0.2)
			end
		end

		local function loadQuestIdle(p, scrambleQuestId: string)
			local animationController = p.Model:FindFirstChildOfClass("AnimationController")
			local animator = animationController and animationController:FindFirstChildOfClass("Animator")
			local scrambleIdle = animationController and animationController:FindFirstChild("ScrambleIdle")

			if animator and scrambleIdle and scrambleIdle:IsA("Animation") then
				task.spawn(function()
					local success, result = pcall(function()
						return animator:LoadAnimation(scrambleIdle)
					end)

					if not success then
						warn("[Scramble] NPC idle could not load:", result)
						return
					end

					if v2[scrambleQuestId] ~= p or not p.Model:IsDescendantOf(workspace) then
						result:Destroy()
						return
					end

					result.Looped = true
					result.Priority = Enum.AnimationPriority.Idle
					p.IdleTrack = result
					updateQuestIdle(p)
				end)
			end
		end

		local function syncQuest()
			if not v7 then
				return
			end

			for k, v20 in v2 do
				local v22 = not questAvailable()

				if k == "LostPart1" or k == "LostPart2" then
					v22 = v22 or v7.State and (v7.State.LostParts[k] or v7.State.Completed)
				end

				setHidden(v20, v22 == true) -- equivalent call inferred; original call site unknown
				updateQuestIdle(v20)

				if v20.Prompt then
					v20.Prompt.Enabled = not v22 and v7.Ready and not (v17.IsPlaying(v20.Model) or VaultSequence.IsPlaying())

					if v7.Interactions and not v20.Floating then
						v20.Prompt.MaxActivationDistance = v7.Interactions.NpcRadius
					end
				end

				if not (k == "ExperimentVault" and v7.State) then
					continue
				end

				local completed = v7.State.Completed

				if v20.Open == completed or VaultSequence.IsPlaying() then
					continue
				end

				VaultSequence.SetOpen(v20.Model, completed)
				v20.Open = completed
			end
		end

		local function registerQuest(model)
			if not (stolenVaultEvent.Parent and model:IsA("Model") and model:IsDescendantOf(workspace)) then
				return
			end

			local scrambleQuestId = model:GetAttribute("ScrambleQuestId")

			if type(scrambleQuestId) ~= "string" then
				return
			end

			local floating = scrambleQuestId == "LostPart1" or scrambleQuestId == "LostPart2"
			local primaryPart = model.PrimaryPart
			local interactionPoint

			if scrambleQuestId == "EscapedExperiment" then
				interactionPoint = model:FindFirstChild("InteractionPoint", true)
			end

			local claimLostPart

			if floating and primaryPart then
				claimLostPart = primaryPart:FindFirstChild("ClaimLostPart")
			end

			local v21 = v2[scrambleQuestId]

			if v21 and v21.Model == model then
				local prompt = v21.Prompt

				if scrambleQuestId == "EscapedExperiment" then
					if prompt and prompt.Parent == interactionPoint and prompt:IsDescendantOf(model) then
						return
					end
				elseif not floating or prompt and prompt == claimLostPart and prompt:IsDescendantOf(model) then
					return
				end
			end

			if v21 then
				stopQuestView(v21) -- equivalent call inferred; original call site unknown
				v2[scrambleQuestId] = nil
			end

			if not (primaryPart and primaryPart:IsDescendantOf(model)) or scrambleQuestId == "EscapedExperiment" and not (interactionPoint and interactionPoint:IsA("Attachment") and interactionPoint.Parent and interactionPoint.Parent:IsA("BasePart")) then
				return
			end

			if floating and not (claimLostPart and claimLostPart:IsA("ProximityPrompt")) then
				return
			end

			local parts = {}

			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					table.insert(parts, part)
				end
			end

			local v22 = {
				Model = model,
				Parts = parts,
				BasePivot = model:GetPivot(),
				Floating = floating,
				Phase = scrambleQuestId == "LostPart1" and 0 or 3.141592653589793,
				Prompt = claimLostPart
			}
			v2[scrambleQuestId] = v22

			if scrambleQuestId == "EscapedExperiment" then
				loadQuestIdle(v22, "EscapedExperiment")
			end

			if scrambleQuestId == "EscapedExperiment" and interactionPoint then
				local proximityPrompt = Instance.new("ProximityPrompt")

				for k, v23 in {
					Name = "ScrambleTalk",
					ActionText = "Talk",
					ObjectText = "Escaped Experiment",
					HoldDuration = 0,
					Enabled = false,
					RequiresLineOfSight = true
				} do
					proximityPrompt[k] = v23
				end

				proximityPrompt.Parent = interactionPoint
				v22.Prompt = proximityPrompt
				proximityPrompt.Triggered:Connect(function()
					if v17.IsPlaying(model) or VaultSequence.IsPlaying() then
						return
					end

					local discovered = v7 and v7.State and v7.State.Discovered
					local v23 = fn("Discover")

					if v23 and v23.Ok and v7 and v7.State then
						if v7.State.TotalParts == 5 or v7.State.Completed or discovered and not v18 then
							v14.ShowVault()
							return
						end

						v18 = true
						v14.Close()
						v15.Close()
						v17.Start(model, proximityPrompt, function()
							v18 = false
							v14.ShowVault()
						end)
					end
				end)
			end

			syncQuest()
		end

		local v20 = false

		local function fn2()
			updateEventButtons() -- equivalent call inferred; original call site unknown
			updateExperimentTimer(workspace:GetServerTimeNow())

			if v7 then
				v14.Update(v7)
				v15.Update(v7)

				if updateLive() then
					v16.Update(v7)
					v20 = true
				end
			end
		end

		local function addDrops(drops)
			for _, item in drops do
				if v[item.Id] or workspace:GetServerTimeNow() >= item.ExpiresAt then
					continue
				end

				local observer

				if item.OwnerUserId == nil then
					observer = false
				else
					observer = item.OwnerUserId ~= localPlayer.UserId
				end

				local currentCamera = workspace.CurrentCamera

				if not (not observer or not (v6 >= 64) and currentCamera and not ((currentCamera.CFrame.Position - item.Origin).Magnitude > 180)) then
					continue
				end

				local scrambleCurrency

				if item.Kind == "Samples" then
					scrambleCurrency = ReplicatedStorage.Assets:FindFirstChild("ScrambleCurrency")
				elseif item.Kind == "Part" then
					scrambleCurrency = scramble3.Parts:FindFirstChild(item.PartId)
				end

				if not scrambleCurrency then
					continue
				end

				local clone = scrambleCurrency:Clone()
				local visualScale = item.VisualScale or 1
				local parts = {}
				local billboardGui = nil

				if clone:IsA("BasePart") then
					clone.Size *= visualScale
					billboardGui = clone:FindFirstChildWhichIsA("BillboardGui")

					if not billboardGui then
						clone:Destroy()
						continue
					end

					billboardGui.Adornee = clone
					local size = billboardGui.Size
					billboardGui.Size = UDim2.new(
						size.X.Scale * visualScale,
						size.X.Offset * visualScale,
						size.Y.Scale * visualScale,
						size.Y.Offset * visualScale
					)
					table.insert(parts, clone)
				else
					clone:ScaleTo(clone:GetScale() * visualScale)

					for _, part in clone:GetDescendants() do
						if part:IsA("BasePart") then
							table.insert(parts, part)
						end
					end
				end

				for _, v23 in parts do
					v23.Anchored = true
					v23.CanCollide = false
					v23.CanTouch = false
					v23.CanQuery = false
				end

				clone:PivotTo(CFrame.new(item.Origin))
				clone.Parent = folder2
				local now = os.clock()
				item.Model = clone
				item.SpawnedAt = now
				item.NextTry = 0
				item.Parts = parts
				item.Observer = observer
				local owner

				if observer then
					owner = Players:GetPlayerByUserId(item.OwnerUserId)
				else
					owner = localPlayer
				end

				item.Owner = owner

				if observer then
					v6 += 1
				end

				local magnetDelay

				if item.MagnetAt then
					magnetDelay = item.MagnetAt - item.CreatedAt
				end

				item.MagnetDelay = magnetDelay
				v[item.Id] = item

				if item.Kind == "Samples" then
					item.Billboard = billboardGui
				else
					local primaryPart = clone.PrimaryPart
					local v25 = {
						Size = UDim2.fromOffset(160, 32),
						StudsOffset = createVector(0, 2, 0),
						AlwaysOnTop = false,
						MaxDistance = 100
					}
					local billboardGui2 = Instance.new("BillboardGui")

					for k, v26 in v25 do
						billboardGui2[k] = v26
					end

					billboardGui2.Parent = primaryPart
					item.Billboard = billboardGui2
					label(billboardGui2, "⚙️ DRONE PART", 32)
				end

				if not item.Hidden then
					continue
				end

				for _, v25 in parts do
					v25.LocalTransparencyModifier = 1
				end

				if item.Billboard then
					item.Billboard.Enabled = false
				end

				item.Arrived = true
			end
		end

		local function onOnClientEvent(data)
			if not data then
				return
			end

			if data.Drones and v10 then
				v10.Apply(data.Drones)
			end

			local revision = data.Revision

			if typeof(revision) ~= "number" then
				return
			end

			if v11 < revision then
				v11 = revision
				v12 = {
					State = data.State,
					Ready = data.Ready
				}
			end

			if not data.Patch and v13 < revision then
				v13 = revision
				v7 = data

				if data.Drops then
					addDrops(data.Drops)
				end
			end

			if not (v7 and v12) then
				return
			end

			v7.State = v12.State
			v7.Ready = v12.Ready
			local v21

			if v7 == nil or v7.Ready ~= true or v7.Enabled ~= true or v7.WorldReady ~= true then
				v21 = false
			else
				v21 = workspace:GetServerTimeNow() < (v7.EventEndsAt or 0)
			end

			if not v21 then
				VaultSequence.Stop(false)
				v14.Close()
			end

			fn2()
			syncQuest()
		end

		local flag = false

		fn = function(p: string, p2, p3)
			if flag then
				return nil
			end

			flag = true
			local success, result = pcall(function()
				return scramble.Request:InvokeServer(p, p2, p3)
			end)
			flag = false

			if success and result then
				onOnClientEvent(result.Snapshot)
				return result
			else
				return nil
			end
		end

		local function registerDrone(model)
			if not model:IsA("Model") or v3[model] or not model:IsDescendantOf(workspace) then
				return
			end

			local hitbox = model:FindFirstChild("Hitbox")
			local flight = ScrambleMotion.Read(model)

			if not (hitbox and hitbox:IsA("BasePart") and flight) then
				return
			end

			local parts = {}
			local offsets = {}
			local animated

			if model:GetAttribute("ScrambleAnimatedRig") == true then
				local child = scramble3.Drones:FindFirstChild(model:GetAttribute("ScrambleTier"))

				if not child then
					return
				end

				animated = DroneVisual.new(model, child, folder2)
			end

			local root2

			if animated then
				root2 = animated.Root
			else
				root2 = hitbox
			end

			for _, part in model:GetDescendants() do
				if not (part:IsA("BasePart") and part ~= hitbox) then
					continue
				end

				table.insert(parts, part)
				table.insert(offsets, flight.Home:ToObjectSpace(part.CFrame))

				if part.Name == "Body" then
					root2 = part
				end
			end

			local v24

			if animated then
				v24 = animated.Rig
			else
				v24 = model
			end

			local boundingBox, v25 = v24:GetBoundingBox()
			local midpoint = (math.abs(boundingBox.RightVector.Y) * v25.X + math.abs(boundingBox.UpVector.Y) * v25.Y + math.abs(boundingBox.LookVector.Y) * v25.Z) / 2
			local v27 = boundingBox.Position.Y + midpoint - root2.Position.Y
			local v28 = {
				Name = "ScrambleHealth",
				Adornee = root2,
				Size = UDim2.fromScale(10, 2.2),
				StudsOffsetWorldSpace = Vector3.new(0, v27 + 2 + 1.1, 0),
				MaxDistance = 100,
				AlwaysOnTop = true,
				LightInfluence = 0
			}
			local billboardGui = Instance.new("BillboardGui")

			for k, v29 in v28 do
				billboardGui[k] = v29
			end

			billboardGui.Parent = root2
			local v29 = label(billboardGui, "DR. SCRAMBLE EXPERIMENT", 26)
			v29.Size = UDim2.fromScale(1, 0.45)
			v29.TextScaled = true
			local clone = scramble2.Progress:Clone()
			local zero = Vector2.zero
			clone.Name = "HealthProgress"
			clone.AnchorPoint = zero
			local uDim = UDim2.fromScale(0.05, 0.53)
			local uDim2 = UDim2.fromScale(0.9, 0.41)
			clone.Position = uDim
			clone.Size = uDim2
			clone.Parent = billboardGui
			local v30 = {
				Billboard = billboardGui,
				Flight = flight,
				Parts = parts,
				Offsets = offsets,
				Tween = nil,
				Animated = animated
			}

			local function update(flag2: boolean?)
				local health = hitbox:GetAttribute("Health") or 0
				local maxHealth = hitbox:GetAttribute("MaxHealth") or 1
				local v31 = math.clamp(health / math.max(maxHealth, 1), 0, 1)
				clone.TextLabel.Text = string.format(
					"%d / %d HP",
					math.max(0, (math.ceil(health))),
					(math.max(1, (math.ceil(maxHealth))))
				)
				clone.Fill.Visible = v31 > 0

				if v30.Tween then
					v30.Tween:Cancel()
				end

				if flag2 then
					clone.Fill.Size = UDim2.fromScale(v31, 1)
					return
				end

				v30.Tween = TweenService:Create(clone.Fill, TweenInfo.new(0.15), {
					Size = UDim2.fromScale(v31, 1)
				})
				v30.Tween:Play()
			end

			v30.Connection = hitbox:GetAttributeChangedSignal("Health"):Connect(update)
			v30.Id = model:GetAttribute("ScrambleDroneId")
			v30.DamageHeight = math.max(2, v27 * 0.85)
			v3[model] = v30
			v4[v30.Id] = v30
			update(true)
		end

		local function burst(position: Vector3, color6: Color3, value: number?)
			local part = Instance.new("Part")

			for k, v22 in {
				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
				Transparency = 1,
				Size = createVector(1, 1, 1),
				Position = position
			} do
				part[k] = v22
			end

			part.Parent = folder2
			local v22 = {
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new(color6),
				Rate = 0,
				Lifetime = NumberRange.new(0.35, 0.9),
				Speed = NumberRange.new(5, 12),
				SpreadAngle = Vector2.new(180, 180),
				LightEmission = 0.6,
				Size = NumberSequence.new(0.5)
			}
			local particleEmitter = Instance.new("ParticleEmitter")

			for k, v23 in v22 do
				particleEmitter[k] = v23
			end

			particleEmitter.Parent = part
			particleEmitter:Emit(value or 24)
			Debris:AddItem(part, 1.5)
		end

		local function droneBreakBurst(vector2: Vector3)
			local part = Instance.new("Part")

			for k, v22 in {
				Name = "ScrambleDroneBreak",
				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
				CastShadow = false,
				Transparency = 1,
				Size = createVector(1, 1, 1),
				Position = vector2
			} do
				part[k] = v22
			end

			part.Parent = folder2

			for _, emitter in folder:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local emitCount = emitter:GetAttribute("EmitCount")

				if typeof(emitCount) ~= "number" then
					emitCount = emitter.Rate
				end

				if not (emitCount > 0) then
					continue
				end

				local clone = emitter:Clone()
				clone.Enabled = false
				clone.Color = ColorSequence.new(color, Color3.fromRGB(225, 255, 200))
				clone.Parent = part
			end

			Debris:AddItem(part, Emit(part) + 0.1)
		end

		local function effect(p: string, vector2: Vector3, data)
			if p == "Hit" then
				local v21

				if type(data) == "table" then
					v21 = v4[data.DroneId]
				else
					v21 = false
				end

				if v21 and v21.Animated and type(data.Amount) == "number" and data.Amount > 0 then
					v21.Animated:ReceiveHit(data.Motion)
					v5.Hit(
						v21.Animated.Rig,
						v21.Animated.Root.Position + Vector3.new(0, v21.DamageHeight, 0),
						data.Amount
					)
				end
			elseif p == "Break" then
				droneBreakBurst(vector2)
				Audio.Play(ReplicatedStorage.Assets.Sounds.LightVsDarknessSounds.CollectNormalRing, vector2, {
					Volume = 0.55
				})
			elseif p == "Rare" then
				toast("🚨 A FORBIDDEN EXPERIMENT HAS APPEARED!") -- equivalent call inferred; original call site unknown
			elseif p == "Samples" then
				toast("+" .. tostring(data.Amount) .. " 🧪 Samples") -- equivalent call inferred; original call site unknown
			elseif p == "VaultStart" then
				v14.Close()
				v15.Close()
				v17.Close()
				local experimentVault = v2.ExperimentVault

				if experimentVault then
					VaultSequence.Start(experimentVault.Model, data)
				end

				syncQuest()
			elseif p == "VaultFinish" then
				VaultSequence.Finish(data.Id, data.Granted == true)
				local experimentVault = v2.ExperimentVault

				if experimentVault then
					experimentVault.Open = nil
				end
			end
		end

		scramble.State.OnClientEvent:Connect(onOnClientEvent)
		scramble.Drops.OnClientEvent:Connect(addDrops)
		scramble.RemoveDrops.OnClientEvent:Connect(function(items)
			for _, item in items do
				removeDrop(item) -- equivalent call inferred; original call site unknown
			end
		end)
		scramble.Effect.OnClientEvent:Connect(effect)
		CollectionService:GetInstanceAddedSignal("ScrambleQuest"):Connect(registerQuest)
		CollectionService:GetInstanceRemovedSignal("ScrambleQuest"):Connect(function(p)
			for k, v21 in v2 do
				if v21.Model ~= p then
					continue
				end

				stopQuestView(v21) -- equivalent call inferred; original call site unknown
				v2[k] = nil
			end
		end)

		local function removeDrone(p)
			local v21 = v3[p]

			if v21 then
				v21.Connection:Disconnect()

				if v21.Tween then
					v21.Tween:Cancel()
				end

				v21.Billboard:Destroy()

				if v21.Animated then
					v21.Animated:Destroy()
				end

				v4[v21.Id] = nil
				v3[p] = nil
			end
		end

		local PersonalDrones = require(script.PersonalDrones)
		v10 = PersonalDrones.new(folder2, registerDrone, removeDrone)
		local onClientEventConnection = scramble.Drones.OnClientEvent:Connect(v10.Apply)

		for _, v21 in CollectionService:GetTagged("ScrambleQuest") do
			registerQuest(v21)
		end

		local part = Instance.new("Part")

		for k, v21 in {
			Anchored = true,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			Transparency = 1,
			Size = createVector(30, 8, 30),
			Position = createVector(0, -1000, 0)
		} do
			part[k] = v21
		end

		part.Parent = folder2
		local v21 = {
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Enabled = false,
			Color = ColorSequence.new(color),
			Rate = 8,
			Lifetime = NumberRange.new(1, 2),
			Speed = NumberRange.new(0.1, 0.5),
			Size = NumberSequence.new(0.15),
			Transparency = NumberSequence.new(0.65),
			SpreadAngle = Vector2.new(180, 180)
		}
		local particleEmitter = Instance.new("ParticleEmitter")

		for k, v22 in v21 do
			particleEmitter[k] = v22
		end

		particleEmitter.Parent = part

		local function inEventBiome(position: Vector3)
			if not (v7 and v7.Window.Active) then
				return false
			end

			local world = workspace:FindFirstChild("World")
			local areas = world and world:FindFirstChild("Areas")
			local guardAreas = areas and areas:FindFirstChild("GuardAreas")

			if not guardAreas then
				return false
			end

			for _, childName in v7.Areas or {} do
				local child = guardAreas:FindFirstChild(childName)
				local bounds = child and child:FindFirstChild("Bounds")

				if not (bounds and bounds:IsA("BasePart") and child:GetAttribute("ZoneHidden") ~= true) then
					continue
				end

				local pointToObjectSpace = bounds.CFrame:PointToObjectSpace(position)
				local halfSize = bounds.Size / 2

				if math.abs(pointToObjectSpace.X) < halfSize.X and math.abs(pointToObjectSpace.Z) < halfSize.Z and math.abs(pointToObjectSpace.Y) < 35 then
					return true
				end
			end

			return false
		end

		local v22 = false
		local clone = nil
		local v23 = nil

		local function updateOutbreakPresentation()
			local scrambleOutbreakEndsAt = workspace:GetAttribute("ScrambleOutbreakEndsAt")
			local v24 = root() -- equivalent call inferred; original call site unknown
			local v25

			if workspace:GetAttribute("ScrambleOutbreakActive") == true and type(scrambleOutbreakEndsAt) == "number" and workspace:GetServerTimeNow() < scrambleOutbreakEndsAt and v24 ~= nil then
				v25 = inEventBiome(v24.Position)
			else
				v25 = false
			end

			local drScrambleVFX = scramble3:FindFirstChild("DrScrambleVFX")

			if clone and (not v25 or v23 ~= drScrambleVFX) then
				clone:Destroy()
				clone = nil
				v23 = nil
			end

			if v25 and drScrambleVFX and not clone then
				v23 = drScrambleVFX
				clone = drScrambleVFX:Clone()
				clone.Parent = folder2
			end

			if v25 == v22 then
				return
			end

			v22 = v25
			MusicDirector.SetScrambleActive(v25)

			if v25 and LightingController.Presets.DrScramble then
				LightingController.SetLayer("DrScrambleOutbreak", "DrScramble", 140, 1)
			else
				LightingController.ClearLayer("DrScrambleOutbreak", 1)
			end
		end

		local v24 = 0
		local v25 = 0
		local v26 = {}
		local v27 = {}
		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			v24 += dt
			local currentCamera = workspace.CurrentCamera
			local now = os.clock()
			local serverTimeNow = workspace:GetServerTimeNow()
			v5.Step(dt)
			table.clear(v26)
			table.clear(v27)

			for k, v28 in v3 do
				local v29

				if k.Parent == nil or currentCamera == nil then
					v29 = false
				else
					v29 = (currentCamera.CFrame.Position - k:GetPivot().Position).Magnitude < 180
				end

				if v28.Animated then
					local v30 = v28.Animated:Step(v28.Flight, serverTimeNow, v29)
					v28.Billboard.Enabled = v29 and (not v28.Animated.State or v28.Animated.State.Name ~= "Death")

					if v29 and (not v28.Animated.State or v28.Animated.State.Name ~= "Death") then
						table.insert(v26, v28.Animated.Root)
						table.insert(v27, v30)
					end
				elseif v29 then
					local pose = ScrambleMotion.Pose(v28.Flight, serverTimeNow)

					for k2, part2 in v28.Parts do
						table.insert(v26, part2)
						table.insert(v27, pose * v28.Offsets[k2])
					end
				end
			end

			if #v26 > 0 then
				workspace:BulkMoveTo(v26, v27, Enum.BulkMoveMode.FireCFrameChanged)
			end

			if v24 >= 0.03333333333333333 then
				v24 %= 0.03333333333333333

				for _, v28 in v2 do
					if not v28.Floating or v28.Hidden or not currentCamera or not ((currentCamera.CFrame.Position - v28.BasePivot.Position).Magnitude < 100) then
						continue
					end

					v28.Model:PivotTo(CFrame.new(0, math.sin(now * 1.8 + v28.Phase) * 0.25 + 1.4, 0) * v28.BasePivot * CFrame.Angles(
						0,
						now * 0.5,
						0
					))
				end
			end

			for k, v28 in v do
				if v28.Arrived then
					continue
				end

				local v29 = now - v28.SpawnedAt
				local v30 = playerRoot(v28.Owner) -- equivalent call inferred; original call site unknown

				if v28.MagnetDelay and v28.MagnetDelay <= v29 and v30 then
					v28.MagnetStarted = v28.MagnetStarted or now
					local v31 = math.clamp((now - v28.MagnetStarted) / ScramblePickupMotion.MagnetSeconds, 0, 1)
					local magnetPosition = ScramblePickupMotion.MagnetPosition(v28.Position, v30.Position, v31)
					v28.Model:PivotTo(CFrame.new(magnetPosition) * CFrame.Angles(0, v29 * 8, 0))

					if v31 == 1 then
						v28.Arrived = true

						if v28.Observer then
							removeDrop(k) -- equivalent call inferred; original call site unknown
						else
							for _, part2 in v28.Parts do
								part2.LocalTransparencyModifier = 1
							end

							if v28.Billboard then
								v28.Billboard.Enabled = false
							end

							if now - v25 > 0.09 then
								v25 = now
								burst(v30.Position, color, 6)
								Audio.Play(
									ReplicatedStorage.Assets.Sounds.LightVsDarknessSounds.CollectNormalRing,
									v30,
									{
										Volume = 0.35
									}
								)
							end
						end
					end
				elseif not v28.Landed then
					local groundPosition = ScramblePickupMotion.GroundPosition(v28.Origin, v28.Position, v29)
					v28.Model:PivotTo(CFrame.new(groundPosition) * CFrame.Angles(
						0,
						math.min(v29, ScramblePickupMotion.MagnetDelay) * 4,
						0
					))

					if ScramblePickupMotion.MagnetDelay <= v29 then
						v28.Landed = true
					end
				end
			end
		end)
		Save.WatchFields("SpeedPower", updateEventButtons)
		BossEventFlags.ContentEnabled.Changed:Connect(updateEventButtons)
		RiftFlags.SpeedPowerRequirement.Changed:Connect(updateEventButtons)
		workspace:GetAttributeChangedSignal("ScrambleHUDUnlocked"):Connect(updateEventButtons)
		workspace:GetAttributeChangedSignal("ScrambleHUDAwaitingSammyOutro"):Connect(updateEventButtons)
		task.spawn(function()
			local v28 = count

			while stolenVaultEvent.Parent and v28 == count do
				local v29 = root() -- equivalent call inferred; original call site unknown
				local serverTimeNow = workspace:GetServerTimeNow()
				local v30 = {}

				for k, v31 in v do
					if v31.ExpiresAt <= serverTimeNow or v31.Observer and os.clock() - v31.SpawnedAt > 8 then
						removeDrop(k) -- equivalent call inferred; original call site unknown
					elseif not v31.Observer and v29 and #v30 < 8 and v31.CollectAfter <= serverTimeNow and os.clock() >= v31.NextTry then
						local v32

						if v31.MagnetAt then
							v32 = v31.Arrived
						else
							v32 = (v29.Position - v31.Position).Magnitude <= (v31.Radius or 0)
						end

						if v32 then
							v31.NextTry = os.clock() + 1
							table.insert(v30, k)
						end
					end
				end

				if #v30 > 0 then
					scramble.Collect:FireServer(v30)
				end

				if v29 then
					part.Position = v29.Position
					particleEmitter.Enabled = inEventBiome(v29.Position)
				else
					particleEmitter.Enabled = false
				end

				updateOutbreakPresentation()
				v10.Tick()
				updateAutoAttack()
				v8.Tick(questAvailable())

				for _, v32 in CollectionService:GetTagged("ScrambleQuest") do
					registerQuest(v32)
				end

				syncQuest()
				updateEventButtons() -- equivalent call inferred; original call site unknown
				v17.Tick(questAvailable())
				v14.Tick(serverTimeNow)
				v15.Tick(serverTimeNow)
				updateExperimentTimer(serverTimeNow)

				if v7 and not v20 and updateLive() then
					fn2()
				end

				task.wait(0.2)
			end
		end)
		task.spawn(function()
			while stolenVaultEvent.Parent and not (v7 and v7.Ready and v10.Ready()) do
				local success, result = pcall(function()
					return scramble.Request:InvokeServer("Snapshot")
				end)

				if success then
					onOnClientEvent(result)
				end

				if not (v7 and v7.Ready and v10.Ready()) then
					task.wait(2)
				end
			end
		end)
		stolenVaultEvent.Destroying:Connect(function()
			VaultSequence.Stop(false)
			MusicDirector.SetScrambleActive(false)
			LightingController.ClearLayer("DrScrambleOutbreak", 1)

			for _, v28 in v19 do
				v28()
			end

			for _, v28 in every3 do
				v28.Visible = false
			end

			for _, v28 in every4 do
				v28.Visible = false
			end

			for _, v28 in v2 do
				stopQuestView(v28) -- equivalent call inferred; original call site unknown
			end

			table.clear(v2)

			for _, v28 in every do
				v28.Visible = false
			end

			count += 1
			v17.Destroy()
			v14.Destroy()
			v15.Destroy()
			v16.Destroy()
			v8.Destroy()
			onClientEventConnection:Disconnect()
			v10.Destroy()
			renderSteppedConnection:Disconnect()
			v5.Destroy()

			for _, v28 in v3 do
				v28.Connection:Disconnect()

				if v28.Tween then
					v28.Tween:Cancel()
				end

				v28.Billboard:Destroy()

				if v28.Animated then
					v28.Animated:Destroy()
				end
			end

			folder2:Destroy()
		end)
	end
}