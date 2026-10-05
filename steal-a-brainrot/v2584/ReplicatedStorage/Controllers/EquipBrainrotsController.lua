local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local NotificationController = require(controllers.NotificationController)
local SoundController = require(controllers.SoundController)
local HoverInfoController = require(controllers.HoverInfoController)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local Animals = require(ReplicatedStorage.Shared.Animals)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local EquipBrainrots = require(ReplicatedStorage.Shared.EquipBrainrots)
local EquipBrainrotsFlags = require(ReplicatedStorage.Shared.Flags.EquipBrainrotsFlags)
local isTradePlaza = ServerData.IsTradePlaza()
local maxEquipped = EquipBrainrots.MaxEquipped
local remoteFunction = Net:RemoteFunction("EquipBrainrotsService/SetEquipped")
local color = Color3.fromRGB(81, 158, 86)
local color2 = Color3.fromRGB(168, 58, 58)
local color3 = Color3.fromRGB(0, 255, 51)
local color4 = Color3.fromRGB(0, 255, 0)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local userId = tostring(localPlayer.UserId)
local equipBrainrots = playerGui:WaitForChild("LeftCenter").LeftCenter.Buttons:WaitForChild("EquipBrainrots")
local equipBrainrots2 = ReplicatorClient.get("EquipBrainrots")

local function GetInventory(object)
	local podiumEntries = {}
	local animalPodiums = object:Get("AnimalPodiums")

	if typeof(animalPodiums) ~= "table" then
		return podiumEntries
	end

	for k, animalPodium in animalPodiums do
		if typeof(animalPodium) ~= "table" or animalPodium.Machine or not Animals2[animalPodium.Index] then
			continue
		end

		table.insert(podiumEntries, {
			Card = nil,
			Viewport = nil,
			PodiumKey = tostring(k),
			Index = animalPodium.Index,
			Mutation = animalPodium.Mutation,
			Traits = animalPodium.Traits,
			Attached = nil,
			State = nil
		})
	end

	table.sort(podiumEntries, function(a, b)
		local generation = Animals:GetGeneration(a.Index, a.Mutation, a.Traits)
		local generation2 = Animals:GetGeneration(b.Index, b.Mutation, b.Traits)

		if generation == generation2 then
			return a.Index < b.Index
		end

		return generation2 < generation
	end)
	return podiumEntries
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

local function RenderTraits(traits, traits2, instance)
	for _, name in traits2 or {} do
		local trait = Traits[name]

		if not trait then
			continue
		end

		local clone = instance:Clone(traits.Template)
		clone.Name = name
		clone.Visible = true
		clone.Image = trait.Icon
		clone.Parent = traits
	end
end

