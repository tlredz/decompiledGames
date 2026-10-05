local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local v = { "rbxassetid://121789380697435", "rbxassetid://131598663318488" }
local HeadHoncho = {}
HeadHoncho.__index = HeadHoncho

function HeadHoncho.new(clientDueler)
	local self = setmetatable({}, HeadHoncho)
	self.ClientDueler = clientDueler
	self._connections = {}
	self._honcho_highlight = nil
	self._bodyguard_highlight = nil
	self._hide_honcho_highlight_until = 0
	self._aura_sound = nil
	self:_Init()
	return self
end

function HeadHoncho:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	if self._honcho_highlight then
		self._honcho_highlight:Destroy()
		self._honcho_highlight = nil
	end

	if self._bodyguard_highlight then
		self._bodyguard_highlight:Destroy()
		self._bodyguard_highlight = nil
	end

	if self._aura_sound then
		self._aura_sound:Destroy()
		self._aura_sound = nil
	end
end

function HeadHoncho:_UpdateBodyguardHighlight()
	if self._bodyguard_highlight then
		self._bodyguard_highlight:Destroy()
		self._bodyguard_highlight = nil
	end

	if not self.ClientDueler.ClientDuel:Get("IsSpectating") then
		return
	end

	if self.ClientDueler:Get("IsHeadHoncho") ~= false or not self.ClientDueler.ClientFighter or self.ClientDueler.ClientFighter:Get("IsSpectating") or not self.ClientDueler.ClientFighter.Entity then
		return
	end

	if not self.ClientDueler.ClientDuel.LocalDueler or self.ClientDueler.ClientDuel.LocalDueler:Get("IsHeadHoncho") ~= true or self.ClientDueler.ClientDuel.LocalDueler:Get("TeamID") == self.ClientDueler:Get("TeamID") then
		return
	end

	local model = self.ClientDueler.ClientFighter.Entity.Model
	self._bodyguard_highlight = Instance.new("Highlight")
	self._bodyguard_highlight.FillTransparency = 1
	self._bodyguard_highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
	self._bodyguard_highlight.OutlineTransparency = 0.5
	self._bodyguard_highlight.Adornee = model
	self._bodyguard_highlight.Parent = model
end

function HeadHoncho:_UpdateHonchoHighlight()
	if self._honcho_highlight then
		self._honcho_highlight:Destroy()
		self._honcho_highlight = nil
	end

	if self._aura_sound then
		self._aura_sound:Destroy()
		self._aura_sound = nil
	end

	if not self.ClientDueler.ClientDuel:Get("IsSpectating") or (self.ClientDueler:Get("IsHeadHoncho") ~= true or not (self.ClientDueler.ClientFighter and self.ClientDueler.ClientFighter.Entity)) then
		return
	end

	self.ClientDueler.ClientFighter:Get("IsSpectating")

	if not v[DuelLibrary.TeamsByID[self.ClientDueler:Get("TeamID")].TeamIndex] then
		local _ = v[1]
	end

	if self.ClientDueler.ClientFighter:Get("IsSpectating") then
		return
	end

	local teamColor = DuelLibrary:GetTeamColor(self.ClientDueler:Get("TeamID"))
	local model = self.ClientDueler.ClientFighter.Entity.Model
	self._honcho_highlight = Instance.new("Highlight")
	self._honcho_highlight.DepthMode = tick() < self._hide_honcho_highlight_until and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
	self._honcho_highlight.FillColor = teamColor
	self._honcho_highlight.OutlineColor = teamColor
	self._honcho_highlight.Adornee = model
	self._honcho_highlight.Parent = model
end

function HeadHoncho:_SetupDamageTakenLogic()
	if not self.ClientDueler.ClientFighter then
		return
	end

	table.insert(
		self._connections,
		self.ClientDueler.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function(...)
			self:_UpdateHonchoHighlight()
			self:_UpdateBodyguardHighlight()
		end)
	)
	local health = nil
	table.insert(self._connections, self.ClientDueler.ClientFighter.HealthChanged:Connect(function(...)
		local health2 = self.ClientDueler.ClientFighter:GetHealth()

		if health and health2 < health then
			self._hide_honcho_highlight_until = tick() + 5
			self:_UpdateHonchoHighlight()
			task.delay(5, self._UpdateHonchoHighlight, self)
		end

		health = self.ClientDueler.ClientFighter:GetHealth()
	end))
end

function HeadHoncho:_Init()
	table.insert(self._connections, self.ClientDueler.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_UpdateHonchoHighlight()
		self:_UpdateBodyguardHighlight()
	end))
	self.ClientDueler:GetDataChangedSignal("IsHeadHoncho"):Connect(function()
		self:_UpdateHonchoHighlight()
		self:_UpdateBodyguardHighlight()
	end)
	self.ClientDueler:GetDataChangedSignal("TeamID"):Connect(function()
		self:_UpdateHonchoHighlight()
		self:_UpdateBodyguardHighlight()
	end)
	self.ClientDueler.EntityAdded:Connect(function()
		self:_UpdateHonchoHighlight()
		self:_UpdateBodyguardHighlight()
	end)
	self:_SetupDamageTakenLogic()
	self:_UpdateHonchoHighlight()
	self:_UpdateBodyguardHighlight()
end

return HeadHoncho