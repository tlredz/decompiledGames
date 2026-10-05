local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local ArcadeController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ArcadeController"))
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
local EliminatedEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("EliminatedEffect"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.BottomStackFrame = UILibrary:GetTo("MainFrame", "BottomStack")
	self.BufferFrame = UILibrary:GetTo("MainFrame", "BottomStack", "SpectateBuffer")
	self.Frame = UILibrary:GetTo("MainFrame", "BottomStack", "Spectate")
	self.Container = self.Frame:WaitForChild("Container")
	self.Background = self.Container:WaitForChild("Background")
	self.NextButton = self.Container:WaitForChild("Next")
	self.LastButton = self.Container:WaitForChild("Last")
	self.ExitButton = self.Container:WaitForChild("Exit")
	self.JoinButton = self.Container:WaitForChild("Join")
	self.JoinButtonOff = self.JoinButton:WaitForChild("Off")
	self.JoinButtonOffTitle = self.JoinButtonOff:WaitForChild("Title")
	self.JoinButtonOn = self.JoinButton:WaitForChild("On")
	self.JoinBubble = self.JoinButtonOn:WaitForChild("Bubble")
	self.PlayerText = self.Container:WaitForChild("Player")
	self.UsernameText = self.Container:WaitForChild("Username")
	self.FreecamButton = self.Container:WaitForChild("Freecam")
	self.ExitFreecamButton = self.Container:WaitForChild("ExitFreecam")
	self._duel_connections = {}
	self._fighter_connections = {}
	self._join_bubble_connection = nil
	self._join_bubble_hash = 0
	self:_Init()
	return self
end

function class:_UpdateBuffer()
	local Y = SpectateController.CurrentSubject and SpectateController.CurrentSubject.FighterInterface and SpectateController.CurrentSubject.FighterInterface.BottomCenter.Layout.AbsoluteContentSize.Y or 0
	self.BufferFrame.Size = UDim2.new(
		1,
		0,
		0,
		(math.max(Y + self.BottomStackFrame.AbsoluteSize.Y * 0.03, self.BottomStackFrame.AbsoluteSize.Y * 0.2))
	)
end

function class:_UpdateJoinCooldown()
	local joinCooldown = ArcadeController:GetJoinCooldown()
	local canJoin = ArcadeController:CanJoin()
	self.JoinButtonOffTitle.Text = joinCooldown > 0 and joinCooldown or "Join"
	self.JoinButtonOff.Visible = not canJoin
	self.JoinButtonOn.Visible = canJoin
end

function class:_Update()
	local v = not Pages.PageSystem.CurrentPage

	if v then
		v = not (SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.LocalDueler and not SpectateController:IsThereValidSubject())
	end

	local v2 = CameraController:GetPublicState() == CameraController.CameraState.States.CustomFreecam
	self.JoinButton.Visible = v and not v2 and SpectateController.CurrentDuelSubject and not SpectateController.CurrentDuelSubject.LocalDueler and SpectateController.CurrentDuelSubject:Get("IsCurrentArcadeDuel")
	self.Background.Visible = v and not v2
	self.LastButton.Visible = v and not v2
	self.NextButton.Visible = v and not v2
	self.PlayerText.Visible = v and not v2
	self.UsernameText.Visible = v and not v2
	self.ExitFreecamButton.Visible = false
	self.PlayerText.Text = v and not SpectateController.CurrentDuelSubject and "" or not SpectateController.CurrentSubject and self.PlayerText.Text or ComplianceController:GetName(SpectateController.CurrentSubject.Player)
	self.UsernameText.Text = v and not SpectateController.CurrentDuelSubject and "" or not SpectateController.CurrentSubject and self.UsernameText.Text or SpectateController.CurrentSubject.Player.DisplayName ~= SpectateController.CurrentSubject.Player.Name and "@" .. SpectateController.CurrentSubject.Player.Name or ""
	self.PlayerText.Position = v and self.UsernameText.Text == "" and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(
		0.5,
		0,
		0.35,
		0
	)
	local freecamButton = self.FreecamButton
	local visible = v and SpectateController.CurrentDuelSubject and not SpectateController.CurrentDuelSubject.LocalDueler

	if visible then
		if ControlsController.CurrentControls == "MouseKeyboard" then
			visible = not v2
		else
			visible = false
		end
	end

	freecamButton.Visible = visible
	self.ExitButton.Visible = v and SpectateController.CurrentDuelSubject and not SpectateController.CurrentDuelSubject.LocalDueler and not v2
	self.Frame.Size = self.ExitButton.Visible and UDim2.new(0.04, 20, 0.08, 40) or UDim2.new(0.04, 20, 0.04, 20)
	local frame = self.Frame
	local visible2 = SpectateController.CurrentDuelSubject and not (SpectateController.CurrentSubject and SpectateController.CurrentSubject.IsLocalPlayer or SpectateController.CurrentDuelSubject:Get("VoteOptions"))

	if visible2 then
		if SpectateController.CurrentDuelSubject:Get("Status") == "GameOver" then
			visible2 = false
		else
			visible2 = not (SpectateController.CurrentDuelSubject.DuelInterface.Buttons:IsAnythingVisible() or SpectateController.CurrentDuelSubject.DuelInterface.Scoreboard:IsOpen() or EliminatedEffect:IsVisible())
		end
	end

	frame.Visible = visible2
	self._join_bubble_hash += 1
	local _join_bubble_hash = self._join_bubble_hash
	task.defer(function()
		if not (self.JoinButton.Visible and self.JoinBubble.Visible and _join_bubble_hash == self._join_bubble_hash) then
			return
		end

		while true do
			if self.JoinBubble:IsDescendantOf(Players) then
				self.JoinBubble:TweenPosition(UDim2.new(0.5, 0, -0.6, 0), "Out", "Sine", 0.5, true)
			end

			wait(0.5)

			if _join_bubble_hash ~= self._join_bubble_hash then
				break
			end

			if self.JoinBubble:IsDescendantOf(Players) then
				self.JoinBubble:TweenPosition(UDim2.new(0.5, 0, -0.25, 0), "In", "Sine", 0.5, true)
			end

			wait(0.5)

			if _join_bubble_hash ~= self._join_bubble_hash then
				break
			end
		end
	end)
end

function class:_ListenFighterSubject()
	for _, _fighter_connection in pairs(self._fighter_connections) do
		_fighter_connection:Disconnect()
	end

	self._fighter_connections = {}

	if not SpectateController.CurrentSubject then
		self:_UpdateBuffer()
		return
	end

	table.insert(self._fighter_connections, SpectateController.CurrentSubject.InterfaceRemoved:Connect(function(_)
		self:_UpdateBuffer()
	end))

	local function interface_added(p)
		table.insert(
			self._fighter_connections,
			p.BottomCenter.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				self:_UpdateBuffer()
			end)
		)
		self:_UpdateBuffer()
	end

	table.insert(self._fighter_connections, SpectateController.CurrentSubject.InterfaceAdded:Connect(interface_added))

	if SpectateController.CurrentSubject.FighterInterface then
		task.spawn(interface_added, SpectateController.CurrentSubject.FighterInterface)
	end

	self:_UpdateBuffer()