return {
	Start = function(_)
		if not isTradePlaza then
			equipBrainrots.Visible = false
			return
		end

		local equipBrainrots3 = playerGui:WaitForChild("EquipBrainrots"):WaitForChild("EquipBrainrots")
		local main = equipBrainrots3.Main
		local header = main.Header
		local close = header.Close
		local equippedText = header.EquippedText
		local holder = main.Content.Holder
		local list = holder.List
		local info = holder.Info
		local item = info.Item
		local equip = info.Equip
		local txt = equip.Txt
		local uIGridLayout = list.UIGridLayout
		local template = list.Template
		template.Visible = false
		template.Traits.Template.Visible = false
		item.Traits.Template.Visible = false
		local color5 = template.UIStroke.Color
		local thickness = template.UIStroke.Thickness
		local backgroundColor3 = template.BackgroundColor3
		local v = InterfaceController:Register("EquipBrainrots", equipBrainrots3, "TopQuint")
		v:AttachCloseButton(close)
		v:Close()
		local v2 = Synchronizer:Wait(localPlayer)
		local maid = Trove.new()
		local v3 = Trove.new()
		local v4 = {}
		local v5 = {}
		local v6 = nil
		local v7 = {}

		local function setLayout(flag: boolean)
			local size = list.Size
			Spr.target(list, 1, 5, {
				Size = UDim2.new(flag and 0.612 or 0.967, size.X.Offset, size.Y.Scale, size.Y.Offset)
			})
			local position = info.Position
			Spr.target(info, 1, 5, {
				Position = UDim2.new(flag and 1 or 1.339, position.X.Offset, position.Y.Scale, position.Y.Offset)
			})
			local cellPadding = uIGridLayout.CellPadding
			Spr.target(uIGridLayout, 1, 5, {
				CellPadding = UDim2.new(
					flag and 0.02 or 0.011,
					cellPadding.X.Offset,
					cellPadding.Y.Scale,
					cellPadding.Y.Offset
				)
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setEquipState(flag: boolean)
			local target = Spr.target
			local backgroundColor

			if flag then
				backgroundColor = color2
			else
				backgroundColor = color
			end

			target(equip, 1, 5, {
				BackgroundColor3 = backgroundColor
			})
			txt.Text = flag and "Unequip" or "Equip"
		end

		local function applyCardVisual(p)
			local v8 = p.PodiumKey == v6
			local v9 = v7[p.PodiumKey] ~= nil
			local isOneOfOne = BrainrotCard.IsOneOfOne(p)
			local uIStroke = p.Card:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				local target = Spr.target
				local oneOfOneStroke

				if v8 or v9 then
					oneOfOneStroke = color3
				elseif isOneOfOne then
					oneOfOneStroke = BrainrotCard.OneOfOneStroke
				else
					oneOfOneStroke = color5
				end

				target(uIStroke, 1, 5, {
					Color = oneOfOneStroke,
					Thickness = v8 and 2 or thickness
				})
			end

			local target = Spr.target
			local card = p.Card
			local oneOfOneBackground

			if v9 then
				oneOfOneBackground = color4
			elseif isOneOfOne then
				oneOfOneBackground = BrainrotCard.OneOfOneBackground
			else
				oneOfOneBackground = backgroundColor3
			end

			target(card, 1, 5, {
				BackgroundColor3 = oneOfOneBackground
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function renderInfo(data)
			v3:Clean()

			if not data then
				return
			end

			local animal = Animals2[data.Index]
			item.Title.Text = animal and animal.DisplayName or data.Index
			ApplyRarity(item.RarityLabel, animal and animal.Rarity, v3)
			local v8 = MutationText.apply(item.MutationLabel, data.Mutation, "Auto")

			if v8 then
				v3:Add(v8)
			end

			RenderTraits(item.Traits, data.Traits, v3)
			v3:Add((Animals:AttachOnViewportWithOptimizations(data.Index, item.ViewportFrame, nil, data.Mutation)))
			setEquipState(v7[data.PodiumKey] ~= nil) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSelected(p: string?)
			local v8 = v6
			v6 = p
			setLayout(p ~= nil)
			local v10

			if p then
				v10 = v4[p]
			end

			renderInfo(v10)

			if v8 and v4[v8] then
				applyCardVisual(v4[v8])
			end

			if p and v4[p] then
				applyCardVisual(v4[p])
			end
		end

		local function refreshEquippedVisuals()
			local count = 0

			for _ in v7 do
				count += 1
			end

			equippedText.Text = `Equipped: {count}/{maxEquipped}`

			for _, v8 in v4 do
				applyCardVisual(v8)
			end

			if v6 then
				setEquipState(v7[v6] ~= nil) -- equivalent call inferred; original call site unknown
			end
		end

		local Y = 0
		local v8 = 0
		local v9 = 0
		local zero = Vector2.zero
		local _ = Vector2.zero
		local _ = Vector2.zero
		local v10 = 0
		local visible = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSize()
			zero = list.AbsoluteSize
			v8 = list.AbsolutePosition.Y + zero.Y
			local cellPadding = uIGridLayout.CellPadding
			v10 = cellPadding.Y.Scale * zero.Y + cellPadding.Y.Offset
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePosition()
			Y = list.AbsolutePosition.Y
			v8 = list.AbsolutePosition.Y + zero.Y
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateWindowTop()
			v9 = Y - list.CanvasPosition.Y
			visible = equipBrainrots3.Visible
		end

		zero = list.AbsoluteSize
		v8 = list.AbsolutePosition.Y + zero.Y
		local cellPadding = uIGridLayout.CellPadding
		v10 = cellPadding.Y.Scale * zero.Y + cellPadding.Y.Offset
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
		equipBrainrots3:GetPropertyChangedSignal("Visible"):Connect(function()
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
				local v12 = {}

				for i = #children, 1, -1 do
					local guiObject = children[i]

					if guiObject:IsA("GuiObject") and guiObject.Visible and guiObject ~= template then
						namesByGuiObject[guiObject] = guiObject.Name
						layoutOrdersByGuiObject[guiObject] = guiObject.LayoutOrder
						v12[guiObject] = i
					else
						table.remove(children, i)
					end
				end

				table.sort(children, function(a, b)
					if layoutOrdersByGuiObject[a] ~= layoutOrdersByGuiObject[b] then
						return layoutOrdersByGuiObject[a] < layoutOrdersByGuiObject[b]
					end

					if namesByGuiObject[a] == namesByGuiObject[b] then
						return v12[a] < v12[b]
					end

					return namesByGuiObject[a] < namesByGuiObject[b]
				end)
				table.clear(v5)

				for k, v13 in children do
					v5[v13] = k
				end
			end)
		end

		uIGridLayout:GetPropertyChangedSignal("AbsoluteCellCount"):Connect(resortGrid)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function attachViewport(state)
			if state.Attached then
				return
			end

			state.Attached = Animals:AttachOnViewportWithOptimizations(state.Index, state.Viewport, nil, state.Mutation)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function detachViewport(p)
			if not p.Attached then
				return
			end

			p.Attached:Destroy()
			p.Attached = nil
		end

		RunService.Heartbeat:Connect(function()
			debug.profilebegin("EquipBrainrots::Cull")
			local v12 = absoluteCellSize.Y * 2

			for _, v13 in v4 do
				local v14 = v5[v13.Card]
				local state

				if v14 and absoluteCellCount.X >= 1 then
					local v16 = math.ceil(v14 / absoluteCellCount.X) - 1
					local v17 = v9 + (absoluteCellSize.Y + v10) * v16 - v10
					local v18 = v17 + absoluteCellSize.Y
					state = visible

					if state then
						if Y < v18 then
							state = v17 < v8 + v12
						else
							state = false
						end
					end
				else
					state = false
				end

				if v13.State == state then
					continue
				end

				v13.State = state

				if state then
					attachViewport(v13) -- equivalent call inferred; original call site unknown
				else
					detachViewport(v13) -- equivalent call inferred; original call site unknown
				end
			end

			debug.profileend()
		end)

		local function clearCards()
			for _, v12 in v4 do
				detachViewport(v12) -- equivalent call inferred; original call site unknown
			end

			table.clear(v4)
			table.clear(v5)
			maid:Clean()
		end

		local flag2 = false

		local function requestEquip(p: string)
			if flag2 then
				return
			end

			flag2 = true
			local v12 = v7[p] == nil
			local success, result, v13 = pcall(remoteFunction.InvokeServer, remoteFunction, p, v12)
			flag2 = false

			if not (success and result) then
				NotificationController:Error(typeof(v13) ~= "string" and "Failed to equip" or v13)
				SoundController:PlaySound("Sounds.Sfx.Error")
			end
		end

		local function renderList()
			clearCards()
			local count = 0

			for _, v12 in GetInventory(v2) do
				count += 1
				local clone = maid:Clone(template)
				clone.Name = v12.PodiumKey
				clone.LayoutOrder = count
				clone.Visible = true
				BrainrotCard.Render(clone, v12, maid, "EquipBrainrots")
				v12.Card = clone
				v12.Viewport = clone.ViewportFrame
				v4[v12.PodiumKey] = v12
				applyCardVisual(v12)

				if EquipBrainrotsFlags.SimpleSelect:Get() then
					local v13 = v12
					maid:Add(HoverInfoController:Add(clone, function()
						return v13.Index, v13.Mutation, v13.Traits
					end))
					local v14 = v12
					maid:Add(clone.Activated:Connect(function()
						SoundController:PlaySound("Sounds.Sfx.Activated")
						requestEquip(v14.PodiumKey)
					end))
				else
					local v13 = v12
					maid:Add(clone.Activated:Connect(function()
						SoundController:PlaySound("Sounds.Sfx.Activated")
						local v14

						if v6 ~= v13.PodiumKey then
							v14 = v13.PodiumKey
						end

						setSelected(v14) -- equivalent call inferred; original call site unknown
					end))
				end

				clone.Parent = list
			end

			resortGrid() -- equivalent call inferred; original call site unknown
		end

		local v12 = AnimatedButton.new(equip)
		v12:Animate()
		v12.OnActivated:Connect(function()
			local v13 = v6

			if not v13 then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Activated")
			requestEquip(v13)
		end)
		equipBrainrots2:Observe({ "players", userId }, function(p)
			v7 = typeof(p) ~= "table" and {} or p
			refreshEquippedVisuals()
		end)
		v2:OnChanged("AnimalPodiums", function()
			if v:IsOpened() then
				renderList()
			end
		end)
		v.OnOpen:Connect(function()
			renderList()
			local v13 = v6
			v6 = nil
			setLayout(false)
			renderInfo() -- equivalent call inferred; original call site unknown

			if v13 and v4[v13] then
				applyCardVisual(v4[v13])
			end
		end)
		v.OnClose:Connect(function()
			local v13 = v6
			v6 = nil
			setLayout(false)
			renderInfo() -- equivalent call inferred; original call site unknown

			if v13 and v4[v13] then
				applyCardVisual(v4[v13])
			end

			clearCards()
		end)
		local v13 = v6
		v6 = nil
		setLayout(false)
		renderInfo() -- equivalent call inferred; original call site unknown

		if v13 and v4[v13] then
			applyCardVisual(v4[v13])
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateEnabled()
			local visible2 = EquipBrainrotsFlags.Enabled:Get()
			equipBrainrots.Visible = visible2

			if not visible2 and v:IsOpened() then
				InterfaceController:Toggle("EquipBrainrots", false)
			end
		end

		updateEnabled() -- equivalent call inferred; original call site unknown
		EquipBrainrotsFlags.Enabled.Changed:Connect(updateEnabled)
	end
}