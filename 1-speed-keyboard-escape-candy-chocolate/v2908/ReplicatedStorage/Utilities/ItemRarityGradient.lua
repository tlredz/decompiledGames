local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))

-- equivalent calls inferred from this helper; original call sites unknown
local function clearTags(instance)
	CollectionService:RemoveTag(instance, "UIGradientRainbow")
	CollectionService:RemoveTag(instance, "UIGradientSecret")
	CollectionService:RemoveTag(instance, "UIGradientExotic")
	CollectionService:RemoveTag(instance, "UIGradientUnreal")
end

local function clearAnimationTags(instance)
	for _, uIGradient in ipairs(instance:GetChildren()) do
		if not uIGradient:IsA("UIGradient") then
			continue
		end

		clearTags(uIGradient) -- equivalent call inferred; original call site unknown
	end
end

local function ensureGradientForAnimation(parent)
	local selected = parent:FindFirstChild("UIGradient")

	for _, uIGradient in ipairs(parent:GetChildren()) do
		if not uIGradient:IsA("UIGradient") then
			continue
		end

		if selected then
			if uIGradient ~= selected then
				clearTags(uIGradient) -- equivalent call inferred; original call site unknown
				uIGradient:Destroy()
			end
		else
			uIGradient.Name = "UIGradient"
			selected = uIGradient
		end
	end

	if not selected then
		selected = Instance.new("UIGradient")
		selected.Name = "UIGradient"
		selected.Parent = parent
	end

	clearTags(selected) -- equivalent call inferred; original call site unknown
	return selected
end

local ItemRarityGradient = {}
ItemRarityGradient.TAG_RAINBOW = "UIGradientRainbow"
ItemRarityGradient.TAG_SECRET = "UIGradientSecret"
ItemRarityGradient.TAG_EXOTIC = "UIGradientExotic"
ItemRarityGradient.TAG_UNREAL = "UIGradientUnreal"

function ItemRarityGradient:apply(p2, p3, p4)
	if p2 == "Mythic" then
		local gradientForAnimation = ensureGradientForAnimation(self)
		self.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		gradientForAnimation.Enabled = true
		CollectionService:AddTag(gradientForAnimation, "UIGradientRainbow")
	elseif p2 == "Secret" then
		local gradientForAnimation = ensureGradientForAnimation(self)
		self.BackgroundColor3 = p3 or Color3.fromRGB(40, 40, 40)
		gradientForAnimation.Enabled = true
		CollectionService:AddTag(gradientForAnimation, "UIGradientSecret")
	elseif p2 == "Exotic" then
		local gradientForAnimation = ensureGradientForAnimation(self)
		self.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		gradientForAnimation.Enabled = true
		CollectionService:AddTag(gradientForAnimation, "UIGradientExotic")
	elseif p2 == "Unreal" then
		local gradientForAnimation = ensureGradientForAnimation(self)
		self.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		gradientForAnimation.Enabled = true
		CollectionService:AddTag(gradientForAnimation, "UIGradientUnreal")
	else
		clearAnimationTags(self)
		local backgroundColor = not p4 and (p3 or Items.RARITY_COLORS[p2])

		if backgroundColor then
			self.BackgroundColor3 = backgroundColor
		end
	end
end

function ItemRarityGradient.clear(p)
	clearAnimationTags(p)
end

return ItemRarityGradient