local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "GoKartLeaderboardEntry"
})
local color = Color3.fromRGB(231, 154, 154)
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
	self._usernameLabel = self.Instance.Username
	self._placeLabel = self.Instance.Place
	self._lapsLabel = self.Instance.Laps
end

function v:Start()
	if self._usernameLabel.Text ~= localPlayer.Name then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function observeLayoutOrder(layoutOrder: number)
		if layoutOrder <= 3 then
			return
		end

		self._usernameLabel.TextColor3 = color
		self._placeLabel.TextColor3 = color
		self._lapsLabel.TextColor3 = color
	end

	observeLayoutOrder(self.Instance.LayoutOrder) -- equivalent call inferred; original call site unknown
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
		if self.Instance.LayoutOrder <= 3 then
			return
		end

		self._usernameLabel.TextColor3 = color
		self._placeLabel.TextColor3 = color
		self._lapsLabel.TextColor3 = color
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v