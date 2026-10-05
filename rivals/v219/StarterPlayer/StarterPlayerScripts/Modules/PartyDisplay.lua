local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PartyController"))
local Matchmaking = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Lobby"):WaitForChild("Matchmaking"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local partyMemberSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PartyMemberSlot")
local PartyDisplay = {}
PartyDisplay.__index = PartyDisplay

function PartyDisplay.new(frame, inverted_order)
	local self = setmetatable({}, PartyDisplay)
	self.Frame = frame
	self._connections = {}
	self._slots = {}
	self._inverted_order = inverted_order
	self:_Init()
	return self
end

function PartyDisplay:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self:_Clear()
end

function PartyDisplay:_Clear()
	for _, _slot in pairs(self._slots) do
		_slot:Destroy()
	end

	self._slots = {}
end

function PartyDisplay:_Generate()
	self:_Clear()
	local currentParty = PartyController.CurrentParty or { Players.LocalPlayer }

	local function generate_slot(p, p2)
		local clone = partyMemberSlot:Clone()
		clone.Button.Icon.Image = not p2 and "" or string.format(CONSTANTS.HEADSHOT_IMAGE, p2.UserId)
		clone.Button.Leader.Visible = PartyController.CurrentParty and p == 1
		clone.Button.Invite.Visible = not p2
		clone.Button.Inputs.Visible = not p2
		clone.Button.Inputs.Gamepad.Keybind.Position = self._inverted_order and UDim2.new(0.5, 0, -0.25, 0) or UDim2.new(
			1.25,
			0,
			0.5,
			0
		)
		clone.Size = p == 1 and UDim2.new(1, 0, 1, 0) or UDim2.new(0.75, 0, 0.75, 0)
		clone.LayoutOrder = p * (self._inverted_order and -1 or 1)
		clone.Button.MouseButton1Click:Connect(function()
			if Matchmaking:IsVisible() then
				return
			end

			local name = Pages.PageSystem.CurrentPage and Pages.PageSystem.CurrentPage.Name
			Pages.PageSystem:OpenPage("Party", true)
			Pages.PageSystem:WaitForPage("Party"):RedirectTo(name)
		end)
		clone.Parent = self.Frame
		table.insert(self._slots, clone)
		ButtonEffect:Add(clone.Button)
	end

	for k, v in pairs(currentParty) do
		generate_slot(k, v)
	end

	if #currentParty < CONSTANTS.MAX_PARTY_SIZE and PartyController:IsPartyLeader() then
		generate_slot(#currentParty + 1, nil)
	end
end

function PartyDisplay:_Init()
	table.insert(self._connections, PartyController.PartyChanged:Connect(function()
		self:_Generate()
	end))
	self:_Generate()
end

return PartyDisplay