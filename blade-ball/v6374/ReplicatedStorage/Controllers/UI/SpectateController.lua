local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local v4 = require3(ReplicatedStorage2.ServerInfo)
require3("@game/ReplicatedStorage/Types/Templates")
local maid = require3(ReplicatedStorage2.Common.Utils).Maid
local v5 = require3(script.Parent.TopBarController)
local v6 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local touchEnabled = v.TouchEnabled == true
local localPlayer = Players.LocalPlayer
local remoteEvent = v2:RemoteEvent("UpdateSpectateCount")
local remoteEvent2 = v2:RemoteEvent("CustomRespawnEvent")
local remoteEvent3 = v2:RemoteEvent("CustomRespawnFinished")
local remoteEvent4 = v2:RemoteEvent("VFXConfettiEvent")
local remoteEvent5 = v2:RemoteEvent("SpectateChanged")
local spectate = localPlayer.PlayerGui:WaitForChild("Spectate")
local holder = spectate.Holder
local buttons = holder.Buttons
local rankedQueue = localPlayer.PlayerGui:WaitForChild("RankedQueue")
local voter = localPlayer.PlayerGui:WaitForChild("voter")
local shop = localPlayer.PlayerGui:WaitForChild("Shop")
local emoteWheel = localPlayer.PlayerGui:WaitForChild("EmoteWheel")
local alive = workspace:WaitForChild("Alive")
local dead = workspace:WaitForChild("Dead")
local currentCamera = workspace.CurrentCamera
local v7 = false
local huntPrivateServer = v4.isHuntPrivateServer()
local v8 = false
local cameraSubject = nil
local v9 = true
local uIGradient = holder.Options.ConfettiButton.UIGradient
local tween = TweenService:Create(uIGradient, TweenInfo.new(10, Enum.EasingStyle.Linear), {
	Offset = Vector2.new(0.48, 0)
})
local children = alive:GetChildren()
local v10 = 1
local v11 = nil
local maid2 = maid.new()
local SpectateController = {
	_getAliveTeammate = function(self)
		local character = localPlayer.Character
		local teamColor = localPlayer.TeamColor

		for i, v12 in ipairs(children) do
			if v12 == character or v12:GetAttribute("teamVIP") then
				continue
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(v12)

			if playerFromCharacter and playerFromCharacter.TeamColor == teamColor or v12:GetAttribute("TeamColor") == teamColor then
				return playerFromCharacter, i
			end
		end

		return nil, nil
	end
}

function SpectateController:SpectateTeammate()
	local _getAliveTeammate, v12 = SpectateController:_getAliveTeammate()
	local flag

	if _getAliveTeammate and v12 then
		v10 = v12
		flag = true
	else
		flag = false
	end

	if flag then
		SpectateController:Next(0)
	end

	ProximityPromptService.Enabled = false
end

function SpectateController:_resetCamera()
	ProximityPromptService.Enabled = true
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	currentCamera.CameraSubject = humanoid
	cameraSubject = humanoid
end

function SpectateController:_updateVisibility()
	if isSpectateDisabled() then
		spectate.Enabled = false
		self:Leave()
	else
		holder.SpectateCount.Text = ""
		spectate.Enabled = not v6.IsUICovered.CurrentState
	end
end

function SpectateController.SetVisibility(_, enabled: boolean)
	if isSpectateDisabled() then
		enabled = false
	end

	spectate.Enabled = enabled
	SpectateController:_updateVisibility()
end

function SpectateController.SetOptionsVisibility(_, visible: boolean)
	holder.Options.Visible = visible
end

function SpectateController:ChangedSpectating(flag: boolean)
	if flag or not v7 then
		if flag and not v7 then
			remoteEvent5:FireServer(flag)
			v7 = true
		end
	else
		remoteEvent5:FireServer(flag)
		v7 = false
	end
end

