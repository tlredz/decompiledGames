local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.ServerInfo)
local v = require3(ReplicatedStorage2.Shared.LTM)

if not table.find(v.serverProfiles, "SquadRoyale") then
	return {}
end

v.getActiveLTM("SquadRoyale")
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Signal)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local remoteEvent = v2:RemoteEvent("StormPhaseChanged")
local remoteEvent2 = v2:RemoteEvent("StormStarted")
local remoteEvent3 = v2:RemoteEvent("StormChanged")
local remoteEvent4 = v2:RemoteEvent("StormEnded")
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Name = "StormColorCorrection"
colorCorrectionEffect.Parent = Lighting
local cframe = CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
local maid = v3.new()
local v5 = v3.new()
local v6 = v4.new()
local v7 = true
local v8 = nil
local v9 = nil
local flag = false
local v10 = {
	BaseColor = Color3.fromRGB(63, 102, 218),
	Clouds = {
		Color = Color3.fromRGB(0, 0, 0),
		Cover = 0.775,
		Density = 0.36
	}
}

function GetStormParticleCF(p: number)
	return currentCamera.CFrame + createVector(0, 1, 0) * (p * 2)
end

function WithinSafeZoneXZ(p, p2)
	local position = p2.Position
	local position2 = p.Position
	return p.Size.Y / 2 > math.sqrt((position2.X - position.X) ^ 2 + (position2.Z - position.Z) ^ 2)
end

function OnStormPhaseChanged(_: number, _: number)
	if not flag then
		return
	end

	ReplicatedStorage2.Misc.BattleRoyaleSFX.Warning:Play()
end

function OnStormChanged(lastRadius: number, position: Vector3)
	if not flag then
		return
	end

	if v8 and v9 then
		local originalRadius = v9 and v9:GetAttribute("OriginalRadius") or 600
		local v11 = (v9 and v9:GetAttribute("LastRadius") or 600) / originalRadius - 0.01
		local tween = TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Size = Vector3.new(1000, lastRadius, lastRadius),
			CFrame = CFrame.new(position) * cframe
		})
		v5:Add(tween)
		local tween2 = TweenService:Create(v9.PrimaryPart, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(position)
		})
		v5:Add(tween2)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = v11
		local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			if v9 then
				v9:ScaleTo(numberValue.Value)
			end
		end)
		local tween3 = TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Value = lastRadius / originalRadius - 0.01
		})
		v5:Add(tween3)
		tween:Play()
		tween3:Play()
		tween2:Play()

		if v9 then
			v9:SetAttribute("LastRadius", lastRadius)
		end

		tween.Completed:Once(function()
			v5:Remove(tween)
		end)
		tween3.Completed:Once(function()
			v5:Remove(tween3)
			valueChangedConnection:Disconnect()
			numberValue:Destroy()
		end)
		tween2.Completed:Once(function()
			v5:Remove(tween2)
		end)
	else
		task.wait(0.25)

		if workspace:GetAttribute("GameActive") then
			OnStormStarted(lastRadius, position)
		end
	end
end

function OnStormStarted(originalRadius: number, position: Vector3)
	if flag then
		return
	end

	flag = true
	local v11 = {}
	local v12 = {
		TintColor = colorCorrectionEffect.TintColor
	}
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.CanQuery = false
	part.Size = Vector3.new(1000, originalRadius, originalRadius)
	part.Material = Enum.Material.ForceField
	part.Transparency = 0
	part.Color = Color3.fromRGB(95, 41, 255)
	part.CFrame = CFrame.new(position) * cframe
	part.Parent = workspace
	v8 = part
	local clone = script.FloorParticle:Clone()
	clone:PivotTo(CFrame.new(position))
	clone.Parent = workspace
	clone:SetAttribute("OriginalRadius", originalRadius)
	v9 = clone
	local clone2 = script.CameraTrick:Clone()
	clone2.CFrame = GetStormParticleCF(1)
	clone2.Parent = currentCamera
	local clone3 = script.CameraTrick:Clone()
	clone3.CFrame = GetStormParticleCF(-1)
	clone3.Parent = currentCamera
	local clone4 = ReplicatedStorage2.Misc.BattleRoyaleSFX.Ambiance:Clone()
	clone4.Looped = true
	clone4.Parent = SoundService
	local clouds = workspace.Terrain:FindFirstChildWhichIsA("Clouds")

	if clouds then
		for k in v10.Clouds do
			v11[k] = clouds[k]
		end
	end

	maid:Add(v6:Connect(function()
		if v7 then
			colorCorrectionEffect.TintColor = v12.TintColor

			if clouds then
				for k, v13 in v11 do
					clouds[k] = v13
				end
			end
		else
			colorCorrectionEffect.TintColor = v10.BaseColor

			if clouds then
				for k, cloud in v10.Clouds do
					clouds[k] = cloud
				end
			end
		end

		local volume = v7 == false and 0.5 or 0
		local tween = TweenService:Create(clone4, TweenInfo.new(0.5), {
			Volume = volume
		})
		tween:Play()
		tween.Completed:Once(function()
			v5:Remove(tween)

			if volume == 0 then
				clone4:Stop()
			end
		end)

		if volume == 0.5 then
			clone4:Play()
		end

		v5:Add(tween)
	end))
	maid:Add(RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character
		local primaryPart = character and character.PrimaryPart

		if not primaryPart then
			return
		end

		local v13 = character.Parent == workspace.Alive
		local v14 = not (v13 and v8) or WithinSafeZoneXZ({
			Size = Vector3.new(v8.Size.Z, v8.Size.Z, v8.Size.Z),
			Position = v8.Position
		}, primaryPart)

		if v13 then
			clone2.CFrame = GetStormParticleCF(1)
			clone3.CFrame = GetStormParticleCF(-1)
		end

		if v14 ~= v7 then
			v7 = v14
			v6:Fire()
		end

		local enabled = v13 and v14 == false and true or false
		clone2.BlackSmoke.Enabled = enabled
		clone2.Smoke.Enabled = enabled
		clone3.BlackSmoke.Enabled = enabled
		clone3.Smoke.Enabled = enabled
	end))
	maid:Add(function()
		RunService.RenderStepped:Wait()
		v5:Destroy()
		colorCorrectionEffect.TintColor = v12.TintColor

		if clouds then
			for k, v13 in v11 do
				clouds[k] = v13
			end
		end

		clone4:Stop()
		clone4:Destroy()
	end)
	maid:Add(function()
		RunService.RenderStepped:Wait()
		clone2:Destroy()
		clone3:Destroy()
	end)
end

function OnStormEnded()
	if not flag then
		return
	end

	flag = false

	if v9 then
		v9:Destroy()
		v9 = nil
	end

	if v8 then
		local tween = TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Transparency = 1
		})
		tween:Play()
		tween.Completed:Wait()
		v8:Destroy()
		v8 = nil
	end

	maid:Destroy()
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(OnStormPhaseChanged)
		remoteEvent2.OnClientEvent:Connect(OnStormStarted)
		remoteEvent3.OnClientEvent:Connect(OnStormChanged)
		ReplicatedStorage2.Remotes.RoundEnded.OnClientEvent:Connect(OnStormEnded)
		remoteEvent4.OnClientEvent:Connect(OnStormEnded)
	end
}