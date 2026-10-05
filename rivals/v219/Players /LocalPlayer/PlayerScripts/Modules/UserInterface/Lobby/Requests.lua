local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local QueuePadController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("QueuePadController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local SocialController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SocialController"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local PlayerList = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("PlayerList"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local JoinQueuePadSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("JoinQueuePadSlot"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local requestChallengeSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RequestChallengeSlot")
local requestPartySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RequestPartySlot")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby", "Requests")
	self.Container = self.Frame:WaitForChild("Container")
	self.PlayerListBuffer = self.Container:WaitForChild("PlayerListBuffer")
	self:_Init()
	return self
end

function class:SendRequest(p2, instance, duration, p3, callback)
	if not p2 then
		return
	end

	local fighter = FighterController:GetFighter(p2)
	local clone = instance:Clone()
	clone.Container.Background.ImageColor3 = UILibrary.BUTTON_BACKGROUND_COLOR
	clone.Container.Background.ImageTransparency = UILibrary.BUTTON_BACKGROUND_TRANSPARENCY
	clone.Container.DisplayName.Text = ComplianceController:GetName(p2)
	clone.Container.DisplayName.Controls.Image = CONSTANTS.CONTROLS_IMAGES[fighter and fighter:Get("Controls")] or ""
	clone.Container.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, p2.UserId)
	clone.Parent = self.Container
	ButtonEffect:Add(clone.Container.Accept)
	ButtonEffect:Add(clone.Container.Decline)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function remove()
		clone:Destroy()

		if p3 then
			PlayerList:SetRequestDuration(p2, p3, 0)
		end
	end

	clone.Container.Decline.MouseButton1Click:Connect(remove)
	task.delay(duration, remove)
	clone.Container.Accept.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end

		remove() -- equivalent call inferred; original call site unknown
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		clone.Container.DisplayName.Controls.Position = UDim2.new(0, clone.Container.DisplayName.TextBounds.X, 0.5, 0)
	end

	clone.Container.DisplayName:GetPropertyChangedSignal("TextBounds"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	clone.Container.Position = UDim2.new(4, 0, 0, 0)
	clone.Container:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.5, true)
	clone.Container.Timeout.Bar.Size = UDim2.new(1, 0, 1, 0)
	clone.Container.Timeout.Bar:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Linear", duration, true)

	if p3 then
		PlayerList:SetRequestDuration(p2, p3, duration)
	end
end

function class:ChallengeRequest(p, p2)
	if not self:_CanReceiveRequest(p, "Challenge Requests") then
		return
	end

	self:SendRequest(p, requestChallengeSlot, p2, "Challenge", function()
		ReplicatedStorage.Remotes.Misc.AcceptChallengeRequest:FireServer(p)
	end)
end

function class:PartyRequest(p, p2)
	if not self:_CanReceiveRequest(p, "Party Invites") then
		return
	end

	self:SendRequest(p, requestPartySlot, p2, "Party", function()
		ReplicatedStorage.Remotes.Matchmaking.AcceptPartyInvite:FireServer(p)
	end)
end

function class:_UpdatePlayerList()
	local v = PlayerList.Elements.Frame.AbsolutePosition.Y - PlayerList.Frame.AbsolutePosition.Y + (not PlayerList.IsOpen and -4 or PlayerList.Elements.Frame.AbsoluteSize.Y)
	self.PlayerListBuffer:TweenSize(UDim2.new(1, 0, 0, v), "Out", "Quint", 0.25, true)
	self.Container.Size = UDim2.new(
		0,
		PlayerList.Elements.Frame.AbsoluteSize.X,
		0,
		PlayerList.Elements.Frame.AbsoluteSize.X
	)
end

function class:_UpdateVisibility()
	local v = not (Pages.PageSystem.CurrentPage or Equipment.IsOpen or Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen)
	local container = self.Container
	local v2

	if v then
		v2 = UDim2.new(1, 0, 0, 0)
	else
		v2 = UDim2.new(2, 20, 0, 0)
	end

	container:TweenPosition(v2, "Out", "Quint", 0.25, true)
end

function class:_CanReceiveRequest(p, p2)
	local setting = PlayerDataController:GetSetting(p2)
	return setting == "Everyone" or setting == "Friends" and SocialController:IsFriendsWith(p.UserId)
end

function class:_QueuePadAdded(p2)
	local new = JoinQueuePadSlot.new(p2)
	new.Frame.Parent = self.Container
end

function class:_Init()
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerList.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdatePlayerList()
	end)
	PlayerList.Elements.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdatePlayerList()
	end)
	PlayerList.Elements.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdatePlayerList()
	end)
	PlayerList.OpenedChanged:Connect(function()
		self:_UpdatePlayerList()
	end)
	QueuePadController.ObjectAdded:Connect(function(p)
		self:_QueuePadAdded(p)
	end)

	for _, object2 in pairs(QueuePadController.Objects) do
		task.defer(self._QueuePadAdded, self, object2)
	end

	self:_UpdateVisibility()
	self:_UpdatePlayerList()
end

return class._new()