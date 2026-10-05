local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local Buttons = {}
Buttons.__index = Buttons

function Buttons.new(duelInterface)
	local self = setmetatable({}, Buttons)
	self.Updated = Signal.new()
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Buttons")
	self.Container = self.Frame:WaitForChild("Container")
	self.ContentsFrame = self.Container:WaitForChild("Contents")
	self.SwitchItemsFrame = self.ContentsFrame:WaitForChild("SwitchItems")
	self.SwitchItemsButton = self.SwitchItemsFrame:WaitForChild("Button")
	self.SwitchItemsTitle = self.SwitchItemsButton:WaitForChild("Title")
	self.SwitchItemsRemaining = self.SwitchItemsButton:WaitForChild("Remaining")
	self.SwitchItemsBackgroundOn = self.SwitchItemsButton:WaitForChild("BackgroundOn")
	self.SwitchItemsBackgroundOff = self.SwitchItemsButton:WaitForChild("BackgroundOff")
	self.SwitchItemsLastPickedFrame = self.SwitchItemsButton:WaitForChild("LastPickedWeapons")
	self.LeaveDuelFrame = self.ContentsFrame:WaitForChild("LeaveDuel")
	self.LeaveDuelButton = self.LeaveDuelFrame:WaitForChild("Button")
	self.RespawnNowFrame = self.ContentsFrame:WaitForChild("RespawnNow")
	self.RespawnNowButton = self.RespawnNowFrame:WaitForChild("Button")
	self.RespawnNowVisualsFrame = self.RespawnNowButton:WaitForChild("Visuals")
	self.RespawnNowBar = self.RespawnNowVisualsFrame:WaitForChild("Bar"):WaitForChild("Bar")
	self.RespawnInputsFrame = self.RespawnNowVisualsFrame:WaitForChild("Inputs")
	self.RespawnVisualsTitle = self.RespawnNowVisualsFrame:WaitForChild("Title")
	self.RespawnNowWaitingFrame = self.RespawnNowButton:WaitForChild("Waiting")
	self.RespawnNowWaitingDotsFrame = self.RespawnNowWaitingFrame:WaitForChild("Dots")
	self.SwitchTeamFrame = self.ContentsFrame:WaitForChild("SwitchTeam")
	self.SwitchTeamButton = self.SwitchTeamFrame:WaitForChild("Button")
	self.SwitchTeamText = self.SwitchTeamButton:WaitForChild("Team")
	self.SwitchTeamBackground = self.SwitchTeamButton:WaitForChild("Background")
	self._destroyed = false
	self._respawn_now_animation_hash = 0
	self._respawn_now_visible_until = 0
	self._respawn_now_is_timer_only = false
	self._last_picked_weapon_images = {}
	self:_Init()
	return self
end

function Buttons:IsLeaveDuelVisible()
	return self.LeaveDuelFrame.Visible
end

function Buttons:IsSwitchItemsVisible()
	return self.SwitchItemsFrame.Visible
end

function Buttons:IsRespawnNowVisible()
	return self.RespawnNowFrame.Visible
end

function Buttons:IsSwitchTeamVisible()
	return self.SwitchTeamFrame.Visible
end

function Buttons:IsAnythingVisible()
	return self:IsLeaveDuelVisible() or self:IsSwitchItemsVisible() or self:IsRespawnNowVisible() or self:IsSwitchTeamVisible()
end

function Buttons:SwitchItemsRequest()
	if self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler:GetStaggeredSpawnsTurn() then
		Pages:OpenPickWeaponsPage()
	else
		ReplicatedStorage.Remotes.Duels.SwitchItems:FireServer()
	end
end

function Buttons:RespawnNowRequest()
	if self._respawn_now_is_timer_only then
		return
	end

	self.RespawnNowWaitingFrame.Visible = true
	self.RespawnNowVisualsFrame.Visible = false
	ReplicatedStorage.Remotes.Duels.RespawnNow:FireServer()
end

function Buttons:RespawnNowAnimation(respawn_now_is_timer_only)
	local respawnDelay = self.DuelInterface.ClientDuel:Get("RespawnDelay") or 0
	self._respawn_now_visible_until = tick() + respawnDelay
	self._respawn_now_is_timer_only = respawn_now_is_timer_only
	self._respawn_now_animation_hash += 1
	local _respawn_now_animation_hash = self._respawn_now_animation_hash
	self.RespawnInputsFrame.Visible = not self._respawn_now_is_timer_only
	self.RespawnVisualsTitle.Text = self._respawn_now_is_timer_only and "Respawning" or "Respawn"
	self.RespawnVisualsTitle.Size = self._respawn_now_is_timer_only and UDim2.new(0.9, 0, 0.5, 0) or UDim2.new(
		0.9,
		0,
		0.575,
		0
	)
	self.RespawnNowWaitingFrame.Visible = false
	self.RespawnNowVisualsFrame.Visible = true
	self.RespawnNowBar.Size = UDim2.new(0, 0, 1, 0)
	self.RespawnNowBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", respawnDelay, true, function()
		wait(1)

		if _respawn_now_animation_hash ~= self._respawn_now_animation_hash then
			return
		end

		self.RespawnNowBar.Size = UDim2.new(0, 0, 1, 0)
	end)
	self:Update()
