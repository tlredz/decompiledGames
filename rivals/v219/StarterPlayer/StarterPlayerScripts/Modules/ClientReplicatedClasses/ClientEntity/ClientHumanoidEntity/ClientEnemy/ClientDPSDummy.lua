local Players = game:GetService("Players")
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
local dPSGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DPSGui")
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self._gui = dPSGui:Clone()
	self._dps_start = nil
	self._dps_initial_damage = 0
	self._dps_total_damage = 0
	self._dps_hash = 0
	self:_Init()
	return self
end

function object:ReplicateFromServer(p, ...)
	if p ~= "RegisterDPS" then
		ClientEnemy.ReplicateFromServer(self, p, ...)
		return
	end

	if not self:IsRendered() then
		return
	end

	local v = ...
	self._dps_start = self._dps_start or tick()
	self._dps_initial_damage = self._dps_initial_damage or v
	self._dps_total_damage += v
	self._dps_hash += 1
	local v2 = self._dps_total_damage - (math.abs(self._dps_initial_damage - self._dps_total_damage) < 0.001 and 0 or self._dps_initial_damage)
	self._gui.MainFrame.Bar.Bar.Size = UDim2.new(1, 0, 1, 0)
	self._gui.MainFrame.Bar.Bar:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Linear", 3, true)
	self._gui.MainFrame.DPS.Text = string.format("DPS: %.1f", v2 / math.max(1, tick() - self._dps_start))
	self._gui.MainFrame.Total.Text = string.format("Total: %.1f", self._dps_total_damage)
	self._gui.Enabled = true
	local _dps_hash = self._dps_hash
	task.delay(3, function()
		if self._destroyed or self._dps_hash ~= _dps_hash then
			return
		end

		self._dps_start = nil
		self._dps_initial_damage = 0
		self._dps_total_damage = 0
		self._gui.Enabled = false
	end)
end

function object:_Setup()
	self._gui.Enabled = false
	self._gui.Parent = self.RootPart
end

function object:_Init()
	self:_Setup()
end

return object