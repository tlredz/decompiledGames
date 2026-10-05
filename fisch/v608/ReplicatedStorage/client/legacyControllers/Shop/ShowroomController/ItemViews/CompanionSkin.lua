local ReplicatedStorage = game:GetService("ReplicatedStorage")
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")
local CompanionSkin = {}

function CompanionSkin.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local skin = skins.Skins[data.Name]
	local companion = companions.Companions[skin.TargetCompanion]
	clone.Name = data.Name
	clone.detail.itemName.Text = skin.DisplayText or data.Name
	clone.detail.itemType.Text = `<font color="#{companion.Color:ToHex()}">{skin.TargetCompanion}</font> Skin`
	clone.icon.Image = data.Icon or skin.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function CompanionSkin.LoadScene(object, p, p2)
	local skin = skins.Skins[p.Name]
	local companion = companions.Companions[skin.TargetCompanion]
	local async = assets.getAsync("companion", (`{companion.Model}/{p.Name}`))

	if not async then
		warn((`[CompanionSkinView] Failed to stream companion "{companion.Model}/{p.Name}"`))
		return
	end

	local clone = async:Clone()
	local rootPart = clone:FindFirstChild("RootPart")

	if rootPart then
		rootPart.PivotOffset = CFrame.identity
		clone.PrimaryPart = rootPart
	end

	object:IgnorePerformance(clone)
	object:CreatePodium(clone, p2)
	local v = (companion.ModelRotation or 0) + 3.141592653589793
	clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, v, 0))
	local animations = clone:FindFirstChild("Animations")
	local animationController = clone:FindFirstChildOfClass("AnimationController")

	if animations and animationController then
		local animation = animations:FindFirstChild(companion.StateAnimations and companion.StateAnimations.Idle or animations:FindFirstChild("SitIdle") and "SitIdle" or "Idle") or animations:FindFirstChild("SleepIdle") or animations:FindFirstChild("Happy") or animations:FindFirstChild("Walk") or animations:FindFirstChild("Run")

		if animation and animation:IsA("Animation") then
			local v2 = animationController:FindFirstChildOfClass("Animator")

			if not v2 then
				v2 = Instance.new("Animator")
				v2.Parent = animationController
			end

			local track = v2:LoadAnimation(animation)
			track.Looped = true
			track:Play()
		end
	end

	if not p2 then
		object:SetInfo({
			Description = skin.Description,
			Stats = nil
		})
	end
end

return CompanionSkin