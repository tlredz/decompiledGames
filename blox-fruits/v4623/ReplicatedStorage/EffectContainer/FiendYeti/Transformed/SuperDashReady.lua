workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local dashReadyFX = FX:WaitForChild("YetiEffectsRed").DashReadyFX
return function(data)
	local hrp = data.hrp
	local player = data.player

	if not hrp then
		print(debug.traceback())
		return
	end

	if (workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude > 2500 then
		return
	end

	local rig = data.rig

	if not rig then
		return
	end

	local v = false

	if typeof(player) == "Instance" then
		local yetiFruitVFXColor = player:FindFirstChild("YetiFruitVFXColor")
		v = yetiFruitVFXColor and yetiFruitVFXColor:GetAttribute("SkinStorageKey") == "FIENDSKINsealed" and true or false
	end

	local v2 = hrp:GetAttribute("YetiSkin") == "FIENDSKINsealed" or v

	if data.disable then
		if v2 then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(rig.Body.SurfaceAppearance, TweenInfo.new(0.33, Enum.EasingStyle.Sine), {
				EmissiveStrength = 0
			}):Play()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(rig.Cloth1.SurfaceAppearance, TweenInfo.new(0.33, Enum.EasingStyle.Sine), {
				EmissiveStrength = 0
			}):Play()
		else
			local TweenService = game:GetService("TweenService")
			TweenService:Create(rig["low poly.006"], TweenInfo.new(0.33, Enum.EasingStyle.Sine), {
				Color = Color3.fromRGB(0, 0, 0)
			}):Play()
		end
	else
		if v2 then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(rig.Cloth1.SurfaceAppearance, TweenInfo.new(0.12, Enum.EasingStyle.Sine), {
				EmissiveStrength = 10
			}):Play()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(rig.Body.SurfaceAppearance, TweenInfo.new(0.12, Enum.EasingStyle.Sine), {
				EmissiveStrength = 40
			}):Play()
		else
			local TweenService = game:GetService("TweenService")
			TweenService:Create(rig["low poly.006"], TweenInfo.new(0.12, Enum.EasingStyle.Sine), {
				Color = Color3.fromRGB(255, 255, 255)
			}):Play()
		end

		local clone = dashReadyFX:Clone()
		clone:PivotTo(CFrame.new(hrp.Position))
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "YetiFruitVFXColor")
		Util.DestroyAfter(clone, 3)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Util.Sound:Play("AkumaYeti_SuperDash_Stance_Activate_02", hrp, nil, 2)
	end
end