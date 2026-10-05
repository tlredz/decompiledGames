local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CenterEquipped = require(script.MiscComponents.CenterEquipped)
local MainSpace = require(script.MiscComponents.MainSpace)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
local Searchbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.Searchbar)
local SkillPoints = require(script.MiscComponents.SkillPoints)
local SkillTreeZoomSlider = require(script.MiscComponents.SkillTreeZoomSlider)
local Load_Custom = require(ReplicatedStorage.CAM.Global.Load_Custom)
local Node = require(script.Node)
local SkillTreeholder = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local uidragger = require(ReplicatedStorage.Packages.uidragger)
require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local RunService = game:GetService("RunService")
local TreeConfigurations = require(script.TreeConfigurations)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local rootSearchbar = localPlayer:WaitForChild("MenuDestination"):WaitForChild("SkillTreeOption"):WaitForChild("RootSearchbar")
local v = TreeConfigurations.Settings.LeafRadius + TreeConfigurations.Settings.Padding
local currentCamera = workspace.CurrentCamera
local uDim = UDim2.fromScale(0.5, 0.5)
local v2 = 0.5
local uDim2 = UDim2.fromScale(0.1, 0.1)
local uDim3 = UDim2.fromScale(0.7, 0.03)
local v3 = nil
local mapIndex = nil
local v4 = 1

local function addLockAndRequirements(state, list)
	state.Locked = list.Locked
	local name = list.Name or state.Name
	local v5 = PlayerProfile.skill_info[name]

	if state.Locked == nil then
		if v5 == nil or v5.Locked == nil then
			local requirements, v6 = Stats.GetRequirements(localPlayer, name, state.PositionInBranch or state.Index)
			state.Locked = not v6
			state.Requirements = requirements
			state.ComputedLock = true
		else
			state.Locked = v5.Locked
		end
	end

	if state.Icon == nil and v5 ~= nil then
		state.Icon = v5.Icon
	end
end

local countBranches

countBranches = function(list)
	if list.IsBranch == nil then
		return 0
	end

	local total = 1

	for _, v5 in ipairs(list) do
		if typeof(v5) == "table" and v5.IsBranch ~= nil then
			total += countBranches(v5)
		end
	end

	return total
end

local function rootNames(list)
	local names = {}

	for _, v5 in ipairs(list) do
		if v5.IsBranch ~= nil and v5.Name ~= nil then
			table.insert(names, v5.Name)
		end
	end

	return names
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildPageName(branches)
	local v5 = rootNames(branches)

	if #v5 == 0 then
		return ""
	end

	if #v5 == 1 then
		return v5[1]
	end

	local v6 = table.remove(v5)
	return table.concat(v5, ", ") .. " and " .. v6
end

local info = faye.Info(0.25, Enum.EasingStyle.Back)

