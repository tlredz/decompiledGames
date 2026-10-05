local ImageUtil = {}
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local DragonNames = require(game.ReplicatedStorage.Modules.Asset.DragonNames)
local ChromaticSprites = require(game.ReplicatedStorage.Modules.SpriteSheets.ChromaticSprites)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local v = {}
local v2 = nil
local v3 = {
	["Permanent Dragon-Dragon"] = function()
		return (`Permanent {DragonNames.East}`)
	end
}

function getIconSpriteFromItemId(p: number?)
	if not p then
		return nil
	end

	local nullable = ItemConfig.match(p):asNullable()

	if nullable then
		return nullable.Display.Sprite
	end

	return nil
end

function getOutlineSpriteFromItemId(p: number?)
	if not p then
		return nil
	end

	local nullable = ItemConfig.match(p):asNullable()

	if nullable then
		return nullable.Display.OutlineSprite
	end

	return nil
end

function spriteToIcon(data, color: Color3?)
	if data then
		return {
			Image = data.Image,
			ImageRectOffset = data.ImageRectOffset or Vector2.new(0, 0),
			ImageRectSize = data.ImageRectSize or Vector2.new(0, 0),
			ImageColor3 = color or Color3.new(1, 1, 1),
			ImageTransparency = 0
		}
	end

	return nil
end

function iconToImageInput(icon, outline, flag: boolean?)
	if icon then
		return {
			Loaded = not typeof(flag) or flag,
			Icon = icon,
			Outline = outline
		}
	end

	return nil
end

function imageInputToImage(data)
	if not data then
		return nil
	end

	local icon = {
		Image = data.Icon.Image,
		ImageRectOffset = data.Icon.ImageRectOffset,
		ImageRectSize = data.Icon.ImageRectSize,
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0
	}
	return {
		Loaded = data.Loaded,
		Icon = data.Icon,
		Outline = data.Outline,
		Hidden = {
			Icon = icon,
			Outline = data.Outline
		}
	}
end

local v4 = {
	Loaded = false,
	Icon = {
		Image = "rbxasset://textures/ui/PlayerList/Block@3x.png",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.7,
		ImageRectOffset = Vector2.new(0, 0),
		ImageRectSize = Vector2.new(0, 0)
	},
	Hidden = {
		Icon = {
			Image = "",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.7,
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0)
		}
	}
}

function ImageUtil.getImageFromSprite(p, p2)
	if p then
		return imageInputToImage(iconToImageInput(
			spriteToIcon(p, Color3.fromRGB(255, 255, 255)),
			spriteToIcon(p2, Color3.fromRGB(0, 0, 0))
		))
	end

	return nil
end

function ImageUtil.getImageFromItemId(storageKey, joined)
	local v5 = nil
	local success, result = pcall(function(...)
		if typeof(storageKey) == "number" then
			v5 = ItemConfig.match(storageKey):asNullable()
		elseif typeof(storageKey) == "string" then
			local v6 = nil

			if typeof(joined) == "string" then
				v6 = ItemId.getId(storageKey, joined):asNullable()
			elseif typeof(joined) == "table" then
				v5 = ItemConfig.Query.selectFirst({
					Index = {
						StorageKey = storageKey,
						IdType = {
							Operation = "OR",
							Values = joined
						}
					}
				}):asNullable()
			end

			if v6 then
				v5 = ItemConfig.match(v6):asNullable()
			end
		end
	end)

	if success then
		if v5 then
			return imageInputToImage(iconToImageInput(
				spriteToIcon(v5.Display.Sprite, Color3.fromRGB(255, 255, 255)),
				spriteToIcon(v5.Display.OutlineSprite, Color3.fromRGB(0, 0, 0))
			))
		end

		return nil
	else
		if typeof(joined) == "table" then
			joined = table.concat(joined, ",")
		end

		warn((`Error getting item config for "{storageKey}" ({joined}): {result}`))
		return nil
	end
