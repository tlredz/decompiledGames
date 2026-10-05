local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local classes = ReplicatedStorage:WaitForChild("Classes")
local utils = ReplicatedStorage:WaitForChild("Utils")
local datas = ReplicatedStorage:WaitForChild("Datas")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(packages.Net)
local InterfaceController = require(controllers.InterfaceController)
require(controllers.CameraController)
local AnimatedButton = require(classes.AnimatedButton)
local Synchronizer = require(packages.Synchronizer)
local NumberUtils = require(utils.NumberUtils)
local Rebirth = require(datas.Rebirth)
local NotificationController = require(controllers.NotificationController)
local AnimalController = require(controllers.AnimalController)
local Animals = require(shared.Animals)
local Animals2 = require(datas.Animals)
local Rarities = require(datas.Rarities)
local ShopItems = require(datas.ShopItems)
local Updates = require(shared.Updates)
local GetRebirthCost = require(ReplicatedStorage.Shared.GetRebirthCost)
local RebirthFlags = require(ReplicatedStorage.Shared.Flags.RebirthFlags)
local remoteFunction = Net:RemoteFunction("Rebirth/RequestRebirth")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local rebirth = playerGui:WaitForChild("Rebirth"):WaitForChild("Rebirth")
local close = rebirth.Header.Close
local content = rebirth.Content
local holderImage = content.Holder.HolderImage
local bar = holderImage.Loader.Bar
local progress = bar.Progress
local progressText = bar.ProgressText
local rebirth2 = content.Rebirth
local requiredCharacters = holderImage.RequiredCharacters
local template = requiredCharacters.Template
local items = content.Unlockable.Items
local template2 = items.Template
local warning = playerGui:WaitForChild("LeftCenter").LeftCenter.Buttons.Rebirth.Warning
local v = nil

local function createLine(clone, color: Color3?, udim: UDim?)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = color or Color3.new(1, 1, 1)
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.ZIndex = clone.ZIndex + 4
	frame.Position = UDim2.fromScale(0.5, 0.5)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = udim or UDim.new(1, 0)
	uICorner.Parent = frame
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 45
	uIGradient.Offset = Vector2.new(-1.1, 0)
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.4, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.6, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
	frame.Parent = clone
	local tween = TweenService:Create(
		uIGradient,
		TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 2),
		{
			Offset = Vector2.new(1.1, 0)
		}
	)
	tween:Play()
	clone.Destroying:Connect(function()
		tween:Cancel()
		frame:Destroy()
		tween:Destroy()
	end)
end

local function CreateUnlockableItems(p: number)
	local count = #Rebirth
	local v2 = p + 1

	if #items:GetChildren() >= 1 then
		for _, image in ipairs(items:GetChildren()) do
			if image.Name ~= "Template" and image:IsA("ImageLabel") then
				image:Destroy()
			end
		end
	end

	if count < v2 or Rebirth[v2].IsEnabled and not Rebirth[v2].IsEnabled() and count - 1 < v2 then
		return 0
	end

	local rewards = Rebirth[v2].Rewards

	for k, reward in pairs(rewards) do
		if not (k ~= "Cash" or not RebirthFlags.ConsumeRequirementsOnly:Get()) then
			continue
		end

		if k == "Items" and typeof(reward) == "table" then
			for _, name in ipairs(reward) do
				local clone = template2:Clone()
				local itemName = clone.ItemName
				local itemImage = clone.ItemImage
				itemName.Text = string.upper(name)
				clone.Name = name
				itemImage.Image = ShopItems[name] and ShopItems[name].Icon or ""
				clone.ClipsDescendants = true
				clone.LayoutOrder = 10
				clone.Visible = true
				clone.Parent = items
				createLine(clone)
			end
		else
			local clone = template2:Clone()
			clone.Name = k
			local itemName = clone.ItemName
			local itemValue = clone.ItemValue
			local itemImage = clone.ItemImage
			clone.ClipsDescendants = true
			itemValue.Visible = true

			if k == "Cash" then
				itemName.Text = "CASH"
				itemValue.Text = "$" .. NumberUtils:ToString(reward, 2)
				itemImage.Image = "rbxassetid://70626497369321"
				itemImage.ImageTransparency = 0.2
				clone.LayoutOrder = 2
			elseif k == "Multiplier" then
				itemName.Text = "MULTI"
				itemValue.Text = "x" .. reward
				itemImage.Image = "rbxassetid://70626497369321"
				itemImage.ImageTransparency = 0.2
				clone.LayoutOrder = 1
			elseif k == "AdditionalLockTime" then
				itemName.Text = "LOCK BASE"
				itemValue.Text = "+10 Sec"
				itemImage.Image = "rbxassetid://123877736890165"
				itemImage.Position = UDim2.fromScale(0.5, 0.5)
				itemImage.ImageTransparency = 0.2
				clone.LayoutOrder = 3
			elseif k == "FriendController" then
				itemName.Text = "Friend Controller"
				itemValue.Text = "Unlock"
				itemImage.Image = "rbxassetid://96730132757867"
				itemImage.ImageTransparency = 0.2
				clone.LayoutOrder = 4
			elseif k == "AnimalSlot" then
				itemName.Text = "Slot"
				itemValue.Text = "+" .. reward
				itemImage.Image = "rbxassetid://85000857078190"
				itemImage.ImageTransparency = 0.2
				clone.LayoutOrder = 4
			end

			createLine(clone)
			clone.Visible = true
			clone.Parent = items
		end
	end
end

