local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "GamepassVisibility"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Instance.Visible = false
end

function v:UpdateVisibility(p2)
	if self.gamepassName == nil then
		warn("GamepassVisibility: GamepassName is nil")
	else
		self.Instance.Visible = GamepassController.IsOwned(p2)
	end
end

function v:Start()
	self.gamepassName = self.Instance:GetAttribute("GamepassName")
	local v2 = Gamepasses.All[self.gamepassName]

	if not v2 then
		warn("unknown gamepass " .. self.gamepassName)
		return
	end

	GamepassController.WaitForGamepasses()
	self:UpdateVisibility(v2)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v