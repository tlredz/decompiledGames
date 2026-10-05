local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Achievements = require(ReplicatedStorage.SharedData.Achievements)
local Titles = require(ReplicatedStorage.SharedData.Titles)
local Stickers = require(ReplicatedStorage.SharedData.Stickers)
local ProfileStats = require(ReplicatedStorage.SharedData.ProfileStats)
local ProfileBackgrounds = require(ReplicatedStorage.SharedData.ProfileBackgrounds)
local ProfileFrames = require(ReplicatedStorage.SharedData.ProfileFrames)
local ProfileBackdrops = require(ReplicatedStorage.SharedData.ProfileBackdrops)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local Describe = {
	Types = table.freeze({
		Toon = "Toon",
		Twisted = "Twisted",
		Trinket = "Trinket",
		Sticker = "Sticker",
		Medal = "Medal",
		Title = "Title",
		Stat = "Stat",
		Background = "Background",
		Frame = "Frame",
		Backdrop = "Backdrop"
	})
}
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function warnOnce(p: string, p2: string)
	if v[p] then
		return
	end

	v[p] = true
	warn(p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blank(p: string, p2: string)
	return {
		Type = p,
		Id = p2,
		Missing = true,
		Name = p2,
		Image = "",
		Icon = "",
		Attributes = {}
	}
end

local function requireTower(p: string)
	local tower = TowerLUT:GetTower(p)

	if not (tower and tower:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, tower)

	if success and type(result) == "table" then
		return result
	end

	return nil
end

local function requireTrinket(childName: string)
	local trinketData = ReplicatedStorage:FindFirstChild("TrinketData")
	local moduleScript = trinketData and trinketData:FindFirstChild(childName)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if success and type(result) == "table" then
		return result
	end

	return nil
end

local function portrait(p)
	return p.Render or p.Icon or ""
end

local v2 = {
	[Describe.Types.Toon] = function(id: string)
		local tower = TowerLUT:GetTower(id)
		local result

		if tower and tower:IsA("ModuleScript") then
			local success
			success, result = pcall(require, tower)

			if not success or type(result) ~= "table" then
				result = nil
			end
		end

		if result then
			return {
				Type = Describe.Types.Toon,
				Id = id,
				Missing = false,
				Name = result.Name or id,
				Image = result.Render or result.Icon or "",
				Icon = result.Icon or "",
				Description = result.Description,
				Rarity = result.Rarity,
				Attributes = {
					MainCharacter = result.MainCharacter,
					Lethal = result.Lethal,
					HolidayTower = result.HolidayTower,
					Easter = result.Easter,
					Halloween = result.Halloween
				}
			}
		end

		return nil
	end,
	[Describe.Types.Twisted] = function(id: string)
		local monster = TowerLUT:GetMonster(id)

		if monster then
			return {
				Type = Describe.Types.Twisted,
				Id = id,
				Missing = false,
				Name = monster.Name or id,
				Image = monster.Render or monster.Icon or "",
				Icon = monster.Icon or "",
				Description = monster.Description,
				Rarity = monster.Rarity,
				Attributes = {
					Trinket = monster.Trinket
				}
			}
		end

		return nil
	end,
	[Describe.Types.Trinket] = function(id: string)
		local v3 = requireTrinket(id)

		if v3 then
			return {
				Type = Describe.Types.Trinket,
				Id = id,
				Missing = false,
				Name = v3.Name or id,
				Image = v3.Icon or "",
				Icon = v3.Icon or "",
				Description = v3.Description,
				Rarity = v3.Rarity,
				Attributes = {
					TrinketType = v3.TrinketType
				}
			}
		end

		return nil
	end,
	[Describe.Types.Sticker] = function(id: string)
		local sticker = Stickers[id]

		if type(sticker) ~= "table" then
			return nil
		end

		local displayImage = sticker.DisplayImage

		if not displayImage or displayImage == "" then
			displayImage = sticker.Image or ""
		end

		local spriteSheet = sticker.SpriteSheet
		local animated = type(spriteSheet) == "table" and sticker.Image and sticker.Image ~= "" and {
			Image = sticker.Image,
			frameRate = spriteSheet.frameRate or 10,
			sequence = spriteSheet.sequence
		} or nil
		local v4 = {
			Type = Describe.Types.Sticker,
			Id = id,
			Missing = false,
			Name = sticker.DisplayName or id,
			Image = displayImage,
			Icon = displayImage,
			Description = 0,
			Rarity = 0,
			Animated = 0,
			Attributes = 0
		}
		local description

		if sticker.Text ~= "" then
			description = sticker.Text or nil
		end

		v4.Description = description
		v4.Rarity = sticker.Rarity
		v4.Animated = animated
		v4.Attributes = {
			Tags = type(sticker.Tags) ~= "table" and "" or table.concat(sticker.Tags, "|") or "",
			Text = sticker.Text
		}
		return v4
	end,
	[Describe.Types.Medal] = function(id: string, p2)
		local standard = Achievements.All and Achievements.All.Standard
		local v3 = standard and standard[id]

		if type(v3) ~= "table" then
			return nil
		end

		local requirement = type(v3.Requirement) ~= "number" and 0 or v3.Requirement or 0
		local progress

		if p2 and type(p2.progress) == "number" then
			progress = math.clamp(p2.progress, 0, 100)
		end

		return {
			Type = Describe.Types.Medal,
			Id = id,
			Missing = false,
			Name = v3.Name or id,
			Image = v3.Icon or "",
			Icon = v3.Icon or "",
			Description = v3.Description,
			Gradient = v3.Difficulty,
			Progress = progress,
			Attributes = {
				NumericIndex = v3.NumericIndex,
				Category = v3.Category,
				Requirement = requirement
			}
		}
	end,
	[Describe.Types.Title] = function(id: string)
		local title = Titles[id]

		if type(title) ~= "table" then
			return nil
		end

		local icon = title.Icon or title.Image or ""
		return {
			Type = Describe.Types.Title,
			Id = id,
			Missing = false,
			Name = title.DisplayName or id,
			Image = icon,
			Icon = icon,
			Description = title.Description,
			Gradient = title.UIGradient,
			Attributes = {
				LinkedAchievementID = title.LinkedAchievementID
			}
		}
	end,
	[Describe.Types.Stat] = function(id: string, p2)
		local v3 = ProfileStats.Get(id)

		if not v3 then
			return nil
		end

		local value = p2 and p2.value
		local v4 = type(value) ~= "number" and 0 or value
		return {
			Type = Describe.Types.Stat,
			Id = id,
			Missing = false,
			Name = v3.DisplayName,
			Image = "",
			Icon = "",
			Value = ProfileStats.Format(id, v4),
			Attributes = {
				StatFormat = v3.Format
			}
		}
	end,
	[Describe.Types.Background] = function(id: string)
		local v3 = ProfileBackgrounds.Get(id)

		if v3 then
			return {
				Type = Describe.Types.Background,
				Id = id,
				Missing = false,
				Name = v3.DisplayName,
				Image = v3.Image,
				Icon = v3.Image,
				Color = v3.Color,
				Attributes = {}
			}
		end

		return nil
	end,
	[Describe.Types.Frame] = function(id: string)
		if id == ProfileFrames.NoneKey then
			return {
				Type = Describe.Types.Frame,
				Id = id,
				Missing = false,
				Name = "None",
				Image = "",
				Icon = "",
				Attributes = {}
			}
		end

		local v3 = ProfileFrames.Get(id)

		if v3 then
			return {
				Type = Describe.Types.Frame,
				Id = id,
				Missing = false,
				Name = v3.DisplayName,
				Image = v3.Image,
				Icon = v3.Image,
				Color = v3.Color,
				Attributes = {}
			}
		end

		return nil
	end,
	[Describe.Types.Backdrop] = function(id: string)
		local v3 = ProfileBackdrops.Get(id)

		if not v3 then
			return nil
		end

		local previewImage = ProfileBackdrops.PreviewImage(id)
		return {
			Type = Describe.Types.Backdrop,
			Id = id,
			Missing = false,
			Name = v3.DisplayName,
			Image = previewImage,
			Icon = previewImage,
			Attributes = {}
		}
	end
}

function Describe.Get(value: string, value2: string, p)
	if type(value) == "string" then
		if type(value2) ~= "string" or value2 == "" then
			return blank(value, tostring(value2))
		end

		local v3 = v2[value]

		if v3 then
			local success, result = pcall(v3, value2, p)

			if success then
				if type(result) == "table" then
					return result
				end

				return blank(value, value2)
			else
				warnOnce("resolver:" .. value, "[UITemplates] " .. value .. " resolver errored: " .. tostring(result)) -- equivalent call inferred; original call site unknown
				return blank(value, value2)
			end
		else
			warnOnce("type:" .. value, "[UITemplates] no resolver for type " .. value) -- equivalent call inferred; original call site unknown
			return blank(value, value2)
		end
	else
		warnOnce(
			"type:" .. tostring(value),
			"[UITemplates] Describe called with a non-string type: " .. tostring(value)
		) -- equivalent call inferred; original call site unknown
		return blank(tostring(value), tostring(value2))
	end
end

return Describe