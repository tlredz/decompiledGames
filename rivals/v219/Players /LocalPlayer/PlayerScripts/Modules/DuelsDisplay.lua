local Players = game:GetService("Players")
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local DuelDisplay = require(script:WaitForChild("DuelDisplay"))
local duelsBoardGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelsBoardGui")
local DuelsDisplay = {}
DuelsDisplay.__index = DuelsDisplay

function DuelsDisplay.new(part)
	local self = setmetatable({}, DuelsDisplay)
	self.Part = part
	self.SurfaceGui = duelsBoardGui:Clone()
	self._duel_displays = {}
	self._connections = {}
	self._enabled_hash = 0
	self._is_enabled = nil
	self:_Init()
	return self
end

function DuelsDisplay:SetEnabled(is_enabled)
	if self._is_enabled == is_enabled then
		return
	end

	self._is_enabled = is_enabled
	self:_Clear()

	if is_enabled then
		task.spawn(self._Generate, self)
	end
end

function DuelsDisplay:_UpdateEmpty()
	self.SurfaceGui.Empty.Visible = not next(self._duel_displays)
end

function DuelsDisplay:_Generate()
	self._enabled_hash += 1
	local _enabled_hash = self._enabled_hash
	task.spawn(function()
		while true do
			self.SurfaceGui.Live.Text = "• LIVE"
			wait(1)

			if _enabled_hash ~= self._enabled_hash then
				break
			end

			self.SurfaceGui.Live.Text = "LIVE"
			wait(0.25)

			if _enabled_hash ~= self._enabled_hash then
				break
			end
		end
	end)
	table.insert(self._connections, DuelController.ObjectAdded:Connect(function(p)
		self:_DuelAdded(p)
	end))
	table.insert(self._connections, DuelController.ObjectRemoved:Connect(function(p)
		self:_DuelRemoved(p)
	end))

	for _, object2 in pairs(DuelController.Objects) do
		task.defer(self._DuelAdded, self, object2)
	end
end

function DuelsDisplay:_Clear()
	for _, _duel_display in pairs(self._duel_displays) do
		_duel_display:Destroy()
	end

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self._duel_displays = {}
	self._enabled_hash += 1
end

function DuelsDisplay:_DuelAdded(object2)
	self:_DuelRemoved(object2)

	if object2:Get("Status") == "GameOver" then
		return
	end

	local v = DuelDisplay.new(object2)
	v.Frame.Parent = self.SurfaceGui.List.Container
	self._duel_displays[object2] = v
	v.GameOver:Connect(function()
		self:_DuelRemoved(object2)
	end)
	self:_UpdateEmpty()
end

function DuelsDisplay:_DuelRemoved(p)
	if self._duel_displays[p] then
		self._duel_displays[p]:Destroy()
		self._duel_displays[p] = nil
	end

	self:_UpdateEmpty()
end

function DuelsDisplay:_Setup()
	self.SurfaceGui.Adornee = self.Part
	self.SurfaceGui.Parent = Players.LocalPlayer.PlayerGui
end

function DuelsDisplay:_Init()
	self.SurfaceGui.List.Container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.SurfaceGui.List.CanvasSize = UDim2.new(
			0,
			0,
			0,
			self.SurfaceGui.List.Container.Layout.AbsoluteContentSize.Y
		)
	end)
	self:_Setup()
	self:_UpdateEmpty()
	self:SetEnabled(true)
end

return DuelsDisplay