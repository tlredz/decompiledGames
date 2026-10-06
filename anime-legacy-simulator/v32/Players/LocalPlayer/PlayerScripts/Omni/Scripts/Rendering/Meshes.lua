local module = require("@game/ReplicatedStorage/Omni")
local v = nil
local Meshes = {
	Refresh = function()
		if module.Data.Settings["Low Mode"] then
			if v then
				return
			end

			v = module.Utils.Instance:ObserveDescendants(workspace, function(instance)
				if instance:IsA("BasePart") or instance:IsA("MeshPart") then
					if not instance:GetAttribute("OriginalMaterial") then
						instance:SetAttribute("OriginalMaterial", instance.Material)
					end

					instance.Material = Enum.Material.SmoothPlastic
				elseif instance:IsA("Texture") then
					if not instance:GetAttribute("OriginalTransparency") then
						instance:SetAttribute("OriginalTransparency", instance.Transparency)
					end

					instance.Transparency = 1
				end
			end)
		else
			if not v then
				return
			end

			for _, descendant in workspace:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
					local originalMaterial = descendant:GetAttribute("OriginalMaterial")

					if originalMaterial ~= nil then
						descendant.Material = originalMaterial
					end
				elseif descendant:IsA("Texture") then
					local originalTransparency = descendant:GetAttribute("OriginalTransparency")

					if originalTransparency ~= nil then
						descendant.Transparency = originalTransparency
					end
				end
			end

			if v then
				v:Destroy()
				v = nil
			end
		end
	end
}

function Meshes.Init()
	Meshes.Refresh()
end

module:OnDataChanged({ "Settings", "Low Mode" }, Meshes.Refresh)
return Meshes