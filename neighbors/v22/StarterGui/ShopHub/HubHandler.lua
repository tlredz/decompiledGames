local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local _ = ReplicatedStorage.Assets.Data
local PlayerStates = require(modules.PlayerStates)
local UI = require(modules.UI)
local Holiday = require(modules.Holiday)
require(modules.Neighbors.House)
local currentHoliday = Holiday:GetCurrentHoliday()

if not currentHoliday.Hub then
	return
end

local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui
local parent = script.Parent
local hub = parent:WaitForChild("Hub")
local content = hub:WaitForChild("Content")
local shop = parent.Parent:WaitForChild("Neighbors"):WaitForChild("Shop")
local top = hub:WaitForChild("Top")
local v = {
	Bundle = function()
		_G.ShowBundle(currentHoliday.Hub.Bundle)
	end,
	Emotes = function()
		shop.Pages.SetPage:Fire(shop.Pages.Emotes)
	end,
	Banner = function()
		shop.Pages.SetPage:Fire(shop.Pages.Weekly)
	end,
	Decorations = function()
		shop.Pages.SetPage:Fire(shop.Pages.Profile)
	end,
	Titles = function()
		shop.Pages.SetPage:Fire(shop.Pages.Titles)
		shop.ItemTitlesPage.Preview:Fire(currentHoliday.Hub.Titles)
	end,
	Skins = function()
		_G.DisplayText("All limited skins are scattered across MOST cases!", 6)
		shop.Pages.SetPage:Fire(shop.Pages.Skins)
	end,
	Items = function()
		shop.Pages.SetPage:Fire(shop.Pages.Items)
	end
}
local v2 = false
local v3 = false
local v4 = nil
local tween = TweenService:Create(hub, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
	Position = UDim2.new(0.5, 0, 0.5, 0)
})
local tween2 = TweenService:Create(hub, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
	Position = UDim2.new(0.5, 0, 1.6, 0)
})

local function changeVisibility(flag: boolean)
	v3 = flag
	hub.Visible = true

	if flag then
		shop:SetAttribute("Visible", false)
		shop.Visible = false
		local proximityPrompt = v4:FindFirstChild("ProximityPrompt", true)
		proximityPrompt.Enabled = false
		script.Open:Play()
		tween:Play()
	else
		tween2:Play()

		if v4 then
			for _, v5 in v4.Humanoid:GetPlayingAnimationTracks() do
				if v5.Animation.Name ~= "Idle" then
					v5:Stop()
				end
			end

			if v4:FindFirstChild("Cheer") then
				v4.Humanoid:LoadAnimation(v4.Cheer):Play()
			end
		end

		local proximityPrompt_2 = v4:FindFirstChild("ProximityPrompt", true)
		proximityPrompt_2.Enabled = true

		while tween2.PlaybackState == Enum.PlaybackState.Playing do
			task.wait()
		end

		if tween2.PlaybackState == Enum.PlaybackState.Completed then
			hub.Visible = false
		end
	end
end

for _, v5 in CollectionService:GetTagged("HubPrompt") do
	local model = v5:FindFirstAncestorOfClass("Model")
	model.Humanoid:LoadAnimation(model.Idle):Play()
	v5.Triggered:Connect(function()
		v3 = true
		hub.Visible = true
		shop:SetAttribute("Visible", false)
		shop.Visible = false
		local proximityPrompt = v4:FindFirstChild("ProximityPrompt", true)
		proximityPrompt.Enabled = false
		script.Open:Play()
		tween:Play()
	end)
end

CollectionService:GetInstanceAddedSignal("HubPrompt"):Connect(function(instance)
	local model = instance:FindFirstAncestorOfClass("Model")
	model.Humanoid:LoadAnimation(model.Idle):Play()
	instance.Triggered:Connect(function()
		v3 = true
		hub.Visible = true
		shop:SetAttribute("Visible", false)
		shop.Visible = false
		local proximityPrompt = v4:FindFirstChild("ProximityPrompt", true)
		proximityPrompt.Enabled = false
		script.Open:Play()
		tween:Play()
	end)
end)
top.Close.Activated:Connect(function()
	changeVisibility(false)
end)
hub.Position = UDim2.new(0.5, 0, 1.6, 0)
parent.Enabled = true
UI:Bind(top.Close)
UI:AddShadowOnHover(top.Close)
UI:RegisterUIScale(hub.UIScale, {
	PC = 1.3,
	Mobile = 1.15,
	Tablet = 1.15
})

for _, v5 in content:QueryDescendants("GuiButton") do
	UI:Bind(v5)
	UI:AddShadowOnHover(v5)
	local v6 = v5
	v5.Activated:Connect(function()
		script.Switch:Play()
		changeVisibility(false)

		if v[v6.Name] then
			shop:SetAttribute("Visible", true)
			shop.Visible = true
			v[v6.Name]()
		end
	end)
end

function _G.ShowShopHub()
	v3 = true
	hub.Visible = true
	shop:SetAttribute("Visible", false)
	shop.Visible = false
	local proximityPrompt = v4:FindFirstChild("ProximityPrompt", true)
	proximityPrompt.Enabled = false
	script.Open:Play()
	tween:Play()
end

localPlayer:GetAttributeChangedSignal("State"):Connect(function()
	if localPlayer:GetAttribute("State") ~= PlayerStates.Matched then
		changeVisibility(false)
	end
end)

while task.wait(0.2) do
	local v5 = 1e999
	local v6 = nil

	for _, v7 in CollectionService:GetTagged("HubNPC") do
		local distanceFromCharacter = localPlayer:DistanceFromCharacter(v7.PrimaryPart.Position)

		if not (distanceFromCharacter < v5) then
			continue
		end

		v6 = v7
		v5 = distanceFromCharacter
	end

	if not v6 then
		continue
	end

	v4 = v6
	local distanceFromCharacter = localPlayer:DistanceFromCharacter(v4:GetBoundingBox().Position)

	if distanceFromCharacter <= 15 and v2 then
		v2 = false

		for _, v7 in v4.Humanoid:GetPlayingAnimationTracks() do
			if v7.Animation.Name ~= "Idle" then
				v7:Stop()
			end
		end

		if v4:FindFirstChild("Wave") then
			local track = v4.Humanoid:LoadAnimation(v4.Wave)
			track:Play()
			track:Destroy()
		end
	elseif distanceFromCharacter >= 30 and not v2 then
		changeVisibility(false)
		v2 = true
	end
end