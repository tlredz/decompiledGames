local module = require("@game/ReplicatedStorage/Omni")
local Weapons = require(script.Parent.Parent.Rendering.Weapons)
local UltimateRunner = require(script.Parent.Parent.Rendering.Weapons.UltimateRunner)
local replication = workspace:WaitForChild("Server"):WaitForChild("Replication")
local v = {}
local v2 = {}
local Weapons2 = {}

local function IsNear(vector: Vector3)
	local currentCamera = workspace.CurrentCamera
	return currentCamera ~= nil and (currentCamera.CFrame.Position - vector).Magnitude <= 150
end

function Weapons2.ClearIdle(p)
	local v3 = v[p]

	if not (v3 and v3.Animate) then
		return
	end

	v3.Animate:RemoveForcedState("Weapon")
	v3.AnimationState = nil
	v3.Animate:RemoveCustomAnimationForState("Weapon", "Idle")
	v3.Animate:RemoveCustomAnimationForState("Weapon", "Walk")
	v3.Animate:RemoveCustomAnimationForState("Weapon", "Run")
	v3.Animate = nil
end

function Weapons2.UpdateIdle(instance)
	if instance ~= module.Instance then
		return
	end

	local v3 = v[instance]
	local character = v3 and v3.Character
	local animate = character and module:GetAnimate(character)
	local v4 = v3 and v3.Name and module.Shared.Weapons.List[v3.Name]
	local idle = v4 and v4.Render and v4.Render.Idle
	local animation = idle and module.Utils.Weapons.GetWeaponAnimation(v3.Name, idle)

	if not animate or not animation or not animation:IsA("Animation") or animate.Humanoid.Health <= 0 or character:GetAttribute("Mounted") or instance:GetAttribute("Mount") then
		Weapons2.ClearIdle(instance)
		return
	end

	if v3.Animate ~= animate then
		Weapons2.ClearIdle(instance)
		v3.Animate = animate
	end

	if not animate.CustomStateTracks.WeaponIdle then
		animate:AddCustomAnimationForState("Weapon", "Idle", {
			Animation = animation,
			Priority = Enum.AnimationPriority.Idle,
			Looped = true
		})
	end

	local walk = v4.Render.Walk
	local animation2 = walk and not animate.CustomStateTracks.WeaponWalk and module.Utils.Weapons.GetWeaponAnimation(
		v3.Name,
		walk
	)

	if animation2 then
		animate:AddCustomAnimationForState("Weapon", "Walk", {
			Animation = animation2,
			Priority = Enum.AnimationPriority.Movement,
			Looped = true
		})
	end

	local run = v4.Render.Run
	local animation3 = run and not animate.CustomStateTracks.WeaponRun and module.Utils.Weapons.GetWeaponAnimation(
		v3.Name,
		run
	)

	if animation3 then
		animate:AddCustomAnimationForState("Weapon", "Run", {
			Animation = animation3,
			Priority = Enum.AnimationPriority.Movement,
			Looped = true
		})
	end

	if v4.Render.ModelAnimations then
		local animationState = animate.Humanoid.MoveDirection.Magnitude > 0 and "Walk" or "Idle"

		if v3.AnimationState ~= animationState then
			v3.AnimationState = animationState
			animate:AddForcedState("Weapon", animationState, 2, true)
		end
	elseif v3.AnimationState then
		v3.AnimationState = nil
		animate:RemoveForcedState("Weapon")
	end
end

function Weapons2.ClearCharacter(p)
	local v3 = v[p]

	if not v3 then
		return
	end

	UltimateRunner.Clear(p)
	Weapons2.ClearIdle(p)

	if v3.Character then
		Weapons.ClearEffects(v3.Character)
	end

	if v3.Model then
		v3.Model:Destroy()
	end

	v3.Character = nil
	v3.HRP = nil
	v3.Name = nil
	v3.Model = nil
	v3.EffectsEnabled = nil
	v3.Hidden = nil
end

function Weapons2.Remove(p)
	Weapons2.ClearCharacter(p)
	v[p] = nil
end

function Weapons2.Update(player)
	local v3 = v[player]

	if not v3 then
		v3 = {}
		v[player] = v3
	end

	local value = v3.Value

	if not value or not value.Parent or value.Parent.Parent ~= replication then
		local child = replication:FindFirstChild(player.Name)
		value = child and child:FindFirstChild("Weapon")
		v3.Value = value
	end

	local name = value and value.Value
	local character = player.Character

	if v3.Character ~= character or v3.Name ~= name then
		Weapons2.ClearCharacter(player)
		v3.Character = character
		v3.Name = name
	end

	if not (character and character:IsDescendantOf(workspace)) then
		Weapons2.ClearCharacter(player)
		return
	end

	local HRP = v3.HRP

	if not HRP or HRP.Parent ~= character then
		HRP = character:FindFirstChild("HumanoidRootPart")
		v3.HRP = HRP
	end

	if name and (not v3.Model or v3.Model.Parent ~= character) then
		if v3.Model then
			Weapons2.ClearIdle(player)
			v3.Model:Destroy()
		end

		v3.Model = Weapons.CreateModel(character, name)

		if v3.Model then
			v3.EffectsEnabled = nil
			v3.Hidden = nil
		end
	end

	local mounted = character:GetAttribute("Mounted") or player:GetAttribute("Mount")
	local hidden

	if mounted == nil then
		hidden = false
	else
		hidden = mounted ~= false
	end

	local effectsEnabled = not (hidden or module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"])

	if v3.EffectsEnabled ~= effectsEnabled then
		Weapons.ClearEffects(character)
		v3.EffectsEnabled = effectsEnabled
		local v6 = name and module.Shared.Weapons.List[name]
		local effects = v6 and v6.Render and v6.Render.Effects

		if v3.Model and v6 and v6.Render then
			local setModelEffects = Weapons.SetModelEffects
			local model = v3.Model
			local v7

			if v6.Render.ModelEffects then
				v7 = effectsEnabled
			else
				v7 = not hidden
			end

			setModelEffects(model, v7)
		end

		if effectsEnabled and effects and HRP then
			for _, effect in effects do
				local clone = table.clone(effect)
				clone.Enable = true
				clone.Duration = 1e999
				clone.Weld = true
				Weapons.CreateEffect(character, name, "Equip", clone, HRP.CFrame)
			end
		end
	end

	Weapons2.UpdateIdle(player)

	if v3.Model then
		if v3.Hidden ~= hidden then
			v3.Hidden = hidden
			Weapons.SetModelVisible(v3.Model, not hidden)
		end

		if hidden or player == module.Instance then
			Weapons.UpdateModel(v3.Model, hidden)
		elseif HRP then
			local position = HRP.Position
			local currentCamera = workspace.CurrentCamera
			local v6

			if currentCamera == nil then
				v6 = false
			else
				v6 = (currentCamera.CFrame.Position - position).Magnitude <= 150
			end

			if v6 then
				Weapons.UpdateModel(v3.Model, hidden)
			end
		end
	end

	UltimateRunner.Update(player)
end

function Weapons2.Destroy()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)

	for k in v do
		Weapons2.Remove(k)
	end
end

function Weapons2.Init()
	if v2.Heartbeat then
		return
	end

	v2.Removing = module.Services.Players.PlayerRemoving:Connect(Weapons2.Remove)
	v2.Heartbeat = module.Services.RunService.Heartbeat:Connect(function()
		for _, v3 in module.Services.Players:GetPlayers() do
			Weapons2.Update(v3)
		end
	end)
end

return Weapons2