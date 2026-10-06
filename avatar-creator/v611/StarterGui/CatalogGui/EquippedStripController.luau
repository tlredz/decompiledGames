local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local livePreview = parent.Root.LivePreview
local wearingRemote = game.ReplicatedStorage:WaitForChild("WearingRemote")
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local v = nil
local v2 = false
local v3 = false
local count = 0
local now = 0
local flag = false
local fn

local function call(p, options)
	if p == "List" then
		local v4 = 0.9 - (os.clock() - now)

		if v4 > 0 then
			task.wait(v4)
		end

		now = os.clock()
	end

	local success, result = pcall(function()
		return wearingRemote:InvokeServer(p, options or {})
	end)
	return success and result or {
		error = "Please try again."
	}
end

local function select(data)
	v = data

	for _, child in livePreview.EquippedItems:GetChildren() do
		local actions = child:FindFirstChild("Actions")

		if not actions then
			continue
		end

		actions.Visible = data ~= nil and child:GetAttribute("ItemId") == data.id
		actions.Buy.Text = child:GetAttribute("Owned") and "Owned" or child:GetAttribute("Available") and "Buy" or "Unavailable"
		local buy = actions.Buy
		buy.Interactable = child:GetAttribute("Known") == true and child:GetAttribute("Available") == true and not (child:GetAttribute("Owned") or v2)
		local remove = actions:FindFirstChild("Remove")
		remove.Interactable = not v2
	end

	livePreview.EquippedName.Text = not data and "Select an item" or data.name or "Select an item"
	livePreview.RemoveEquipped.Interactable = data ~= nil
	local buyEquipped = livePreview.BuyEquipped
	buyEquipped.Interactable = data ~= nil and data.known and data.available and not data.owned
	livePreview.BuyEquipped.Text = not data and "Buy" or data.owned and "Owned" or data.available and "Buy" or "Unavailable"
end

local fn2

fn2 = function()
	if not parent.Enabled then
		return
	end

	if v2 or v3 then
		flag = true
		return
	end

	v3 = true
	local v4 = count
	local v5 = call("List")
	v3 = false

	if v4 == count and not v2 then
		if v5.error then
			livePreview.EquippedHeading.Text = v5.error
			return
		end

		livePreview.EquippedHeading.Text = "Wearing · tap an item"
		local count2 = 0
		local total = 0
		local total2 = 0
		local count3 = 0

		for _, v6 in ipairs(v5.items or {}) do
			if v6.known then
				if v6.available and type(v6.price) == "number" then
					total += v6.price

					if not v6.owned then
						total2 += v6.price
					end
				else
					count2 += 1
				end
			else
				count3 += 1
			end
		end

		livePreview.OutfitCost.Text = "Available items: R$ " .. total .. "  |  To buy: R$ " .. total2 .. "\n" .. (count3 > 0 and count3 .. " prices unavailable · partial total" or count2 > 0 and count2 .. " items unavailable individually" or "Estimated catalog prices · final price at checkout")
		local id = v and v.id
		select(nil)
		local v6 = {}

		for i, v7 in ipairs(v5.items or {}) do
			local v8 = "Equipped_" .. string.format("%.0f", v7.id)
			v6[v8] = true
			local child = livePreview.EquippedItems:FindFirstChild(v8)

			if not child then
				child = CatalogUI.button(v8, livePreview.EquippedItems, "", UDim2.new(), UDim2.fromOffset(62, 62))
				CatalogUI.make("ImageLabel", "Icon", child, {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = "rbxthumb://type=Asset&id=" .. string.format("%.0f", v7.id) .. "&w=150&h=150"
				})
				local v9 = CatalogUI.make("Frame", "Actions", child, {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.fromRGB(32, 36, 44),
					BackgroundTransparency = 0.04,
					Visible = false,
					Active = true,
					ZIndex = child.ZIndex + 3
				})
				CatalogUI.round(v9, 10)
				local button = CatalogUI.button("Buy", v9, "Buy", UDim2.fromOffset(5, 5), UDim2.new(1, -10, 0.5, -8))
				local button2 = CatalogUI.button(
					"Remove",
					v9,
					"Remove",
					UDim2.new(0, 5, 0.5, 3),
					UDim2.new(1, -10, 0.5, -8)
				)
				button.BackgroundColor3 = Color3.fromRGB(100, 242, 130)
				button.TextColor3 = Color3.fromRGB(17, 45, 26)
				button2.BackgroundColor3 = Color3.fromRGB(225, 48, 59)
				button2.TextColor3 = Color3.new(1, 1, 1)

				for _, v10 in { button, button2 } do
					v10.ZIndex = v9.ZIndex + 1
					v10.Font = Enum.Font.GothamBold
					v10.TextSize = 18
				end

				button.Activated:Connect(function()
					if button.Interactable then
						fn("BuyOne")
					end
				end)
				button2.Activated:Connect(function()
					if button2.Interactable then
						fn("Remove")
					end
				end)
				child.Activated:Connect(function()
					local v12 = {
						id = child:GetAttribute("ItemId"),
						name = child:GetAttribute("ItemName"),
						known = child:GetAttribute("Known"),
						available = child:GetAttribute("Available"),
						owned = child:GetAttribute("Owned")
					}

					if not v2 then
						select(v12)
					end
				end)
			end

			local id2 = v7.id
			child:SetAttribute("ItemId", id2)
			local name = v7.name
			child:SetAttribute("ItemName", name)
			local known = v7.known
			child:SetAttribute("Known", known)
			local available = v7.available
			child:SetAttribute("Available", available)
			local owned = v7.owned
			child:SetAttribute("Owned", owned)
			child.LayoutOrder = i
			MenuFade.Set(child, "Visible", true)

			if v7.id == id then
				select(v7)
			end
		end

		for _, guiObject in ipairs(livePreview.EquippedItems:GetChildren()) do
			if not guiObject:IsA("GuiObject") or v6[guiObject.Name] then
				continue
			end

			guiObject:Destroy()
		end

		if flag then
			flag = false
			task.defer(fn2)
		end
	else
		flag = true

		if not v2 then
			flag = false
			task.defer(fn2)
		end
	end
