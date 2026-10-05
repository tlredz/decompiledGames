local Fx = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debris = require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("debris"))
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SettingsController = require(ReplicatedStorage2.client.legacyControllers.SettingsController)

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	local _ = legacyPlayerData.forPlayer
else
	local legacyLocalPlayerData = require(ReplicatedStorage2.client.modules.legacyLocalPlayerData)
	local _ = legacyLocalPlayerData.fetch
end

local function waitTimeout(object, duration: number)
	local thread = coroutine.running()
	local thread2 = task.delay(duration, task.spawn, thread, true)
	local connection = object:Once(function()
		task.spawn(thread, true)
	end)
	local v = coroutine.yield()
	connection:Disconnect()

	if coroutine.status(thread2) == "suspended" then
		task.cancel(thread2)
	end

	return v
end

function Fx.PlaySound(_, instance, parent, playbackSpeed, tag: string?, p)
	if RunService:IsClient() and instance:HasTag("LazyLoadSound") and instance:GetAttribute("SoundId") then
		instance.SoundId = instance:GetAttribute("SoundId")
		instance:RemoveTag("LazyLoadSound")
	end

	local clone = instance:Clone()

	if clone:HasTag("LazyLoadSound") and clone:GetAttribute("SoundId") then
		clone.SoundId = clone:GetAttribute("SoundId")
		clone:RemoveTag("LazyLoadSound")
	end

	if playbackSpeed == true then
		clone.PlaybackSpeed += math.random(-15, 15) / 100
	elseif typeof(playbackSpeed) == "number" then
		clone.PlaybackSpeed = playbackSpeed
	end

	if tag then
		CollectionService:AddTag(clone, tag)

		if p then
			clone:SetAttribute("Owner", p.Name)
		end
	end

	clone:SetAttribute("temp", true)
	clone.Parent = parent
	clone:Play()
	SaneDebris:AddItem(clone, not (clone.TimeLength > 0) and 30 or clone.TimeLength / clone.PlaybackSpeed + 1 or 30)
	clone.Ended:Once(function()
		clone:Destroy()
	end)
	return clone
end

function Fx.ShakeScreen(_, player, p: number, p2: number, _: boolean?)
	if not SettingsController:GetSettingValue("cameraShake") then
		return {
			Stop = function() end
		}
	end

	local RunService2 = game:GetService("RunService")

	if not (RunService2:IsClient() and player.Character) then
		return
	end

	if not player.Character:FindFirstChildWhichIsA("Humanoid") then
		return {
			Stop = function() end
		}
	end

	local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	local v = (p2 == nil or p2 == 0) and 1 or p2
	local v2 = v < 0 and 1e999 or v
	local v3 = p == nil and 1 or p
	local v4 = (v3 <= 0 and 1 or v3) * 100
	local v5 = true
	os.time()
	local cframe = CFrame.new()
	local currentCamera = game.Workspace.CurrentCamera
	local RunService3 = game:GetService("RunService")
	local heartbeatConnection = RunService3.Heartbeat:Connect(function(dt)
		local v6 = dt / 0.016666666666666666
		local _ = currentCamera.CFrame * cframe:Inverse()
		local v7 = -math.round((humanoid.MoveDirection:Dot(currentCamera.CFrame.RightVector)))
		cframe = cframe:Lerp(
			CFrame.Angles(
				v5 and math.rad((math.sin(time() * (math.random(v4 / 2, v4) / 10)))) / 3.5 * v6 or math.rad((math.sin((time())))) / 100 * v6,
				v5 and math.rad((math.sin(time() * (math.random(v4 / 2, v4) / 10)))) / 3 * v6 or math.rad((math.cos((time())))) / 100 * v6,
				math.rad(v7 * 2) * v6
			),
			0.3
		)
		currentCamera.CFrame *= cframe
	end)
	local v6 = {}

	function v6.Stop()
		heartbeatConnection:Disconnect()
		v5 = false
	end

	if v2 and v2 ~= 1e999 then
		task.delay(v2, function()
			v6.Stop()
		end)
	end

	return v6
end

function Fx.EmitParticles(_, instance, parent, p, p2)
	if instance then
		if p > 0 then
			local clone = instance:Clone()
			clone.Parent = parent
			clone:Emit(p)
			debris:AddItem(clone, clone.Lifetime.Max * 2)
		else
			task.spawn(function()
				local clone = instance:Clone()
				clone.Parent = parent
				clone.Enabled = true
				task.wait(p2 or clone.Lifetime.Max)

				if clone and parent then
					clone.Enabled = false
					debris:AddItem(clone, clone.Lifetime.Max * 2)
				end
			end)
		end
	end
end

return Fx