function SpectateController:Next(p)
	v8 = false
	local count = #children

	if count == 0 then
		self:Leave()
		return
	end

	v10 += p

	if count < v10 then
		v10 = 1
	elseif v10 < 1 then
		v10 = count
	end

	maid2:DoCleaning()
	local v12 = children[v10]

	if not v12 then
		return self:Next(1)
	end

	local humanoid = v12:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return self:Next(1)
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(v12)

	if not playerFromCharacter then
		return self:Next(1)
	end

	maid2:GiveTask(humanoid.Died:Once(function()
		self:Next(1)
	end))
	maid2:GiveTask(playerFromCharacter.Destroying:Once(function()
		self:Next(1)
	end))
	v11 = playerFromCharacter
	self:ChangedSpectating(true)
	buttons.PlayerName.Text = type(humanoid.DisplayName) == "string" and #humanoid.DisplayName > 0 and humanoid.DisplayName or v12.Name
	currentCamera.CameraSubject = humanoid
	cameraSubject = humanoid
	maid2:GiveTask(currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		if v8 then
			self:UpdateBallSpectating()
		elseif currentCamera.CameraSubject ~= humanoid then
			currentCamera.CameraSubject = humanoid
		end

		cameraSubject = currentCamera.CameraSubject
	end))
	local v13 = nil
	pcall(function()
		local v14 = v11

		if v14 then
			if v11 == playerFromCharacter then
				v14 = false
			else
				v14 = playerFromCharacter:IsFriendsWith(v11.UserId)
			end
		end

		v13 = v14
	end)
	holder.SpectateCount.Text = ""
	holder.SpectateCount.Visible = true
	holder.CancelSpectateButton.Visible = true
	holder.Options.ConfettiButton.Visible = true
	holder.Options.AddFriendButton.Visible = v13 == false
	self._isSpectating = true
	remoteEvent:FireServer(v11)
end

function SpectateController:GetCurrentlySpectating()
	if self._isSpectating then
		return v11
	end

	return nil
end

function SpectateController:Leave()
	ProximityPromptService.Enabled = true

	if not self._isSpectating then
		return
	end

	if v11 then
		v11 = nil
	end

	self:ChangedSpectating(false)
	maid2:DoCleaning()
	self:_resetCamera()
	holder.SpectateCount.Visible = false
	holder.CancelSpectateButton.Visible = false
	holder.Options.ConfettiButton.Visible = false
	holder.Options.AddFriendButton.Visible = false
	buttons.PlayerName.Text = "Spectate"
	self._isSpectating = false
	v10 = 0
	remoteEvent:FireServer()
	v8 = false
end

local function getFakeBall()
	for _, child in workspace.Balls:GetChildren() do
		if not child:GetAttribute("realBall") then
			return child
		end
	end

	return nil
end

function SpectateController:SpectateBall()
	if currentCamera.CameraSubject and not currentCamera.CameraSubject:IsDescendantOf(workspace.Balls) then
		currentCamera.CameraSubject = getFakeBall() or cameraSubject
	end
end

function SpectateController:UpdateBallSpectating()
	if v8 then
		self:SpectateBall()
	elseif cameraSubject and currentCamera.CameraSubject ~= cameraSubject then
		currentCamera.CameraSubject = cameraSubject
	else
		self:_resetCamera()
	end
end

function SpectateController.Init(_)
	local v12 = holder
	local position2

	if touchEnabled then
		position2 = UDim2.fromScale(0.5, 0.85)
	else
		position2 = UDim2.fromScale(0.5, 0.1)
	end

	v12.Position = position2

	if not touchEnabled then
		task.defer(function()
			local duelMatchServer = v4.isDuelMatchServer()
			local rankedMatchServer = v4.isRankedMatchServer()
			local trainingServer = v4.isTrainingServer()
			local tournamentMatchServer = v4.isTournamentMatchServer()
			local currentLTM = v3.getCurrentLTM()
			local v14 = v4.isLTMServer() and currentLTM and currentLTM.getGameMode() == "Flying"

			if rankedMatchServer or v14 then
				holder.Position = UDim2.fromScale(0.5, 0.175)
			elseif duelMatchServer or trainingServer then
				holder.Position = UDim2.fromScale(0.5, 0.175)
			elseif tournamentMatchServer then
				holder.Position = UDim2.fromScale(0.5, 0.2)
				holder.SpectateCount.Position = UDim2.fromScale(0.5, 9.75)
				holder.CancelSpectateButton.Position = UDim2.fromScale(0.5, 2)
			else
				holder.Position = UDim2.fromScale(0.5, 0.1)
			end

			if table.find(v3.serverProfiles, "AbilityGame") or table.find(v3.serverProfiles, "CrownClash") or table.find(
				v3.serverProfiles,
				"LuckyBlocks"
			) then
				local position = holder.Position

				local function updateSpectatePosition()
					local currentlySelectedMode = workspace:GetAttribute("CurrentlySelectedMode")
					local v15 = holder
					local position3

					if currentlySelectedMode == "AbilityGame" or currentlySelectedMode == "CrownClash" or currentlySelectedMode == "LuckyBlocks" then
						position3 = UDim2.fromScale(0.5, 0.2)
					else
						position3 = position
					end

					v15.Position = position3
				end

				workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(updateSpectatePosition)
				task.spawn(updateSpectatePosition)
			end
		end)
	end
