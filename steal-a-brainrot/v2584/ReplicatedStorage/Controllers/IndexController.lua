local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local Synchronizer = require(packages.Synchronizer)
local Trove = require(packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals = require(datas.Animals)
local Rarities = require(datas.Rarities)
local Mutations = require(datas.Mutations)
local Index = require(ReplicatedStorage.Datas.Index)
local Net = require(packages.Net)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Animals2 = require(shared.Animals)
local Index2 = require(shared.Index)
local Updates = require(shared.Updates)
local MutationText = require(shared.MutationText)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local HoverInfoController = require(controllers.HoverInfoController)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local localPlayer = Players.LocalPlayer
local index = localPlayer.PlayerGui:WaitForChild("Index").Index
local header = index.Main.Header
local close = header.Close
local searchBox = header.SearchFrame.SearchBox
local list = index.Main.Content.Holder.List
local template = list.Template
local mutations = index.Main.Mutations
local template2 = mutations.Template
local progress = index.Progress
local description = progress.Description
local bar = progress.Bar
local loading = bar.Loading
local number = bar.Number
local v = {}
local name = "Default"
local v2 = Signal.new()
local text = ""
local v3 = Signal.new()
local maid = Trove.new()
local v4 = nil
local flag = false

local function matchesSearch(displayName: string)
	if text == "" then
		return true
	end

	local animal = Animals[displayName]

	if animal then
		displayName = animal.DisplayName or displayName
	end

	return string.find(displayName:lower(), text, 1, true) ~= nil
end

local function Setup()
	task.spawn(function()
		if ServerData.IsTsunamiServer() or ServerData.IsDuelsServer() then
			return
		end

		Net:RemoteEvent("ExistCounts/RequestPublic"):FireServer("4833d1a5-7006-4219-a006-18550cb9f1c6")
	end)

	if flag then
		v2:Fire(name)
		return
	end

	local v5 = Synchronizer:Get(localPlayer)

	if not v5 then
		return
	end

	flag = true
	local _ = Index[name]
	local list2 = Animals2:GetList("Generation", true)

	for i = 1, #list2 do
		local name2 = list2[i]
		local animal = Animals[name2]
		local rarity = Rarities[animal.Rarity]

		if not Index2:CanShowInIndex(name2) then
			continue
		end

		local child = list:FindFirstChild(name2)

		if child then
			child.LayoutOrder = i
		else
			local clone = template:Clone()
			clone.Name = name2
			clone.LayoutOrder = i
			local name3 = name2

			local function refreshVisibility()
				local v9 = Index[name]
				local visible = not (v9 and v9.Index) or v9.Index[name3] ~= nil
				local targetParent = clone

				if visible then
					local displayName = name3

					if text == "" then
						visible = true
					else
						local animal2 = Animals[displayName]

						if animal2 then
							displayName = animal2.DisplayName or displayName
						end

						visible = string.find(displayName:lower(), text, 1, true) ~= nil
					end
				end

				targetParent.Visible = visible
			end

			local v9 = Index[name]
			local visible2 = not v9 or not v9.Index or v9.Index[name2] ~= nil

			if visible2 then
				if text == "" then
					visible2 = true
				else
					local animal2 = Animals[name2]
					local v11

					if animal2 then
						v11 = animal2.DisplayName or name2
					else
						v11 = name2
					end

					visible2 = string.find(v11:lower(), text, 1, true) ~= nil
				end
			end

			clone.Visible = visible2
			v2:Connect(refreshVisibility)
			v3:Connect(refreshVisibility)
			local viewportFrame = clone.ViewportFrame
			local v11 = nil
			local v12 = nil
			local v13 = nil
			clone.NameLabel.Text = animal.DisplayName
			clone.RarityLabel.Text = animal.Rarity
			local v14, v15, v16 = Animals2:AttachOnViewport(name2, viewportFrame, true, nil, true)

			if v14 then
				v[viewportFrame] = {
					targetParent = clone,
					cellIndex = i,
					state = nil
				}
				viewportFrame.Parent = nil
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function cleanupEffects()
				if v12 then
					maid:Remove(v12)
					v12 = nil
				end

				if v11 then
					maid:Remove(v11)
					v11 = nil
				end

				if v13 then
					maid:Remove(v13)
					v13 = nil
				end
			end

			local update
			local update2 = update
			local name4 = name2
			local targetParent2 = clone
			local v20 = rarity

			update = function()
				if v[viewportFrame] and v[viewportFrame].state ~= true then
					v[viewportFrame].scheduledUpdate = update2
					return
				end

				local v22 = name or "Default"
				local v23 = not Index[v22] and "Default" or v22
				local v24 = not Index[v23] or Index[v23].IsMutation
				local v25 = v5:Get({ "Index", name4 })
				local visible

				if Index[v23] and Index[v23].CustomIndex then
					if v25 ~= nil then
						visible = v25[Index[v23].CustomIndex.Name] or nil
					end
				elseif v24 then
					if v25 ~= nil then
						visible = v25[v23] or nil
					end
				elseif v25 == nil then
					visible = false
				else
					visible = next(v25) ~= nil
				end

				targetParent2.NameLabel.Visible = visible
				viewportFrame.ImageColor3 = not visible and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
				cleanupEffects() -- equivalent call inferred; original call site unknown

				if v20.GradientPreset then
					targetParent2.RarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					v13 = maid:Add(Gradients.apply(targetParent2.RarityLabel, v20.GradientPreset))
				else
					targetParent2.RarityLabel.TextColor3 = v20.Color
				end

				local v27 = MutationText.apply(targetParent2.MutationLabel, v23, "Auto")

				if v27 then
					v12 = maid:Add(v27)
				end

				local v28 = v15 and v15()

				if v28 and v23 ~= "Default" and visible and v24 then
					v11 = maid:Add(Animals2:ApplyMutation(v28, name4, v23, true))
				end
			end

			local update3 = update
			v2:Connect(function()
				cleanupEffects() -- equivalent call inferred; original call site unknown
				update3()
			end)
			v5:OnChanged({ "Index", name2 }, update, true)
			task.spawn(update)

			if v16 then
				local update4 = update
				v16(function()
					update4()
				end)
			end

			local name5 = name2
			HoverInfoController:Add(clone, function()
				return name5, name
			end)
			clone.Parent = list
		end
	end

	local function update()
		local indexAnimals, v6, v7 = Index2:GetIndexAnimals(localPlayer, name)
		assert(indexAnimals)
		assert(v6)
		assert(v7)
		local isComplete = Index2:IsComplete(localPlayer, name)
		loading.Size = UDim2.new(math.clamp(indexAnimals / v6, 0, 1), 0, 1, 0)
		header.Total.Text = `{indexAnimals}/{v7}`

		if isComplete then
			number.Text = "Milestone Completed"
			number.TextColor3 = Color3.new(0.0588235, 1, 0.32549)
			loading.BackgroundColor3 = Color3.new(0.490196, 0.941176, 0.439216)
		else
			number.Text = `{indexAnimals}/{v6}`
			number.TextColor3 = Color3.new(1, 1, 1)
			loading.BackgroundColor3 = Color3.new(0.941176, 0.729412, 0.482353)
		end
	end

	v2:Connect(update)
	update()
end

return {
	Start = function(_)
		v4 = InterfaceController:Register("Index", index, "TopQuint")
		v4:AttachCloseButton(close)
		v4:Close()
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			text = searchBox.Text:lower()
			v3:Fire(text)
		end)
		local clone = template2:Clone()
		clone.Button.TextLabel.Text = "Normal"
		clone.Name = "Default"
		clone.LayoutOrder = 0
		clone.Parent = mutations
		clone.Visible = true
		clone.Button.ImageLabel.Image = "rbxassetid://139326264265904"
		local v5 = AnimatedButton.new(clone.Button, clone)
		v5:Animate()
		v5.OnActivated:Connect(function()
			if name == clone.Name then
				return
			end

			name = clone.Name
			v2:Fire(name)
		end)

		for k, v6 in Index do
			local limitedMutation = v6.LimitedMutation
			local indexLimitedTime = Index2:GetIndexLimitedTime(k) or limitedMutation
			local v7

			if v6.IsMutation == true and indexLimitedTime ~= nil then
				v7 = indexLimitedTime < workspace:GetServerTimeNow()
			else
				v7 = false
			end

			if not Index2:CanProgressIndex(k) or (v6.DisableIndex or v6.HideButton) then
				continue
			end

			local clone2 = template2:Clone()
			clone2.Name = k
			local layoutOrder

			if indexLimitedTime then
				layoutOrder = 2000000000 - indexLimitedTime
			else
				layoutOrder = v6.Order or 1
			end

			clone2.LayoutOrder = layoutOrder
			clone2.Visible = true
			MutationText.apply(clone2.Button.TextLabel, k, "Auto")
			local icon = Mutations[k] and Mutations[k].Icon
			clone2.Button.ImageLabel.Image = icon or "rbxassetid://139326264265904"
			clone2.Parent = mutations
			-- equivalent calls inferred from this helper; original call sites unknown
			local v9 = v6
			local v10 = k

			local function isVisible()
				local v11 = not v9.Update or Updates.Methods.IsEnabled(v9.Update)
				return Index2:CanProgressIndex(v10) and v11
			end

			if limitedMutation and not v7 then
				local v11 = clone2
				local v12 = v6
				local v13 = k
				local limitedMutation2 = limitedMutation
				task.spawn(function()
					Updates.OnUpdateEnabled:Connect(function()
						v11.Visible = isVisible()
					end)
					Updates.OnUpdateDisabled:Connect(function()
						v11.Visible = isVisible()
					end)
					local v15 = true

					while v11.Parent == mutations do
						local v16 = (Index2:GetIndexLimitedTime(v13) or limitedMutation2) - workspace:GetServerTimeNow()
						v11.Button.Timer.Text = TimeUtils:E(v16)
						v11.Button.Timer.Visible = v16 > 0

						if v16 <= 0 and not v15 then
							v15 = true
							v11.Button.TextLabel.Position = UDim2.fromScale(0.627, 0.5)
							v11.Button.TextLabel.Size = UDim2.fromScale(0.596, 0.7)
							v11.Button.TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
							v11.Visible = isVisible()

							if not Index2:CanProgressIndex(v13) and name == v13 then
								name = "Default"
								v2:Fire(name)
							end
						elseif v16 > 0 and v15 then
							v11.Button.TextLabel.Position = UDim2.fromScale(0.627, 0.05)
							v11.Button.TextLabel.Size = UDim2.fromScale(0.596, 0.525)
							v11.Button.TextLabel.AnchorPoint = Vector2.new(0.5, 0)
							v11.Visible = isVisible()
							v15 = false
						end

						task.wait(1)
					end
				end)
			end

			local v11 = AnimatedButton.new(clone2.Button, clone2)
			v11:Animate()
			local v12 = k
			v11.OnActivated:Connect(function()
				if name == v12 then
					return
				end

				name = v12
				v2:Fire(name)
			end)
		end

		local Y = 0
		local v6 = 0
		local v7 = 0
		local zero = Vector2.zero
		local _ = Vector2.zero
		local v8 = nil
		local uIGridLayout = list.UIGridLayout

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

		local visible = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateWindowTop()
			v7 = Y - list.CanvasPosition.Y
			visible = index.Visible
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
		uIGridLayout:GetPropertyChangedSignal("CellPadding"):Connect(function()
			local cellPadding2 = uIGridLayout.CellPadding
			v8 = cellPadding2.Y.Scale * zero.Y + cellPadding2.Y.Offset
		end)
		list:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
		list:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			updatePosition() -- equivalent call inferred; original call site unknown
			updateWindowTop() -- equivalent call inferred; original call site unknown
		end)
		list:GetPropertyChangedSignal("CanvasPosition"):Connect(updateWindowTop)
		index:GetPropertyChangedSignal("Visible"):Connect(function()
			updatePosition() -- equivalent call inferred; original call site unknown
			updateSize() -- equivalent call inferred; original call site unknown
			updateWindowTop() -- equivalent call inferred; original call site unknown
		end)
		local v10 = {}
		local flag2 = false

		local function resortGrid()
			if flag2 then
				return
			end

			flag2 = true
			task.defer(function()
				flag2 = false
				local children = list:GetChildren()
				local names = {}
				local layoutOrders = {}
				local v11 = {}

				for i = #children, 1, -1 do
					if children[i]:IsA("GuiObject") and children[i].Visible then
						names[children[i]] = children[i].Name
						layoutOrders[children[i]] = children[i].LayoutOrder
						v11[children[i]] = i
					else
						table.remove(children, i)
					end
				end

				table.sort(children, function(a, b)
					if layoutOrders[a] ~= layoutOrders[b] then
						return layoutOrders[a] < layoutOrders[b]
					end

					if names[a] == names[b] then
						return v11[a] < v11[b]
					end

					return names[a] < names[b]
				end)
				table.clear(v10)

				for k, v12 in children do
					v10[v12] = k
				end
			end)
		end

		if not flag2 then
			flag2 = true
			task.defer(function()
				flag2 = false
				local children = list:GetChildren()
				local names = {}
				local layoutOrders = {}
				local v11 = {}

				for i = #children, 1, -1 do
					if children[i]:IsA("GuiObject") and children[i].Visible then
						names[children[i]] = children[i].Name
						layoutOrders[children[i]] = children[i].LayoutOrder
						v11[children[i]] = i
					else
						table.remove(children, i)
					end
				end

				table.sort(children, function(a, b)
					if layoutOrders[a] ~= layoutOrders[b] then
						return layoutOrders[a] < layoutOrders[b]
					end

					if names[a] == names[b] then
						return v11[a] < v11[b]
					end

					return names[a] < names[b]
				end)
				table.clear(v10)

				for k, v12 in children do
					v10[v12] = k
				end
			end)
		end

		list.UIGridLayout:GetPropertyChangedSignal("AbsoluteCellCount"):Connect(resortGrid)
		RunService.Heartbeat:Connect(function()
			debug.profilebegin("Index::Cull")
			local v11 = absoluteCellSize.Y * 2
			local count = 0

			for k, v12 in v do
				local v13 = v10[v12.targetParent]
				local state

				if v13 then
					local v15 = math.ceil(v13 / absoluteCellCount.X) - 1
					local v16 = v7 + (absoluteCellSize.Y + v8) * v15 - v8
					local v17 = v16 + absoluteCellSize.Y
					state = visible

					if state then
						if Y < v17 then
							state = v16 < v6 + v11
						else
							state = false
						end
					end
				else
					state = false
				end

				if v12.state ~= state then
					local parent

					if state then
						parent = v12.targetParent
					end

					k.Parent = parent
					v12.state = state

					if v12.scheduledUpdate and state == true then
						v12.scheduledUpdate()
						v12.scheduledUpdate = nil
					end
				end

				count += 1
			end

			debug.profileend()
		end)
		Synchronizer:WaitAndCall(localPlayer, function(_)
			v4.OnOpen:Connect(Setup)
			v4.OnClose:Connect(function()
				maid:Clean()
			end)

			if v4:IsOpened() then
				Setup()
			end
		end)
		Updates.OnUpdateEnabled:Connect(function()
			if v4:IsOpened() then
				v2:Fire(name)
				Setup()
			end
		end)
		Updates.OnUpdateDisabled:Connect(function()
			if v4:IsOpened() then
				Setup()
			end
		end)

		local function updateDescription()
			if not name then
				return
			end

			local v11 = Index[name]
			local completitionPercent = v11 and v11.CompletitionPercent or name == "Default" and 0.75 or 1
			local color = Color3.new(1, 1, 1)

			if name ~= "Default" and name ~= nil and v11 then
				color = v11.MainColor
			end

			local v12 = not (v11 and v11.LimitedMutation)
			local resolved

			if v11 then
				resolved = MutationText.resolve(name, "Rich")
			else
				resolved = `<font color="#{color:ToHex()}">{name}</font>`
			end

			local v13 = description
			local text2

			if name == "Default" then
				text2 = `Collect {math.round(completitionPercent * 100)}% Normal Brainrots for +0.5x Base Multi`
			elseif name == "Halloween" then
				text2 = `Collect {math.round(completitionPercent * 100)}% {resolved} Brainrots for a <font color="#{color:ToHex()}">{resolved} Base</font>`
			else
				text2 = `Collect {math.round(completitionPercent * 100)}% {resolved} Brainrots for {v12 and "+0.5x Base Multi and " or ""}a <font color="#{color:ToHex()}">{resolved} Base</font>`
			end

			v13.Text = text2
		end

		v2:Connect(updateDescription)
		updateDescription()
	end
}