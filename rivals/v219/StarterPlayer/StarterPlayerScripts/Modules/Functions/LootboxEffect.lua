local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local attachment = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("LootboxCollectParticles"):WaitForChild("Attachment")
local unboxEffect = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("UnboxEffect")
local lootboxes = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Lootboxes")
local v = {
	Common = { "rbxassetid://18182950485", 0.5 },
	Rare = { "rbxassetid://18182950836", 0.375 },
	Legendary = { "rbxassetid://18182950182", 0.375 },
	Mythical = { "rbxassetid://115151712865765", 0.5 },
	Standard = { "rbxassetid://18182950485", 0.5 },
	Prime = { "rbxassetid://18182950182", 0.375 }
}
local count = 0
return function(position, p, list, p2, parent, p3, _, p4)
	local v2 = list[1] and CosmeticLibrary.Cosmetics[list[1].RewardData.Name]
	local v3 = list[1] and CosmeticLibrary.Rewards[list[1].RewardData.Name]

	if p2 and p2 > 0 then
		wait(p2)
	end

	count += 1
	local v4 = count * 3.141592653589793 * 2 / 8 + math.floor((count - 1) / 8) * 3.141592653589793 / 8 + math.rad(math.floor(count - 1) * 5)
	local v5 = math.floor((count % 64 - 1) / 8) * 1
	local clone = lootboxes[p]:Clone()
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("RootPart")

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = false
	end

	if p == "Prize Wheel" then
		if not v2 or v2.Type ~= "Skin" then
			clone.wheel.Slices:PivotTo(clone.wheel.Slices:GetPivot() * CFrame.Angles(
				0,
				0,
				1.0471975511965976 * Random.new(p4):NextInteger(1, 5)
			))
		end

		for _, child in pairs(clone.wheel.Slices:GetChildren()) do
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = child
			weldConstraint.Part1 = clone.wheel
			weldConstraint.Parent = child
		end
	end

	humanoidRootPart.Anchored = true
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 15)
	Utility:CreateSound("rbxassetid://18183233381", 0.5, 1 + 0.25 * math.random(), humanoidRootPart, true)
	local v6 = CFrame.new(position) * CFrame.Angles(0, v4, 0)
	local v7 = CFrame.new(position) * CFrame.Angles(0, v4, 0) * CFrame.new(0, -3, v5 + 7)
	Utility:RenderstepForLoop(0, 100, 2, function(p5)
		local v8 = p5 / 100
		local v9 = 1 - (1 - v8) ^ 5
		local v10 = math.abs(math.cos(9.42477796076938 * (v8 + 0.25)) * (v8 - 1) / 0.707)
		local lerped = v6:Lerp(v7, v9)
		clone:PivotTo(CFrame.new(lerped.X, v7.Y + (v6.Y - v7.Y) * v10, lerped.Z) * lerped.Rotation)
	end)
	BetterDebris:AddItem(clone, clone.Animation:GetAttribute("Duration"))
	task.spawn(CONSTANTS.IS_STUDIO and task.defer or pcall, function()
		clone.AnimationController:LoadAnimation(clone.Animation):Play()
		local module = require(script[CosmeticLibrary.Rewards[p].SoundProfile])
		module(clone)
	end)
	wait(clone.Animation:GetAttribute("RevealDelay"))
	local clone2 = unboxEffect:Clone()
	clone2.CFrame = v7 + createVector(0, 8, 0)
	clone2.Parent = workspace
	BetterDebris:AddItem(clone2, 15)
	local billboardGui = clone2.BillboardGui
	billboardGui.Adornee = clone2
	billboardGui.Parent = Players.LocalPlayer.PlayerGui
	BetterDebris:AddItem(billboardGui, 15)

	for _, v8 in pairs(list) do
		local v9 = RewardSlot.new(v8.RewardData, true)
		v9:SetInteractable(false)
		v9:SetParent(billboardGui.Container)
	end

	billboardGui.Container.Size = UDim2.new(0.25, 0, 0.25, 0)
	billboardGui.Container.Position = UDim2.new(0.5, 0, 0.75, 0)
	billboardGui.Container:TweenSizeAndPosition(
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		"Out",
		"Quint",
		0.5,
		true
	)
	local rarity = nil
	local color = nil

	if v2 then
		rarity = v2.Rarity
		color = CosmeticLibrary.Rarities[v2.Rarity].Color
	elseif v3 then
		local item = ItemLibrary.Items[v3.Name]
		rarity = item and item.Status or "Standard"
		color = ItemLibrary.Statuses[rarity].Color
	end

	if rarity and color then
		clone2.Trail.Color = ColorSequence.new(color)
		local v8 = v[rarity]

		if v8 then
			Utility:CreateSound(v8[1], v8[2] * (p3 == Players.LocalPlayer and 1 or 0.5), 1, clone2, true)
		end
	end

	local container = billboardGui.Container
	wait(4)

	if container:IsDescendantOf(workspace) then
		container:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 1, true)
	end

	if not parent then
		return
	end

	local cFrame = clone2.CFrame
	Utility:RenderstepForLoop(0, 100, 1.9, function(p5)
		local value = TweenService:GetValue(p5 / 100, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		clone2.CFrame = cFrame:Lerp(parent.CFrame, value)
	end)
	local clone3 = attachment:Clone()
	clone3.Parent = parent

	for _, child in pairs(clone3:GetChildren()) do
		child:SetAttribute("IgnoreVisibilityCheck", true)
		child.Color = color and ColorSequence.new(color) or child.Color
	end

	Utility:PlayParticles(clone3)
	Utility:CreateSound("rbxassetid://109954155299965", 0.75, 1 + 0.25 * math.random(), parent, true)
	clone2:Destroy()
	billboardGui:Destroy()
end