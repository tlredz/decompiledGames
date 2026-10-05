local CameraShakerExample = {}
game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function CameraShakerExample.SetupClientShaker()
	return [[
    -- Place this in a LocalScript in StarterPlayerScripts
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    
    local CameraShaker = require(ReplicatedStorage.Modules.External.CameraShaker)
    local camera = workspace.CurrentCamera
    local player = Players.LocalPlayer
    
    -- Create and start camera shaker
    local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(shakeCFrame)
        camera.CFrame = camera.CFrame * shakeCFrame
    end)
    camShake:Start()
    
    -- Listen for shake events from server
    local shakeEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CameraShake", 5)
    if shakeEvent then
        shakeEvent.OnClientEvent:Connect(function(shakeType, customParams)
            if shakeType == "Explosion" then
                camShake:Shake(CameraShaker.Presets.Explosion)
            elseif shakeType == "Bump" then
                camShake:Shake(CameraShaker.Presets.Bump)
            elseif shakeType == "Earthquake" then
                camShake:Shake(CameraShaker.Presets.Earthquake)
            elseif shakeType == "Custom" and customParams then
                camShake:ShakeOnce(
                    customParams.magnitude or 1,
                    customParams.roughness or 1,
                    customParams.fadeInTime or 0.1,
                    customParams.fadeOutTime or 1,
                    customParams.posInfluence,
                    customParams.rotInfluence
                )
            end
        end)
    end
    ]]
end

CameraShakerExample.ShakeTypes = {
	MonsterRoar = function()
		return "Earthquake", nil
	end,
	Explosion = function(p)
		return "Custom", {
			magnitude = math.max(0.5, 2 - p / 50),
			roughness = 2,
			fadeInTime = 0.1,
			fadeOutTime = 0.75
		}
	end,
	TakeDamage = function()
		return "Bump", nil
	end,
	ZoneEffect = function()
		return "Custom", {
			magnitude = 0.3,
			roughness = 5,
			fadeInTime = 0.5,
			fadeOutTime = 1
		}
	end,
	BlackoutPulse = function()
		return "Custom", {
			magnitude = 0.5,
			roughness = 1,
			fadeInTime = 2,
			fadeOutTime = 2
		}
	end
}

function CameraShakerExample.TriggerShakeForPlayer(player, p, p2)
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local cameraShake = events:FindFirstChild("CameraShake")

	if cameraShake then
		cameraShake:FireClient(player, p, p2)
	end
end

function CameraShakerExample.TriggerShakeForAllPlayers(p, p2)
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local cameraShake = events:FindFirstChild("CameraShake")

	if cameraShake then
		cameraShake:FireAllClients(p, p2)
	end
end

function CameraShakerExample.TriggerProximityShake(p, p2, p3, options)
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local cameraShake = events:FindFirstChild("CameraShake")

	if not cameraShake then
		return
	end

	for _, player in pairs(Players:GetPlayers()) do
		if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local magnitude = (player.Character.HumanoidRootPart.Position - p).Magnitude

		if not (magnitude <= p2) then
			continue
		end

		local v = 1 - magnitude / p2
		local v2 = options or {}

		if v2.magnitude then
			v2.magnitude *= v
		end

		cameraShake:FireClient(player, p3, v2)
	end
end

return CameraShakerExample