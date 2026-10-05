local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local AssetItemData = require(game.ReplicatedStorage.Util.AssetItemData)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local v = nil
return function(data)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Name = "__ModifierImages"
	frame.Size = UDim2.fromScale(1, 1)
	local v2 = nil
	local v3 = {}
	v = v or Realm.getCurrentSeaAsync()
	local size

	if data and data.Size then
		size = data.Size
	else
		size = nil
	end

	local position

	if data and data.Position then
		position = data.Position
	else
		position = nil
	end

	local anchorPoint

	if data and data.AnchorPoint then
		anchorPoint = data.AnchorPoint
	else
		anchorPoint = nil
	end

	local function update(name, parent)
		if v2 == name then
			return
		end

		v2 = name

		for k, v4 in pairs(v3) do
			if k == name then
				v4.Visible = true
			else
				v4.Visible = false
			end
		end

		if not v3[name] then
			local modifierData = AccessoriesShared.GetModifierData(name)

			if modifierData == nil then
				warn((`no modifier in AccessoriesShared.GetModifierData with name={name}`))
				return
			end

			local frame2 = Instance.new("Frame")
			frame2.BackgroundTransparency = 1
			frame2.Position = position or parent.Position
			frame2.AnchorPoint = anchorPoint or parent.AnchorPoint
			frame2.Size = size or parent.Size
			frame2.Name = name
			frame2.Parent = frame
			v3[name] = frame2
			local count = 0

			for k, effect in pairs(modifierData.Effects) do
				local v4 = effect[v] or effect.Sea3

				if v4 then
					local v5 = AccessoriesShared.EFFECT_MAPPINGS[k]

					if v5 then
						local v6 = AssetItemData.fromLegacyName(v5)

						if v6:isErr() then
							warn(v6:unwrapErr())
						else
							local solve = AssetItemData.solve(v6:unwrap(), v4)

							if solve:isErr() then
								warn(solve:unwrapErr())
							else
								local unwrapped = solve:unwrap()
								count += 1
								local frame3 = Instance.new("Frame")
								frame3.BackgroundTransparency = 1
								frame3.Size = UDim2.fromScale(1, 1)
								frame3.Name = k
								frame3.Visible = true
								frame3.Parent = frame2
								local main

								if unwrapped.Icon.Main and unwrapped.Icon.Main.Image and typeof(unwrapped.Icon.Main.Image) == "string" then
									main = unwrapped.Icon.Main
								end

								local variant

								if unwrapped.Icon.Variant and unwrapped.Icon.Variant.Image and typeof(unwrapped.Icon.Variant.Image) == "string" then
									variant = unwrapped.Icon.Variant
								end

								local v7

								if main and variant and data and data.SwapMiniForPrimary then
									main = variant
									variant = nil
									v7 = true
								else
									v7 = false
								end

								if main then
									local image = assert(main.Image)
									local imageLabel = Instance.new("ImageLabel")
									imageLabel.BackgroundTransparency = 1
									imageLabel.Name = "Main"
									imageLabel.Size = UDim2.fromScale(1, 1)
									imageLabel.Position = UDim2.fromScale(0.5, 0.5)
									imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
									imageLabel.Image = image
									imageLabel.ImageRectOffset = main.ImageRectOffset
									imageLabel.ImageRectSize = main.ImageRectSize
									imageLabel.Parent = frame3
									Instance.new("UIAspectRatioConstraint", imageLabel)
								end

								if variant then
									local image = assert(variant.Image)
									local imageLabel = Instance.new("ImageLabel")
									imageLabel.BackgroundTransparency = 1
									imageLabel.Name = "Variant"
									imageLabel.Size = UDim2.fromScale(0.3, 0.3)
									imageLabel.Position = UDim2.fromScale(1, 1)
									imageLabel.AnchorPoint = Vector2.new(1, 1)
									imageLabel.Image = image
									imageLabel.ImageRectOffset = variant.ImageRectOffset
									imageLabel.ImageRectSize = variant.ImageRectSize
									imageLabel.Parent = frame3
									Instance.new("UIAspectRatioConstraint", imageLabel)
								end

								local modifier = unwrapped.Icon.Modifier

								if modifier and modifier.Image and typeof(modifier.Image) == "string" and not v7 then
									local imageLabel = Instance.new("ImageLabel")
									imageLabel.BackgroundTransparency = 1
									imageLabel.Name = "Modifier"
									imageLabel.Size = UDim2.fromScale(0.3, 0.3)
									imageLabel.Position = UDim2.fromScale(0, 1)
									imageLabel.AnchorPoint = Vector2.new(0, 1)
									imageLabel.Image = modifier.Image
									imageLabel.ImageRectOffset = modifier.ImageRectOffset
									imageLabel.ImageRectSize = modifier.ImageRectSize

									if unwrapped.Icon.ModifierColor then
										imageLabel.ImageColor3 = unwrapped.Icon.ModifierColor
									end

									imageLabel.Parent = frame3
									Instance.new("UIAspectRatioConstraint", imageLabel)
								end
							end
						end
					else
						warn((`no effectName in AccessoriesShared.EFFECT_MAPPINGS with name={k}`))
					end
				else
					warn((`no sea in effect list: {k}.Effects[{v}]`))
				end
			end

			local _ = count > 1
		end

		frame.Parent = parent
	end

	return {
		Container = frame,
		SetVisible = function(visible: boolean)
			frame.Visible = visible
		end,
		Update = update,
		Destroy = function()
			table.clear(v3)
			frame:Destroy()
		end
	}
end