local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("itemModules")
local import3 = _G.import("configuration")
local import4 = _G.import("mathUtil")
local import5 = _G.import("viewImports")
local basic = import5:get("basic")
local react = import5:get("react")
local gradients = game.ReplicatedStorage:WaitForChild("ReplicatedAssets"):WaitForChild("Ui"):WaitForChild("Gradients")
local color = Color3.fromRGB(215, 215, 215)
local PET = import3.PET

local function getPetMeta(p)
	local v = import2:getItem("Pet", p) or {}
	return v.DisplayName or p, v.Rarity or "Common"
end

local function escapeRichText(p)
	return tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function fullText(p, p2)
	return string.format(
		"%s %s",
		tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"),
		escapeRichText(p2)
	)
end

local function nameLayerText(p, p2)
	return string.format(
		"<font transparency=\"1\">%s </font>%s",
		tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"),
		escapeRichText(p2)
	)
end

local function levelLayerText(p, p2)
	return string.format(
		"%s <font transparency=\"1\">%s</font>",
		tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"),
		escapeRichText(p2)
	)
end

local model = import.model(basic.TextLabel)

function model.init(data)
	return {
		Size = UDim2.new(1, 0, 1, 0),
		StrokeWidth = data.StrokeWidth,
		Text = data.Text,
		RichText = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = data.TextColor3 or color,
		Rarity = data.Rarity,
		ZIndex = data.ZIndex
	}
end

function model:prespawn()
	if not self.Rarity then
		return
	end

	local child = gradients:FindFirstChild(self.Rarity)

	if not child then
		return
	end

	self.TextColor3 = Color3.new(1, 1, 1)
	local clone = child:Clone()
	clone.Parent = self.Instance
end

local function makeNameChildren(displayName, rarity, XP)
	local v = math.clamp(XP or 0, 0, PET.PET_MAX_XP)
	local v2 = "Lvl " .. import4.xpToLevel(v, PET.PET_MAX_XP, PET.PET_LEVEL_GROWTH)
	return {
		StrokeLayer = import.make(model, {
			Text = string.format(
				"%s %s",
				tostring(v2):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"),
				escapeRichText(displayName)
			),
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 1,
			StrokeWidth = 2,
			ZIndex = 1
		}),
		LevelLayer = import.make(model, {
			Text = string.format(
				"%s <font transparency=\"1\">%s</font>",
				tostring(v2):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"),
				escapeRichText(displayName)
			),
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 2
		}),
		NameLayer = import.make(model, {
			Text = string.format(
				"<font transparency=\"1\">%s </font>%s",
				tostring(v2):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"),
				escapeRichText(displayName)
			),
			Rarity = rarity,
			ZIndex = 3
		})
	}
end

local model2 = import.model(basic.EmptyElement, react.Reactive)

function model2.init(p)
	local petId = p.PetId
	return {
		Size = UDim2.new(1, 0, 0.35, 0),
		LayoutOrder = 2,
		KeyChains = { "Inventory.Pet" },
		SavedChanged = function(p2, object)
			local id = object:findId("Inventory", "Pet", petId)
			local v = math.clamp(id and id.Config.XP or 0, 0, PET.PET_MAX_XP)
			local xpToLevel = import4.xpToLevel(v, PET.PET_MAX_XP, PET.PET_LEVEL_GROWTH)
			import4.xpToRatio(v, PET.PET_MAX_XP, PET.PET_LEVEL_GROWTH)
			local v2 = xpToLevel <= 1 and 0 or math.ceil(PET.PET_MAX_XP * ((xpToLevel - 1) / 99) ^ (1 / PET.PET_LEVEL_GROWTH))
			local v3 = math.max(
				(xpToLevel >= 100 and PET.PET_MAX_XP or math.ceil(PET.PET_MAX_XP * (xpToLevel / 99) ^ (1 / PET.PET_LEVEL_GROWTH))) - v2,
				1
			)
			local v4 = math.clamp(v - v2, 0, v3)
			p2.Track.Fill.Size = UDim2.new(v4 / v3, 0, 1, 0)
			p2.Track.XpText.Text = string.format("%d / %d", v4, v3)
		end
	}, {
		Track = import.make(import.wrap(basic.Stroke, basic.Corner), {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			CornerRadius = UDim.new(1, 0),
			Thickness = 2
		}, {
			Fill = import.make(import.wrap(basic.Corner, basic.Gradient), {
				BackgroundColor3 = Color3.new(1, 1, 1),
				CornerRadius = UDim.new(1, 0),
				GradientColor = ColorSequence.new(Color3.fromRGB(238, 223, 107), Color3.fromRGB(255, 85, 0)),
				GradientRotation = 90
			}),
			XpText = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.6, 0, 1, 0),
				StrokeWidth = 1,
				ZIndex = 2
			})
		})
	}
end

local model3 = import.model("BillboardGui", react.Reactive)

function model3.init(p)
	local petId = p.PetId
	local v = import2:getItem("Pet", petId) or {}
	local displayName = v.DisplayName or petId
	local rarity = v.Rarity or "Common"
	return {
		Name = "PetBillboard",
		AlwaysOnTop = true,
		MaxDistance = 18,
		Size = UDim2.new(5, 0, 1, 0),
		StudsOffset = createVector(0, 2, 0),
		KeyChains = { "Inventory.Pet" },
		SavedChanged = function(object, object2)
			local id = object2:findId("Inventory", "Pet", p.PetId)
			local XP = id and id.Config.XP or 0
			object:ClearReactiveChildren()
			return nil, (makeNameChildren(displayName, rarity, XP))
		end
	}
end

return {
	PetBillboard = model3,
	XpBar = model2,
	NameLabel = model
}