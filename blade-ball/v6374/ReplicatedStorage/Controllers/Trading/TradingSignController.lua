local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

if not require3(ReplicatedStorage2.ServerInfo).isTradingPlazaServer() then
	return {}
end

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("ServerScriptService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local v2 = require3(ReplicatedStorage2.Packages.Net)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Observers)
local v4 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v5 = require3(ReplicatedStorage2.Controllers.SettingsController)
local v6 = require3(ReplicatedStorage2.Controllers.NotificationController)
local remoteEvent = v2:RemoteEvent("TradingSign/Toggle")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local tradeSignAnim = script:WaitForChild("TradeSignAnim")
local TradingSignController = {}

function TradingSignController:Update()
	local replion = client:GetReplion("Data")

	if not replion then
		return
	end

	local toggleTradingSign = playerGui:WaitForChild("Hotbar"):WaitForChild("ToggleTradingSign")
	toggleTradingSign.Visible = replion:Find("GamePasses", "TradingSign")
end

function TradingSignController:Toggle()
	if localPlayer:GetAttribute("HasBooth") then
		remoteEvent:FireServer()
	else
		v6:SendNotification("Claim a booth first!")
	end
end

function TradingSignController:Start()
	client:WaitReplion("Data"):OnChange("GamePasses", function()
		self:Update()
	end)
	self:Update()
	local toggleTradingSign = playerGui:WaitForChild("Hotbar"):WaitForChild("ToggleTradingSign")
	toggleTradingSign.CanvasGroup.Button.Activated:Connect(function()
		self:Toggle()
	end)
	toggleTradingSign.CanvasGroup.GroupTransparency = 0.5
	v.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local binds

		if GuiService:IsTenFootInterface() then
			binds = v5:GetBinds("Ability")
		end

		if input.KeyCode == Enum.KeyCode.One or binds and (input.KeyCode.Name == binds.Bind1 or input.UserInputType.Name == binds.Bind1 or input.KeyCode.Name == binds.Bind2 or input.UserInputType.Name == binds.Bind2) then
			self:Toggle()
		end
	end)
	v3.observeCharacters(function(p, instance)
		local v7 = v3.observeAttribute(instance, "TradingSignEquipped", function()
			if p == localPlayer then
				toggleTradingSign.CanvasGroup.GroupTransparency = 0
			end

			local clone = ReplicatedStorage2.Assets.TradingSign:Clone()
			local rightArm = instance:WaitForChild("Right Arm")
			local rigidConstraint = Instance.new("RigidConstraint")
			rigidConstraint.Attachment0 = rightArm:WaitForChild("RightGripAttachment")
			rigidConstraint.Attachment1 = clone.PrimaryPart.Attachment
			rigidConstraint.Parent = clone
			clone.Parent = workspace.Runtime
			local surfaceGui = clone.Gui.SurfaceGui
			surfaceGui.Parent = playerGui
			surfaceGui.Adornee = clone.Gui
			surfaceGui.ScrollingFrame:SetAttribute("MaxListingItems", 3)
			surfaceGui.ScrollingFrame:AddTag((`ListingsUI_{p.UserId}`))
			local track = instance:FindFirstChildWhichIsA("Animator", true):LoadAnimation(tradeSignAnim)
			track:Play()
			local v8 = v3.observeAttribute(p, "BoothEarnedTokens", function(p2)
				clone.AmountSoldGui.Frame.List.Amount.Text = v4.ValueConvertor:AddCommas(p2)
			end)
			return function()
				v8()
				toggleTradingSign.CanvasGroup.GroupTransparency = 0.5
				surfaceGui:Destroy()
				clone:Destroy()
				track:Stop()
				track:Destroy()
			end
		end)
		return function()
			toggleTradingSign.CanvasGroup.GroupTransparency = 0.5
			v7()
		end
	end)
end

return TradingSignController