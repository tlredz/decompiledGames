local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
local FireworkTypeConfigs = {
	BY_TYPE = {
		Basic = {
			applyRecolor = true,
			explodeSoundName = nil,
			emitMode = "byName",
			emitByName = {
				FireworkBoom = 500,
				MainSparks = 500,
				Specs = 500
			},
			defaultEmitCount = 5
		},
		Bobcat = {
			applyRecolor = false,
			explodeSoundName = nil,
			emitMode = "byName",
			emitByName = {
				FireworkBoom = 500,
				MainSparks = 500,
				MortarSparks = 5,
				Specs = 100,
				Mortar = 1
			},
			defaultEmitCount = 1
		},
		Brookhaven = {
			applyRecolor = false,
			explodeSoundName = nil,
			emitMode = "byName",
			emitByName = {
				FireworkBoom = 100,
				Letters = 1,
				MortarSparks = 1,
				ParticleEmitter = 1,
				Specs = 100
			},
			defaultEmitCount = 1
		},
		FloorSparkler = {
			applyRecolor = true,
			explodeSoundName = nil,
			emitMode = "floorSparkler"
		},
		GalaxySpiral = {
			applyRecolor = true,
			explodeSoundName = "GalaxySpiralExplosion",
			emitMode = "byName",
			emitByName = {
				Galaxy = 1,
				Red = 50,
				Blue = 50,
				Yellow = 50,
				Sparks = 50,
				Explosion = 5
			},
			defaultEmitCount = 1
		},
		HeartBurst = {
			applyRecolor = true,
			explodeSoundName = "HeartBurstExplosion",
			emitMode = "namedOnly",
			namedEmitters = { "Vfxheart" },
			defaultEmitCount = 1
		}
	}
}

function FireworkTypeConfigs.Get(p)
	return FireworkTypeConfigs.BY_TYPE[p]
end

return FireworkTypeConfigs