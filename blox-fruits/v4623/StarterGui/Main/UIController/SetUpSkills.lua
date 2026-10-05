local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local BuildUtil = require(game.ReplicatedStorage.BuildUtil)
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local FruitSkills = require(game.ReplicatedStorage.FruitSkills)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local GamepadConversion = require(game.ReplicatedStorage:WaitForChild("GamepadConversion"))
local Global = require(game.ReplicatedStorage.Global)
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Fruit"):tag("UI"):display():traceback():build()
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()
local v2 = {
	["Blox Fruit"] = { Vector2.new(0, 0), Color3.fromRGB(235, 205, 255), Color3.fromRGB(205, 125, 255) },
	Gun = { Vector2.new(376, 0), Color3.fromRGB(255, 245, 205), Color3.fromRGB(255, 217, 65) },
	Melee = { Vector2.new(0, 376), Color3.fromRGB(255, 205, 205), Color3.fromRGB(255, 123, 123) },
	Sword = { Vector2.new(376, 376), Color3.fromRGB(221, 255, 205), Color3.fromRGB(141, 255, 92) }
}
local v3 = {}
local v4 = {}
local require2 = require

-- equivalent calls inferred from this helper; original call sites unknown
local function reflectInputTypeForSkill(clone)
	local visible = LastInput:Get() == "Gamepad"
	clone.Key.Visible = not visible
	clone.GamepadKey.Visible = visible
end

local function getToolData(playerGui, parent)
	local movesetModules = playerGui:WaitForChild("MovesetModules", 5)
	local child = movesetModules and movesetModules:WaitForChild(parent.Name, 5)
	local legacyDataAggregate = child and child:WaitForChild("LegacyDataAggregate", 5)

	if legacyDataAggregate and legacyDataAggregate:IsA("ModuleScript") then
		return require2(legacyDataAggregate)
	end

	return nil
end

local function cloneSkillRow(p)
	if type(p) == "table" then
		return table.clone(p)
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAwakenedMovesetName(value: string)
	return string.match(value, "%(Awakened%)$") ~= nil
end

local function normalizeMovesetEntry(p: string, value)
	if type(value) == "string" then
		return value, p
	end

	if type(value) ~= "table" then
		return nil, nil
	end

	local moveset = value.moveset or value.Moveset or value[1]
	local move = value.move or value.Move or value.key or value.Key or value[2] or p

	if type(moveset) == "string" and type(move) == "string" then
		return moveset, move
	end

	return nil, nil
end

local function getFruitSkillName(value: string, p: string)
	local awakenedMovesetName = isAwakenedMovesetName(value) -- equivalent call inferred; original call site unknown

	if awakenedMovesetName then
		value = string.gsub(value, " %(Awakened%)$", "")
	end

	local fruitSkill = FruitSkills[value]
	local v5 = fruitSkill and fruitSkill[awakenedMovesetName and 2 or 1]

	if type(v5) ~= "table" then
		return nil
	end

	for _, v6 in v5 do
		if v6[1] == p and type(v6[3]) == "string" then
			return v6[3]
		end
	end

	return nil
end

local function getToolMoveset(instance)
	local moveset = instance:FindFirstChild("Moveset")

	if not (moveset and moveset:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require2, moveset)

	if not success then
		warn((`failed to read Moveset for "{instance.Name}": {result}`))
		return nil
	end

	if type(result) == "table" then
		return result
	end

	warn((`bad Moveset module for "{instance.Name}"`))
	return nil
end

local function applyToolMovesetSkillNames(parent, clones)
	local toolMoveset = getToolMoveset(parent)

	if not toolMoveset then
		return
	end

	local awakened

	if type(toolMoveset.Awakened) == "table" then
		awakened = toolMoveset.Awakened
	end

	for _, fruitSkillNames in clones do
		local v5 = fruitSkillNames[1]

		if type(v5) ~= "string" then
			continue
		end

		local v6 = fruitSkillNames.Awakened and awakened and awakened[v5] ~= nil
		local v7

		if v6 then
			v7 = awakened[v5]
		else
			v7 = toolMoveset[v5]
		end

		local movesetEntry, v8 = normalizeMovesetEntry(v5, v7)

		if not (movesetEntry and v8) then
			continue
		end

		if fruitSkillNames.Awakened and not v6 and string.match(movesetEntry, "%(Awakened%)$") == nil then
			movesetEntry = `{movesetEntry} (Awakened)`
		end

		local fruitSkillName = getFruitSkillName(movesetEntry, v8)

		if fruitSkillName then
			fruitSkillNames[3] = fruitSkillName
		end
	end
end

local function applyStreamedBindingSkillNames(playerGui, parent, clones)
	local movesetModules = playerGui:FindFirstChild("MovesetModules")
	local child = movesetModules and movesetModules:FindFirstChild(parent.Name)
	local bindings = child and child:FindFirstChild("Bindings")

	if not bindings then
		return
	end

	local function nameFor(instance, p: string, flag: boolean)
		local attribute = instance:GetAttribute(flag and "AwakenedMoveset" or "Moveset")

		if type(attribute) ~= "string" then
			return nil
		end

		local attribute2 = instance:GetAttribute(flag and "AwakenedMove" or "Move")

		if type(attribute2) ~= "string" then
			attribute2 = p
		end

		return (getFruitSkillName(attribute, attribute2))
	end

	for _, item in clones do
		local v5 = item[1]

		if type(v5) ~= "string" then
			continue
		end

		local child2 = bindings:FindFirstChild(v5)

		if not child2 then
			continue
		end

		local v6, moveset, move

		if item.Awakened then
			local awakenedMoveset = child2:GetAttribute("AwakenedMoveset")

			if type(awakenedMoveset) == "string" then
				local awakenedMove = child2:GetAttribute("AwakenedMove")

				if type(awakenedMove) ~= "string" then
					awakenedMove = v5
				end

				v6 = getFruitSkillName(awakenedMoveset, awakenedMove)
			end

			if not v6 then
				moveset = child2:GetAttribute("Moveset")

				if type(moveset) == "string" then
					move = child2:GetAttribute("Move")

					if type(move) ~= "string" then
						move = v5
					end

					v6 = getFruitSkillName(moveset, move)
				else
					v6 = nil
				end
			end
		else
			moveset = child2:GetAttribute("Moveset")

			if type(moveset) == "string" then
				move = child2:GetAttribute("Move")

				if type(move) ~= "string" then
					move = v5
				end

				v6 = getFruitSkillName(moveset, move)
			end
		end

		if v6 then
			item[3] = v6
		end
	end
end

local function isCreationCreativeBuildMode(p, instance)
	local waitingITERATE = instance:GetAttribute("WaitingITERATE")
	local v5 = p.Value and not instance.Value

	if v5 then
		if typeof(waitingITERATE) == "Vector2" then
			return waitingITERATE.Y == 1
		else
			return false
		end
	end

	return v5
end

local function syncCreationBuildModeUi(playerGui, parent, clone)
	if parent.Name ~= "Creation-Creation" then
		return
	end

	local main = playerGui:FindFirstChild("Main")
	local skills = main and main:FindFirstChild("Skills")

	if not skills then
		return
	end

	local creationBuildMode = parent:FindFirstChild("CreationBuildMode") or skills:FindFirstChild("CreationBuildMode")
	local fortBuilderActive = parent:FindFirstChild("FortBuilderActive")
	local quickBuildMode = parent:FindFirstChild("QuickBuildMode")

	if not (creationBuildMode and creationBuildMode:IsA("GuiObject") and fortBuilderActive and fortBuilderActive:IsA("BoolValue") and quickBuildMode and quickBuildMode:IsA("BoolValue")) then
		return
	end

	local waitingITERATE = quickBuildMode:GetAttribute("WaitingITERATE")
	local v5 = fortBuilderActive.Value and not quickBuildMode.Value

	if v5 then
		if typeof(waitingITERATE) == "Vector2" then
			v5 = waitingITERATE.Y == 1
		else
			v5 = false
		end
	end

	if v5 then
		clone.Visible = false
		creationBuildMode.Parent = skills
		creationBuildMode.Visible = true
	else
		clone.Visible = true
		creationBuildMode.Parent = parent
	end
