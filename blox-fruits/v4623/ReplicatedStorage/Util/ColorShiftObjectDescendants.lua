local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local ColorPaletteCache = require(game.ReplicatedStorage.Util.ColorPaletteCache)
local GetColorPropertiesFor = require(game.ReplicatedStorage.Util.GetColorPropertiesFor)
local AdjustObjectDescendantsColors = require(game.ReplicatedStorage.Util.AdjustObjectDescendantsColors)
local RestoreDefaultColorProperties = require(game.ReplicatedStorage.Util.RestoreDefaultColorProperties)

local function warnstudio(...)
	local RunService = game:GetService("RunService")

	if RunService:IsStudio() then
		warn(...)
	else
		print(...)
	end
end

local function buildColorTargets(folder)
	local result = {}
	local props = GetColorPropertiesFor(folder)

	if #props > 0 then
		table.insert(result, {
			obj = folder,
			props = props
		})
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		local props2 = GetColorPropertiesFor(descendant)

		if #props2 > 0 then
			table.insert(result, {
				obj = descendant,
				props = props2
			})
		end
	end

	return result
end

local function ColorShiftObjectDescendants(instance, player, childName: string, p)
	if player == nil or player.Parent == nil then
		warnstudio("ColorShiftObjectDescendants: WARNING, MISSING PLAYER" .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
		return
	end

	local child = player:FindFirstChild(childName)

	if child == nil then
		if typeof(player) == "Instance" and player:IsA("Player") then
			warnstudio("ColorShiftObjectDescendants: WARNING, MISSING Color3ValueFolder" .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
		end
	else
		if type(p) ~= "table" then
			p = nil
		end

		debug.profilebegin("ColorShiftObjectDescendants")
		local v = ColorPaletteCache.get(child)

		if v == nil then
			debug.profileend()
		elseif v.AllColorsUnchanged then
			local v3

			if p then
				v3 = p.targets
			end

			RestoreDefaultColorProperties(instance, v3)
			debug.profileend()
		else
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
						local parent = v2.Parent
						local colorValuesByColorPropertyName = v2[parent.Name]

						if v2:GetAttribute("ColorPropertyName") and v2:GetAttribute("ColorValue") then
							colorValuesByColorPropertyName[v2:GetAttribute("ColorPropertyName")] = v2:GetAttribute("ColorValue")
							colorValuesByColorPropertyName:SetAttribute("RetextureTintApplied", true)
						end

						colorValuesByColorPropertyName.Parent = parent.Parent

						if parent == instance then
							instance = colorValuesByColorPropertyName
						end

						parent:Destroy()
					elseif v2.Parent:IsA("MaterialVariant") then
						local parent = v2.Parent
						local colorValuesByColorPropertyName = v2[parent.Name]

						if v2:GetAttribute("ColorPropertyName") and v2:GetAttribute("ColorValue") then
							colorValuesByColorPropertyName[v2:GetAttribute("ColorPropertyName")] = v2:GetAttribute("ColorValue")
						end

						colorValuesByColorPropertyName.Parent = parent.Parent

						if parent == instance then
							instance = colorValuesByColorPropertyName
						end

						parent:Destroy()
					elseif v2.Parent:IsA("MeshPart") then
						local parent = v2.Parent
						local part = v2:FindFirstChild(parent.Name)

						if part and part:IsA("MeshPart") then
							local retextureForRecolorSA = part:FindFirstChild("RetextureForRecolorSA")

							if retextureForRecolorSA and retextureForRecolorSA:IsA("SurfaceAppearance") then
								local surfaceAppearance = parent:FindFirstChildWhichIsA("SurfaceAppearance")

								if surfaceAppearance then
									surfaceAppearance:Destroy()
								end

								local clone = retextureForRecolorSA:Clone()
								clone.Name = "RetextureForRecolorSA"
								clone.Parent = parent
								local parent2 = parent
								pcall(function()
									parent2.TextureID = ""
								end)
							else
								warn("RetextureForRecolor: Expected SurfaceAppearance 'RetextureForRecolorSA' not found under: " .. part:GetFullName())
							end
						else
							warn("RetextureForRecolor: MeshPart clone missing under config: " .. v2:GetFullName())
						end

						v2:Destroy()

						if parent == instance then
							instance = parent
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

			local targets

			if p then
				if p.targets == nil then
					p.targets = buildColorTargets(instance)
				end

				targets = p.targets
			end

			local fn = v.ShiftedSequences and function(_, _: string, p2)
				return ColorPaletteCache.getSequenceResampleTimes(v, p2)
			end or nil
			AdjustObjectDescendantsColors(instance, function(_, _, p2, _, p3)
				if ColorEncoder.isColorDataEncoded(p2) then
					return p2
				end

				return ColorPaletteCache.transformColor(v, p2, p3)
			end, true, targets, fn)
			debug.profileend()
		end
	end
end

return ColorShiftObjectDescendants