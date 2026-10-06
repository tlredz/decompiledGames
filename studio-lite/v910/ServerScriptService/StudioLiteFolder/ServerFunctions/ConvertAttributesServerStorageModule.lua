local ConvertAttributesServerStorageModule = {}
ConvertAttributesServerStorageModule.__index = ConvertAttributesServerStorageModule

function ConvertAttributesServerStorageModule.Play(_)
	local recurse

	recurse = function(part)
		if part:IsA("BasePart") then
			part.Anchored = part:GetAttribute("SL_Anchored")
			part.CanCollide = part:GetAttribute("SL_CanCollide")
		end

		for _, child in pairs(part:GetChildren()) do
			recurse(child)
		end
	end

	recurse(game.ServerStorage.StudioLiteFolder.game)
end

return ConvertAttributesServerStorageModule