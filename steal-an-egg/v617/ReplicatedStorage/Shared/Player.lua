local Players = game:GetService("Players")
local Player = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePlayer(p)
	local v = p or Players.LocalPlayer
	assert(v ~= nil, "Rig lookups need an explicit Player when there is no LocalPlayer")
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pickPart(childName: string)
	return function(instance)
		local part = instance:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			return part
		end

		return nil
	end
end

local function pickHumanoid(instance)
	return (instance:FindFirstChildOfClass("Humanoid"))
end

local part2 = pickPart("HumanoidRootPart") -- equivalent call inferred; original call site unknown
local part3 = pickPart("Head") -- equivalent call inferred; original call site unknown

local function awaitPiece(instance, callback)
	local v5 = callback(instance)

	while v5 == nil do
		instance.ChildAdded:Wait()
		v5 = callback(instance)
	end

	return v5
end

function Player.FindCharacter(p)
	local player = resolvePlayer(p) -- equivalent call inferred; original call site unknown
	return player.Character
end

function Player.WaitForCharacter(p)
	local player = resolvePlayer(p) -- equivalent call inferred; original call site unknown
	return player.Character or player.CharacterAdded:Wait()
end

function Player.FindHumanoid(p)
	local character = Player.FindCharacter(p)

	if character then
		return (character:FindFirstChildOfClass("Humanoid"))
	end

	return nil
end

function Player.WaitForHumanoid(p)
	return (awaitPiece(Player.WaitForCharacter(p), pickHumanoid))
end

function Player.FindRootPart(p)
	local character = Player.FindCharacter(p)

	if character then
		return (part2(character))
	end

	return nil
end

function Player.WaitForRootPart(p)
	return (awaitPiece(Player.WaitForCharacter(p), part2))
end

function Player.FindPrimaryPart(p)
	local character = Player.FindCharacter(p)

	if character then
		return character.PrimaryPart
	end

	return nil
end

function Player.FindHead(p)
	local character = Player.FindCharacter(p)

	if character then
		return (part3(character))
	end

	return nil
end

function Player.FindAnimator(p)
	local humanoid = Player.FindHumanoid(p)

	if humanoid then
		return (humanoid:FindFirstChildOfClass("Animator"))
	end

	return nil
end

function Player.FindFeetCFrame(p)
	local character = Player.FindCharacter(p)
	local primaryPart

	if character then
		primaryPart = character.PrimaryPart
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if primaryPart == nil or humanoid == nil then
		return nil
	end

	return primaryPart.CFrame * CFrame.new(0, -(humanoid.HipHeight + primaryPart.Size.Y / 2), 0)
end

return Player