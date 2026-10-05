local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local assets = require(ReplicatedStorage.shared.utils.assets)
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local GenericFallingWeapon = {}
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
local v = {}

function GenericFallingWeapon.CreateWeaponModel(p, p2)
	local skin

	if p.OverrideModelName then
		skin = ReplicatedStorage.resources.replicated.instances.general:FindFirstChild(p.OverrideModelName)
	elseif p2.RodSkin and p2.RodSkin ~= "Default" then
		local async = assets.getAsync("skin", p2.RodSkin)
		skin = async and async:FindFirstChild("Skin")
	else
		local async = assets.getAsync("rod", p2.Rod)
		skin = async and async:FindFirstChild(p2.Rod)
	end

	if not skin then
		warn((`Failed to find model for falling weapon {p2.Rod} / {p2.RodSkin}!`))
		return nil
	end

	local clone = skin:Clone()
	clone:ScaleTo(clone:GetScale() * (p.ModelScale or 1))

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.CastShadow = false
		elseif descendant:IsA("Light") then
			descendant.Enabled = false
		end
	end

	return clone
end

function GenericFallingWeapon.SpawnShockwave(data, p)
	if data.ShockwaveDisabled then
		return
	end

	local child = ReplicatedStorage.resources.replicated.instances.general:FindFirstChild(data.ShockwaveName or "Shockwave")

	if not child then
		warn((`No shockwave part found with name "{data.ShockwaveName}"`))
		return
	end

	local shockwaveSize = data.ShockwaveSize or 10
	local shockwaveSizeEnd = data.ShockwaveSizeEnd or shockwaveSize * 3
	local clone = child:Clone()
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Massless = true
	clone.CastShadow = false
	clone:PivotTo(CFrame.new(p.Center.Position + createVector(0, 2, 0)))
	clone.Size = Vector3.new(shockwaveSize, clone.Size.Y, shockwaveSize)
	clone.Parent = workspace.active.debrisfx
	local tween = TweenService:Create(clone, TweenInfo.new(data.ShockwaveTime or 2, Enum.EasingStyle.Quart), {
		Size = Vector3.new(shockwaveSizeEnd, clone.Size.Y, shockwaveSizeEnd),
		Transparency = 1
	})
	tween.Completed:Once(function()
		clone:Destroy()
	end)
	tween:Play()
end

function GenericFallingWeapon.PlaySound(childName: string?, p, p2)
	if not (childName and p) then
		return
	end

	local child = fishing:FindFirstChild(childName)

	if not child then
		return
	end

	fx:PlaySound(child, p, false, "FishingSound", p2)
end

function GenericFallingWeapon.SpawnWeapon(_, maid, p, data, data2)
	local flag = false
	v[p] = true
	maid:Add(function()
		flag = true
		v[p] = nil
	end)
	local weaponModel = GenericFallingWeapon.CreateWeaponModel(data, data2)

	if not weaponModel or flag then
		return
	end

	local v2 = data2.Center * data.InitialOffset
	local v3 = data2.Center * data.EndingOffset
	local primaryPart = weaponModel.PrimaryPart
	primaryPart.Anchored = true

	if data.PivotOffset then
		primaryPart.PivotOffset *= CFrame.new(data.PivotOffset.Position * (data.ModelScale or 1)) * data.PivotOffset.Rotation
	end

	weaponModel:PivotTo(v2)
	weaponModel.Name = data2.Owner.Name
	weaponModel.Parent = workspace.active.debrisfx
	maid:Add(weaponModel)
	GenericFallingWeapon.PlaySound(data.StartSoundName, data2.Root, data2.Owner)

	while v[p] == true and not flag do
		task.wait()
	end

	if flag or not v[p] then
		return
	end

	local v4 = math.clamp(workspace:GetServerTimeNow() - v[p], 0, data.FallAnimTime + (data.SpawnDelay or 0))
	task.wait((data.SpawnDelay or 0) - v4)

	if flag then
		weaponModel:Destroy()
		return
	end

	SaneDebris:AddItem(weaponModel, data.FallAnimTime)
	local v5 = false

	while true do
		local v6 = RunService.RenderStepped:Wait()

		if not (weaponModel.Parent and primaryPart.Parent) then
			break
		end

		v4 += v6
		local v7 = v4 / data.FallAnimTime
		primaryPart:PivotTo(v2:Lerp(
			v3,
			(math.lerp(
				v7,
				TweenService:GetValue(
					v7,
					data.EasingStyle or Enum.EasingStyle.Back,
					data.EasingDirection or Enum.EasingDirection.In
				),
				data.EasingIntensity or 1
			))
		))

		if not v5 and (data.FallHitTime or data.FallAnimTime * 0.9) <= v4 then
			GenericFallingWeapon.SpawnShockwave(data, data2)
			GenericFallingWeapon.PlaySound(data.HitSoundName, data2.Root, data2.Owner)
			v5 = true
		end

		if data.FallAnimTime <= v4 then
			break
		end
	end

	GenericFallingWeapon.PlaySound(data.EndSoundName, data2.Root, data2.Owner)
end

function GenericFallingWeapon.StartAnim(_, _, p, p2)
	v[p] = p2
end

return GenericFallingWeapon