local module = require("@game/ReplicatedStorage/Omni")
local viscoClient = module.Libs.ViscoClient
local localPlayer = module.Services.Players.LocalPlayer
local topBarPlus = module.Libs.TopBarPlus.new()
local flag = false

local function RefreshSelection()
	if topBarPlus.isDestroyed or topBarPlus.isSelected == flag then
		return
	end

	if flag then
		topBarPlus:select("Commands")
	else
		topBarPlus:deselect("Commands")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshVisibility()
	if topBarPlus.isDestroyed then
		return
	end

	topBarPlus:setEnabled(localPlayer:GetAttribute("VISCO_USER") == true)
end

topBarPlus:setEnabled(false)
topBarPlus:setName("Commands")
topBarPlus:setLabel(">_")
topBarPlus:align("Left")
topBarPlus:setOrder(10)
topBarPlus:autoDeselect(false)
topBarPlus:modifyTheme({
	{
		"IconButton",
		"BackgroundColor3",
		Color3.fromRGB(27, 80, 255),
		"Deselected"
	},
	{
		"IconButton",
		"BackgroundColor3",
		Color3.fromRGB(27, 80, 255),
		"Selected"
	},
	{ "IconButton", "BackgroundTransparency", 0.08 },
	{ "IconSpot", "BackgroundTransparency", 1 },
	{ "IconSpotGradient", "Enabled", false },
	{
		"IconLabel",
		"TextColor3",
		Color3.fromRGB(225, 235, 245),
		"Deselected"
	},
	{
		"IconLabel",
		"TextColor3",
		Color3.fromRGB(255, 255, 255),
		"Selected"
	}
})
topBarPlus:bindEvent("toggled", function(_, p, p2)
	if p2 == "Commands" then
		return
	end

	viscoClient:SetUIEnabled(p)
	task.defer(RefreshSelection)
end)
viscoClient:BindTo(Enum.KeyCode.F2)
viscoClient:OnUIOpened(function()
	flag = true
	task.defer(RefreshSelection)
	module.Frame:AddUIHider("Commands")
end)
viscoClient:OnUIClosed(function()
	flag = false
	task.defer(RefreshSelection)
	module.Frame:RemoveUIHider("Commands")
end)
topBarPlus:addToJanitor(localPlayer:GetAttributeChangedSignal("VISCO_USER"):Connect(RefreshVisibility))
RefreshVisibility() -- equivalent call inferred; original call site unknown
return {}