end

function ImageUtil.getImageForToolInstance(instance, storageKey)
	local v5 = instance:HasTag("Fruit") and "Fruit" or "Item"

	if not v5 then
		return nil
	end

	local dragonType = instance:GetAttribute("DragonType")

	if not storageKey then
		local iconImage = instance:GetAttribute("IconImage")

		if type(iconImage) == "string" and iconImage ~= "" then
			local v6 = {
				Image = iconImage,
				ImageRectOffset = Vector2.new(0, 0),
				ImageRectSize = Vector2.new(0, 0),
				ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 0
			}
			return imageInputToImage(iconToImageInput(v6))
		end

		local iconSpriteKey = instance:GetAttribute("IconSpriteKey")

		if type(iconSpriteKey) == "string" then
			local nullable = Spritesheets.match(iconSpriteKey):asNullable()
			local v6 = nil

			if nullable then
				local outlineSpriteKey = instance:GetAttribute("OutlineSpriteKey")

				if type(outlineSpriteKey) == "string" then
					v6 = Spritesheets.match(outlineSpriteKey):asNullable()
				end
			end

			return imageInputToImage(iconToImageInput(spriteToIcon(nullable), spriteToIcon(v6, Color3.new())))
		else
			local fruitSkinId = instance:GetAttribute("FruitSkinId")

			if type(fruitSkinId) == "number" then
				local nullable = ItemConfig.match(fruitSkinId):asNullable()

				if nullable and nullable.Index.IdType == "Skin" then
					storageKey = nullable.Index.StorageKey
				end
			end

			if not storageKey and (dragonType == "East" or dragonType == "West") then
				return ImageUtil.getImageForTool(`Dragon ({dragonType})-Dragon ({dragonType})`, v5, nil)
			end

			if not storageKey then
				local itemId = instance:GetAttribute("ItemId")

				if type(itemId) == "number" then
					local v6 = spriteToIcon(getIconSpriteFromItemId(itemId))
					local v7 = spriteToIcon(getOutlineSpriteFromItemId(itemId), Color3.new())
					return imageInputToImage(iconToImageInput(v6, v7))
				end
			end
		end
	end

	local name = instance.Name

	if instance:GetAttribute("IsAprilFoolsFruit") then
		name = `Plastic {instance.Name}`
	elseif dragonType then
		name = `Dragon ({dragonType})-Dragon ({dragonType})`
	end

	return ImageUtil.getImageForTool(name, v5, storageKey)
end

function ImageUtil.getImageForTool(value: string, p: string, value2)
	if p == "Fruit" then
		local v5 = value:gsub(" Fruit", "")
		local nullable = ItemId.getId(v5, "PhysicalMoveset"):asNullable()

		if nullable then
			local unwrapped = ItemConfig.match(nullable):unwrap()
			local v6 = spriteToIcon(unwrapped.Display.Sprite, Color3.fromRGB(255, 255, 255))
			return imageInputToImage(iconToImageInput(v6))
		end
	elseif p == "Item" then
		local storageKey = value:gsub("'", "")
		local nullable = ItemId.getId(storageKey, "Moveset"):asNullable()

		if nullable then
			local unwrapped = ItemConfig.match(nullable):unwrap()

			if not value2 then
				return imageInputToImage(iconToImageInput(spriteToIcon(
					unwrapped.Display.Sprite,
					Color3.fromRGB(255, 255, 255)
				)))
			end

			if type(value2) ~= "number" then
				value2 = ItemId.getId(value2, "Skin"):asNullable()
			end

			if not value2 then
				return imageInputToImage(iconToImageInput(spriteToIcon(
					unwrapped.Display.Sprite,
					Color3.fromRGB(255, 255, 255)
				)))
			end

			local unwrapped2 = ItemConfig.match(value2):unwrap()
			local v6 = spriteToIcon(
				unwrapped2.Skin and unwrapped2.Skin.EquippedAdorneeSprite or unwrapped2.Display.Sprite or unwrapped.Display.Sprite,
				Color3.fromRGB(255, 255, 255)
			)
			return imageInputToImage(iconToImageInput(v6))
		else
			local nullable2 = ItemConfig.Query.selectFirst({
				Index = {
					StorageKey = storageKey,
					IdType = {
						Operation = "OR",
						Values = {
							"Fish",
							"Redeemable",
							"Rod",
							"Tool",
							"Potion",
							"Accessory",
							"Consumable",
							"Ability"
						}
					}
				}
			}):asNullable()

			if nullable2 then
				return imageInputToImage(iconToImageInput(spriteToIcon(
					nullable2.Display.Sprite,
					Color3.fromRGB(255, 255, 255)
				)))
			end
		end
	end

	return nil
