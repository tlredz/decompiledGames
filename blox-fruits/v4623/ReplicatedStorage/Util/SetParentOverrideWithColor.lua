local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local ColorPaletteCache = require(game.ReplicatedStorage.Util.ColorPaletteCache)
local AdjustObjectDescendantsColors = require(game.ReplicatedStorage.Util.AdjustObjectDescendantsColors)

local function warnstudio(...) end

local function SetParentOverrideWithColor(instance, parent, character, childName: string, flag: boolean?)
	if character == nil or character.Parent == nil then
		if typeof(character) == "table" and character.Character then
			character = character.Character
		else
			warnstudio(character, "SetParentOverrideWithColor: WARNING, MISSING PLAYER" .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
			instance.Parent = parent
			return
		end
	end

	local child = character:FindFirstChild(childName)

	if child == nil then
		if typeof(character) == "Instance" and character:IsA("Player") then
			warnstudio(`SetParentOverrideWithColor: WARNING, MISSING Color3ValueFolder "{childName}" under player "{character}"` .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
		end

		instance.Parent = parent
	else
		local v = ColorPaletteCache.get(child)

		if v == nil then
			instance.Parent = parent
			return
		end

		if v.AllColorsUnchanged then
			instance.Parent = parent
			return
		end

		if instance:GetAttribute("ContainsRetextureForRecolor") then
			local configurations = {}
			local findRetextureForRecolors

			findRetextureForRecolors = function(instance2)
				local configuration = instance2:FindFirstChildOfClass("Configuration")

				if configuration and configuration.Name == "RetextureForRecolor" then
					table.insert(configurations, configuration)
				end

				for _, child2 in ipairs(instance2:GetChildren()) do
					if child2:GetAttribute("ContainsRetextureForRecolor") then
						findRetextureForRecolors(child2)
					end
				end
			end

			findRetextureForRecolors(instance)

			for _, v2 in ipairs(configurations) do
				if v2.Parent == nil then
					continue
				end

				local skinKey = v2:GetAttribute("SkinKey")

				if not (skinKey == nil or skinKey == child:GetAttribute("SkinStorageKey")) then
					continue
				end

				if v2.Parent:IsA("SurfaceAppearance") then
					local parent2 = v2.Parent
					local colorValuesByColorPropertyName = v2[parent2.Name]

					if v2:GetAttribute("ColorPropertyName") and v2:GetAttribute("ColorValue") then
						colorValuesByColorPropertyName[v2:GetAttribute("ColorPropertyName")] = v2:GetAttribute("ColorValue")
						colorValuesByColorPropertyName:SetAttribute("RetextureTintApplied", true)
					end

					colorValuesByColorPropertyName.Parent = parent2.Parent

					if parent2 == instance then
						instance = colorValuesByColorPropertyName
					end

					parent2:Destroy()
				elseif v2.Parent:IsA("MaterialVariant") then
					local parent2 = v2.Parent
					local colorValuesByColorPropertyName = v2[parent2.Name]

					if v2:GetAttribute("ColorPropertyName") and v2:GetAttribute("ColorValue") then
						colorValuesByColorPropertyName[v2:GetAttribute("ColorPropertyName")] = v2:GetAttribute("ColorValue")
					end

					colorValuesByColorPropertyName.Parent = parent2.Parent

					if parent2 == instance then
						instance = colorValuesByColorPropertyName
					end

					parent2:Destroy()
				elseif v2.Parent:IsA("MeshPart") then
					local parent2 = v2.Parent
					local part = v2:FindFirstChild(parent2.Name)

					if part and part:IsA("MeshPart") then
						local retextureForRecolorSA = part:FindFirstChild("RetextureForRecolorSA")

						if retextureForRecolorSA and retextureForRecolorSA:IsA("SurfaceAppearance") then
							local surfaceAppearance = parent2:FindFirstChildWhichIsA("SurfaceAppearance")

							if surfaceAppearance then
								surfaceAppearance:Destroy()
							end

							local clone = retextureForRecolorSA:Clone()
							clone.Name = "RetextureForRecolorSA"
							clone.Parent = parent2
							local parent3 = parent2
							pcall(function()
								parent3.TextureID = ""
							end)
						else
							warn("RetextureForRecolor: Expected SurfaceAppearance 'RetextureForRecolorSA' not found under: " .. part:GetFullName())
						end
					else
						warn("RetextureForRecolor: MeshPart clone missing under config: " .. v2:GetFullName())
					end

					v2:Destroy()

					if parent2 == instance then
						instance = parent2
					end
				else
					local decal = v2:FindFirstChildWhichIsA("Decal")

					if decal then
						local name = decal.Name
						local texture = decal.Texture

						if v2:GetAttribute("ColorPropertyName") and v2:GetAttribute("ColorValue") then
							v2.Parent[v2:GetAttribute("ColorPropertyName")] = v2:GetAttribute("ColorValue")
						end

						v2.Parent[name] = texture
					else
						warn("RetextureForRecolor config file is missing relevant replacement. See: \n" .. v2:GetFullName() .. " with debug.traceback: \n" .. debug.traceback())
					end
				end
			end
		end

		local fn = v.ShiftedSequences ~= nil and function(_, _: string, p)
			return ColorPaletteCache.getSequenceResampleTimes(v, p)
		end or nil
		AdjustObjectDescendantsColors(instance, function(_, _, p, _, p2)
			if ColorEncoder.isColorDataEncoded(p) then
				return p
			end

			return ColorPaletteCache.transformColor(v, p, p2)
		end, flag, nil, fn)
		instance.Parent = parent
	end
end

return SetParentOverrideWithColor