local createVector = vector.create
require(game.ReplicatedStorage.MovesetTypes)
local HttpService = game:GetService("HttpService")
local require2 = require
local v = {
	Z = Enum.KeyCode.Z,
	X = Enum.KeyCode.X,
	C = Enum.KeyCode.C,
	V = Enum.KeyCode.V,
	F = Enum.KeyCode.F,
	TAP = Enum.KeyCode.G
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isAwakenedSet(p)
	return string.match(p.Name, "%(Awakened%)$") ~= nil
end

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Display = require(game.ReplicatedStorage.Packages.Display)
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local InputTelemetryController = require(game.ReplicatedStorage.Controllers.InputTelemetryController)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local spawnFunction = require(game.ReplicatedStorage.Util.spawnFunction)
local Global = require(game.ReplicatedStorage.Global)
local Inventory = require(game.ReplicatedStorage.Controllers.UI.Inventory)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local Notification = require(game.ReplicatedStorage.Notification)
local GamepadConversion = require(game.ReplicatedStorage.GamepadConversion)
local FruitSkills = require(game.ReplicatedStorage.FruitSkills)
local Mouse = require(game.ReplicatedStorage.Mouse)
local FruitSkillUtil = require(game.ReplicatedStorage.Modules.FruitSkillUtil)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v2 = LoggerBuilder.new():tag("Fruit"):display(Display.JSON.new():setOverride(function(p, _, _, _)
	if p == Global then
		return "_G*"
	end

	if p == shared then
		return "shared*"
	end

	return nil
end):build()):traceback():build()
local v3 = {}

for k, v4 in v do
	v3[v4] = k
end

local function triggerFor(p)
	local v4 = v3[p]
	return v4 or string.upper((string.char(p.Value)))
end

local function fruitName(value: string)
	local v4 = string.match(value, "(((%u)%-?)([^-.]+))$")
	return v4 or value
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
	local v4 = fruitSkill and fruitSkill[awakenedMovesetName and 2 or 1]

	if type(v4) ~= "table" then
		return nil
	end

	for _, v5 in v4 do
		if v5[1] == p and type(v5[3]) == "string" then
			return v5[3]
		end
	end

	return nil
end

local function getToolMoveset(instance)
	local moveset = instance:FindFirstChild("Moveset")

	if not (moveset and moveset:IsA("ModuleScript")) then
		return nil
	end

	local require3 = require
	local success, result = pcall(require3, moveset)

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

local function getToolMovesetSkillName(parent, p: string, flag: boolean)
	local toolMoveset = getToolMoveset(parent)

	if not toolMoveset then
		return nil
	end

	local awakened

	if type(toolMoveset.Awakened) == "table" then
		awakened = toolMoveset.Awakened
	end

	local v4 = flag and awakened and awakened[p] ~= nil
	local v5

	if v4 then
		v5 = awakened[p]
	else
		v5 = toolMoveset[p]
	end

	local movesetEntry, v6 = normalizeMovesetEntry(p, v5)

	if movesetEntry and v6 then
		if flag and not v4 and string.match(movesetEntry, "%(Awakened%)$") == nil then
			movesetEntry = `{movesetEntry} (Awakened)`
		end

		return (getFruitSkillName(movesetEntry, v6))
	else
		return nil
	end
end

local function getStreamedBindingSkillName(parent, childName: string, flag: boolean)
	local localPlayer = game.Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
	local movesetModules = playerGui and playerGui:FindFirstChild("MovesetModules")
	local child = movesetModules and movesetModules:FindFirstChild(parent.Name)
	local bindings = child and child:FindFirstChild("Bindings")
	local child2 = bindings and bindings:FindFirstChild(childName)

	if not child2 then
		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function nameFor(flag2: boolean)
		local attribute = child2:GetAttribute(flag2 and "AwakenedMoveset" or "Moveset")

		if type(attribute) ~= "string" then
			return nil
		end

		local attribute2 = child2:GetAttribute(flag2 and "AwakenedMove" or "Move")

		if type(attribute2) ~= "string" then
			attribute2 = childName
		end

		return (getFruitSkillName(attribute, attribute2))
	end

	if flag then
		local v4 = nameFor(true) -- equivalent call inferred; original call site unknown

		if v4 then
			return v4
		end
	end

	local moveset = child2:GetAttribute("Moveset")

	if type(moveset) ~= "string" then
		return nil
	end

	local move = child2:GetAttribute("Move")

	if type(move) ~= "string" then
		move = childName
	end

	return (getFruitSkillName(moveset, move))
end

local function createFruitClient(p, p2, LegacyDataAggregate)
	local MobileCombatInput = require(game.ReplicatedStorage.Modules.MobileCombatInput)
	local extended = v2.extend((`"{p.Parent and p.Parent.Name}" script`))
	extended.info((`fn called: (script={p})`))
	extended.trace(function()
		return "env", p2
	end)
	local lastTime = tick()
	local parent = p.Parent
	local v4 = assert(LegacyDataAggregate, (`FruitClient requires moveset data for {parent.Name}`))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCooldownScale(p3: string)
		return parent:GetAttribute("Cooldown" .. p3) or 1
	end

	local function isKeyAwakened(childName: string)
		local awakenedMoves = parent:FindFirstChild("AwakenedMoves")

		if not (awakenedMoves and awakenedMoves:FindFirstChild(childName)) then
			return false
		end

		local awakening = v4.Awakening
		return awakening ~= nil and (awakening.Cost[childName] ~= nil or awakening.Cooldown[childName] ~= nil)
	end

	extended.trace(function()
		return "data", v4
	end)

	if not parent.Parent then
		extended.trace("returning early because no tool parent")
		return
	end

	if not parent.Parent:IsA("Model") then
		repeat
			parent.AncestryChanged:Wait()
		until parent.Parent:IsA("Model")
	end

	if not parent:FindFirstChild("RemoteEvent") then
		repeat
			task.wait()
		until parent:FindFirstChild("RemoteEvent")
	end

	local v5 = nil
	parent.ChildAdded:Connect(function(remoteEvent)
		if remoteEvent:GetAttribute("Legacy") and remoteEvent:IsA("RemoteEvent") then
			v5 = remoteEvent
			v5.Name = "LegacyRemoteEvent"
		end
	end)

	for _, remoteEvent in parent:GetChildren() do
		if not (remoteEvent:GetAttribute("Legacy") and remoteEvent:IsA("RemoteEvent")) then
			continue
		end

		v5 = remoteEvent
		v5.Name = "LegacyRemoteEvent"
		break
	end

	local mousePos = parent:FindFirstChild("MousePos") or parent:FindFirstChild("Mouse")
	local holding = parent:FindFirstChild("Holding")

	if not (mousePos and holding) then
		return
	end

	local nows = {}
	local v6 = Global[""](p, p2)
	v2.trace(function()
		return "xyz", v6
	end)
	local localPlayer = game.Players.LocalPlayer
	localPlayer:GetMouse()
	local character = localPlayer.Character
	assert(character, "bad char")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	assert(humanoidRootPart, "bad hrp")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	assert(humanoid, "bad humanoid")
	local flag = false
	local v7 = {}
	local v8 = {}

	local function getSpeed(p3: string?)
		local toolTip = parent.ToolTip or "poasjdghjoisadhjg"
		local v10 = toolTip == "Blox Fruit" and "Fruit" or toolTip
		local attribute = character:GetAttribute(v10 .. "Cooldown") or 0
		local allCooldown = character:GetAttribute("AllCooldown") or 0
		assert(attribute and allCooldown, "bad cds")
		local attribute2

		if p3 then
			attribute2 = character:GetAttribute(v10 .. tostring(p3) .. "Cooldown") or 0

			if p3 == "TAP" then
				attribute = 0
				allCooldown = 0
			end
		else
			attribute2 = 0
		end

		return (1 - (attribute + allCooldown + attribute2)) * (localPlayer:GetAttribute("NSUNS") and 0 or 1)
	end

	local v9 = {
		MainCheck = {},
		OtherCheck = {}
	}

	local function animateCooldown(p3, p4: number?, value: number?, flag2: boolean?, p5: number?)
		local extended2 = extended.extend("animateCooldown")
		extended2.info((`fn called: (input={p3}, f={p4}, fast={value})`))
		local v10 = v3[p3] or string.upper((string.char(p3.Value)))

		if v10 == "TAP" then
			return
		end

		local child = game.Players.LocalPlayer.PlayerGui.Main.Skills:WaitForChild(parent.Name, 0.1)

		if not child then
			v2.warn((`failed to find skills gui for {parent.Name}`))
			return
		end

		local child2 = child:FindFirstChild(v10)

		if not child2 then
			v2.warn((`failed to find skills gui key for {v10}`))
		elseif child2 then
			local v11 = value or 0
			assert(v11, "bad fast")
			local speed = getSpeed(v10)
			local cooldown = child2:FindFirstChild("Cooldown")
			assert(cooldown and cooldown:IsA("GuiObject"), "bad frame at \"Cooldown\"")

			if p5 ~= nil then
				local v12 = math.clamp(cooldown.Size.X.Scale, 0, 1)
				v11 = p5 <= 0 and 1 or not (v12 > 0) and 0 or 1 - v12
			end

			cooldown.Size = UDim2.new(1 - v11, 0, 1, -1)
			cooldown:TweenSize(UDim2.new(1 - v11, 0, 1, -1), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0, true)

			if p4 == 0 then
				local v12 = v4.Cooldown[v10]

				if type(v12) == "function" then
					v12 = v12(parent)
				end

				local v13 = (v12 or 1) * getCooldownScale(v10)
				local awakenedMoves = parent:FindFirstChild("AwakenedMoves")
				local v14

				if awakenedMoves and awakenedMoves:FindFirstChild(v10) then
					local awakening = v4.Awakening

					if awakening == nil then
						v14 = false
					else
						v14 = awakening.Cost[v10] ~= nil or awakening.Cooldown[v10] ~= nil
					end
				else
					v14 = false
				end

				if v14 then
					if not v4.Awakening then
						extended2.fatal(function()
							return "no awakening set for", v4
						end)
					end

					assert(v4.Awakening, "no awakening set for data")
					local v15 = v4.Awakening.Cooldown[v10]

					if type(v15) == "function" then
						v15 = v15(parent)
					end

					v13 = (v15 or 1) * getCooldownScale(v10)
				end

				local v15 = p5 or v13 * speed * 1.5 * (1 - v11)
				game.ReplicatedStorage.Events.PlaySkillCooldownAnimation:Fire(parent.Name, v10, v15)
				cooldown:TweenSize(UDim2.new(0, 0, 1, -1), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, v15, true)
				v7[v10] = false

				local function loop(value2: number, p6: string)
					v9[p6][v10] = (v9[p6][v10] or 0) + 1
					local v16 = v9[p6][v10]
					local v17 = value2 or 1
					assert(v17, "bad alpha")
					local lastTime2 = tick()
					local v18 = false

					while true do
						local v19 = tick() - lastTime2

						if v16 ~= v9[p6][v10] then
							v18 = true
							break
						end

						local speed2 = getSpeed(v10)

						if speed2 == 0 then
							break
						end

						local v20 = (p5 or v13 * speed2 * 1.5 * (1 - v11)) * v17

						if v20 ~= v20 then
							break
						end

						if v20 <= v19 then
							if v17 ~= 1 then
								break
							end

							pcall(function()
								cooldown:TweenSize(
									UDim2.new(0, 0, 1, -1),
									Enum.EasingDirection.Out,
									Enum.EasingStyle.Linear,
									0,
									true
								)
							end)
							break
						else
							task.wait()
						end
					end

					return not v18
				end

				if flag2 == false then
					v9.OtherCheck[v10] = (v9.OtherCheck[v10] or 0) + 1
				else
					coroutine.resume(coroutine.create(function()
						if loop(0.6, "OtherCheck") then
							v7[v10] = true
						end
					end))
				end

				if loop(1, "MainCheck") then
					v7[v10] = false
				end
			elseif p4 == 1 then
				cooldown.Size = UDim2.new(0, 0, 1, -1)
				cooldown:TweenSize(UDim2.new(0, 0, 1, -1), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0, true)
			end
		end
	end

	local v10 = {}

	function v10.add(p3, p4, p5)
		local extended2 = extended.extend((`add-{p3}`))
		extended2.info((`called fn: (key={p3}, func={p4}, funcAwakening={p5})`))
		v10[p3] = {
			p4,
			true,
			false,
			p5
		}
		extended2.trace(function()
			return "current attacks", v10
		end)
		local v11 = v3[p3] or string.upper((string.char(p3.Value)))

		if p3 == Enum.KeyCode.V then
			if v4.Lvl and v4.Lvl[v11] then
				v10[p3][2] = false
				task.spawn(function()
					v8[p3] = (v8[p3] or 0) + 1
					local v12 = v8[p3]
					local level = parent:WaitForChild("Level", 10)
					assert(level, "no tool level found")
					local v13 = v4.Lvl[v11]
					assert(v13, "bad data level")

					if v13 <= level.Value then
						local v14 = v11
						local awakenedMoves = parent:FindFirstChild("AwakenedMoves")
						local v15

						if awakenedMoves and awakenedMoves:FindFirstChild(v14) then
							local awakening = v4.Awakening

							if awakening == nil then
								v15 = false
							else
								v15 = awakening.Cost[v14] ~= nil or awakening.Cooldown[v14] ~= nil
							end
						else
							v15 = false
						end

						local v16 = v4.Cooldown[v11]

						if type(v16) == "function" then
							v16 = v16(parent)
						end

						local v17 = (v16 or 1) * getCooldownScale(v11)

						if v15 then
							local awakening = v4.Awakening
							assert(awakening, "bad awakening data")
							local v18 = awakening.Cooldown[v11]

							if type(v18) == "function" then
								v18 = v18(parent)
							end

							v17 = (v18 or 1) * getCooldownScale(v11)
						end

						animateCooldown(p3, 0, (tick() - lastTime) / (v17 * 1.5 * getSpeed(p3) * 0.5))
					end

					if v12 == v8[p3] then
						v10[p3][2] = true
					end
				end)
			end
		else
			local v12 = v11 .. string.gsub(parent.ToolTip, " ", "") .. "CooldownClient"
			local attribute = character:GetAttribute(v12)

			if attribute then
				v10[p3][2] = false
				task.spawn(function()
					local v13 = v8[v11]
					local v14 = v11
					local awakenedMoves = parent:FindFirstChild("AwakenedMoves")
					local v15

					if awakenedMoves and awakenedMoves:FindFirstChild(v14) then
						local awakening = v4.Awakening

						if awakening == nil then
							v15 = false
						else
							v15 = awakening.Cost[v14] ~= nil or awakening.Cooldown[v14] ~= nil
						end
					else
						v15 = false
					end

					local v16 = v4.Cooldown[v11]

					if type(v16) == "function" then
						v16 = v16(parent)
					end

					local v17 = (v16 or 1) * getCooldownScale(v11)

					if v15 then
						local awakening = v4.Awakening
						assert(awakening, "bad awakening data")
						local v18 = awakening.Cooldown[v11]

						if type(v18) == "function" then
							v18 = v18(parent)
						end

						v17 = (v18 or 1) * getCooldownScale(v11)
					end

					local v18 = v17 * 1.5 * getSpeed(p3)
					local v19 = attribute + v18
					animateCooldown(p3, 0, not (v18 > 0) and 1 or (tick() - attribute) / v18)
					local v20 = v19 - tick()

					if v20 > 0 then
						task.wait(v20)
					end

					if v8[v11] == v13 then
						v10[p3][2] = true
					end
				end)
			else
				extended2.trace((`returning early, character lacks value for attribute key "{v12}"`))
			end
		end
	end

	function v10.setCooldown(p3, p4: number)
		local v11 = v10[p3]

		if not v11 then
			return
		end

		local v12 = v3[p3] or string.upper((string.char(p3.Value)))
		v8[v12] = (v8[v12] or 0) + 1
		local v13 = v8[v12]
		local v14 = v4.Cooldown[v12]
		local awakenedMoves = parent:FindFirstChild("AwakenedMoves")
		local v15

		if awakenedMoves and awakenedMoves:FindFirstChild(v12) then
			local awakening = v4.Awakening

			if awakening == nil then
				v15 = false
			else
				v15 = awakening.Cost[v12] ~= nil or awakening.Cooldown[v12] ~= nil
			end
		else
			v15 = false
		end

		if v15 and v4.Awakening then
			v14 = v4.Awakening.Cooldown[v12]
		end

		if type(v14) == "function" then
			v14 = v14(parent)
		end

		local v16 = (v14 or 1) * getCooldownScale(v12) * 1.5 * getSpeed(v12)
		local v17 = not (v16 > 0) and 1 or math.clamp(1 - p4 / v16, 0, 1)
		character:SetAttribute(v12 .. string.gsub(parent.ToolTip, " ", "") .. "CooldownClient", tick() - v16 * v17)
		local v18 = tick() + math.max(0, p4)
		local v19 = humanoidRootPart:FindFirstChild("Heightened Senses") == nil
		v11[2] = false
		task.spawn(function()
			animateCooldown(p3, 0, nil, v19, math.max(0, p4))
			local v20 = v18 - tick()

			if v20 > 0 then
				task.wait(v20)
			end

			if v8[v12] == v13 then
				v11[2] = true
			end
		end)
	end

	if parent.Name == "Dragon (Classic)-Dragon (Classic)" then
		if parent:GetAttribute("ClassicEnabled") == nil then
			parent:GetAttributeChangedSignal("ClassicEnabled"):Wait()
		end

		if not parent:GetAttribute("ClassicEnabled") then
			parent:SetAttribute("ImageColor3", Color3.fromRGB(75, 75, 75))
		end

		parent:GetAttributeChangedSignal("ClassicEnabled"):Connect(function()
			if parent:GetAttribute("ClassicEnabled") then
				parent:SetAttribute("ImageColor3", Color3.fromRGB(255, 255, 255))
			else
				parent:SetAttribute("ImageColor3", Color3.fromRGB(75, 75, 75))
			end
		end)
	end

	local v11 = false

	local function casFunc(p3: string, p4, currentTouchObjectForMouse, p5)
		if Global.fruitSwapTimeLockout and Global.fruitSwapTimeLockout > tick() then
			return
		end

		if Global.CurrentlyStoringItem == parent.Name then
			Global.TestGameWarn("trying to use ability from storing item")
			return
		end

		if currentTouchObjectForMouse.UserInputState == Enum.UserInputState.Begin and parent.Name == "Dragon (Classic)-Dragon (Classic)" and not parent:GetAttribute("ClassicEnabled") then
			return
		end

		if p5 and typeof(p5) ~= "EnumItem" and p5.EnumType ~= Enum.KeyCode then
			p5 = nil
		end

		if not game.Players.LocalPlayer.PlayerGui.Main.Skills:WaitForChild(parent.Name, 0.1) then
			Global.TestGameWarn("failed to find key")
			return
		end

		local v12 = p5 or currentTouchObjectForMouse.KeyCode
		local fn = localPlayer:GetAttribute("AAIM") and function()
			local localPlayer2 = game.Players.LocalPlayer
			assert(localPlayer2.Character, "bad character")
			local position = localPlayer2.Character:GetPivot().Position
			local v13 = 1e999
			local v14 = nil

			for _, v15 in pairs(game.Players:GetPlayers()) do
				if v15 == localPlayer2 then
					continue
				end

				assert(v15.Character, "bad character")
				local position2 = v15.Character:GetPivot().Position
				local magnitude = (position2 - position).Magnitude

				if v15.Character and magnitude < v13 then
					v14 = position2
				end
			end

			return v14
		end or nil
		local ignoreCooldowns = parent:GetAttribute("IgnoreCooldowns")
		local GANKS = localPlayer:GetAttribute("GANKS")
		local gANKSvolley = localPlayer:GetAttribute("GANKSvolley")
		local _, v13 = GamepadConversion.changeBtns(v12)
		local v14 = v13 or v12
		local v15 = v3[v14] or string.upper((string.char(v14.Value)))

		if currentTouchObjectForMouse.UserInputState == Enum.UserInputState.Begin then
			InputTelemetryController.recordAbilityIntent(v15, currentTouchObjectForMouse)
		end

		local v16

		if v15 == "X" and parent:GetAttribute("IsBratSlayerSkin") == true then
			v16 = character:GetAttribute("DogSlayerForm") ~= true
		else
			v16 = false
		end

		if v15 == "TAP" and not gANKSvolley then
			if LastInput.IsMobile() and MobileCombatInput.isM1Blocked() then
				return
			end

			if (Global.tapCooldown or 0) > os.clock() then
				Global.TestGameWarn("tapCooldown")
				return
			elseif Global.mobileSoru then
				return Global.TestGameWarn("mobileSoru")
			end
		end

		local v17 = v4.Cost[v15]
		local v18 = v4.Lvl[v15]
		local awakenedMoves = parent:FindFirstChild("AwakenedMoves")
		local v19

		if awakenedMoves and awakenedMoves:FindFirstChild(v15) then
			local awakening = v4.Awakening

			if awakening == nil then
				v19 = false
			else
				v19 = awakening.Cost[v15] ~= nil or awakening.Cooldown[v15] ~= nil
			end
		else
			v19 = false
		end

		if v19 then
			assert(v4.Awakening, "bad awakening")
			v17 = v4.Awakening.Cost[v15]
		end

		if not v17 then
			return
		end

		local toolTip = parent.ToolTip
		local v20 = toolTip == "Blox Fruit" and "Fruit" or toolTip
		local v21 = (character:GetAttribute("MasterpieceAll") or character:GetAttribute("Masterpiece" .. v20)) and 0 or v17

		if currentTouchObjectForMouse.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		local level = parent:FindFirstChild("Level")
		assert(level, "bad tool level value")
		assert(v18, "bad level")

		if level.Value < v18 then
			Notification.new("<Color=Red>Skill locked!<Color=/> Mastery Lv. " .. v18 .. " required."):Display()
			return
		end

		local energy = character:FindFirstChild("Energy")
		assert(energy, "bad char energy value")

		if energy.Value < v21 then
			Notification.new("<Color=Red>Low energy!<Color=/> <Color=Blue>" .. v21 .. " Energy<Color=/> required."):Display()
			return
		end

		if localPlayer.UserId ~= 3095250 and localPlayer.UserId ~= 45124586 then
			if character:FindFirstChild("Dragon") and not parent.Name:find("-Dragon") or character:FindFirstChild("GasRig") and parent.Name ~= "Gas-Gas" then
				return
			end

			if character:FindFirstChild("HydraRig") and parent.Name ~= "Venom-Venom" or character:FindFirstChild("TigerRig") and parent.Name ~= "Tiger-Tiger" and parent.Name ~= "Werewolf (Tiger)-Werewolf (Tiger)" then
				return
			end

			if character:FindFirstChild("YetiRig") and parent.Name ~= "Yeti-Yeti" and parent.Name ~= "Fiend (Yeti)-Fiend (Yeti)" or character:FindFirstChild("Mammoth") and parent.Name ~= "Mammoth-Mammoth" then
				return
			end

			if character:FindFirstChild("Kitsune") and parent.Name ~= "Kitsune-Kitsune" and parent.Name ~= "Empyrean (Kitsune)-Empyrean (Kitsune)" or character:FindFirstChild("TRex") and parent.Name ~= "T-Rex-T-Rex" then
				return
			end

			if character:FindFirstChild("Phoenix") and not (game.Players.LocalPlayer.Backpack:FindFirstChild("Portal-Portal") or character:FindFirstChild("Portal-Portal")) then
				if parent.Name ~= "Phoenix-Phoenix" then
					return
				end

				local awakenedMoves2 = parent:FindFirstChild("AwakenedMoves")
				local child = awakenedMoves2 and awakenedMoves2:FindFirstChild(v15)

				if v15 == "F" and not child then
					return
				end
			end
		end

		if tick() - (Global.equipTimer or 0) < 0.1 or tick() - (Global.castTimer or 0) < 0 then
			Global.TestGameWarn("invalid tick")
			return
		end

		local success, result = pcall(function()
			local isSkillBlocked, v22 = FruitSkillUtil.IsSkillBlocked(localPlayer, parent, v15)

			if isSkillBlocked and v22 and currentTouchObjectForMouse.UserInputState == Enum.UserInputState.Begin then
				Notification.new(v22):Display()
			end

			return isSkillBlocked
		end)

		if success then
			if result == true then
				return
			end
		else
			warn(result)
		end

		local busy = character:FindFirstChild("Busy")
		assert(busy, "bad Busy value")
		local stun = character:FindFirstChild("Stun")
		assert(stun, "bad Stun value")

		if v11 == false and humanoid.Sit == false and holding.Value == false and humanoid.Health > 0 and busy.Value == false and stun.Value == 0 and v10[v14] and currentTouchObjectForMouse.UserInputState == Enum.UserInputState.Begin then
			Global.TestGameWarn("go")

			if humanoidRootPart:FindFirstChild("Heightened Senses") and v7[v15] then
				v10[v14][2] = true
				v7[v15] = false
			end

			if not (v10[v14][2] or ignoreCooldowns) then
				Global.TestGameWarn("on cooldown", v10)
				return
			end

			local destroyable = AttributeCounter.destroyable(humanoid, "BlockSit")
			local v22 = {
				["Love-Love"] = true
			}
			Inventory:Close()

			if v15 ~= "TAP" then
				Global.tapCooldown = os.clock() + 10
			end

			Global.castTimer = os.clock() + 30
			Global.busy = parent.Name

			if v5 then
				v5:FireServer(true)
			else
				local parent2 = p.Parent
				assert(parent2, "bad script parent")
				local remoteEvent = parent2:FindFirstChild("RemoteEvent")
				assert(remoteEvent, "bad remote event")
				remoteEvent:FireServer(true)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function sendMouse()
				if not v22[parent.Name] then
					if mousePos:IsA("Vector3Value") then
						if v5 then
							if fn then
								v5:FireServer(fn())
							else
								v5:FireServer(Mouse.Hit.Position)
							end
						else
							local parent2 = p.Parent
							assert(parent2, "bad script parent")
							local remoteEvent = parent2:FindFirstChild("RemoteEvent")
							assert(remoteEvent, "bad remote event")

							if fn then
								remoteEvent:FireServer(fn())
							else
								remoteEvent:FireServer(Mouse.Hit.Position)
							end
						end
					else
						local parent2 = p.Parent
						assert(parent2, "bad script parent")
						local remoteEvent = parent2:FindFirstChild("RemoteEvent")
						assert(remoteEvent, "bad remote event")

						if fn then
							remoteEvent:FireServer(CFrame.new(fn()))
						else
							remoteEvent:FireServer(Mouse.Hit)
						end
					end
				end
			end

			sendMouse()
			holding.Value = true

			if fn then
				task.spawn(function()
					local function fn2()
						local character2 = localPlayer.Character
						assert(character2, "bad character")
						local position = character2:GetPivot().Position
						local v23 = fn()
						local cframe = CFrame.new(v23 + (position - v23).Unit * 15, v23)

						for _, descendant in character2:GetDescendants() do
							if descendant:IsA("BodyGyro") then
								descendant.MaxTorque = createVector(0, 0, 0)
							elseif descendant:IsA("BodyMover") then
								descendant.MaxForce = createVector(0, 0, 0)
							end
						end

						local primaryPart = character2.PrimaryPart
						assert(primaryPart, "bad hrp")
						primaryPart.CFrame = cframe
						character2:PivotTo(cframe)
					end

					fn2()

					if holding and holding.Value then
						holding.Changed:Wait()
					end

					fn2()
				end)
			end

			local mobileId = math.random(99999999)
			Global.mobileId = mobileId

			-- equivalent calls inferred from this helper; original call sites unknown
			local function cancel()
				if mobileId ~= Global.mobileId then
					return
				end

				Global.mobileSelection = nil

				if Global.mobileSelectionFrame then
					Global.mobileSelectionFrame.BackgroundColor3 = Color3.new()
					Global.mobileSelectionFrame = nil
				end
			end

			local awakenedMoves2 = parent:FindFirstChild("AwakenedMoves")
			local v24

			if awakenedMoves2 and awakenedMoves2:FindFirstChild(v15) then
				local awakening = v4.Awakening

				if awakening == nil then
					v24 = false
				else
					v24 = awakening.Cost[v15] ~= nil or awakening.Cooldown[v15] ~= nil
				end
			else
				v24 = false
			end

			local v25 = getStreamedBindingSkillName(parent, v15, v24) or getToolMovesetSkillName(parent, v15, v24)

			if not v25 then
				for _, v27 in FruitSkills[parent.Name][v24 and 2 or 1] do
					if v27[1] ~= v15 then
						continue
					end

					v25 = v27[3]
					break
				end
			end

			local v26 = nil
			local flag2 = false

			local function stopMove()
				if flag2 then
					return
				end

				destroyable:Destroy()

				if v26 then
					game.ReplicatedStorage.Events.SetMobileMouseLockMode:Fire(v26)
				end

				game.ReplicatedStorage.Events.DeactivatedSkill:Fire(parent.Name, v25, parent:GetAttribute("WeaponType"))
				local contextButton = MobileUIController:GetContextButton("Skill_" .. v15)

				if contextButton then
					contextButton.GroupColor3 = Color3.fromRGB(255, 255, 255)
				end

				if flag then
					Global.TestGameWarn("dead")
					return
				end

				sendMouse() -- equivalent call inferred; original call site unknown

				if v5 then
					v5:FireServer(false)
				else
					local parent2 = p.Parent
					assert(parent2, "bad script parent")
					local remoteEvent = parent2:FindFirstChild("RemoteEvent")
					assert(remoteEvent, "bad remote event")
					remoteEvent:FireServer(false)
				end

				Global.TestGameWarn("stopmove")
				holding.Value = false
				cancel() -- equivalent call inferred; original call site unknown
			end

			local sitChangedConnection = nil
			local valueChangedConnection = nil
			local healthChangedConnection = nil
			local unequippedConnection = nil
			local changedConnection = nil

			local function disconnect()
				if changedConnection then
					changedConnection:Disconnect()
				end

				changedConnection = nil

				if unequippedConnection then
					unequippedConnection:Disconnect()
				end

				unequippedConnection = nil

				if healthChangedConnection then
					healthChangedConnection:Disconnect()
				end

				healthChangedConnection = nil

				if valueChangedConnection then
					valueChangedConnection:Disconnect()
				end

				valueChangedConnection = nil

				if sitChangedConnection then
					sitChangedConnection:Disconnect()
				end

				sitChangedConnection = nil
			end

			changedConnection = currentTouchObjectForMouse.Changed:Connect(function(_: string)
				local v27 = currentTouchObjectForMouse.UserInputState == Enum.UserInputState.End
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()

				if v27 or currentTouchObjectForMouse.UserInputState == Enum.UserInputState.End then
					disconnect()
					stopMove()
				end
			end)
			unequippedConnection = parent.Unequipped:Connect(function()
				disconnect()
				stopMove()
			end)
			local health = humanoid.Health
			local v28

			if character:FindFirstChild("Mammoth") and v15 == "F" or character:FindFirstChild("MagnetRig") and (v15 == "X" or v15 == "C") then
				v28 = true
			elseif character:FindFirstChild("MagnetArms") and v15 == "C" then
				local magnetArmFunctions = character:FindFirstChild("MagnetArmFunctions")
				v28 = magnetArmFunctions and magnetArmFunctions:GetAttribute("CurrentTier") == 3 and true or false
			else
				v28 = localPlayer:GetAttribute("RedYeti") and character:FindFirstChild("YetiRig") and v15 == "Z" and true or false
			end

			local lastTime2 = tick()
			healthChangedConnection = humanoid.HealthChanged:Connect(function(p6)
				if character:FindFirstChild("PainTransformed") then
					return
				end

				local toolTip2 = parent.ToolTip
				local v29 = toolTip2 == "Blox Fruit" and "Fruit" or toolTip2

				if p6 < health and character:FindFirstChild("Dragon") == nil and v28 == false and not character:GetAttribute("UnbreakableAll") then
					local v30

					if tick() - lastTime2 > 2 then
						v30 = false
					else
						v30 = character:GetAttribute("Unbreakable" .. v29)
					end

					if not v30 then
						disconnect()
						stopMove()
						return
					end
				end

				health = humanoid.Health
			end)
			local stun2 = character:FindFirstChild("Stun")
			assert(stun2, "bad Stun")
			local value = stun2.Value
			valueChangedConnection = stun2:GetPropertyChangedSignal("Value"):Connect(function()
				local toolTip2 = parent.ToolTip
				local v29 = toolTip2 == "Blox Fruit" and "Fruit" or toolTip2
				local value2 = stun2.Value

				if value <= value2 and character:FindFirstChild("Dragon") == nil and v28 == false and not character:GetAttribute("UnbreakableAll") then
					local v30

					if tick() - lastTime2 > 2 then
						v30 = false
					else
						v30 = character:GetAttribute("Unbreakable" .. v29)
					end

					if not v30 then
						disconnect()
						stopMove()
						return
					end
				end

				value = stun2.Value
			end)
			sitChangedConnection = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
				if humanoid.Sit then
					disconnect()
					stopMove()
				end
			end)

			if v15 == ({
				["Bomb-Bomb"] = "V",
				["Magma-Magma"] = "F"
			})[parent.Name] and healthChangedConnection and valueChangedConnection then
				healthChangedConnection:Disconnect()
				valueChangedConnection:Disconnect()
				healthChangedConnection = nil
				valueChangedConnection = nil
			end

			v11 = true
			local v29

			if not ignoreCooldowns then
				v10[v14][2] = false
				v8[v15] = (v8[v15] or 0) + 1
				v29 = v8[v15]

				if v15 ~= "TAP" then
					animateCooldown(v14)
				end
			end

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
			sendMouse()

			if MobileUIController:GetMobileSkillMode() == 1 then
				v26 = game.ReplicatedStorage.Events.GetCurrentMobileMouseLockMode:Invoke()
				game.ReplicatedStorage.Events.SetMobileMouseLockMode:Fire(3)
			end

			game.ReplicatedStorage.Events.ActivatedSkill:Fire(v25, v15)

			local function run()
				local v30 = nil
				local success2 = nil
				local result2 = nil
				local thread = coroutine.running()
				local v31 = false
				local v32 = v15
				local awakenedMoves3 = parent:FindFirstChild("AwakenedMoves")
				local v33

				if awakenedMoves3 and awakenedMoves3:FindFirstChild(v32) then
					local awakening = v4.Awakening

					if awakening == nil then
						v33 = false
					else
						v33 = awakening.Cost[v32] ~= nil or awakening.Cooldown[v32] ~= nil
					end
				else
					v33 = false
				end

				spawnFunction(function()
					success2, result2 = pcall(function()
						v30 = (v10[v14][v33 and 4 or 1] or v10[v14][1])(p3, p4, currentTouchObjectForMouse)
					end)
					v31 = true
					coroutine.resume(thread)
				end)

				if not v31 then
					coroutine.yield()
				end

				return v30, success2, result2
			end

			local v30 = nil
			local v31 = nil
			local v32

			if GANKS then
				task.spawn(run)
				v32 = true
			elseif gANKSvolley == 2 then
				task.spawn(function()
					while Global.busy do
						for _ = 1, 1000 do
							if mousePos:IsA("Vector3Value") then
								if v5 then
									v5:FireServer(Mouse.Hit.Position)
								else
									local parent2 = p.Parent
									assert(parent2, "bad script parent")
									local remoteEvent = parent2:FindFirstChild("RemoteEvent")
									assert(remoteEvent, "bad remote event")
									remoteEvent:FireServer(Mouse.Hit.Position)
								end
							else
								local parent2 = p.Parent
								assert(parent2, "bad script parent")
								local remoteEvent = parent2:FindFirstChild("RemoteEvent")
								assert(remoteEvent, "bad remote event")
								remoteEvent:FireServer(Mouse.Hit)
							end

							task.wait()
						end
					end
				end)
				run()
				v32 = true
			else
				v30, v32, v31 = run()
			end

			Global.castTimer = tick()
			Global.busy = false

			if v15 ~= "TAP" then
				local now = tick()

				if not nows[v15] or now - nows[v15] > 5 then
					nows[v15] = now
					Global.aimAssistComboReady = now
				end

				Global.tapCooldown = os.clock() + 0.03333333333333333
			end

			if not v32 then
				local name = parent.Name
				warn("[SKILL ERROR] " .. (string.match(name, "(((%u)%-?)([^-.]+))$") or name) .. " " .. tostring(v31))
			end

			disconnect()
			stopMove()
			flag2 = true
			v11 = false

			if not ignoreCooldowns and not v16 and v8[v15] == v29 then
				character:SetAttribute(v15 .. string.gsub(parent.ToolTip, " ", "") .. "CooldownClient", tick())
			end

			if v15 == "TAP" then
				local TAP = v4.Cooldown.TAP
				local awakenedMoves3 = parent:FindFirstChild("AwakenedMoves")
				local v33

				if awakenedMoves3 and awakenedMoves3:FindFirstChild("TAP") then
					local awakening = v4.Awakening

					if awakening == nil then
						v33 = false
					else
						v33 = awakening.Cost.TAP ~= nil or awakening.Cooldown.TAP ~= nil
					end
				else
					v33 = false
				end

				if v33 then
					local awakening = v4.Awakening
					assert(awakening, "bad awakening in data")
					TAP = awakening.Cooldown.TAP
				end

				local speed = getSpeed(v15)
				local v34 = v30 == nil and 0 or 1
				assert(TAP, "bad cd")
				local v35 = TAP * speed * 1.5 * (1 - v34)
				task.wait(v35)
			elseif (not Global.SUPER_COOL_CONTROL_HACK or v15 ~= "F") and not ignoreCooldowns and not v16 and v8[v15] == v29 then
				animateCooldown(v14, v30 == nil and 0 or 1)
			end

			if v8[v15] == v29 and v29 and (not Global.SUPER_COOL_CONTROL_HACK or v15 ~= "F") then
				v10[v14][2] = true
			end
		end
	end

	local inputBeganConnection = nil
	local connection = nil

	local function onEquipped()
		if parent.Parent ~= character then
			return
		end

		v2.extend("Tool.Equipped").info("event fired")
		ContextActionService:BindAction(
			"DevilFruit",
			casFunc,
			false,
			Enum.KeyCode.Z,
			Enum.KeyCode.X,
			Enum.KeyCode.C,
			Enum.KeyCode.V,
			Enum.KeyCode.F
		)

		if UserInputService.GamepadEnabled then
			ContextActionService:BindAction("DevilFruit2", casFunc, false, unpack(GamepadConversion.getButtons()))
		end

		Global.CurrentTouchObjectForMouse = nil
		Global.casFunc = casFunc
		local now = 0
		local mobileM1Hold = parent:GetAttribute("MobileM1Hold")
		local mobileM1Button = parent:GetAttribute("MobileM1Button")

		if inputBeganConnection then
			inputBeganConnection:Disconnect()
			inputBeganConnection = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		local now2 = 0
		local position = nil
		inputBeganConnection = UserInputService.InputBegan:Connect(function(currentTouchObjectForMouse, gameProcessed)
			if gameProcessed or v11 or MobileCombatInput.isGuiTouch(currentTouchObjectForMouse) then
				return
			end

			if Global.mobileSelection == nil then
				if parent.Name == "Dragon-Dragon" then
					return
				end

				if mobileM1Hold then
					if currentTouchObjectForMouse.UserInputType == Enum.UserInputType.Touch then
						now = tick()
						local flag2 = false
						currentTouchObjectForMouse.Changed:Connect(function(p3)
							if p3 == "UserInputState" and currentTouchObjectForMouse.UserInputState == Enum.UserInputState.End then
								if flag2 then
									parent:Deactivate()
								end

								flag2 = nil
							end
						end)
						local v12 = now
						local position2 = currentTouchObjectForMouse.Position
						task.delay(0.2, function()
							if now == v12 and flag2 ~= nil and parent.Parent == character and not v11 and not MobileCombatInput.isM1Blocked() and (position2 - currentTouchObjectForMouse.Position).Magnitude < 20 then
								flag2 = true
								parent:Activate()
							end
						end)
					end
				elseif mobileM1Button then
					if currentTouchObjectForMouse.UserInputType ~= Enum.UserInputType.Touch then
						return
					end

					if position and tick() - now2 < 0.2 then
						if (position - currentTouchObjectForMouse.Position).Magnitude < 20 then
							Global.CurrentTouchObjectForMouse = currentTouchObjectForMouse
							Global.updateMouseWrapper()
							currentTouchObjectForMouse.Changed:Connect(function(p3)
								if p3 == "UserInputState" and currentTouchObjectForMouse.UserInputState == Enum.UserInputState.End then
									if Global.CurrentTouchObjectForMouse == currentTouchObjectForMouse then
										Global.CurrentTouchObjectForMouse = nil
									end

									casFunc(
										"DevilFruit",
										Enum.UserInputState.End,
										currentTouchObjectForMouse,
										Enum.KeyCode.G
									)
								end
							end)
							casFunc("DevilFruit", Enum.UserInputState.Begin, currentTouchObjectForMouse, Enum.KeyCode.G)
						end
					else
						now2 = tick()
						position = currentTouchObjectForMouse.Position
					end
				end
			elseif currentTouchObjectForMouse.UserInputType == Enum.UserInputType.Touch and currentTouchObjectForMouse.UserInputState == Enum.UserInputState.Begin then
				if Global.mobileSelection == "G" and mobileM1Button then
					return
				end

				Global.CurrentTouchObjectForMouse = currentTouchObjectForMouse
				Global.updateMouseWrapper()
				local mobileSelection = Global.mobileSelection
				local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
				currentTouchObjectForMouse.KeyCode = keyCode
				currentTouchObjectForMouse.Changed:Connect(function(p3)
					if p3 == "UserInputState" and currentTouchObjectForMouse.UserInputState == Enum.UserInputState.End and Global.CurrentTouchObjectForMouse == currentTouchObjectForMouse then
						Global.CurrentTouchObjectForMouse = nil
					end
				end)
				casFunc("DevilFruit", Enum.UserInputState.Begin, currentTouchObjectForMouse, keyCode)
			end
		end)
	end

	parent.Equipped:Connect(onEquipped)

	if parent.Parent == character then
		task.defer(onEquipped)
	end

	parent.Activated:Connect(function()
		if v11 or LastInput.IsMobile() and MobileCombatInput.isM1Blocked() then
			return
		end

		if parent:GetAttribute("MobileM1Button") and LastInput:IsMobile() and parent.Name ~= "Dragon-Dragon" or Global.CurrentTouchObjectForMouse or Global.mobileSoru == true then
			return
		end

		local v12 = {
			KeyCode = Enum.KeyCode.G,
			UserInputState = Enum.UserInputState.Begin,
			Changed = parent.Deactivated,
			Position = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
		}
		local deactivatedConnection = nil
		deactivatedConnection = parent.Deactivated:Connect(function()
			assert(deactivatedConnection, "bad connection")
			deactivatedConnection:Disconnect()
			deactivatedConnection = nil
			assert(v12, "bad tab")
			v12.Position = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
			v12.UserInputState = Enum.UserInputState.End
		end)
		casFunc("DevilFruit", Enum.UserInputState.Begin, Global.CurrentTouchObjectForMouse or v12, Enum.KeyCode.G)
	end)
	parent.Unequipped:Connect(function()
		if Global.stopGunAnims then
			Global.stopGunAnims()
		end

		ContextActionService:UnbindAction("DevilFruit")
		ContextActionService:UnbindAction("DevilFruit2")

		if inputBeganConnection then
			inputBeganConnection:Disconnect()
			inputBeganConnection = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)

	local function died()
		flag = true
		Global.busy = nil

		if inputBeganConnection then
			inputBeganConnection:Disconnect()
			inputBeganConnection = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	humanoid.Died:Connect(died)
	character.AncestryChanged:Connect(died)
	v10.animateCooldown = animateCooldown
	return v10
