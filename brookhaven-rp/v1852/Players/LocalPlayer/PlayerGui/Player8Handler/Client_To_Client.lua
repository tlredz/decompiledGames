local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local child = workspace:WaitForChild(localPlayer.Name)
local humanoid = child:WaitForChild("Humanoid")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local mouse = game.Players.LocalPlayer:GetMouse()
local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
local settingsMain = playerGui:WaitForChild("SettingsMain")
local sent = mainGUIHandler:WaitForChild("Menu"):WaitForChild("Sent")
local game8Settings = script.Parent:WaitForChild("Game8Settings")
local module = require(game8Settings)
local playerTrigEvent = module.PlayerTrigEvent
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local BakingConfig = require(ReplicatedStorage.Modules.Shared.Housing.Baking.BakingConfig)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local HumanoidSyncableEmote = require(ReplicatedStorage.Modules.Client.Components.Humanoid.HumanoidSyncableEmote)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local FamilyController = require(ReplicatedStorage.Modules.Client.UI.Family.FamilyController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local client2Client = mainGUIHandler:WaitForChild("Client2Client")
local whiteCircle = client2Client:WaitForChild("WhiteCircle")
local client2ClientAskTool = client2Client:WaitForChild("Client2ClientAskTool")
local client2ClientTakeTool = client2Client:WaitForChild("Client2ClientTakeTool")
local client2ClientAccept = client2Client:WaitForChild("Client2ClientAccept")
local client2ClientDrop = client2Client:WaitForChild("Client2ClientDrop")
local drop = client2ClientDrop:WaitForChild("Drop")
local jump = client2ClientDrop:WaitForChild("Jump")
local value = script.PiggyBackPerson.Value
local value2 = script.ToolsPerson.Value
local value3 = script.ToolName.Value
local animationPlaying = script.Parent:WaitForChild("AnimationPlaying")
local chatAnimationPlaying = script.Parent:WaitForChild("ChatAnimationPlaying")
local waitingForReplyPiggy = script.Parent:WaitForChild("WaitingForReplyPiggy")
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local v7 = nil
local v8 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function clearWhiteCircleSelection()
	whiteCircle.MainOpen.WhiteCirclePic.SelectedPlayer.Text.Text = ""
	value = nil
end

local function unbindWhiteCircleBackAction()
	if not v8 then
		return
	end

	v8()
	v8 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindWhiteCircleBackAction()
	if v8 then
		return
	end

	v8 = BackActionRouter.Bind(function()
		PanelController.Close("MainGUIHandler", "WhiteCircle")
		clearWhiteCircleSelection() -- equivalent call inferred; original call site unknown
	end, function()
		return PanelController.IsOpen("MainGUIHandler", "WhiteCircle")
	end)
end

local track = humanoid:LoadAnimation((script:WaitForChild("AskingCarryHurtAnimation")))
local track2 = humanoid:LoadAnimation((script:WaitForChild("AcceptPiggyBackAnimation")))
local track3 = humanoid:LoadAnimation((script:WaitForChild("AcceptShouldersAnimation")))
local track4 = humanoid:LoadAnimation((script:WaitForChild("AcceptCarryHurtAnimation")))

function ClientMessage(p: string)
	NotificationController.Notify(p)
end

client2ClientAccept.Accept.Decline.MouseButton1Click:connect(function()
	print("Decline")
	client2ClientAccept.Visible = false
end)

function AnimationButtonAccept(text, p)
	if client2ClientTakeTool.Visible == false then
		jump.Visible = false
		client2ClientAccept.Accept.PlayersFace.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=420&height=420&format=png"
		client2ClientAccept.Accept.NameOfAnimation.Text = text
		client2ClientAccept.Visible = true
		wait(8)
		client2ClientAccept.Visible = false
		client2ClientAccept.Accept.AcceptPlayerRequestButtonPiggy.Visible = false
		client2ClientAccept.Accept.AcceptPlayerRequestButtonCarry.Visible = false
		client2ClientAccept.Accept.AcceptPlayerRequestButtonShoulders.Visible = false
	end
end

function WaitForReply()
	waitingForReplyPiggy.Value = true
	wait(10)
	v6 = false
	waitingForReplyPiggy.Value = false
end

function SentMessageShow()
	sent.Visible = true
	wait(5)
	sent.Visible = false
end

local function isValidForInteraction(localPlayer2, instance, p)
	local v9

	if localPlayer2 == nil or p == nil or instance == nil then
		return false
	else
		v9 = not (localPlayer2.Character:FindFirstChild("ClientToClient") or instance:FindFirstChild("ClientToClient"))

		if v9 then
			if animationPlaying.Value == false and chatAnimationPlaying.Value == false then
				return not (instance:FindFirstChild("NoMotorVehicleModel") or instance:FindFirstChild(p.Name .. "Horse"))
			else
				return false
			end
		end
	end

	return v9
end

local function isValidForEmoteSyncInteraction(localPlayer2, instance, p)
	local v9

	if localPlayer2 == nil or p == nil or instance == nil then
		return false
	else
		v9 = not (localPlayer2.Character:FindFirstChild("ClientToClient") or instance:FindFirstChild("ClientToClient"))

		if v9 then
			if chatAnimationPlaying.Value == false then
				return not (instance:FindFirstChild("NoMotorVehicleModel") or instance:FindFirstChild(p.Name .. "Horse"))
			else
				return false
			end
		end
	end

	return v9
end

local function handleAnimationRequest(p, p2)
	v6 = true

	if FamilyController.IsPlayerInFamily(p2) then
		task.delay(10, function()
			v6 = false
		end)
	else
		spawn(SentMessageShow)
		spawn(WaitForReply)
	end

	PanelController.Close("MainGUIHandler", "WhiteCircle")
	playerTrigEvent:FireServer("Client2Client", "Request: " .. p, p2)
	value = nil
end

PanelController.OnPanelClosed:Connect(function(p: string, p2: string)
	if p == "MainGUIHandler" and p2 == "WhiteCircle" then
		if not v8 then
			return
		end

		v8()
		v8 = nil
	end
end)

local function handleHousePermission(p, value4, p2, p3)
	local propertyPermissions = LotUtil.GetPropertyPermissions(value4)

	if propertyPermissions == nil then
		warn("No property permissions found for lot: " .. value4)
		return
	end

	if p2 == "give" then
		propertyPermissions:TryAddRoommate(p)
	else
		propertyPermissions:TryRemoveRoommate(p)
	end

	value = nil
	PanelController.Close("MainGUIHandler", "WhiteCircle")
	spawn(function()
		ClientMessage(p3)
	end)
end

local function handleSyncEmote(instance, p)
	if not isValidForEmoteSyncInteraction(localPlayer, instance, p) then
		return
	end

	local humanoid2 = instance:WaitForChild("Humanoid")

	if not humanoid2 then
		return
	end

	local component = ComponentUtil.GetComponentFromInstance(humanoid2, HumanoidSyncableEmote)

	if not component then
		return
	end

	component:SyncAnimationWithOtherPlayer()
end

local function isPlayerOnProperty(player)
	local value4 = localPlayer.PlayersBag:FindFirstChild("HouseNumber").Value

	if not LotUtil.GetProperty(value4) then
		return false
	end

	local bannedBlock = LotUtil.GetBannedBlock(value4)

	if not bannedBlock then
		warn("No banned block found for lot: " .. value4)
		return false
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { player.Character }
	overlapParams.MaxParts = 1
	return #workspace:GetPartBoundsInBox(bannedBlock.CFrame, bannedBlock.Size, overlapParams) > 0
end

local function updateUIBasedOnFamily()
	if not v7 then
		return
	end

	local isPlayerInFamily = FamilyController.IsPlayerInFamily(v7)
	local playersBag = localPlayer:WaitForChild("PlayersBag", 60)

	if not playersBag then
		v3 = false
		return
	end

	local houseOwn = playersBag:FindFirstChild("HouseOwn")
	local value4 = localPlayer.PlayersBag:FindFirstChild("HouseNumber").Value
	local propertyPermissions = LotUtil.GetPropertyPermissions(value4)
	local visible, v10

	if propertyPermissions then
		visible = propertyPermissions:HasRole(value, "Roommate")
		v10 = propertyPermissions:IsDisallowed(v7)
	else
		v10 = false
		visible = false
	end

	if v10 then
		whiteCircle.MainOpen.WhiteCirclePic.BanPlayerFromHouse.Image = "rbxassetid://5117371989"
		whiteCircle.MainOpen.WhiteCirclePic.BanPlayerFromHouse.TextLabel.Text = "Unban House"
	else
		whiteCircle.MainOpen.WhiteCirclePic.BanPlayerFromHouse.Image = "rbxassetid://5117440182"
		whiteCircle.MainOpen.WhiteCirclePic.BanPlayerFromHouse.TextLabel.Text = "Ban House"
	end

	local visible2 = LotUtil.GetLotType(value4) ~= "Landmark"

	if visible2 then
		if isPlayerInFamily or not (houseOwn and houseOwn.Value) then
			visible2 = v10
		else
			visible2 = isPlayerOnProperty(v7) or v10
		end
	end

	local visible3 = not isPlayerInFamily and houseOwn and houseOwn.Value

	if isPlayerInFamily then
		whiteCircle.MainOpen.WhiteCirclePic.Family.Image = "rbxassetid://89295258282826"
		whiteCircle.MainOpen.WhiteCirclePic.Family.TextLabel.Text = "Leave Family"
	else
		whiteCircle.MainOpen.WhiteCirclePic.Family.Image = "rbxassetid://116245642275982"
		whiteCircle.MainOpen.WhiteCirclePic.Family.TextLabel.Text = "Invite to Family"
	end

	whiteCircle.MainOpen.WhiteCirclePic.BanPlayerFromHouse.Visible = visible2
	whiteCircle.MainOpen.WhiteCirclePic.Permission.No.Visible = visible
	whiteCircle.MainOpen.WhiteCirclePic.Permission.Visible = visible3
end

local v9 = {
	Piggyback = function(p, p2)
		if isValidForInteraction(localPlayer, p, p2) then
			handleAnimationRequest("Piggyback!", p2)
		end
	end,
	Shoulders = function(p, p2)
		if isValidForInteraction(localPlayer, p, p2) then
			handleAnimationRequest("Shoulders!", p2)
		end
	end,
	["Carry Hurt"] = function(p, p2)
		if isValidForInteraction(localPlayer, p, p2) then
			handleAnimationRequest("Carry!", p2)
		end
	end,
	BanPlayerFromHouse = function(p, p2)
		if localPlayer ~= nil and p2 ~= nil and p ~= nil then
			local houseNumber = localPlayer.PlayersBag:FindFirstChild("HouseNumber")
			local propertyPermissions = LotUtil.GetPropertyPermissions(houseNumber.Value)

			if propertyPermissions == nil then
				warn("No property permissions found for lot: " .. houseNumber.Value)
				return
			end

			if propertyPermissions:IsDisallowed(p2) then
				propertyPermissions:TryAllow(p2)
			else
				propertyPermissions:TryDisallow(p2)
			end

			value = nil
			PanelController.Close("MainGUIHandler", "WhiteCircle")
		end
	end,
	Permission = function(p, p2)
		if localPlayer ~= nil and p2 ~= nil and p ~= nil then
			local value4 = localPlayer.PlayersBag:FindFirstChild("HouseNumber").Value

			if LotUtil.GetPropertyPermissions(value4):HasRole(value, "Roommate") then
				handleHousePermission(p2, value4, "remove", p2.Name .. " is no longer a roommate")
			else
				handleHousePermission(p2, value4, "give", p2.Name .. " is now a roommate")
			end
		end
	end,
	SyncEmote = function(instance, p)
		if localPlayer ~= nil and p ~= nil and instance ~= nil and isValidForEmoteSyncInteraction(
			localPlayer,
			instance,
			p
		) then
			local humanoid2 = instance:WaitForChild("Humanoid")
			local v10 = humanoid2 and ComponentUtil.GetComponentFromInstance(humanoid2, HumanoidSyncableEmote)

			if v10 then
				v10:SyncAnimationWithOtherPlayer()
			end
		end

		value = nil
		PanelController.Close("MainGUIHandler", "WhiteCircle")
	end,
	Family = function(_, p)
		if FamilyController.IsPlayerInFamily(p) then
			PanelController.OpenPanelByContext("MainGUIHandler", "LeaveFamily")
			return
		end

		PanelController.Close("MainGUIHandler", "WhiteCircle")
		Remotes.fireServer("InvitePlayerToFamily", p.UserId, "Wheel")
	end
}

for _, button in pairs(whiteCircle.MainOpen.WhiteCirclePic:GetChildren()) do
	if not button:IsA("ImageButton") then
		continue
	end

	local v10 = button
	button.MouseButton1Click:Connect(function()
		if not v4 then
			v4 = true
			local v11 = v9[v10.Name]

			if v11 then
				local v12 = value
				v11(v12, (game.Players:GetPlayerFromCharacter(v12)))
			end

			wait(0.5)
			v4 = false
		end
	end)
end

mouse.Button1Down:connect(function()
	local target = mouse.Target
	local backpackItem = localPlayer.Character:FindFirstChildWhichIsA("BackpackItem")
	local clientToClient = localPlayer.Character:FindFirstChild("ClientToClient")

	if target ~= nil and localPlayer.Character ~= nil and not clientToClient and (target.Parent:FindFirstChild("Humanoid") or target.Parent.Parent:FindFirstChild("Humanoid")) and not backpackItem and v3 == false and v6 == false or backpackItem and v5 == false then
		local head = localPlayer.Character:FindFirstChild("Head")

		if target ~= nil and head ~= nil and (target.Position - head.Position).magnitude < 15 then
			local parent = nil

			if target.Parent:FindFirstChild("Humanoid") == nil then
				if target.Parent.Parent:FindFirstChild("Humanoid") ~= nil then
					parent = target.Parent.Parent
				end
			else
				parent = target.Parent
			end

			if parent and parent.Name ~= localPlayer.Character.Name then
				if backpackItem then
					v5 = true
					value2 = parent
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)

					if playerFromCharacter ~= nil then
						local backpackItem2 = localPlayer.Character:FindFirstChildWhichIsA("BackpackItem")

						if backpackItem2 and backpackItem2:GetAttribute("Giveable") ~= false then
							local v10 = ToolsConfig.GetConfig()[value3]

							if v10 and v10.UntradeableNoMessage then
								client2ClientAskTool.Visible = false
								v5 = false
								value2 = nil
								value3 = nil
								return
							else
								client2ClientAskTool.Accept.ToolPic.Image = backpackItem2.TextureId
								client2ClientAskTool.Accept.PlayersFace.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. playerFromCharacter.UserId .. "&width=420&height=420&format=png"
								value3 = backpackItem2.Name
								client2ClientAskTool.Visible = true
								sent.Visible = false
							end
						end
					end
				else
					v3 = true
					value = parent
					local playerFromCharacter = Players:GetPlayerFromCharacter(value)

					if not playerFromCharacter then
						v3 = false
						return
					end

					v7 = playerFromCharacter
					whiteCircle.MainOpen.WhiteCirclePic.SelectedPlayer.Text.Text = value.Name
					updateUIBasedOnFamily()
					local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(parent)

					if playerFromCharacter2 then
						whiteCircle.MainOpen.WhiteCirclePic.SelectedPlayer.ImagePlayer.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. playerFromCharacter2.UserId .. "&width=420&height=420&format=png"
						local humanoid2 = parent:FindFirstChild("Humanoid")

						if humanoid2 then
							if humanoid2:HasTag("HumanoidSyncableEmote") then
								whiteCircle.MainOpen.WhiteCirclePic.SyncEmote.Visible = true
							else
								whiteCircle.MainOpen.WhiteCirclePic.SyncEmote.Visible = false
							end

							if whiteCircle.MainOpen.WhiteCirclePic.SyncEmote.Visible then
								whiteCircle.MainOpen.WhiteCirclePic.Permission.Position = UDim2.new(0.08, 0, 0.51, 0)
							else
								whiteCircle.MainOpen.WhiteCirclePic.Permission.Position = whiteCircle.MainOpen.WhiteCirclePic.SyncEmote.Position
							end
						end

						PanelController.OpenPanelByContext("MainGUIHandler", "WhiteCircle")
						bindWhiteCircleBackAction() -- equivalent call inferred; original call site unknown
						settingsMain.SettingsMenu.Visible = false
						drop.Visible = false
						jump.Visible = false
					end
				end
			end
		end
	elseif backpackItem then
		client2ClientAskTool.Visible = false
		value2 = nil
		value3 = nil
	else
		PanelController.Close("MainGUIHandler", "WhiteCircle")
		clearWhiteCircleSelection() -- equivalent call inferred; original call site unknown

		for k, visible in pairs({
			BanPlayerFromHouse = false,
			Permission = false
		}) do
			whiteCircle.MainOpen.WhiteCirclePic[k].Visible = visible
		end
	end

	wait(0.5)
	v3 = false
	v5 = false
end)
local mouseButton1ClickConnection = nil
local mouseButton1ClickConnection2 = nil
local mouseButton1ClickConnection3 = nil