end

function StarsUntilLevel(p, p2, p3, p4)
	local v5 = p3 > 600 and 600 or p3

	if v5 <= p then
		return 0
	end

	local v6 = math.pow(p4, 1.1) * 20
	local v7 = v6 % 100
	local v8

	if v7 >= 50 then
		v8 = v6 + (100 - v7)
	else
		v8 = v6 - v7
	end

	local CollectionService = game:GetService("CollectionService")

	if CollectionService:HasTag(game.Players.LocalPlayer, "DoubleMastery") then
		v8 *= 2
	end

	local v9 = -p2

	for i = p, v5 - 1 do
		local MasteryEXPFunction = require(game.ReplicatedStorage.MasteryEXPFunction)
		v9 += MasteryEXPFunction(i)
	end

	return (math.ceil(v9 / v8))
end

local ItemConfig = require(game.ReplicatedStorage.ItemConfig)

local function fruitName(value)
	local nullable = ItemConfig.match(value, "Moveset"):asNullable()

	if nullable then
		return nullable.Display.Name or nullable.Index.StorageKey
	end

	if value == "" then
		return "Fruitless"
	end

	local v5 = value:match("^Permanent %a+%-%a+") and "Permanent " or ""
	local v6 = string.match(value, "(((%u)%-?)([^-.]+))$")

	if v6 then
		return v5 .. v6
	end

	return value
end

function getSpecialFruitName()
	local specialFruit = script.Parent:GetAttribute("SpecialFruit")
	assert(typeof(specialFruit) == "string", "bad \"SpecialFruit\" attribute")

	if specialFruit:len() <= 0 then
		return nil
	end

	return specialFruit
end

