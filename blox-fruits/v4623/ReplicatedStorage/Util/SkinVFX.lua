local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Appearance = require(game.ReplicatedStorage.Definitions.Skin.Appearance)
local Modification = require(game.ReplicatedStorage.Util.Modification)
require(game.ReplicatedStorage.Modules.Net)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Util"):tag("Modifications"):tag("SkinVFX"):display():traceback():build()
local skinnedRigs = game.ReplicatedStorage.Assets:FindFirstChild("SkinnedRigs")

function applySkin(instance, p: number?, instance2)
	local extended = v.extend("applySkin")
	extended.info((`fn called: (module={instance}, modId={p}, rig={instance2:GetFullName()})`))

	if not p then
		return
	end

	local unwrapped = ItemConfig.match(p):unwrap()
	extended.trace((`modConfig: {unwrapped.Index.DebugLabel}`))
	local name = unwrapped.Display.Name
	local storageKey = unwrapped.Index.StorageKey
	local recur

	recur = function(items, parent, instance3)
		for childName, item in pairs(items) do
			local clone = parent:FindFirstChild(childName)

			if parent:FindFirstChildOfClass("SurfaceAppearance") then
				for _, surfaceAppearance in pairs(parent:GetChildren()) do
					if surfaceAppearance:IsA("SurfaceAppearance") then
						surfaceAppearance:Destroy()
					end
				end
			elseif clone and clone:FindFirstChildOfClass("SurfaceAppearance") then
				for _, surfaceAppearance in pairs(clone:GetChildren()) do
					if surfaceAppearance:IsA("SurfaceAppearance") then
						surfaceAppearance:Destroy()
					end
				end
			end

			if item.Properties and item.Properties.ClassName == "SurfaceAppearance" then
				local v2

				if name then
					v2 = instance3:FindFirstChild(name)
				end

				local surfaceAppearance = v2 or instance3:FindFirstChild(storageKey) or instance3:FindFirstChild("Default")

				if surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance") then
					clone = surfaceAppearance:Clone()
					clone.Parent = parent
				else
					warn("No matching surface appearance found for skin", name or storageKey)
				end
			end

			if clone then
				if item.Properties then
					for k, property in pairs(item.Properties) do
						if k ~= "ClassName" then
							clone[k] = property
						end
					end
				end

				if item.Children then
					recur(item.Children, clone, (instance3:FindFirstChild(childName)))
				end
			else
				warn("No matching part in rig found with name", childName)
			end
		end
	end

	local rig = instance:FindFirstChild("Rig")
	assert(rig, "bad storage")
	local unwrapped2 = Modification.matchAdornee(p):unwrap()
	local nullable = Modification.matchDefaultSkin(unwrapped2):asNullable()
	local v2

	if nullable then
		v2 = ItemConfig.match(nullable):unwrap()
	end

	local module = require(instance)
	local v3 = module[name or storageKey]

	if not v3 then
		if v2 then
			local module2 = require(instance)
			v3 = module2[v2.Display.Name or v2.Index.StorageKey]
		else
			v3 = v2
		end
	end

	if not v3 then
		extended.trace("couldn't find skin")
		return
	end

	assert(v3, (`no skin definition for {instance:GetFullName()} and skin "{unwrapped.Index.DebugLabel}"`))
	extended.trace("recursively applying")
	recur(v3, instance2, rig)
end

