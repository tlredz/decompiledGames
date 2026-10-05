local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticViewModel)
local BundleSlot = require(Players.LocalPlayer.PlayerScripts.Modules.BundleSlot)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local finalResultsCameraRig = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("FinalResultsCameraRig")
local finalResultsPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("FinalResultsPlayerSlot")
local v = {
	ViewModelName = "Assault Rifle"
}
local Winners = {}
Winners.__index = Winners

function Winners.new(finalResults)
	local self = setmetatable({}, Winners)
	self.Finished = Signal.new()
	self.FinalResults = finalResults
	self.TopFrame = self.FinalResults.DuelInterface.Frame:WaitForChild("Top")
	self.Frame = self.FinalResults.Frame:WaitForChild("Winners")
	self.PlayersFrame = self.Frame:WaitForChild("Players")
	self.TeamFrame = self.Frame:WaitForChild("Team")
	self.TeamText = self.TeamFrame:WaitForChild("Team")
	self.TeamShineFrame = self.TeamFrame:WaitForChild("Shine"):WaitForChild("Frame")
	self.SuperStarterBundleFrame = self.Frame:WaitForChild("SuperStarterBundle")
	self._destroyed = false
	self._skipped = false
	self._animation_cleanup = {}
	self._static_viewmodels = {}
	self._renderstep_id = nil
	self._winning_dueler_ids = {}
	self._displayed_duelers = {}
	self._player_slots = {}
	self._final_winning_animation_hash = 0
	self._outro_sound = nil
	self._superstarterbundle_slot = BundleSlot.new("superstarter_bundle")
	self:_Init()
	return self
end

function Winners:IsFinished()
	return self._skipped
end

function Winners:Skip()
	self._skipped = true
	self.Finished:Fire()
end

function Winners:SetVisible(visible)
	self.Frame.Visible = visible
	task.spawn(self._PlayFinalWinningAnimation, self)

	if not visible and self._outro_sound and self._outro_sound.Volume >= 1.25 then
		task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 2, function(p)
			local v2 = p / 100
			self._outro_sound.Volume = 1.25 + -0.75 * v2
		end)
	end
end

