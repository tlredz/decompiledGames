local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MasteryItem = require(script.MasteryItem)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local GetMasteryStatus = require(ReplicatedStorage.CAM.Global.SkillService.GetMasteryStatus)
local ToolbarItemRestrictions = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ToolbarItemRestrictions)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
require(ReplicatedStorage.Packages.faye)
local SlotDragger = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.SlotDragger)
local SlotNumber = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.Mobile.SlotNumber)
local vector = Vector2.new(0.93, 0.93)
local bottomHudLift = gameSettings.BottomHudLift
local padHintRaise = gameSettings.PadHintRaise

local function CycleHint(maid, name: string, point: Vector2)
	return Utility.AddTag(maid:Create("Frame")({
		Name = name,
		AnchorPoint = point,
		Position = UDim2.fromScale(point.X, point.Y),
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1
	}), "UIkey")
end

local parent = localPlayer:FindFirstChild("Items_Config")

if parent == nil then
	parent = Instance.new("Folder")
	local intValue = Instance.new("IntValue")
	intValue.Parent = parent
	intValue.Name = "Equipped"
	parent.Name = "Items_Config"
	parent.Parent = localPlayer
end

local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
parent.Equipped.Changed:Connect(function()
	SignalEvent.ToServer("Item_Equip", parent.Equipped.Value)
end)
local v2 = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five"
}
local v3 = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5
}
local v4 = {
	"Toolbar_1st",
	"Toolbar_2nd",
	"Toolbar_3rd",
	"Toolbar_4th",
	"Toolbar_5th"
}
local data = Utility.GetData(localPlayer, true)
local Tool = require(script.Tool)
local toolScripts = ReplicatedStorage.ToolScripts
local modules = {}

local function getToolScript(name: string)
	if modules[name] ~= nil then
		return modules[name] or nil
	end

	local item = Items[name]
	local toolScript

	if item then
		toolScript = item.ToolScript or name
	else
		toolScript = name
	end

	local child = toolScripts:FindFirstChild(toolScript)
	local child2 = child and child:FindFirstChild(toolScript)
	modules[name] = child2 and require(child2) or false
	return modules[name] or nil
end

local v5 = {}

local function hasServerToolScript(p: string)
	if v5[p] ~= nil then
		return v5[p]
	end

	local item = Items[p]
	local toolScript

	if item then
		toolScript = item.ToolScript or p
	else
		toolScript = p
	end

	local child = toolScripts:FindFirstChild(toolScript)
	v5[p] = child ~= nil and child:FindFirstChild(toolScript .. "Server") ~= nil
	return v5[p]
end