local function acceptPiggyback(player)
	client2ClientAccept.Visible = false

	if localPlayer ~= nil and player ~= nil and not localPlayer.Character:FindFirstChild("NoMotorVehicleModel") and not localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") and (localPlayer.Character.UpperTorso.Position - player.Character.UpperTorso.Position).magnitude < 110 and track2 then
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		if humanoid and humanoid.Sit == true then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			wait(0.5)
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		if not track2.IsPlaying then
			track2:Play(nil, nil, 1)
			playerTrigEvent:FireServer("BothWantPiggyBackRide", player)
			jump.Visible = true
			humanoid.Died:connect(function()
				if humanoid.Parent:FindFirstChild("UpperTorso") ~= nil and humanoid.Parent.UpperTorso:FindFirstChild("Client_To_ClientWeld") ~= nil then
					humanoid.Parent.UpperTorso.Client_To_ClientWeld:Destroy()
					localPlayer.Character:BreakJoints()
				end

				playerTrigEvent:FireServer("NoAnimationDied", player)
			end)
		end
	end
end

local function acceptCarry(player)
	client2ClientAccept.Visible = false

	if localPlayer ~= nil and player ~= nil and not localPlayer.Character:FindFirstChild("NoMotorVehicleModel") and not localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") and (localPlayer.Character.UpperTorso.Position - player.Character.UpperTorso.Position).magnitude < 110 and track4 then
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		if humanoid and humanoid.Sit == true then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			wait(0.5)
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		if not track4.IsPlaying then
			track4:Play(nil, nil, 1)
			playerTrigEvent:FireServer("BothWantCarryHurt", player)
			jump.Visible = true
			humanoid.Died:connect(function()
				if humanoid.Parent:FindFirstChild("UpperTorso") ~= nil and humanoid.Parent.UpperTorso:FindFirstChild("Client_To_ClientWeld") ~= nil then
					humanoid.Parent.UpperTorso.Client_To_ClientWeld:Destroy()
					localPlayer.Character:BreakJoints()
				end

				playerTrigEvent:FireServer("StopCarryHurtDied", player)
			end)
		end
	end