function Winners:Play(p, winning_dueler_ids, p2)
	self.TopFrame.Visible = false
	self._winning_dueler_ids = winning_dueler_ids
	local random = Random.new(p)
	local v2

	if #winning_dueler_ids == 0 then
		v2 = "Tie"
	elseif not self.FinalResults.DuelInterface.ClientDuel.LocalDueler then
		v2 = "Win"
	elseif self.FinalResults.DuelInterface.ClientDuel.LocalDueler and table.find(
		winning_dueler_ids,
		self.FinalResults.DuelInterface.ClientDuel.LocalDueler:Get("DuelerID")
	) then
		v2 = "Win"
	else
		v2 = "Lose"
	end

	for _, v4 in pairs({ winning_dueler_ids, p2 }) do
		for _, v6 in pairs(v4) do
			for k in pairs(self.FinalResults.DuelInterface:GetLoggedClientDuelers()) do
				if k:Get("DuelerID") ~= v6 then
					continue
				end

				table.insert(self._displayed_duelers, k)
				break
			end

			if #self._displayed_duelers >= 5 then
				break
			end
		end

		if #self._displayed_duelers >= 5 then
			break
		end
	end

	local _GetWinnersLocation, v4 = self:_GetWinnersLocation()
	local tracks = {}

	for k, _displayed_dueler in pairs(self._displayed_duelers) do
		local characterModelForCutscene = _displayed_dueler:GetCharacterModelForCutscene()
		characterModelForCutscene.Name = "Dueler" .. k
		characterModelForCutscene:SetPrimaryPartCFrame(v4)
		characterModelForCutscene.Parent = _GetWinnersLocation
		table.insert(self._animation_cleanup, characterModelForCutscene)
		local randomPlayedViewModelDetails = _displayed_dueler:GetRandomPlayedViewModelDetails(random) or v
		local v5 = StaticViewModel.new(randomPlayedViewModelDetails.ViewModelName)

		if v5:HasGripAttachment() then
			v5:DeleteAnimationContextSubModels()
			v5:SetWrap(randomPlayedViewModelDetails.Wrap)
			v5:SetCharm(randomPlayedViewModelDetails.Charm)
			v5:ScaleTo(k == 1 and 1.5 or 1.25)
			v5:InitializeGrip()
			v5:SetParent(characterModelForCutscene)
			self._static_viewmodels[v5] = characterModelForCutscene
		else
			v5:Destroy()
		end

		local v7 = k
		local success, result = pcall(function()
			local track = characterModelForCutscene.Humanoid:LoadAnimation(PreloadController:GetPreloadedAnimation("FinalResultsPlayer" .. v7))
			track:Play(0)
			table.insert(tracks, track)
			table.insert(self._animation_cleanup, track)
		end)

		if success then
			continue
		end

		warn("Player " .. k .. " failed to animate, error:", result)
		characterModelForCutscene.Parent = nil
	end

	local clone = finalResultsCameraRig:Clone()
	clone:PivotTo(v4)
	clone.Parent = self.FinalResults.DuelInterface.ClientDuel.Map.Model:FindFirstChild("Winners")
	local track = nil
	local success, result = pcall(function()
		track = clone.AnimationController:LoadAnimation(PreloadController:GetPreloadedAnimation("FinalResultsCamera"))
		track:Play(0)
		table.insert(self._animation_cleanup, track)
	end)
	local fieldOfView = 40
	local flag = false

	local function tween_camera_fov(p3, _, p4, p5, out)
		if flag then
			return
		end

		local lastTime = tick()

		while tick() < lastTime + p3 do
			fieldOfView = 40 + 30 * TweenService:GetValue((tick() - lastTime) / p3, p5, out)
			RunService.RenderStepped:Wait()

			if flag then
				return
			end
		end

		fieldOfView = p4
	end

	if success then
		if track then
			track:GetMarkerReachedSignal("Start Sine-Out 70"):Connect(function()
				tween_camera_fov(0.9666666666666667, 40, 70, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)
			track:GetMarkerReachedSignal("Start Quad-Out 120"):Connect(function()
				tween_camera_fov(0.75, 70, 120, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			end)
		end
	else
		warn("Camera failed to animate, error:", result)
	end

	self._renderstep_id = "FinalResults" .. HttpService:GenerateGUID(false)
	RunService:BindToRenderStep(self._renderstep_id, CameraController:GetRenderstepPriority() + 1, function(_)
		if not self.FinalResults.DuelInterface.ClientDuel:Get("IsSpectating") then
			return
		end

		local cframe = CFrame.Angles(
			math.sin(tick() * 0.23983 % 6.283185307179586) * 0.017453292519943295,
			math.sin(tick() * 0.372721 % 6.283185307179586) * 0.017453292519943295,
			math.sin(tick() * 0.43123 % 6.283185307179586) * 0.017453292519943295
		)
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		workspace.CurrentCamera.FieldOfView = fieldOfView
		workspace.CurrentCamera.CFrame = clone.Cam.CFrame * cframe

		for k, _static_viewmodel in pairs(self._static_viewmodels) do
			k:GripPivotTo(_static_viewmodel)
		end
	end)
	task.delay(12, function()
		if self._destroyed then
			return
		end

		if track then
			track:AdjustSpeed(0)
		end

		for _, v6 in pairs(tracks) do
			v6:AdjustSpeed(0)
		end
	end)
	local sound = self.FinalResults.DuelInterface:CreateSound("rbxassetid://18221897857", 0, 1, script, true, 60)

	if sound then
		sound.Looped = true
	end

	local duelInterface = self.FinalResults.DuelInterface
	local v6

	if v2 == "Win" then
		v6 = math.random() < 0.5 and "rbxassetid://18239670056" or "rbxassetid://18221725850"
	else
		v6 = math.random() < 0.5 and "rbxassetid://18239670367" or "rbxassetid://18221726246"
	end

	self._outro_sound = duelInterface:RawCreateSound(v6, 1.25, 1, script, true, 15, nil, nil, "Music")
	self:_WaitWhileNotSkipped(1)

	if self._destroyed then
		return
	end

	self:_WaitWhileNotSkipped(5)

	if self._destroyed then
		return
	end

	if not self:IsFinished() then
		self.FinalResults.DuelInterface:CreateSound("rbxassetid://18129776757", 1.25, 1, script, true, 15)
	end

	self:_WaitWhileNotSkipped(0.45)

	if self._destroyed then
		return
	end

	if not self:IsFinished() then
		self.FinalResults.DuelInterface:CreateSound("rbxassetid://18221897857", 1.25, 1, script, true, 15)
	end

	self:_WaitWhileNotSkipped(3.6)

	if self._destroyed then
		return
	end

	if self:IsFinished() then
		flag = true
		fieldOfView = 120

		if track then
			track.TimePosition = 12
			track:AdjustSpeed(0)
		end

		for _, v7 in pairs(tracks) do
			v7.TimePosition = 12
			v7:AdjustSpeed(0)
		end
	end

	local scoresBehavior = self.FinalResults.DuelInterface.ClientDuel:Get("ScoresBehavior")
	local arcadeMode = self.FinalResults.DuelInterface.ClientDuel:Get("ArcadeMode")
	local v7 = not arcadeMode or scoresBehavior == "Teams"
	local visible = not arcadeMode

	for k, _displayed_dueler in pairs(self._displayed_duelers) do
		if not self.FinalResults.DuelInterface.ClientDuel.IsRanked then
			local _ = _displayed_dueler.Player:GetAttribute("StatisticDuelsWinStreak") or 0
		end

		local level

		if not self.FinalResults.DuelInterface.ClientDuel.IsRanked then
			level = _displayed_dueler.Player:GetAttribute("Level") or 0
		end

		local teamColor = DuelLibrary:GetTeamColor(_displayed_dueler:Get("TeamID"))
		local v9 = Utility:SanitizeName(_displayed_dueler.Player.Name)
		local clone2 = finalResultsPlayerSlot:Clone()
		clone2.Placement.Visible = arcadeMode and scoresBehavior == "Duelers"
		clone2.Placement.Title.Text = "#" .. k
		local MVP = clone2.MVP
		MVP.Visible = k == 1 and #winning_dueler_ids > 1 and not clone2.Placement.Visible
		clone2.Background.ImageColor3 = teamColor
		clone2.Player.Username.Text = _displayed_dueler.Player.DisplayName == v9 and "" or "@" .. v9
		clone2.Player.Text = ComplianceController:GetName(_displayed_dueler.Player)
		clone2.Player.Position = clone2.Player.Username.Text == "" and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(
			0.5,
			0,
			0.4,
			0
		)
		clone2.Controls.Image = CONSTANTS.CONTROLS_IMAGES_CENTERED[_displayed_dueler.ClientFighter:Get("Controls")] or ""
		clone2.Level.Visible = level and level > 0
		clone2.Level.Value.Text = level and Utility:PrettyNumber(level) or ""
		clone2.Performance.Eliminations.Value.Text = Utility:PrettyNumber(_displayed_dueler:Get("Eliminations"))
		clone2.Performance.Deaths.Value.Text = Utility:PrettyNumber(_displayed_dueler:Get("Deaths"))
		clone2.Performance.Assists.Value.Text = Utility:PrettyNumber(_displayed_dueler:Get("Assists"))
		clone2.Performance.DamageDealt.Position = visible and UDim2.new(0.333, 0, 3.25, 0) or UDim2.new(0.5, 0, 3.25, 0)
		clone2.Performance.DamageDealt.Title.Text = v7 and "Damage Dealt" or "Points"
		clone2.Performance.DamageDealt.Value.Text = v7 and Utility:PrettyNumber((math.floor(_displayed_dueler:Get("Damage") + 0.5))) or scoresBehavior ~= "Duelers" and "???" or Utility:PrettyNumber(self.FinalResults.DuelInterface.ClientDuel:Get("Scores")[_displayed_dueler:Get("DuelerID")] or 0) or "???"
		clone2.Performance.DamageTaken.Visible = visible
		clone2.Performance.DamageTaken.Value.Text = Utility:PrettyNumber((math.floor(_displayed_dueler:Get("DamageTaken") + 0.5)))
		table.insert(self._player_slots, clone2)

		if self.FinalResults.DuelInterface.ClientDuel.IsRanked then
			local v11

			if _displayed_dueler.IsLocalPlayer then
				v11 = self.FinalResults.Summary:GetLocalPlayerPreviousELO()
			else
				v11 = _displayed_dueler.Player:GetAttribute("DisplayELO")
			end

			RankIcon.new(v11, _displayed_dueler.Player.UserId):SetParent(clone2.Rank)
		end

		local player = clone2.Player
		local username = player.Username
		local controls = clone2.Controls
		local streak = clone2.Streak
		local level2 = clone2.Level
		local rank = clone2.Rank

		local function update()
			local v17 = math.max(player.TextBounds.X, username.TextBounds.X)
			controls.Position = UDim2.new(0.5, v17 / 2, 0.5, 0)
			streak.Position = UDim2.new(0.5, -v17 / 2, 0.5, 0)
			level2.Position = UDim2.new(0.5, -v17 / 2, 0.5, 0)
			rank.Position = UDim2.new(0.5, -v17 / 2, 0.5, 0)
		end

		player:GetPropertyChangedSignal("TextBounds"):Connect(update)
		username:GetPropertyChangedSignal("TextBounds"):Connect(update)
		player.AncestryChanged:Connect(update)
		username.AncestryChanged:Connect(update)
		update()
	end

	self:Skip()
end

function Winners:Destroy()
	self._destroyed = true
	self._final_winning_animation_hash += 1

	for _, v2 in pairs(self._animation_cleanup) do
		v2:Destroy()
	end

	for _, _static_viewmodel in pairs(self._static_viewmodels) do
		_static_viewmodel:Destroy()
	end

	if self._renderstep_id then
		RunService:UnbindFromRenderStep(self._renderstep_id)
		self._renderstep_id = nil
	end

	self.Finished:Destroy()
	self._superstarterbundle_slot:Destroy()
end

function Winners:_PlayFinalWinningAnimation()
	if not self:IsFinished() then
		return
	end

	self._final_winning_animation_hash += 1
	local _final_winning_animation_hash = self._final_winning_animation_hash
	local teamID

	if #self._winning_dueler_ids > 0 and self.FinalResults.DuelInterface.ClientDuel:Get("ScoresBehavior") == "Teams" then
		teamID = self._displayed_duelers[1] and self._displayed_duelers[1]:Get("TeamID")
	else
		teamID = false
	end

	local teamColor = DuelLibrary:GetTeamColor(teamID)
	self.SuperStarterBundleFrame.Visible = false
	self.TeamFrame.Background.ImageColor3 = teamColor
	self.TeamFrame.Visible = teamID and true
	self.TeamFrame.Position = UDim2.new(0.5, 0, 0.16, 40)
	self.TeamFrame:TweenPosition(UDim2.new(0.5, 0, 0.125, 30), "Out", "Quint", 0.25, true)
	self.TeamText.Text = teamID and DuelLibrary.TeamsByID[teamID].TeamName or ""
	self.TeamShineFrame.Position = UDim2.new(-0.5, 0, 0.5, 0)
	self.TeamShineFrame:TweenPosition(
		UDim2.new(1.5, 0, 0.5, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quart,
		1,
		true
	)

	for childName, _player_slot in pairs(self._player_slots) do
		if self._final_winning_animation_hash ~= _final_winning_animation_hash then
			break
		end

		_player_slot.Parent = self.PlayersFrame:FindFirstChild(childName)
		_player_slot.Size = UDim2.new(0.45, 0, 0.075, 0)
		_player_slot.Position = UDim2.new(0.5, 0, 0.4, 0)
		_player_slot:TweenSizeAndPosition(
			UDim2.new(0.75, 0, 0.125, 0),
			UDim2.new(0.5, 0, 0.5, 0),
			"Out",
			"Quint",
			0.25 * childName,
			true
		)
		wait(0.125)
	end
end

function Winners:_GetWinnersLocation()
	local winners = self.FinalResults.DuelInterface.ClientDuel.Map.Model:FindFirstChild("Winners")
	return winners, winners and winners:FindFirstChild("Primary") and winners.Primary.CFrame or CFrame.identity
end

function Winners:_WaitWhileNotSkipped(p)
	local v2 = tick() + p

	while tick() < v2 and not self:IsFinished() do
		RunService.RenderStepped:Wait()
	end
end

function Winners:_Setup()
	self.SuperStarterBundleFrame.Visible = false
	self._superstarterbundle_slot:SetParent(self.SuperStarterBundleFrame)
end

function Winners:_Init()
	self.Finished:Connect(function()
		self:_PlayFinalWinningAnimation()
	end)
	self:_Setup()
end

return Winners