local SkinVFX = {
	applyChaliceColor = function(instance, data)
		if data.Type ~= "ColorSet" then
			warn("only ColorSet is supported")
			return function() end
		end

		local outline = instance:FindFirstChild("Outline")

		if not (outline and outline:IsA("BasePart")) then
			warn("Outline invalid", outline, typeof(outline), instance:GetChildren())
			return function() end
		end

		outline.Color = data.Color3
		local v2

		if data.FadeColor3 then
			local TweenService = game:GetService("TweenService")
			v2 = TweenService:Create(
				outline,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true, 0),
				{
					Color = data.FadeColor3
				}
			)
			assert(v2):Play()
		else
			v2 = nil
		end

		return function()
			if v2 then
				v2:Cancel()
				v2 = nil
			end
		end
	end,
	applySkin = function(p: number?, items)
		local extended = v.extend(".applySkin")
		extended.info((`fn called: (modId={p}, rigs={items})`))
		extended.trace(function()
			return "rigs", items
		end)

		if not skinnedRigs then
			return
		end

		for k, item in pairs(items) do
			assert(typeof(k) == "Instance")
			assert(typeof(item) == "string")
			local parts = item:split(".")
			local v2 = k
			local v3 = item
			extended.trace(function()
				return `inst: "{v2 and v2:GetFullName() or nil}"`, `path: "{v3}"`, "split", parts
			end)
			local child = skinnedRigs:FindFirstChild(parts[1])

			for i = 2, #parts do
				child = child:FindFirstChild(parts[i])
			end

			if child then
				extended.trace((`found module: {child:GetFullName()}`))
				applySkin(child, p, k)
			elseif parts[1] ~= "InstRoot" then
				local v5 = parts
				extended.warn(function()
					return "no rig data found for: ", v5
				end)
			end
		end
	end,
	applyColorShiftHSV = function(color: Color3, p: number, p2: number, p3: number)
		local v2 = math.max(1, color.R, color.G, color.B)
		local v3 = math.floor(color.R / v2 * 255) % 256
		local v4 = math.floor(color.G / v2 * 255) % 256
		local v5 = math.floor(color.B / v2 * 255) % 256
		local HSV, v6, v7 = Color3.fromRGB(v3, v4, v5):ToHSV()
		local v8 = (HSV + p) % 1
		local v9 = math.clamp(v6 * p2, 0, 1)
		local v10 = math.clamp(v7 * p3, 0, 1)
		return Color3.fromHSV(v8, v9, v10 * v2)
	end,
	applyStackedDefinitions = function(instance, ...)
		local v2 = { ... }

		if #v2 == 0 then
			return
		end

		local default = instance:FindFirstChild("Default") or instance
		local shifted = instance:FindFirstChild("Shifted") or instance

		for k in default:GetAttributes() do
			if k:match("^Default_Color%d+$") then
				default:SetAttribute(k, nil)
			end
		end

		for k in shifted:GetAttributes() do
			if k:match("^Shifted_Color%d+$") or k:match("^Shifted_Color%d+_StaticTime$") then
				shifted:SetAttribute(k, nil)
			end
		end

		Appearance.applyPaletteToInstance(default, nil, "Default", "Overwrite")
		Appearance.applyPaletteToInstance(shifted, nil, "Shifted", "Overwrite")

		for _, v3 in ipairs(v2) do
			assert(v3.Type == "Palette", "all definitions must be type \"Pallete\"")
			Appearance.applyPaletteToInstance(default, v3, "Default", "FillBlanks")
			Appearance.applyPaletteToInstance(shifted, v3, "Shifted", "FillBlanks")
		end

		instance:SetAttribute("PaletteVersion", (instance:GetAttribute("PaletteVersion") or 0) + 1)
	end
}

function SkinVFX.updateVFXFolder(instance, value)
	local v2

	if typeof(value) == "number" then
		v2 = ItemConfig.match(value):unwrap()
	else
		v2 = ItemConfig.match(value, "Skin"):unwrap()
	end

	if v2.Skin and v2.Skin.Type ~= "Aura" then
		local unwrapped = Modification.matchAdornee(v2.Index.ItemId):unwrap()
		local unwrapped2 = Modification.matchDefaultSkin(unwrapped):unwrap()
		local nullable = Skin.Definition.Appearance.match(unwrapped2):asNullable()
		local nullable2 = Skin.Definition.Appearance.match(v2.Index.ItemId):asNullable()
		local nullables = {}

		if nullable2 then
			table.insert(nullables, nullable2)
		end

		if nullable then
			table.insert(nullables, nullable)
		end

		if #nullables > 0 then
			SkinVFX.applyStackedDefinitions(instance, table.unpack(nullables))
		end

		instance:SetAttribute("ItemId", v2.Index.ItemId)
		instance:SetAttribute("SkinStorageKey", v2.Index.StorageKey)
	end
end

return SkinVFX