end

function SpectateController:Start()
	local v12 = v5:Create("Spectate"):setImage(15360127724):setOrder(100):disableStateOverlay(true):setCaption("Spectators"):lock():setEnabled(false)

	local function updateSpectators(p)
		local v13 = p[tostring(localPlayer.UserId)]

		if v13 and #v13 > 0 then
			v12:setLabel(#v13):setCaption(#v13 .. " WATCHING"):setEnabled(true)
		else
			v12:setEnabled(false)
		end
	end

	local flag = false
	buttons.RightButton.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		task.delay(1, function()
			flag = false
		end)
		self:Next(1)
	end)
	buttons.LeftButton.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		task.delay(1, function()
			flag = false
		end)
		self:Next(-1)
	end)
	holder.CancelSpectateButton.Activated:Connect(function()
		self:Leave()
	end)
	holder.Options.AddFriendButton.Activated:Connect(function()
		if v11 and v11 ~= localPlayer then
			local success, result = pcall(function()
				StarterGui:SetCore("PromptSendFriendRequest", v11)
			end)

			if not success then
				print("Error sending friend request: ", result)
			end
		end
	end)
	holder.Options.ConfettiButton.Activated:Connect(function()
		if not v9 then
			return
		end

		if v11 and v11 ~= localPlayer then
			v9 = false
			remoteEvent4:FireServer(v11.Character)
			uIGradient.Offset = Vector2.new(-0.48, 0)
			tween:Play()
			task.delay(10, function()
				v9 = true
			end)
		end
	end)
	pcall(function()
		StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(p)
			if v11 == p then
				holder.Options.AddFriendButton.Visible = false
			end
		end)
	end)
	pcall(function()
		StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(p)
			if v11 == p then
				holder.Options.AddFriendButton.Visible = true
			end
		end)
	end)
	remoteEvent3.OnClientEvent:Connect(function()
		if not Players.CharacterAutoLoads then
			return
		end

		if v11 then
			self:Leave()
		end
	end)
	ReplicatedStorage2.Remotes.RoundEnded.OnClientEvent:Connect(function()
		task.wait(0.25)

		if v11 then
			self:Leave()
		end
	end)
	remoteEvent2.OnClientEvent:Connect(function(_: number)
		if not Players.CharacterAutoLoads then
			return
		end

		self:SpectateTeammate()
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		updateSpectators(p)

		if not v11 then
			holder.SpectateCount.Text = ""
			return
		end

		local v13 = p[tostring(v11.UserId)]
		holder.SpectateCount.Text = `Watching: {v13 and #v13 or "1"}`
	end)
	alive.ChildAdded:Connect(function(model)
		if not model:IsA("Model") or table.find(children, model) or model:GetAttribute("teamVIP") then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(model)

		if playerFromCharacter or not playerFromCharacter and model.Name:find("Bot") then
			table.insert(children, model)
			self:_updateVisibility()
		end
	end)
	alive.ChildRemoved:Connect(function(child)
		local index = table.find(children, child)

		if not index then
			return
		end

		if index == v10 and self._isSpectating then
			self:Next(-1)
		end

		table.remove(children, index)
		self:_updateVisibility()
	end)
	dead.ChildAdded:Connect(function(_)
		self:_updateVisibility()
	end)
	dead.ChildRemoved:Connect(function(_)
		self:_updateVisibility()
	end)
	workspace:GetAttributeChangedSignal("NotStartMatch"):Connect(function()
		self:_updateVisibility()
	end)
	voter:GetPropertyChangedSignal("Enabled"):Connect(function()
		if voter.Enabled and spectate.Enabled then
			spectate.Enabled = false
			self:Leave()
		end

		if rankedQueue.Frame.Visible and rankedQueue.Enabled then
			voter.Frame.Position = UDim2.fromScale(0.5, 0.28)
		else
			voter.Frame.Position = UDim2.fromScale(0.5, 0.1)
		end
	end)
	rankedQueue.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if rankedQueue.Frame.Visible and rankedQueue.Enabled then
			holder.Position = UDim2.fromScale(0.5, 0.28)
			voter.Frame.Position = UDim2.fromScale(0.5, 0.28)
		else
			holder.Position = UDim2.fromScale(0.5, 0.1)
			voter.Frame.Position = UDim2.fromScale(0.5, 0.1)
		end
	end)
	rankedQueue:GetPropertyChangedSignal("Enabled"):Connect(function()
		if rankedQueue.Frame.Visible and rankedQueue.Enabled then
			holder.Position = UDim2.fromScale(0.5, 0.28)
			voter.Frame.Position = UDim2.fromScale(0.5, 0.28)
		else
			holder.Position = UDim2.fromScale(0.5, 0.1)
			voter.Frame.Position = UDim2.fromScale(0.5, 0.1)
		end
	end)
	workspace:GetAttributeChangedSignal("DisableSpectateFinisher"):Connect(function()
		self:_updateVisibility()
	end)
	workspace:GetAttributeChangedSignal("PlayingFinisher"):Connect(function()
		self:_updateVisibility()
	end)
	v6.IsUICoveredState:Connect(function()
		self:_updateVisibility()
	end)
	shop:GetPropertyChangedSignal("Enabled"):Connect(function()
		self:_updateVisibility()
	end)
	self:_updateVisibility()

	if v4.isMedalTournamentMatch() then
		local ancestryChangedConnection = nil

		local function onCharAdded(instance)
			if ancestryChangedConnection and ancestryChangedConnection.Connected then
				ancestryChangedConnection:Disconnect()
			end

			ancestryChangedConnection = instance.AncestryChanged:Connect(function()
				if instance.Parent == nil then
					local _isSpectating = self._isSpectating
					self:_updateVisibility()

					if self._isSpectating and self._isSpectating ~= _isSpectating then
						self:Next(1)
					end
				else
					self:Leave()
				end
			end)
		end

		if localPlayer.Character then
			task.spawn(onCharAdded, localPlayer.Character)
		end

		localPlayer.CharacterAdded:Connect(onCharAdded)
	end

	if huntPrivateServer then
		v.InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed or not v7 then
				return
			end

			if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
				v8 = not v8
				self:UpdateBallSpectating()
			end
		end)
		workspace.Balls.ChildAdded:Connect(function(_)
			if v8 and v7 then
				self:SpectateBall()
			end
		end)
		workspace.Balls.ChildRemoved:Connect(function(child)
			if v8 and v7 and currentCamera.CameraSubject == child then
				self:UpdateBallSpectating()
			end
		end)
	end
end

function isSpectateDisabled()
	local children2 = workspace.Alive:GetChildren()
	local character = localPlayer.Character
	local disableSpectateFinisher

	if workspace:GetAttribute("PlayingFinisher") then
		disableSpectateFinisher = workspace:GetAttribute("DisableSpectateFinisher")
	end

	if #children2 == 1 or #children == 0 or not (character or v4.isMedalTournamentMatch()) or character:IsDescendantOf(alive) or character:GetAttribute("Dead") or disableSpectateFinisher and os.clock() < disableSpectateFinisher or emoteWheel.Wheel.Visible or shop.Enabled or workspace:GetAttribute("NotStartMatch") then
		return true
	end

	return false
end

SpectateController.isSpectateDisabled = isSpectateDisabled
return SpectateController