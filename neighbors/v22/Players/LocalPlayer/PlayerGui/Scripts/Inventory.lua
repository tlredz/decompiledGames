game:GetService("RunService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local Server = require(game.ReplicatedStorage.Modules.Server)
local localPlayer = game.Players.LocalPlayer
local SatchelScript = require(localPlayer.PlayerScripts:WaitForChild("Satchel"):WaitForChild("SatchelScript"))
local flag = false

local function isPlayerBeingCarried()
	local character = localPlayer.Character

	if character then
		return character:GetAttribute("Carried") or character:GetAttribute("Tied") or character:GetAttribute("BoogieDancing") or character:GetAttribute("InTornado") or character:GetAttribute("Dizzy")
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPlayerCustomizing()
	return localPlayer:GetAttribute("IsCustomizingLocalHouse") and true or false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPlayerInEvent()
	local state = localPlayer:GetAttribute("State")
	return state == 6 or state == 7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPlayerShopping()
	return localPlayer.PlayerGui:WaitForChild("Neighbors"):WaitForChild("Shop").Visible
end

local function update()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local v = isPlayerBeingCarried() or isPlayerCustomizing() or isPlayerShopping()

	if not v then
		v = isPlayerInEvent()
	end

	if v then
		humanoid:UnequipTools()

		if not flag and SatchelScript:GetBackpackEnabled() then
			SatchelScript:SetBackpackEnabled(false)
			flag = true
		end
	elseif flag then
		SatchelScript:SetBackpackEnabled(true)
		flag = false
	end
end

local function registerCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and tool.Name ~= "Prop Hunt" then
			if isPlayerBeingCarried() then
				task.defer(function()
					humanoid:UnequipTools()
				end)
			elseif isPlayerInEvent() then
				task.defer(function()
					humanoid:UnequipTools()
				end)
			end
		end
	end)
	character:GetAttributeChangedSignal("Carried"):Connect(update)
	character:GetAttributeChangedSignal("Tied"):Connect(update)
	character:GetAttributeChangedSignal("PropMorphed"):Connect(update)
	character:GetAttributeChangedSignal("BoogieDancing"):Connect(update)
	character:GetAttributeChangedSignal("InTornado"):Connect(update)
	character:GetAttributeChangedSignal("Dizzy"):Connect(update)
end

localPlayer:GetAttributeChangedSignal("IsCustomizingLocalHouse"):Connect(update)
localPlayer:GetAttributeChangedSignal("State"):Connect(update)
localPlayer.CharacterAdded:Connect(registerCharacter)
Network:listen("TriggerInventory", function(flag2: boolean)
	if flag2 and localPlayer:GetAttribute("State") ~= 3 and (Server:GetServerType() == Server.Servers.Neighborhood or Server:GetServerType() == Server.Servers.Night) then
		return
	end

	SatchelScript:SetBackpackEnabled(flag2)
end)

if localPlayer.Character then
	registerCharacter(localPlayer.Character)
end