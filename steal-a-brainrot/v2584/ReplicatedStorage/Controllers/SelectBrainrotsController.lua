local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local Animals = require(ReplicatedStorage.Shared.Animals)
local Index = require(ReplicatedStorage.Shared.Index)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local remoteFunction = Net:RemoteFunction("SettingsService/SetFilterBrainrots")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(0, 255, 51)
local color3 = Color3.fromRGB(0, 0, 0)
local color4 = Color3.fromRGB(0, 0, 0)

local function GetBrainrotList()
	local result = {}

	for k in Animals2 do
		if Index:CanShowInIndex(k) then
			table.insert(result, k)
		end
	end

	table.sort(result, function(a, b)
		local generation = Animals2[a].Generation or 0
		local generation2 = Animals2[b].Generation or 0

		if generation == generation2 then
			return a < b
		end

		return generation2 < generation
	end)
	return result
end

local function ApplyRarity(rarityLabel, rarity: string?, maid)
	rarityLabel.Text = rarity or ""
	local v

	if rarity then
		v = Rarities[rarity]
	end

	if v and v.GradientPreset then
		rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		maid:Add(Gradients.apply(rarityLabel, v.GradientPreset))
	elseif v then
		rarityLabel.TextColor3 = v.Color
	end
end

return {
	Start = function(_)
		local selectBrainrots = playerGui:WaitForChild("SelectBrainrots"):WaitForChild("SelectBrainrots")
		local main = selectBrainrots.Main
		local header = main.Header
		local close = header.Close
		local searchBox = header.SearchFrame.SearchBox
		local list = main.Content.Holder.List
		local template = list.Template
		local uIGridLayout = list.UIGridLayout
		local buttons = main:FindFirstChild("Buttons")
		local yes = buttons and buttons:FindFirstChild("Yes")
		local cancel = buttons and buttons:FindFirstChild("Cancel")

		if not (yes and cancel) then
			warn("[SelectBrainrots] Confirm/Cancel buttons missing (Main.Buttons.Yes/Cancel) — syncback the UI")
		end

		template.Visible = false
		local v = InterfaceController:Register("SelectBrainrots", selectBrainrots, "TopQuint")
		v:AttachCloseButton(close)
		v:Close()
		local maid = Trove.new()
		local v2 = {}
		local v3 = {}
		local text = ""
		local v4 = {}
		local v5 = Synchronizer:Wait(localPlayer)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyCardColor(p: string)
			local v6 = v2[p]

			if not v6 then
				return
			end

			local v7 = v4[p] == true
			local card = v6.Card
			local backgroundColor

			if v7 then
				backgroundColor = color
			else
				backgroundColor = color3
			end

			card.BackgroundColor3 = backgroundColor
			local uIStroke = v6.Card:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				local color5

				if v7 then
					color5 = color2
				else
					color5 = color4
				end

				uIStroke.Color = color5
			end
		end

		local function matchesQuery(displayName: string)
			if text == "" then
				return true
			end

			local animal = Animals2[displayName]

			if animal then
				displayName = animal.DisplayName or displayName
			end

			return string.find(string.lower(displayName), text, 1, true) ~= nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function attachViewport(state)
			if state.Attached then
				return
			end

			state.Attached = Animals:AttachOnViewportWithOptimizations(state.Index, state.Viewport, nil, nil)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function detachViewport(p)
			if not p.Attached then
				return
			end

			p.Attached:Destroy()
			p.Attached = nil
		end

		local Y = 0
		local v6 = 0
		local v7 = 0
		local zero = Vector2.zero
		local _ = Vector2.zero
		local _ = Vector2.zero
		local v8 = 0
		local visible = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSize()
			zero = list.AbsoluteSize
			v6 = list.AbsolutePosition.Y + zero.Y
			local cellPadding = uIGridLayout.CellPadding
			v8 = cellPadding.Y.Scale * zero.Y + cellPadding.Y.Offset
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePosition()
			Y = list.AbsolutePosition.Y
			v6 = list.AbsolutePosition.Y + zero.Y
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateWindowTop()
			v7 = Y - list.CanvasPosition.Y
			visible = selectBrainrots.Visible
		end

		zero = list.AbsoluteSize
		v6 = list.AbsolutePosition.Y + zero.Y
		local cellPadding = uIGridLayout.CellPadding
		v8 = cellPadding.Y.Scale * zero.Y + cellPadding.Y.Offset
		updatePosition() -- equivalent call inferred; original call site unknown
		updateWindowTop() -- equivalent call inferred; original call site unknown
		local absoluteCellCount = uIGridLayout.AbsoluteCellCount
		local absoluteCellSize = uIGridLayout.AbsoluteCellSize
		uIGridLayout:GetPropertyChangedSignal("AbsoluteCellCount"):Connect(function()
			absoluteCellCount = uIGridLayout.AbsoluteCellCount
		end)
		uIGridLayout:GetPropertyChangedSignal("AbsoluteCellSize"):Connect(function()
			absoluteCellSize = uIGridLayout.AbsoluteCellSize
		end)
		uIGridLayout:GetPropertyChangedSignal("CellPadding"):Connect(updateSize)
		list:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
		list:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			updatePosition() -- equivalent call inferred; original call site unknown
			updateWindowTop() -- equivalent call inferred; original call site unknown
		end)
		list:GetPropertyChangedSignal("CanvasPosition"):Connect(updateWindowTop)
		selectBrainrots:GetPropertyChangedSignal("Visible"):Connect(function()
			updatePosition() -- equivalent call inferred; original call site unknown
			updateSize() -- equivalent call inferred; original call site unknown
			updateWindowTop() -- equivalent call inferred; original call site unknown
		end)
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resortGrid()
			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				local children = list:GetChildren()
				local namesByGuiObject = {}
				local layoutOrdersByGuiObject = {}
				local v10 = {}

				for i = #children, 1, -1 do
					local guiObject = children[i]

					if guiObject:IsA("GuiObject") and guiObject.Visible and guiObject ~= template then
						namesByGuiObject[guiObject] = guiObject.Name
						layoutOrdersByGuiObject[guiObject] = guiObject.LayoutOrder
						v10[guiObject] = i
					else
						table.remove(children, i)
					end
				end

				table.sort(children, function(a, b)
					if layoutOrdersByGuiObject[a] ~= layoutOrdersByGuiObject[b] then
						return layoutOrdersByGuiObject[a] < layoutOrdersByGuiObject[b]
					end

					if namesByGuiObject[a] == namesByGuiObject[b] then
						return v10[a] < v10[b]
					end

					return namesByGuiObject[a] < namesByGuiObject[b]
				end)
				table.clear(v3)

				for k, v11 in children do
					v3[v11] = k
				end
			end)
		end

		uIGridLayout:GetPropertyChangedSignal("AbsoluteCellCount"):Connect(resortGrid)
		RunService.Heartbeat:Connect(function()
			debug.profilebegin("SelectBrainrots::Cull")
			local v10 = absoluteCellSize.Y * 2

			for _, v11 in v2 do
				local v12 = v3[v11.Card]
				local state

				if v12 and absoluteCellCount.X >= 1 then
					local v14 = math.ceil(v12 / absoluteCellCount.X) - 1
					local v15 = v7 + (absoluteCellSize.Y + v8) * v14 - v8
					local v16 = v15 + absoluteCellSize.Y
					state = visible

					if state then
						if Y < v16 then
							state = v15 < v6 + v10
						else
							state = false
						end
					end
				else
					state = false
				end

				if v11.State == state then
					continue
				end

				v11.State = state

				if state then
					attachViewport(v11) -- equivalent call inferred; original call site unknown
				else
					detachViewport(v11) -- equivalent call inferred; original call site unknown
				end
			end

			debug.profileend()
		end)

		local function clearCards()
			for _, v10 in v2 do
				detachViewport(v10) -- equivalent call inferred; original call site unknown
			end

			table.clear(v2)
			table.clear(v3)
			maid:Clean()
		end

		local function renderList()
			clearCards()
			table.clear(v4)
			local tradeFilterBrainrots = v5 and v5:Get("TradeFilterBrainrots")

			if typeof(tradeFilterBrainrots) == "table" then
				for k in tradeFilterBrainrots do
					v4[k] = true
				end
			end

			local count = 0

			for _, name in GetBrainrotList() do
				count += 1
				local animal = Animals2[name]
				local clone = maid:Clone(template)
				clone.Name = name
				clone.LayoutOrder = count
				local nameLabel = clone.NameLabel
				local text2

				if animal then
					text2 = animal.DisplayName or name
				else
					text2 = name
				end

				nameLabel.Text = text2
				clone.MutationLabel.Text = ""
				ApplyRarity(clone.RarityLabel, animal and animal.Rarity, maid)
				local visible2

				if text == "" then
					visible2 = true
				else
					local animal2 = Animals2[name]
					local v13

					if animal2 then
						v13 = animal2.DisplayName or name
					else
						v13 = name
					end

					visible2 = string.find(string.lower(v13), text, 1, true) ~= nil
				end

				clone.Visible = visible2
				v2[name] = {
					Card = clone,
					Viewport = clone.ViewportFrame,
					Index = name,
					Attached = nil,
					State = nil
				}
				applyCardColor(name) -- equivalent call inferred; original call site unknown
				local v14 = name
				maid:Add(clone.Activated:Connect(function()
					SoundController:PlaySound("Sounds.Sfx.Activated")
					v4[v14] = not v4[v14] or nil
					applyCardColor(v14) -- equivalent call inferred; original call site unknown
				end))
				clone.Parent = list
			end

			resortGrid() -- equivalent call inferred; original call site unknown
		end

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			text = string.lower(searchBox.Text)

			for displayName, v10 in v2 do
				local card = v10.Card
				local visible2

				if text == "" then
					visible2 = true
				else
					local animal = Animals2[displayName]

					if animal then
						displayName = animal.DisplayName or displayName
					end

					visible2 = string.find(string.lower(displayName), text, 1, true) ~= nil
				end

				card.Visible = visible2
			end

			resortGrid() -- equivalent call inferred; original call site unknown
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closePicker()
			InterfaceController:SetState("SelectBrainrots", false)
		end

		if yes then
			local flag2 = false
			local v10 = AnimatedButton.new(yes)
			v10:Animate()
			v10.OnActivated:Connect(function()
				if flag2 then
					return
				end

				flag2 = true
				SoundController:PlaySound("Sounds.Sfx.Activated")
				local v11 = {}

				for k, v12 in v4 do
					if v12 then
						table.insert(v11, k)
					end
				end

				local v12, v13 = remoteFunction:InvokeServer(v11)

				if v12 then
					flag2 = false
					closePicker() -- equivalent call inferred; original call site unknown
				else
					NotificationController:Error(typeof(v13) ~= "string" and "Failed to save selection" or v13)
					SoundController:PlaySound("Sounds.Sfx.Error")
					flag2 = false
				end
			end)
		end

		if cancel then
			local v10 = AnimatedButton.new(cancel)
			v10:Animate()
			v10.OnActivated:Connect(function()
				SoundController:PlaySound("Sounds.Sfx.Activated")
				closePicker() -- equivalent call inferred; original call site unknown
			end)
		end

		v.OnOpen:Connect(renderList)
		v.OnClose:Connect(function()
			clearCards()
			task.defer(function()
				if v:IsOpened() then
					return
				end

				for k, v10 in InterfaceController:GetInterfaces() do
					if k ~= "Hud" and k ~= "SelectBrainrots" and v10:IsOpened() then
						return
					end
				end

				InterfaceController:SetState("TradePlayerList", true)
			end)
		end)

		if v5 then
			v5:OnDictionaryInserted("TradeFilterBrainrots", function(_, value)
				if typeof(value) == "string" then
					v4[value] = true
					applyCardColor(value) -- equivalent call inferred; original call site unknown
				end
			end)
			v5:OnDictionaryRemoved("TradeFilterBrainrots", function(_, value)
				if typeof(value) == "string" then
					v4[value] = nil
					applyCardColor(value) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end
}