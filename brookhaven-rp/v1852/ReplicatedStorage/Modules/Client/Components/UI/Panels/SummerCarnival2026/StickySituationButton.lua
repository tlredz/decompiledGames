local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local StickyBombController = require(ReplicatedStorage.Modules.Client.LiveOps.StickyBombController)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local v = Component.new({
	Tag = "StickySituationButton"
})

function v:UpdateUI(p2: number)
	if p2 == 1 then
		local counter = self.Instance:WaitForChild("Counter")
		counter.Text = "1 USE LEFT"
	else
		local counter_2 = self.Instance:WaitForChild("Counter")
		counter_2.Text = `{p2} USES LEFT`
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(StickyBombController.StickyBombCountUpdated:Connect(function(p: number)
		self:UpdateUI(p)
	end))
	self:UpdateUI(StickyBombController.GetStickyBombCount())
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		CountableDevProductController.PromptPurchase(CountableDevProducts.STICKY_SITUATION, "ToolGUI")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v