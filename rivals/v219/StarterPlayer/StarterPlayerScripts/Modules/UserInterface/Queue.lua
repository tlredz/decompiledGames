local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local SocialController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SocialController"))
local QueuePadController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("QueuePadController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("TeammateSlot"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local localQueuePlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LocalQueuePlayerSlot")
local titleVS = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TitleVS")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.VisibilityChanged = Signal.new()
	self.Frame = UILibrary:GetTo("MainFrame", "Queue")
	self.Container = self.Frame:WaitForChild("Container")
	self._cleanup = {}
	self._countdown_hash = 0
	self._last_countdown_sound = nil
	self:_Init()
	return self
end

function class.IsVisible(p)
	return p.Frame.Visible
end

function class:_UpdateInviteFrame()
	self.Container.Invite.Visible = SocialController.CanSendGameInvite and not self.Container.Countdown.Visible
end

function class:_UpdateWaitingBackground()
	self.Container.Waiting.Background.Size = UDim2.new(
		0,
		self.Container.Background.AbsoluteSize.X,
		0,
		self.Container.Background.AbsoluteSize.Y
	)
end

function class:_StartCountdown()
	self._countdown_hash += 1
	local _countdown_hash = self._countdown_hash
	self.Container.Countdown.Visible = true
	self.Container.Waiting.Visible = false
	self.Container.Start.Visible = false

	for i = 3, 1, -1 do
		if _countdown_hash ~= self._countdown_hash then
			break
		end

		self.Container.Countdown.Value.Text = i
		self._last_countdown_sound = Utility:CreateSound("rbxassetid://17259538274", 0.5, 1, script, true, 5)
		local lastTime = tick()

		while tick() < lastTime + 0.375 do
			if _countdown_hash ~= self._countdown_hash then
				return
			end

			local v = (tick() - lastTime) / 0.375
			local value = TweenService:GetValue(v, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local value2 = TweenService:GetValue(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			self.Container.Countdown.Value.Size = UDim2.new(1, 0, 1.25 - 0.625 * value)
			self.Container.Countdown.Glow.ImageTransparency = 0.875 - 0.25 * value2
			self.Container.Countdown.Glow.Size = UDim2.new(value2, 0, value2, 0)
			RunService.RenderStepped:Wait()
		end

		local lastTime2 = tick()

		while tick() < lastTime2 + 0.625 do
			if _countdown_hash ~= self._countdown_hash then
				return
			end

			local v = (tick() - lastTime2) / 0.625
			local value = TweenService:GetValue(v, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			local value2 = TweenService:GetValue(v, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			self.Container.Countdown.Value.Size = UDim2.new(1, 0, 0.625 - 0.625 * value)
			self.Container.Countdown.Glow.ImageTransparency = 0.625 + 0.25 * value2
			RunService.RenderStepped:Wait()
		end
	end
end

function class:_StopCountdown()
	self._countdown_hash += 1
	self.Container.Countdown.Visible = false

	if self._last_countdown_sound then
		self._last_countdown_sound:Destroy()
		self._last_countdown_sound = nil
	end
end

function class:_Update()
	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self._cleanup = {}
	local queuePad = QueuePadController:GetQueuePad(Players.LocalPlayer)
	self.Frame.Visible = queuePad and true or false
	self.VisibilityChanged:Fire()

	if self.Frame.Visible then
		local clientFightersWaiting = queuePad:GetClientFightersWaiting()
		local v = 0
		local count = 0
		local count2 = 0
		local count3 = 0
		local count4 = 0
		local count5 = 0
		local v2 = 0

		for i = 1, queuePad:Get("NumTeams") do
			local v3 = clientFightersWaiting[i]
			local flag = false
			local flag2 = false
			v = math.max(v, #v3)

			if table.find(v3, FighterController.LocalFighter) then
				v2 = #v3 or v2
			end

			for i2 = 1, queuePad:Get("InfinitePlayersPerTeam") and 1e999 or queuePad:Get("PlayersPerTeam") do
				local v4 = v3[i2]
				local clone, layoutOrder, v6

				if not v4 and queuePad:Get("InfinitePlayersPerTeam") then
					if flag then
						break
					end

					flag = true
				end

				clone = localQueuePlayerSlot:Clone()

				if queuePad:Get("NumTeams") == 2 and i == 1 then
					layoutOrder = -count2 or count2
				else
					layoutOrder = count2
				end

				clone.LayoutOrder = layoutOrder
				clone.Container.Ready.Visible = v4 and queuePad:IsReady(v4.Player)
				clone.Parent = self.Container.Details
				table.insert(self._cleanup, clone)
				count4 += 1
				count2 += 1

				if v4 then
					clone.Container.Dots:Destroy()
					v6 = TeammateSlot.new(
						v4.Player.UserId,
						v4:Get("Controls"),
						1,
						false,
						true,
						v4.Player:GetAttribute("StatisticDuelsWinStreak"),
						v4.Player:GetAttribute("Level")
					)
					v6.SlotFrame.Container.Background.Visible = false
					v6.SlotFrame.Parent = clone.Container
					table.insert(self._cleanup, v6)
					count5 += 1
					flag2 = true
				else
					clone.Container.Dots:AddTag("UILoadingDots")
				end
			end

			if i ~= queuePad:Get("NumTeams") then
				local clone = titleVS:Clone()
				clone.LayoutOrder = count2
				clone.Parent = self.Container.Details
				table.insert(self._cleanup, clone)
				count3 += 1
				count2 += 1
			end

			if flag2 then
				count += 1
			end
		end

		self.Frame.UIScale.Scale = math.clamp(1.3 - count4 * 0.05, 0.5, 1)
		self.Container.Background.Size = UDim2.new(count3 * 0.7 + 0.125 + count4 * 0.875, 0, 1, 0)
		local ready = self.Container.Ready
		local visible = not queuePad:Get("InfinitePlayersPerTeam")

		if visible then
			if count == queuePad:Get("NumTeams") and v2 < v then
				visible = not queuePad:IsReady(FighterController.LocalFighter.Player)
			else
				visible = false
			end
		end

		ready.Visible = visible
		local start = self.Container.Start
		local infinitePlayersPerTeam = queuePad:Get("InfinitePlayersPerTeam")

		if infinitePlayersPerTeam then
			if count > 1 then
				infinitePlayersPerTeam = CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId)
			else
				infinitePlayersPerTeam = false
			end
		end

		start.Visible = infinitePlayersPerTeam
		local waiting = self.Container.Waiting
		local infinitePlayersPerTeam2 = queuePad:Get("InfinitePlayersPerTeam")

		if infinitePlayersPerTeam2 then
			if count > 1 then
				infinitePlayersPerTeam2 = not CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId)
			else
				infinitePlayersPerTeam2 = false
			end
		end

		waiting.Visible = infinitePlayersPerTeam2

		if queuePad:Get("IsStarting") then
			self:_StartCountdown()
		else
			self:_StopCountdown()
		end
	else
		self.Frame.UIScale.Scale = 1
		self:_StopCountdown()
	end
end

function class:_WaitForLocalFighter()
	FighterController:WaitForLocalFighter()
	self:_Update()
end

function class:_Init()
	self.Container.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateWaitingBackground()
	end)
	self.Container.Countdown:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateInviteFrame()
	end)
	self.Container.Start.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.PrivateServer.StartQueuePad:FireServer()
	end)
	self.Container.Ready.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.Misc.QueueReady:FireServer()
	end)
	self.Container.Invite.Button.MouseButton1Click:Connect(function()
		SocialController:PromptFriendInvite()
	end)
	QueuePadController.LocalPlayerActivity:Connect(function()
		self:_Update()
	end)
	SocialController.CanSendGameInviteChanged:Connect(function()
		self:_UpdateInviteFrame()
	end)
	self:_Update()
	self:_UpdateInviteFrame()
	self:_UpdateWaitingBackground()
	task.spawn(self._WaitForLocalFighter, self)
	ButtonEffect:Add(self.Container.Start)
	ButtonEffect:Add(self.Container.Ready)
	ButtonEffect:Add(self.Container.Invite.Button, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

return class._new()