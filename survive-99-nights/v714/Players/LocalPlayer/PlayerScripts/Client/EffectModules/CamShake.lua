local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CamShake = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CameraShaker = require(ReplicatedStorage.Modules.CameraShaker)

function UpdateShake(p)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * p
end

local v = CameraShaker.new(Enum.RenderPriority.Camera.Value, UpdateShake)
v:Start()

function CamShake.ShakeOnce(value, value2, value3, value4)
	return v:ShakeOnce(value or 5, value2 or 4, value3 or 0.1, value4 or 0.3)
end

local count = 0

function CamShake.rumble(p, value, p2)
	task.spawn(function()
		if count ~= 0 then
			v:StopSustained(0)
		end

		count += 1
		local v2 = count
		local v3 = value or 1
		v:StartShake(0.29 * v3, 14 * v3, 0)
		wait(p)

		if count == v2 then
			v:StopSustained(0)
			count = 0
		end

		if p2 then
			v:Shake(CameraShaker.Presets.Bump)
		end
	end)
end

local v2 = false

function CamShake.cameraSway()
	v2 = true
	coroutine.wrap(function()
		v:StartShake(0.35, 0.5, 0)

		repeat
			wait(0.5)
		until not v2

		v:StopSustained(0)
	end)()
end

function CamShake.cameraSwaySecret()
	v2 = true
	coroutine.wrap(function()
		v:StartShake(0.12, 0.12, 0)

		repeat
			wait(0.5)
		until not v2

		v:StopSustained(0)
	end)()
end

Client.Events.CamShake:Connect(function(p, value, value2, value3, value4)
	if p == "rumble" then
		CamShake.rumble(value, value2)
	elseif p == "shake" then
		CamShake.ShakeOnce(value or 5, value2 or 4, value3 or 0.1, value4 or 0.3)
	end
end)
return CamShake