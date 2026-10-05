local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Maid = require(game.ReplicatedStorage.Util.Maid)
local ImageUtil = require(game.ReplicatedStorage:WaitForChild("Modules").Asset.ImageUtil)
local ItemConfig = require(game.ReplicatedStorage:WaitForChild("ItemConfig"))
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset:WaitForChild("RarityUtil"))
local Sound = require(game.ReplicatedStorage.Util:WaitForChild("Sound"))
local random = Random.new()
local dropIconNew = script:WaitForChild("DropIconNew")
local v = nil
local v2 = nil
local flag = false

local function findHudButton(folder, p)
	for _, button in folder:GetDescendants() do
		if button.Name == p and button:IsA("GuiButton") then
			return button
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tween(p, tweenInfo, p2)
	local tween2 = TweenService:Create(p, tweenInfo, p2)
	tween2:Play()
	return tween2
end

local function getDropItemConfig(instance)
	local storageKey = instance:GetAttribute("StorageKey") or instance.Value
	local idType = instance:GetAttribute("IdType")

	if typeof(idType) == "string" and idType ~= "" then
		local success, result = pcall(function()
			return ItemConfig.tryGet(storageKey, idType)
		end)

		if success and result then
			return result
		end
	end

	for _, v3 in ipairs({
		"Item",
		"Fruit",
		"Material",
		"Fish"
	}) do
		local v4 = v3
		local success, result = pcall(function()
			return ItemConfig.tryGet(storageKey, v4)
		end)

		if success and result then
			return result
		end
	end

	return nil
end

local function getDropRarityData(instance)
	local dropItemConfig = getDropItemConfig(instance)
	local rarity = dropItemConfig and dropItemConfig.Quality and dropItemConfig.Quality.Rarity

	if typeof(rarity) ~= "string" or rarity == "" then
		rarity = instance:GetAttribute("Rarity")
	end

	local v3 = (typeof(rarity) ~= "string" or rarity == "") and "Common" or rarity
	return v3, RarityUtil.tryGetRarity(v3) or RarityUtil.tryGetRarity("Common")
end

local function getRarityGradient(color)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, color:Lerp(Color3.new(1, 1, 1), 0.35)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(0, 0, 0), 0.35))
	})
end

local function getDropDetailsText(instance)
	local value = instance.Value
	local amount = instance:GetAttribute("Amount")

	if typeof(amount) == "number" and amount > 1 then
		return (`{value} x{amount}`)
	end

	return value
end

local function clearDropList(instance)
	if not instance then
		return
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local function clearBossBarDrops(p, p2, p3)
	if flag and not p3 then
		return
	end

	if v then
		v:DoCleaning()
		v = nil
	end

	if p3 and v2 then
		v2:DoCleaning()
		v2 = nil
	end

	clearDropList(p)

	if p then
		p.Visible = false
	end

	if p2 then
		p2.Visible = false
	end
end

