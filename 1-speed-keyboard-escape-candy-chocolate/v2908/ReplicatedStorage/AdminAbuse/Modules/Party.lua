local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local Spotlight = require(ReplicatedStorage.Utilities.Events.Spotlight)
local v = Spotlight.new({
	colorSpeed = 0.12,
	cameraOffset = CFrame.new(0, 20, -50),
	range = 30,
	speed = 1.5,
	ccSpeed = 0.06
})
local v2 = PartyEvent.new({
	MaxDurationSeconds = 1200,
	DefaultDurationSeconds = 600,
	NeedsDuration = true,
	RequiresRespawnRefire = true,
	SkipDoorTransition = true,
	IsAdminAbuse = false,
	Sounds = {
		"rbxassetid://140074993424765",
		"rbxassetid://5410080857",
		"rbxassetid://127447678350704",
		"rbxassetid://7024280102",
		"rbxassetid://7024245182"
	}
})

function v2.OnStart(_, state, _, _, p)
	local cc = state.janitor:Add(Instance.new("ColorCorrectionEffect"))
	cc.Name = "ConcertColorCorrection"
	cc.Brightness = 0.05
	cc.Contrast = 0.25
	cc.Saturation = 0.35
	cc.TintColor = Color3.fromRGB(255, 255, 255)
	cc.Parent = Lighting
	state._cc = cc
	v:setup(state, p, state.janitor)
	state._particles = {}
	local _spotlight = state._spotlight

	if _spotlight and _spotlight.model then
		local pivot = _spotlight.model:GetPivot()

		for _, part in _spotlight.model:GetDescendants() do
			if part:IsA("BasePart") and part.Name == "Particle" then
				table.insert(state._particles, {
					part = part,
					partOffset = pivot:ToObjectSpace(part.CFrame)
				})
			end
		end
	end
end

function v2.OnRender(_, p, p2, _, p3, p4)
	v:update(p, p2, p4)
	local cframe = CFrame.new(p3.Position)

	for _, _particle in p._particles do
		_particle.part.CFrame = cframe * _particle.partOffset
	end
end

return v2