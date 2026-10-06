local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local ProfileManager = require(ReplicatedStorage.Chest.Assets.Modules.ProfileManager)
local Streaming = require(ReplicatedStorage.Chest.Assets.Modules.Streaming)
local DamageIndicator = require(ReplicatedStorage.Chest.Assets.Modules.Features.DamageIndicator)
local MountPrompt = require(script:WaitForChild("MountPrompt"))
local Optimization = {}
local characterWorkshop = workspace:WaitForChild("CharacterWorkshop", 7)
local seaMonster = workspace:WaitForChild("SeaMonster", 7)
local allDroppedFruit = workspace:WaitForChild("AllDroppedFruit", 7)
local allspawnDF = workspace:WaitForChild("AllspawnDF", 7)
local v = {
	"Allosaurus",
	"Brachiosaurus",
	"Spinosaurus",
	"MammothModel",
	"Dragon",
	"Giraffe",
	"Wolf",
	"Leopard",
	"DemonForm",
	"Phoenix_Model",
	"Pteranodon_KL",
	"Tree_KL",
	"ToyTrex"
}

function SafeWait()
	task.wait(0.03333333333333333)
end

function AddStreaming(p)
	SafeWait()
	Streaming:RegisterDetail(p)
end

function RemoveStreaming(p)
	Streaming:UnregisterDetail(p)
end

function Optimization.Setup(_)
	characterWorkshop.ChildAdded:Connect(AddStreaming)
	characterWorkshop.ChildRemoved:Connect(RemoveStreaming)

	if seaMonster then
		seaMonster.ChildAdded:Connect(AddStreaming)
		seaMonster.ChildRemoved:Connect(AddStreaming)
	end

	ProfileManager.OnCharacterAdded:Connect(function(instance)
		instance.ChildAdded:Connect(function(child)
			if table.find(v, child.Name) then
				AddStreaming(child)
			end

			if MountPrompt:CanMount(child) then
				MountPrompt:SetupMountPrompt(instance)
			end
		end)
		instance.ChildRemoved:Connect(function(child)
			if not table.find(v, child.Name) then
				return
			end

			RemoveStreaming(child)
		end)
	end)
	ProfileManager.OnCharacterRemoving:Connect(function(p)
		DamageIndicator.ClearCache(p)
	end)
	allDroppedFruit.ChildAdded:Connect(function(child)
		AddStreaming(child)
	end)
	allDroppedFruit.ChildRemoved:Connect(function(child)
		RemoveStreaming(child)
	end)
	allspawnDF.ChildAdded:Connect(AddStreaming)
	allspawnDF.ChildRemoved:Connect(RemoveStreaming)

	for _, v2 in pairs(Players:GetPlayers()) do
		local v3 = v2
		task.defer(function()
			local v4 = ProfileManager.AwaitProfile(v3, 7)

			if not v4 then
				return
			end

			local character = v4:GetCharacter()

			if not character then
				return
			end

			for i, child in pairs(character:GetChildren()) do
				if table.find(v, child.Name) then
					AddStreaming(child)
				end

				if MountPrompt:CanMount(child) then
					MountPrompt:SetupMountPrompt(character)
				end
			end

			character.ChildAdded:Connect(function(child)
				if table.find(v, child.Name) then
					AddStreaming(child)
				end

				if MountPrompt:CanMount(child) then
					MountPrompt:SetupMountPrompt(character)
				end
			end)
			character.ChildRemoved:Connect(function(child)
				if not table.find(v, child.Name) then
					return
				end

				RemoveStreaming(child)
			end)
		end)
	end
end

return Optimization