end

function Buttons:Update()
	for _, _last_picked_weapon_image in pairs(self._last_picked_weapon_images) do
		_last_picked_weapon_image:Destroy()
	end

	self._last_picked_weapon_images = {}
	local visible = self.LeaveDuelFrame.Visible
	local visible2 = self.SwitchItemsFrame.Visible
	local visible3 = self.SwitchItemsBackgroundOn.Visible
	local visible4 = self.SwitchItemsBackgroundOff.Visible
	local visible5 = self.RespawnNowFrame.Visible
	local visible6 = self.SwitchTeamFrame.Visible
	local v = self.DuelInterface.ClientDuel.LocalDueler and not (self.DuelInterface:IsPageOpen() or self.DuelInterface.Voting:IsOpen())
	local v2 = self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler.ClientFighter and self.DuelInterface.ClientDuel.LocalDueler.ClientFighter:IsAlive()
	local v3 = not v2 or self.DuelInterface.ClientDuel:Get("WasSelfQueued") or self.DuelInterface.ClientDuel:Get("IsCurrentArcadeDuel") and self.DuelInterface.Scoreboard:IsOpen()
	local visible7 = v and v3 and self.DuelInterface.ClientDuel:CanLeave()

	if visible7 then
		if self.DuelInterface.ClientDuel:Get("Status") == "GameOver" then
			visible7 = false
		else
			visible7 = self.DuelInterface.Scoreboard:IsOpen()
		end
	end

	self.LeaveDuelFrame.Visible = visible7
	local visible8 = v and not v2 and tick() < self._respawn_now_visible_until
	self.RespawnNowFrame.Visible = visible8
	local v6 = not v and 0 or (self.DuelInterface.ClientDuel.LocalDueler:Get("SwitchItemsMax") or 1e999) - self.DuelInterface.ClientDuel.LocalDueler:Get("SwitchItemsCount")
	local isInvincible = self.DuelInterface.ClientDuel:Get("CanSwitchItems") == "WhileInvincible" and v2 and self.DuelInterface.ClientDuel.LocalDueler.ClientFighter.Entity:Get("IsInvincible") or self.DuelInterface.ClientDuel:Get("CanSwitchItems") == true
	local staggeredSpawnsTurn = v and self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler:GetStaggeredSpawnsTurn()
	local visible9

	if v then
		if v2 and isInvincible or staggeredSpawnsTurn then
			visible9 = not self.DuelInterface.ClientDuel.LocalDueler.ClientFighter:Get("CanPickWeapons")

			if visible9 then
				if self.DuelInterface.ClientDuel:Get("ArcadeMode") or self.DuelInterface.ClientDuel:Get("RoundNum") > 1 or staggeredSpawnsTurn then
					if self.DuelInterface.ClientDuel:Get("Status") == "GameOver" then
						visible9 = false
					else
						visible9 = GameplayUtility:SwitchingWeaponsMakesSense(
							self.DuelInterface.ClientDuel.LocalDueler.ClientFighter,
							PlayerDataController
						)
					end
				else
					visible9 = staggeredSpawnsTurn
				end
			end
		else
			visible9 = staggeredSpawnsTurn
		end
	else
		visible9 = v
	end

	local v8 = v6 < 1e999 or staggeredSpawnsTurn
	self.SwitchItemsFrame.Visible = visible9
	self.SwitchItemsTitle.Position = v8 and UDim2.new(0.5, 0, 0.375, 0) or UDim2.new(0.5, 0, 0.5, 0)
	self.SwitchItemsTitle.Text = staggeredSpawnsTurn and "Pick Weapons" or "Switch Weapons"
	self.SwitchItemsRemaining.Text = staggeredSpawnsTurn and "before you spawn" or not v8 and "" or string.format(
		"%s switch%s remaining",
		v6,
		v6 == 1 and "" or "es"
	)
	self.SwitchItemsBackgroundOn.Visible = staggeredSpawnsTurn or v6 > 0
	self.SwitchItemsBackgroundOff.Visible = not self.SwitchItemsBackgroundOn.Visible

	if staggeredSpawnsTurn then
		for k, v9 in pairs(self.DuelInterface.ClientDuel.LocalDueler.ClientFighter:Get("LastPickedWeapons") or {}) do
			local weaponData = PlayerDataController:GetWeaponData(v9)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.new(3, 0, 3, 0)
			imageLabel.BackgroundTransparency = 1
			imageLabel.LayoutOrder = k
			imageLabel.ZIndex = k
			imageLabel.Image = weaponData and ItemLibrary:GetViewModelImageFromWeaponData(weaponData) or ItemLibrary:GetViewModelImage(v9) or ""
			imageLabel.Parent = self.SwitchItemsLastPickedFrame
			table.insert(self._last_picked_weapon_images, imageLabel)
		end
	end

	local _GetNextTeamID = self:_GetNextTeamID()
	local v9 = self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel:CountTeam(self.DuelInterface.ClientDuel.LocalDueler:Get("TeamID"))
	local v10 = _GetNextTeamID and self.DuelInterface.ClientDuel:CountTeam(_GetNextTeamID)
	local visible10 = v and visible9 and _GetNextTeamID and self.DuelInterface.ClientDuel:Get("ArcadeMode") and self.DuelInterface.ClientDuel.LocalDueler and not self.DuelInterface.ClientDuel.LocalDueler:Get("JustSwitchedTeam") and self.DuelInterface.Scoreboard:IsOpen()

	if visible10 then
		if v9 then
			if v10 then
				if v9 > 1 then
					v10 = v10 < v9
				else
					v10 = false
				end
			end
		else
			v10 = v9
		end
	else
		v10 = visible10
	end

	self.SwitchTeamFrame.Visible = visible10
	self.SwitchTeamText.Text = not _GetNextTeamID and "" or "to " .. DuelLibrary.TeamsByID[_GetNextTeamID].TeamName
	self.SwitchTeamBackground.ImageColor3 = v10 and DuelLibrary:GetTeamColor(_GetNextTeamID) or DuelLibrary.EMPTY_TEAM_COLOR

	if self.LeaveDuelFrame.Visible ~= visible or self.SwitchItemsFrame.Visible ~= visible2 or self.SwitchItemsBackgroundOn.Visible ~= visible3 or self.SwitchItemsBackgroundOff.Visible ~= visible4 or self.RespawnNowFrame.Visible ~= visible5 or self.SwitchTeamFrame.Visible ~= visible6 then
		self.Updated:Fire()
	end
