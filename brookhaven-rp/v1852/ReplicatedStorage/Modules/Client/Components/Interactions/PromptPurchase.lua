local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PromptPurchase"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Gamepass = Gamepasses.All[self.Instance:GetAttribute("PromptPurchase_Gamepass")]
	assert(self.Gamepass, "Unknown gamepass")
end

function v:Start()
	if not self.Instance:IsA("ProximityPrompt") then
		return
	end

	GamepassController.WaitForGamepasses()

	if GamepassController.IsOwned(self.Gamepass) then
		self.Instance:Destroy()
		return
	end

	self._Janitor:Add(self.Instance.Triggered:Connect(function(_)
		if GamepassController.IsOwned(self.Gamepass) then
			self.Instance:Destroy()
		else
			Remotes.fireServer("PromptGamepassPurchase", Gamepasses.GetId(self.Gamepass), "PromptPurchase")
		end
	end))
	self._Janitor:Add(Remotes.connect("GamepassPromptPurchaseFinished", function(p: number, flag: boolean)
		if not flag or p ~= Gamepasses.GetId(self.Gamepass) then
			return
		end

		self.Instance:Destroy()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v