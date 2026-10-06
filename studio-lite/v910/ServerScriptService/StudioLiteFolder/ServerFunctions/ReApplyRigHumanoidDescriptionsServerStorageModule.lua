local ReApplyRigHumanoidDescriptionsServerStorageModule = {}
ReApplyRigHumanoidDescriptionsServerStorageModule.__index = ReApplyRigHumanoidDescriptionsServerStorageModule

function ReApplyRigHumanoidDescriptionsServerStorageModule.ReApply(_)
	local humanoidDescription = nil
	local humanoid = nil
	local FindHumanoidDescriptionRecursive

	FindHumanoidDescriptionRecursive = function(instance)
		if instance.ClassName == "Model" and instance:FindFirstChild("Humanoid") and instance.Humanoid:FindFirstChild("HumanoidDescription") and instance:FindFirstChild("HumanoidRootPart") then
			humanoid = instance.Humanoid
			humanoidDescription = humanoid.HumanoidDescription
			local v = {}

			for _, child in pairs(humanoidDescription:GetChildren()) do
				if child.ClassName == "AccessoryDescription" then
					if v[child.AssetId] then
						child:Destroy()
					else
						v[child.AssetId] = 1
					end
				elseif child.ClassName == "BodyPartDescription" then
					if v[child.BodyPart] then
						child:Destroy()
					else
						v[child.BodyPart] = 1
					end
				end
			end

			humanoid:ApplyDescriptionReset(humanoidDescription)

			if humanoidDescription.Head == 3064931584 then
				for _, child in pairs(humanoid.Parent:GetChildren()) do
					if child.ClassName ~= "MeshPart" then
						continue
					end

					local v2 = child
					pcall(function()
						v2.TextureID = game.ServerStorage.StudioLiteFolder.Models.Zombie[v2.Name].TextureID
					end)
				end
			end
		end

		for _, child in pairs(instance:GetChildren()) do
			FindHumanoidDescriptionRecursive(child)
		end
	end

	FindHumanoidDescriptionRecursive(game.ServerStorage.StudioLiteFolder.game)
end

return ReApplyRigHumanoidDescriptionsServerStorageModule