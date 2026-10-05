local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local SoulvesterGuardCinematic = RunService:IsClient() and require(script.Parent.SoulvesterGuardCinematic) or nil

local function heroShotActive()
	return SoulvesterGuardCinematic ~= nil and SoulvesterGuardCinematic.isActive()
end

local ScreenEffectsCore = require(ReplicatedStorage.Modules.Gameplay.ScreenEffectsCore)
local ScreenEffectsSetting = RunService:IsClient() and require(ReplicatedStorage.Modules.ClientUI.ScreenEffectsSetting) or nil
local CameraTrick = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value)
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - 2 * v)
end

local function envelope(p, p2, p3, p4)
	if p < p3 then
		return smooth(p / p3)
	end

	if p2 - p4 < p then
		return smooth((p2 - p) / p4)
	else
		return 1
	end
end

CameraTrick.EFFECTS = {
	Vertigo = {
		order = 1,
		label = "Vertigo (dolly zoom)",
		blurb = "FOV opens while the camera pushes in; the room stretches away behind you.",
		duration = 4,
		frame = function(p, _, p2, p3)
			local duration = p3.duration
			local v

			if p < 1.6 then
				v = smooth(p / 1.6)
			elseif duration - 1 < p then
				v = smooth((duration - p) / 1)
			else
				v = 1
			end

			local v2 = 45 * v
			local restFov = p2.restFov
			local v3 = math.tan((math.rad(restFov / 2))) / math.tan((math.rad((restFov + v2) / 2)))
			return v2, 0, (Vector3.new(0, 0, -(p2.subjectDistance * (1 - v3))))
		end,
		grade = {
			saturation = -0.3,
			contrast = 0.15
		}
	},
	Drunk = {
		order = 2,
		label = "Drunk (sway + roll)",
		blurb = "Slow roll, breathing FOV, a lazy sideways sway, soft blur.",
		duration = 7,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 1.2 then
				v = smooth(p / 1.2)
			elseif duration - 1.5 < p then
				v = smooth((duration - p) / 1.5)
			else
				v = 1
			end

			local v2 = math.sin(p * 1.1) * 0.15707963267948966 * v
			return
				math.sin(p * 0.8 + 1) * 7 * v,
				v2,
				Vector3.new(math.sin(p * 0.7) * 0.9, math.sin(p * 1.3) * 0.35, 0) * v
		end,
		grade = {
			blur = 7,
			saturation = 0.15
		}
	},
	Tunnel = {
		order = 3,
		label = "Tunnel vision",
		blurb = "FOV crushes to a keyhole, colour drains, the edges blur.",
		duration = 4,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 0.5 then
				v = smooth(p / 0.5)
			elseif duration - 0.9 < p then
				v = smooth((duration - p) / 0.9)
			else
				v = 1
			end

			return -38 * v, 0, createVector(0, 0, 0)
		end,
		grade = {
			saturation = -0.7,
			contrast = 0.25,
			blur = 5
		}
	},
	Fisheye = {
		order = 4,
		label = "Fisheye",
		blurb = "FOV blows out to 120 and hangs there, everything bends at the edges.",
		duration = 4,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 0.25 then
				v = smooth(p / 0.25)
			elseif duration - 0.8 < p then
				v = smooth((duration - p) / 0.8)
			else
				v = 1
			end

			return 50 * v, 0, createVector(0, 0, 0)
		end,
		grade = {
			contrast = 0.2,
			tint = Color3.fromRGB(235, 225, 255)
		}
	},
	UpsideDown = {
		order = 5,
		label = "Upside down",
		blurb = "The world rolls over, holds, and rolls back.",
		duration = 4.5,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 0.6 then
				v = smooth(p / 0.6)
			elseif duration - 0.7 < p then
				v = smooth((duration - p) / 0.7)
			else
				v = 1
			end

			return 0, 3.141592653589793 * v, createVector(0, 0, 0)
		end,
		grade = {
			saturation = -0.4,
			tint = Color3.fromRGB(255, 220, 220)
		}
	},
	Earthquake = {
		order = 6,
		label = "Earthquake",
		blurb = "Building rumble: shake ramps, FOV jitters, then settles.",
		duration = 3.2,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 1 then
				v = smooth(p / 1)
			elseif duration - 0.8 < p then
				v = smooth((duration - p) / 0.8)
			else
				v = 1
			end

			return (math.random() - 0.5) * 6 * v, math.sin(p * 23) * 0.03490658503988659 * v, createVector(0, 0, 0)
		end,
		shake = 0.55,
		grade = {
			contrast = 0.1
		}
	},
	Glitch = {
		order = 7,
		label = "Glitch (VHS)",
		blurb = "Random frame jumps, roll spikes and colour tearing for a few seconds.",
		duration = 3,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 0.1 then
				v = smooth(p / 0.1)
			elseif duration - 0.4 < p then
				v = smooth((duration - p) / 0.4)
			else
				v = 1
			end

			if math.random() < 0.18 * v then
				return
					(math.random() - 0.5) * 30,
					(math.random() - 0.5) * 0.4188790204786391,
					(Vector3.new((math.random() - 0.5) * 1.6, (math.random() - 0.5) * 0.8, 0))
			end

			return 0, 0, createVector(0, 0, 0)
		end,
		grade = {
			saturation = -1,
			contrast = 0.6,
			tint = Color3.fromRGB(200, 255, 220)
		},
		graceFlicker = true
	},
	Heartbeat = {
		order = 8,
		label = "Heartbeat",
		blurb = "FOV and contrast pulse in a two-beat rhythm, red bleeding in.",
		duration = 5,
		frame = function(p, _, _, p2)
			local duration = p2.duration
			local v

			if p < 0.6 then
				v = smooth(p / 0.6)
			elseif duration - 1 < p then
				v = smooth((duration - p) / 1)
			else
				v = 1
			end

			local v2 = p * 1.3 % 1
			local v3 = math.max(0, 1 - math.abs(v2 - 0.08) / 0.08) + math.max(0, 1 - math.abs(v2 - 0.32) / 0.08) * 0.7
			return v3 * -6 * v, 0, (Vector3.new(0, 0, v3 * 0.25 * v))
		end,
		grade = {
			saturation = -0.35,
			contrast = 0.3,
			tint = Color3.fromRGB(255, 200, 200)
		}
	}
}