local function buildLeafMap(list)
	local mapIndex2 = 1
	local v5 = {
		[mapIndex2] = {
			MapIndex = mapIndex2,
			Type = TreeConfigurations.Menum.Type.Root,
			Rotation = 2.0943951023931953,
			Direction = 1,
			ChildCounter = 0,
			BranchDirection = 1,
			Position = UDim2.fromScale(0.5, 0.5)
		}
	}
	local count = 0
	local v6 = {}
	local total = 0
	local v7 = {}

	for _, v8 in ipairs(list) do
		if v8.IsBranch == nil then
			continue
		end

		count += 1
		local v9 = countBranches(v8)
		v6[count] = v9
		total += v9
	end

	if total > 0 then
		local count2 = #v6
		local rotationSnap = TreeConfigurations.Settings.RotationSnap
		local rotation = v5[1].Rotation

		if rotationSnap * count2 >= 6.283185307179586 then
			for i = 1, count2 do
				v7[i] = rotation + (i - 0.5) * (6.283185307179586 / count2)
			end
		else
			local v8 = 6.283185307179586 - rotationSnap * count2

			for i, v9 in ipairs(v6) do
				local v10 = rotationSnap + v9 / total * v8
				v7[i] = rotation + v10 / 2
				rotation += v10
			end
		end
	end

	local parse

	parse = function(list2, state)
		if list2.IsBranch == nil then
			if state.Type == TreeConfigurations.Menum.Type.Root then
				warn((`Can't create the leaf: {list2.Name} from the root, has to be from a branch.`))
				return
			end

			state.ChildCounter += 1
			state.ChildLeafCounter = (state.ChildLeafCounter or 0) + 1
			local v8 = (state.ChildCounter % 2 == 0 and 1 or -1) * TreeConfigurations.Settings.ZigZagOffset
			local v9 = {
				Type = TreeConfigurations.Menum.Type.Leaf,
				Ref = state.MapIndex,
				Index = state.ChildCounter,
				PositionInBranch = list2.ProgressionIndex or state.ChildLeafCounter,
				Rotation = state.Rotation + (state.ChildrenRotationInfluence or 0) + v8 + (list2.RotationBias or 0),
				MapIndex = mapIndex2 + 1,
				Prev = state.LastChild or state.MapIndex,
				Name = list2.Name,
				Icon = list2.Icon,
				IsBranch = list2.IsBranch,
				RotationBias = list2.RotationBias,
				DisplayName = list2.DisplayName
			}
			addLockAndRequirements(v9, list2)
			mapIndex2 = v9.MapIndex
			state.LastChild = mapIndex2
			v5[mapIndex2] = v9

			for _, v10 in ipairs(list2) do
				if typeof(v10) == "table" and v10.Name ~= nil then
					parse(v10, state)
				end
			end
		elseif state.Type == TreeConfigurations.Menum.Type.Root then
			state.ChildCounter += 1
			state.ChildBranchCounter = (state.ChildBranchCounter or 0) + 1
			local v8 = {
				Ref = state.MapIndex,
				Type = TreeConfigurations.Menum.Type.Branch,
				Index = state.ChildCounter,
				PositionInBranch = list2.ProgressionIndex or state.ChildBranchCounter,
				ChildCounter = 0,
				ChildBranchCounter = 0,
				ChildLeafCounter = 0,
				Rotation = (v7[state.ChildCounter] or state.Rotation) + (list2.RotationBias or 0),
				MapIndex = mapIndex2 + 1,
				Prev = state.MapIndex,
				Name = list2.Name,
				Icon = list2.Icon,
				IsBranch = true,
				AdditionalOffset = list2.AdditionalOffset,
				RotationBias = list2.RotationBias,
				DisplayName = list2.DisplayName
			}
			addLockAndRequirements(v8, list2)
			mapIndex2 = v8.MapIndex
			v5[mapIndex2] = v8

			for _, v9 in ipairs(list2) do
				parse(v9, v8)
			end
		elseif state.Type == TreeConfigurations.Menum.Type.Branch then
			state.ChildCounter = (state.ChildCounter or 0) + 1
			state.ChildBranchCounter = (state.ChildBranchCounter or 0) + 1
			state.BranchDirection = state.BranchDirection or 1
			state.BranchDirection *= -1
			local v8 = state.ChildCounter % 2 == 0 and 1 or -1
			local v9 = math.ceil(state.ChildCounter / 2)
			local v10 = TreeConfigurations.Settings.RotationSnap + (state.AdditionalOffset or 0)
			local v11 = v8 * v10 * v9
			local v12 = {
				Ref = state.MapIndex,
				Type = TreeConfigurations.Menum.Type.Branch,
				Rotation = state.Rotation + (state.ChildrenRotationInfluence or 0) + v11 + (list2.RotationBias or 0),
				MapIndex = mapIndex2 + 1,
				ChildCounter = 0,
				ChildBranchCounter = 0,
				ChildLeafCounter = 0,
				BranchDirection = 1,
				Index = state.ChildCounter,
				PositionInBranch = list2.ProgressionIndex or state.ChildBranchCounter,
				ChildrenRotationInfluence = state.BranchDirection == TreeConfigurations.Menum.Direction.Left and v10 or v10 * -1,
				Prev = state.MapIndex,
				Name = list2.Name,
				Icon = list2.Icon,
				IsBranch = list2.IsBranch,
				AdditionalOffset = list2.AdditionalOffset,
				RotationBias = list2.RotationBias,
				DisplayName = list2.DisplayName
			}
			addLockAndRequirements(v12, list2)
			mapIndex2 = v12.MapIndex
			v5[mapIndex2] = v12

			for _, v13 in ipairs(list2) do
				parse(v13, v12)
			end
		end
	end

	for _, v8 in ipairs(list) do
		parse(v8, v5[1])
	end

	return v5
