local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local armourVFX = FX:WaitForChild("EasternDragon").ArmourVFX
	local dragonModel = data.dragonModel
	local auraModel = armourVFX.AuraModel
	local auraModel2 = armourVFX.AuraModel2
	local highlight = armourVFX.Highlight
	local v = { "low poly.030", "low poly.004", "low poly.005" }
	local v2 = {
		["UpperEyelid1.L"] = {
			scale = 1.5
		},
		["UpperEyelid1.R"] = {
			scale = 1.5
		},
		["Leg2.L"] = {
			scale = 1
		},
		["Leg2.R"] = {
			scale = 1
		},
		["Foot.R"] = {
			scale = 1
		},
		["Foot.L"] = {
			scale = 1
		},
		["Arm1.L"] = {
			scale = 1.5
		},
		["Arm1.R"] = {
			scale = 1.5
		},
		["Arm2.L"] = {
			scale = 1
		},
		["Arm2.R"] = {
			scale = 1
		},
		["Hand1.L"] = {
			scale = 1
		},
		["Hand1.R"] = {
			scale = 1
		}
	}
	local descendants

	if data.isEastern == true then
		descendants = dragonModel.RootPart:GetDescendants()
	else
		descendants = dragonModel.RootPart:GetDescendants()
		v2 = {
			["Leg2.L"] = {
				scale = 1
			},
			["Leg2.R"] = {
				scale = 1
			},
			["Foot.R"] = {
				scale = 1
			},
			["Foot.L"] = {
				scale = 1
			},
			["Arm1.L"] = {
				scale = 1.5
			},
			["Arm1.R"] = {
				scale = 1.5
			},
			["Wing5.L"] = {
				scale = 1.5
			},
			["Wing5.R"] = {
				scale = 1.5
			},
			Neck7 = {
				scale = 1.5
			},
			["EyeUpper1.R"] = {
				scale = 1.5
			},
			["EyeUpper1.L"] = {
				scale = 1.5
			},
			Neck10 = {
				scale = 1.5
			}
		}
		v = { "Armour.005", "Armour.006", "Armour.007" }
	end

	local function ParticleEmit(instance)
		for _, descendant in ipairs(descendants) do
			local v3 = v2[descendant.Name]

			if not v3 then
				continue
			end

			local clone = instance:Clone()
			clone.PrimaryPart.CFrame = descendant.WorldCFrame
			Util.SetParentOverrideWithColor(clone, dragonModel, player, "DragonFruitVFXColor")
			Util.DestroyAfter(clone, 5)

			if v3.scale and v3.scale ~= 1 then
				clone:ScaleTo(v3.scale)
			end

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end

	local function Activate()
		for _, v3 in ipairs(v) do
			local v4 = v3
			task.spawn(function()
				local clone = highlight:Clone()
				Util.ColorShiftObjectDescendants(clone, player, "DragonFruitVFXColor")
				clone.Parent = dragonModel[v4]
				Util.ColorShiftObjectDescendants(clone, player, "DragonFruitVFXColor")
				task.wait(0.05)
				Util.DestroyAfter(clone, 5)
				local highlight2 = dragonModel[v4]:FindFirstChildOfClass("Highlight")

				if highlight2 == nil then
					return
				end

				Util.DestroyAfter(highlight2, 5)
				Util.ColorShiftObjectDescendants(highlight2, player, "DragonFruitVFXColor")
				local TweenService = game:GetService("TweenService")
				TweenService:Create(
					highlight2,
					TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
					{
						OutlineTransparency = 1,
						FillTransparency = 1
					}
				):Play()
				task.delay(1, function()
					highlight2:Destroy()
				end)
			end)
		end

		ParticleEmit(auraModel)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DeActivate()
		ParticleEmit(auraModel2)
	end

	if data.activate == nil or data.activate == false then
		Util.Sound:Play("BF_Dragon_ArmorUnequip_01_V3", hrp)
		DeActivate() -- equivalent call inferred; original call site unknown
	else
		Util.Sound:Play("BF_Dragon_ArmorEquip_01_V3", hrp)
		Activate()
	end
end