game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassUtil = require(ReplicatedStorage.Modules.GamepassUtil)
local Color = require(ReplicatedStorage.Modules.Color)
local UI = require(ReplicatedStorage.Modules.UI)
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local v = {
	{
		Attribute = "ExtraSlots",
		Color = ColorSequence.new(Color3.fromHex("#aeff63"), Color3.fromHex("#61ff3d"))
	},
	{
		Attribute = "ExtraSlots2",
		Color = ColorSequence.new(Color3.fromRGB(255, 242, 55), Color3.fromRGB(255, 182, 57))
	},
	{
		Attribute = "ExtraSlots3",
		Color = ColorSequence.new(Color3.fromRGB(105, 255, 238), Color3.fromRGB(57, 202, 255))
	}
}
UI:AddShadowOnHover(parent)
UI:Bind(parent)

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentGamepassSlot()
	for _, v2 in v do
		if not localPlayer:GetAttribute(v2.Attribute) then
			return v2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateBackgroundBasedOnAttributes()
	local currentGamepassSlot = getCurrentGamepassSlot() -- equivalent call inferred; original call site unknown

	if not currentGamepassSlot then
		parent.Visible = false
		return
	end

	parent.Visible = true
	parent.UIGradient.Color = currentGamepassSlot.Color
	parent.UIStroke.Color = Color:GetShadedColor(currentGamepassSlot.Color.Keypoints[1].Value, 0.7)
end

updateBackgroundBasedOnAttributes() -- equivalent call inferred; original call site unknown
parent.MouseButton1Click:Connect(function()
	local currentGamepassSlot = getCurrentGamepassSlot() -- equivalent call inferred; original call site unknown

	if currentGamepassSlot then
		GamepassUtil:DisplayGamepassInfo(currentGamepassSlot.Attribute)
	end
end)

for _, v2 in v do
	localPlayer:GetAttributeChangedSignal(v2.Attribute):Connect(function()
		local currentGamepassSlot = getCurrentGamepassSlot() -- equivalent call inferred; original call site unknown

		if not currentGamepassSlot then
			parent.Visible = false
			return
		end

		parent.Visible = true
		parent.UIGradient.Color = currentGamepassSlot.Color
		parent.UIStroke.Color = Color:GetShadedColor(currentGamepassSlot.Color.Keypoints[1].Value, 0.7)
	end)
end