return function(parent, items, items2)
	local extended = v.extend((`{parent.Name}`))
	extended.info((`fn called: (tool: {parent.Name}, z, tAwakening)`))
	extended.trace(function()
		return "z", items
	end)
	extended.trace(function()
		return "tAwakening", items2
	end)
	local localPlayer = game.Players.LocalPlayer
	local character = localPlayer.Character
	assert(character, "bad character")
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mobileRage = playerGui:WaitForChild("HUDNoInset"):WaitForChild("MobileRage")
	local currentTransformation = Global.CurrentTransformation
	local parent2 = script.Parent.Parent
	local clones = {}

	for k, clone in items do
		if type(clone) == "table" then
			clone = table.clone(clone)
		end

		clones[k] = clone
	end

	local isNewUIEnabled = MobileUIController:IsNewUIEnabled()
	local name = parent.Name

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isAwakened(childName)
		return parent:FindFirstChild("AwakenedMoves") and parent.AwakenedMoves:FindFirstChild(childName)
	end

	if items2 then
		for k, clone in items2 do
			if not isAwakened(clone[1]) then
				continue
			end

			if type(clone) == "table" then
				clone = table.clone(clone)
			end

			clones[k] = clone
			clones[k].Awakened = true
		end
	end

	applyToolMovesetSkillNames(parent, clones)
	applyStreamedBindingSkillNames(playerGui, parent, clones)
	local v5 = false

	if v3[name] then
		for _, v6 in clones do
			for _, v7 in v3[name] do
				if v6[1] == v7[1] and v6[3] ~= v7[3] then
					v5 = true
				end
			end
		end

		if #clones ~= #v3[name] then
			v5 = true
		end
	end

	v3[name] = clones
	local toolData = getToolData(playerGui, parent)

	if not toolData then
		Global.TestGamePrint("No tool data, can't setup skills")
		return
	end

	if UserInputService.TouchEnabled then
		parent2.Skills.BackgroundTransparency = 0.7
	end

	for _, frame in parent2.Skills:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	Global.mobileSelection = nil
	Global.mobileSelectionFrame = nil
	local clone = parent2.Skills:FindFirstChild(name)

	if v5 and clone then
		clone:Destroy()
		clone = nil
	end

	maid:DoCleaning()

	local function checkNewSkillUnlocked(list)
		if not v4[parent.Name] then
			v4[parent.Name] = {}
		end

		if not ((parent:GetAttribute("Level") or parent.Level.Value) >= list[2]) then
			v4[parent.Name][list[1]] = false
			return
		end

		if v4[parent.Name][list[1]] == false then
			Notification.new("<Color=Yellow>NEW SKILL AVAILABLE!<Color=/>"):Display()
		end

		v4[parent.Name][list[1]] = true
	end

	Global.CurrentTouchObjectForMouse = nil

	local function GenerateTapHoldButton()
		if not UserInputService.TouchEnabled then
			Global.TestGameWarn("no uis")
			return
		end

		task.wait(0.1)
		local parent3 = nil

		for _, frame in pairs(clone:GetChildren()) do
			if frame:IsA("Frame") and frame.LayoutOrder == 1 then
				parent3 = frame
			end
		end

		if not parent3 then
			Global.TestGameWarn("no found skill")
			return
		end

		if parent3:FindFirstChild("M1Hold") then
			parent3:FindFirstChild("M1Hold"):Destroy()
		end

		local clone2 = parent2.Skills.Container.Template.Mobile:Clone()
		clone.AncestryChanged:Connect(function()
			clone2:Destroy()
		end)
		clone2.Name = "M1Hold"
		clone2.Visible = true
		clone2.Parent = parent3
		clone2.Position = UDim2.new(
			clone2.Position.X.Scale,
			clone2.Position.X.Offset,
			clone2.Position.Y.Scale - clone2.Size.Y.Scale,
			clone2.Position.Y.Offset - clone2.Size.Y.Offset
		)
		local FruitSkillUtil = require(game.ReplicatedStorage.Modules.FruitSkillUtil)
		clone2.Activated:Connect(function()
			Global.mobileId = nil

			if Global.mobileSelection == nil and Global.mobileSelectionFrame then
				Global.mobileSelectionFrame.BackgroundColor3 = Color3.new()
				Global.mobileSelectionFrame = nil
			end

			if Global.mobileSelectionFrame == clone2 then
				Global.mobileSelectionFrame.BackgroundColor3 = Color3.new()
				Global.mobileSelectionFrame = nil
				Global.mobileSelection = nil
			else
				Global.mobileSelection = "G"
				Global.mobileSelectionFrame = clone2

				for _, frame in clone:GetChildren() do
					if frame:IsA("Frame") then
						frame.Mobile.BackgroundColor3 = Color3.new()
					end
				end

				clone2.BackgroundColor3 = Color3.new(0, 1, 1)
				local touchStartedConnection = nil
				touchStartedConnection = UserInputService.TouchStarted:Connect(function(inputObject, p2)
					if p2 or Global.mobileSelectionFrame ~= clone2 then
						return
					end

					local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

					if not tool then
						return
					end

					touchStartedConnection:Disconnect()
					FruitSkillUtil.MobileM1ButtonActivated({
						HeldTool = tool,
						InputObject = inputObject,
						TapHoldButton = clone2
					})
				end)
			end
		end)
		clone2.InputBegan:Connect(function() end)
		clone2.InputEnded:Connect(function() end)
		return clone2
	end

	if not clone then
		clone = parent2.Skills.Container:Clone()
		clone.Name = name
		clone:SetAttribute("SkillsContainer", true)
		clone.Parent = parent2.Skills

		local function tryConnectButton(p, list)
			if UserInputService.TouchEnabled then
				p.Mobile.Activated:Connect(function()
					Global.mobileId = nil

					if Global.mobileSelection == nil and Global.mobileSelectionFrame then
						Global.mobileSelectionFrame.BackgroundColor3 = Color3.new()
						Global.mobileSelectionFrame = nil
					end

					if Global.mobileSelectionFrame == p.Mobile then
						Global.mobileSelectionFrame.BackgroundColor3 = Color3.new()
						Global.mobileSelectionFrame = nil
						Global.mobileSelection = nil
					else
						Global.mobileSelection = list[1]
						Global.mobileSelectionFrame = p.Mobile

						for _, frame in clone:GetChildren() do
							if frame:IsA("Frame") then
								frame.Mobile.BackgroundColor3 = Color3.new()
							end
						end

						p.Mobile.BackgroundColor3 = Color3.new(0, 1, 1)

						while Global.mobileSelectionFrame == p.Mobile do
							task.wait()
						end

						p.Mobile.BackgroundColor3 = Color3.new()
					end
				end)

				if (parent:GetAttribute("Level") or parent.Level.Value) >= list[2] then
					p.Mobile.Visible = true
				end
			end
		end

		local v6 = nil
		local childAddedConnection = parent2.Skills.ChildAdded:Connect(function(child)
			if v6 == child then
				return
			end

			if child.Name == "CreationBuildMode" then
				v6 = child

				for _, child2 in child:GetChildren() do
					for _, v7 in clones do
						if v7[1] == child2.Name then
							tryConnectButton(child2, v7)
						end
					end
				end
			end
		end)
		clone.Destroying:Connect(function()
			if v6 then
				if parent and parent.Parent and v6.Parent then
					v6.Visible = false
					v6.Parent = parent
				else
					v6:Destroy()
				end

				v6 = nil
			end

			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end)

		for _, child in clone:GetChildren() do
			if #child.Name == 1 then
				child:Destroy()
			end
		end

		for k, v7 in clones do
			v7[2] = toolData.Lvl[v7[1]]
			checkNewSkillUnlocked(v7)
			local clone2 = clone.Template:Clone()
			local color = (parent:GetAttribute("Level") or parent.Level.Value) < v7[2] and Color3.new(0.45, 0.45, 0.45) or Color3.new(
				1,
				1,
				1
			)
			clone2.Title.TextColor3 = color
			clone2.Level.TextColor3 = color
			clone2.Key.TextColor3 = color
			local _ = v7[1]
			local v8 = v7[1]
			clone2.Key.Text = "[" .. v8 .. "]"
			clone2.GamepadKey.Image = GamepadConversion.getImg(v7[1])
			reflectInputTypeForSkill(clone2) -- equivalent call inferred; original call site unknown
			clone2.Level.Text = "Mas. " .. v7[2]
			clone2.Title.Text = v7[3]
			clone2.Name = v7[1]
			clone2.LayoutOrder = k
			clone2.Visible = true
			clone2.Parent = clone
			tryConnectButton(clone2, v7)
		end
	end

	for _, v6 in clones do
		local v7 = v6[1]
		local v8 = toolData.Lvl[v7]
		v6[2] = v8
		checkNewSkillUnlocked(v6)
		local v9 = v8 <= (parent:GetAttribute("Level") or parent.Level.Value)
		local v10 = clone[v7]
		local color = v9 and Color3.new(1, 1, 1) or Color3.new(0.45, 0.45, 0.45)
		v10.Title.TextColor3 = color
		v10.Level.TextColor3 = color
		v10.Key.TextColor3 = color
		v10.Mobile.BackgroundColor3 = Color3.new()

		if UserInputService.TouchEnabled and v9 then
			v10.Mobile.Visible = true
		end

		if not UserInputService.TouchEnabled then
			continue
		end

		local contextButton = MobileUIController:GetContextButton("Skill_" .. v7)

		if not contextButton then
			continue
		end

		if not v9 then
			contextButton.Button.LockedFrame.Label.Text = "Mas. " .. v8
			contextButton.Button.LockedFrame.ZIndex = 98
		end

		contextButton.Button.LockedFrame.Visible = not v9
	end

	if Global.currentTapHold then
		Global.currentTapHold:Destroy()
		Global.currentTapHold = nil
	end

	if parent:GetAttribute("MobileM1Button") and name ~= "Dragon-Dragon" then
		Global.currentTapHold = GenerateTapHoldButton()
	end

	local starContainer = parent2.Skills.StarContainer
	local stars = localPlayer:WaitForChild("Data"):WaitForChild("Stars")

	local function updateStars()
		local value = stars.Max.Value
		local value2 = stars[parent.ToolTip].Value
		starContainer.Center.Bar.Fill.Position = UDim2.fromScale(-1 + value2 / value, 0)
		starContainer.Center.Bar.TextLabel.Text = value2 .. "/" .. value .. " Stored"

		if (parent:GetAttribute("Level") or parent.Level.Value) < 600 then
			starContainer.Center.Bar.Size = UDim2.new(0.7, -14, 1, -4)
			starContainer.Center.Button.Visible = true
		else
			starContainer.Center.Bar.Size = UDim2.new(1, -8, 1, -4)
			starContainer.Center.Button.Visible = false
		end

		starContainer.Center.Border.Size = starContainer.Center.Bar.Size
	end

	maid:GiveTask(stars[parent.ToolTip].Changed:Connect(updateStars))
	maid:GiveTask(stars.Max.Changed:Connect(updateStars))
	maid:GiveTask(parent.Level.Changed:Connect(updateStars))
	updateStars()
	starContainer.Center.Bar.Fill.BackgroundColor3 = v2[parent.ToolTip][3]
	starContainer.Center.Bar.Fill.Center.BackgroundColor3 = v2[parent.ToolTip][3]
	starContainer.Center.Bar.ImageLabel.ImageRectOffset = v2[parent.ToolTip][1]
	local Util = require(game.ReplicatedStorage.Util)
	local maid2 = Util.Maid.new()
	maid:GiveTask(maid2)
	maid:GiveTask(starContainer.Center.Button.Activated:Connect(function()
		maid2:DoCleaning()

		for _, frame in parent2.Stars.Container:GetChildren() do
			if frame:IsA("Frame") and frame.Visible then
				frame:Destroy()
			end
		end

		local template = parent2.Stars.Container:FindFirstChild("Template")
		local v6 = {}

		for _, v7 in next, clones, nil do
			if not ((parent:GetAttribute("Level") or parent.Level.Value) < v7[2]) then
				continue
			end

			local stars2 = StarsUntilLevel(
				parent:GetAttribute("Level") or parent.Level.Value,
				parent:GetAttribute("Exp") or parent.Exp.Value,
				v7[2],
				localPlayer.Data.Level.Value
			)
			table.insert(v6, {
				Text = v7[3] .. " (Mas. " .. v7[2] .. ")",
				Stars = stars2,
				Mastery = v7[2]
			})
		end

		local stars3 = 0

		if (parent:GetAttribute("Level") or parent.Level.Value) < 400 then
			table.insert(v6, {
				Text = "Mastery Level 400",
				Stars = StarsUntilLevel(
					parent:GetAttribute("Level") or parent.Level.Value,
					parent:GetAttribute("Exp") or parent.Exp.Value,
					400,
					localPlayer.Data.Level.Value
				),
				Mastery = 400
			})
		end

		if (parent:GetAttribute("Level") or parent.Level.Value) < 600 then
			stars3 = StarsUntilLevel(
				parent:GetAttribute("Level") or parent.Level.Value,
				parent:GetAttribute("Exp") or parent.Exp.Value,
				600,
				localPlayer.Data.Level.Value
			)
			table.insert(v6, {
				Text = "Mastery Level 600",
				Stars = stars3,
				Mastery = 600
			})
		end

		table.sort(v6, function(a, b)
			return a.Stars < b.Stars
		end)
		local star = localPlayer.Data.Stars[parent.ToolTip]

		local function toggleButton(state, p)
			if p then
				state.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
				state.BorderColor3 = Color3.fromRGB(255, 240, 69)
				state.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
				state.ImageLabel.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				state.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			else
				state.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
				state.BorderColor3 = Color3.fromRGB(100, 100, 100)
				state.Trans.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
				state.ImageLabel.TextLabel.TextColor3 = Color3.fromRGB(188, 188, 188)
				state.ImageLabel.ImageColor3 = Color3.fromRGB(211, 211, 211)
			end
		end

		local function refreshLines()
			stars3 = StarsUntilLevel(
				parent:GetAttribute("Level") or parent.Level.Value,
				parent:GetAttribute("Exp") or parent.Exp.Value,
				600,
				localPlayer.Data.Level.Value
			)

			for _, v8 in v6 do
				v8.Stars = StarsUntilLevel(
					parent:GetAttribute("Level") or parent.Level.Value,
					parent:GetAttribute("Exp") or parent.Exp.Value,
					v8.Mastery,
					localPlayer.Data.Level.Value
				)
				v8.Gui.Add.ImageLabel.TextLabel.Text = v8.Stars

				if v8.Stars > star.Value or v8.Stars == 0 or stars3 < v8.Stars then
					v8.Gui.TextLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
					local add = v8.Gui.Add
					add.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
					add.BorderColor3 = Color3.fromRGB(100, 100, 100)
					add.Trans.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
					add.ImageLabel.TextLabel.TextColor3 = Color3.fromRGB(188, 188, 188)
					add.ImageLabel.ImageColor3 = Color3.fromRGB(211, 211, 211)
				else
					v8.Gui.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					local add = v8.Gui.Add
					add.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
					add.BorderColor3 = Color3.fromRGB(255, 240, 69)
					add.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
					add.ImageLabel.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					add.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end
			end

			for _, button in parent2.Stars.ExtraRow:GetChildren() do
				if not button:IsA("TextButton") then
					continue
				end

				if tonumber(button.Name) > star.Value or tonumber(button.Name) == 0 or stars3 < tonumber(button.Name) then
					button.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
					button.BorderColor3 = Color3.fromRGB(100, 100, 100)
					button.Trans.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
					button.ImageLabel.TextLabel.TextColor3 = Color3.fromRGB(188, 188, 188)
					button.ImageLabel.ImageColor3 = Color3.fromRGB(211, 211, 211)
				else
					button.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
					button.BorderColor3 = Color3.fromRGB(255, 240, 69)
					button.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
					button.ImageLabel.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					button.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end
			end

			parent2.Stars.Bottom.Available.Text = "Available: " .. star.Value
		end

		local function spendStars(p)
			local v8 = math.min(p, stars3)

			if v8 == 0 then
				return
			end

			game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SpendStar", parent.ToolTip, v8)
		end

		maid2:GiveTask(localPlayer.Data.Level.Changed:Connect(refreshLines))
		maid2:GiveTask(star.Changed:Connect(function()
			task.wait(0.1)
			refreshLines()
		end))
		maid2:GiveTask(parent.Level.Changed:Connect(function()
			task.wait(0.1)
			refreshLines()
		end))

		for _, v8 in v6 do
			local clone2 = template:Clone()
			clone2.Add.ImageLabel.TextLabel.Text = v8.Stars
			clone2.TextLabel.Text = v8.Text
			clone2.Visible = true
			clone2.Add.ImageLabel.ImageRectOffset = v2[parent.ToolTip][1]
			clone2.Parent = parent2.Stars.Container
			v8.Gui = clone2
			local v9 = v8
			maid2:GiveTask(clone2.Add.Activated:Connect(function()
				local v10 = math.min(v9.Stars, stars3)

				if v10 == 0 then
					return
				end

				game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SpendStar", parent.ToolTip, v10)
			end))
		end

		maid2:GiveTask(parent2.Stars.Title.Exit.Activated:Connect(function()
			TweenService:Create(parent2.Stars, TweenInfo.new(0.2), {
				Position = UDim2.fromScale(0.5, 2)
			}):Play()
			maid2:DoCleaning()
		end))

		for _, button in parent2.Stars.ExtraRow:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			local v8 = button
			maid2:GiveTask(button.Activated:Connect(function()
				local v9 = math.min(tonumber(v8.Name), stars3)

				if v9 == 0 then
					return
				end

				game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SpendStar", parent.ToolTip, v9)
			end))
			button.ImageLabel.ImageRectOffset = v2[parent.ToolTip][1]
		end

		refreshLines()
		TweenService:Create(parent2.Stars, TweenInfo.new(0.2), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
	end))
	maid:GiveTask(function()
		TweenService:Create(parent2.Stars, TweenInfo.new(0.2), {
			Position = UDim2.fromScale(0.5, 2)
		}):Play()
	end)
	local v6 = name == "Black Leg" and "Dark Step" or name
	local v7 = v6 == "Fishman Karate" and "Water Kung Fu" or v6
	local v8 = v7 == "Electro" and "Electric" or v7
	local v9 = v8 == "Dragon Claw" and "Dragon Breath" or v8
	parent2.Skills.Rage.Black.Trans.Visible = false
	parent2.Skills.Rage.Bar.UIGradient.Enabled = false
	mobileRage.Bar.Trans.Visible = false
	mobileRage.Bar.UIGradient.Enabled = false

	for _, child in parent2.Skills.Rage.Ticks:GetChildren() do
		child.Visible = true
	end

	for _, child in mobileRage.Ticks:GetChildren() do
		child.Visible = true
	end

	parent2.Skills.Rage.Ticks.MoodLine.Visible = false
	mobileRage.Ticks.MoodLine.Visible = false
	local flag = false

	if v9 == getSpecialFruitName() or v9 == "Control-Control" or v9 == "Magnet-Magnet" or v9 == "Pain-Pain" or v9 == "Werewolf (Tiger)-Werewolf (Tiger)" or v9 == "Tiger-Tiger" or v9 == "Creation-Creation" or v9 == "Gravity-Gravity" and BuildUtil.getIfNewGravityEnabled() or v9 == "Gas-Gas" or v9 == "Sound-Sound" or v9 == "Kitsune-Kitsune" or v9 == "Empyrean (Kitsune)-Empyrean (Kitsune)" or v9 == "Dragon-Dragon" or v9 == "Dragon (Classic)-Dragon (Classic)" or v9 == "T-Rex-T-Rex" or v9 == "Venom-Venom" or v9 == "Shadow-Shadow" or v9 == "Soul-Soul" or v9 == "Spirit-Spirit" then
		parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
		parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
		parent2.Skills.Rage.Black.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
		parent2.Skills.Rage.Black.Trans.Visible = false
		mobileRage.Fire:SetAttribute("ParticleEnabled", false)
		mobileRage.Black.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
		mobileRage.Black.Trans.Visible = false

		if v9 == "Soul-Soul" or v9 == "Spirit-Spirit" then
			if v9 == "Spirit-Spirit" then
				parent2.Skills.Rage.Text = "Spirits: ?"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 1, 1)
				parent2.Skills.Rage.Bar.UIGradient.Enabled = true

				for _, child in parent2.Skills.Rage.Ticks:GetChildren() do
					child.Visible = false
				end

				parent2.Skills.Rage.Black.Trans.Visible = false
				parent2.Skills.Rage.Ticks.MoodLine.Visible = true
				mobileRage.Text = "Spirits: ?"
				mobileRage.Bar.BackgroundColor3 = Color3.new(1, 1, 1)
				mobileRage.Bar.UIGradient.Enabled = true

				for _, child in mobileRage.Ticks:GetChildren() do
					child.Visible = false
				end

				mobileRage.Black.Trans.Visible = false
				mobileRage.Ticks.MoodLine.Visible = true

				if rageConnection then
					rageConnection:Disconnect()
					rageConnection = nil
				end

				if spiritsConnection then
					spiritsConnection:Disconnect()
					spiritsConnection = nil
				end

				parent2.Skills.Rage.Bar.Size = UDim2.fromScale(1, 0.2)
				mobileRage.Bar.Size = UDim2.fromScale(1, 0.3)
				task.defer(function()
					local rage = character:WaitForChild("Rage")
					local souls = character:WaitForChild("Souls")

					if not rageConnection then
						local value = rage.Value
						local v10 = nil
						local v11 = nil
						rageConnection = rage.Changed:Connect(function()
							if rage.Value <= value then
								if v10 then
									v10:Cancel()
								end

								if v11 then
									v11:Cancel()
								end

								parent2.Skills.Rage.Ticks.MoodLine.Position = UDim2.fromScale(rage.Value / 100, 0)
								mobileRage.Ticks.MoodLine.Position = UDim2.fromScale(rage.Value / 100, 0)
							else
								v10 = TweenService:Create(parent2.Skills.Rage.Ticks.MoodLine, TweenInfo.new(0.25), {
									Position = UDim2.new(rage.Value / 100, 0, 0, 0)
								})
								v10:Play()
								v11 = TweenService:Create(mobileRage.Ticks.MoodLine, TweenInfo.new(0.25), {
									Position = UDim2.new(rage.Value / 100, 0, 0, 0)
								})
								v11:Play()
							end

							if rage.Value > 50 then
								parent2.Skills.Rage.TextColor3 = Color3.new(1, 0.1, 0.1)
								mobileRage.TextColor3 = Color3.new(1, 0.1, 0.1)
							else
								parent2.Skills.Rage.TextColor3 = Color3.new(0.1, 1, 1)
								mobileRage.TextColor3 = Color3.new(0.1, 1, 1)
							end

							value = rage.Value
						end)
						parent2.Skills.Rage.Ticks.MoodLine.Position = UDim2.new(rage.Value / 100, 0, 0, 0)
						mobileRage.Ticks.MoodLine.Position = UDim2.new(rage.Value / 100, 0, 0, 0)
					end

					parent2.Skills.Rage.Text = "Spirits: " .. souls.Value
					mobileRage.Text = "Spirits: " .. souls.Value

					if not spiritsConnection then
						spiritsConnection = souls.Changed:Connect(function()
							parent2.Skills.Rage.Text = "Spirits: " .. souls.Value
							mobileRage.Text = "Spirits: " .. souls.Value
						end)
						parent2.Skills.Rage.Text = "Spirits: " .. souls.Value
						mobileRage.Text = "Spirits: " .. souls.Value
					end
				end)
			else
				parent2.Skills.Rage.Text = "Souls: ?"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 1, 1)
				parent2.Skills.Rage.Bar.UIGradient.Enabled = true

				for _, child in parent2.Skills.Rage.Ticks:GetChildren() do
					child.Visible = false
				end

				parent2.Skills.Rage.Black.Trans.Visible = false
				parent2.Skills.Rage.Ticks.MoodLine.Visible = true
				mobileRage.Text = "Souls: ?"
				mobileRage.Bar.BackgroundColor3 = Color3.new(1, 1, 1)
				mobileRage.Bar.UIGradient.Enabled = true

				for _, child in mobileRage.Ticks:GetChildren() do
					child.Visible = false
				end

				mobileRage.Black.Trans.Visible = false
				mobileRage.Ticks.MoodLine.Visible = true

				if rageConnection then
					rageConnection:Disconnect()
					rageConnection = nil
				end

				if soulsConnection then
					soulsConnection:Disconnect()
					soulsConnection = nil
				end

				parent2.Skills.Rage.Bar.Size = UDim2.fromScale(1, 0.2)
				mobileRage.Bar.Size = UDim2.fromScale(1, 0.3)
				task.defer(function()
					local rage = character:WaitForChild("Rage")

					if not rageConnection then
						rageConnection = rage.Changed:Connect(function()
							parent2.Skills.Rage.Ticks.MoodLine.Position = UDim2.new(rage.Value / 100, 0, 0, 0)
							mobileRage.Ticks.MoodLine.Position = UDim2.new(rage.Value / 100, 0, 0, 0)
						end)
						parent2.Skills.Rage.Ticks.MoodLine.Position = UDim2.new(rage.Value / 100, 0, 0, 0)
						mobileRage.Ticks.MoodLine.Position = UDim2.new(rage.Value / 100, 0, 0, 0)
					end

					local souls = character:WaitForChild("Souls")

					if not soulsConnection then
						soulsConnection = souls.Changed:Connect(function()
							parent2.Skills.Rage.Text = "Souls: " .. souls.Value
							mobileRage.Text = "Souls: " .. souls.Value
						end)
						parent2.Skills.Rage.Text = "Souls: " .. souls.Value
						mobileRage.Text = "Souls: " .. souls.Value
					end
				end)
			end
		elseif v9 == getSpecialFruitName() then
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			parent2.Skills.Rage.Bar.UIGradient.Enabled = false

			for _, child in parent2.Skills.Rage.Black:GetChildren() do
				child.Visible = true
			end

			parent2.Skills.Rage.Ticks.MoodLine.Visible = false
			parent2.Skills.Rage.Text = "Feather Meter"
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 0.690196, 0.192157)
			mobileRage.Bar.UIGradient.Enabled = false

			for _, child in mobileRage.Black:GetChildren() do
				child.Visible = true
			end

			mobileRage.Ticks.MoodLine.Visible = false
			mobileRage.Text = "Feather Meter"
			mobileRage.Bar.BackgroundColor3 = Color3.new(1, 0.690196, 0.192157)

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			coroutine.resume(coroutine.create(function()
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					rageConnection = rage.Changed:Connect(function()
						parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
						mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					end)
					parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
				end
			end))
		elseif v9 == "Creation-Creation" then
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			parent2.Skills.Rage.Bar.UIGradient.Enabled = false

			for _, child in parent2.Skills.Rage.Black:GetChildren() do
				child.Visible = true
			end

			parent2.Skills.Rage.Ticks.MoodLine.Visible = false
			parent2.Skills.Rage.Text = "Build Meter"
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 0.203922, 0.203922)
			mobileRage.TextColor3 = Color3.new(1, 1, 1)
			mobileRage.Text = "Build Meter"
			mobileRage.Bar.BackgroundColor3 = Color3.new(1, 0.203922, 0.203922)
			mobileRage.Bar.UIGradient.Enabled = false
			mobileRage.Ticks.MoodLine.Visible = false

			for _, child in mobileRage.Black:GetChildren() do
				child.Visible = true
			end

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			if fortBuilderChangedConnection then
				fortBuilderChangedConnection:Disconnect()
				fortBuilderChangedConnection = nil
			end

			coroutine.resume(coroutine.create(function()
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					rageConnection = rage.Changed:Connect(function()
						parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
						mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					end)
					parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
				end

				local fortBuilderActive = parent:WaitForChild("FortBuilderActive")

				if not fortBuilderChangedConnection then
					fortBuilderChangedConnection = fortBuilderActive.Changed:Connect(function()
						if fortBuilderActive.Value == true then
							parent2.Skills.Rage.Visible = not isNewUIEnabled
							mobileRage.Visible = isNewUIEnabled
						else
							parent2.Skills.Rage.Visible = false
							mobileRage.Visible = false
						end
					end)

					if fortBuilderActive.Value == true then
						flag = false
						parent2.Skills.Rage.Visible = true
					else
						flag = true
						parent2.Skills.Rage.Visible = false
					end
				end
			end))
		elseif v9 == "Gravity-Gravity" and BuildUtil.getIfNewGravityEnabled() then
			local hiddenAbilities = parent:FindFirstChild("HiddenAbilities")

			if hiddenAbilities and (hiddenAbilities:FindFirstChild("CelestialCataclysm") or hiddenAbilities:FindFirstChild("DarkMatterImplosion")) then
				parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
				parent2.Skills.Rage.Bar.UIGradient.Enabled = false

				for _, child in pairs(parent2.Skills.Rage.Black:GetChildren()) do
					child.Visible = true
				end

				parent2.Skills.Rage.Ticks.MoodLine.Visible = false
				parent2.Skills.Rage.Text = "Gravitational Force"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(0.45098, 0, 1)
				mobileRage.Text = "Gravitational Force"
				mobileRage.Bar.BackgroundColor3 = Color3.new(0.45098, 0, 1)
				mobileRage.Ticks.MoodLine.Visible = false
				mobileRage.Bar.UIGradient.Enabled = false

				for _, child in pairs(mobileRage.Black:GetChildren()) do
					child.Visible = true
				end

				if rageConnection then
					rageConnection:Disconnect()
					rageConnection = nil
				end

				coroutine.resume(coroutine.create(function()
					local rage = character:WaitForChild("Rage")

					if not rageConnection then
						rageConnection = rage.Changed:Connect(function()
							parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
							mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)

							if not (rage.Value >= 100) then
								parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
							elseif hiddenAbilities and hiddenAbilities:FindFirstChild("CelestialCataclysm") then
								parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", "Gravity")
							else
								parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
							end
						end)
						parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
						mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					end
				end))
			else
				flag = true
			end
		elseif v9 == "Magnet-Magnet" then
			local v10 = { parent2.Skills.Rage, mobileRage }

			for _, v11 in v10 do
				v11.TextColor3 = Color3.new(1, 1, 1)
				v11.Bar.UIGradient.Enabled = false

				for _, child in pairs(v11.Black:GetChildren()) do
					child.Visible = true
				end

				v11.Ticks.MoodLine.Visible = false
				v11.Text = "Magnetic Power [1/3]"
				v11.Bar.BackgroundColor3 = Color3.new(0.160784, 0.356863, 1)
			end

			local v11 = {
				{
					Name = "TierNotch2",
					X = 0.3333333333333333
				},
				{
					Name = "TierNotch3",
					X = 0.6666666666666666
				}
			}

			local function ensureNotches()
				for _, parent3 in v10 do
					for _, v13 in ipairs(v11) do
						if parent3:FindFirstChild(v13.Name) then
							continue
						end

						local frame = Instance.new("Frame")
						frame.Name = v13.Name
						frame.BackgroundColor3 = Color3.new(1, 1, 1)
						frame.BorderSizePixel = 0
						frame.AnchorPoint = Vector2.new(0.5, 0.5)
						frame.Position = UDim2.new(v13.X, 0, 1.033, 0)
						frame.Size = UDim2.new(0.015, 0, 0.35, 0)
						frame.ZIndex = 4
						frame.Parent = parent3
					end
				end
			end

			local function destroyNotches()
				for _, v12 in v10 do
					for _, v13 in ipairs(v11) do
						local child = v12:FindFirstChild(v13.Name)

						if child then
							child:Destroy()
						end
					end
				end
			end

			local function setNotchesVisible(visible)
				for _, v12 in v10 do
					for _, v13 in ipairs(v11) do
						local child = v12:FindFirstChild(v13.Name)

						if child then
							child.Visible = visible
						end
					end
				end
			end

			local function setBarScale(p)
				for _, v12 in v10 do
					v12.Bar.Size = UDim2.new(p, 0, 0.2, 0)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setFireEnabled(particleEnabled)
				for _, v12 in v10 do
					v12.Fire:SetAttribute("ParticleEnabled", particleEnabled)
				end
			end

			local function resetMeterBackground()
				for _, v12 in v10 do
					v12.Black.BackgroundColor3 = Color3.new(0.184314, 0.184314, 0.184314)
				end
			end

			ensureNotches()
			local ancestryChangedConnection = parent.AncestryChanged:Connect(function()
				if not parent:IsDescendantOf(character) then
					destroyNotches()
					resetMeterBackground()
					setFireEnabled(false) -- equivalent call inferred; original call site unknown
				end
			end)

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			coroutine.resume(coroutine.create(function()
				local rage = character:WaitForChild("Rage")
				local magnetArmFunctions = character:WaitForChild("MagnetArmFunctions")
				local isTransformed = parent:WaitForChild("IsTransformed")

				if not rageConnection then
					local RunService = game:GetService("RunService")
					rageConnection = RunService.Heartbeat:Connect(function()
						if parent:IsDescendantOf(character) then
							local currentTier = magnetArmFunctions:GetAttribute("CurrentTier") or 1

							for _, v12 in v10 do
								v12.Text = "Magnetic Power [" .. tostring(currentTier) .. "/3]"
							end

							ensureNotches()

							if isTransformed.Value then
								setNotchesVisible(false)
								setBarScale(rage.Value / 100)
								setFireEnabled("Kitsune") -- equivalent call inferred; original call site unknown
							else
								setNotchesVisible(true)
								setBarScale(((currentTier - 1) * 100 + rage.Value) / 300)

								if currentTier == 3 and rage.Value == 100 then
									setFireEnabled("Kitsune") -- equivalent call inferred; original call site unknown
								else
									setFireEnabled(false) -- equivalent call inferred; original call site unknown
								end
							end
						else
							destroyNotches()

							if ancestryChangedConnection then
								ancestryChangedConnection:Disconnect()
							end

							resetMeterBackground()
							rageConnection:Disconnect()
							rageConnection = nil
						end
					end)
					local currentTier = magnetArmFunctions:GetAttribute("CurrentTier") or 1

					if isTransformed.Value then
						setBarScale(rage.Value / 100)
					else
						setBarScale(((currentTier - 1) * 100 + rage.Value) / 300)
					end
				end
			end))
		elseif v9 == "Kitsune-Kitsune" or v9 == "Empyrean (Kitsune)-Empyrean (Kitsune)" then
			parent2.Skills.Rage.Text = "1 Tail"
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(0, 0, 1)
			mobileRage.Text = "1 Tail"
			mobileRage.Bar.BackgroundColor3 = Color3.new(0, 0, 1)

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			if spiritsConnection then
				spiritsConnection:Disconnect()
				spiritsConnection = nil
			end

			parent2.Skills.Rage.Bar.Size = UDim2.fromScale(1, 0.2)
			mobileRage.Bar.Size = UDim2.fromScale(1, 0.2)
			task.defer(function()
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					local v10 = rage.Value / 100

					local function changeBar(p)
						local v11 = p > 0.6666666666666666 and 2 or p > 0.3333333333333333 and 1 or 0
						local color = Color3.new(0, v11 / 2, 1)
						local v12

						if v11 >= 1 then
							parent2.Skills.Rage.Black.BackgroundColor3 = Color3.new(0, (v11 - 1) / 2, 1)
							parent2.Skills.Rage.Black.Trans.Visible = true
							mobileRage.Black.BackgroundColor3 = Color3.new(0, (v11 - 1) / 2, 1)
							mobileRage.Black.Trans.Visible = true
							v12 = (p - v11 * 0.3333333333333333) / 0.3333333333333333
						else
							parent2.Skills.Rage.Black.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
							parent2.Skills.Rage.Black.Trans.Visible = false
							mobileRage.Black.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
							mobileRage.Black.Trans.Visible = false
							v12 = p / 0.3333333333333333
						end

						parent2.Skills.Rage.Bar.BackgroundColor3 = color
						parent2.Skills.Rage.Bar.Size = UDim2.new(v12, 0, 0.2, 0)
						mobileRage.Bar.BackgroundColor3 = color
						mobileRage.Bar.Size = UDim2.new(v12, 0, 0.2, 0)
						local text = v11 == 1 and "2 Tails" or v11 == 2 and "3 Tails" or "1 Tail"
						parent2.Skills.Rage.Text = text
						mobileRage.Text = text
					end

					local now = 0
					rageConnection = rage.Changed:Connect(function()
						local v11 = rage.Value / 100
						now = os.clock()
						v10 = v11
					end)
					changeBar(v10)
					local v11 = v10
					local v12 = false

					while true do
						local v13 = task.wait()

						if not rageConnection then
							break
						end

						if os.clock() - now < 0.25 then
							v11 += (v10 - v11) * (v13 / 0.25) * 5
							changeBar(v11)
							v12 = false
						elseif not v12 then
							changeBar(v10)
							v11 = v10
							v12 = true
						end

						if not (v10 >= 1) or (character:FindFirstChild("Kitsune") or character:FindFirstChild("RedKitsune")) then
							continue
						end

						local v14 = os.clock() % 3 / 3
						local color = Color3.fromHSV(v14, 1, 1)
						parent2.Skills.Rage.Bar.BackgroundColor3 = color
						mobileRage.Bar.BackgroundColor3 = color
					end
				end
			end)
		elseif v9 == "Dragon-Dragon" then
			Global.TestGamePrint("Init dragon tools", currentTransformation)
			parent2.Skills.Rage.Text = "Fury Meter"
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 0.6, 0)
			mobileRage.Text = "Fury Meter"
			mobileRage.Bar.BackgroundColor3 = Color3.new(1, 0.6, 0)
			local currentTapHold = nil

			if TransformConn then
				TransformConn:Disconnect()
				TransformConn = nil
			end

			local SharedSignals = require(game.ReplicatedStorage:WaitForChild("SharedSignals"))
			TransformConn = SharedSignals.TransformationChanged():Connect(function(p, p2, p3)
				Global.TestGamePrint("TransformationChanged: DragonTools", p, p2, p3)

				if p and not p3 then
					Global.TestGamePrint("make flamethrower button for dragon (2)")
					currentTapHold = GenerateTapHoldButton()
					Global.currentTapHold = currentTapHold
				elseif currentTapHold then
					Global.TestGamePrint("destroy flame button")
					currentTapHold:Destroy()
				end
			end)

			if currentTransformation == "Dragon" then
				Global.TestGamePrint("make flamethrower button for dragon")
				currentTapHold = GenerateTapHoldButton()
				Global.currentTapHold = currentTapHold
			end

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			if spiritsConnection then
				spiritsConnection:Disconnect()
				spiritsConnection = nil
			end

			parent2.Skills.Rage.Bar.Size = UDim2.fromScale(1, 0.2)
			mobileRage.Bar.Size = UDim2.fromScale(1, 0.2)
			coroutine.resume(coroutine.create(function()
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					local v11 = rage.Value / 100

					local function changeBar(p)
						local color = Color3.new(1, 0.6, 0)
						local v12

						if p >= 0.5 then
							parent2.Skills.Rage.Black.BackgroundColor3 = color
							parent2.Skills.Rage.Black.Trans.Visible = true
							mobileRage.Black.BackgroundColor3 = color
							mobileRage.Black.Trans.Visible = true
							color = Color3.new(1, 0, 0)
							v12 = (p - 0.5) / 0.5
						else
							parent2.Skills.Rage.Black.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
							parent2.Skills.Rage.Black.Trans.Visible = false
							mobileRage.Black.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
							mobileRage.Black.Trans.Visible = false
							v12 = p / 0.5
						end

						parent2.Skills.Rage.Bar.BackgroundColor3 = color
						parent2.Skills.Rage.Bar.Size = UDim2.new(v12, 0, 0.2, 0)
						mobileRage.Bar.BackgroundColor3 = color
						mobileRage.Bar.Size = UDim2.new(v12, 0, 0.2, 0)
					end

					local now = 0
					rageConnection = rage.Changed:Connect(function()
						local v12 = rage.Value / 100
						now = os.clock()
						v11 = v12
					end)
					changeBar(v11)
					local v12 = v11
					local rageConnection2 = rageConnection
					local v13 = false

					while true do
						local v14 = math.min(task.wait(), 0.05)

						if not rageConnection or rageConnection2 ~= rageConnection then
							break
						end

						if os.clock() - now < 0.25 then
							v12 += (v11 - v12) * (v14 / 0.25) * 5
							changeBar(v12)
							v13 = false
						elseif not v13 then
							changeBar(v11)
							v12 = v11
							v13 = true
						end

						if not (v11 >= 1) or character:FindFirstChild("Dragon") then
							continue
						end

						local v15 = os.clock() % 3 / 3
						local color = Color3.fromHSV(v15, 1, 1)
						parent2.Skills.Rage.Bar.BackgroundColor3 = color
						mobileRage.Bar.BackgroundColor3 = color
					end
				end
			end))
		elseif v9 == "Tiger-Tiger" or v9 == "Werewolf (Tiger)-Werewolf (Tiger)" then
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			parent2.Skills.Rage.Bar.UIGradient.Enabled = false

			for _, child in pairs(parent2.Skills.Rage.Ticks:GetChildren()) do
				child.Visible = true
			end

			parent2.Skills.Rage.Ticks.MoodLine.Visible = false
			parent2.Skills.Rage.Text = "Fire Meter"
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 0, 0)
			mobileRage.Text = "Fire Meter"
			mobileRage.Bar.BackgroundColor3 = Color3.new(1, 0, 0)
			mobileRage.Ticks.MoodLine.Visible = false
			mobileRage.Bar.UIGradient.Enabled = false

			for _, child in mobileRage.Ticks:GetChildren() do
				child.Visible = true
			end

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			coroutine.resume(coroutine.create(function()
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					rageConnection = rage.Changed:Connect(function()
						if parent:GetAttribute("Awakened") then
							parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", "TigerAwakened")
						elseif rage.Value >= 100 then
							parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", "TigerAwakened")
						elseif rage.Value >= 75 then
							parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", true)
						else
							parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
						end

						parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
						mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					end)
					parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
				end
			end))
		elseif v9 == "Control-Control" then
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			parent2.Skills.Rage.Bar.UIGradient.Enabled = false

			for _, child in pairs(parent2.Skills.Rage.Ticks:GetChildren()) do
				child.Visible = true
			end

			parent2.Skills.Rage.Ticks.MoodLine.Visible = false
			parent2.Skills.Rage.Text = ""
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(0.721569, 0.160784, 1)
			mobileRage.Text = ""
			mobileRage.Bar.BackgroundColor3 = Color3.new(0.721569, 0.160784, 1)
			mobileRage.Ticks.MoodLine.Visible = false
			mobileRage.Bar.UIGradient.Enabled = false

			for _, child in mobileRage.Ticks:GetChildren() do
				child.Visible = true
			end

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			coroutine.resume(coroutine.create(function()
				local controlModeProxy = character:WaitForChild("ControlModeProxy")
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					local RunService = game:GetService("RunService")
					rageConnection = RunService.Heartbeat:Connect(function()
						if character:FindFirstChild("__Room") then
							parent2.Skills.Rage.Text = "Mode: " .. controlModeProxy.Value
							parent2.Skills.Rage.Visible = true
							mobileRage.Text = "Mode: " .. controlModeProxy.Value
						else
							parent2.Skills.Rage.Text = ""
							parent2.Skills.Rage.Visible = false
							mobileRage.Text = ""
						end

						parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
						mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					end)
					parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
				end
			end))
		elseif v9 == "Pain-Pain" then
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			parent2.Skills.Rage.Bar.UIGradient.Enabled = false

			for _, child in pairs(parent2.Skills.Rage.Ticks:GetChildren()) do
				child.Visible = true
			end

			parent2.Skills.Rage.Ticks.MoodLine.Visible = false
			parent2.Skills.Rage.Text = "Pain Meter"
			parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(0.847059, 0, 0.0156863)
			mobileRage.Text = "Pain Meter"
			mobileRage.Bar.BackgroundColor3 = Color3.new(0.847059, 0, 0.0156863)
			mobileRage.Ticks.MoodLine.Visible = false
			mobileRage.Bar.UIGradient.Enabled = false

			for _, child in mobileRage.Ticks:GetChildren() do
				child.Visible = true
			end

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			if addedConnection then
				addedConnection:Disconnect()
				addedConnection = nil
			end

			local function painNotTransformed()
				character:SetAttribute("PainLastStandClientApplied", nil)
				parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
				parent2.Skills.BackgroundColor3 = Color3.fromRGB(42, 42, 42)

				if rageConnection then
					rageConnection:Disconnect()
					rageConnection = nil
				end

				if addedConnection then
					addedConnection:Disconnect()
					addedConnection = nil
				end

				coroutine.resume(coroutine.create(function()
					local rage = character:WaitForChild("Rage")

					if not rageConnection then
						rageConnection = rage.Changed:Connect(function()
							parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
							mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)

							if rage.Value >= 100 or localPlayer.Character:GetAttribute("PainAura") and rage.Value > 0 then
								parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", "Pain")
							elseif rage.Value <= 0 then
								parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
							end
						end)
						parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
						mobileRage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					end
				end))
			end

			local function painTransformed(child)
				local painLastStandClientApplied = character:GetAttribute("PainLastStandClientApplied")
				child.AncestryChanged:Once(function()
					character:SetAttribute("PainLastStandClientApplied", nil)
				end)

				if painLastStandClientApplied then
					return
				end

				character:SetAttribute("PainLastStandClientApplied", true)

				if addedConnection then
					addedConnection:Disconnect()
					addedConnection = nil
				end

				if rageConnection then
					rageConnection:Disconnect()
					rageConnection = nil
				end

				task.wait()
				local v10 = not child:GetAttribute("Duration") and 20 or child:GetAttribute("Duration") or 20
				local v11 = math.min(v10, workspace:GetServerTimeNow() - child:GetAttribute("Timestamp"))
				task.delay(math.max(0, 0.3 - v11), function()
					if character:FindFirstChild("Pain-Pain") then
						if not character:GetAttribute("PainLastStandClientApplied") then
							return
						end

						parent2.Skills.BackgroundColor3 = Color3.fromRGB(115, 7, 7)
						parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", "Pain")
					end
				end)
				parent2.Skills.Rage.Bar.Size = UDim2.new(1 - v11 / v10, 0, 0.2, 0)
				mobileRage.Bar.Size = UDim2.new(1 - v11 / v10, 0, 0.2, 0)
				local tween = TweenService:Create(parent2.Skills.Rage.Bar, TweenInfo.new((math.max(0.1, v10 - v11))), {
					Size = UDim2.new(0, 0, 0.2, 0)
				})
				tween:Play()
				local tween2 = TweenService:Create(mobileRage.Bar, TweenInfo.new((math.max(0.1, v10 - v11))), {
					Size = UDim2.new(0, 0, 0.2, 0)
				})
				tween2:Play()
				task.wait()
				task.spawn(function()
					while task.wait() and character:FindFirstChild("PainTransformed") do

					end

					parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", false)
					parent2.Skills.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					tween:Cancel()
					tween2:Cancel()
					task.defer(painNotTransformed)
				end)
			end

			local painTransformed2 = character:FindFirstChild("PainTransformed")
			addedConnection = character.ChildAdded:Connect(function(child)
				if child.Name == "PainTransformed" then
					painTransformed(child)
				end
			end)

			if painTransformed2 then
				task.defer(painTransformed, painTransformed2)
			else
				task.defer(painNotTransformed)
			end
		else
			parent2.Skills.Rage.TextColor3 = Color3.new(1, 1, 1)
			mobileRage.TextColor3 = Color3.new(1, 1, 1)

			if v9 == "Shadow-Shadow" then
				parent2.Skills.Rage.Text = "Umbra Meter"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(0.33, 0, 1)
				mobileRage.Text = "Umbra Meter"
				mobileRage.Bar.BackgroundColor3 = Color3.new(0.33, 0, 1)
			elseif v9 == "Gas-Gas" then
				parent2.Skills.Rage.Text = "Gas Meter"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(0.811765, 0.482353, 1)
				mobileRage.Text = "Gas Meter"
				mobileRage.Bar.BackgroundColor3 = Color3.new(0.811765, 0.482353, 1)
			elseif v9 == "Sound-Sound" then
				parent2.Skills.Rage.Text = "Tempo Meter"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 1, 1)
				mobileRage.Text = "Tempo Meter"
				mobileRage.Bar.BackgroundColor3 = Color3.new(1, 1, 1)
				task.spawn(function()
					local maxTempoActive = parent:WaitForChild("MaxTempoActive", 10)

					if maxTempoActive then
						maxTempoActive.Changed:Connect(function()
							parent2.Skills.Rage.Bar.BackgroundColor3 = maxTempoActive.Value and Color3.new(1, 0.9, 0.1) or Color3.new(
								1,
								1,
								1
							)
							mobileRage.Bar.BackgroundColor3 = maxTempoActive.Value and Color3.new(1, 0.9, 0.1) or Color3.new(
								1,
								1,
								1
							)
						end)
					end
				end)
			else
				parent2.Skills.Rage.Text = "Fury Meter"
				parent2.Skills.Rage.Bar.BackgroundColor3 = Color3.new(1, 0, 0)
				mobileRage.Text = "Fury Meter"
				mobileRage.Bar.BackgroundColor3 = Color3.new(1, 0, 0)
			end

			if rageConnection then
				rageConnection:Disconnect()
				rageConnection = nil
			end

			if soulsConnection then
				soulsConnection:Disconnect()
				soulsConnection = nil
			end

			task.defer(function()
				local rage = character:WaitForChild("Rage")

				if not rageConnection then
					rageConnection = rage.Changed:Connect(function()
						parent2.Skills.Rage.Bar.Size = UDim2.fromScale(rage.Value / 100, 0.2)
						mobileRage.Bar.Size = UDim2.fromScale(rage.Value / 100, 0.2)
					end)
					parent2.Skills.Rage.Bar.Size = UDim2.new(rage.Value / 100, 0, 0.2, 0)
					mobileRage.Bar.Size = UDim2.fromScale(rage.Value / 100, 0.2)
				end
			end)
		end

		if flag then
			parent2.Skills.Rage.Visible = false
			mobileRage.Visible = false
		else
			parent2.Skills.Rage.Visible = not isNewUIEnabled
			mobileRage.Visible = isNewUIEnabled
		end
	else
		parent2.Skills.Rage.Visible = false
		mobileRage.Visible = false
	end

	if character:GetAttribute("PainLastStandClientApplied") and v9 == "Pain-Pain" then
		parent2.Skills.Rage.Fire:SetAttribute("ParticleEnabled", "Pain")
		parent2.Skills.BackgroundColor3 = Color3.fromRGB(115, 7, 7)
	else
		parent2.Skills.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	end

	local v10 = 0.937 - #clones * 0.2 * 0.42
	parent2.Skills.Position = UDim2.new(0.83, -10, v10, -10)
	parent2.Skills.Title.Text = string.upper((fruitName(v9)))
	clone.Visible = true
	syncCreationBuildModeUi(playerGui, parent, clone)
	parent2.MobileMasteryLevel.Visible = isNewUIEnabled

	if not isNewUIEnabled then
		parent2.Skills.Visible = true
	end
end