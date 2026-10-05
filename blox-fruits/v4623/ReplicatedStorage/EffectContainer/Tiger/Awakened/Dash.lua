local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
FX:WaitForChild("TigerEffects")
require(script.Parent.Parent.Modules.Beziers)
local TweenService = game:GetService("TweenService")

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
local geppoDash = FX2:WaitForChild("TigerEffects").GeppoDash
local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
local geppoDashAwak = FX3:WaitForChild("TigerEffects").GeppoDashAwak
return function(data)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local _ = data.RigModel
	local root = data.Root
	local Players = game:GetService("Players")
	local playerFromCharacter = Players:GetPlayerFromCharacter(root.Parent) or data.Player
	local awakened = data.Awakened

	if stage == 1 then
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 5)

		if awakened then
			local geppo = geppoDashAwak.Geppo
			local clone = geppo.Push1:Clone()
			local clone2 = geppo.Push2:Clone()
			local clone3 = geppo.RingPop1:Clone()
			Util.Sound:Play("BF_TigerFt_Jump_01", root)
			Util.SetParentOverrideWithColor(clone, root, playerFromCharacter, "LeopardFruitVFXColor")
			Util.SetParentOverrideWithColor(clone2, root, playerFromCharacter, "LeopardFruitVFXColor")
			Util.SetParentOverrideWithColor(clone3, root, playerFromCharacter, "LeopardFruitVFXColor")
			emitAll(clone)
			emitAll(clone2)
			emitAll(clone3)
			Util.Debris:AddItem(clone, 2)
			Util.Debris:AddItem(clone2, 2)
			Util.Debris:AddItem(clone3, 2)
			local clone4 = geppoDashAwak.lines:Clone()
			clone4.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone4, folder, playerFromCharacter, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone4, 2)
			local motor6D = Instance.new("Motor6D")
			Util.SetParentOverrideWithColor(motor6D, clone4, playerFromCharacter, "LeopardFruitVFXColor")
			motor6D.Part0 = root
			motor6D.Part1 = clone4
			emitAll(clone4)
		else
			local geppo = geppoDash.Geppo
			local clone = geppo.Push1:Clone()
			local clone2 = geppo.Push2:Clone()
			local clone3 = geppo.RingPop1:Clone()
			Util.Sound:Play("BF_TigerFt_Jump_01", root)
			Util.SetParentOverrideWithColor(clone, root, playerFromCharacter, "LeopardFruitVFXColor")
			Util.SetParentOverrideWithColor(clone2, root, playerFromCharacter, "LeopardFruitVFXColor")
			Util.SetParentOverrideWithColor(clone3, root, playerFromCharacter, "LeopardFruitVFXColor")
			emitAll(clone)
			emitAll(clone2)
			emitAll(clone3)
			Util.Debris:AddItem(clone, 2)
			Util.Debris:AddItem(clone2, 2)
			Util.Debris:AddItem(clone3, 2)
			local clone4 = geppoDashAwak.lines:Clone()
			clone4.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone4, folder, playerFromCharacter, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone4, 2)
			local motor6D = Instance.new("Motor6D")
			Util.SetParentOverrideWithColor(motor6D, clone4, playerFromCharacter, "LeopardFruitVFXColor")
			motor6D.Part0 = root
			motor6D.Part1 = clone4
			emitAll(clone4)
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 5)

		if awakened then
			Util.Sound:Play("BF_TigerFt_Dash_01", root)
			local clone = geppoDashAwak.Mainbeam:Clone()
			local lookVector = root.CFrame.LookVector
			local direction = data.Direction
			local unit = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
			local unit2 = Vector3.new(direction.X, 0, direction.Z).Unit
			local v = unit:Dot(unit2) > 0.8 and createVector(0, 0, 0) or unit2
			print(v)
			local cFrame = root.CFrame * CFrame.new(0, 2, 0)

			if v ~= createVector(0, 0, 0) then
				cFrame = CFrame.new(root.Position, root.Position + v) * CFrame.new(0, 2, 0)
			end

			clone.CFrame = cFrame
			clone.Anchored = true
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, playerFromCharacter, "LeopardFruitVFXColor")
			local v3 = tick() + 1.25
			task.spawn(function()
				while true do
					if v3 < tick() or not clone:IsDescendantOf(workspace) then
						break
					end

					local cFrame2 = root.CFrame * CFrame.new(0, 2, 0)

					if v ~= createVector(0, 0, 0) then
						cFrame2 = CFrame.new(root.Position, root.Position + v) * CFrame.new(0, 2, 0)
					end

					clone.CFrame = cFrame2
					task.wait()
				end
			end)
			task.spawn(function()
				for _, beam in pairs(clone:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end
				end
			end)
			Util.Debris:AddItem(clone, 1.5)
			emitAll(clone)
			local clone2 = geppoDashAwak.Dash:Clone()
			clone2.CFrame = data.Direction == createVector(0, 0, 0) and root.CFrame or CFrame.new(
				root.Position,
				root.Position + data.Direction
			)
			Util.SetParentOverrideWithColor(clone2, folder, playerFromCharacter, "LeopardFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 1)
			local clone3 = geppoDashAwak.dashlines:Clone()
			clone3.CFrame = data.Direction == createVector(0, 0, 0) and root.CFrame or CFrame.new(
				root.Position,
				root.Position + data.Direction
			)
			Util.SetParentOverrideWithColor(clone3, folder, playerFromCharacter, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone3, 1)
			local motor6D = Instance.new("Motor6D")
			motor6D.Parent = clone3
			motor6D.Part0 = root
			motor6D.Part1 = clone3
			emitAll(clone3)
		else
			Util.Sound:Play("BF_TigerFt_Dash_01", root)
			local clone = geppoDash.Dash:Clone()
			clone.CFrame = data.Direction == createVector(0, 0, 0) and root.CFrame or CFrame.new(
				root.Position,
				root.Position + data.Direction
			)
			Util.SetParentOverrideWithColor(clone, folder, playerFromCharacter, "LeopardFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 1)
			local clone2 = geppoDash.dashlines:Clone()
			clone2.CFrame = data.Direction == createVector(0, 0, 0) and root.CFrame or CFrame.new(
				root.Position,
				root.Position + data.Direction
			)
			Util.SetParentOverrideWithColor(clone2, folder, playerFromCharacter, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone2, 1)
			local motor6D = Instance.new("Motor6D")
			motor6D.Parent = clone2
			motor6D.Part0 = root
			motor6D.Part1 = clone2
			emitAll(clone2)
		end
	end
end