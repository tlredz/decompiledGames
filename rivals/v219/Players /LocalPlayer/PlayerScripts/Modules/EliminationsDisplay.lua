local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local eliminationBoardSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EliminationBoardSlot")
local eliminationBoardGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EliminationBoardGui")
local EliminationsDisplay = {}
EliminationsDisplay.__index = EliminationsDisplay

function EliminationsDisplay.new(part)
	local self = setmetatable({}, EliminationsDisplay)
	self.Part = part
	self.SurfaceGui = eliminationBoardGui:Clone()
	self._slots = {}
	self._layout_order = 0
	self:_Init()
	return self
end

function EliminationsDisplay:NewElimination(player, p, player2, _, p2)
	self._layout_order -= 1
	local clone = eliminationBoardSlot:Clone()
	clone.Weapon.Image = ItemLibrary.Items[p2] and ItemLibrary.Items[p2].Image or ""
	clone.LayoutOrder = self._layout_order
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	local new = TeammateSlot.new(player.UserId, p, not humanoid and 0 or humanoid.Health / humanoid.MaxHealth)
	new.SlotFrame.Parent = clone.Eliminator
	local humanoid2 = player2.Character and player2.Character:FindFirstChild("Humanoid")
	local new_2 = TeammateSlot.new(player2.UserId, p, not humanoid2 and 0 or humanoid2.Health / humanoid2.MaxHealth)
	new_2.SlotFrame.Parent = clone.Victim
	clone.Parent = self.SurfaceGui.List.Container
	table.insert(self._slots, 1, clone)
	local v = table.remove(self._slots, 31)

	if v then
		v:Destroy()
	end
end

function EliminationsDisplay:_Setup()
	self.SurfaceGui.Adornee = self.Part
	self.SurfaceGui.Parent = Players.LocalPlayer.PlayerGui
end

function EliminationsDisplay:_Init()
	self.SurfaceGui.List.Container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.SurfaceGui.List.CanvasSize = UDim2.new(
			0,
			0,
			0,
			self.SurfaceGui.List.Container.Layout.AbsoluteContentSize.Y
		)
	end)
	self:_Setup()
end

return EliminationsDisplay