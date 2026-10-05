local Players = game:GetService("Players")
local parent = script.Parent
local ConnectionUtil = require(parent:WaitForChild("ConnectionUtil"))
local _ = {
	LOCAL_PLAYER = "LOCAL_PLAYER",
	ON_LOCAL_PLAYER = "ON_LOCAL_PLAYER",
	CHARACTER_ADDED = "CHARACTER_ADDED",
	ON_CHARACTER = "ON_CHARACTER",
	CHARACTER_CHILD_ADDED = "CHARACTER_CHILD_ADDED"
}
local CharacterUtil = {
	_connectionUtil = ConnectionUtil.new(),
	_boundEvents = {},
	getLocalPlayer = function()
		return Players.LocalPlayer
	end
}

function CharacterUtil.onLocalPlayer(onEvent)
	local localPlayer = CharacterUtil.getLocalPlayer()

	if localPlayer then
		onEvent(localPlayer)
	end

	CharacterUtil._connectionUtil:trackConnection(
		"LOCAL_PLAYER",
		Players:GetPropertyChangedSignal("LocalPlayer"):Connect(function()
			local localPlayer2 = CharacterUtil.getLocalPlayer()
			assert(localPlayer2)
			CharacterUtil._getOrCreateBoundEvent("LOCAL_PLAYER"):Fire(localPlayer2)
		end)
	)
	return CharacterUtil._getOrCreateBoundEvent("LOCAL_PLAYER").Event:Connect(onEvent)
end

function CharacterUtil.getCharacter()
	local localPlayer = CharacterUtil.getLocalPlayer()

	if localPlayer then
		return localPlayer.Character
	end

	return nil
end

function CharacterUtil.onCharacter(onEvent)
	CharacterUtil._connectionUtil:trackConnection("ON_LOCAL_PLAYER", CharacterUtil.onLocalPlayer(function(p)
		local character = CharacterUtil.getCharacter()

		if character then
			onEvent(character)
		end

		CharacterUtil._connectionUtil:trackConnection("CHARACTER_ADDED", p.CharacterAdded:Connect(function(character2)
			assert(character2)
			CharacterUtil._getOrCreateBoundEvent("CHARACTER_ADDED"):Fire(character2)
		end))
	end))
	return CharacterUtil._getOrCreateBoundEvent("CHARACTER_ADDED").Event:Connect(onEvent)
end

function CharacterUtil.getChild(childName: string, className: string)
	local character = CharacterUtil.getCharacter()

	if not character then
		return nil
	end

	local child = character:FindFirstChild(childName)

	if child and child:IsA(className) then
		return child
	end

	return nil
end

function CharacterUtil.onChild(p: string, className: string, onEvent)
	CharacterUtil._connectionUtil:trackConnection("ON_CHARACTER", CharacterUtil.onCharacter(function(instance)
		local child = CharacterUtil.getChild(p, className)

		if child then
			onEvent(child)
		end

		CharacterUtil._connectionUtil:trackConnection(
			"CHARACTER_CHILD_ADDED",
			instance.ChildAdded:Connect(function(child2)
				if child2.Name == p and child2:IsA(className) then
					CharacterUtil._getOrCreateBoundEvent("CHARACTER_CHILD_ADDED" .. p .. className):Fire(child2)
				end
			end)
		)
	end))
	return CharacterUtil._getOrCreateBoundEvent("CHARACTER_CHILD_ADDED" .. p .. className).Event:Connect(onEvent)
end

function CharacterUtil._getOrCreateBoundEvent(p: string)
	if not CharacterUtil._boundEvents[p] then
		CharacterUtil._boundEvents[p] = Instance.new("BindableEvent")
	end

	return CharacterUtil._boundEvents[p]
end

return CharacterUtil