local function renderBossBarDrops(enemy, dropList, dropsTextLabel)
	if flag then
		return
	end

	if v then
		v:DoCleaning()
		v = nil
	end

	if v2 then
		v2:DoCleaning()
		v2 = nil
	end

	clearDropList(dropList)

	if dropList then
		dropList.Visible = false
	end

	if dropsTextLabel then
		dropsTextLabel.Visible = false
	end

	if not (enemy and enemy.Parent and dropList) then
		return
	end

	local dropPreview = enemy:FindFirstChild("DropPreview")

	if not dropPreview then
		return
	end

	local stringValues = {}

	for _, stringValue in ipairs(dropPreview:GetChildren()) do
		if stringValue:IsA("StringValue") then
			table.insert(stringValues, stringValue)
		end
	end

	if #stringValues == 0 then
		return
	end

	local maid = Maid.new()
	v = maid
	table.sort(stringValues, function(a, b)
		local _, v3 = getDropRarityData(a)
		local _, v4 = getDropRarityData(b)
		local value = v3 and v3.Value or 0
		local value2 = v4 and v4.Value or 0

		if value == value2 then
			return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
		end

		return value2 < value
	end)
	dropList.Visible = true
	dropList.ClipsDescendants = false
	local parent = dropList.Parent

	if parent and parent:IsA("GuiObject") then
		parent.ClipsDescendants = false
	end

	if dropsTextLabel then
		dropsTextLabel.Visible = true
	end

	for _, v3 in ipairs(stringValues) do
		local clone = dropIconNew:Clone()
		clone.Name = v3.Value
		clone.Visible = true
		clone.Parent = dropList
		local dropRarityData, v4 = getDropRarityData(v3)
		local color = v4 and v4.Color or Color3.fromRGB(179, 179, 179)
		local value = v4 and v4.Value or 0
		clone:SetAttribute("RarityColor", color)

		if dropRarityData == "Mythical" then
			clone.BackgroundColor3 = Color3.fromRGB(38, 3, 3)
		else
			clone.BackgroundColor3 = color:Lerp(Color3.new(0, 0, 0), 0.65)
		end

		if clone:IsA("GuiButton") then
			clone.AutoButtonColor = false
			clone.Selectable = true
			clone.Active = true
		end

		ImageUtil.applySprite(v3.Value, {
			Icon = clone
		})

		for _, uIGradient in ipairs(clone:GetDescendants()) do
			if uIGradient:IsA("UIGradient") then
				uIGradient.Color = getRarityGradient(color)
			end
		end

		local uIStroke = clone:FindFirstChildWhichIsA("UIStroke")
		local uIGradient = uIStroke and uIStroke:FindFirstChildWhichIsA("UIGradient")

		if uIStroke then
			uIStroke.Color = color
		end

		if uIGradient then
			if value >= 3 then
				local icon = clone
				local v7 = uIGradient
				local v8 = value >= 4 and 120 or 75
				maid:GiveTask(RunService.RenderStepped:Connect(function()
					if icon.Parent and v7.Parent then
						v7.Rotation = os.clock() * v8 % 360
					end
				end))
			else
				uIGradient.Rotation = -90
			end
		end

		local shadow = clone:FindFirstChild("Shadow")
		local details = shadow and shadow:FindFirstChild("Details")
		local text = v3.Value
		local amount = v3:GetAttribute("Amount")

		if typeof(amount) == "number" and amount > 1 then
			text = `{text} x{amount}`
		end

		if shadow and shadow:IsA("TextLabel") then
			shadow.Text = text
			shadow.Visible = false
		end

		if details and details:IsA("TextLabel") then
			details.Text = text
			details.Visible = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local label = shadow
		local label2 = details

		local function showDetails(visible)
			if label and label:IsA("TextLabel") then
				label.Visible = visible
			end

			if label2 and label2:IsA("TextLabel") then
				label2.Visible = visible
			end
		end

		if not clone:IsA("GuiButton") then
			continue
		end

		local v5 = shadow
		local v6 = details
		maid:GiveTask(clone.MouseEnter:Connect(function()
			showDetails(true) -- equivalent call inferred; original call site unknown
		end))
		local v7 = shadow
		local v8 = details
		maid:GiveTask(clone.MouseLeave:Connect(function()
			showDetails(false) -- equivalent call inferred; original call site unknown
		end))
		local v9 = shadow
		local v10 = details
		maid:GiveTask(clone.SelectionGained:Connect(function()
			showDetails(true) -- equivalent call inferred; original call site unknown
		end))
		local v11 = shadow
		local v12 = details
		maid:GiveTask(clone.SelectionLost:Connect(function()
			showDetails(false) -- equivalent call inferred; original call site unknown
		end))
		local label3 = shadow
		local label4 = details
		maid:GiveTask(clone.Activated:Connect(function()
			local visible = false

			if label3 and label3:IsA("TextLabel") then
				visible = label3.Visible
			elseif label4 and label4:IsA("TextLabel") then
				visible = label4.Visible
			end

			showDetails(not visible) -- equivalent call inferred; original call site unknown
		end))
	end
end

