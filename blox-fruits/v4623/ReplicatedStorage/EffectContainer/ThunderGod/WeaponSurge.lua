local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local color = Color3.fromRGB(64, 230, 255)
local v = {
	"Lightning",
	"Lightning0",
	"Lightning5",
	"Sparks3",
	"Glow"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function electricSource()
	local effectContainer = ReplicatedStorage:FindFirstChild("EffectContainer")
	local hit = effectContainer and effectContainer:FindFirstChild("Hit")
	local combat = hit and hit:FindFirstChild("Combat")
	return combat and combat:FindFirstChild("Electric")
end

return function(data)
	local marker = data.Marker

	if typeof(marker) ~= "Instance" or not marker:IsA("Attachment") or (marker.WorldPosition - workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
		return
	end

	local v2 = electricSource() -- equivalent call inferred; original call site unknown

	if not v2 then
		warn("ThunderGod.WeaponSurge: EffectContainer.Hit.Combat.Electric missing")
		return
	end

	local duration = data.Duration or 2
	local color2

	if typeof(data.Color) == "Color3" then
		color2 = data.Color
	else
		color2 = color
	end

	local clones = {}

	for _, childName in v do
		local emitter = v2:FindFirstChild(childName)

		if not (emitter and emitter:IsA("ParticleEmitter")) then
			continue
		end

		local clone = emitter:Clone()
		clone.Color = ColorSequence.new(color2)
		clone.Enabled = true
		clone.Parent = marker
		table.insert(clones, clone)
	end

	task.delay(duration, function()
		local v3 = 0

		for _, v4 in clones do
			if not v4.Parent then
				continue
			end

			v4.Enabled = false
			v3 = math.max(v3, v4.Lifetime.Max)
		end

		for _, v4 in clones do
			Util.Debris:AddItem(v4, v3 + 0.2)
		end
	end)
end