local track = nil
local v6 = 0
return function(maid, parent2, target, p3, p4)
	local dragEnabled

	if p4 == nil then
		dragEnabled = nil
	else
		dragEnabled = p4.DragEnabled
	end

	local visible = maid:Value(Platform_Handler.Platform.Value ~= "Mobile")
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		visible:Set(Platform_Handler.Platform.Value ~= "Mobile")
	end)
	local value2 = maid:Value(GetMasteryStatus.GetMasteries())
	maid:Connect(GetMasteryStatus.Changed, function(p5)
		value2:Set(p5)
	end)
	local v7 = {}

	for i = 1, 5 do
		v7[i] = {
			Key = v2[i],
			Id = maid:Value(0),
			Restrictions = maid:Value({})
		}
	end

	for k, currentRestriction in ToolbarItemRestrictions.CurrentRestrictions do
		-- equivalent calls inferred from this helper; original call sites unknown
		local v9 = currentRestriction
		local v10 = v3[k]

		local function updateRestriction()
			if v9.Restrictions.Locked and parent.Equipped.Value == v10 then
				parent.Equipped.Value = 0
			end

			v7[v10].Restrictions:Set(v9.Restrictions)
		end

		updateRestriction() -- equivalent call inferred; original call site unknown
		maid:Connect(currentRestriction.Changed, updateRestriction)
	end

	local function updToolbarEquips()
		for i = 1, 5 do
			v7[i].Id:Set(data.Inventory.Toolbar[v2[i]].Value)
		end
	end

	updToolbarEquips()

	for _, child in pairs(data.Inventory.Toolbar:GetChildren()) do
		maid:Connect(child.Changed, updToolbarEquips)
	end

	local v8 = nil
	local name = nil
	local v9 = false
	local flag = false
	local changedConnection = nil
	local value3 = parent.Equipped.Value
	local v10 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopIdleAnim()
		if track then
			track:Stop()
			track = nil
		end

		v6 = math.random()
	end

	local onEquipChanged

	onEquipChanged = function()
		local value4 = parent.Equipped.Value
		local v11 = v10
		v10 = false

		if value4 > 0 and not v11 then
			local item = Character_info_provider.GetItemFromId(localPlayer, data.Inventory.Toolbar[v2[value4]].Value)
			local v12 = item and getToolScript(item.Name)

			if name ~= nil and item and item.Name == name and v12 == v8 then
				value3 = value4
				return
			end

			if item ~= nil and not ItemRequirements.SatisfiesEquip(data, item.Name) then
				parent.Equipped.Value = value3 == value4 and 0 or value3
				return
			end

			if v12 and v12.check then
				local success, result = pcall(v12.check, localPlayer.Character, item.Name)

				if success and result == false then
					parent.Equipped.Value = value3 == value4 and 0 or value3
					return
				end
			end
		end

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if flag then
			flag = false

			if v8 and v8.MouseUp then
				task.spawn(v8.MouseUp, localPlayer.Character, name)
			end

			if v9 then
				SignalEvent.ToServer("Tool_Mouse", "Up", Platform_Handler.mousepos(nil, v8 and v8.MouseParams))
			end
		end

		if v8 and v8.UnEquipped then
			task.spawn(v8.UnEquipped, localPlayer.Character, name)
		end

		v8 = nil
		name = nil
		v9 = false
		stopIdleAnim() -- equivalent call inferred; original call site unknown

		if value4 > 0 then
			local item = Character_info_provider.GetItemFromId(localPlayer, data.Inventory.Toolbar[v2[value4]].Value)

			if item then
				local toolScript = getToolScript(item.Name)
				local name2 = item.Name

				if v5[name2] == nil then
					local item2 = Items[name2]
					local toolScript2

					if item2 then
						toolScript2 = item2.ToolScript or name2
					else
						toolScript2 = name2
					end

					local child = toolScripts:FindFirstChild(toolScript2)
					v5[name2] = child ~= nil and child:FindFirstChild(toolScript2 .. "Server") ~= nil
				end

				local v12 = v5[name2]

				if toolScript or v12 then
					v8 = toolScript
					name = item.Name
					v9 = v12

					if toolScript and toolScript.Equipped then
						task.spawn(toolScript.Equipped, localPlayer.Character, item.Name)
					end
				end

				local item2 = Items[item.Name]

				if item2 and not item2.HasCombat and not item2.NoToolIdle and (toolScript ~= nil or item2.UseIdle == true) then
					local child = toolScripts:FindFirstChild(item2.ToolScript or item.Name)
					local toolIdleAnimation = child ~= nil and child:FindFirstChild("ToolIdleAnimation") or Character_info_provider.get_core_anim(
						localPlayer,
						"toolidle"
					)

					if toolIdleAnimation then
						local v13 = math.random()
						v6 = v13
						task.spawn(function()
							local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

							if v6 ~= v13 then
								return
							end

							local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild(
								"Humanoid",
								5
							)

							if humanoid == nil or v6 ~= v13 then
								return
							end

							local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild(
								"Animator",
								5
							)

							if animator == nil or v6 ~= v13 then
								return
							end

							track = animator:LoadAnimation(toolIdleAnimation)
							track:Play()

							for _ = 1, 5 do
								task.wait(0.075)

								if v6 ~= v13 then
									break
								end

								if not (track == nil or not track.IsPlaying) then
									continue
								end

								onEquipChanged()
								break
							end
						end)
					end
				end
			end

			local v12 = data.Inventory.Toolbar[v2[value4]]

			if v12 then
				changedConnection = v12.Changed:Connect(function(_)
					SignalEvent.ToServer("Item_Equip", parent.Equipped.Value)
					onEquipChanged()
				end)
			end
		end

		value3 = value4
	end

	maid:Connect(parent.Equipped.Changed, onEquipChanged)
	onEquipChanged()

	if parent.Equipped.Value > 0 then
		SignalEvent.ToServer("Item_Equip", parent.Equipped.Value)
	end

	maid:Connect(localPlayer.CharacterRemoving, function()
		if v8 and v8.UnEquipped then
			v8.UnEquipped()
		end

		v8 = nil
		name = nil
		v9 = false
		stopIdleAnim() -- equivalent call inferred; original call site unknown
	end)
	maid:Add(InputHandler.ScreenClicked(function(p5, p6)
		if p5 == "Down" then
			if not p6 and name ~= nil then
				flag = true

				if v8 and v8.MouseDown then
					task.spawn(v8.MouseDown, localPlayer.Character, name)
				end

				if v9 then
					SignalEvent.ToServer("Tool_Mouse", "Down", Platform_Handler.mousepos(nil, v8 and v8.MouseParams))
				end
			end
		elseif p5 == "Up" and flag then
			flag = false

			if v8 and v8.MouseUp then
				task.spawn(v8.MouseUp, localPlayer.Character, name)
			end

			if v9 then
				SignalEvent.ToServer("Tool_Mouse", "Up", Platform_Handler.mousepos(nil, v8 and v8.MouseParams))
			end
		end
	end), true)

	for i = 1, 5 do
		local v11 = i
		maid:Add(InputHandler.ListenTo(v4[i], function(p5, p6)
			if p5 ~= "Down" or p6 then
				return
			end

			local v12 = v7[v11].Restrictions:Get()

			if not (v12.Locked or v12.ActionsDisabled) then
				if parent.Equipped.Value == v11 then
					parent.Equipped.Value = 0
				else
					parent.Equipped.Value = v11
				end
			end
		end), true)
	end

	local slotDragger = SlotDragger(maid, {
		Target = target,
		Backdrop = function(object)
			return object:Create("ImageLabel")({
				Name = "Bg",
				ZIndex = -1,
				Image = "http://www.roblox.com/asset/?id=134657809787110",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(2.75, 2.75),
				BackgroundTransparency = 1,
				ImageColor3 = Color3.new(0.15, 0.15, 0.15)
			})
		end,
		OnDrop = function(p5: string, p6: string)
			if v7[v3[p6]].Restrictions:Get().ActionsDisabled or Checker.DenyLoadoutChange(localPlayer) then
				return
			end

			local value4 = data.Inventory.Toolbar[p5].Value
			local value5 = data.Inventory.Toolbar[p6].Value
			data.Inventory.Toolbar[p6].Value = value4
			data.Inventory.Toolbar[p5].Value = value5
			SignalEvent.ToServer("Toolbar_Equip", p6, value4, p5)
		end
	})
	local space = maid:Space(function(state, p5, object, object2, object3, object4, object5, object6, object7, object8, object9)
		local lastId = parent.Equipped.Value
		local v12 = p5.Restrictions:Get()

		if lastId ~= state.LastId or not slotDragger.Dragging:Compare(state.LastDrag) or not slotDragger.Hover:Compare(state.LastHover) or v12.Locked ~= state.LastLocked then
			local lastDrag = slotDragger.Dragging:Get()
			local lastHover = slotDragger.Hover:Get()
			local locked = v12.Locked
			local state2

			if lastDrag ~= state.Key and lastHover == state.Key and lastDrag ~= nil then
				state2 = 4
			elseif lastDrag == state.Key then
				state2 = 3
			elseif locked then
				state2 = 5
			elseif lastId == state.Index then
				state2 = 1
			else
				state2 = 2
			end

			if state2 ~= state.State then
				if state2 == 1 then
					object3:Set(UDim2.fromScale(1.15, 1.15))
					object4:Set(0.75)
					object2:Set(0.65)
					object:Set(Color3.new(1, 1, 1))
					object6:Reset()
					object7:Reset()
					object8:Reset()
				elseif state2 == 3 then
					object8:Reset()
					object3:Reset()
					object4:Reset()
					object2:Reset(0.5)
					object:Reset()
					object6:Set(1)
					object7:Set(0.7)
				elseif state2 == 4 then
					object:Set(Color3.new(1, 1, 1))
					object2:Set(0.75)
					object3:Set(UDim2.fromScale(1.15, 1.15))
					object4:Set(0)
					object6:Set(1)
					object7:Set(0.7)
					object8:Reset()
				else
					if state2 == 5 then
						object3:Reset()
						object8:Set(0.2)
						object4:Reset()
						object2:Reset()
						object:Reset()
						object6:Set(0.75)
					elseif state2 == 6 then
						object3:Reset()
						object8:Set(0.2)
						object4:Reset()
						object2:Reset()
						object:Reset()
						object6:Set(0.75)
					else
						object8:Reset()
						object3:Reset()
						object4:Reset()
						object2:Reset()
						object:Reset()
						object6:Reset()
					end

					object7:Reset()
				end

				state.State = state2
			end

			state.LastLocked = locked
			state.LastId = lastId
			state.LastDrag = lastDrag
			state.LastHover = lastHover
		end

		if v12.Locked then
			object9:Set(ToolbarItemRestrictions.Inventory.Locked.Icon)
		elseif v12.NoSave then
			object9:Set(ToolbarItemRestrictions.Inventory.NoSave.Icon)
			object8:Set(gameSettings.noSaveOverlayTransparency)
		else
			object8:Reset()
		end

		if not p5.Id:Compare(state.LastTool) or state.LastToolIsStyle == true then
			local v13 = p5.Id:Get()
			local item = Character_info_provider.GetItemFromId(localPlayer, v13)
			state.LastToolIsStyle = false
			local v14

			if item == nil then
				v14 = ""
			else
				v14 = ItemIcon.For(localPlayer, item.Name)
				state.LastToolIsStyle = item.Name == FightingStyles.TOOL_NAME
			end

			object5:Set(v14)
			state.LastTool = p5.Id:Get()
		end
	end)
	space:Connect(parent.Equipped.Changed)
	space:Connect(slotDragger.Dragging.Changed)
	space:Connect(slotDragger.Hover.Changed)

	for _, v12 in ipairs(v7) do
		space:Connect(v12.Restrictions.Changed)
		space:Connect(v12.Id.Changed)
	end

	local function pokeStylePresenter()
		space:Call()
	end

	maid:Connect(data.Powers.FightingStyle.Changed, pokeStylePresenter)
	maid:Connect(data.Race.Changed, pokeStylePresenter)

	if p3 == nil then
		local function canEquip(p5: number)
			local value4 = data.Inventory.Toolbar[v2[p5]].Value

			if value4 == 0 then
				return false
			end

			local v12 = v7[p5].Restrictions:Get()

			if v12.Locked or v12.ActionsDisabled then
				return false
			end

			local item = Character_info_provider.GetItemFromId(localPlayer, value4)

			if not (item ~= nil and ItemRequirements.SatisfiesEquip(data, item.Name)) then
				return false
			end

			local toolScript = getToolScript(item.Name)

			if toolScript and toolScript.check then
				local success, result = pcall(toolScript.check, localPlayer.Character, item.Name)

				if success and result == false then
					return false
				end
			end

			return true
		end

		local function cycle(p5: number)
			local value4 = parent.Equipped.Value

			for i = 1, #v2 do
				local v12 = (value4 - 1 + p5 * i) % #v2 + 1

				if value4 == 0 then
					v12 = (p5 > 0 and i - 1 or #v2 - i) % #v2 + 1
				end

				if not canEquip(v12) then
					continue
				end

				parent.Equipped.Value = v12
				break
			end
		end

		maid:Add(InputHandler.ListenTo("Toolbar_Prev", function(p5, p6)
			if p5 == "Down" and not p6 then
				cycle(-1)
			end
		end), true)
		maid:Add(InputHandler.ListenTo("Toolbar_Next", function(p5, p6)
			if p5 == "Down" and not p6 then
				cycle(1)
			end
		end), true)
		local value4 = maid:Value(0)
		local visible2 = maid:Value(Platform_Handler.IsGamepad())
		maid:Connect(Platform_Handler.Platform.Changed.Event, function()
			visible2:Set(Platform_Handler.IsGamepad())
		end)
		return maid:Create("Frame")({
			Name = "Toolbar",
			Visible = visible,
			Size = UDim2.fromScale(0.4, 0.4),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -gameSettings.BottomHudLift),
			Parent = parent2,
			BackgroundTransparency = 1,
			maid:Create("UIAspectRatioConstraint")({}),
			maid:Create("Frame")({
				Name = "Cycle",
				Visible = visible2,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 1, -padHintRaise),
				Size = maid:Do(function(callback)
					return UDim2.new(0, callback(value4), 0, bottomHudLift)
				end),
				BackgroundTransparency = 1,
				CycleHint(maid, "Toolbar_Prev", Vector2.new(0, 0.5)),
				CycleHint(maid, "Toolbar_Next", Vector2.new(1, 0.5))
			}),
			maid:Create("Frame")({
				Name = "SkillHolder",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				maid:Create("UIListLayout")({
					Name = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.15, 0),
					[maid:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p5)
						value4:Set(p5.AbsoluteContentSize.X)
					end
				}),
				maid:Iterate(v7, function(p5, p6, p7)
					return Tool(p7, p5, p6, parent.Equipped, space, slotDragger, dragEnabled)
				end)
			}),
			After = function(_)
				return maid:Create("Frame")({
					Name = "MasteryHolder",
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ZIndex = -1,
					Size = UDim2.fromScale(6, 1),
					BackgroundTransparency = 1,
					maid:Create("Frame")({
						Name = "Actual",
						Size = UDim2.fromScale(1, 0.7),
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(1.025, 0.85),
						BackgroundTransparency = 1,
						maid:Create("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, 5)
						}),
						maid:State(function(callback, p5, _)
							local v20 = callback(value2)

							if v20 == nil then
								return
							end

							local result = {}

							for _, v21 in ipairs(v20) do
								table.insert(result, MasteryItem(p5, v21))
							end

							return result
						end)
					})
				})
			end
		})
	else
		for k, v12 in v7 do
			local parent3 = p3[v2[k]]

			if parent3 ~= nil then
				maid:Create("Frame")({
					Parent = parent3,
					Name = "Slot",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Tool(maid, k, v12, parent.Equipped, space, slotDragger, dragEnabled),
					SlotNumber(maid, k, vector)
				})
			end
		end
	end
end