end

fn = function(p)
	if v2 or not v then
		return
	end

	v2 = true
	count += 1
	local v4 = v
	local child = livePreview.EquippedItems:FindFirstChild("Equipped_" .. string.format("%.0f", v4.id))

	if p == "Remove" then
		if child then
			MenuFade.Set(child, "Visible", false)
		end

		livePreview.EquippedName.Text = "Taking off " .. v4.name .. "..."
		livePreview.RemoveEquipped.Interactable = false
		livePreview.BuyEquipped.Interactable = false
	end

	local v5 = call(p, {
		id = v4.id
	})

	if v5.error and p == "Remove" then
		if child and child.Parent then
			MenuFade.Set(child, "Visible", true)
		end

		select(v4)
	end

	v2 = false
	livePreview.EquippedHeading.Text = v5.error or "Wearing · tap an item"
	livePreview.EquippedName.Text = v5.error or v5.message

	if p == "Remove" and not v5.error then
		select(nil)
	end

	if flag or p == "Remove" then
		flag = false
		task.defer(fn2)
	end
end

livePreview.RemoveEquipped.Activated:Connect(function()
	fn("Remove")
end)
livePreview.BuyEquipped.Activated:Connect(function()
	fn("BuyOne")
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if MenuFade.IsOpen(parent, "Enabled") then
		fn2()
	end
end)
local applyDescriptionFinishedConnection = nil

local function bind(instance)
	if applyDescriptionFinishedConnection then
		applyDescriptionFinishedConnection:Disconnect()
	end

	applyDescriptionFinishedConnection = instance:WaitForChild("Humanoid").ApplyDescriptionFinished:Connect(function()
		task.defer(fn2)
	end)

	if MenuFade.IsOpen(parent, "Enabled") then
		fn2()
	end
end

localPlayer.CharacterAdded:Connect(bind)

if localPlayer.Character then
	task.spawn(bind, localPlayer.Character)
end

select(nil)