end

function class:_ListenDuelSubject()
	for _, _duel_connection in pairs(self._duel_connections) do
		_duel_connection:Disconnect()
	end

	self._duel_connections = {}

	if SpectateController.CurrentDuelSubject then
		table.insert(
			self._duel_connections,
			SpectateController.CurrentDuelSubject:GetDataChangedSignal("VoteOptions"):Connect(function()
				self:_Update()
			end)
		)
		table.insert(
			self._duel_connections,
			SpectateController.CurrentDuelSubject:GetDataChangedSignal("Status"):Connect(function()
				self:_Update()
			end)
		)
		table.insert(
			self._duel_connections,
			SpectateController.CurrentDuelSubject:GetDataChangedSignal("IsCurrentArcadeDuel"):Connect(function()
				self:_Update()
			end)
		)
		table.insert(
			self._duel_connections,
			SpectateController.CurrentDuelSubject.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
				self:_Update()
			end)
		)
		table.insert(
			self._duel_connections,
			SpectateController.CurrentDuelSubject.DuelInterface.Buttons.Updated:Connect(function()
				self:_Update()
			end)
		)
		table.insert(self._duel_connections, SpectateController.SubjectChanged:Connect(function()
			self:_Update()
		end))
		table.insert(self._duel_connections, ControlsController.ControlsChanged:Connect(function()
			self:_Update()
		end))
		table.insert(self._duel_connections, Pages.PageSystem.PagesActivity:Connect(function()
			self:_Update()
		end))
		table.insert(self._duel_connections, ArcadeController.UpdateJoinCooldown:Connect(function()
			self:_UpdateJoinCooldown()
		end))
		self:_Update()
		self:_UpdateBuffer()
		self:_UpdateJoinCooldown()
	else
		self:_Update()
		self:_UpdateBuffer()
	end
end

function class:_Init()
	self.NextButton.MouseButton1Click:Connect(function()
		SpectateController:Next()
	end)
	self.LastButton.MouseButton1Click:Connect(function()
		SpectateController:Last()
	end)
	self.ExitButton.MouseButton1Click:Connect(function()
		SpectateController:Exit()
	end)
	self.FreecamButton.MouseButton1Click:Connect(function()
		CameraController.CameraState:SetCustomFreecamEnabled(true)
	end)
	self.ExitFreecamButton.MouseButton1Click:Connect(function()
		CameraController.CameraState:SetCustomFreecamEnabled(false)
	end)
	self.JoinButton.MouseButton1Click:Connect(function()
		ArcadeController:Join()
		self.JoinBubble.Visible = false
		self:_Update()
	end)
	self.BottomStackFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateBuffer()
	end)
	CameraController.CustomFreecamStateChanged:Connect(function()
		self:_Update()
	end)
	EliminatedEffect.VisibilityChanged:Connect(function()
		self:_Update()
	end)
	SpectateController.SubjectChanged:Connect(function()
		self:_ListenFighterSubject()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_ListenDuelSubject()
	end)
	self:_UpdateBuffer()
	task.spawn(self._ListenDuelSubject, self)
	task.spawn(self._ListenFighterSubject, self)
	ButtonEffect:Add(self.NextButton)
	ButtonEffect:Add(self.LastButton)
	ButtonEffect:Add(self.ExitButton)
	ButtonEffect:Add(self.JoinButton)
	ButtonEffect:Add(self.FreecamButton)
	ButtonEffect:Add(self.ExitFreecamButton)
end

return class._new()