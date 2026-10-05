local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}

function BurnItem(instance, instance2)
	if v[instance2] or not (instance2 and instance and instance.PrimaryPart) then
		return
	end

	v[instance2] = true
	task.delay(5, function()
		v[instance2] = nil
	end)

	if instance2.PrimaryPart == nil then
		instance2:Destroy()
		return
	end

	local position = instance2:GetPivot().Position
	local v2 = instance:GetPivot().Position + createVector(0, 2, 0)
	instance2:Destroy()

	if not (instance and instance:FindFirstChild("ExtraBits") and instance.ExtraBits:FindFirstChild("Furnace") and instance.ExtraBits.Furnace:FindFirstChild("LightPart")) then
		return
	end

	if (v2 - position).Magnitude <= 25 then
		if instance2.Name == "Oil Barrel" then
			for _, emitter in pairs(instance.DashedLine:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		else
			instance.ExtraBits.Furnace.PartParticle.Attachment.FireFlareLarge:Emit(2)
		end
	end

	local clone = instance.ExtraBits.Furnace.PartParticle.FuelAdded:Clone()
	clone.Parent = instance.PrimaryPart
	clone:Play()
	task.spawn(function()
		wait(4)
		clone:Destroy()
	end)
end

Client.Events.BurnItemInAmmoFurnaceFire:Connect(BurnItem)

function CheckInnerTouch(p, instance)
	if instance and instance.Parent and instance:GetAttribute("BurnFuel") then
		print("Checking again")
		local owner = instance:GetAttribute("Owner")

		if owner == nil or owner == localPlayer.UserId then
			print("Owner is good")
			Client.Events.RequestAmmoFurnaceBurnItem:FireServer(p, instance)
			BurnItem(p, instance)
		end
	end
end

function ToggleFire(instance, enabled)
	if not (instance and instance:FindFirstChild("ExtraBits") and instance.ExtraBits:FindFirstChild("Furnace") and instance.ExtraBits.Furnace:FindFirstChild("LightPart")) then
		return
	end

	instance.ExtraBits.Furnace.PartParticle.Attachment.Fire.Enabled = enabled

	if enabled then
		instance.ExtraBits.Furnace.LightPart.PointLight.Enabled = true
	else
		instance.ExtraBits.Furnace.LightPart.PointLight.Enabled = false
	end
end

function AddFireSource(instance)
	print("BULLET THING ADDED")
	local fuelRemaining = instance:GetAttribute("FuelRemaining") or 0
	instance:GetAttributeChangedSignal("FuelRemaining"):Connect(function()
		local fuelRemaining2 = instance:GetAttribute("FuelRemaining")

		if fuelRemaining2 > 0 and fuelRemaining == 0 then
			ToggleFire(instance, true)
		elseif fuelRemaining2 <= 0 then
			ToggleFire(instance, false)
		end

		fuelRemaining = fuelRemaining2
	end)
	local touchZone = instance:WaitForChild("TouchZone")
	print("Found touch zone...")
	touchZone.Touched:Connect(function(otherPart)
		print("Touch zone touched")
		local parent = otherPart.Parent

		if not parent then
			return
		end

		print("Found parent")
		CheckInnerTouch(instance, parent)
	end)
end

function AmmoFurnaceAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	AddFireSource(instance)
end

Client.Utility.ForAllTagged("AmmoFurnace", AmmoFurnaceAdded)
return {}