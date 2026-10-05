local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local _ = ReplicatedStorage.Assets.Data
local UI = require(modules.UI)
local House = require(modules.Neighbors.House)
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui
local parent = script.Parent
local valentinesShop = parent:WaitForChild("ValentinesShop")
local content = valentinesShop:WaitForChild("Content")
local shop = parent.Parent:WaitForChild("Neighbors"):WaitForChild("Shop")
local top = valentinesShop:WaitForChild("Top")
local v = false
local v2 = false
local v3 = nil
local tween = TweenService:Create(
	valentinesShop,
	TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	{
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}
)
local tween2 = TweenService:Create(valentinesShop, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
	Position = UDim2.new(0.5, 0, 1.6, 0)
})

local function changeVisibility(flag: boolean)
	v2 = flag
	valentinesShop.Visible = true

	if flag then
		shop:SetAttribute("Visible", false)
		shop.Visible = false
		local proximityPrompt = v3:FindFirstChild("ProximityPrompt", true)
		proximityPrompt.Enabled = false
		script.Open:Play()
		tween:Play()
	else
		tween2:Play()

		if v3 then
			for _, v4 in v3.Humanoid:GetPlayingAnimationTracks() do
				if v4.Animation.Name ~= "Idle" then
					v4:Stop()
				end
			end

			v3.Humanoid:LoadAnimation(v3.Cheer):Play()
		end

		local proximityPrompt_2 = v3:FindFirstChild("ProximityPrompt", true)
		proximityPrompt_2.Enabled = true

		while tween2.PlaybackState == Enum.PlaybackState.Playing do
			task.wait()
		end

		if tween2.PlaybackState == Enum.PlaybackState.Completed then
			valentinesShop.Visible = false
		end
	end
end

for _, v4 in CollectionService:GetTagged("ValentinesShopPrompt") do
	local model = v4:FindFirstAncestorOfClass("Model")
	model.Humanoid:LoadAnimation(model.Idle):Play()
	v4.Triggered:Connect(function()
		v2 = true
		valentinesShop.Visible = true
		shop:SetAttribute("Visible", false)
		shop.Visible = false
		local proximityPrompt = v3:FindFirstChild("ProximityPrompt", true)
		proximityPrompt.Enabled = false
		script.Open:Play()
		tween:Play()
	end)
end

CollectionService:GetInstanceAddedSignal("ValentinesShopPrompt"):Connect(function(instance)
	local model = instance:FindFirstAncestorOfClass("Model")
	model.Humanoid:LoadAnimation(model.Idle):Play()
	instance.Triggered:Connect(function()
		v2 = true
		valentinesShop.Visible = true
		shop:SetAttribute("Visible", false)
		shop.Visible = false
		local proximityPrompt = v3:FindFirstChild("ProximityPrompt", true)
		proximityPrompt.Enabled = false
		script.Open:Play()
		tween:Play()
	end)
end)
top.Close.Activated:Connect(function()
	changeVisibility(false)
end)
valentinesShop.Position = UDim2.new(0.5, 0, 1.6, 0)
parent.Enabled = true
UI:Bind(top.Close)
UI:AddShadowOnHover(top.Close)
UI:RegisterUIScale(valentinesShop.UIScale, {
	PC = 1,
	Mobile = 0.5,
	Tablet = 0.8
})

for _, v4 in content:QueryDescendants("GuiButton") do
	UI:Bind(v4)
	UI:AddShadowOnHover(v4)
	v4.Activated:Connect(function()
		script.Switch:Play()
		changeVisibility(false)
	end)
end

content.Container.Top.Bundle.Activated:Connect(function()
	shop:SetAttribute("Visible", true)
	shop.Visible = true
	_G.ShowBundle("Valentines Bundle 3")
end)
content.Container.Top.Banner.Activated:Connect(function()
	shop:SetAttribute("Visible", true)
	shop.Visible = true
	shop.Pages.SetPage:Fire(shop.Pages.Weekly)
end)
content.Container.Bottom.Decorations.Activated:Connect(function()
	shop:SetAttribute("Visible", true)
	shop.Visible = true
	shop.Pages.SetPage:Fire(shop.Pages.Profile)
end)
content.Container.Bottom.Titles.Activated:Connect(function()
	shop:SetAttribute("Visible", true)
	shop.Visible = true
	shop.Pages.SetPage:Fire(shop.Pages.Titles)
	shop.ItemTitlesPage.Preview:Fire("Valentines Pack 2")
end)
content.Container.Bottom.Skins.Activated:Connect(function()
	shop:SetAttribute("Visible", true)
	shop.Visible = true
	_G.DisplayText("All Limited Valentines Skins are scattered across MOST cases!", 6)
	shop.Pages.SetPage:Fire(shop.Pages.Skins)
end)

while task.wait(0.2) do
	House:GetCurrentPrefab()
	local v4 = 1e999
	local v5 = nil

	for _, v6 in CollectionService:GetTagged("ValentinesNPC") do
		local distanceFromCharacter = localPlayer:DistanceFromCharacter(v6.PrimaryPart.Position)

		if not (distanceFromCharacter < v4) then
			continue
		end

		v5 = v6
		v4 = distanceFromCharacter
	end

	if not v5 then
		continue
	end

	v3 = v5
	local distanceFromCharacter = localPlayer:DistanceFromCharacter(v3:GetBoundingBox().Position)

	if distanceFromCharacter <= 15 and v then
		v = false

		for _, v6 in v3.Humanoid:GetPlayingAnimationTracks() do
			if v6.Animation.Name ~= "Idle" then
				v6:Stop()
			end
		end

		local track = v3.Humanoid:LoadAnimation(v3.Wave)
		track:Play()
		track:Destroy()
		TweenService:Create(v3.Weld, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			C0 = CFrame.new(0, 0, 4.5)
		}):Play()
		task.delay(2, function()
			TweenService:Create(v3.Weld, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				C0 = CFrame.new(0, 0, 0)
			}):Play()
		end)
	elseif distanceFromCharacter >= 30 and not v then
		changeVisibility(false)
		v = true
	end
end