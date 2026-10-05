local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local eliminationSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EliminationSlot")
local EliminationSlots = {}
EliminationSlots.__index = EliminationSlots

function EliminationSlots.new(fighterInterface)
	local self = setmetatable({}, EliminationSlots)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.Frame:WaitForChild("EliminationSlots")
	self._destroyed = false
	self._connections = {}
	self._reference_frame = UILibrary:GetTo("MainFrame", "BottomStack", "EliminationSlots")
	self._elimination_queue = {}
	self._elimination_queue_playing = false
	self._elimination_chain = 0
	self:_Init()
	return self
end

function EliminationSlots.SetVisible(p, visible)
	p.Frame.Visible = visible
end

function EliminationSlots:Refresh()
	self.Frame.Position = UDim2.new(0.5, 0, 0, self._reference_frame.AbsolutePosition.Y)
end

function EliminationSlots:Clear()
	self._elimination_chain = 0
end

function EliminationSlots:Create(...)
	if not self.FighterInterface:IsActive() then
		return
	end

	table.insert(self._elimination_queue, { ... })

	if self._elimination_queue_playing then
		return
	end

	self._elimination_queue_playing = true

	while #self._elimination_queue > 0 do
		local v, v2 = table.unpack(table.remove(self._elimination_queue, 1))

		if v == Players.LocalPlayer then
			continue
		end

		self._elimination_chain += 1
		local v3 = math.clamp(self._elimination_chain - 3, 0, 10)
		self.FighterInterface:CreateSound(
			SoundLibrary.EliminationSounds[math.min(self._elimination_chain, 3)],
			v3 * 0.25 + 2,
			v3 * 0.1 + 1,
			script,
			true,
			10
		)
		local teamColor = DuelLibrary:GetTeamColor(self.FighterInterface.ClientFighter:Get("TeamID"))
		local v4 = string.format(
			"%s,%s,%s",
			string.format("%.0f", teamColor.R * 255),
			string.format("%.0f", teamColor.G * 255),
			string.format("%.0f", teamColor.B * 255)
		)
		local name = ComplianceController:GetName(self.FighterInterface.ClientFighter.Player)
		local v5 = not self.FighterInterface.ClientFighter.IsLocalPlayer and string.format(
			"<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"3\" transparency=\"0\"><font color=\"rgb(%s)\"><font weight=\"800\">%s</font></font></stroke>  ",
			v4,
			name
		)
		local v6 = v2 and "Assist" or "Eliminated"
		local teamColor2 = DuelLibrary:GetTeamColor(v:GetAttribute("TeamID"))
		local v7 = string.format(
			"%s,%s,%s",
			string.format("%.0f", teamColor2.R * 255),
			string.format("%.0f", teamColor2.G * 255),
			string.format("%.0f", teamColor2.B * 255)
		)
		local name2 = ComplianceController:GetName(v)

		if v5 then
			v6 = string.lower(v6) or v6
		end

		local v9 = string.format(
			"<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"1\" transparency=\"0.75\"><font weight=\"500\">%s  </font></stroke><stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"3\" transparency=\"0\"><font color=\"rgb(%s)\"><font weight=\"800\">%s</font></font></stroke>",
			v6,
			v7,
			name2
		)
		local clone = eliminationSlot:Clone()
		clone.LayoutOrder = self._elimination_chain
		clone.TextLabel.Text = (v5 or "") .. v9
		clone.Size = UDim2.new(1, 0, 0, 0)
		clone.Parent = self.Frame
		BetterDebris:AddItem(clone, 5)
		clone:TweenSize(UDim2.new(1, 0, v5 and 0.75 or 1, 6), "Out", "Back", 0.25, true, function()
			wait(3)

			if self._destroyed or not clone:IsDescendantOf(Players.LocalPlayer) then
				return
			end

			clone:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quint", 0.5, true)
			Utility:RenderstepForLoop(0, 100, 10, function(p)
				clone.GroupTransparency = p / 100
			end)
			clone:Destroy()

			if #self.Frame:GetChildren() == 1 then
				self:Clear()
			end
		end)
		wait(0.04)
	end

	self._elimination_queue_playing = false
end

function EliminationSlots:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
end

function EliminationSlots:_Init()
	table.insert(
		self._connections,
		self._reference_frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			self:Refresh()
		end)
	)
end

return EliminationSlots