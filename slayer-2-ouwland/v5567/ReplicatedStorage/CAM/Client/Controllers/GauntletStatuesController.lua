local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local v = {
	Weapon = Color3.fromRGB(80, 255, 110),
	Power = Color3.fromRGB(190, 90, 255),
	Fighting = Color3.fromRGB(255, 60, 60)
}
local ratiosByType = {}
local colorsByEyes = {}
local v2 = {}

local function show(instance)
	local type = instance:GetAttribute("type")
	local v3 = ratiosByType[type]
	local eyes = instance:FindFirstChild("Eyes")

	if v3 == nil or eyes == nil or not eyes:IsA("BasePart") then
		return
	end

	if colorsByEyes[eyes] == nil then
		colorsByEyes[eyes] = eyes.Color
	end

	TweenService:Create(eyes, TweenInfo.new(0.4), {
		Color = colorsByEyes[eyes]:Lerp(v[type], v3)
	}):Play()

	if v3 >= 1 then
		eyes.Material = Enum.Material.Neon
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function track(instance)
	if v2[instance] then
		return
	end

	v2[instance] = true
	instance.ChildAdded:Connect(function(child)
		if child.Name == "Eyes" then
			show(instance)
		end
	end)
	show(instance)
end

for _, v3 in CollectionService:GetTagged("GauntletStatue") do
	if v2[v3] then
		continue
	end

	v2[v3] = true
	local v4 = v3
	v3.ChildAdded:Connect(function(child)
		if child.Name == "Eyes" then
			show(v4)
		end
	end)
	show(v3)
end

CollectionService:GetInstanceAddedSignal("GauntletStatue"):Connect(track)
CollectionService:GetInstanceRemovedSignal("GauntletStatue"):Connect(function(p)
	v2[p] = nil
end)
local GauntletStatuesController = {}

function GauntletStatuesController.handle(p)
	ratiosByType[p.Type] = p.Ratio

	for _, v3 in CollectionService:GetTagged("GauntletStatue") do
		if v3:GetAttribute("type") ~= p.Type then
			continue
		end

		track(v3) -- equivalent call inferred; original call site unknown
	end
end

function GauntletStatuesController.Done()
	for k in v do
		if (ratiosByType[k] or 0) < 1 then
			return false
		end
	end

	return true
end

return GauntletStatuesController