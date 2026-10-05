local Players = game:GetService("Players")
local parent = script.Parent.Parent
local Character = require(parent:WaitForChild("Character"))
local CharacterService = {}
CharacterService.__index = CharacterService
local v = nil

function CharacterService.new()
	local object = setmetatable({
		Characters = {}
	}, CharacterService)
	Players.PlayerRemoving:Connect(function(player)
		object.Characters[player] = nil
	end)
	return object
end

function CharacterService.GetInstance()
	if not v then
		v = CharacterService.new()
	end

	return v
end

function CharacterService.GetCharacter(p, player)
	if not (player.Character and player.Character:FindFirstChild("Head")) then
		return nil
	end

	local character = p.Characters[player]

	if not character or character.Character ~= player.Character then
		p.Characters[player] = {
			Character = player.Character,
			VRCharacter = Character.new(player.Character)
		}
	end

	return p.Characters[player].VRCharacter
end

function CharacterService.RefreshAllCharacters(p)
	for _, character in p.Characters do
		character.VRCharacter:RefreshCharacter()
	end
end

return CharacterService