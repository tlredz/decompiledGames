local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TableUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("TableUtil"))
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local v = {
	["Blox Fruit"] = true,
	Gun = true,
	Melee = true,
	Sword = true
}
local v2 = {
	"Light-Light",
	"Sand-Sand",
	"Magma-Magma",
	"Flame-Flame",
	"Eagle-Eagle",
	"Phoenix-Phoenix",
	"Dragon-Dragon",
	"Love-Love",
	"Spider-Spider",
	"Ghost-Ghost",
	"Smoke-Smoke",
	"Spin-Spin",
	"Blade-Blade",
	"Gravity-Gravity",
	"Shadow-Shadow",
	"Venom-Venom",
	"Spirit-Spirit",
	"Blizzard-Blizzard",
	"Sound-Sound",
	"Gas-Gas",
	"Rocket-Rocket"
}

function getItemsFolder()
	if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false or RunService:IsServer() then
		return ServerStorage:WaitForChild("Items")
	end

	return nil
end

function assembleServerData()
	local itemsFolder = getItemsFolder()

	if not itemsFolder then
		error("bad folder")
	end

	local Movesets = require(game.ServerScriptService.Movesets)
	local copiesByName = {}

	for _, tool in ipairs(itemsFolder:GetChildren()) do
		if not (tool:IsA("Tool") and v[tool.ToolTip]) then
			continue
		end

		local legacyData = Movesets.getLegacyData(tool.Name)
		local copy = TableUtil.deepCopy(legacyData)
		TableUtil.deepFreeze(copy)
		copiesByName[tool.Name] = copy
	end

	table.freeze(copiesByName)
	return copiesByName
end

local FruitSkillUtil = {
	getFruitDataAsync = function()
		if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false or RunService:IsServer() then
			return assembleServerData()
		end

		local getFruitData = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetFruitData")
		assert(getFruitData:IsA("RemoteFunction"))
		return getFruitData:InvokeServer()
	end,
	MobileM1ButtonActivated = function(data)
		local heldTool = data.HeldTool
		local inputObject = data.InputObject
		local tapHoldButton = data.TapHoldButton

		if heldTool.Name == "Dragon-Dragon" then
			local Global = require(game.ReplicatedStorage.Global)
			Global.CurrentTouchObjectForMouse = nil
			local changedConnection = nil
			changedConnection = inputObject.Changed:Connect(function(p)
				if p == "UserInputState" and inputObject.UserInputState == Enum.UserInputState.End then
					changedConnection:Disconnect()
					heldTool:Deactivate()

					if tapHoldButton then
						local Global2 = require(game.ReplicatedStorage.Global)

						if Global2.mobileSelectionFrame == tapHoldButton then
							local Global3 = require(game.ReplicatedStorage.Global)
							Global3.mobileSelectionFrame.BackgroundColor3 = Color3.new()
							local Global4 = require(game.ReplicatedStorage.Global)
							Global4.mobileSelectionFrame = nil
							local Global5 = require(game.ReplicatedStorage.Global)
							Global5.mobileSelection = nil
						end
					end

					task.defer(function()
						local Global2 = require(game.ReplicatedStorage.Global)
						Global2.CurrentTouchObjectForMouse = nil
					end)
				end
			end)
			heldTool:Activate()
		else
			local Global = require(game.ReplicatedStorage.Global)
			Global.CurrentTouchObjectForMouse = inputObject
			local Global2 = require(game.ReplicatedStorage.Global)
			Global2.updateMouseWrapper(inputObject)
			inputObject.KeyCode = Enum.KeyCode.G
			local changedConnection = nil
			changedConnection = inputObject.Changed:Connect(function(p)
				if p == "UserInputState" and inputObject.UserInputState == Enum.UserInputState.End then
					changedConnection:Disconnect()

					if tapHoldButton then
						local Global3 = require(game.ReplicatedStorage.Global)

						if Global3.mobileSelectionFrame == tapHoldButton then
							local Global4 = require(game.ReplicatedStorage.Global)
							Global4.mobileSelectionFrame.BackgroundColor3 = Color3.new()
							local Global5 = require(game.ReplicatedStorage.Global)
							Global5.mobileSelectionFrame = nil
							local Global6 = require(game.ReplicatedStorage.Global)
							Global6.mobileSelection = nil
						end
					end

					inputObject.KeyCode = Enum.KeyCode.G
					local Global3 = require(game.ReplicatedStorage.Global)
					Global3.TestGamePrint("end from here")
					local Global4 = require(game.ReplicatedStorage.Global)
					Global4.casFunc("DevilFruit", Enum.UserInputState.End, inputObject, Enum.KeyCode.G)
					task.defer(function()
						local Global5 = require(game.ReplicatedStorage.Global)
						Global5.CurrentTouchObjectForMouse = nil
					end)
				end
			end)
			task.defer(function()
				local Global3 = require(game.ReplicatedStorage.Global)
				Global3.TestGamePrint("cast from here")
				local Global4 = require(game.ReplicatedStorage.Global)
				Global4.casFunc("DevilFruit", Enum.UserInputState.Begin, inputObject, Enum.KeyCode.G)
			end)
		end
	end,
	isToolSkillDisabled = function(instance, p: string)
		return instance:GetAttribute("DisabledSkill" .. p) == true
	end
}

function FruitSkillUtil.IsSkillBlocked(player, instance, childName: string)
	if FruitSkillUtil.isToolSkillDisabled(instance, childName) then
		return true
	end

	if childName ~= "F" or not (player.Character and player.Character:HasTag("TargetEggOwner") and table.find(
		v2,
		instance.Name
	)) then
		return false
	end

	local v3 = {}
	local awakenedMoves = instance:FindFirstChild("AwakenedMoves")
	local child = awakenedMoves and awakenedMoves:FindFirstChild(childName)

	if table.find({ "Magma-Magma" }, instance.Name) then
		if child then
			return true, "<Color=Red>You can't use this skill while holding the Target Egg!<Color=/>"
		end
	elseif not (table.find(v3, instance.Name) and child) then
		return true, "<Color=Red>You can't use this skill while holding the Target Egg!<Color=/>"
	end

	return false
end

return FruitSkillUtil