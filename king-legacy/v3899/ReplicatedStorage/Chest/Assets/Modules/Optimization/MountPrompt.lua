local Players = game:GetService("Players")
game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local Allies = require(ReplicatedStorage:WaitForChild("Chest").Assets.Modules.Features.Allies)
local v = {
	"Dragon",
	"Allosaurus",
	"Spinosaurus",
	"Brachiosaurus",
	"Pteranodon_KL"
}
local v2 = {
	Allosaurus = 15,
	Pteranodon_KL = 20,
	Spinosaurus = 30,
	Dragon = 30,
	Brachiosaurus = 45
}
local MountPrompt = {
	CanMount = function(_, p)
		if table.find(v, p.Name) then
			return true
		end
	end
}

function CreateMountPrompt()
	return (script.MountPrompt:Clone())
end

function SendMessage(data)
	ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
		Message = data.Message,
		DebrisTime = data.DebrisTime,
		Color = data.TextColor or Color3.fromRGB(255, 255, 255),
		Name = HttpService:GenerateGUID(false)
	})
end

function SafeWait()
	task.wait(0.1)
end

function MountPrompt.SetupMountPrompt(_, instance)
	if localPlayer.Character == instance then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	SafeWait()

	for _, v3 in ipairs(v) do
		local v4 = v3
		task.spawn(function()
			local child = instance:WaitForChild(v4, 7)

			if not child then
				return
			end

			local mountAttachment = child:FindFirstChild("MountAttachment", true)

			if not mountAttachment or mountAttachment:FindFirstChild("MountPrompt") or not instance:IsDescendantOf(game) then
				return
			end

			local v5 = CreateMountPrompt()
			v5.Enabled = nil
			v5.MaxActivationDistance = v2[v4] or v5.MaxActivationDistance
			v5.Parent = mountAttachment
			v5:SetAttribute("PromptOwner", instance.Name)
			CollectionService:AddTag(v5, "MountPrompt")
			v5.Triggered:Connect(function()
				if not _G.CheckAllyClient(localPlayer, playerFromCharacter) then
					SendMessage({
						Message = "<font color=\"#ff0000\">You must be allies to be able to ride</font>"
					})
				elseif _G.AntiMobSkill() then
					SendMessage({
						Message = "<font color=\"#ff0000\">You cannot ride while in transformation</font>"
					})
				else
					ReplicatedStorage.Chest.Remotes.Events.EtcEvent:FireServer({
						Type = "BeginMount",
						MountCharacter = instance
					})
				end
			end)
			Allies:UpdateMountPrompt()
		end)
	end
end

return MountPrompt