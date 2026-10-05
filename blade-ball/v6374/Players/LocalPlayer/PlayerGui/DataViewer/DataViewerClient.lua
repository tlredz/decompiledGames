local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local emotes = ReplicatedStorage.Misc.Emotes
local Utils = require(ReplicatedStorage.Common.Utils)
local Replion = require(ReplicatedStorage.Packages.Replion)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = require(ReplicatedStorage.Common.MarketplaceService)
local Swords = require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
local PlayerUtility = require(ReplicatedStorage.Shared.PlayerUtility)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local Net = require(ReplicatedStorage.Packages.Net)
local Emotes = require(ReplicatedStorage.Shared.RNG.Emotes)
local NonGiveableItems = require(ReplicatedStorage.Shared.NonGiveableItems)
local ColorsUtil = require(ReplicatedStorage.Common.ColorsUtil)
local parent = script.Parent
local window = parent.Window
local loading = window.Loading
local banButton = window.Board.BanButton
local banDuration = window.Board.BanDuration
local banReason = window.Board.BanReason
local Players2 = game:GetService("Players")
local localPlayer = Players2.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local remoteEvent = Net:RemoteEvent("RequestExistCountRefresh")
local remoteEvent2 = Net:RemoteEvent("RequestViewExistCount")
local v = {
	["N/A"] = 0,
	Duo = 1,
	Normal = 1,
	Common = 2,
	Rare = 3,
	Legendary = 4,
	Unique = 5,
	Limited = 6,
	LimitedU = 7,
	Secret = 8
}
local maid = Utils.Maid.new()
local maid2 = Utils.Maid.new()
local maid3 = Utils.Maid.new()
local v2 = {
	string = function(p, object, p2)
		local textBox = p2.TextBox

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetValue()
			textBox.Text = object.GetValue and object:GetValue() or ""
		end

		textBox.Visible = true

		if object.ValueChanged then
			p.ValueChanged = object.ValueChanged:Connect(SetValue)
		end

		p.FocusLost = textBox.FocusLost:Connect(function(p3, p4)
			if p3 and p4 then
				object.ValueUpdated:Fire(textBox.Text)
			else
				SetValue() -- equivalent call inferred; original call site unknown
			end
		end)
		SetValue() -- equivalent call inferred; original call site unknown
	end,
	number = function(p, object, p2)
		local textBox = p2.TextBox

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetValue()
			local value = object.GetValue and tonumber(object:GetValue())

			if value then
				textBox.Text = tostring(value or 0)
			else
				textBox.Text = "[REMOVED]"
			end
		end

		textBox.Visible = true

		if object.ValueChanged then
			p.ValueChanged = object.ValueChanged:Connect(SetValue)
		end

		p.FocusLost = textBox.FocusLost:Connect(function(p3, p4)
			if p3 and p4 then
				local v3 = textBox.Text:gsub(",", "")
				object.ValueUpdated:Fire(tonumber(v3) or 0)
			else
				SetValue() -- equivalent call inferred; original call site unknown
			end
		end)
		SetValue() -- equivalent call inferred; original call site unknown
	end,
	boolean = function(p, object, p2)
		local toggleBox = p2.ToggleBox
		local v3 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetValue(value)
			v3 = value

			if value then
				toggleBox.Button.BackgroundTransparency = 0
				toggleBox.Button.ImageTransparency = 0
			else
				toggleBox.Button.ImageTransparency = 1
				toggleBox.Button.BackgroundTransparency = 1
			end
		end

		local value = object.GetValue and object:GetValue()
		SetValue(value) -- equivalent call inferred; original call site unknown
		toggleBox.Visible = true

		if object.ValueChanged then
			p.ValueChanged = object.ValueChanged:Connect(SetValue)
		end

		p.OnPress = toggleBox.Button.Activated:Connect(function()
			object.ValueUpdated:Fire(not v3)
		end)
	end,
	table = function(_, _, _) end
}

