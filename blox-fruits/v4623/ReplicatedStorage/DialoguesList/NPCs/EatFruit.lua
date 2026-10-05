local GetFruitName = require(game.ReplicatedStorage.Modules.Asset.GetFruitName)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
require(game.ReplicatedStorage.DialogueController.Types)
local v = nil
local connections = {}
local v2 = DialogueController.new()
v2:setTitle("Blox Fruit")

local function getEquippedFruitTool()
	local character = game.Players.LocalPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if not tool then
		return nil
	end

	local itemId = tool:GetAttribute("ItemId")

	if type(itemId) ~= "number" then
		return nil
	end

	local v3 = ItemConfig.tryGet(itemId)

	if v3 and v3.Index.IdType == "PhysicalMoveset" then
		return tool
	end

	return nil
end

local function closeIfActive()
	local activeDialogue = DialogueController.getActiveDialogue()

	if activeDialogue and activeDialogue._dialogue == v2 then
		DialogueController.close()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopWatchingFruitTool()
	v = nil

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

local function watchFruitTool(equippedFruitTool)
	if v == equippedFruitTool then
		return
	end

	stopWatchingFruitTool() -- equivalent call inferred; original call site unknown
	v = equippedFruitTool
	table.insert(connections, equippedFruitTool.Unequipped:Connect(closeIfActive))
	table.insert(connections, equippedFruitTool.Destroying:Connect(closeIfActive))
	v2:getMaid():GiveTask(stopWatchingFruitTool)
end

local function getEatRemote()
	local character = game.Players.LocalPlayer.Character
	local eatRemote = character and character:FindFirstChild("EatRemote", true)

	if eatRemote and eatRemote:IsA("RemoteFunction") then
		return eatRemote
	end

	return nil
end

local function addMissingFruitText(object, p: string)
	object:addText("[You must be holding out the Blox Fruit to " .. p .. " it.]")
end

local function buildEatResultPage(object, object2)
	stopWatchingFruitTool() -- equivalent call inferred; original call site unknown
	local v3 = object2:InvokeServer()

	if typeof(v3) == "string" then
		object:addText(v3)
		return
	end

	if not v3 then
		object:addText("[An error has occurred. Please try again.]")
		return
	end

	object:addText("[Eating Blox Fruit.]")
	object:advanceAfterDelay(1)
end

local function buildEatConfirmPage(object, eatRemote)
	local parent = eatRemote.Parent
	object:addText((`This will replace your <Color=Yellow><{GetFruitName(game.Players.LocalPlayer.Data.DevilFruit.Value)}><Color=/> with <Color=Yellow><{GetFruitName(parent:GetAttribute("OriginalName"))}><Color=/>. Are you sure?`))
	object:addOptionType("Chat", function(object2)
		object2:setText("Confirm")
		object2:jumpToPage(function(p)
			buildEatResultPage(p, eatRemote)
		end)
	end)
	object:addOptionType("Chat", function(object2)
		object2:setText("Cancel")
		object2:jumpTo("Main")
	end)
end

local function buildDropResultPage(object)
	local character = game.Players.LocalPlayer.Character
	local eatRemote = character and character:FindFirstChild("EatRemote", true)

	if not (eatRemote and eatRemote:IsA("RemoteFunction")) then
		eatRemote = nil
	end

	if not eatRemote then
		object:addText("[You must be holding out the Blox Fruit to drop it.]")
		return
	end

	stopWatchingFruitTool() -- equivalent call inferred; original call site unknown

	if eatRemote:InvokeServer("Drop") then
		object:addText("[Blox Fruit dropped.]")
		object:advanceAfterDelay(1)
	else
		object:addText("[Cannot drop Blox Fruit.]")
		object:addText("[Blox Fruits that were previously stored cannot be dropped.]")
	end
end

local function buildStoreResultPage(object)
	local character = game.Players.LocalPlayer.Character
	local eatRemote = character and character:FindFirstChild("EatRemote", true)

	if not (eatRemote and eatRemote:IsA("RemoteFunction")) then
		eatRemote = nil
	end

	if not eatRemote then
		object:addText("[You must be holding out the Blox Fruit to store it.]")
		return
	end

	local parent = eatRemote.Parent
	stopWatchingFruitTool() -- equivalent call inferred; original call site unknown
	local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
		"StoreFruit",
		parent:GetAttribute("OriginalName"),
		parent
	)

	if typeof(v3) == "number" then
		object:addText("[Storage full. Would you like to purchase +1 Blox Fruit Storage? Your current capacity is " .. v3 .. " for each Blox Fruit.]")
		object:addOptionType("Chat", function(object2)
			object2:setText("Upgrade")
			object2:jumpToPage(function(object3)
				game.ReplicatedStorage.Remotes.CommF_:InvokeServer("buyRobuxShop", "+1 Fruit Storage")
				object3:addText("...")
			end)
		end)
	else
		if not v3 then
			object:addText("[Storage failed.]")
			return
		end

		object:addText("[Blox Fruit stored.]")
		object:advanceAfterDelay(1)
	end
end

return v2:addPage("Main", function(object)
	local equippedFruitTool = getEquippedFruitTool()

	if not equippedFruitTool then
		object:close()
		return
	end

	watchFruitTool(equippedFruitTool)
	object:addText("What do you wish to do with this Blox Fruit?<AnimateYield=3>")
	object:addOptionType("Chat", function(object2)
		object2:setText("Eat")
		object2:jumpToPage(function(object3)
			local character = game.Players.LocalPlayer.Character
			local eatRemote = character and character:FindFirstChild("EatRemote", true)

			if not (eatRemote and eatRemote:IsA("RemoteFunction")) then
				eatRemote = nil
			end

			if not eatRemote then
				object3:addText("[You must be holding out the Blox Fruit to eat it.]")
			elseif game.Players.LocalPlayer.Data.DevilFruit.Value == "" then
				buildEatResultPage(object3, eatRemote)
			else
				buildEatConfirmPage(object3, eatRemote)
			end
		end)
	end)
	object:addOptionType("Chat", function(object2)
		object2:setText("Drop")
		object2:jumpToPage(buildDropResultPage)
	end)
	object:addOptionType("Chat", function(object2)
		object2:setText("Store")
		object2:jumpToPage(buildStoreResultPage)
	end)
end):build()