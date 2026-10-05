local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("HttpService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = require3(ReplicatedStorage2.Packages.Net)
local remoteEvent = v:RemoteEvent("ClaimEasterEgg")
local remoteEvent2 = v:RemoteEvent("SpawnEasterEgg")
local remoteEvent3 = v:RemoteEvent("DestroyEasterEgg")
local data = {}
local data2 = {}
local v2 = {}
local EggDropController = {}

function EggDropController.Start(_)
	remoteEvent2.OnClientEvent:Connect(function(p)
		EggDropController:SpawnEgg(p)
	end)
	remoteEvent3.OnClientEvent:Connect(function(p: string?, flag: boolean)
		if flag then
			EggDropController:DestroyAllEggs()
		elseif p then
			EggDropController:DestroyEgg(p)
		end
	end)
end

function EggDropController:DestroyAllEggs()
	for _, v3 in v2 do
		v3:Destroy()
	end

	table.clear(v2)
	table.clear(data2)
end

function EggDropController:DestroyEgg(p: string)
	for i, v3 in ipairs(data2) do
		if v3.GUID ~= p then
			continue
		end

		table.remove(data2, i)
		break
	end

	local v3 = v2[p]

	if v3 then
		v3:Destroy()
		v2[p] = nil
	end
end

function EggDropController:SpawnEgg(data3)
	local child = script.Drops:FindFirstChild(data3.EggName)

	if not child then
		return
	end

	local v3 = createVector(0, 1, 0) * (child.Size.Y / 2)
	local clone = child:Clone()
	clone.Position = data3.Position + v3
	clone.Parent = currentCamera
	local touchedConnection = nil
	touchedConnection = clone.Touched:Connect(function(otherPart)
		if clone:GetAttribute("Claimed") then
			return
		end

		local character = localPlayer.Character

		if not (character == otherPart.Parent and ValidateEggClaim(character)) then
			return
		end

		local primaryPart = character.PrimaryPart

		if (not primaryPart and 0 or (primaryPart.Position - clone.Position).Magnitude or 0) > 15 then
			return
		end

		touchedConnection:Disconnect()
		clone:SetAttribute("Claimed")
		local clone2 = script.SFX:Clone()
		clone2.Position = clone.Position
		clone2.Parent = workspace
		clone2.Sound:Play()
		local clone3 = script.VFX.Attachment:Clone()
		clone3.Parent = primaryPart

		for _, child2 in clone3:GetChildren() do
			PlayParticle(child2)
		end

		task.delay(clone2.Sound.TimeLength + 0.1, function()
			clone2:Destroy()
			task.wait(1)
			clone3:Destroy()
		end)
		remoteEvent:FireServer(data3.GUID, data3.LobbyEgg)
		clone:Destroy()
	end)
	clone.Destroying:Once(function()
		if touchedConnection.Connected then
			touchedConnection:Disconnect()
		end
	end)
	v2[data3.GUID] = clone

	if data3.LobbyEgg then
		table.insert(data, data3)
	else
		table.insert(data2, data3)
	end
end

function ValidateEggClaim(instance)
	if instance:GetAttribute("Dead") or not instance:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid and not (humanoid and humanoid.Health <= 0) then
		return true
	end

	return false
end

function PlayParticle(instance)
	local emitDuration = instance:GetAttribute("EmitDuration") or 0

	if emitDuration > 0 then
		instance.Enabled = true
		task.delay(emitDuration, function()
			instance.Enabled = false
		end)
	else
		instance:Emit(instance:GetAttribute("EmitCount") or 1)
	end
end

return EggDropController