end

return function(maid, _)
	local branches = SkillTreeholder.GetBranches()
	local branches2 = {}
	local count = 0
	local v5 = {}

	for _, branch in ipairs(branches) do
		table.insert(branches2, branch)

		if branch.IsBranch ~= nil then
			count += 1
		end

		if not (TreeConfigurations.Settings.MaxBranchesPerPage <= count) then
			continue
		end

		local v6 = {
			Map = buildLeafMap(branches2),
			Name = 0,
			Roots = 0
		}
		local pageName = buildPageName(branches2) -- equivalent call inferred; original call site unknown
		v6.Name = pageName
		v6.Roots = rootNames(branches2)
		table.insert(v5, v6)
		branches2 = {}
		count = 0
	end

	if #branches2 > 0 then
		local v6 = {
			Map = buildLeafMap(branches2),
			Name = 0,
			Roots = 0
		}
		local pageName = buildPageName(branches2) -- equivalent call inferred; original call site unknown
		v6.Name = pageName
		v6.Roots = rootNames(branches2)
		table.insert(v5, v6)
	end

	if #v5 == 0 then
		table.insert(v5, {
			Map = buildLeafMap({}),
			Name = "",
			Roots = {}
		})
	end

	for i, v6 in ipairs(v5) do
		v6.Index = i
	end

	local v6 = math.clamp(v4, 1, #v5)
	local value = maid:Value(v6)
	local value2 = maid:Value(v5[v6].Map)
	local roots = {}

	for _, v7 in ipairs(v5) do
		for _, root in ipairs(v7.Roots) do
			if table.find(roots, root) == nil then
				table.insert(roots, root)
			end
		end
	end

	local value3 = maid:Value(v5)

	local function updateVisiblePages()
		local v7 = not (#v5 > 1) and "" or string.lower(rootSearchbar.Value)
		local v8 = {}

		for _, v9 in ipairs(v5) do
			local v10 = v7 == ""

			if not v10 then
				for _, root in ipairs(v9.Roots) do
					if string.sub(string.lower(root), 1, #v7) ~= v7 then
						continue
					end

					v10 = true
					break
				end
			end

			if v10 then
				table.insert(v8, v9)
			end
		end

		value3:Set(v8)

		if #v8 > 0 then
			local v9 = false

			for _, v11 in ipairs(v8) do
				if v11.Index ~= value:Get() then
					continue
				end

				v9 = true
				break
			end

			if not v9 then
				value:Set(v8[1].Index)
			end
		end
	end

	maid:Connect(rootSearchbar:GetPropertyChangedSignal("Value"), updateVisiblePages)
	updateVisiblePages()
	local v7 = nil

	if v3 ~= nil then
		local v8 = mapIndex and v5[v6].Map[mapIndex]

		if v8 and v8.Name == v3 then
			v7 = v8
		else
			for _, v10 in pairs(v5[v6].Map) do
				if v10.Name ~= v3 then
					continue
				end

				v7 = v10
				break
			end
		end
	end

	local value4 = maid:Value()

	if v7 ~= nil then
		value4:Set(v7)
	end

	local value5 = maid:Value(0)
	local v8 = {
		lowestX = nil,
		highestX = nil,
		lowestY = nil,
		highestY = nil
	}
	local v9 = maid:Add(uidragger.new())
	local mainSpace = MainSpace(maid, value4)
	mainSpace:Connect(data.MasteryProgressionList.ChildAdded)
	mainSpace:Connect(value4.Changed)
	local skillTreeUnlockedList = data:FindFirstChild("SkillTreeUnlockedList")

	if skillTreeUnlockedList then
		local function refreshUnlockStates()
			local v11 = false

			for _, v12 in ipairs(v5) do
				for _, v13 in pairs(v12.Map) do
					if not v13.ComputedLock then
						continue
					end

					local requirements, v14 = Stats.GetRequirements(
						localPlayer,
						v13.Name,
						v13.PositionInBranch or v13.Index
					)
					local locked = not v14
					v11 = locked ~= v13.Locked or v11
					v13.Locked = locked
					v13.Requirements = requirements
				end
			end

			if not maid.IsActive then
				return
			end

			if v11 then
				mainSpace:Call()
			end

			if value4:Get() ~= nil then
				value5:Set(value5:Get() + 1)
			end
		end

		maid:Connect(skillTreeUnlockedList.ChildAdded, function(valueBase)
			refreshUnlockStates()

			if valueBase:IsA("ValueBase") then
				maid:Connect(valueBase.Changed, refreshUnlockStates)
			end
		end)
		maid:Connect(skillTreeUnlockedList.ChildRemoved, refreshUnlockStates)

		for _, valueBase in skillTreeUnlockedList:GetChildren() do
			if valueBase:IsA("ValueBase") then
				maid:Connect(valueBase.Changed, refreshUnlockStates)
			end
		end
	end

	local value6 = maid:Value(uDim)
	local v11 = nil
	local viewportSize = currentCamera.ViewportSize
	local value7 = maid:Value(v2)
	local v12 = nil

	local function UpdateDrag(p, _)
		if v11 == nil then
			v11 = {
				X = p.X,
				Y = p.Y
			}
		end

		local v13 = p.X - v11.X
		local v14 = p.Y - v11.Y
		v11.X = p.X
		v11.Y = p.Y
		local v15 = v13 / viewportSize.X
		local v16 = v14 / viewportSize.Y

		if v8.lowestX ~= nil and v8.highestX ~= nil and v8.lowestY ~= nil and v8.highestY ~= nil and v12 ~= nil and v9.UI ~= nil then
			local absoluteSize = v12.Parent.AbsoluteSize
			local absoluteSize2 = v12.AbsoluteSize

			if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
				return
			end

			local v17 = absoluteSize2.X / absoluteSize.X
			local v18 = absoluteSize2.Y / absoluteSize.Y
			local v19 = value6:Get()
			local v20 = v19.X.Scale + (v8.lowestX - 0.5) * v17
			local v21 = v19.X.Scale + (v8.highestX - 0.5) * v17
			local v22 = v19.Y.Scale + (v8.lowestY - 0.5) * v18
			local v23 = v19.Y.Scale + (v8.highestY - 0.5) * v18
			v15 = v15 > 0 and v20 + v15 > 1 and 0 or v15 < 0 and v21 + v15 < 0 and 0 or v15

			if v16 > 0 and v22 + v16 > 1 then
				v16 = 0
			elseif v16 < 0 and v23 + v16 < 0 then
				v16 = 0
			end
		end

		value6 += UDim2.fromScale(v15, v16)
		uDim = value6:Get()
	end

	v9.Ended:Connect(UpdateDrag)
	v9.Changed:Connect(UpdateDrag)

	local function ClampPosition(p: number, p2: number)
		if v8.lowestX == nil or v8.highestX == nil or v8.lowestY == nil or v8.highestY == nil then
			return
		end

		local v13 = value6:Get()
		local v14 = v13.X.Scale + (v8.lowestX - 0.5) * p
		local v15 = v13.X.Scale + (v8.highestX - 0.5) * p
		local v16 = v13.Y.Scale + (v8.lowestY - 0.5) * p2
		local v17 = v13.Y.Scale + (v8.highestY - 0.5) * p2
		local scale = v13.X.Scale
		local scale2 = v13.Y.Scale

		if v14 > 1 then
			scale -= v14 - 1
		elseif v15 < 0 then
			scale -= v15
		end

		if v16 > 1 then
			scale2 -= v16 - 1
		elseif v17 < 0 then
			scale2 -= v17
		end

		if scale ~= v13.X.Scale or scale2 ~= v13.Y.Scale then
			local uDim4 = UDim2.fromScale(scale, scale2)
			value6:Set(uDim4)
			uDim = uDim4
		end
	end

	local value8 = maid:Value()
	maid:Reactive(function(callback)
		local v13 = (callback(value7) + 0.2) * 2
		local v14 = value8:Get()
		local scale = v14 and v14.X.Scale or 0

		if scale > 0 and scale ~= v13 then
			local v15 = value6:Get()
			local v16 = v13 / scale
			local uDim4 = UDim2.fromScale(0.5 - (0.5 - v15.X.Scale) * v16, 0.5 - (0.5 - v15.Y.Scale) * v16)
			value6:Set(uDim4)
			uDim = uDim4
		end

		value8:Set(UDim2.fromScale(v13, v13))
		ClampPosition(v13, v13)
	end)
	local value9 = maid:Value(v7 ~= nil and UDim2.fromScale(0.38, 0.45) or UDim2.fromScale(0.5, 0.45))
	local flag = true
	maid:Reactive(function(callback)
		local v13 = callback(value4)

		if v13 == nil then
			if flag then
				flag = false
			else
				value9:Reset()
			end
		else
			flag = false
			value9:Set(UDim2.fromScale(0.38, 0.45))
			local position = v13.Position

			if position == nil then
				return
			end

			local v14 = (value7:Get() + 0.2) * 2
			local v15 = 0.5 - (position.X.Scale - 0.5) * v14
			local v16 = 0.5 - (position.Y.Scale - 0.5) * v14
			value6:Set(UDim2.fromScale(v15, v16))
			uDim = UDim2.fromScale(v15, v16)
			ClampPosition(v14, v14)
		end
	end)
	maid:Connect(value4.Changed, function(p)
		local v13

		if p then
			v13 = p.Name or nil
		end

		v3 = v13
		mapIndex = p and p.MapIndex or nil
	end)
	maid:Connect(value.Changed, function(p)
		v4 = p
	end)
	local flag2 = true
	local value10 = maid:Value(UDim2.fromScale(1, 0.9))
	maid:Reactive(function(callback)
		value2:Set((v5[callback(value)] or v5[1]).Map)

		if flag2 then
			flag2 = false
		else
			value4:Reset()
		end

		value10:Refresh()
	end)
	local v13 = false
	local v14 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setZoom(value11: number)
		local v15 = math.clamp(value11, 0, 1)
		value7:Set(v15)
		v2 = v15
	end

	maid:Add(InputHandler.ListenTo("Zoom_In", function(p: string)
		v13 = p == "Down"
	end))
	maid:Add(InputHandler.ListenTo("Zoom_Out", function(p: string)
		v14 = p == "Down"
	end))
	maid:Add(InputHandler.Pinched(function(p: string, p2: number)
		if p ~= "Changed" or p2 <= 0 then
			return
		end

		setZoom(value7:Get() * p2) -- equivalent call inferred; original call site unknown
	end))
	maid:Connect(RunService.RenderStepped, function(p: number)
		local v15 = (v13 and 1 or 0) - (v14 and 1 or 0)

		if v15 == 0 then
			return
		end

		setZoom(value7:Get() + v15 * 0.6 * p) -- equivalent call inferred; original call site unknown
	end)
	local v15 = 1
	local v17 = maid:Create("Frame")({
		Name = "Skill Tree Holder",
		Size = maid:Animation(value10, info, {
			AlwaysFrom = UDim2.fromScale(0.9, 0.81)
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		maid:Create("UIAspectRatioConstraint")({
			AspectRatio = TreeConfigurations.Settings.AspectRatio
		}),
		maid:Create("TextButton")({
			Name = "Button",
			Size = UDim2.fromScale(1.8, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			function(parent)
				local frame = Instance.new("Frame")
				frame.Name = "NoSelection"
				frame.BackgroundTransparency = 1
				frame.Size = UDim2.new()
				frame.Parent = parent
				parent.SelectionImageObject = frame
			end,
			MouseButton1Down = function(UI)
				viewportSize = currentCamera.ViewportSize

				if v9.UI == nil then
					v9.UI = UI
				end

				v11 = nil
				UpdateDrag(v9:Start())
			end,
			InputChanged = function(_, p)
				if p.UserInputType == Enum.UserInputType.MouseWheel then
					setZoom(value7:Get() + p.Position.Z * 0.01 * v15) -- equivalent call inferred; original call site unknown
					v15 += 1
					task.delay(0.3, function()
						if maid.IsActive then
							v15 -= 1
						end
					end)
				end
			end
		}),
		maid:Create("Frame")({
			Name = "Holder",
			Position = maid:Lerp(value6, TreeConfigurations.Settings.lerpfactor),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = maid:Lerp(value8, TreeConfigurations.Settings.lerpfactor),
			BackgroundTransparency = 1,
			function(p)
				v12 = p
				return { maid:Create("Frame")({
						Size = UDim2.fromScale(
							TreeConfigurations.Settings.LeafRadius,
							TreeConfigurations.Settings.LeafRadius
						),
						Instance.new("UIAspectRatioConstraint"),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ZIndex = 2,
						BackgroundTransparency = 1,
						function(UI)
							for _, v18 in ipairs(v5) do
								v18.Map[1].UI = UI
								v18.Map[1].Position = UI.Position
							end
						end,
						function()
							return maid:Create("Frame")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								maid:Create("ImageLabel")({
									Size = UDim2.fromScale(0.9, 0.9),
									BackgroundTransparency = 1,
									Image = "rbxassetid://16873598266",
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									maid:Create("UIGradient")({
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0.7),
											NumberSequenceKeypoint.new(1, 1)
										})
									})
								}),
								maid:Create("ViewportFrame")({
									ZIndex = 2,
									BorderColor3 = Color3.new(),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431),
									ImageTransparency = 0,
									function(parent)
										local worldModel = Instance.new("WorldModel", parent)
										local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
										clone.Parent = worldModel
										clone.HumanoidRootPart.Anchored = true
										local camera = Instance.new("Camera")
										camera.Parent = parent
										parent.CurrentCamera = camera
										local v18 = clone.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2).Position
										local position = clone.HumanoidRootPart.Position
										local humanIdle = game.ReplicatedStorage.Assets.Animations.mainPlace.humanIdle

										if data.Race.Value == "Demon" then
											camera.CFrame = CFrame.new(v18, position) + createVector(0, 1.5, 0)
											humanIdle = game.ReplicatedStorage.Assets.Animations.mainPlace.demonIdle
										else
											camera.CFrame = CFrame.new(v18, position) + createVector(0, 1.25, 0)
										end

										clone.Humanoid.Animator:LoadAnimation(humanIdle):Play(0)
										Load_Custom(localPlayer, clone, data, true)
									end,
									Size = UDim2.fromScale(0.9, 0.9),
									maid:Create("UICorner")({
										CornerRadius = UDim.new(1)
									})
								}),
								maid:Create("UIStroke")({
									Color = Color3.new(1, 1, 1),
									Thickness = 2,
									Transparency = 0
								}),
								maid:Create("UIStroke")({
									BorderOffset = UDim.new(0.1),
									Color = Color3.new(1, 1, 1),
									Thickness = 2,
									Transparency = 0.85
								}),
								maid:Create("UICorner")({
									CornerRadius = UDim.new(1)
								})
							})
						end
					}), maid:State(function(callback, object)
						local v18 = callback(value2)
						v8 = {
							lowestX = 0.5,
							highestX = 0.5,
							lowestY = 0.5,
							highestY = 0.5
						}

						for _, v19 in pairs(v18) do
							if typeof(v19) == "table" and v19.MapIndex ~= 1 then
								v19.PosAbs = nil
							end
						end

						task.defer(function()
							if not maid.IsActive then
								return
							end

							local v19 = value8:Get()

							if v19 then
								ClampPosition(v19.X.Scale, v19.Y.Scale)
							end
						end)
						return object:Create("Frame")({
							Name = "Free",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							function()
								for _, v19 in pairs(v18) do
									if v19.Type == TreeConfigurations.Menum.Type.Branch then
										v19.RenderChildCounter = 0
									end
								end
							end,
							object:Iterate(v18, function(_, state, object2, p2)
								if state.MapIndex == 1 then
									return
								end

								local position = nil

								if state.Ref == nil then
									position = state.Position
								else
									local v19 = v18[state.Ref]

									if v19.Type == TreeConfigurations.Menum.Type.Root then
										local rotation = state.Rotation
										position = v19.Position + UDim2.fromScale(
											math.cos(rotation) * v,
											math.sin(rotation) * v
										)
									elseif v19.Type == TreeConfigurations.Menum.Type.Branch then
										local rotation = state.Rotation
										position = v19.Position + UDim2.fromScale(
											math.cos(rotation) * v * state.Index * 1 / TreeConfigurations.Settings.AspectRatio,
											math.sin(rotation) * v * state.Index
										)
									end
								end

								local v19 = state.Prev and v18[state.Prev]
								return object2:Create("Frame")({
									Size = UDim2.fromScale(
										TreeConfigurations.Settings.LeafRadius,
										TreeConfigurations.Settings.LeafRadius
									),
									Instance.new("UIAspectRatioConstraint"),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = position,
									ZIndex = 2,
									BackgroundTransparency = 1,
									function(UI)
										state.Position = UI.Position
										state.UI = UI
									end,
									function(_)
										if v8.lowestX == nil or position.X.Scale < v8.lowestX then
											v8.lowestX = position.X.Scale
										end

										if v8.highestX == nil or position.X.Scale > v8.highestX then
											v8.highestX = position.X.Scale
										end

										if v8.lowestY == nil or position.Y.Scale < v8.lowestY then
											v8.lowestY = position.Y.Scale
										end

										if v8.highestY == nil or position.Y.Scale > v8.highestY then
											v8.highestY = position.Y.Scale
										end

										return Node(mainSpace, p2, object2, state, v19, value4)
									end
								})
							end)
						})
					end) }
			end
		})
	})
	local pageBrowser = PageBrowser(maid, value, value3, {
		ToggleOff = 1,
		Keybinds = false,
		Overflow = true,
		Size = uDim3,
		Position = uDim2,
		Key = function(_, p)
			return p.Index
		end
	})
	local v19

	if #v5 > 1 then
		v19 = maid:Create("Frame")({
			Name = "RootSearchbarHolder",
			Size = UDim2.fromScale(0.2, 0.04),
			Position = UDim2.new(0.1, -7, 0.08, 0),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			(Searchbar(maid, roots, rootSearchbar, "Root name here!"))
		}) or nil
	end

	return {
		v17,
		pageBrowser,
		v19,
		maid:Create("Frame")({
			Name = "Footer",
			ZIndex = 2,
			Size = UDim2.fromScale(1.3, 0.2),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1.005),
			BackgroundColor3 = Color3.new(0.125, 0.125, 0.125),
			maid:Create("Frame")({
				Name = "DefaultCenter",
				Size = UDim2.fromScale(0.25, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = maid:Lerp(value9, TreeConfigurations.Settings.lerpfactor),
				BackgroundTransparency = 1,
				maid:Create("Frame")({
					Name = "ZoomSlider",
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromScale(0.25, 0.15),
					ZIndex = 2,
					BackgroundTransparency = 1,
					SkillTreeZoomSlider(maid, value7)
				}),
				maid:Create("Frame")({
					Name = "SkillPointHolder",
					Size = UDim2.fromScale(0.5, 0.5),
					Instance.new("UIAspectRatioConstraint"),
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 0.9),
					ZIndex = 2,
					BackgroundTransparency = 1,
					SkillPoints(maid, data)
				})
			}),
			maid:State(function(callback, p)
				callback(value5)
				local v20 = callback(value4)

				if v20 == nil then
					return
				end

				if v20.ComputedLock then
					local requirements, v21 = Stats.GetRequirements(
						localPlayer,
						v20.Name,
						v20.PositionInBranch or v20.Index
					)
					v20.Locked = not v21
					v20.Requirements = requirements
				end

				return CenterEquipped(p, v20, value2:Get()[v20.Prev], value4)
			end),
			maid:Create("UIGradient")({
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.2, 0.1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	}
end