local function fauxTable(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function sortByCount(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	table.sort(result, function(a, b)
		return a.Count > b.Count
	end)
	return result
end

local function SetCirclePosition(p)
	local circle = loading.Circle

	if p then
		local v3 = math.clamp(math.ceil(math.clamp((1 - math.abs(p - 0.5)) / 1.1, 0, 1) * 64), 0, 63)
		circle.ImageRectOffset = Vector2.new(v3 % 8 * 75, math.floor(v3 / 8) * 75)
		circle.Rotation = p * 1080
	end
end

local function SetLoading(p, value)
	if p then
		loading.Title.Text = value or "Loading..."

		if maid2.Loading then
			return
		end

		maid2.Loading = true
		loading.Visible = true
		TweenService:Create(loading, TweenInfo.new(0.2), {
			BackgroundTransparency = 0
		})
		maid.LoadingAnim = Utils.Thread.Delay(0.2, function()
			loading.Visible = true
		end)
		local total = 0
		maid2.Animation = Utils.Thread.Loop(function(p2)
			total += p2
			SetCirclePosition(total % 2 / 2)
		end)
		maid2:GiveTask(function()
			TweenService:Create(loading, TweenInfo.new(0.2), {
				BackgroundTransparency = 1
			})
			maid.LoadingAnim = Utils.Thread.Delay(0.2, function()
				loading.Visible = false
			end)
		end)
	else
		if not maid2.Loading then
			return
		end

		maid2:Destroy()
	end
end

local function GetDataSize(p: number)
	local v3 = 1

	while p > 1024 do
		p /= 1024
		v3 += 1
	end

	return math.floor(p * 100) / 100 .. ({ "B", "KB", "MB" })[v3]
end

local function CreatePropertyField(p, p2, p3)
	local maid4 = Utils.Maid.new()
	maid4.Active = true
	local v3 = {
		ValueChanged = Utils.Signal.new(),
		ValueUpdated = Utils.Signal.new(),
		DataType = typeof(p3),
		DropDownClicked = Utils.Signal.new(),
		_maid = maid4,
		GetValue = function(self)
			return p3
		end
	}
	local clone

	if typeof(p3) == "table" then
		local signal = Utils.Signal.new()
		v3.DropDownClicked = signal
		clone = p.Assets.TemplateTable:Clone()
		clone.Top.Title.Text = p2
		local maid5 = Utils.Maid.new()
		clone.Top.Drop.Image = Utils.Icons:GetIcon("DropUp")
		v3._DropDownMaid = maid5
		maid4[clone] = clone.Activated:Connect(function()
			if maid5.Active then
				maid5:Destroy()
				return
			end

			clone.Top.Drop.Image = Utils.Icons:GetIcon("DropDown")

			function maid5.Active()
				clone.Top.Drop.Image = Utils.Icons:GetIcon("DropUp")
			end

			signal:Fire(maid5)
		end)
		maid4:GiveTask(maid5)
		maid4.Delete = clone.Top.Delete.Activated:Connect(function()
			v3.ValueUpdated:Fire(nil)
		end)
		v3.RemovingFrame = clone.Top.RemovingFrame
		v3.AddingFrame = clone.Top.AddingFrame
		clone.LayoutOrder = 1000
		clone.Name = "~" .. p2
	else
		clone = p.Assets.TemplateProperty:Clone()
		clone.Title.Text = p2
		maid4.Delete = clone.Delete.Activated:Connect(function()
			v3.ValueUpdated:Fire(nil)
		end)
		v3.RemovingFrame = clone.RemovingFrame
		v3.AddingFrame = clone.AddingFrame
		clone.Name = p2
	end

	clone.Visible = true
	local v4 = v2[typeof(p3)]

	if v4 then
		v4(maid4, v3, clone)
	else
		warn("No property mode for " .. typeof(p3), p2, p3)
	end

	v3.Frame = clone
	return v3
end

local function sortByNameDesc(list)
	local result = {}

	for k, v3 in pairs(list) do
		result[k] = v3
	end

	table.sort(list, function(a, b)
		return a.Name > b.Name
	end)
	return result
end

local function update(object, p)
	local items = object:Get("Items")
	local result = {}

	for k, item in items do
		if k ~= p then
			continue
		end

		result = {}

		for k2, count in item do
			table.insert(result, {
				Name = k2,
				Count = count
			})
		end
	end

	return result
end

local function getExistCounter(p)
	remoteEvent2:FireServer()
	local v3 = Replion.Client:WaitReplion("ExistCount")

	if v3:Get("Loaded") then
		return (update(v3, p))
	end

	warn("Loading exist counters.")
	SetLoading(true, "Waiting for data...")
	remoteEvent:FireServer()

	repeat
		task.wait()
	until v3:Get("Loaded")

	if maid2.Loading then
		maid2:Destroy()
	end

	return (update(v3, p))
end

local function createInventory(_, _, p, _, _, _)
	if p then
	end
end

local v3 = {
	Data = function(p, p2, _, p3, p4)
		local v4 = {}
		local v5 = {}
		local v6 = {}
		local isSearchElementPresent

		isSearchElementPresent = function(item)
			for k, item2 in pairs(item) do
				if tostring(k) and tostring(k):lower():find(p4) then
					return true
				end

				if tostring(item2) and tostring(item2):lower():find(p4) then
					return true
				end

				if typeof(item2) == "table" and isSearchElementPresent(item2) then
					return true
				end
			end
		end

		local deepAdd

		deepAdd = function(items, p5, p6, options, flag: boolean)
			local v7 = options or {}
			local connectionsByGuiObject = p6 or Utils.Maid.new()
			local clone = p.Assets.TableContents:Clone()
			clone.Visible = true
			local guiObjects = {}
			local name = "string"

			for _, guiObject in pairs(clone.AddSelected.ValueFrame.PropertyTypes.Areas:GetChildren()) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				guiObjects[#guiObjects + 1] = guiObject
				local v8 = guiObject
				connectionsByGuiObject[guiObject] = guiObject.Activated:Connect(function()
					name = v8.Name

					if name == "table" or name == "boolean" then
						clone.AddSelected.ValueFrame.ValueBox.Visible = false
					else
						clone.AddSelected.ValueFrame.ValueBox.Visible = true
					end

					clone.AddSelected.ValueFrame.ValueBox.Text = ""
					clone.AddSelected.ValueFrame.PropertyTypes.CurrentButton.Text = name
					clone.AddSelected.ValueFrame.PropertyTypes.ClipsDescendants = true
				end)
			end

			clone.AddSelected.ValueFrame.PropertyTypes.CurrentButton.Activated:Connect(function()
				clone.AddSelected.ValueFrame.PropertyTypes.ClipsDescendants = not clone.AddSelected.ValueFrame.PropertyTypes.ClipsDescendants
			end)
			clone.AddSelected.IndexFrame.Add.Activated:Connect(function()
				local text = clone.AddSelected.ValueFrame.ValueBox.Text

				if name ~= "string" then
					if name == "number" then
						text = tonumber(text)
					elseif name == "boolean" then
						text = text == "true"
					else
						text = name == "table" and {} or text
					end
				end

				if text == nil then
					return
				end

				local v8 = {}

				for _, v9 in pairs(v7) do
					v8[#v8 + 1] = v9
				end

				local copyDictionary = Utils.Table.CopyDictionary(p2)

				for _, v9 in pairs(v7) do
					copyDictionary = copyDictionary[v9]
				end

				local text2 = clone.AddSelected.IndexFrame.IndexBox.Text
				local v9 = text2 == "" and "1" or text2
				local v10 = #copyDictionary ~= 0 and Utils.Table.IsDictionary(copyDictionary) or v9 ~= "1"

				if v10 then
					local v11 = true

					while v11 do
						v9 = tostring(v9)
						v11 = copyDictionary[v9] and true or false

						if not v11 then
							for k in pairs(v4) do
								if #k - 1 ~= #v8 then
									continue
								end

								local v13 = true

								for k2, v15 in pairs(v8) do
									if k[k2] == v15 then
										continue
									end

									v13 = false
									break
								end

								if not (v13 and k[#k] == v9) then
									continue
								end

								v11 = true
								break
							end
						end

						if not v11 then
							continue
						end

						local v12 = tonumber(v9:match("%d+$"))

						if v12 then
							v9 = v9:gsub("%d+$", v12 + 1)
						else
							v9 ..= "1"
						end
					end

					v8[#v8 + 1] = v9
				else
					v9 = "#array"
				end

				local propertyField = CreatePropertyField(p, v9, text)

				local function setValue(p7)
					if v10 then
						v4[v8] = p7
						return
					end

					propertyField.Value = p7
					v5[v8] = propertyField
				end

				local v12 = text

				if v10 then
					v4[v8] = v12
				else
					propertyField.Value = v12
					v5[v8] = propertyField
				end

				propertyField.AddingFrame.Visible = true
				propertyField.ValueUpdated:Connect(function(p7)
					if p7 == nil then
						propertyField.Frame:Destroy()
					end

					if v10 then
						v4[v8] = p7
					else
						propertyField.Value = p7
						v5[v8] = propertyField
					end

					propertyField.ValueChanged:Fire(p7)
				end)

				function propertyField.GetValue()
					return v5[v8] and propertyField.Value or text
				end

				propertyField.Frame.LayoutOrder = 0
				propertyField.Frame.Parent = clone
			end)

			for k, item in pairs(items) do
				if not (not p4 or flag or tostring(k) and tostring(k):lower():find(p4) or tostring(item) and tostring(item):lower():find(p4) or typeof(item) == "table" and isSearchElementPresent(item)) then
					continue
				end

				local v8 = {}

				for _, v9 in pairs(v7) do
					v8[#v8 + 1] = v9
				end

				v8[#v8 + 1] = k
				local propertyField = CreatePropertyField(p, k, item)
				local v12 = item
				propertyField.ValueUpdated:Connect(function(p7)
					if p7 == nil then
						if v6[v8] then
							v6[v8] = nil
							v4[v8] = nil
							propertyField.RemovingFrame.Visible = false
							propertyField.ValueChanged:Fire(v12)
							return
						else
							v6[v8] = propertyField
							propertyField.RemovingFrame.Visible = true
						end
					elseif p7 == v12 then
						v4[v8] = nil
					else
						v4[v8] = p7
					end

					propertyField.ValueChanged:Fire(p7)
				end)
				local v13 = v8
				local v14 = item

				function propertyField.GetValue()
					return not v6[v13] and (v4[v13] or v14)
				end

				if propertyField.DropDownClicked then
					local propertyField2 = propertyField
					local v16 = item
					local v17 = v8
					propertyField.DropDownClicked:Connect(function(maid4, p7)
						repeat
							task.wait()
						until propertyField2.Frame and propertyField2.Frame:FindFirstChild("Content") or not propertyField2._maid.Active

						if not propertyField2._maid.Active then
							return
						end

						if p7 then
							propertyField2.Frame.Top.Drop.Image = Utils.Icons:GetIcon("DropDown")
						end

						local v18 = deepAdd(v16, propertyField2.Frame.Content, maid4, v17, not p7)
						maid4:GiveTask(function()
							v18:Destroy()
						end)
					end)

					if p4 then
						propertyField.DropDownClicked:Fire(propertyField._DropDownMaid, true)
					end
				end

				if not propertyField.Frame then
					continue
				end

				if p4 and (tostring(k) and tostring(k):lower():find(p4) or tostring(item) and tostring(item):lower():find(p4)) then
					if propertyField.DataType == "table" then
						propertyField.Frame.Top.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
					else
						propertyField.Frame.BackgroundTransparency = 0
					end
				end

				propertyField.Frame.Parent = clone
			end

			clone.Parent = p5 or p
			return clone
		end

		local flag = false
		maid3.SendUpdateData = p.Parent.Functions.Save.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			local set = {}

			for k, v8 in pairs(v4) do
				set[#set + 1] = {
					Path = k,
					Value = v8
				}
			end

			local remove = {}

			for list, _ in pairs(v6) do
				local v9 = p2
				local v10 = table.remove(list, #list)

				for _, v11 in pairs(list) do
					v9 = v9[v11]
				end

				if Utils.Table.IsDictionary(v9) then
					table.insert(list, v10)
					set[#set + 1] = {
						Path = list
					}
				else
					remove[#remove + 1] = {
						Path = list,
						Value = v10
					}
				end
			end

			local insert = {}

			for k, v10 in pairs(v5) do
				if v10 and v10.Value ~= nil then
					insert[#insert + 1] = {
						Path = k,
						Value = v10.Value
					}
				end
			end

			SetLoading(true, "Applying Changes...")

			if Utils.Network:Invoke("AdminPanelChangeData", p3, {
				Set = set,
				Insert = insert,
				Remove = remove
			}) then
				SetLoading(true, "Changes applied successfully!")
			else
				SetLoading(true, "Failed to apply changes!")
				task.wait(1)

				if maid2.Loading then
					maid2:Destroy()
				end
			end

			flag = false
		end)
		maid3:GiveTask((deepAdd(p2)))
	end,
	SwordsNew = function(p, p2, p3, p4, p5)
		return createInventory(p, p2, p3, p4, p5, Swords:GetCollection())
	end,
	Swords = function(data, p, _, p2, p3)
		local names = {}
		local names2 = {}
		local flag = false
		maid3.SendUpdateData = data.Parent.Functions.Save.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			SetLoading(true, "Applying Changes...")
			local insert = {}
			local removeByValue = {}

			for _, v6 in pairs(names) do
				insert[#insert + 1] = {
					Path = { "SwordSkins", "Unlocked" },
					Value = v6
				}
			end

			for _, v6 in pairs(names2) do
				removeByValue[#removeByValue + 1] = {
					Path = { "SwordSkins", "Unlocked" },
					Value = v6
				}
			end

			if Utils.Network:Invoke("AdminPanelChangeData", p2, {
				Insert = insert,
				RemoveByValue = removeByValue
			}) then
				SetLoading(true, "Changes applied successfully!")
			else
				SetLoading(true, "Failed to apply changes!")
				task.wait(1)

				if maid2.Loading then
					maid2:Destroy()
				end
			end

			flag = false
		end)

		for _, v4 in Swords:GetCollection() do
			if not (not p3 or v4.Name:lower():find(p3)) then
				continue
			end

			local clone = data.TemplateItem:Clone()
			clone.Visible = true
			clone.Name = `{v[v4.Rarity] or 1}_{v4.Name}`
			clone.Title.Text = v4.Name
			local colorGradient = ColorsUtil:GetColorGradient(v4.Rarity .. "Gradient")
			colorGradient.Parent = clone.Title
			local icon = v4.Icon

			if icon then
				clone.IconLabel.Image = icon
				clone.ViewportFrame.Visible = false
			else
				clone.IconLabel.Visible = false
				Utils.Icons:SetSwordIconAsViewportByName(clone.ViewportFrame, v4.Name)
			end

			clone.LockIcon.Visible = table.find(NonGiveableItems.Sword, v4.Name)
			local key = FFlagClient:GetKey("SuperAdmins") or {}
			local index = table.find(key, localPlayer.UserId) or localPlayer:GetRankInGroup(12836673) >= 210
			local index2 = table.find(NonGiveableItems.Sword, v4.Name) or ServerInfo.isTestGame() or index and localPlayer.UserId ~= 119477844
			local v5 = table.find(p.SwordSkins.Unlocked, v4.Name) and true or false
			clone.Visible = true
			clone.Parent = v5 and data.Owned or data.Unowned
			maid3:GiveTask(clone)
			local flag2 = false
			local v8 = v4
			maid3:GiveTask(clone.Activated:Connect(function()
				if v5 then
					if flag2 then
						flag2 = false
						clone.RemovingFrame.Visible = false
						table.remove(names2, table.find(names2, v8.Name))
					else
						flag2 = true
						clone.RemovingFrame.Visible = true
						names2[#names2 + 1] = v8.Name
					end
				elseif flag2 or not index2 then
					flag2 = false
					clone.AddingFrame.Visible = false
					table.remove(names, table.find(names, v8.Name))
				else
					flag2 = true
					clone.AddingFrame.Visible = true
					names[#names + 1] = v8.Name
				end
			end))
		end
	end,
	Explosions = function(data, p, _, p2, p3)
		local names = {}
		local names2 = {}
		local flag = false
		maid3.SendUpdateData = data.Parent.Functions.Save.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			SetLoading(true, "Applying Changes...")
			local insert = {}
			local removeByValue = {}

			for _, v6 in pairs(names) do
				insert[#insert + 1] = {
					Path = { "ExplosionSkins", "Unlocked" },
					Value = v6
				}
			end

			for _, v6 in pairs(names2) do
				removeByValue[#removeByValue + 1] = {
					Path = { "ExplosionSkins", "Unlocked" },
					Value = v6
				}
			end

			if Utils.Network:Invoke("AdminPanelChangeData", p2, {
				Insert = insert,
				RemoveByValue = removeByValue
			}) then
				SetLoading(true, "Changes applied successfully!")
			else
				SetLoading(true, "Failed to apply changes!")
				task.wait(1)

				if maid2.Loading then
					maid2:Destroy()
				end
			end

			flag = false
		end)

		for _, child in pairs(ReplicatedStorage.Misc.DataExplosions:GetChildren()) do
			if not (not p3 or child.Name:lower():find(p3)) then
				continue
			end

			local clone = data.TemplateItem:Clone()
			clone.Visible = true
			local rarity = child:GetAttribute("Rarity") or "N/A"
			clone.Name = `{v[rarity] or 1}_{child.Name}`
			clone.Title.Text = child.Name
			local colorGradient = ColorsUtil:GetColorGradient((rarity or "") .. "Gradient")

			if colorGradient then
				colorGradient.Parent = clone.Title
			end

			clone.ItemIcon.Image = child:GetAttribute("Icon")
			local v4 = table.find(p.ExplosionSkins.Unlocked, child.Name) and true or false
			clone.Visible = true
			clone.Parent = v4 and data.Owned or data.Unowned
			maid3:GiveTask(clone)
			local flag2 = false
			local v7 = child
			maid3:GiveTask(clone.Activated:Connect(function()
				if v4 then
					if flag2 then
						flag2 = false
						clone.RemovingFrame.Visible = false
						table.remove(names2, table.find(names2, v7.Name))
					else
						flag2 = true
						clone.RemovingFrame.Visible = true
						names2[#names2 + 1] = v7.Name
					end
				elseif flag2 then
					flag2 = false
					clone.AddingFrame.Visible = false
					table.remove(names, table.find(names, v7.Name))
				else
					flag2 = true
					clone.AddingFrame.Visible = true
					names[#names + 1] = v7.Name
				end
			end))
		end
	end,
	Abilities = function(data, p, _, p2, p3)
		local names = {}
		local names2 = {}
		local namesByName = {}
		local flag = false
		maid3.SendUpdateData = data.Parent.Functions.Save.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			SetLoading(true, "Applying Changes...")
			local insert = {}
			local removeByValue = {}
			local set = {}

			for _, v7 in pairs(names) do
				insert[#insert + 1] = {
					Path = { "Abilities", "Unlocked" },
					Value = v7
				}
			end

			for _, v7 in pairs(names2) do
				removeByValue[#removeByValue + 1] = {
					Path = { "Abilities", "Unlocked" },
					Value = v7
				}
			end

			for k, v7 in pairs(namesByName) do
				set[#set + 1] = {
					Path = { "AbilityUpgrades", k },
					Value = v7
				}
			end

			if Utils.Network:Invoke("AdminPanelChangeData", p2, {
				Set = set,
				Insert = insert,
				RemoveByValue = removeByValue
			}) then
				SetLoading(true, "Changes applied successfully!")
			else
				SetLoading(true, "Failed to apply changes!")
				task.wait(1)

				if maid2.Loading then
					maid2:Destroy()
				end
			end

			flag = false
		end)

		for _, child in pairs(ReplicatedStorage.Misc.DataAbilities:GetChildren()) do
			if not (not p3 or child.Name:lower():find(p3)) then
				continue
			end

			local clone = data.TemplateItem:Clone()
			clone.Visible = true
			clone.Name = child.Name
			clone.Title.Text = child.Name
			clone.ItemIcon.Image = child:GetAttribute("Icon")
			local v4 = table.find(p.Abilities.Unlocked, child.Name) and true or false
			clone.Visible = true
			clone.Parent = v4 and data.Owned or data.Unowned
			maid3:GiveTask(clone)
			local nonUpgradable = not child:GetAttribute("MaxUpgrade") and child:GetAttribute("NonUpgradable")
			local v5 = math.min(child:GetAttribute("MaxUpgrade") or 2, 2)

			if v4 and not nonUpgradable then
				local name = p.AbilityUpgrades[child.Name] or 0
				clone.UpgradeLevel.CurrentButton.Text = "Level " .. name

				for _, guiObject in pairs(clone.UpgradeLevel.Areas:GetChildren()) do
					if not guiObject:IsA("GuiObject") then
						continue
					end

					guiObject.Visible = tonumber(guiObject.Name) <= v5
					local v6 = guiObject
					local v7 = clone
					local v8 = child
					maid3:GiveTask(guiObject.Activated:Connect(function()
						name = tonumber(v6.Name)
						v7.UpgradeLevel.CurrentButton.Text = "Level " .. name
						namesByName[v8.Name] = name
						v7.UpgradeLevel.ClipsDescendants = true
					end))
				end

				local v6 = clone
				clone.UpgradeLevel.CurrentButton.Activated:Connect(function()
					v6.UpgradeLevel.ClipsDescendants = not v6.UpgradeLevel.ClipsDescendants
				end)
			else
				clone.UpgradeLevel.Visible = false
				clone.UpgradeLabel.Visible = false
			end

			clone.Delete.Text = v4 and "X" or "+"
			local flag2 = false
			local v8 = child
			maid3:GiveTask(clone.Delete.Activated:Connect(function()
				if v4 then
					if flag2 then
						flag2 = false
						clone.RemovingFrame.Visible = false
						table.remove(names2, table.find(names2, v8.Name))
					else
						flag2 = true
						clone.RemovingFrame.Visible = true
						names2[#names2 + 1] = v8.Name
					end
				elseif flag2 then
					flag2 = false
					clone.AddingFrame.Visible = false
					table.remove(names, table.find(names, v8.Name))
				else
					flag2 = true
					clone.AddingFrame.Visible = true
					names[#names + 1] = v8.Name
				end
			end))
		end
	end,
	Emotes = function(data, p, _, p2, p3)
		local names = {}
		local names2 = {}
		local flag = false
		maid3.SendUpdateData = data.Parent.Functions.Save.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			SetLoading(true, "Applying Changes...")
			local set = {}

			for _, v5 in pairs(names) do
				set[#set + 1] = {
					Path = { "Emotes", "Unlocked", v5 },
					Value = true
				}
			end

			for _, v5 in pairs(names2) do
				set[#set + 1] = {
					Path = { "Emotes", "Unlocked", v5 }
				}
			end

			if Utils.Network:Invoke("AdminPanelChangeData", p2, {
				Set = set
			}) then
				SetLoading(true, "Changes applied successfully!")
			else
				SetLoading(true, "Failed to apply changes!")
				task.wait(1)

				if maid2.Loading then
					maid2:Destroy()
				end
			end

			flag = false
		end)

		for _, child in pairs(emotes:GetChildren()) do
			if not (not p3 or child.Name:lower():find(p3) or child:GetAttribute("EmoteName"):lower():find(p3)) then
				continue
			end

			local clone = data.TemplateItem:Clone()
			clone.Visible = true
			local mappedId = Emotes.MappedIds[child.Name]
			local rarity = mappedId and mappedId.Rarity or child:GetAttribute("IsDuo") and "Duo" or "N/A"
			clone.Name = `{v[rarity] or 1}_{child:GetAttribute("EmoteName") or child.Name}`
			clone.Title.Text = child:GetAttribute("EmoteName") or "N/A"
			local colorGradient = ColorsUtil:GetColorGradient((({
				Common = "Unique",
				Duo = "Limited"
			})[rarity] or rarity) .. "Gradient")

			if colorGradient then
				colorGradient.Parent = clone.Title
			end

			clone.ItemIcon.Image = child:GetAttribute("Icon") or "rbxassetid://0"
			local v4 = p.Emotes.Unlocked[child.Name] and true or false
			local index = child and table.find(NonGiveableItems.Emote, child.Name)
			clone.LockIcon.Visible = index
			clone.Visible = true
			clone.Parent = v4 and data.Owned or data.Unowned
			local key = FFlagClient:GetKey("SuperAdmins") or {}
			local index2 = table.find(key, localPlayer.UserId) or localPlayer:GetRankInGroup(12836673) >= 210
			local v5 = not index or ServerInfo.isTestGame() or index2 and localPlayer.UserId ~= 119477844
			maid3:GiveTask(clone)
			local flag2 = false
			local v8 = child
			maid3:GiveTask(clone.Activated:Connect(function()
				if v4 then
					if flag2 then
						flag2 = false
						clone.RemovingFrame.Visible = false
						table.remove(names2, table.find(names2, v8.Name))
					else
						flag2 = true
						clone.RemovingFrame.Visible = true
						names2[#names2 + 1] = v8.Name
					end
				elseif flag2 or not v5 then
					flag2 = false
					clone.AddingFrame.Visible = false
					table.remove(names, table.find(names, v8.Name))
				else
					flag2 = true
					clone.AddingFrame.Visible = true
					names[#names + 1] = v8.Name
				end
			end))
		end
	end,
	PurchaseHistory = function(parent2, p, _, _)
		local copy = Utils.Table.Copy(p.RobuxPurchases)
		table.sort(copy, function(a, b)
			return a.Time > b.Time
		end)
		local v4 = 1e999
		local parent3 = nil
		local count = 0
		local v6 = {
			{
				tag = "%dh ago",
				value = 3600
			},
			{
				tag = "%dd ago",
				value = 86400
			},
			{
				tag = "%dw ago",
				value = 604800
			},
			{
				tag = "%dm ago",
				value = 2592000
			}
		}

		local function createHistorySection(time)
			local tag = "Now (Current Time: " .. os.date("%X", os.time()) .. ")"
			local v7 = os.time() - time
			local value = 3600

			for _, v8 in pairs(v6) do
				if not (v8.value < v7) then
					continue
				end

				tag = v8.tag
				value = v8.value
			end

			if value < v4 - time then
				v4 = time
				count += 1
				local clone = parent2.History:Clone()
				clone.Visible = true
				clone.Name = os.date("%x", v4)
				clone.LayoutOrder = count + 1
				clone.Visible = true
				clone.Parent = parent2
				local clone2 = parent2.Title:Clone()
				clone2.Text = tag:format((math.floor(v7 / value)))
				clone2.Name = "ReceiptTitle"
				clone2.LayoutOrder = count
				clone2.Visible = true
				clone2.Parent = parent2
				parent3 = clone
				maid3:GiveTask(clone)
				maid3:GiveTask(clone2)
			end
		end

		for k, v7 in pairs(copy) do
			createHistorySection(v7.Time)
			local clone = parent2.TemplateReceipt:Clone()
			clone.Visible = true
			clone.Name = v7.ReceiptId or "GamePass"
			clone.Title.Text = "Loading " .. (v7.Type or "")
			clone.ProductId.Text = "[" .. (v7.ProductId or "") .. "]"
			clone.ReceiptId.Text = v7.ReceiptId or "[Game Pass]"
			clone.DateLabel.Text = os.date("%b %d %Y at %X", v7.Time)
			clone.Price.AmountText.Text = v7.Price or "N/A"
			clone.Visible = true
			clone.LayoutOrder = k
			local granted = v7.Granted or v7.Tokens
			clone.Attempts.Text = (granted and "Granted" or v7.Price and "Pending" or "Granted?") .. (not v7.Attempts and "" or "[" .. v7.Attempts .. "]" or "")
			clone.Attempts.TextColor3 = granted and Color3.new(0, 1, 0) or v7.Price and Color3.new(1, 0, 0) or Color3.new(
				1,
				1,
				0
			)
			clone.Parent = parent3
			maid3:GiveTask(clone)
			local connection = nil
			local v8 = v7
			connection = Utils.Thread.Loop(function()
				local success, result = pcall(function()
					if v8.Type == "DevProduct" then
						return MarketplaceService:GetProductInfo(v8.ProductId, Enum.InfoType.Product)
					end

					if v8.Type == "Gamepass" then
						return MarketplaceService:GetProductInfo(v8.ProductId, Enum.InfoType.GamePass)
					end

					return MarketplaceService:GetProductInfo(v8.ProductId, v8.Type)
				end)

				if not success then
					task.wait(2)
					return
				end

				connection:Disconnect()

				if not clone.Parent then
					return
				end

				if v8.Tokens then
					clone.Price.Icon.Image = Utils.Icons:GetIcon("Tokens")
					clone.Price.Icon.Size = UDim2.fromScale(0.35, 1.25)
					clone.ReceiptId.Text = "Token Purchase"
				end

				local price = v8.Price or result.PriceInRobux
				local v10 = v8.Price ~= nil
				clone.Price.AmountText.Text = not price and "" or `{Utils.ValueConvertor:AddCommas(price)}{v10 and "" or "?"}` or ""
				clone.ItemIcon.Image = "rbxassetid://" .. result.IconImageAssetId
				clone.Title.Text = result.Name
			end)
			maid3:GiveTask(connection)
		end
	end,
	SwordCount = function(data, _, _, _, value)
		for _, button in pairs(data.Tracked:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		local v4 = getExistCounter("Sword") or {}

		if #v4 > 0 then
			local v5 = {}

			for k, v6 in pairs(v4) do
				v5[k] = v6
			end

			table.sort(v5, function(a, b)
				return a.Count > b.Count
			end)

			for _, v6 in pairs(v5) do
				local v7

				if value then
					v7 = value:lower() or nil
				end

				if not (not v7 or v6.Name:lower():find(v7)) then
					continue
				end

				local sword = Swords:GetSword(v6.Name)
				local name = v6.Name
				local count = v6.Count
				local clone = data.TemplateItem:Clone()
				clone.Visible = true
				clone.Name = name
				clone.Title.Text = name
				clone.LockIcon.Visible = sword and table.find(NonGiveableItems.Sword, sword.Name)
				clone.Existing.Text = `{Utils.ValueConvertor:AddCommas(count)} Exist`
				clone.ItemIcon.Image = Utils.Icons:GetSwordIcon(name) or "rbxassetid://6034407076"
				clone.Parent = data.Tracked
			end
		end

		data.OwnedTitle.Text = "TRACKED SWORDS - FULLY LOADED"
	end,
	ExplosionCount = function(data, _, _, _, value)
		for _, button in pairs(data.Tracked:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		local v4 = getExistCounter("Explosion") or {}

		if #v4 > 0 then
			local v5 = {}

			for k, v6 in pairs(v4) do
				v5[k] = v6
			end

			table.sort(v5, function(a, b)
				return a.Count > b.Count
			end)

			for _, v6 in pairs(v5) do
				local v7

				if value then
					v7 = value:lower() or nil
				end

				if not (not v7 or v6.Name:lower():find(v7)) then
					continue
				end

				local name = v6.Name
				local count = v6.Count
				local clone = data.TemplateItem:Clone()
				clone.Visible = true
				clone.Name = name
				clone.Title.Text = name
				clone.Existing.Text = `{Utils.ValueConvertor:AddCommas(count)} Exist`
				clone.ItemIcon.Image = Utils.Icons:GetExplosionIcon(name) or "rbxassetid://6034407076"
				clone.Parent = data.Tracked
			end
		end

		data.OwnedTitle.Text = "TRACKED EXPLOSIONS - FULLY LOADED"
	end,
	AbilityCount = function(data, _, _, _, value)
		for _, button in pairs(data.Tracked:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		local v4 = getExistCounter("Ability") or {}

		if #v4 > 0 then
			local v5 = {}

			for k, v6 in pairs(v4) do
				v5[k] = v6
			end

			table.sort(v5, function(a, b)
				return a.Count > b.Count
			end)

			for _, v6 in pairs(v5) do
				local v7

				if value then
					v7 = value:lower() or nil
				end

				if not (not v7 or v6.Name:lower():find(v7)) then
					continue
				end

				local name = v6.Name
				local count = v6.Count
				local clone = data.TemplateItem:Clone()
				clone.Visible = true
				clone.Name = name
				clone.Title.Text = name
				clone.Existing.Text = `{Utils.ValueConvertor:AddCommas(count)} Exist`
				clone.ItemIcon.Image = Utils.Icons:GetAbilityIcon(name) or "rbxassetid://14993692520"
				clone.Parent = data.Tracked
			end
		end

		data.OwnedTitle.Text = "TRACKED ABILITIES - FULLY LOADED"
	end,
	FinisherCount = function(data, _, _, _, value)
		for _, button in pairs(data.Tracked:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		local v4 = getExistCounter("Finisher") or {}

		if #v4 > 0 then
			local v5 = {}

			for k, v6 in pairs(v4) do
				v5[k] = v6
			end

			table.sort(v5, function(a, b)
				return a.Count > b.Count
			end)

			for _, v6 in pairs(v5) do
				local v7

				if value then
					v7 = value:lower() or nil
				end

				if not (not v7 or v6.Name:lower():find(v7)) then
					continue
				end

				local name = v6.Name
				local count = v6.Count
				local clone = data.TemplateItem:Clone()
				clone.Visible = true
				clone.Name = name
				clone.Title.Text = name
				clone.Existing.Text = `{Utils.ValueConvertor:AddCommas(count)} Exist`
				clone.ItemIcon.Image = Utils.Icons:GetFinisherIcon(name) or "rbxassetid://14993692520"
				clone.Parent = data.Tracked
			end
		end

		data.OwnedTitle.Text = "TRACKED FINISHERS - FULLY LOADED"
	end,
	SwordAccessoryCount = function(data, _, _, _, value)
		for _, button in pairs(data.Tracked:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		local v4 = getExistCounter("SwordAccessory") or {}

		if #v4 > 0 then
			local v5 = {}

			for k, v6 in pairs(v4) do
				v5[k] = v6
			end

			table.sort(v5, function(a, b)
				return a.Count > b.Count
			end)

			for _, v6 in pairs(v5) do
				local v7

				if value then
					v7 = value:lower() or nil
				end

				if not (not v7 or v6.Name:lower():find(v7)) then
					continue
				end

				local name = v6.Name
				local count = v6.Count
				local clone = data.TemplateItem:Clone()
				clone.Visible = true
				clone.Name = name
				clone.Title.Text = name
				clone.Existing.Text = `{Utils.ValueConvertor:AddCommas(count)} Exist`
				clone.ItemIcon.Image = Utils.Icons:GetSwordAccessoryIcon(name) or "rbxassetid://14993692520"
				clone.Parent = data.Tracked
			end
		end

		data.OwnedTitle.Text = "TRACKED SWORD ACCESSORIES - FULLY LOADED"
	end,
	EmoteCount = function(data, _, _, _, value)
		for _, button in pairs(data.Tracked:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		local v4 = getExistCounter("Emote") or {}

		if #v4 > 0 then
			local v5 = {}

			for k, v6 in pairs(v4) do
				v5[k] = v6
			end

			table.sort(v5, function(a, b)
				return a.Count > b.Count
			end)

			for _, v6 in pairs(v5) do
				local v7

				if value then
					v7 = value:lower() or nil
				end

				if not (not v7 or v6.Name:lower():find(v7)) then
					continue
				end

				local name = v6.Name
				local child = emotes:FindFirstChild(name)

				if child then
					name = child:GetAttribute("EmoteName") or name
				end

				local count = v6.Count
				local clone = data.TemplateItem:Clone()
				clone.Visible = true
				clone.Name = name
				clone.LockIcon.Visible = child and table.find(NonGiveableItems.Emote, child.Name)
				clone.Title.Text = name
				clone.Existing.Text = `{Utils.ValueConvertor:AddCommas(count)} Exist`
				clone.ItemIcon.Image = Utils.Icons:GetEmoteIcon(v6.Name) or "rbxassetid://6034407076"
				clone.Parent = data.Tracked
			end
		end

		data.OwnedTitle.Text = "TRACKED EMOTES - FULLY LOADED"
	end,
	GiftHistory = function(parent2, p, _, _)
		local v4 = {}

		for k, v5 in pairs({
			Received = Utils.Table.Copy(p.GiftHistory.Received),
			Sent = Utils.Table.Copy(p.GiftHistory.Sent)
		}) do
			for _, v6 in pairs(v5) do
				v6.Type = k
				v4[#v4 + 1] = v6
			end
		end

		table.sort(v4, function(a, b)
			return a.Time > b.Time
		end)
		local v5 = 1e999
		local parent3 = nil
		local count = 0
		local v7 = {
			{
				tag = "%dh ago",
				value = 3600
			},
			{
				tag = "%dd ago",
				value = 86400
			},
			{
				tag = "%dw ago",
				value = 604800
			},
			{
				tag = "%dm ago",
				value = 2592000
			}
		}

		local function createHistorySection(time)
			local tag = "Now (Current Time: " .. os.date("%X", os.time()) .. ")"
			local v8 = os.time() - time
			local value = 3600

			for _, v9 in pairs(v7) do
				if not (v9.value < v8) then
					continue
				end

				tag = v9.tag
				value = v9.value
			end

			if value < v5 - time then
				v5 = time
				count += 1
				local clone = parent2.History:Clone()
				clone.Visible = true
				clone.Name = os.date("%x", v5)
				clone.LayoutOrder = count + 1
				clone.Visible = true
				clone.Parent = parent2
				local clone2 = parent2.Title:Clone()
				clone2.Text = tag:format((math.floor(v8 / value)))
				clone2.Name = "ReceiptTitle"
				clone2.LayoutOrder = count
				clone2.Visible = true
				clone2.Parent = parent2
				parent3 = clone
				maid3:GiveTask(clone)
				maid3:GiveTask(clone2)
			end
		end

		for k, v8 in pairs(v4) do
			createHistorySection(v8.Time)
			local clone = parent2.TemplateReceipt:Clone()
			clone.Visible = true
			clone.Name = v8.Time or ""
			clone.Title.Text = "Loading"
			clone.ProductId.Text = "[" .. v8.ProductId .. "]"
			clone.Source.Text = v8.Type == "Received" and "From: " .. v8.Sender or "To: " .. v8.Receiver
			clone.BackgroundColor3 = v8.Type == "Received" and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(
				226,
				50,
				34
			)
			clone.DateLabel.Text = os.date("%b %d %Y at %X", v8.Time)
			clone.Price.AmountText.Text = v8.Price or "N/A"
			clone.Visible = true
			clone.LayoutOrder = k
			clone.Parent = parent3
			local v9 = v8
			maid3:GiveTask(clone.ViewProfile.Activated:Connect(function()
				Utils.Network:Invoke("AdminPanelSearch", v9.Type == "Received" and v9.Sender or v9.Receiver)
			end))
			maid3:GiveTask(clone)
			local connection = nil
			local v10 = v8
			connection = Utils.Thread.Loop(function()
				if v10.FromInventory then
					connection:Disconnect()
					clone.Title.Text = "From Inventory"
				else
					local success, result = pcall(function()
						return MarketplaceService:GetProductInfo(v10.ProductId, Enum.InfoType.Product)
					end)

					if not success then
						task.wait(2)
						return
					end

					connection:Disconnect()

					if not clone.Parent then
						return
					end

					clone.Price.AmountText.Text = v10.Price or result.PriceInRobux .. "?"
					clone.ItemIcon.Image = "rbxassetid://" .. result.IconImageAssetId
					clone.Title.Text = result.Name
				end
			end)
			local connection2 = nil
			local v12 = v8
			local v13 = clone
			connection2 = Utils.Thread.Loop(function()
				local success, result = pcall(function()
					if v12.Type == "Received" then
						return PlayerUtility:GetUsername(v12.Sender):expect()
					end

					return PlayerUtility:GetUsername(v12.Receiver):expect()
				end)

				if not success then
					task.wait(2)
					return
				end

				connection2:Disconnect()
				v13.Source.Text = v12.Type == "Received" and "From: " .. result or "To: " .. result
			end)
			maid3:GiveTask(connection2)
			maid3:GiveTask(connection)
		end
	end,
	GiftLedger = function(parent2, p, _, _)
		local copy = Utils.Table.Copy(p.GiftLedger)
		local v4 = 1e999
		local parent3 = nil
		local count = 0
		local v6 = {
			{
				tag = "%dh ago",
				value = 3600
			},
			{
				tag = "%dd ago",
				value = 86400
			},
			{
				tag = "%dw ago",
				value = 604800
			},
			{
				tag = "%dm ago",
				value = 2592000
			}
		}

		local function createHistorySection(timeSent)
			local tag = "Now (Current Time: " .. os.date("%X", os.time()) .. ")"
			local v7 = os.time() - timeSent
			local value = 3600

			for _, v8 in pairs(v6) do
				if not (v8.value < v7) then
					continue
				end

				tag = v8.tag
				value = v8.value
			end

			if value < v4 - timeSent then
				v4 = timeSent
				count += 1
				local clone = parent2.History:Clone()
				clone.Visible = true
				clone.Name = os.date("%x", v4)
				clone.LayoutOrder = count + 1
				clone.Visible = true
				clone.Parent = parent2
				local clone2 = parent2.Title:Clone()
				clone2.Text = tag:format((math.floor(v7 / value)))
				clone2.Name = "ReceiptTitle"
				clone2.LayoutOrder = count
				clone2.Visible = true
				clone2.Parent = parent2
				parent3 = clone
				maid3:GiveTask(clone)
				maid3:GiveTask(clone2)
			end
		end

		local function stringToColor3(value)
			local v7 = 0

			for i = 1, #value do
				v7 = (v7 + string.byte(value, i)) % 255
			end

			local v8 = v7 % 31 / 31
			local v9 = v7 // 31 % 31 / 31
			local v10 = v7 // 961 % 31 / 31
			local v11 = (v8 + 0.25) / 1.5
			local v12 = (v9 + 0.25) / 1.5
			local v13 = (v10 + 0.25) / 1.5
			return Color3.new(v11, v12, v13)
		end

		local v7 = {
			"Status: <font color=\"rgb(0,255,0)\">Successfully Sent</font>",
			"Status: <font color=\"rgb(255,0,0)\">Failed</font>",
			"Status: <font color=\"rgb(255,125,0)\">Pending</font>",
			"Status: <font color=\"rgb(255, 105, 180)\">Unknown</font>"
		}

		for k, v8 in copy do
			createHistorySection(v8.TimeSent)
			local v9 = nil

			for k2, v11 in {
				Sent = 1,
				["Returned To Inventory"] = 2,
				Returned = 3,
				["Sent From Inventory"] = 5
			} do
				if v8.Type ~= v11 then
					continue
				end

				v9 = k2
				break
			end

			local _ = v8.Type == 2
			local clone = parent2.TemplateReceipt:Clone()
			clone.Visible = true
			clone.Name = v8.TimeSent or ""
			clone.Title.Text = "Loading"
			local v11 = v8.ReceiptUUID and "R-" .. v8.ReceiptUUID or "G-" .. v8._uuid
			clone.UUID.Text = "UUID: " .. v11
			local source = clone.Source
			local text

			if v8.Type == 1 then
				text = "Sent To: " .. v8.Receiver
			else
				text = v8.Type == 2 and "Returned to Inventory" or v8.Type == 3 and "Sent From Inventory To: " or "N/A"
			end

			source.Text = text
			local v13 = os.date("%b %d %Y at %X", v8.TimeSent)
			clone.DateLabel.Text = string.format("%s On: %s", v9, v13)
			local backgroundColor

			if v8.Type == 5 then
				backgroundColor = Color3.fromRGB(50, 50, 50)
			else
				backgroundColor = stringToColor3(string.sub(v8.ReceiptUUID or v8._uuid, 1, 5))
			end

			clone.BackgroundColor3 = backgroundColor
			clone.Price.AmountText.Text = v8.Price or "N/A"
			clone.Status.Text = v8.Status and v7[v8.Status] or v7[4]
			clone.Info.Visible = v8.ErrorStr and true or false
			clone.Info.Text = "Info: " .. (v8.ErrorStr or "N/A")
			clone.Visible = true
			clone.LayoutOrder = #copy - k
			clone.Parent = parent3
			maid3:GiveTask(clone)
			local connection = nil
			local v15 = v8
			connection = Utils.Thread.Loop(function()
				local success, result = pcall(function()
					return MarketplaceService:GetProductInfo(v15.ProductId, Enum.InfoType.Product)
				end)

				if not success then
					task.wait(2)
					return
				end

				connection:Disconnect()
				clone.Price.AmountText.Text = v15.Price or result.PriceInRobux .. "?"
				clone.ItemIcon.Image = "rbxassetid://" .. result.IconImageAssetId
				clone.Title.Text = result.Name .. " [" .. v15.ProductId .. "]"
			end)
			local connection2 = nil
			local v17 = v8
			local v18 = clone
			connection2 = Utils.Thread.Loop(function()
				local success, result = pcall(function()
					if v17.Type == 1 then
					end

					return PlayerUtility:GetUsername(v17.Receiver):expect()
				end)

				if not success then
					task.wait(2)
					return
				end

				connection2:Disconnect()
				local source2 = v18.Source
				local text2

				if v17.Type == 1 then
					text2 = "Sent To: " .. result
				else
					text2 = v17.Type == 2 and "Returned to Inventory" or v17.Type ~= 5 and "N/A" or "Sent From Inventory To: " .. result
				end

				source2.Text = text2
			end)
			maid3:GiveTask(connection2)
			maid3:GiveTask(connection)
		end
	end
}
local fn

fn = function(childName: string, p, p2, p3)
	maid3:Destroy()
	maid.ResultSearchingText = window.Content.Windows.Functions.SearchBar.Box:GetPropertyChangedSignal("Text"):Connect(function()
		maid.SubmitSearch = Utils.Thread.Delay(0.5, function()
			fn(childName, p, p2, p3)
		end)
	end)
	maid.ResultSearching = window.Content.Windows.Functions.SearchBar.Enter.Activated:Connect(function()
		fn(childName, p, p2, p3)
	end)

	for _, button in pairs(window.Board:GetChildren()) do
		if button:IsA("ImageButton") then
			button.BackgroundTransparency = childName == button.Name and 0 or 1
		end
	end

	local child = window.Content.Windows:FindFirstChild(childName)

	if not child then
		return
	end

	local key = FFlagClient:GetKey("DevUserIds") or {}
	local _ = table.find(key, localPlayer.UserId) or false

	if childName == "Data" then
		local key2 = FFlagClient:GetKey("SuperAdmins") or {}
		local index = table.find(key2, localPlayer.UserId) or localPlayer:GetRankInGroup(12836673) >= 210
		window.Content.Windows.Functions.Save.Visible = index or p3 == localPlayer.UserId
		window.Content.Windows.Functions.SaveLabel.Visible = window.Content.Windows.Functions.Save.Visible
	else
		window.Content.Windows.Functions.Save.Visible = true
		window.Content.Windows.Functions.SaveLabel.Visible = window.Content.Windows.Functions.Save.Visible
	end

	local locked = window.Content.Windows.Locked
	locked.Visible = childName == "GiftLedger" and localPlayer.UserId ~= 52589925
	local v5 = v3[childName]

	if not v5 then
		return
	end

	v5(
		child,
		p,
		p2,
		p3,
		window.Content.Windows.Functions.SearchBar.Box.Text:len() > 0 and window.Content.Windows.Functions.SearchBar.Box.Text:lower() or nil
	)
	child.Visible = true
	maid3:GiveTask(function()
		child.Visible = false
	end)
end

local function LoadBanData(p, p2)
	local banned = p and p.Banned

	for _, button in pairs(banReason.PreFixes:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local v4 = button
		maid:GiveTask(button.Activated:Connect(function()
			banReason.ReasonBox.Box.Text = v4.Label.Text
		end))
	end

	local active = banned and banned.Active

	if active then
		if banned.Active == true then
			active = true
		elseif typeof(banned.Active) == "number" then
			active = banned.Active > os.time()
		else
			active = false
		end
	end

	if banned then
		local _ = banned.Reason
	end

	if active then
		banDuration.Visible = false
		banButton.Button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
		banButton.Button.Label.Text = "Unban"
		maid.PromptBan = banButton.Button.Activated:Connect(function()
			SetLoading(true, "Unban player...")

			if not Utils.Network:Invoke("AdminPanelUnban", p2, banReason.ReasonBox.Box.Text) then
				if not maid2.Loading then
					return
				end

				maid2:Destroy()
			end
		end)
	else
		banDuration.Visible = true

		for _, button in pairs(banDuration.PreFixes:GetChildren()) do
			if not button:IsA("ImageButton") then
				continue
			end

			local v4 = button
			maid:GiveTask(button.Activated:Connect(function()
				banDuration.DurationBox.Box.Text = v4.Name
			end))
		end

		banButton.Button.BackgroundColor3 = Color3.fromRGB(226, 50, 34)
		banButton.Button.Label.Text = "Ban"
		maid.PromptBan = banButton.Button.Activated:Connect(function()
			SetLoading(true, "Banning player...")

			if not Utils.Network:Invoke(
				"AdminPanelBan",
				p2,
				banReason.ReasonBox.Box.Text,
				(tonumber(banDuration.DurationBox.Box.Text))
			) then
				if not maid2.Loading then
					return
				end

				maid2:Destroy()
			end
		end)
	end
end

FFlagClient.DataUpdatedEvent:Connect(function()
	if not FFlagClient:GetKey("AdminPanelEnabled") then
		parent.Enabled = false
		maid:Destroy()
		maid2:Destroy()
		maid3:Destroy()
	end
end)
task.spawn(function()
	if localPlayer:GetRankInGroup(12836673) < 210 then
		for _, child in pairs(window.Board:GetChildren()) do
			if string.find(child.Name, "Count") or child.Name == "GiftLedger" then
				child:Destroy()
			end
		end
	end
end)

local function SearchUser(p, p2, p3, value)
	if not (FFlagClient:IsDataReady() and FFlagClient:GetKey("AdminPanelEnabled")) then
		return
	end

	maid:Destroy()
	local lastTime = os.time()
	maid.UpdateLastUpdated = Utils.Thread.Every(1, function()
		local v4 = os.time() - lastTime
		window.Content.LastUpdated.Text = "Last updated: " .. Utils.ValueConvertor:FormatTime(v4)
	end)
	maid:GiveTask(function()
		window.Content.LastUpdated.Text = "Last updated: Not loaded"
	end)
	local jSONEncode = HttpService:JSONEncode(p2)
	local dataSize = GetDataSize(#jSONEncode)
	local v5 = 4194304
	local v6 = 1

	while v5 > 1024 do
		v5 /= 1024
		v6 += 1
	end

	local text = "Data: " .. dataSize .. "/" .. (math.floor(v5 * 100) / 100 .. ({ "B", "KB", "MB" })[v6]) .. "(" .. math.floor(#jSONEncode / 4194304 * 10000) / 100 .. "%)"

	if p3 then
		local jSONEncode2 = HttpService:JSONEncode(p3)
		local v11 = text .. "\n"
		local dataSize2 = GetDataSize(#jSONEncode2)
		local v13 = 4194304
		local v14 = 1

		while v13 > 1024 do
			v13 /= 1024
			v14 += 1
		end

		text = v11 .. "Inventory: " .. dataSize2 .. "/" .. (math.floor(v13 * 100) / 100 .. ({ "B", "KB", "MB" })[v14]) .. "(" .. math.floor(#jSONEncode2 / 4194304 * 10000) / 100 .. "%)"
	end

	window.Content.DataSize.Text = text
	SetLoading(true, "Loading...")
	parent.Enabled = true
	maid.LookingForData = true
	window.Board.Info.Content.UserID.Text = "[" .. p .. "]"
	maid.LookingForData = Utils.Thread.Loop(function()
		local v11, v12 = PlayerUtility:GetUser(p):await()

		if not maid.LookingForData then
			return
		end

		if not v11 then
			task.wait(1)
			return
		end

		maid.LookingForData = nil
		local headShot = Enum.ThumbnailType.HeadShot
		local size420x420 = Enum.ThumbnailSize.Size420x420
		maid.UpdateProfileImage = Utils.Thread.Every(2, function()
			local userThumbnailAsync, v13 = Players:GetUserThumbnailAsync(p, headShot, size420x420)

			if v13 then
				window.Board.Info.Profile.Image = userThumbnailAsync
				maid.UpdateProfileImage = nil
			end
		end)

		if v12 and v12.Username == v12.DisplayName then
			window.Board.Info.Content.DisplayName.Visible = false
		else
			window.Board.Info.Content.DisplayName.Visible = true
			window.Board.Info.Content.DisplayName.Text = `[{not v12 and "???" or v12.DisplayName or "???"}]`
		end

		window.Board.Info.Content.Username.Text = v12 and v12.Username or "???"
	end)

	for _, button in pairs(window.Board:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local v11 = button
		maid:GiveTask(button.Activated:Connect(function()
			maid.ResultSearchingText = nil
			window.Content.Windows.Functions.SearchBar.Box.Text = ""
			fn(v11.Name, p2, p3, p)
		end))
	end

	maid.RefreshUser = window.Content.Refresh.Activated:Connect(function()
		SetLoading(true, "Refreshing...")
		Utils.Network:Invoke("AdminPanelSearch", p)
	end)
	maid.PageMaid = maid3
	fn(value or "Data", p2, p3, p)
	maid.UpdateTeleportStatus = Utils.Thread.Every(30, function()
		local v11 = game.Players:GetPlayerByUserId(p) ~= nil

		if (v11 or Utils.Network:Invoke("AdminPanelIsInGame", p)) and not v11 then
			window.Board.OnlineStatus.Text = "Online\nIn another server"
			maid.TeleportPrompt = window.Board.Info.Join.Activated:Connect(function()
				Utils.Network:Fire("AdminPanelTeleport", p)
			end)
		else
			if v11 then
				window.Board.OnlineStatus.Text = "Online\nIn this server"
			else
				window.Board.OnlineStatus.Text = "Last Played\n" .. Utils.ValueConvertor:FormatTimeWithDays(os.time() - p2.LastSession)
			end

			window.Board.Info.Join.Visible = false
			maid.TeleportPrompt = nil
		end
	end)
	local flag = false
	maid.SearchClick = window.Board.SearchBar.Enter.Activated:Connect(function()
		local v11 = window.Board.SearchBar.Box.Text:gsub("%s+", "")

		if v11:len() == 0 or flag then
			return
		end

		flag = true
		SetLoading(true, "Searching for UserId " .. v11 .. "...")
		local v12, v13 = Utils.Network:Invoke("AdminPanelSearch", v11)

		if not v12 then
			SetLoading(true, v13)
			task.wait(2)
			flag = false

			if not maid2.Loading then
				return
			end

			maid2:Destroy()
		end
	end)
	maid.Search = window.Board.SearchBar.Box.FocusLost:Connect(function(p4)
		if p4 then
			local v11 = window.Board.SearchBar.Box.Text:gsub("%s+", "")

			if v11:len() == 0 or flag then
				return
			end

			flag = true
			SetLoading(true, "Searching for UserId " .. v11 .. "...")
			local v12, v13 = Utils.Network:Invoke("AdminPanelSearch", v11)

			if not v12 then
				SetLoading(true, v13)
				task.wait(2)
				flag = false

				if not maid2.Loading then
					return
				end

				maid2:Destroy()
			end
		end
	end)
	LoadBanData(p2, p)

	if maid2.Loading then
		maid2:Destroy()
	end
end

local v4 = {}
local v5 = true
local visible = nil

local function updateCoreGui()
	local v7 = not (visible and parent.Enabled)

	if v7 and not v5 then
		for _, v8 in v4 do
			StarterGui:SetCoreGuiEnabled(v8, true)
		end

		table.clear(v4)
		v5 = true
	elseif not v7 and v5 then
		for _, v8 in Enum.CoreGuiType:GetEnumItems() do
			if StarterGui:GetCoreGuiEnabled(v8) then
				table.insert(v4, v8)
			end
		end

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		v5 = false
	end
end

local cornerRadius = window.UICorner.CornerRadius
local size = window.Size
local uIAspectRatioConstraint = window.UIAspectRatioConstraint

local function updateWindowMode()
	visible = workspace.CurrentCamera.ViewportSize.X < 800 or (workspace.CurrentCamera.ViewportSize.Y < 500 or parent:GetAttribute("Fullscreen"))
	local uICorner = window.UICorner
	local cornerRadius2

	if visible then
		cornerRadius2 = UDim.new()
	else
		cornerRadius2 = cornerRadius
	end

	uICorner.CornerRadius = cornerRadius2
	local v8 = window
	local size2

	if visible then
		size2 = UDim2.fromScale(1, 1)
	else
		size2 = size
	end

	v8.Size = size2
	local uIAspectRatioConstraint2 = uIAspectRatioConstraint
	local parent2

	if not visible then
		parent2 = window
	end

	uIAspectRatioConstraint2.Parent = parent2
	parent.ClipToDeviceSafeArea = not visible
	local parent3 = parent
	local safeAreaCompatibility

	if visible then
		safeAreaCompatibility = Enum.SafeAreaCompatibility.None
	else
		safeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	end

	parent3.SafeAreaCompatibility = safeAreaCompatibility
	parent.Background.Visible = visible
	window.Move.Visible = not visible
	parent.Close.Visible = visible

	if parent.Enabled then
		updateCoreGui()
	end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowMode)
parent:GetAttributeChangedSignal("Fullscreen"):Connect(updateWindowMode)
parent:GetPropertyChangedSignal("Enabled"):Connect(updateCoreGui)
task.spawn(updateWindowMode)

local function close()
	parent.Enabled = false
	maid:Destroy()
	maid2:Destroy()
	maid3:Destroy()
end

window.Board.Close.Button.Activated:Connect(close)
parent.Close.Activated:Connect(close)
Utils.Network.Events.AdminPanelPrompt = SearchUser