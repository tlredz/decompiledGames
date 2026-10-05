local ConfigurationService = {}
ConfigurationService.__index = ConfigurationService
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	CircleMinigame = {},
	DyleMonster = {}
}
local v2 = {
	CircleMinigame = {},
	DyleMonster = {}
}
local nows = {}
local v3 = {
	DyleMonster = {
		Speed = {
			WalkSpeed = {
				min = 1,
				max = 30,
				type = "number"
			},
			RunSpeed = {
				min = 5,
				max = 50,
				type = "number"
			},
			SpeedBuildRate = {
				min = 0.01,
				max = 0.5,
				type = "number"
			},
			SpeedDecayRate = {
				min = 0.001,
				max = 0.2,
				type = "number"
			},
			MaxSpeedMultiplier = {
				min = 1,
				max = 5,
				type = "number"
			},
			DecayDelay = {
				min = 0,
				max = 20,
				type = "number"
			},
			GaugeFillRate = {
				min = 0.05,
				max = 1,
				type = "number"
			}
		},
		Behavior = {
			VisionRadius = {
				min = 10,
				max = 200,
				type = "number"
			},
			InstantRadius = {
				min = 5,
				max = 100,
				type = "number"
			},
			KillRadius = {
				min = 3,
				max = 20,
				type = "number"
			},
			GeneratorFreezeTime = {
				min = 0,
				max = 10,
				type = "number"
			},
			HitCooldown = {
				min = 0.5,
				max = 15,
				type = "number"
			},
			GeneratorDetectionRange = {
				min = 10,
				max = 200,
				type = "number"
			},
			AttackSpeedResetDelay = {
				min = 0,
				max = 5,
				type = "number"
			},
			StopOnGenerators = {
				type = "boolean"
			},
			ResetSpeedOnAttack = {
				type = "boolean"
			}
		},
		Visual = {
			GaugeSize = {
				min = 2,
				max = 20,
				type = "number"
			},
			GaugeType = {
				type = "string"
			},
			GaugePosition = {
				type = "string"
			},
			CameraShakeIntensity = {
				min = 0.1,
				max = 5,
				type = "number"
			},
			CameraShakeMinDistance = {
				min = 10,
				max = 150,
				type = "number"
			},
			AttackShakeRange = {
				min = 5,
				max = 100,
				type = "number"
			},
			LightingIntensity = {
				min = 0.1,
				max = 3,
				type = "number"
			},
			LightingSpeedThreshold = {
				min = 0,
				max = 100,
				type = "number"
			},
			BaseClockSpeed = {
				min = 1,
				max = 60,
				type = "number"
			},
			MaxClockSpeed = {
				min = 30,
				max = 500,
				type = "number"
			},
			GaugeShakeThreshold = {
				min = 0,
				max = 100,
				type = "number"
			},
			GaugeFlickerThreshold = {
				min = 0,
				max = 100,
				type = "number"
			},
			GaugePulseThreshold = {
				min = 0,
				max = 100,
				type = "number"
			},
			RedLightingEnabled = {
				type = "boolean"
			},
			FaceAnimationEnabled = {
				type = "boolean"
			},
			ClockHandsEnabled = {
				type = "boolean"
			},
			CameraShakeEnabled = {
				type = "boolean"
			}
		},
		Audio = {
			MaxMusicPitch = {
				min = 0.5,
				max = 4,
				type = "number"
			},
			MusicPitchThreshold = {
				min = 0,
				max = 100,
				type = "number"
			},
			MinMusicVolume = {
				min = 0,
				max = 1,
				type = "number"
			},
			MaxMusicVolume = {
				min = 0,
				max = 1,
				type = "number"
			},
			DynamicMusicEnabled = {
				type = "boolean"
			},
			MusicVolumeScaling = {
				type = "boolean"
			}
		},
		TailPhysics = {
			Constraint = {
				min = 0,
				max = 1,
				type = "number"
			},
			Damping = {
				min = 0,
				max = 1,
				type = "number"
			},
			Elasticity = {
				min = 0,
				max = 1,
				type = "number"
			},
			Gravity = {
				min = 0,
				max = 2,
				type = "number"
			},
			Force = {
				min = 0.1,
				max = 3,
				type = "number"
			},
			UpdateRate = {
				min = 15,
				max = 240,
				type = "number"
			},
			Inertia = {
				min = 0,
				max = 1,
				type = "number"
			},
			Stiffness = {
				min = 0,
				max = 1,
				type = "number"
			},
			ActivationDistance = {
				min = 30,
				max = 200,
				type = "number"
			}
		},
		Particles = {
			ParticleEffectsEnabled = {
				type = "boolean"
			},
			EnableDripParticles = {
				type = "boolean"
			},
			EnableTrailParticles = {
				type = "boolean"
			},
			EnableAmbientParticles = {
				type = "boolean"
			},
			ParticleDripRate = {
				min = 1,
				max = 100,
				type = "number"
			},
			ParticleTrailDensity = {
				min = 5,
				max = 100,
				type = "number"
			},
			ParticleGooIntensity = {
				min = 0.1,
				max = 3,
				type = "number"
			},
			ParticleSpeedMultiplier = {
				min = 0.5,
				max = 5,
				type = "number"
			}
		},
		Advanced = {
			ScaleAnimationTempo = {
				type = "boolean"
			},
			DynamicTailPhysics = {
				type = "boolean"
			},
			SmartBoneSpeedMultiplier = {
				min = 0,
				max = 2,
				type = "number"
			},
			SmartBoneAttackForce = {
				min = 0.5,
				max = 5,
				type = "number"
			},
			SmartBoneEnabled = {
				type = "boolean"
			},
			SmartBonePreset = {
				type = "string"
			}
		},
		RageMode = {
			RageModeEnabled = {
				type = "boolean"
			},
			RageSpeedThreshold = {
				min = 50,
				max = 100,
				type = "number"
			},
			RageDamageMultiplier = {
				min = 1,
				max = 5,
				type = "number"
			},
			RageVisualEffects = {
				type = "boolean"
			},
			RageCameraShake = {
				min = 0.5,
				max = 5,
				type = "number"
			}
		}
	},
	CircleMinigame = {
		Core = {
			boundarySize = {
				min = 20,
				max = 500,
				type = "number"
			},
			boundaryModifier = {
				min = 0.1,
				max = 3,
				type = "number"
			},
			markerSpeed = {
				min = 0.1,
				max = 5,
				type = "number"
			},
			lineThicknessModifier = {
				min = 0.1,
				max = 3,
				type = "number"
			},
			hitTolerance = {
				min = 0,
				max = 20,
				type = "number"
			},
			randomPosition = {
				type = "boolean"
			}
		},
		Zones = {
			blackRatio = {
				min = 0.05,
				max = 0.5,
				type = "number"
			},
			yellowRatio = {
				min = 0.01,
				max = 0.3,
				type = "number"
			},
			greyRatio = {
				min = 0.01,
				max = 0.3,
				type = "number"
			},
			yellowReward = {
				min = 0,
				max = 20,
				type = "number"
			},
			greyReward = {
				min = 0,
				max = 10,
				type = "number"
			}
		},
		Movement = {
			amplitude = {
				min = 10,
				max = 500,
				type = "number"
			},
			speed = {
				min = 0.1,
				max = 10,
				type = "number"
			},
			radius = {
				min = 10,
				max = 300,
				type = "number"
			}
		}
	}
}