end

local function acceptShoulders(player)
	client2ClientAccept.Visible = false

	if localPlayer ~= nil and player ~= nil and not localPlayer.Character:FindFirstChild("NoMotorVehicleModel") and not localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") and (localPlayer.Character.UpperTorso.Position - player.Character.UpperTorso.Position).magnitude < 110 and track3 then
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		if humanoid and humanoid.Sit == true then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			wait(0.5)
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		if not track3.IsPlaying then
			track3:Play(nil, nil, 1)
			playerTrigEvent:FireServer("BothWantShoulders", player)
			jump.Visible = true
			humanoid.Died:connect(function()
				if humanoid.Parent:FindFirstChild("UpperTorso") ~= nil and humanoid.Parent.UpperTorso:FindFirstChild("Client_To_ClientWeld") ~= nil then
					humanoid.Parent.UpperTorso.Client_To_ClientWeld:Destroy()
					localPlayer.Character:BreakJoints()
				end

				playerTrigEvent:FireServer("NoAnimationDied", player)
			end)
		end
	end
end

playerTrigEvent.OnClientEvent:Connect(function(p, p2)
	local isPlayerInFamily = FamilyController.IsPlayerInFamily(p2)

	if p == "Request: Piggyback!" and v6 == false and client2ClientAccept.Visible == false and localPlayer.Character.Humanoid.Sit == false and localPlayer.Character.Humanoid.WalkSpeed > 1 then
		PanelController.Close("MainGUIHandler", "WhiteCircle")
		client2ClientAccept.Accept.AcceptPlayerRequestButtonCarry.Visible = false
		client2ClientAccept.Accept.AcceptPlayerRequestButtonShoulders.Visible = false

		if isPlayerInFamily then
			client2ClientAccept.Accept.AcceptPlayerRequestButtonPiggy.Visible = false
			acceptPiggyback(p2)
		else
			v6 = true
			spawn(WaitForReply)
			spawn(function()
				AnimationButtonAccept(p, p2)
			end)
			client2ClientAccept.Accept.AcceptPlayerRequestButtonPiggy.Visible = true
			mouseButton1ClickConnection = client2ClientAccept.Accept.AcceptPlayerRequestButtonPiggy.MouseButton1Click:connect(function()
				acceptPiggyback(p2)
				mouseButton1ClickConnection:disconnect()
			end)
		end
	elseif p == "Request: Carry!" and v6 == false and client2ClientAccept.Visible == false and localPlayer.Character.Humanoid.Sit == false and localPlayer.Character.Humanoid.WalkSpeed > 1 then
		PanelController.Close("MainGUIHandler", "WhiteCircle")
		client2ClientAccept.Accept.AcceptPlayerRequestButtonPiggy.Visible = false
		client2ClientAccept.Accept.AcceptPlayerRequestButtonShoulders.Visible = false

		if isPlayerInFamily then
			client2ClientAccept.Accept.AcceptPlayerRequestButtonCarry.Visible = false
			acceptCarry(p2)
		else
			v6 = true
			spawn(WaitForReply)
			spawn(function()
				AnimationButtonAccept(p, p2)
			end)
			client2ClientAccept.Accept.AcceptPlayerRequestButtonCarry.Visible = true
			mouseButton1ClickConnection2 = client2ClientAccept.Accept.AcceptPlayerRequestButtonCarry.MouseButton1Click:connect(function()
				acceptCarry(p2)
				mouseButton1ClickConnection2:disconnect()
			end)
		end
	elseif p == "Request: Shoulders!" and v6 == false and client2ClientAccept.Visible == false and localPlayer.Character.Humanoid.Sit == false and localPlayer.Character.Humanoid.WalkSpeed > 1 then
		PanelController.Close("MainGUIHandler", "WhiteCircle")
		client2ClientAccept.Accept.AcceptPlayerRequestButtonPiggy.Visible = false
		client2ClientAccept.Accept.AcceptPlayerRequestButtonCarry.Visible = false

		if isPlayerInFamily then
			client2ClientAccept.Accept.AcceptPlayerRequestButtonShoulders.Visible = false
			acceptShoulders(p2)
		else
			v6 = true
			spawn(WaitForReply)
			spawn(function()
				AnimationButtonAccept(p, p2)
			end)
			client2ClientAccept.Accept.AcceptPlayerRequestButtonShoulders.Visible = true
			mouseButton1ClickConnection3 = client2ClientAccept.Accept.AcceptPlayerRequestButtonShoulders.MouseButton1Click:connect(function()
				acceptShoulders(p2)
				mouseButton1ClickConnection3:disconnect()
			end)
		end
	end
end)
playerTrigEvent.OnClientEvent:Connect(function(p)
	if p == "ReturnAnimationCarryHurt" then
		sent.Visible = false
		drop.Visible = true

		if track and not track.IsPlaying then
			track:Play(nil, nil, 1)
		end
	elseif p == "DropButtonStopAnimations" then
		jump.Visible = false

		if track3 then
			track3:Stop()
		end

		if track2 then
			track2:Stop()
		end

		if track4 then
			child.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			track4:Stop()
		end
	elseif p == "DropButtonOn" then
		sent.Visible = false
		drop.Visible = true
	elseif p == "JumpedPlayer/DropButtonOff" then
		drop.Visible = false

		if track then
			track:Stop()
		end
	end
end)
drop.Drop.MouseButton1Click:connect(function()
	if localPlayer.PlayersBag:FindFirstChild("Client2Client") ~= nil then
		playerTrigEvent:FireServer("DropButtonStopAll", localPlayer.PlayersBag:FindFirstChild("Client2Client").Value)

		if track then
			track:Stop()
		end

		drop.Visible = false
	end
end)
jump.Jump.MouseButton1Click:connect(function()
	if localPlayer.PlayersBag:FindFirstChild("Client2Client") ~= nil then
		playerTrigEvent:FireServer("JumpButtonStopAll", localPlayer.PlayersBag:FindFirstChild("Client2Client").Value)
	end

	if track2 ~= nil then
		track2:Stop()
	end

	if track3 ~= nil then
		track3:Stop()
	end

	if track4 ~= nil then
		child.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		track4:Stop()
	end

	jump.Visible = false
end)
client2ClientAskTool.Accept.GiveToolPress.MouseButton1Click:connect(function()
	if v2 == false then
		v2 = true
		local playerFromCharacter = Players:GetPlayerFromCharacter(value2)
		local backpackItem = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("BackpackItem")
		local name

		if backpackItem == nil then
			name = value3
		else
			name = backpackItem.Name
		end

		if playerFromCharacter == nil or typeof(name) ~= "string" then
			v2 = false
			return
		end

		if BakingConfig.ParseToolName(name) == nil then
			local v10 = ToolsConfig.GetConfig()[name]

			if v10 and v10.Untradeable then
				NotificationController.Notify("You cannot give this tool to other players.")
				v2 = false
				return
			elseif v10 and v10.UntradeableNoMessage then
				v2 = false
				return
			end
		end

		playerTrigEvent:FireServer("ToolGiveToServer", playerFromCharacter, name)
		sent.Visible = false
		client2ClientAskTool.Visible = false
		value2 = nil
		value3 = nil
		wait(1)
		v2 = false
	end
end)
local mouseButton1ClickConnection4 = nil
playerTrigEvent.OnClientEvent:Connect(function(p, p2, image, value4)
	if p == "ToolGiveToClient" and v == false and client2ClientAskTool.Visible == false and client2ClientAccept.Visible == false and jump.Visible == false and drop.Visible == false then
		if typeof(value4) == "string" and BakingConfig.ParseToolName(value4) == nil then
			local v10 = ToolsConfig.GetConfig()[value4]

			if v10 and v10.Untradeable then
				NotificationController.Notify("You cannot take this tool.")
				return
			elseif v10 and v10.UntradeableNoMessage then
				return
			end
		end

		v = true
		local v10 = value4
		client2ClientTakeTool.Visible = true
		client2ClientTakeTool.Accept.ToolPic.Image = image
		client2ClientTakeTool.Accept.PlayersFace.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p2.UserId .. "&width=420&height=420&format=png"
		mouseButton1ClickConnection4 = client2ClientTakeTool.Accept.GiveToolPress.MouseButton1Click:connect(function()
			playerTrigEvent:FireServer("AcceptedToolToServer", v10, p2)
			client2ClientTakeTool.Visible = false
			v10 = nil
			mouseButton1ClickConnection4:disconnect()
		end)
		wait(7)

		if client2ClientTakeTool.Visible == true then
			client2ClientTakeTool.Visible = false
		end

		v10 = nil
		v = false
	end
end)
FamilyController.FamilyStateChanged:Connect(updateUIBasedOnFamily)
Players.PlayerRemoving:Connect(function(player)
	if player == v7 then
		v7 = nil
	end
end)