end

function Buttons:Destroy()
	self._destroyed = true
	self.Updated:Destroy()
end

function Buttons:_GetNextTeamID()
	local teamID = self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler:Get("TeamID")
	local numTeams = self.DuelInterface.ClientDuel:Get("NumTeams")

	if teamID and numTeams and not (numTeams <= 1) then
		return DuelLibrary.Teams[DuelLibrary.TeamsByID[teamID].TeamIndex % numTeams + 1].TeamID
	end
end

function Buttons:_UpdateRespawnNowDots()
	if self.RespawnNowWaitingFrame.Visible then
		self.RespawnNowWaitingDotsFrame:AddTag("UILoadingDots")
	else
		self.RespawnNowWaitingDotsFrame:RemoveTag("UILoadingDots")
	end
end

function Buttons:_UpdateVisibility()
	self.Frame.Visible = not self.DuelInterface.FinalResults:IsActive()
end

function Buttons:_UpdateParent()
	if self._destroyed then
		return
	end

	pcall(function()
		self.ContentsFrame.Parent = self.DuelInterface.Scoreboard:IsOpen() and self.DuelInterface.Scoreboard.ButtonsContainer or self.Container
	end)
end

function Buttons:_Init()
	self.SwitchItemsButton.MouseButton1Click:Connect(function()
		self:SwitchItemsRequest()
	end)
	self.RespawnNowButton.MouseButton1Click:Connect(function()
		self:RespawnNowRequest()
	end)
	self.LeaveDuelButton.MouseButton1Click:Connect(function()
		self.DuelInterface.ClientDuel:LeaveDuelRequest()
	end)
	self.SwitchTeamButton.MouseButton1Click:Connect(function()
		if not ReplicatedStorage.Remotes.Duels.SwitchTeam:InvokeServer(self:_GetNextTeamID()) then
			Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		end
	end)
	self.DuelInterface.FinalResults.Activated:Connect(function()
		self:_UpdateVisibility()
	end)
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:Update()
		self:_UpdateParent()
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:Update()
	end)
	self.RespawnNowWaitingFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateRespawnNowDots()
	end)
	self:_UpdateVisibility()
	task.defer(self._UpdateParent, self)
	ButtonEffect:Add(self.LeaveDuelButton)
	ButtonEffect:Add(self.RespawnNowButton)
	ButtonEffect:Add(self.SwitchItemsButton)
	ButtonEffect:Add(self.SwitchTeamButton)
end

return Buttons