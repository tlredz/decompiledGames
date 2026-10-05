local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "WaterBalloon_MidAir"
})
local GunHitReceiver = require(ReplicatedStorage.Modules.Shared.Components.Triggers.GunHitReceiver)

function v.Start(p)
	if p.Instance.Name ~= Players.LocalPlayer.Name then
		return
	end

	local hitbox = p.Instance:WaitForChild("Hitbox", 0.25)

	if not hitbox then
		return
	end

	local flag = false
	hitbox.Touched:Connect(function(part)
		if part:IsA("BasePart") then
			local v2 = part and part:HasTag("GunHitReceiver") and GunHitReceiver:FromInstance(part)

			if v2 then
				GunHitReceiver.OnPlayerShot(v2, Players.LocalPlayer, hitbox.Position)
			end

			if not (Players.LocalPlayer.Character and part:IsDescendantOf(Players.LocalPlayer.Character)) then
				if flag then
					return
				end

				flag = true
				p.Instance.Transparency = 1
				p.Instance.CanCollide = false
				p.Instance.CanQuery = false
				p.Instance.CanTouch = false
				p.Instance.Anchored = true
				local clone = p.Instance:Clone()
				clone.Size = createVector(0.01, 0.01, 0.01)
				clone.Parent = Players.LocalPlayer.Character
				Debris:AddItem(clone:FindFirstChild("Hitbox"), 0)
				Debris:AddItem(clone, 1)
				Debris:AddItem(p.Instance, 0)
				local VFX = clone:WaitForChild("VFX", 0.25)

				if not VFX then
					return
				end

				for _, child in VFX:GetChildren() do
					if child:IsA("ParticleEmitter") then
						child:Emit(child:GetAttribute("EmitCount"))
					elseif child:IsA("Sound") then
						child:Play()
					end
				end
			end
		end
	end)
end

return v