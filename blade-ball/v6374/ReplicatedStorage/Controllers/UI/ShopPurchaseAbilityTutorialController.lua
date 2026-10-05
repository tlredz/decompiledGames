local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Controllers.UI.ShopController)
local v5 = require3(ReplicatedStorage2.Controllers.AnalyticsController)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v6 = require3(ReplicatedStorage2.Packages.Freeze)
local v7 = game.GameId ~= 4777817887
Players.LocalPlayer:WaitForChild("PlayerGui")
local remoteEvent = v2:RemoteEvent("TUTORIAL_CHECKPOINT_STARTED")
local v8 = false
local ShopPurchaseAbilityTutorialController = {
	CheckPointTrove = v3.new(),
	TutorialFinishedTrove = v3.new(),
	CurrentCheckPoint = nil,
	CreateArrowOnElement = function(_, parent, items)
		local clone = script.Arrow:Clone()

		if not v8 then
			clone.Visible = false
			clone.ImageTransparency = 1
		end

		if items then
			for k, item in items do
				clone[k] = item
			end
		end

		clone.Parent = parent
		return clone
	end,
	SetTutorialCheckPoint = function(self, currentCheckPoint: string)
		local v9 = require3(script.CheckPoints)
		self.CurrentCheckPoint = currentCheckPoint
		self.CheckPointTrove:Destroy()
		remoteEvent:FireServer(currentCheckPoint, v8)
		local v10 = v9[currentCheckPoint]

		if typeof(v10) == "function" then
			v10(self.CheckPointTrove)
		end
	end
}

function ShopPurchaseAbilityTutorialController:StartTutorial()
	v4.itemSelected:Connect(function(p)
		if p.name ~= "Invisibility" and self.CurrentCheckPoint == "AbilitySelected" then
			ShopPurchaseAbilityTutorialController:SetTutorialCheckPoint("AbilityShopOpened")
		end
	end)
	self:SetTutorialCheckPoint("Start")
end

function ShopPurchaseAbilityTutorialController:CheckTutorialEligibility()
	v5:GetRemoteConfigValue("AbilityTutorialEnabled", false, 6):andThen(function(flag: boolean)
		v8 = flag or v7
		local v9 = self.Replion:Get("Credits") >= 300
		local v10 = #client:FindItems("Ability", "Invisibility") > 0
		local v11 = v6.Dictionary.count(client:Get("Ability") or {}) > 1
		local abilityTutorialCheckPoint = self.Replion:Get("AbilityTutorialCheckPoint")
		local v12 = abilityTutorialCheckPoint == "Finished" or abilityTutorialCheckPoint == "BoughtDifferentAbility" or abilityTutorialCheckPoint == "FinishedDidNotEquip"

		if v9 and not (v10 or v12 or v11) then
			self:StartTutorial()
		end
	end)
end

function ShopPurchaseAbilityTutorialController:Start()
	local roundEnded = ReplicatedStorage2.Remotes.RoundEnded
	local onPlayerKilled = ReplicatedStorage2.Remotes.OnPlayerKilled
	self.Replion = v.Client:WaitReplion("Data")
	roundEnded.OnClientEvent:Connect(function(p)
		if not table.find(p.allParticipantsEver, Players.LocalPlayer) then
			return
		end

		;(Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()).AncestryChanged:Once(function(instance, parent)
			if parent == workspace.Dead then
				local humanoid = instance:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					self:CheckTutorialEligibility()
				end
			end
		end)
	end)
	onPlayerKilled.OnClientEvent:Connect(function(...)
		Players.LocalPlayer.CharacterAdded:Once(function()
			self:CheckTutorialEligibility()
		end)
	end)
end

return ShopPurchaseAbilityTutorialController