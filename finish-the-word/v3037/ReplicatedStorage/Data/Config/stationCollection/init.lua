local localPlayer = game.Players.LocalPlayer
local rigs = game.ReplicatedStorage.ReplicatedAssets.Rigs
local import = _G.import("event")
local import2 = _G.import("bodyUtil")
local import3 = _G.import("viewImports")

local function renderCharacter(parent)
	local clone = rigs.R15:Clone()
	clone.HumanoidRootPart.CFrame = parent.Trigger.CFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.new(
		0,
		3,
		0
	)
	clone.Parent = parent
	local humanoidDescriptionFromUserIdAsync = game.Players:GetHumanoidDescriptionFromUserIdAsync(localPlayer.UserId > 0 and localPlayer.UserId or 1)
	clone.Humanoid:ApplyDescription(humanoidDescriptionFromUserIdAsync)
	import2.animate(clone, 120627260953605, {
		Looped = true
	})
end

return {
	AFK = {
		BillboardGui = import3:get("afkStation").AfkStation,
		ActionText = "Teleport",
		ObjectText = "AFK Servers",
		OnTriggered = function()
			import.remoteFire("teleport", "Afk")
			import.fire("signal", "Teleporting to AFK servers")
		end,
		Client = function(parent)
			renderCharacter(parent)
		end
	},
	Ranked = {
		BillboardGui = import3:get("rankedStation").RankedStation,
		ActionText = "Queue Ranked",
		ObjectText = "Ranked",
		HoldDuration = 0,
		OnTriggered = function()
			import.fire("openMenu", "Ranked")
		end,
		Client = function(instance)
			local cannon = instance:FindFirstChild("Cannon")

			if not cannon then
				return
			end

			cannon.ExitTeleport.Transparency = 1
			cannon.ExitTeleport.CanCollide = false

			for _, child in pairs(cannon.Seats:GetChildren()) do
				child.Transparency = 1
				child.CanCollide = false
			end
		end
	},
	Discord = {
		BillboardGui = nil,
		ActionText = "Blah Blah",
		ObjectText = "Blah",
		OnTriggered = function()
			import.fire("openMenu", "Discord")
		end
	}
}