local function CreateViewportCharacters(p: number)
	local count = #Rebirth
	local v2 = p + 1

	if #requiredCharacters:GetChildren() >= 1 then
		for _, image in ipairs(requiredCharacters:GetChildren()) do
			if image.Name ~= "Template" and image:IsA("ImageLabel") then
				image:Destroy()
			end
		end
	end

	if count < v2 or Rebirth[v2].IsEnabled and not Rebirth[v2].IsEnabled() and count - 1 < v2 then
		return 0
	end

	local requiredCharacters2 = Rebirth[v2].Requirements.RequiredCharacters
	local total = 0

	if not (#requiredCharacters2 >= 1) then
		return total
	end

	for i, requiredCharacter in ipairs(requiredCharacters2) do
		local clone = template:Clone()
		clone.Name = requiredCharacter .. i
		clone.Visible = true
		local color = Rarities[Animals2[requiredCharacter].Rarity].Color
		clone.CharacterName.Text = requiredCharacter
		clone.UIGradient.Color = AnimalController:HasAnimal(requiredCharacter) and ColorSequence.new(color) or ColorSequence.new(Color3.new(
			0.223529,
			0.196078,
			0.215686
		))
		total += AnimalController:HasAnimal(requiredCharacter) and 1 or 0
		clone.CheckImage.Visible = AnimalController:HasAnimal(requiredCharacter) and true or false
		clone.Parent = requiredCharacters
		clone.ViewportFrame.ImageColor3 = AnimalController:HasAnimal(requiredCharacter) and Color3.fromRGB(
			255,
			255,
			255
		) or Color3.fromRGB(0, 0, 0)
		Animals:AttachOnViewport(requiredCharacter, clone.ViewportFrame, true)
	end

	return total
end

local function UpdateRebirthButton(p: number, p2: number)
	local coins = Synchronizer:Get(localPlayer):Get("Coins")
	local count = #Rebirth
	local v2 = p + 1

	if count < v2 then
		rebirth2.ImageColor3 = Color3.fromRGB(138, 138, 138)
	elseif Rebirth[v2].IsEnabled and not Rebirth[v2].IsEnabled() and count - 1 < v2 then
		rebirth2.ImageColor3 = Color3.fromRGB(138, 138, 138)
	elseif GetRebirthCost(localPlayer, v2) <= coins and p2 == #Rebirth[v2].Requirements.RequiredCharacters then
		rebirth2.ImageColor3 = Color3.fromRGB(255, 255, 255)
		warning.Visible = true
	else
		rebirth2.ImageColor3 = Color3.fromRGB(138, 138, 138)
		warning.Visible = false
	end
end

return {
	Start = function(_)
		local v2 = 0
		local v3 = 0
		local v4 = 0
		v = InterfaceController:Register("Rebirth", rebirth, "TopQuint")
		v:AttachCloseButton(close)
		v:Close()
		v.OnOpen:Connect(function()
			if warning.Visible then
				warning.Visible = false
			end
		end)
		local v5 = AnimatedButton.new(rebirth2)
		v5:Animate()
		v5.OnActivated:Connect(function()
			local v6, v7 = remoteFunction:InvokeServer()

			if v6 then
				NotificationController:Success(v7)
			else
				NotificationController:Error(v7)
			end
		end)
		Synchronizer:WaitAndCall(localPlayer, function(object)
			object:OnChanged("Rebirth", function(p: number, _: number)
				v2 = p
				CreateUnlockableItems(v2)
				CreateViewportCharacters(v2)
			end, true)
			RebirthFlags.ConsumeRequirementsOnly.Changed:Connect(function()
				CreateUnlockableItems(v2)
			end)
			object:OnChanged("AnimalAddedOrRemoved", function()
				v3 = CreateViewportCharacters(v2)
				UpdateRebirthButton(v2, v3)
			end, true)

			local function TextUpdates()
				local count = #Rebirth
				local v6 = v2 + 1

				if v6 <= count and Rebirth[v6].IsEnabled and not Rebirth[v6].IsEnabled() then
					count -= 1
				end

				UpdateRebirthButton(v2, v3)

				if count < v6 then
					progress.Size = UDim2.new(1, 0, 1, 0)
					progress.BackgroundColor3 = Color3.new(0.490196, 0.941176, 0.439216)
					progressText.Text = "Completed!"
				else
					local rebirthCost = GetRebirthCost(localPlayer, v6)
					progress.Size = UDim2.new(math.clamp(v4 / rebirthCost, 0, 1), 0, 1, 0)
					local v8 = rebirthCost <= v4
					local string2 = NumberUtils:ToString(rebirthCost, 2)
					local v9 = progressText
					local v11

					if v8 then
						v11 = string2
					else
						v11 = NumberUtils:ToString((math.clamp(v4, 0, rebirthCost)))
					end

					v9.Text = "$ " .. v11 .. " / " .. "$ " .. string2
					progress.BackgroundColor3 = v8 and Color3.new(0.490196, 0.941176, 0.439216) or Color3.new(
						0.941176,
						0.729412,
						0.482353
					)
				end
			end

			object:OnChanged("Coins", function(p: number, _: number)
				v4 = p
				TextUpdates()
			end, true)

			local function Update()
				CreateUnlockableItems(v2)
				CreateViewportCharacters(v2)
				TextUpdates()
			end

			Updates.OnUpdateEnabled:Connect(Update)
			Updates.OnUpdateDisabled:Connect(Update)
			task.spawn(Update)
		end)
	end
}