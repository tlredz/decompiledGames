local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local VisualizeBullet = require(script.Parent.VisualizeBullet)
local BulletsController = {
	FrameworkInit = function() end
}

function BulletsController.FrameworkStart()
	Remotes.connect("Bullet", function(player, vector: Vector3, p)
		local character = player.Character

		if not character then
			return
		end

		local tool = character:FindFirstChildWhichIsA("Tool")

		if not (tool and tool:HasTag("GunTool")) then
			return
		end

		BulletsController.VisualizeBullet(vector, p, tool)
	end)
	Remotes.connect("GunPlaySound", function(_, p)
		BulletsController.PlaySound(p)
	end)
end

function BulletsController.VisualizeBullet(vector: Vector3, p, p2)
	VisualizeBullet(vector, p, p2)
end

function BulletsController.PlaySound(sound)
	if not sound:IsA("Sound") then
		return
	end

	local clone = sound:Clone()
	clone.Parent = sound.Parent
	local tool = clone:FindFirstAncestorWhichIsA("Tool")
	local unequippedConnection

	if tool then
		if tool.Parent:IsA("Model") then
			unequippedConnection = tool.Unequipped:Once(function()
				clone:Destroy()
			end)
		else
			clone:Destroy()
			return
		end
	else
		unequippedConnection = nil
	end

	clone.Destroying:Once(function()
		if unequippedConnection then
			unequippedConnection:Disconnect()
		end
	end)
	clone.Ended:Once(function()
		clone:Destroy()
	end)
	clone:Play()
end

return BulletsController