end

function ImageUtil.applySpriteFromItemId(p, p2, p3, flag: boolean?)
	local imageFromItemId = ImageUtil.getImageFromItemId(p, p2)

	if imageFromItemId then
		ImageUtil.applySprite(imageFromItemId, p3, flag)
	else
		ImageUtil.applySprite(nil, p3, flag)
	end
end

function ImageUtil.applySprite(value, value2, flag: boolean?)
	local icon = nil
	local iconOutline = nil

	if typeof(value2) == "Instance" then
		icon = value2:FindFirstChild("Icon")
		iconOutline = value2:FindFirstChild("IconOutline")
	elseif typeof(value2) == "table" then
		icon = value2.Icon
		iconOutline = value2.IconOutline
	end

	if icon then
		local v5 = v4

		if value ~= nil then
			if typeof(value) == "string" or typeof(value) == "number" then
				v5 = ImageUtil.getAssetSprite(value)
			elseif typeof(value) == "table" then
				v5 = value
			end
		end

		local icon2 = flag and v5.Hidden.Icon or v5.Icon
		icon.Image = icon2.Image
		icon.ImageColor3 = icon2.ImageColor3 or Color3.fromRGB(255, 255, 255)
		icon.ImageTransparency = icon2.ImageTransparency or 0
		icon.ImageRectOffset = icon2.ImageRectOffset or Vector2.zero
		icon.ImageRectSize = icon2.ImageRectSize or Vector2.zero

		if iconOutline then
			local outline = flag and v5.Hidden.Outline or v5.Outline

			if not outline then
				iconOutline.Visible = false
				return
			end

			iconOutline.Image = outline.Image
			iconOutline.ImageColor3 = outline.ImageColor3 or Color3.fromRGB(0, 0, 0)
			iconOutline.ImageTransparency = outline.ImageTransparency or 0.7
			iconOutline.ImageRectOffset = outline.ImageRectOffset or Vector2.zero
			iconOutline.ImageRectSize = outline.ImageRectSize or Vector2.zero
			iconOutline.Visible = true
		end
	elseif iconOutline then
		iconOutline.Visible = false
	end
end

local v5 = {}

