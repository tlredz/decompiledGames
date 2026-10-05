local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local darkenFade = script.darkenFade
darkenFade.Parent = HudController:GetPlayerGui()
local remoteFunction = Net:RemoteFunction("Deep/Teleport", -1)
local v = Component.new({
	Tag = "DeepEntryZone",
	Ancestors = { workspace }
})

function v:Construct()
	self.Trove = Trove.new()
end

function v.Start(p)
	local flag = false
	local flag2 = false
	p.Trove:Connect(RunService.RenderStepped, function(_: number)
		if flag2 then
			darkenFade.fade.BackgroundTransparency = 0
			return
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		if GeneralUtils.isInsidePart(p.Instance, humanoidRootPart.Position) then
			flag = true
			local teleportType = p.Instance:GetAttribute("TeleportType")
			local v2 = teleportType == "exit"
			local backgroundTransparency = math.clamp(
				math.map(
					humanoidRootPart.Position.Y,
					p.Instance.Position.Y + p.Instance.Size.Y / 2,
					p.Instance.Position.Y - p.Instance.Size.Y / 2,
					v2 and -0.1 or 1,
					v2 and 1 or -0.1
				),
				0,
				1
			)
			darkenFade.fade.BackgroundTransparency = backgroundTransparency

			if backgroundTransparency <= 0 then
				flag2 = true
				GuiService:SetGameplayPausedNotificationEnabled(false)
				remoteFunction:InvokeServer(teleportType)

				repeat
					task.wait(1)
				until not localPlayer.GameplayPaused

				darkenFade.fadeAnim.BackgroundTransparency = 0
				darkenFade.fade.BackgroundTransparency = 1
				flag2 = false
				GuiService:SetGameplayPausedNotificationEnabled(true)
				TweenService:Create(darkenFade.fadeAnim, TweenInfo.new(3), {
					BackgroundTransparency = 1
				}):Play()
			end
		else
			if flag then
				darkenFade.fade.BackgroundTransparency = 1
			end

			flag = false
		end
	end)
end

function v.Stop(p)
	p.Trove:Clean()
end

return v