local function collectBossBarDrops(dropList, dropsTextLabel)
	if flag or not dropList then
		return
	end

	local guiObjects = {}

	for _, guiObject in ipairs(dropList:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			table.insert(guiObjects, guiObject)
		end
	end

	if #guiObjects == 0 then
		if v then
			v:DoCleaning()
			v = nil
		end

		if v2 then
			v2:DoCleaning()
			v2 = nil
		end

		clearDropList(dropList)

		if dropList then
			dropList.Visible = false
		end

		if dropsTextLabel then
			dropsTextLabel.Visible = false
		end
	else
		flag = true

		if v2 then
			v2:DoCleaning()
		end

		if v then
			v:DoCleaning()
			v = nil
		end

		local maid = Maid.new()
		v2 = maid
		local playerGui = localPlayer:FindFirstChild("PlayerGui")

		if playerGui then
			local hUDRoot = playerGui:WaitForChild("HUDRoot", 5)
			local parent2 = hUDRoot and findHudButton(hUDRoot, "Items")

			if not (parent2 and parent2.Visible) then
				parent2 = hUDRoot and findHudButton(hUDRoot, "Menu")
			end

			if parent2 then
				local v4 = parent2:FindFirstChildOfClass("UIScale")
				local flag2

				if v4 then
					flag2 = false
				else
					v4 = Instance.new("UIScale")
					v4.Scale = 1
					v4.Parent = parent2
					flag2 = true
				end

				local scale = v4.Scale
				local rotation = parent2.Rotation
				local backgroundColor3 = parent2.BackgroundColor3
				local borderColor3 = parent2.BorderColor3
				local trans = parent2:FindFirstChild("Trans")
				local backgroundColor32 = trans and trans.BackgroundColor3
				local count = 0

				-- equivalent calls inferred from this helper; original call sites unknown
				local function resetButtonColor(p)
					if parent2 and parent2.Parent then
						if p then
							TweenService:Create(
								parent2,
								TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									BackgroundColor3 = backgroundColor3,
									BorderColor3 = borderColor3,
									Rotation = rotation
								}
							):Play()
						else
							parent2.BackgroundColor3 = backgroundColor3
							parent2.BorderColor3 = borderColor3
							parent2.Rotation = rotation
						end
					end

					if trans and trans:IsA("Frame") and backgroundColor32 then
						if p then
							TweenService:Create(
								trans,
								TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									BackgroundColor3 = backgroundColor32
								}
							):Play()
						else
							trans.BackgroundColor3 = backgroundColor32
						end
					end

					if v4 and v4.Parent then
						v4.Scale = scale

						if flag2 then
							v4:Destroy()
						end
					end
				end

				maid:GiveTask(function()
					resetButtonColor(false) -- equivalent call inferred; original call site unknown
				end)

				local function pulseTargetButton(rarityColor)
					if not parent2.Parent then
						return
					end

					Sound:Play("Other.CelestialTokenCollected", nil, nil, random:NextNumber(0.92, 1.12), 0.65)

					if rarityColor then
						local lerped = rarityColor:Lerp(Color3.new(0, 0, 0), 0.45)
						TweenService:Create(
							parent2,
							TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								BackgroundColor3 = rarityColor,
								BorderColor3 = lerped
							}
						):Play()

						if trans and trans:IsA("Frame") then
							TweenService:Create(
								trans,
								TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									BackgroundColor3 = rarityColor
								}
							):Play()
						end
					end

					count += 1
					local v5 = count % 2 == 0 and -1 or 1
					v4.Scale = scale * 1.18
					parent2.Rotation = rotation + v5 * 8
					TweenService:Create(v4, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = scale
					}):Play()
					TweenService:Create(parent2, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Rotation = rotation
					}):Play()
				end

				dropList.ClipsDescendants = false
				local parent = dropList.Parent

				if parent and parent:IsA("GuiObject") then
					parent.ClipsDescendants = false
				end

				for _, button in ipairs(guiObjects) do
					local shadow = button:FindFirstChild("Shadow")
					local details = shadow and shadow:FindFirstChild("Details")

					if shadow and shadow:IsA("TextLabel") then
						shadow.Visible = false
					end

					if details and details:IsA("TextLabel") then
						details.Visible = false
					end

					if not button:IsA("GuiButton") then
						continue
					end

					button.Selectable = false
					button.Active = false
				end

				local absolutePosition = dropList.AbsolutePosition
				local v5 = parent2.AbsolutePosition + Vector2.new(
					parent2.AbsoluteSize.X / 2,
					parent2.AbsoluteSize.Y / 2
				)
				local uDim = UDim2.fromOffset(v5.X - absolutePosition.X, v5.Y - absolutePosition.Y)
				local v6 = {}

				for _, v7 in ipairs(guiObjects) do
					v6[v7] = {
						Position = v7.AbsolutePosition,
						Size = v7.AbsoluteSize
					}
				end

				local uIListLayout = dropList:FindFirstChildOfClass("UIListLayout")

				if uIListLayout then
					uIListLayout.Parent = nil
					maid:GiveTask(function()
						if uIListLayout and not uIListLayout.Parent and dropList.Parent then
							uIListLayout.Parent = dropList
						end
					end)
				end

				for _, folder in ipairs(guiObjects) do
					local v7 = v6[folder]
					local position = v7.Position
					local size = v7.Size
					folder.AnchorPoint = Vector2.new(0.5, 0.5)
					folder.Position = UDim2.fromOffset(
						position.X - absolutePosition.X + size.X / 2,
						position.Y - absolutePosition.Y + size.Y / 2
					)
					folder.Size = UDim2.fromOffset(size.X, size.Y)
					folder.Rotation = 0
					folder.ZIndex += 100

					for _, guiObject in ipairs(folder:GetDescendants()) do
						if guiObject:IsA("GuiObject") then
							guiObject.ZIndex += 100
						end
					end
				end

				for i, v7 in ipairs(guiObjects) do
					local v8 = v7
					task.delay((i - 1) * 0.04, function()
						if not v8.Parent then
							return
						end

						;(tween(v8, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
							Position = uDim,
							Size = UDim2.fromOffset(0, 0),
							Rotation = -220,
							BackgroundTransparency = 1
						})).Completed:Once(function(p)
							if p == Enum.PlaybackState.Completed then
								pulseTargetButton(v8:GetAttribute("RarityColor"))
							end
						end)
					end)
				end

				task.delay(#guiObjects * 0.04 + 0.65, function()
					if uIListLayout and not uIListLayout.Parent and dropList.Parent then
						uIListLayout.Parent = dropList
					end

					resetButtonColor(true)
					task.delay(0.16, function()
						clearDropList(dropList)

						if dropList then
							dropList.Visible = false
						end

						if dropsTextLabel then
							dropsTextLabel.Visible = false
						end

						flag = false

						if v2 == maid then
							v2 = nil
						end

						maid:DoCleaning()
					end)
				end)
			else
				flag = false
				maid:DoCleaning()
				v2 = nil

				if v then
					v:DoCleaning()
					v = nil
				end

				if v2 then
					v2:DoCleaning()
					v2 = nil
				end

				clearDropList(dropList)

				if dropList then
					dropList.Visible = false
				end

				if dropsTextLabel then
					dropsTextLabel.Visible = false
				end
			end
		else
			flag = false
			maid:DoCleaning()
			v2 = nil
		end
	end
end

return function(data)
	if data.Phase == "BossBar" then
		renderBossBarDrops(data.Enemy, data.DropList, data.DropsTextLabel)
		return
	end

	if data.Phase == "CollectBossBar" then
		collectBossBarDrops(data.DropList, data.DropsTextLabel)
		return
	end

	if data.Phase ~= "ClearBossBar" then
		return
	end

	local dropList = data.DropList
	local dropsTextLabel = data.DropsTextLabel

	if flag then
		return
	end

	if v then
		v:DoCleaning()
		v = nil
	end

	clearDropList(dropList)

	if dropList then
		dropList.Visible = false
	end

	if dropsTextLabel then
		dropsTextLabel.Visible = false
	end
end