function ImageUtil.getAssetSprite(value)
	local flag = false
	local v6

	if value then
		v6 = tostring(value)

		if typeof(value) == "number" then
			flag = true
		end
	else
		v6 = nil
	end

	local function format(data)
		local clone = table.clone(data.Icon)
		clone.ImageColor3 = Color3.fromRGB(0, 0, 0)

		if not data.Loaded then
			local v7 = v6 or "_unknown"

			if not v5[v7] then
				warn((`No image for "{v7}"`))
			end

			v5[v7] = true
		end

		return {
			Loaded = data.Loaded,
			Icon = data.Icon,
			Outline = data.Outline,
			Hidden = {
				Icon = clone,
				Outline = data.Outline
			}
		}
	end

	if v6 then
		local id = ItemId.getId(v6, "Redeemable")

		if id:isOk() then
			local unwrapped = ItemConfig.match(id:unwrap()):unwrap()
			local v7 = {
				Loaded = true,
				Icon = spriteToIcon(unwrapped.Display.Sprite, Color3.fromRGB(255, 255, 255)),
				Outline = spriteToIcon(unwrapped.Display.OutlineSprite, Color3.fromRGB(0, 0, 0))
			}

			if v7.Icon ~= nil then
				v[v6] = format(v7)
			end
		end
	end

	if v6 and v3[v6] then
		v6 = v3[v6]()
	end

	if not v6 or v[v6] then
		return v[v6 or "_unknown"] or v4
	end

	if flag then
		v[v6] = format({
			Loaded = true,
			Icon = {
				Image = `rbxassetid://{value}`,
				ImageRectOffset = Vector2.new(0, 0),
				ImageRectSize = Vector2.new(0, 0),
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ImageTransparency = 0
			},
			Outline = nil
		})
	else
		local image = nil
		local image2 = nil
		local formatted = `{v6}.png`
		local v9 = v6:gsub("'", ""):gsub(":", "") .. "1.png"
		local v10 = v6:gsub("'", ""):gsub(":", "") .. "2.png"
		local formatted2 = `{v6}1.png`
		local v11 = true
		v2 = v2 or require(game.ReplicatedStorage.FruitSpritesheets)

		for k, v12 in pairs(v2) do
			if not v11 then
				break
			end

			assert(v12, "bad Sprites")

			for k2, v14 in pairs(v12) do
				assert(v14, "bad spriteBounds")

				if k2 == v9 or k2 == formatted2 then
					image = { k, v14 }
				elseif k2 == v10 then
					image2 = { k, v14 }
				elseif k2 == v6 or k2 == formatted then
					v11 = false
					image = { k, v14 }
					break
				end

				if not (image and image2) then
					continue
				end

				v11 = false
				break
			end
		end

		if not image then
			local v12, v13 = ChromaticSprites.Try(v6)

			if v12 then
				return v12, v13
			end
		end

		if image then
			if typeof(image) == "string" and #image > 0 then
				local outline = image2 and typeof(image2) == "string" and {
					Image = image2,
					ImageRectOffset = Vector2.new(0, 0),
					ImageRectSize = Vector2.new(0, 0),
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = 0
				} or nil
				v[v6] = format({
					Loaded = true,
					Icon = {
						Image = image,
						ImageRectOffset = Vector2.new(0, 0),
						ImageRectSize = Vector2.new(0, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						ImageTransparency = 0
					},
					Outline = outline
				})
			elseif typeof(image) == "table" then
				v[v6] = format({
					Loaded = true,
					Icon = {
						Image = image[1],
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						ImageTransparency = 0,
						ImageRectOffset = Vector2.new(
							image[2][1] / (image[2][3] and 1 or 2),
							image[2][2] / (image[2][3] and 1 or 2)
						),
						ImageRectSize = Vector2.new(image[2][3] or 150, image[2][4] or 150)
					},
					Outline = image2 and #image2 > 0 and {
						Image = image2[1],
						ImageColor3 = Color3.fromRGB(0, 0, 0),
						ImageTransparency = 0,
						ImageRectOffset = Vector2.new(
							image2[2][1] / (image2[2][3] and 1 or 2),
							image2[2][2] / (image2[2][3] and 1 or 2)
						),
						ImageRectSize = Vector2.new(image2[2][3] or 150, image2[2][4] or 150)
					} or nil
				})
			end
		else
			v[v6] = format({
				Loaded = false,
				Icon = {
					Image = "rbxasset://textures/ui/PlayerList/Block@3x.png",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = 0.7,
					ImageRectOffset = Vector2.new(0, 0),
					ImageRectSize = Vector2.new(0, 0)
				}
			})
		end
	end

	return v[v6 or "_unknown"] or v4
end

return ImageUtil