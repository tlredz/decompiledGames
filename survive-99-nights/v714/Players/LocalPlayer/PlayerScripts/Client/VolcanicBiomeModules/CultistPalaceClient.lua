local CultistPalaceClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.BurnPodiumGems:Connect(function(instance)
	local functional = instance:WaitForChild("Functional")

	for _, child in pairs(functional:WaitForChild("Podiums"):GetChildren()) do
		local cultistGem = child:WaitForChild("Cultist Gem")
		local clone = cultistGem:Clone()

		for _, part in pairs(cultistGem:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "Main" then
				part.Transparency = 1
			end
		end

		for _, part in pairs(clone:GetDescendants()) do
			if not (part:IsA("BasePart") and part ~= clone.PrimaryPart) then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Parent = part
			weldConstraint.Part0 = part
			weldConstraint.Part1 = clone.PrimaryPart
		end

		Client.LavaClient.BurnItem(clone)
		clone:Destroy()
	end
end)

function AddPodium(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	local cultistGem = instance:WaitForChild("Cultist Gem")
	local gem = instance:WaitForChild("Gem")
	local flag = false
	instance:GetAttributeChangedSignal("GemAdded"):Connect(function()
		local gemAdded = instance:GetAttribute("GemAdded")

		for _, part in pairs(cultistGem:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "Main" then
				part.Transparency = gemAdded and 0 or 1
			end
		end

		gem.Gem.Color = gemAdded and Color3.fromRGB(209, 52, 52) or Color3.fromRGB(27, 42, 53)

		if gemAdded and not instance:GetAttribute("LocalAdded") then
			for _, child in pairs(instance.PrimaryPart.ItemAttach:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount") or 1)
			end
		else
			instance:SetAttribute("LocalAdded", nil)
			flag = false
		end
	end)
	touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if flag or parent:GetAttribute("BeingUsed") or instance:GetAttribute("GemAdded") or parent:GetAttribute("Destroyed") then
			return
		end

		if instance:GetAttribute("LocalAdded") then
			return
		end

		if parent.Name == "Cultist Gem" then
			local function undo()
				instance:SetAttribute("LocalAdded", nil)
				parent:SetAttribute("BeingUsed", nil)
				parent.Parent = workspace.Items

				if not instance:GetAttribute("GemAdded") then
					for _, part in pairs(cultistGem:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 1
						end
					end

					gem.Gem.Color = Color3.fromRGB(27, 42, 53)
				end
			end

			flag = true
			parent:SetAttribute("BeingUsed", true)
			instance:SetAttribute("LocalAdded", true)
			parent.Parent = game.ReplicatedStorage.TempStorage

			for _, part in pairs(cultistGem:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "Main" then
					part.Transparency = 0
				end
			end

			gem.Gem.Color = Color3.fromRGB(209, 52, 52)

			for _, child in pairs(instance.PrimaryPart.ItemAttach:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount") or 1)
			end

			local v = Client.Events.RequestAddCultistPalaceGem:InvokeServer(parent, instance)

			if not (v and v.Success) then
				task.spawn(function()
					wait(0.5)
					undo()
					wait(1)
					flag = false
				end)
			end
		end
	end)
end

function CultistPalaceAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local functional = instance:WaitForChild("Functional")

	for _, child in pairs(functional:WaitForChild("Podiums"):GetChildren()) do
		AddPodium(child)
	end
end

function CultistPalaceClient.Init()
	Client.Utility.ForAllTagged("CultistKingPalace", CultistPalaceAdded)
end

return CultistPalaceClient