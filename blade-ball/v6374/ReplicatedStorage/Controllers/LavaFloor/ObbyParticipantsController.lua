local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Lighting = game:GetService("Lighting")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local v4 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v5 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v6 = require3(script.Tween)
local underWater = Lighting:WaitForChild("UnderWater")
local currentLTM = v3.getCurrentLTM()
local v7 = v2.isLTMServer() and currentLTM and currentLTM.getGameMode() == "LavaFloor" and true or v2.isTournamentEventServer()
local X = 20
local obbyParticipants = nil
local v8 = nil
local v9 = nil
local myPlayerMarker = nil
local playerMarker = nil
local connections = {}
local v10 = {}
local v11 = {}
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
local ObbyParticipantsController = {}

function ObbyParticipantsController.Start(_)
	obbyParticipants = playerGui.ObbyParticipants
	obbyParticipants.Enabled = false
	v9 = v:IsMobile()
	local mobile

	if v9 then
		mobile = obbyParticipants.Mobile
	else
		mobile = obbyParticipants.PC
	end

	obbyParticipants.Mobile.Visible = obbyParticipants.Mobile == mobile
	obbyParticipants.PC.Visible = obbyParticipants.PC == mobile
	v8 = mobile
	myPlayerMarker = v8.BG.Players.MyPlayerMarker
	myPlayerMarker.Parent = nil
	playerMarker = v8.BG.Players.PlayerMarker
	playerMarker.Parent = nil

	local function onLavaStatusChanged()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		local v12 = workspace:GetAttribute("WaterRaising") and true or false

		if v12 then
			table.insert(connections, workspace.Alive.ChildAdded:Connect(function(child)
				ObbyParticipantsController:_addParticipantCharacter(child)
			end))
			table.insert(connections, workspace.Dead.ChildAdded:Connect(function(child)
				ObbyParticipantsController:_destroyParticipantCharacter(child)
			end))
			table.insert(connections, Players.PlayerRemoving:Connect(function(player)
				ObbyParticipantsController:_destroyTile(player)
			end))

			for _, child in ipairs(workspace.Alive:GetChildren()) do
				local v13 = child
				task.spawn(function()
					ObbyParticipantsController:_addParticipantCharacter(v13)
				end)
			end

			obbyParticipants.Enabled = true
		else
			obbyParticipants.Enabled = false

			for k in v10 do
				ObbyParticipantsController:_destroyTile(k)
			end

			task.defer(function()
				underWater.Enabled = false
			end)
		end

		v4(Enum.CoreGuiType.Health, v12)
		v4(Enum.CoreGuiType.PlayerList, not v12)
	end

	workspace:GetAttributeChangedSignal("WaterRaising"):Connect(onLavaStatusChanged)
	task.spawn(onLavaStatusChanged)
	v5.ShowRoomOpened:Connect(function()
		task.defer(function()
			ObbyParticipantsController:_updateVisibility()
			task.wait()
			ObbyParticipantsController:_updateVisibility()
		end)
	end)
	v5.ShowRoomClosed:Connect(function()
		ObbyParticipantsController:_updateVisibility()
	end)

	local function GetPositionRange()
		local v12 = workspace.Map:GetChildren()[1]

		if v12 == nil then
			v12 = workspace.Map.ChildAdded:Wait()
		end

		if not v12 then
			return
		end

		local v13 = CollectionService:GetTagged("CUSTOM_WATER_PART")[1]

		if not v13 then
			return
		end

		local minWaterHeight = v12:GetAttribute("MinWaterHeight")
		local maxWaterHeight = v12:GetAttribute("MaxWaterHeight")

		if minWaterHeight and maxWaterHeight then
			return NumberRange.new(minWaterHeight, maxWaterHeight), v13.Position.Y + v13.Size.Y / 2
		end
	end

	if v7 then
		task.spawn(function()
			while true do
				task.wait(0.125)

				if workspace:GetAttribute("PlayingFinisher") then
					underWater.Enabled = false
				else
					local v12, v13 = GetPositionRange()

					if v12 and v13 then
						underWater.Enabled = localPlayer.Character.Parent == workspace.Alive and workspace.CurrentCamera.CFrame.Y < v13 - 0.5
						local v16 = math.clamp((v13 - v12.Min) / (v12.Max - v12.Min), 0, 1)
						local size

						if v9 then
							size = UDim2.fromScale(v16, 0.9)
						else
							size = UDim2.fromScale(0.9, v16)
						end

						TweenService:Create(v8.BG.Bar, tweenInfo, {
							Size = size
						}):Play()
						v8.BG.Bar.Visible = true

						for _, v18 in ipairs(Players:GetPlayers()) do
							local character = v18.Character
							local primaryPart = character and character.PrimaryPart

							if primaryPart then
								local v19 = math.clamp(
									(math.clamp(primaryPart.Position.Y, v12.Min, v12.Max) - v12.Min) / (v12.Max - v12.Min),
									0,
									1
								)
								pcall(setPlayerPosition, v18, v19)
							else
								pcall(setPlayerPosition, v18, 0)
							end
						end
					end
				end
			end
		end)
	end
