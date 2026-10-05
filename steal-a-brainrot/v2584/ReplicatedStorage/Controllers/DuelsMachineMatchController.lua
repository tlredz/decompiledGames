local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Packages.FFlags)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local DuelsModes = require(ReplicatedStorage.Datas.DuelsModes)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local DuelsFlags = require(ReplicatedStorage.Shared.Flags.DuelsFlags)
local Animals = require(ReplicatedStorage.Shared.Animals)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
require(ReplicatedStorage.Shared.Updates)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local duelsMachineSession = playerGui:WaitForChild("DuelsMachineSession").DuelsMachineSession
local duelsMachineTopFrame = playerGui:WaitForChild("DuelsMachineTopFrame").DuelsMachineTopFrame
local duelsMachineAnimation = playerGui:WaitForChild("DuelsMachineAnimation").DuelsMachineAnimation
local duelsMachineVoteFrame = playerGui:WaitForChild("DuelsMachineTopFrame").DuelsMachineVoteFrame
local v = playerGui:WaitForChild("DuelsMachineTopFrame").Return
local tip = playerGui:WaitForChild("DuelsMachineTopFrame").Tip
local flag = false
return {
	Start = function(_)
		if not ServerData.IsDuelsServer() then
			return
		end

		local function updateButtonPosition()
			if not localPlayer:GetAttribute("__duels_tp_back") then
				Spr.target(v, 0.9, 4, {
					Position = UDim2.fromScale(0.5, 1.2)
				})
				return
			end

			v.Visible = true
			Spr.target(v, 0.9, 4, {
				Position = UDim2.fromScale(0.5, 0.9)
			})
			local notification = playerGui:WaitForChild("Notification"):WaitForChild("Notification")
			notification.AnchorPoint = Vector2.new(0.5, 0.5)
			notification.Position = UDim2.fromScale(0.5, 0.57)
		end

		v.Activated:Connect(function()
			if not ConfirmationController:Show(
				"This will send you to a public server. Continue?",
				3600,
				"DuelsTeleportBackTemplate"
			) then
				return
			end

			Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/TeleportBack"):FireServer()
		end)
		localPlayer:GetAttributeChangedSignal("__duels_tp_back"):Connect(updateButtonPosition)
		task.spawn(updateButtonPosition)
		Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/WinnerScreen").OnClientEvent:Connect(function(_) end)
		local duelsRounds = ReplicatorClient.get("DuelsRounds")
		local duelsModeVote = ReplicatorClient.get("DuelsModeVote")

		if not DuelsFlags.PreTeleportSelection:Get() then
			ReplicatorClient.get("SelectBrainrots")
			local v2 = InterfaceController:Register("DuelsMachineSession", duelsMachineSession, "TopQuint")
			v2:AttachCloseButton(duelsMachineSession.Header.Close)
			v2:Close()
			local v3 = Synchronizer:Wait(localPlayer)
			local maid = Trove.new()

			local function updateDuelsSelectionUI()
				if workspace:GetAttribute("DuelsSelectBrainrotActive") then
					InterfaceController:SetState("DuelsMachineSession", true)
					local selectBrainrots = ReplicatorClient.get("SelectBrainrots")
					selectBrainrots:WaitForLoaded()
					local maid2 = maid:Extend()

					local function updateReadyButtonState()
						local v4 = selectBrainrots:TryIndex({ "lastChange" }) or 0
						local v5 = selectBrainrots:TryIndex({ "players" }) or {}
						local v6 = true

						for _, v8 in v5 do
							if v8.brainrot then
								continue
							end

							v6 = false
							break
						end

						local v8 = v5[tostring(localPlayer.UserId)]
						local v9 = v4 + 5 - workspace:GetServerTimeNow()
						local target = Spr.target
						local ready = duelsMachineSession.Other.Ready
						local backgroundColor

						if v9 <= 0 and v6 and next(v5) and not (v8 and v8.accepted) then
							backgroundColor = Color3.fromRGB(81, 158, 86)
						else
							backgroundColor = Color3.fromRGB(112, 112, 112)
						end

						target(ready, 1, 5, {
							BackgroundColor3 = backgroundColor
						})
					end

					maid:Add(selectBrainrots:Observe({ "lastChange" }, function(p: number)
						maid2:Clean()

						if p == nil then
							return
						end

						maid2:Add(Timer.Simple(0.1, function()
							local serverTimeNow = workspace:GetServerTimeNow()
							local v4 = p + 5 - serverTimeNow
							duelsMachineSession.Other.Timer.Text = v4 <= 0 and "" or `⏰{math.floor(v4 * 10) / 10}s Left`
							updateReadyButtonState()
						end, true))
					end))
					local values = {}
					local v4 = {}
					maid:Add(selectBrainrots:Observe({ "players" }, function(items)
						local flag2 = true

						for _, item in items do
							if item.ready and item.brainrot then
								continue
							end

							flag2 = false
							break
						end

						if flag2 then
							duelsMachineSession.Other.Ready.Txt.Text = "ACCEPT"
						else
							duelsMachineSession.Other.Ready.Txt.Text = "READY"
						end

						local function updateFrame(k, item, p)
							local item2 = p.Item
							p.Frame.Ready.Text = item.accepted and "ACCEPTED" or "READY"
							p.Frame.Ready.Visible = item.ready
							local target = Spr.target
							local uIStroke = item2.UIStroke
							local color

							if item.ready then
								color = Color3.fromRGB(0, 255, 0)
							else
								color = Color3.fromRGB(0, 0, 0)
							end

							target(uIStroke, 1, 5, {
								Color = color
							})
							local formatted = `{item.indexOnPlot}_{item.brainrot and item.brainrot.UUID}`

							if values[k] == formatted then
								return
							end

							values[k] = formatted
							v4[k]:Clean()
							local brainrot = item.brainrot

							if brainrot then
								v4[k]:Add(BrainrotCard.ObserveOneOfOne(brainrot, function(flag3: boolean)
									BrainrotCard.ApplyOneOfOne(p, flag3, false)
								end))
								item2.Title.Text = Animals:GetDisplayName(brainrot.Index)
								item2.Cash.Text = `${NumberUtils:ToString(Animals:GetGeneration(brainrot.Index, brainrot.Mutation, brainrot.Traits))}/s`
								local v10 = Animals:AttachOnViewportWithOptimizations(
									brainrot.Index,
									item2.ViewportFrame,
									nil,
									brainrot.Mutation
								)

								if v10 then
									v4[k]:Add(v10)
								end

								for _, name in brainrot.Traits or {} do
									local trait = Traits[name]

									if not trait then
										continue
									end

									local clone = v4[k]:Clone(item2.Traits.Template)
									clone.Name = name
									clone.Visible = true
									clone.Image = trait.Icon
									clone.Parent = item2.Traits
								end
							else
								BrainrotCard.ApplyOneOfOne(p, false, false)
								item2.Title.Text = "Waiting for player to select..."
								item2.Cash.Text = ""
							end
						end

						for k, item in items do
							if not v4[k] then
								v4[k] = maid:Extend()
							end

							if k == tostring(localPlayer.UserId) then
								duelsMachineSession.Your.Frame.Ready.Text = item.accepted and "ACCEPTED" or "READY"
								duelsMachineSession.Your.Frame.Ready.Visible = item.ready
								duelsMachineSession.Main.Visible = flag2
								duelsMachineSession.ScrollingFrame.Visible = not flag2

								if flag2 then
									updateFrame(k, item, duelsMachineSession.Main)
								end
							else
								local playerByUserId = Players:GetPlayerByUserId((tonumber(k)))
								duelsMachineSession.Other.Frame.Username.Text = `@{not playerByUserId and "???" or playerByUserId.Name}'s Offer`
								duelsMachineSession.Other.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={k}&w=100&h=100`
								updateFrame(k, item, duelsMachineSession.Other)
							end
						end
					end))
					local maid3 = maid:Extend()
					maid:Add(v3:OnChanged("AnimalPodiums", function(items)
						maid3:Clean()

						for k, item in items do
							if typeof(item) ~= "table" or item.Machine then
								continue
							end

							local clone = maid3:Clone(duelsMachineSession.ScrollingFrame.Template)
							clone.Visible = true
							BrainrotCard.Render(clone, item, maid3, "Duels")
							maid3:Add(BrainrotCard.ObserveOneOfOne(item, function(flag2: boolean)
								BrainrotCard.ApplyOneOfOne(clone, flag2, false)
							end))
							clone.Parent = duelsMachineSession.ScrollingFrame
							local v6 = k
							local v7 = item
							maid3:Add(clone.Spacer.Activated:Connect(function()
								SoundController:PlaySound("Sounds.Sfx.Activated")
								Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Select"):FireServer(v6, v7)
							end))
							local flag2 = true
							local v8 = `{k}_{item.UUID}`
							local v9 = clone
							maid3:Add(selectBrainrots:Observe({ "players", (tostring(localPlayer.UserId)) }, function(p)
								local v10 = v8 == `{p.indexOnPlot}_{p.brainrot and p.brainrot.UUID}`
								local color

								if v10 then
									color = Color3.fromRGB(15, 50, 15)
								else
									color = Color3.fromRGB(35, 45, 50)
								end

								local color2

								if v10 then
									color2 = Color3.fromRGB(0, 255, 0)
								else
									color2 = Color3.fromRGB(0, 0, 0)
								end

								if flag2 then
									flag2 = false
									v9.Spacer.BackgroundColor3 = color
									v9.Spacer.UIStroke.Color = color2
								else
									Spr.target(v9.Spacer, 1, 5, {
										BackgroundColor3 = color
									})
									Spr.target(v9.Spacer.UIStroke, 1, 5, {
										Color = color2
									})
								end
							end))
						end
					end, true))
				else
					InterfaceController:SetState("DuelsMachineSession", false)
					maid:Clean()
				end
			end

			workspace:GetAttributeChangedSignal("DuelsSelectBrainrotActive"):Connect(function()
				maid:Add(task.spawn(updateDuelsSelectionUI))
			end)
			maid:Add(task.spawn(updateDuelsSelectionUI))

			local function updateDuelsMode()
				local duelsSelectedMode = workspace:GetAttribute("DuelsSelectedMode")

				if duelsSelectedMode and DuelsModes[duelsSelectedMode] then
					duelsMachineSession.Mode.Text = `<font color="#{DuelsModes[duelsSelectedMode].Color:ToHex()}">{duelsSelectedMode}</font> mode selected!`
				else
					duelsMachineSession.Mode.Text = ""
				end
			end

			workspace:GetAttributeChangedSignal("DuelsSelectedMode"):Connect(updateDuelsMode)
			task.spawn(updateDuelsMode)
			duelsMachineSession.Your.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
			duelsMachineSession.Other.Ready.Activated:Connect(function()
				local selectBrainrots = ReplicatorClient.get("SelectBrainrots")

				if not (selectBrainrots.Data and workspace:GetAttribute("DuelsSelectBrainrotActive")) then
					return
				end

				SoundController:PlaySound("Sounds.Sfx.Activated")
				local flag2 = true

				for _, player in selectBrainrots.Data.players do
					if player.ready and player.brainrot then
						continue
					end

					flag2 = false
					break
				end

				if flag2 then
					Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Accept"):FireServer()
				else
					Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Ready"):FireServer()
				end
			end)
			duelsMachineSession.Other.Cancel.Activated:Connect(function()
				if ReplicatorClient.get("SelectBrainrots").Data and workspace:GetAttribute("DuelsSelectBrainrotActive") then
					SoundController:PlaySound("Sounds.Sfx.Activated")
					Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Cancel"):FireServer()
				end
			end)
			v2.OnClose:Connect(function()
				if ReplicatorClient.get("SelectBrainrots").Data and workspace:GetAttribute("DuelsSelectBrainrotActive") then
					Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Cancel"):FireServer()
				end
			end)
		end

		local remoteEvent = Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Vote")
		duelsModeVote:Observe({ "timer" }, function(p: number)
			duelsMachineVoteFrame.TimerLabel.Text = p and `Game starting in {p // 1} seconds` or ""
		end)

		for _, button in duelsMachineVoteFrame.Buttons:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local v2 = AnimatedButton.new(button)
			v2:Animate()
			local v3 = button
			v2.OnActivated:Connect(function()
				remoteEvent:FireServer(v3.Name)
			end)
		end

		duelsModeVote:Observe({ "playerVotes" }, function(items)
			if not items then
				return
			end

			local v2 = {}

			for _, item in items do
				v2[item] = (v2[item] or 0) + 1
			end

			for _, button in duelsMachineVoteFrame.Buttons:GetChildren() do
				if button:IsA("GuiButton") then
					button.Background.Function.Text = v2[button.Name] or 0
				end
			end
		end)
		task.spawn(function()
			if not UserInputService:GetLastInputType() then
				UserInputService.LastInputTypeChanged:Wait()
			end

			if UserInputService.PreferredInput ~= Enum.PreferredInput.Touch then
				return
			end

			duelsMachineVoteFrame.Size = UDim2.fromScale(0.325, 0.3)
		end)

		local function updateVoteUIVisibility()
			if workspace:GetAttribute("DuelsVoteModeActive") then
				duelsMachineVoteFrame.Visible = true
				Spr.target(duelsMachineVoteFrame, 1, 4, {
					Position = UDim2.fromScale(0.5, 0.08)
				})
			else
				Spr.target(duelsMachineVoteFrame, 1, 4, {
					Position = UDim2.fromScale(0.5, -0.2)
				})
				Spr.completed(duelsMachineVoteFrame, function()
					if duelsMachineVoteFrame.Position.Y.Scale <= -0.15 then
						duelsMachineVoteFrame.Visible = false
					end
				end)
			end
		end

		workspace:GetAttributeChangedSignal("DuelsVoteModeActive"):Connect(updateVoteUIVisibility)
		task.spawn(updateVoteUIVisibility)
		local remoteEvent2 = Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/Animation")
		Net:RemoteEvent("DuelsMachineMatchService/SelectBrainrot/SetDevice"):FireServer(UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and "Console" or UserInputService.PreferredInput == Enum.PreferredInput.Touch and "Mobile" or "PC")
		local label1 = duelsMachineAnimation.Label1
		local label2 = duelsMachineAnimation.Label2
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 0
		blurEffect.Parent = workspace.CurrentCamera
		remoteEvent2.OnClientEvent:Connect(function(p: number)
			while flag do
				task.wait()
			end

			flag = true
			duelsMachineAnimation.Visible = true
			SoundController:PlaySound("Sounds.Sfx.Duels.Countdown", nil, false)
			CreateTween(duelsMachineAnimation, TweenInfo.new(0.25), {
				BackgroundTransparency = 0.25
			})
			CreateTween(blurEffect, TweenInfo.new(0.5), {
				Size = 20
			})
			label1.Visible = true
			label2.Visible = true

			for i = p // 1, 1, -1 do
				local label

				if i % 2 == 0 then
					label = label1
				else
					label = label2
				end

				label.ZIndex = 2
				label.TextTransparency = 1
				label.Size = UDim2.fromScale(0.5, 0.5)
				label.Text = i
				CreateTween(label, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(0.2, 0.2)
				}).Completed:Once(function()
					label.ZIndex = 1
					CreateTween(label, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Size = UDim2.fromScale(0, 0)
					})
				end)
				CreateTween(label, TweenInfo.new(0.35), {
					TextTransparency = 0
				})
				task.wait(1)
			end

			CreateTween(blurEffect, TweenInfo.new(0.25), {
				Size = 0
			})
			CreateTween(duelsMachineAnimation, TweenInfo.new(0.25), {
				BackgroundTransparency = 1
			}).Completed:Wait()
			label1.TextTransparency = 1
			label2.TextTransparency = 1
			label1.Visible = false
			label2.Visible = false
			duelsMachineAnimation.Visible = false
			flag = false
		end)
		duelsMachineTopFrame.Visible = false
		duelsMachineTopFrame.Position = UDim2.fromScale(0.5, -0.2)
		tip.TextTransparency = 1
		tip.UIStroke.Transparency = 1
		duelsRounds:WaitForLoaded()
		duelsMachineTopFrame.Visible = true
		CreateTween(duelsMachineTopFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
			Position = UDim2.fromScale(0.5, 0.01)
		})
		CreateTween(tip, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1), {
			TextTransparency = 0
		})
		CreateTween(tip.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1), {
			Transparency = 0
		})
		task.delay(10.5, function()
			CreateTween(tip, TweenInfo.new(0.5), {
				TextTransparency = 1
			})
			CreateTween(tip.UIStroke, TweenInfo.new(0.5), {
				Transparency = 1
			})
		end)
		duelsRounds:Observe({ "roundTimer" }, function(p: number)
			local v2 = p // 1
			local label = duelsMachineTopFrame.Timer.Label
			local text

			if v2 > 60 then
				text = string.format("%d:%0.2d", v2 // 60, v2 % 60)
			else
				text = `{v2}`
			end

			label.Text = text
		end)
		local v2 = { duelsMachineTopFrame.Blue, duelsMachineTopFrame.Red }
		local v3 = {
			PC = "rbxassetid://87143261820372",
			Console = "rbxassetid://119798532223911",
			Mobile = "rbxassetid://72402748445638"
		}

		local function updateTopUI()
			local v4 = duelsRounds:TryIndex({ "expectedPlayers" })
			local v5 = duelsRounds:TryIndex({ "roundWins" })

			if not (v4 and v5) then
				return
			end

			for k, v6 in v4 do
				local v7 = v2[k]
				local playerByUserId = Players:GetPlayerByUserId(v6)
				v7.Player.Image = `rbxthumb://type=AvatarHeadShot&id={v6}&w=100&h=100`
				v7.Label.Text = tostring(v5[tostring(v6)] or 0)
				local device = playerByUserId and playerByUserId:GetAttribute("Device")

				if device then
					v7.Icon.Image = v3[device] or ""
				end
			end
		end

		duelsRounds:Observe({ "roundWins" }, updateTopUI)
		duelsRounds:Observe({ "expectedPlayers" }, updateTopUI)
		Observers.observePlayer(function(p)
			task.spawn(updateTopUI)
			local v4 = Observers.observeAttribute(p, "Device", function()
				task.spawn(updateTopUI)
				return nil
			end)
			return function()
				v4()
				task.spawn(updateTopUI)
			end
		end)
	end
}