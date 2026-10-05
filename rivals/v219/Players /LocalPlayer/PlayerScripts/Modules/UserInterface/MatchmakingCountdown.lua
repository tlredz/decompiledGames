local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MatchmakingController"))
local Notifications = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Notifications"))
local GlowyBackground = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GlowyBackground"))
local ChickenFooter = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ChickenFooter"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.VisibilityChanged = Signal.new()
	self.Frame = UILibrary:GetTo("MatchmakingCountdown")
	self.Container = self.Frame:WaitForChild("Container")
	self.CountdownFrame = self.Container:WaitForChild("Countdown")
	self.CountdownText = self.CountdownFrame:WaitForChild("Value")
	self.CountdownGlow = self.CountdownFrame:WaitForChild("Glow")
	self.WaitingFrame = self.Container:WaitForChild("Waiting")
	self.WaitingDotsFrame = self.WaitingFrame:WaitForChild("Dots")
	self._countdown_hash = 0
	self._aborted_notification = false
	self._cover_part = Instance.new("Part")
	self._cover_connection = nil
	self._chicken_footer = ChickenFooter.new()
	self._glowy_background = GlowyBackground.new("MatchmakingCountdown")
	self:_Init()
	return self
end

function class.IsVisible(p)
	return p.Frame.Visible
end

function class:_Countdown()
	self._countdown_hash += 1
	local _countdown_hash = self._countdown_hash
	local matchmadeCountdown = MatchmakingController:Get("MatchmadeCountdown") or 0
	self.CountdownFrame.Visible = matchmadeCountdown > 0
	self.CountdownText.Text = matchmadeCountdown

	if matchmadeCountdown <= 0 then
		return
	end

	Utility:CreateSound("rbxassetid://17259538274", 0.5, 1, script, true, 5)
	local lastTime = tick()

	while tick() < lastTime + 0.375 do
		if _countdown_hash ~= self._countdown_hash then
			return
		end

		local v = (tick() - lastTime) / 0.375
		local value = TweenService:GetValue(v, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local value2 = TweenService:GetValue(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		self.CountdownText.Size = UDim2.new(1, 0, 1.25 - 0.625 * value)
		self.CountdownGlow.ImageTransparency = 0.875 - 0.25 * value2
		self.CountdownGlow.Size = UDim2.new(value2, 0, value2, 0)
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
		self.CountdownText.Size = UDim2.new(1, 0, 0.625 - 0.625 * value)
		self.CountdownGlow.ImageTransparency = 0.625 + 0.25 * value2
		RunService.RenderStepped:Wait()
	end

	if _countdown_hash ~= self._countdown_hash then
		return
	end

	self.CountdownFrame.Visible = false
end

function class:_Update()
	local matchmadeStatus = MatchmakingController:Get("MatchmadeStatus")
	local matchmadeExpectedPlayers = MatchmakingController:Get("MatchmadeExpectedPlayers")
	local visible = CONSTANTS.IS_MATCHMAKING_SERVER and not MatchmakingController:Get("MatchmadeGameOver") and (matchmadeStatus == "Waiting" or matchmadeStatus == "Starting")
	local visible2 = visible and matchmadeStatus == "Waiting"
	self.Frame.Visible = visible
	self.WaitingFrame.Visible = visible2
	self._glowy_background:SetEnabled(visible, visible)

	if visible2 then
		self.WaitingDotsFrame:AddTag("UILoadingDots")
		self._chicken_footer:Show()
		self._chicken_footer:SetStatus("Waiting For Players")
		self._chicken_footer:EnableFunFacts()
		self._chicken_footer:SetTimer((MatchmakingController:Get("MatchmadeConnectedPlayers") or 0) .. " / " .. (matchmadeExpectedPlayers or "???"))
	else
		self.WaitingDotsFrame:RemoveTag("UILoadingDots")
		self._chicken_footer:Hide()
	end

	if visible and not self._cover_connection then
		self._cover_part.Parent = workspace
		self._cover_connection = RunService.RenderStepped:Connect(function()
			self._cover_part.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -1)
		end)
	elseif not visible and self._cover_connection then
		self._cover_part.Parent = nil
		self._cover_connection:Disconnect()
		self._cover_connection = nil
	end

	if matchmadeStatus == "Aborted" and not self._aborted_notification then
		self._aborted_notification = true
		Notifications:Queue("Duel Cancelled", "Not enough players connected", "rbxassetid://18553001997", nil, 0.75)
	end
end

function class:_Setup()
	self._cover_part.Size = createVector(10, 10, 0)
	self._cover_part.Anchored = true
	self._cover_part.CanCollide = false
	self._cover_part.CanTouch = false
	self._cover_part.CanQuery = false
	self._cover_part.Color = Color3.fromRGB(0, 0, 0)
	self._cover_part.Material = Enum.Material.Neon
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.AlwaysOnTop = true
	surfaceGui.Face = Enum.NormalId.Back
	surfaceGui.Parent = self._cover_part
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.Parent = surfaceGui
	self._chicken_footer:SetParent(self.Container)
	self._glowy_background:SetParent(self.Container)
end

function class:_Init()
	self.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self.VisibilityChanged:Fire()
	end)
	MatchmakingController:GetDataChangedSignal("MatchmadeGameOver"):Connect(function()
		self:_Update()
	end)
	MatchmakingController:GetDataChangedSignal("MatchmadeStatus"):Connect(function()
		self:_Update()
	end)
	MatchmakingController:GetDataChangedSignal("MatchmadeCountdown"):Connect(function()
		self:_Update()
		self:_Countdown()
	end)
	MatchmakingController:GetDataChangedSignal("MatchmadeConnectedPlayers"):Connect(function()
		self:_Update()
		self:_Countdown()
	end)
	MatchmakingController:GetDataChangedSignal("MatchmadeExpectedPlayers"):Connect(function()
		self:_Update()
		self:_Countdown()
	end)
	self:_Setup()
	task.defer(self._Update, self)
	task.defer(self._Countdown, self)
end

return class._new()