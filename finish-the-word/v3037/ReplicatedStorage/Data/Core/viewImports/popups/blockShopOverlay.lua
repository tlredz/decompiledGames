local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("iterUtil")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local menu = import4:get("menu")
local ux = import4:get("ux")
local blocksPage = import4:get("blocksPage").BlocksPage
local v = { "Blocks", "Skins" }
local v2 = {
	Blocks = blocksPage,
	Skins = import4:get("skinsPage").SkinsPage
}
local model = import.model(menu.Button, basic.ConstrainedElement)

function model.init(p)
	return {
		AspectRatio = 3.25,
		Size = UDim2.new(0.4, 0, 0.7, 0),
		Text = p.Label,
		MouseButton1Down = function(p2)
			p2.Ui:setTab(p.Label)
		end
	}
end

local model2 = import.model(basic.ImageButton, ux.Button, basic.Stroke, basic.Corner)

function model2.init()
	return {
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(190, 40, 40),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0.01, 0, 0.9825, 0),
		Size = UDim2.new(0.1, 0, 0.1, 0),
		CornerRadius = UDim.new(0.25, 0),
		AspectRatio = 2,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		StrokeWidth = 0.05,
		MouseButton1Down = function()
			import2.fire("closeShop")
		end
	}, {
		CloseLabel = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Text = "Exit",
			StrokeWidth = 3
		})
	}
end

local model3 = import.model(basic.EmptyList)

function model3.init()
	return {
		Position = UDim2.new(0.5, 0, 0.01, 0),
		Size = UDim2.new(0.3, 0, 0.09, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Padding = UDim.new(0.06, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}, import3.toDict(v, function(p, label)
		return p, import.make(model, {
			Label = label
		})
	end)
end

local model4 = import.model("ScreenGui", basic.Ui)

function model4.init()
	return {
		Name = "BlocksShop",
		IgnoreGuiInset = true,
		DisplayOrder = 3,
		ResetOnSpawn = false,
		CurrentTab = "Blocks"
	}, {
		TabsList = import.make(model3),
		CloseButton = import.make(model2),
		ActivePage = import.make(blocksPage)
	}
end

function model4:setTab(currentTab)
	if self.CurrentTab == currentTab then
		return
	end

	self.CurrentTab = currentTab
	local activePage = self.ActivePage

	if activePage then
		local v3 = rawget(activePage._Model, "despawn")

		if v3 then
			v3(activePage)
		end

		rawset(activePage, "despawn", true)
		activePage.Instance:Destroy()
	end

	local v3 = v2[currentTab]

	if not v3 then
		return
	end

	import.apply(self, nil, {
		ActivePage = import.make(v3)
	})
end

return {
	BlockShopOverlay = model4
}