function CameraTrick.names()
	local result = {}

	for k in pairs(CameraTrick.EFFECTS) do
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		return CameraTrick.EFFECTS[a].order < CameraTrick.EFFECTS[b].order
	end)
	return result
end

local v = nil
local count = 0

local function getGrade()
	local v2 = Lighting:FindFirstChild("CameraTrickGrade")

	if not v2 then
		v2 = Instance.new("ColorCorrectionEffect")
		v2.Name = "CameraTrickGrade"
		v2.Enabled = false
		v2.Parent = Lighting
	end

	local v3 = Lighting:FindFirstChild("CameraTrickBlur")

	if v3 then
		return v2, v3
	end

	v3 = Instance.new("BlurEffect")
	v3.Name = "CameraTrickBlur"
	v3.Size = 0
	v3.Enabled = false
	v3.Parent = Lighting
	return v2, v3
end

local function stop(p)
	local v2 = v

	if not v2 then
		return
	end

	v = nil
	pcall(function()
		RunService:UnbindFromRenderStep("CameraTrickStep")
	end)
	local camera = v2.camera

	if camera and camera.Parent then
		camera.FieldOfView = v2.restFov
	end

	local cc = v2.cc
	local blur = v2.blur

	if cc and cc.Parent then
		local tween = TweenService:Create(cc, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Saturation = 0,
			Contrast = 0,
			TintColor = Color3.new(1, 1, 1)
		})
		tween.Completed:Once(function()
			if v == nil and cc.Parent then
				cc.Enabled = false
			end
		end)
		tween:Play()
	end

	if blur and blur.Parent then
		local tween = TweenService:Create(blur, TweenInfo.new(0.5), {
			Size = 0
		})
		tween.Completed:Once(function()
			if v == nil and blur.Parent then
				blur.Enabled = false
			end
		end)
		tween:Play()
	end

	if p and p ~= "ended" then
		print("[CameraTrick] stopped:", p)
	end
end

function CameraTrick.stopAll()
	stop("stopAll")
	local cameraTrickGrade = Lighting:FindFirstChild("CameraTrickGrade")

	if cameraTrickGrade then
		cameraTrickGrade.Enabled = false
	end

	local cameraTrickBlur = Lighting:FindFirstChild("CameraTrickBlur")

	if cameraTrickBlur then
		cameraTrickBlur.Enabled = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function subjectDistance(p)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (math.max((p.CFrame.Position - humanoidRootPart.Position).Magnitude, 0.5))
	end

	return 10