function ConfigurationService:Initialize()
	local configurations = ReplicatedStorage:FindFirstChild("Configurations")

	if not configurations then
		warn("ConfigurationService: Configurations folder not found")
		return
	end

	local dyleMonsterConfig = configurations:FindFirstChild("DyleMonsterConfig")

	if dyleMonsterConfig then
		local module = require(dyleMonsterConfig)

		for k, v4 in pairs(module) do
			v.DyleMonster[k] = {}

			for k2, v5 in pairs(v4) do
				v.DyleMonster[k][k2] = v5
			end
		end
	end
end

function ConfigurationService:ValidateValue(p, p2, p3, value)
	local v4 = v3[p]

	if not (v4 and v4[p2] and v4[p2][p3]) then
		return true, value
	end

	local v5 = v4[p2][p3]

	if v5.type == "boolean" then
		if type(value) ~= "boolean" then
			return false, "Value must be a boolean"
		end
	elseif v5.type == "number" then
		if type(value) ~= "number" then
			return false, "Value must be a number"
		end

		if v5.min and value < v5.min then
			return false, string.format("Value must be at least %g", v5.min)
		end

		if v5.max and v5.max < value then
			return false, string.format("Value must be at most %g", v5.max)
		end
	elseif v5.type == "string" and type(value) ~= "string" then
		return false, "Value must be a string"
	end

	return true, value
end

function ConfigurationService:GetValue(p, p2, p3)
	if p == "CircleMinigame" and not v[p] then
		self:GetAllValues("CircleMinigame")
	end

	if v[p] and v[p][p2] then
		return v[p][p2][p3]
	end

	return nil
end

function ConfigurationService:SetValue(p, p2, p3, p4)
	local now = tick()
	local v4 = p .. "." .. p2 .. "." .. p3

	if nows[v4] then
		local v5 = now - nows[v4]

		if v5 < 0.1 then
			return false, "Rate limited - please wait " .. 0.1 - v5 .. " seconds"
		end
	end

	nows[v4] = now
	local v5, v6 = self:ValidateValue(p, p2, p3, p4)

	if not v5 then
		error("Validation failed: " .. v6)
	end

	if not v[p] then
		v[p] = {}
	end

	if not v[p][p2] then
		v[p][p2] = {}
	end

	local v7 = v[p][p2][p3]
	v[p][p2][p3] = p4

	if v2[p] then
		for _, v8 in ipairs(v2[p]) do
			local v9 = v8
			task.spawn(function()
				v9(p2, p3, p4, v7)
			end)
		end
	end

	return true
end

function ConfigurationService:GetAllValues(p)
	if p == "CircleMinigame" and not v[p] then
		v.CircleMinigame = {}
		local configurations = ReplicatedStorage:FindFirstChild("Configurations")

		if configurations then
			local circleMinigameConfig = configurations:FindFirstChild("CircleMinigameConfig")

			if circleMinigameConfig then
				local success, result = pcall(require, circleMinigameConfig)

				if success and result then
					for k, v4 in pairs(result) do
						v.CircleMinigame[k] = {}

						for k2, v5 in pairs(v4) do
							v.CircleMinigame[k][k2] = v5
						end
					end
				end
			end
		end
	end

	return v[p] or {}
end

function ConfigurationService.OnConfigChanged(_, p, p2)
	if not v2[p] then
		v2[p] = {}
	end

	table.insert(v2[p], p2)
	return function()
		local index = table.find(v2[p], p2)

		if index then
			table.remove(v2[p], index)
		end
	end
end

function ConfigurationService:ApplyPreset(p, p2)
	local configurations = ReplicatedStorage:FindFirstChild("Configurations")

	if not configurations then
		return
	end

	local child = configurations:FindFirstChild(p .. "Presets")

	if not child then
		return
	end

	local module = require(child)
	local v4 = module[p2]

	if not v4 then
		return false
	end

	for k, v5 in pairs(v4) do
		for k2, v6 in pairs(v5) do
			self:SetValue(p, k, k2, v6)
		end
	end

	return true
end

ConfigurationService:Initialize()
return ConfigurationService