local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local weapons = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Weapons")
local KnifePerks = require(weapons:WaitForChild("KnifePerks"))
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquippedKnifeBonuses"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 12
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Bonuses"
textLabel.AnchorPoint = Vector2.new(1, 1)
textLabel.Position = UDim2.new(1, -18, 1, -16)
textLabel.Size = UDim2.fromOffset(330, 38)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.GothamMedium
textLabel.TextSize = 11
textLabel.TextColor3 = Color3.fromRGB(235, 201, 137)
textLabel.TextXAlignment = Enum.TextXAlignment.Right
textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
textLabel.TextStrokeTransparency = 0.55
textLabel.TextWrapped = true
textLabel.Parent = screenGui

local function render()
	local equippedKnife = localPlayer:GetAttribute("EquippedKnife")
	local v = KnifePerks.forSkin(equippedKnife)
	textLabel.Visible = v.Key ~= "None"
	textLabel.Text = string.format(
		"%s KNIFE  ·  +%.2f SPEED\nITEM / ABILITY / DODGE COOLDOWNS −%.2fs",
		string.upper(v.Key),
		v.SpeedBonus,
		v.CooldownReduction
	)
	textLabel.TextColor3 = v.Key == "Legendary" and Color3.fromRGB(235, 201, 137) or Color3.fromRGB(184, 157, 241)
	textLabel.Size = UDim2.fromOffset(math.max(160, (math.min(330, screenGui.AbsoluteSize.X - 36))), 38)
end

localPlayer:GetAttributeChangedSignal("EquippedKnife"):Connect(render)
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)
render()
script.Destroying:Connect(function()
	screenGui:Destroy()
end)