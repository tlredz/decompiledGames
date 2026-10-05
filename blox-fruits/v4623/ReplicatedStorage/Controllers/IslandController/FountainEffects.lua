local ContentProvider = game:GetService("ContentProvider")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = {
	GiantFountain = true,
	WaterfallEffects = true
}
local object = setmetatable({}, {
	__mode = "k"
})
local v2 = false
local flag = false
local v3 = false
local FountainEffects = {
	LoadForLocations = { "Fountain City" },
	Maid = Maid.new()
}

local function isFountainEffect(effect, p)
	if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Texture") or effect:IsA("Decal")) then
		return false
	end

	local parent = effect.Parent

	while parent and parent ~= p do
		if parent:IsA("Model") and v[parent.Name] then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function track(effect, fountain)
	if not (isFountainEffect(effect, fountain) and object[effect] == nil) then
		return
	end

	if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
		if not effect.Enabled then
			return
		end

		object[effect] = true

		if not v2 then
			effect.Enabled = false

			if effect:IsA("ParticleEmitter") then
				effect:Clear()
			end
		end
	else
		if effect.Transparency >= 1 then
			return
		end

		object[effect] = effect.Transparency

		if not v2 then
			effect.Transparency = 1
		end
	end
end

local function setActive(enabled: boolean)
	v2 = enabled

	for effect, v4 in object do
		if effect.Parent == nil then
			object[effect] = nil
		elseif effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = enabled

			if not enabled and effect:IsA("ParticleEmitter") then
				effect:Clear()
			end
		else
			effect.Transparency = not enabled and 1 or v4
		end
	end
end

function FountainEffects.RegionEntered(p)
	flag = true
	p.Maid:GiveTask(task.spawn(function()
		local fountain = workspace:WaitForChild("Map"):WaitForChild("Fountain", 30)

		if not fountain then
			return
		end

		setActive(false)

		for _, descendant in fountain:GetDescendants() do
			track(descendant, fountain)
		end

		p.Maid:GiveTask(fountain.DescendantAdded:Connect(function(descendant)
			track(descendant, fountain)
		end))

		if not v3 then
			local v4 = {}

			for k in object do
				table.insert(v4, k)
			end

			if #v4 > 0 then
				v3 = true
				pcall(ContentProvider.PreloadAsync, ContentProvider, v4)
			end
		end

		if flag then
			setActive(true)
		end
	end))
end

function FountainEffects.RegionLeaving(_)
	flag = false
	setActive(false)
end

return FountainEffects