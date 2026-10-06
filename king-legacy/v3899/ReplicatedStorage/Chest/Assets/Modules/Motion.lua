local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local Motion = {}
local v = {}
local flag = nil
local Presets = require(script:WaitForChild("Presets"))

function ExcuteMotions()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("MotionShaker", Enum.RenderPriority.Camera.Value + 1, function(p)
		Motion:Update(p)
	end)
end

function RegisterMotion(p)
	if table.find(v, p) then
		return
	end

	if _G.CheckSettingClient(localPlayer, "Setting_CameraShake") and not _G.ChestOpening then
		table.insert(v, p)
		ExcuteMotions()
	end
end

function CreateMotionTask(value: number, value2: number, value3: number, value4: number, value5: number, vector2: Vector3)
	return {
		_Elapsed = 0,
		_Duration = value5 or 1,
		_Magnitude = value or 1,
		_Roughness = value2 or 10,
		_FadeIn = value3 or 0.1,
		_FadeOut = value4 or 0.25,
		_PositionInfluence = vector2 or createVector(1, 1, 1),
		_Seed = tick() + math.random(1, 10000000)
	}
end

function Motion.ShakeOnce(_, p: number, p2: number, p3: number, p4: number, p5: number, vector2: Vector3)
	RegisterMotion(CreateMotionTask(p, p2, p3, p4, p5, vector2))
end

function Motion.Shake(_, p: string)
	if not Presets[p] then
		return
	end

	RegisterMotion(Presets[p](CreateMotionTask()))
end

function Motion:Update(p)
	local cFrame = currentCamera.CFrame
	debug.profilebegin("Motion")
	local v2 = {}
	local v3 = createVector(0, 0, 0)

	for i, v4 in ipairs(v) do
		local _Duration = v4._Duration
		v4._Elapsed += p

		if _Duration <= v4._Elapsed then
			table.insert(v2, i)
		else
			local v5 = v4._Elapsed / _Duration
			local v6 = 1

			if v4._Elapsed < v4._FadeIn then
				v6 = v4._Elapsed / v4._FadeIn
			elseif v4._Elapsed > _Duration - v4._FadeOut then
				v6 = math.max((_Duration - v4._Elapsed) / v4._FadeOut, 0)
			end

			local v7 = v6 ^ 2
			local v8 = v5 * v4._Roughness
			v3 += Vector3.new(math.noise(v8, 0), math.noise(v4._Seed, 0, v8), (math.noise(v4._Seed, v8, v4._Seed))) * v4._Magnitude * v7 * v4._PositionInfluence
		end
	end

	debug.profileend()
	currentCamera.CFrame = cFrame * CFrame.new(v3)

	if #v <= 0 then
		RunService:UnbindFromRenderStep("MotionShaker")
		flag = nil
	end

	if #v2 <= 0 then
		return
	end

	for i = #v2, 1, -1 do
		table.remove(v, v2[i])
	end
end

return Motion