end

function CameraTrick.RenderObject(p)
	local effect = p and p.effect
	local effect2

	if type(effect) == "string" then
		effect2 = CameraTrick.EFFECTS[effect]
	else
		effect2 = false
	end

	if not effect2 then
		warn("[CameraTrick] unknown effect", (tostring(effect)))
		return
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local v3

		if SoulvesterGuardCinematic == nil then
			v3 = false
		else
			v3 = SoulvesterGuardCinematic.isActive()
		end

		if not v3 then
			local profile = ScreenEffectsSetting.profile()

			if ScreenEffectsCore.isMotionOff(profile) then
				print("[CameraTrick] skipped", effect, "- Intense Screen Effects is Off")
				return
			end

			local v4 = math.clamp(tonumber(p.duration) or effect2.duration, 0.5, 15)
			stop("replaced")
			count += 1
			local token = count
			local grade, blur = getGrade()
			local v7 = {
				token = token,
				camera = currentCamera,
				restFov = currentCamera.FieldOfView,
				effect = effect2,
				cc = grade,
				blur = blur
			}
			v = v7
			local grade2 = effect2.grade

			if grade2 then
				grade.Enabled = true
				TweenService:Create(grade, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Saturation = (grade2.saturation or 0) * profile.grade,
					Contrast = (grade2.contrast or 0) * profile.grade,
					TintColor = Color3.new(1, 1, 1):Lerp(grade2.tint or Color3.new(1, 1, 1), profile.grade)
				}):Play()

				if grade2.blur and profile.blur then
					blur.Enabled = true
					TweenService:Create(blur, TweenInfo.new(0.4), {
						Size = grade2.blur
					}):Play()
				end
			end

			local lastTime = os.clock()
			local v8 = {
				restFov = v7.restFov,
				subjectDistance = subjectDistance(currentCamera)
			}
			RunService:BindToRenderStep("CameraTrickStep", Enum.RenderPriority.Camera.Value + 2, function()
				if v ~= v7 then
					return
				end

				local v9 = os.clock() - lastTime

				if not (v4 <= v9) and currentCamera.Parent and workspace.CurrentCamera == currentCamera then
					local v10

					if SoulvesterGuardCinematic == nil then
						v10 = false
					else
						v10 = SoulvesterGuardCinematic.isActive()
					end

					if not v10 then
						v8.subjectDistance = subjectDistance(currentCamera)
						local success, result, v13, v14 = pcall(effect2.frame, v9, v9 / v4, v8, effect2)

						if not success then
							stop("frame error: " .. tostring(result))
							return
						end

						currentCamera.FieldOfView = math.clamp(v7.restFov + (result or 0) * profile.motion, 1, 120)
						local cFrame = currentCamera.CFrame

						if v13 and v13 ~= 0 then
							cFrame *= CFrame.Angles(0, 0, ScreenEffectsCore.limitRoll(profile, v13))
						end

						if v14 and v14 ~= createVector(0, 0, 0) then
							cFrame *= CFrame.new(v14 * profile.motion)
						end

						if effect2.shake then
							local v15 = v4
							local v16

							if v9 < 1 then
								v16 = smooth(v9 / 1)
							elseif v15 - 0.8 < v9 then
								v16 = smooth((v15 - v9) / 0.8)
							else
								v16 = 1
							end

							local v17 = v16 * profile.motion
							cFrame *= CFrame.new(
								(math.random() - 0.5) * effect2.shake * v17,
								(math.random() - 0.5) * effect2.shake * v17,
								0
							)
						end

						if effect2.graceFlicker and profile.flicker and grade.Parent then
							grade.Enabled = math.random() > 0.08
						end

						currentCamera.CFrame = cFrame
						return
					end
				end

				stop(v4 <= v9 and "ended" or "camera changed or hero shot")
			end)
			task.delay(v4 + 0.5, function()
				if v == v7 then
					stop("hard stop")
				end
			end)
		end
	end
end

if ScreenEffectsSetting then
	ScreenEffectsSetting.onChanged(function()
		if v and ScreenEffectsCore.isMotionOff(ScreenEffectsSetting.profile()) then
			stop("screen effects switched off")
		end
	end)
end

return CameraTrick