end

return function(script)
	local parent = script.Parent
	local localPlayer = game.Players.LocalPlayer
	local movesetModules = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MovesetModules")

	local function findContainer()
		local movesetToolUid = parent:GetAttribute("MovesetToolUid")
		local child = movesetModules:FindFirstChild(parent.Name)

		if movesetToolUid == nil or not child or child:GetAttribute("MovesetToolUid") ~= movesetToolUid then
			return nil
		end

		return child
	end

	local movesetToolUid = parent:GetAttribute("MovesetToolUid")
	local child = movesetModules:FindFirstChild(parent.Name)

	if movesetToolUid == nil or not child or child:GetAttribute("MovesetToolUid") ~= movesetToolUid then
		child = nil
	end

	while not child do
		task.wait()
		local movesetToolUid2 = parent:GetAttribute("MovesetToolUid")
		child = movesetModules:FindFirstChild(parent.Name)

		if movesetToolUid2 == nil or not child or child:GetAttribute("MovesetToolUid") ~= movesetToolUid2 then
			child = nil
		end
	end

	local LegacyDataAggregate = require2((child:WaitForChild("LegacyDataAggregate")))
	local v5 = {
		event = parent:WaitForChild("RemoteEvent"),
		func = parent:WaitForChild("RemoteFunction")
	}

	local function readStringAttribute(instance, attributeName: string)
		local attribute = instance:GetAttribute(attributeName)

		if type(attribute) == "string" then
			return attribute
		end

		return nil
	end

	local deepCopy

	deepCopy = function(items)
		if type(items) ~= "table" then
			return items
		end

		local result = {}

		for k, item in items do
			result[k] = deepCopy(item)
		end

		return result
	end

	local deepMerge

	deepMerge = function(p2, items)
		if type(p2) ~= "table" or type(items) ~= "table" then
			return p2
		end

		for k, item in items do
			if type(item) == "table" and type(p2[k]) == "table" then
				deepMerge(p2[k], item)
			else
				p2[k] = deepCopy(item)
			end
		end

		return p2
	end

	local function readOverrides(instance, attributeName: string)
		local attribute = instance:GetAttribute(attributeName)

		if type(attribute) ~= "string" then
			attribute = nil
		end

		if not attribute then
			return nil
		end

		local jSONDecode = HttpService:JSONDecode(attribute)

		if type(jSONDecode) == "table" then
			return jSONDecode
		end

		return nil
	end

	local function applyOverrides(p2, p3)
		if p2 and type(p3) == "table" then
			return (deepMerge(deepCopy(p2), p3))
		end

		return p2
	end

	local function findMoveFolder(childName: string?, childName2: string?)
		if not (childName and childName2) then
			return nil, nil
		end

		local folder = child:FindFirstChild(childName)
		local folder2 = folder and folder:FindFirstChild(childName2)

		if folder and folder:IsA("Folder") then
			if folder2 and folder2:IsA("Folder") then
				return folder, folder2
			end

			return folder, nil
		else
			return nil, nil
		end
	end

	local function parseBindingFolder(folder)
		if not folder:IsA("Folder") then
			return nil
		end

		local moveset = folder:GetAttribute("Moveset")

		if type(moveset) ~= "string" then
			moveset = nil
		end

		local move = folder:GetAttribute("Move")

		if type(move) ~= "string" then
			move = nil
		end

		local move2 = move or folder.Name

		if not moveset then
			return nil
		end

		local v7 = {
			key = folder.Name,
			moveset = moveset,
			move = move2,
			sharedOverrides = 0,
			awakenedMoveset = 0,
			awakenedMove = 0,
			awakenedSharedOverrides = 0
		}
		local sharedOverrides = folder:GetAttribute("SharedOverrides")

		if type(sharedOverrides) ~= "string" then
			sharedOverrides = nil
		end

		local sharedOverrides2

		if sharedOverrides then
			sharedOverrides2 = HttpService:JSONDecode(sharedOverrides)

			if type(sharedOverrides2) ~= "table" then
				sharedOverrides2 = nil
			end
		end

		v7.sharedOverrides = sharedOverrides2
		local awakenedMoveset = folder:GetAttribute("AwakenedMoveset")

		if type(awakenedMoveset) ~= "string" then
			awakenedMoveset = nil
		end

		v7.awakenedMoveset = awakenedMoveset
		local awakenedMove = folder:GetAttribute("AwakenedMove")

		if type(awakenedMove) ~= "string" then
			awakenedMove = nil
		end

		v7.awakenedMove = awakenedMove or move2
		local awakenedSharedOverrides = folder:GetAttribute("AwakenedSharedOverrides")

		if type(awakenedSharedOverrides) ~= "string" then
			awakenedSharedOverrides = nil
		end

		local awakenedSharedOverrides2

		if awakenedSharedOverrides then
			awakenedSharedOverrides2 = HttpService:JSONDecode(awakenedSharedOverrides)

			if type(awakenedSharedOverrides2) ~= "table" then
				awakenedSharedOverrides2 = nil
			end
		end

		v7.awakenedSharedOverrides = awakenedSharedOverrides2
		return v7
	end

	local function readBindings()
		local bindings = child:FindFirstChild("Bindings")

		if bindings and bindings:IsA("Folder") then
			local result = {}

			for _, child2 in bindings:GetChildren() do
				local v6 = parseBindingFolder(child2)

				if v6 then
					table.insert(result, v6)
				end
			end

			return result
		else
			local v6 = {}

			for _, folder in child:GetChildren() do
				if not folder:IsA("Folder") then
					continue
				end

				for _, folder2 in folder:GetChildren() do
					if not folder2:IsA("Folder") then
						continue
					end

					local name = folder2.Name
					local v7 = v6[name]

					if not v7 then
						v7 = {
							key = name,
							moveset = "",
							move = name
						}
						v6[name] = v7
					end

					if isAwakenedSet(folder) then
						v7.awakenedMoveset = folder.Name
						v7.awakenedMove = name
					else
						v7.moveset = folder.Name
						v7.move = name
					end
				end
			end

			local result = {}

			for _, v7 in v6 do
				table.insert(result, v7)
			end

			return result
		end
	end

	local fruitClient = createFruitClient(script, {
		script = script
	}, LegacyDataAggregate)

	if not fruitClient then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	local holding = parent:WaitForChild("Holding")
	local mousePos = parent:FindFirstChild("MousePos") or parent:WaitForChild("Mouse")

	local function remotesFor(p2: string, p3: string)
		if p2 == p3 then
			return v5
		end

		return {
			event = v5.event,
			func = {
				InvokeServer = function(self, p4, ...)
					if p4 == p3 then
						p4 = p2
					end

					return v5.func:InvokeServer(p4, ...)
				end
			}
		}
	end

	local function buildCtx(instance, instance2, p2, p3)
		local v6 = {
			player = localPlayer,
			character = character,
			humanoid = humanoid,
			rootPart = humanoidRootPart,
			tool = parent,
			camera = workspace.CurrentCamera,
			mouse = Mouse,
			holdingInstance = holding,
			mousePosInstance = mousePos,
			remotes = p2 or v5,
			shared = 0,
			movesetShared = 0,
			data = 0,
			aim = 0
		}
		local Shared

		if instance2 then
			Shared = require2((instance2:WaitForChild("Shared")))

			if Shared and type(p3) == "table" then
				Shared = deepMerge(deepCopy(Shared), p3)
			end
		end

		v6.shared = Shared
		v6.movesetShared = require2((instance:WaitForChild("Shared")))
		v6.data = LegacyDataAggregate

		function v6.aim(_)
			return Mouse.Hit.Position
		end

		return v6
	end

	local function handlerFor(moveFolder, instance, key: string, p2: string, p3)
		local Client = require2((instance:WaitForChild("Client")))
		local ctx = buildCtx(moveFolder, instance, remotesFor(key, p2), p3)
		return function(p4: string, p5, p6)
			return Client.onInput(ctx, p4, p5, p6)
		end
	end

	local function runMovesetSetup(folder)
		if folder:IsA("Folder") and folder.Name ~= "Bindings" then
			local client = folder:FindFirstChild("Client")
			local module

			if client then
				module = require2(client)
			end

			if module and module.setup then
				module.setup((buildCtx(folder, nil)))
			end
		end
	end

	for _, child2 in child:GetChildren() do
		runMovesetSetup(child2)
	end

	child.ChildAdded:Connect(runMovesetSetup)
	local v6 = {}

	local function registerBinding(data)
		local v7 = v[data.key]

		if not v7 then
			return false
		end

		local moveFolder, v8 = findMoveFolder(data.moveset, data.move)
		local v9

		if moveFolder and v8 then
			v9 = handlerFor(moveFolder, v8, data.key, data.move, data.sharedOverrides)
		end

		local moveFolder2, v10 = findMoveFolder(data.awakenedMoveset, data.awakenedMove)
		local v11

		if moveFolder2 and v10 then
			v11 = handlerFor(moveFolder2, v10, data.key, data.awakenedMove, data.awakenedSharedOverrides)
		end

		if v9 or v11 then
			v6[data.key] = true
			fruitClient.add(v7, v9, v11)
			return true
		else
			return false
		end
	end

	for _, v7 in readBindings() do
		if not v6[v7.key] then
			registerBinding(v7)
		end
	end

	local bindings = child:FindFirstChild("Bindings")

	if bindings and bindings:IsA("Folder") then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshBinding(p2)
			local v7 = parseBindingFolder(p2)

			if v7 then
				registerBinding(v7)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function watchBinding(folder)
			if not folder:IsA("Folder") then
				return
			end

			local flag = false
			folder.AttributeChanged:Connect(function()
				if flag then
					return
				end

				flag = true
				task.defer(function()
					flag = false
					refreshBinding(folder) -- equivalent call inferred; original call site unknown
				end)
			end)
		end

		for _, folder in bindings:GetChildren() do
			if not folder:IsA("Folder") then
				continue
			end

			local flag = false
			local v7 = folder
			folder.AttributeChanged:Connect(function()
				if flag then
					return
				end

				flag = true
				task.defer(function()
					flag = false
					refreshBinding(v7) -- equivalent call inferred; original call site unknown
				end)
			end)
		end

		bindings.ChildAdded:Connect(function(child2)
			watchBinding(child2) -- equivalent call inferred; original call site unknown
			task.defer(refreshBinding, child2)
		end)
	end

	v5.event.OnClientEvent:Connect(function(p2, value, value2)
		if p2 == "SetCooldown" and type(value) == "string" and type(value2) == "number" then
			local v7 = v[value]

			if v7 and fruitClient.setCooldown then
				fruitClient.setCooldown(v7, value2)
			end
		end
	end)
end