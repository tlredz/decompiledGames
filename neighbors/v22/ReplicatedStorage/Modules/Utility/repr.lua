local v = {
	pretty = false,
	robloxFullName = false,
	robloxProperFullName = true,
	robloxClassName = true,
	tabs = false,
	semicolons = false,
	spaces = 3,
	sortKeys = true
}
local v2 = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true
}

local function isLuaIdentifier(value)
	if not (type(value) == "string" and value:len() ~= 0) then
		return false
	end

	return not value:find("[^%d%a_]") and not tonumber(value:sub(1, 1)) and not v2[value]
end

local properFullName

properFullName = function(instance, _)
	if instance == nil or instance == game then
		return ""
	end

	local name = instance.Name
	local v3 = true
	local v4

	if type(name) == "string" and name:len() ~= 0 and not (name:find("[^%d%a_]") or tonumber(name:sub(1, 1))) then
		v4 = not v2[name]
	else
		v4 = false
	end

	if not v4 then
		name = ("[%q]"):format(name)
		v3 = false
	end

	if instance.Parent and instance.Parent ~= game then
		return properFullName(instance.Parent) .. (v3 and "." or "") .. name
	end

	return name
end

local v3 = 0
local v4 = nil
local v5 = nil
local repr

repr = function(cframe, p)
	local v6 = p or v
	v5 = (" "):rep(v6.spaces or v.spaces)

	if v6.tabs then
		v5 = "\t"
	end

	local v7 = v5:rep(v3)

	if v3 == 0 then
		v4 = {}
	end

	if type(cframe) == "string" then
		return ("%q"):format(cframe)
	end

	if type(cframe) == "number" then
		if cframe == 1e999 then
			return "math.huge"
		elseif cframe == -1e999 then
			return "-math.huge"
		end

		return (tonumber(cframe))
	else
		if type(cframe) == "boolean" then
			return (tostring(cframe))
		end

		if type(cframe) == "nil" then
			return "nil"
		end

		if type(cframe) == "table" and type(cframe.__tostring) == "function" then
			return (tostring(cframe.__tostring(cframe)))
		end

		if type(cframe) == "table" and getmetatable(cframe) and type(getmetatable(cframe).__tostring) == "function" then
			return (tostring(getmetatable(cframe).__tostring(cframe)))
		end

		if type(cframe) == "table" then
			if v4[cframe] then
				return "{CYCLIC}"
			end

			v4[cframe] = true
			local v8 = "{" .. (not v6.pretty and "" or "\n" .. v5 .. v7 or "")
			local flag = true

			for k, _ in pairs(cframe) do
				if type(k) == "number" then
					continue
				end

				flag = false
				break
			end

			if flag then
				for i = 1, #cframe do
					if i ~= 1 then
						v8 ..= (v6.semicolons and ";" or ",") .. (not v6.pretty and " " or "\n" .. v5 .. v7 or " ")
					end

					v3 += 1
					v8 ..= repr(cframe[i], v6)
					v3 -= 1
				end
			else
				local v10 = {}
				local v11 = {}

				for k, item in pairs(cframe) do
					v3 += 1
					local v13 = type(k) == "string" and k:len() ~= 0 and not (k:find("[^%d%a_]") or tonumber(k:sub(1, 1))) and not v2[k] and k or "[" .. repr(
						k,
						v6
					) .. "]"
					local v14 = repr(item, v6)
					table.insert(v10, v13)
					v11[v13] = v14
					v3 -= 1
				end

				if v6.sortKeys then
					table.sort(v10)
				end

				local v12 = true

				for _, v13 in pairs(v10) do
					if not v12 then
						v8 ..= (v6.semicolons and ";" or ",") .. (not v6.pretty and " " or "\n" .. v5 .. v7 or " ")
					end

					v8 ..= ("%s = %s"):format(v13, v11[v13])
					v12 = false
				end
			end

			v4[cframe] = false

			if v6.pretty then
				v8 ..= "\n" .. v7
			end

			return v8 .. "}"
		else
			if not typeof then
				return "<" .. type(cframe) .. ">"
			end

			if typeof(cframe) == "Instance" then
				return (v6.robloxFullName and (v6.robloxProperFullName and properFullName(cframe) or cframe:GetFullName()) or cframe.Name) .. (v6.robloxClassName and (" (%s)"):format(cframe.ClassName) or "")
			end

			if typeof(cframe) == "Axes" then
				local v8 = {}

				if cframe.X then
					table.insert(v8, repr(Enum.Axis.X, v6))
				end

				if cframe.Y then
					table.insert(v8, repr(Enum.Axis.Y, v6))
				end

				if cframe.Z then
					table.insert(v8, repr(Enum.Axis.Z, v6))
				end

				return ("Axes.new(%s)"):format(table.concat(v8, ", "))
			else
				if typeof(cframe) == "BrickColor" then
					return ("BrickColor.new(%q)"):format(cframe.Name)
				end

				if typeof(cframe) == "CFrame" then
					return ("CFrame.new(%s)"):format(table.concat({ cframe:GetComponents() }, ", "))
				end

				if typeof(cframe) == "Color3" then
					return ("Color3.new(%d, %d, %d)"):format(cframe.r, cframe.g, cframe.b)
				end

				if typeof(cframe) == "ColorSequence" then
					if #cframe.Keypoints > 2 then
						return ("ColorSequence.new(%s)"):format(repr(cframe.Keypoints, v6))
					end

					if cframe.Keypoints[1].Value == cframe.Keypoints[2].Value then
						return ("ColorSequence.new(%s)"):format(repr(cframe.Keypoints[1].Value, v6))
					end

					return ("ColorSequence.new(%s, %s)"):format(
						repr(cframe.Keypoints[1].Value, v6),
						repr(cframe.Keypoints[2].Value, v6)
					)
				else
					if typeof(cframe) == "ColorSequenceKeypoint" then
						return ("ColorSequenceKeypoint.new(%d, %s)"):format(cframe.Time, repr(cframe.Value, v6))
					end

					if typeof(cframe) == "DockWidgetPluginGuiInfo" then
						return ("DockWidgetPluginGuiInfo.new(%s, %s, %s, %s, %s, %s, %s)"):format(
							repr(cframe.InitialDockState, v6),
							repr(cframe.InitialEnabled, v6),
							repr(cframe.InitialEnabledShouldOverrideRestore, v6),
							repr(cframe.FloatingXSize, v6),
							repr(cframe.FloatingYSize, v6),
							repr(cframe.MinWidth, v6),
							repr(cframe.MinHeight, v6)
						)
					end

					if typeof(cframe) == "Enums" then
						return "Enums"
					end

					if typeof(cframe) == "Enum" then
						return ("Enum.%s"):format((tostring(cframe)))
					end

					if typeof(cframe) == "EnumItem" then
						return ("Enum.%s.%s"):format(tostring(cframe.EnumType), cframe.Name)
					end

					if typeof(cframe) == "Faces" then
						local v8 = {}

						for _, v9 in pairs(Enum.NormalId:GetEnumItems()) do
							if cframe[v9.Name] then
								table.insert(v8, repr(v9, v6))
							end
						end

						return ("Faces.new(%s)"):format(table.concat(v8, ", "))
					elseif typeof(cframe) == "NumberRange" then
						if cframe.Min == cframe.Max then
							return ("NumberRange.new(%d)"):format(cframe.Min)
						end

						return ("NumberRange.new(%d, %d)"):format(cframe.Min, cframe.Max)
					elseif typeof(cframe) == "NumberSequence" then
						if #cframe.Keypoints > 2 then
							return ("NumberSequence.new(%s)"):format(repr(cframe.Keypoints, v6))
						end

						if cframe.Keypoints[1].Value == cframe.Keypoints[2].Value then
							return ("NumberSequence.new(%d)"):format(cframe.Keypoints[1].Value)
						end

						return ("NumberSequence.new(%d, %d)"):format(
							cframe.Keypoints[1].Value,
							cframe.Keypoints[2].Value
						)
					elseif typeof(cframe) == "NumberSequenceKeypoint" then
						if cframe.Envelope == 0 then
							return ("NumberSequenceKeypoint.new(%d, %d)"):format(cframe.Time, cframe.Value)
						end

						return ("NumberSequenceKeypoint.new(%d, %d, %d)"):format(
							cframe.Time,
							cframe.Value,
							cframe.Envelope
						)
					else
						if typeof(cframe) == "PathWaypoint" then
							return ("PathWaypoint.new(%s, %s)"):format(
								repr(cframe.Position, v6),
								repr(cframe.Action, v6)
							)
						end

						if typeof(cframe) == "PhysicalProperties" then
							return ("PhysicalProperties.new(%d, %d, %d, %d, %d)"):format(
								cframe.Density,
								cframe.Friction,
								cframe.Elasticity,
								cframe.FrictionWeight,
								cframe.ElasticityWeight
							)
						end

						if typeof(cframe) == "Random" then
							return "<Random>"
						end

						if typeof(cframe) == "Ray" then
							return ("Ray.new(%s, %s)"):format(repr(cframe.Origin, v6), repr(cframe.Direction, v6))
						end

						if typeof(cframe) == "RBXScriptConnection" then
							return "<RBXScriptConnection>"
						end

						if typeof(cframe) == "RBXScriptSignal" then
							return "<RBXScriptSignal>"
						end

						if typeof(cframe) == "Rect" then
							return ("Rect.new(%d, %d, %d, %d)"):format(
								cframe.Min.X,
								cframe.Min.Y,
								cframe.Max.X,
								cframe.Max.Y
							)
						end

						if typeof(cframe) == "Region3" then
							local v8 = cframe.CFrame.p + cframe.Size * -0.5
							local v9 = cframe.CFrame.p + cframe.Size * 0.5
							return ("Region3.new(%s, %s)"):format(repr(v8, v6), repr(v9, v6))
						else
							if typeof(cframe) == "Region3int16" then
								return ("Region3int16.new(%s, %s)"):format(repr(cframe.Min, v6), repr(cframe.Max, v6))
							end

							if typeof(cframe) == "TweenInfo" then
								return ("TweenInfo.new(%d, %s, %s, %d, %s, %d)"):format(
									cframe.Time,
									repr(cframe.EasingStyle, v6),
									repr(cframe.EasingDirection, v6),
									cframe.RepeatCount,
									repr(cframe.Reverses, v6),
									cframe.DelayTime
								)
							end

							if typeof(cframe) == "UDim" then
								return ("UDim.new(%d, %d)"):format(cframe.Scale, cframe.Offset)
							end

							if typeof(cframe) == "UDim2" then
								return ("UDim2.new(%d, %d, %d, %d)"):format(
									cframe.X.Scale,
									cframe.X.Offset,
									cframe.Y.Scale,
									cframe.Y.Offset
								)
							end

							if typeof(cframe) == "Vector2" then
								return ("Vector2.new(%d, %d)"):format(cframe.X, cframe.Y)
							end

							if typeof(cframe) == "Vector2int16" then
								return ("Vector2int16.new(%d, %d)"):format(cframe.X, cframe.Y)
							end

							if typeof(cframe) == "Vector3" then
								return ("Vector3.new(%d, %d, %d)"):format(cframe.X, cframe.Y, cframe.Z)
							end

							if typeof(cframe) == "Vector3int16" then
								return ("Vector3int16.new(%d, %d, %d)"):format(cframe.X, cframe.Y, cframe.Z)
							end

							if typeof(cframe) == "DateTime" then
								return ("DateTime.fromIsoDate(%q)"):format(cframe:ToIsoDate())
							end

							return "<Roblox:" .. typeof(cframe) .. ">"
						end
					end
				end
			end
		end
	end
end

return repr