end

function ObbyParticipantsController:_addParticipantCharacter(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter or v10[playerFromCharacter] then
		return
	end

	local v12

	if playerFromCharacter == localPlayer then
		v12 = myPlayerMarker
	else
		v12 = playerMarker
	end

	local clone = v12:Clone()
	local v13 = not (playerFromCharacter.UserId > 0) and 75974130 or playerFromCharacter.UserId
	clone.ImageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={v13}&w=100&h=100`
	clone.Visible = true
	clone.Parent = v8.BG.Players
	v10[playerFromCharacter] = clone

	if X == 20 then
		X = clone.AbsoluteSize.X
	end

	setPlayerPosition(playerFromCharacter, 0)
	ObbyParticipantsController:_updateVisibility()
end

function ObbyParticipantsController:_destroyParticipantCharacter(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter then
		ObbyParticipantsController:_destroyTile(playerFromCharacter)
	else
		ObbyParticipantsController:_updateVisibility()
	end
end

function ObbyParticipantsController:_destroyTile(p)
	local v12 = v11[p]

	if v12 then
		v12:Destroy()
		v11[p] = nil
	end

	local v13 = v10[p]

	if v13 then
		v13:Destroy()
		v10[p] = nil
	end

	task.delay(2, function()
		ObbyParticipantsController:_updateVisibility()
	end)
end

function ObbyParticipantsController:_updateVisibility()
	if areTilesEmpty() or not v7 or #workspace.Alive:GetChildren() < 2 or v5.UI ~= nil then
		obbyParticipants.Enabled = false
	else
		obbyParticipants.Enabled = true
	end
end

function setPlayerPosition(p, p2: number)
	local v12 = v10[p]

	if v12 and v12.Parent then
		local v13 = v11[p]

		if v13 then
			v13:Destroy()
			v11[p] = nil
		end

		local uDim

		if v9 then
			uDim = UDim2.fromScale(p2, 0.5)
		else
			uDim = UDim2.fromScale(0, 1 - p2)
		end

		local anchorPoint

		if v9 then
			anchorPoint = Vector2.new(0, 0)
		else
			anchorPoint = Vector2.new(0.75, 1 - p2)
		end

		v11[p] = v6(v12, tweenInfo, {
			Position = uDim,
			AnchorPoint = anchorPoint
		})
	end
end

function areTilesEmpty()
	return next(v10) == nil
end

ReplicatedStorage2.Remotes.RoundEnded.OnClientEvent:Connect(function()
	task.defer(function()
		underWater.Enabled = false
		task.wait()
		underWater.Enabled = false
	end)
	local size

	if v9 then
		size = UDim2.fromScale(1, 0.9)
	else
		size = UDim2.fromScale(0.9, 1)
	end

	v8.BG.Bar.Size = size
	v8.BG.Bar.Visible = false
end)
workspace.Dead.ChildAdded:Connect(function(child)
	if child == localPlayer.Character then
		task.defer(function()
			underWater.Enabled = false
			task.wait()
			underWater.Enabled = false
		end)
	end
end)
return ObbyParticipantsController