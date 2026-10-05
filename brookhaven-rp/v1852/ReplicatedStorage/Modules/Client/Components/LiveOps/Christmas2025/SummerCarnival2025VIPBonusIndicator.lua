game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local v = Component.new({
	Tag = "SummerCarnival2025VIPBonusIndicator"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Update()
	GamepassController.WaitForGamepasses()

	if UnlockableController.IsFeatureUnlocked("vipChristmasMultiplier", Gamepasses.VIP) then
		local bonusLabel = self.Instance:WaitForChild("BonusLabel")
		bonusLabel.Text = "2X Snowflakes!"
		self.Instance:RemoveTag("HoverAndActivationFX")
		self.Instance.Selectable = false
		self.Instance.Interactable = false
	end
end

function v:Start()
	self.Instance.MouseButton1Down:Connect(function()
		if not UnlockableController.IsFeatureUnlocked("vipChristmasMultiplier", Gamepasses.VIP) then
			GamepassController.Show(Gamepasses.VIP, self.Instance.ImageLabel.Image, "christmas vip indicator", nil)
		end
	end)
	GamepassController.OnGamepassUnlocked:Connect(function(p)
		if Gamepasses.GetById(p) == Gamepasses.VIP then
			local bonusLabel = self.Instance:WaitForChild("BonusLabel")
			bonusLabel.Text = "2X Snowflakes!"
			self.Instance.Selectable = false
			self.Instance.Interactable = false
			self.Instance:RemoveTag("HoverAndActivationFX")
		end
	end)
	self.Instance.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance and self.Instance.Parent and self.Instance.Parent.Visible then
			self:Update()
		end
	end)
	self:Update()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v