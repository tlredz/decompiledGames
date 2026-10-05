local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local Flash = require(ReplicatedStorage.Client.UI.VFX.Flash)
local Shake = require(ReplicatedStorage.Client.Shake)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local riftTradeIn = ReplicatedStorage.Assets.VFX.RiftTradeIn
local sounds = ReplicatedStorage.Assets.Sounds
local color = Color3.fromRGB(164, 255, 61)
local color2 = Color3.fromRGB(231, 255, 185)
local flag = false

local function machineParts()
	local world = Workspace:FindFirstChild("World")
	local machines = world and world:FindFirstChild("Machines")
	local riftMachine = machines and machines:FindFirstChild("RiftMachine")
	local rift = riftMachine and riftMachine:FindFirstChild("Rift")

	if not (rift and rift:IsA("Model")) then
		return nil, nil, nil, {}
	end

	local mainScreen = rift:FindFirstChild("MainScreen")
	local eggSpawn = mainScreen and mainScreen:FindFirstChild("EggSpawn")

	if not (mainScreen and mainScreen:IsA("BasePart") and eggSpawn and eggSpawn:IsA("Attachment")) then
		return nil, nil, nil, {}
	end

	local offeringSpawns = {}

	for i = 1, 3 do
		local child = rift:FindFirstChild("Pad" .. i)
		local offeringSpawn = child and child:FindFirstChild("OfferingSpawn", true)

		if offeringSpawn and offeringSpawn:IsA("Attachment") then
			table.insert(offeringSpawns, offeringSpawn)
		else
			return nil, nil, nil, {}
		end
	end

	return rift, mainScreen, eggSpawn, offeringSpawns
end

local function cue(childName: string, vector2: Vector3, volume: number?)
	local sound = sounds:FindFirstChild(childName) or sounds:FindFirstChild(childName, true)

	if not (sound and sound:IsA("Sound")) then
		sound = sound and sound:FindFirstChildWhichIsA("Sound")
	end

	if sound then
		Audio.Play(sound, vector2, {
			Volume = volume
		})
	end
end

local function freeze(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end
end

local function centerAndScale(instance, p: number)
	instance.PrimaryPart = nil
	local boundingBox, v2 = instance:GetBoundingBox()
	instance.WorldPivot = boundingBox
	local v3 = math.max(v2.X, v2.Y, v2.Z)
	instance:ScaleTo(not (v3 > 0.01) and 1 or math.clamp(p / v3, 0.05, 6))
	local _, v4 = instance:GetBoundingBox()
	return v4.Y * 0.5
end

local function offeringModel(data)
	local success, result = pcall(function()
		return EggRecords.EggModelTemplate(data.AssetCategory, data.Mutations, data.BaseMutation, data.EggSkin)
	end)

	if success and result and result:IsA("Model") then
		local clone = result:Clone()
		freeze(clone)
		return clone
	else
		local model = Instance.new("Model")
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(2, 2, 2)
		part.Material = Enum.Material.Neon
		part.Color = color
		part.Parent = model
		freeze(model)
		return model
	end
end

local function tintEffects(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
			descendant.Color = ColorSequence.new(color)
		elseif descendant:IsA("Light") then
			descendant.Color = color
		elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
			descendant.Color = color
		end
	end
end

local function tweenNumber(duration: number, p, onChanged)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local changedConnection = numberValue.Changed:Connect(onChanged)
	local tween = TweenService:Create(numberValue, TweenInfo.new(duration, p), {
		Value = 1
	})
	onChanged(0)
	tween:Play()
	tween.Completed:Wait()
	changedConnection:Disconnect()
	numberValue:Destroy()
	onChanged(1)
end

local function bezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return vector2:Lerp(vector3, p):Lerp(vector3:Lerp(vector4, p), p)
end

local v = {
	Available = function()
		local _, v2, v3, v4 = machineParts()
		return v2 ~= nil and v3 ~= nil and #v4 == 3
	end,
	IsPlaying = function()
		return flag
	end,
	Play = function(items, callback, p)
		if flag then
			task.spawn(callback)
			return
		end

		flag = true
		task.spawn(function()
			local v2 = false
			local v3 = {}
			local v4 = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function deliver()
				if not v2 then
					v2 = true
					task.spawn(callback)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function keep(clone)
				table.insert(v3, clone)
				return clone
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function remember(part)
				table.insert(v4, {
					part = part,
					color = part.Color,
					material = part.Material
				})
			end

			local success, result = pcall(function()
				local _, parent2, attachment, v7 = machineParts()
				assert(parent2 and attachment and #v7 == 3, "laboratory reveal anchors missing")
				local worldPosition = attachment.WorldPosition
				local transient = Workspace:WaitForChild("Transient")
				remember(parent2) -- equivalent call inferred; original call site unknown
				parent2.Material = Enum.Material.Neon
				local parents = {}

				for _, v8 in v7 do
					local parent = v8.Parent
					assert(parent and parent:IsA("BasePart"), "offering anchor must be under a pad part")
					table.insert(parents, parent)
					remember(parent) -- equivalent call inferred; original call site unknown
					parent.Material = Enum.Material.Neon
				end

				local pointLight = Instance.new("PointLight")
				table.insert(v3, pointLight)
				pointLight.Color = color
				pointLight.Brightness = 0
				pointLight.Range = 15
				pointLight.Parent = parent2
				local v8 = {}

				for _, v9 in v7 do
					local beam = Instance.new("Beam")
					table.insert(v3, beam)
					beam.Attachment0 = v9
					beam.Attachment1 = attachment
					beam.Color = ColorSequence.new(color)
					beam.Width0 = 0.18
					beam.Width1 = 0.32
					beam.LightEmission = 1
					beam.FaceCamera = true
					beam.Enabled = false
					beam.Parent = v9
					table.insert(v8, beam)
				end

				cue("CinematicRiser", worldPosition, 0.55)
				Shake.Play({
					Seconds = 0.45,
					Magnitude = 0.7
				})
				local v9 = {}

				for k, item in items do
					local v10 = v7[k]

					if not v10 then
						break
					end

					local model = offeringModel(item)
					table.insert(v3, model)
					model.PrimaryPart = nil
					local boundingBox, v12 = model:GetBoundingBox()
					model.WorldPivot = boundingBox
					local v13 = math.max(v12.X, v12.Y, v12.Z)
					model:ScaleTo(not (v13 > 0.01) and 1 or math.clamp(2.5 / v13, 0.05, 6))
					local _, v14 = model:GetBoundingBox()
					local v15 = v14.Y * 0.5
					local start = v10.WorldPosition + Vector3.new(0, v15 + 0.05, 0)
					local hover = start + createVector(0, 2.3, 0)
					model:PivotTo(CFrame.new(start))
					model.Parent = transient
					table.insert(v9, {
						model = model,
						start = start,
						hover = hover,
						scale = model:GetScale()
					})
					task.wait(0.12)
					cue("MechaShake", start, 0.28)
					TweenService:Create(parents[k], TweenInfo.new(0.25), {
						Color = color2
					}):Play()
					tweenNumber(0.45, Enum.EasingStyle.Back, function(p2)
						if model.Parent then
							model:PivotTo(CFrame.new(start:Lerp(hover, p2)))
						end
					end)
				end

				task.wait(0.35)

				for k, v10 in v9 do
					v8[k].Enabled = true
					cue("ImpactBoom", v10.hover, 0.38)
					local v12 = v10
					local v13 = v10.hover:Lerp(worldPosition, 0.5) + createVector(0, 1.2, 0)
					tweenNumber(0.42, Enum.EasingStyle.Quad, function(p2)
						if v12.model.Parent then
							v12.model:PivotTo(CFrame.new(bezier(v12.hover, v13, worldPosition, p2)))
							v12.model:ScaleTo(v12.scale * math.max(1 - p2 * 0.85, 0.15))
						end
					end)
					v10.model:Destroy()
					task.wait(0.15)
				end

				Flash.Play({
					Attack = 0.08,
					Decay = 0.28,
					Tint = color,
					Opacity = 0.5
				})
				Shake.Play({
					Seconds = 0.55,
					Magnitude = 1.1
				})
				TweenService:Create(parent2, TweenInfo.new(0.4), {
					Color = color
				}):Play()
				TweenService:Create(pointLight, TweenInfo.new(0.4), {
					Brightness = 4
				}):Play()
				cue("CinematicBoom", worldPosition, 0.8)
				task.wait(0.6)

				for _, v10 in v8 do
					v10.Enabled = false
				end

				local clone

				if p then
					clone = offeringModel(p)
				else
					clone = riftTradeIn.Egg:Clone()
				end

				freeze(keep(clone))

				if p == nil then
					tintEffects(clone)
				end

				clone.PrimaryPart = nil
				local boundingBox, v10 = clone:GetBoundingBox()
				clone.WorldPivot = boundingBox
				local v11 = math.max(v10.X, v10.Y, v10.Z)
				clone:ScaleTo(not (v11 > 0.01) and 1 or math.clamp(5 / v11, 0.05, 6))
				local _, v12 = clone:GetBoundingBox()
				local _ = v12.Y * 0.5
				clone.Parent = transient
				local scale = clone:GetScale()
				local _, v13 = clone:GetBoundingBox()
				local v14 = v13.Y * 0.5
				clone:ScaleTo(scale * 0.4)
				clone:PivotTo(CFrame.new(worldPosition))
				VFX.EmitTree(clone, true)
				cue("MechaHatch", worldPosition, 0.9)
				Flash.Play({
					Attack = 0.06,
					Decay = 0.4,
					Tint = color2,
					Opacity = 0.75
				})
				local character = Players.LocalPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local v15

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					v15 = (humanoidRootPart.Position - worldPosition) * createVector(1, 0, 1)
				else
					v15 = parent2.CFrame.LookVector * createVector(1, 0, 1)
				end

				local v16 = worldPosition + (not (v15.Magnitude > 0.05) and createVector(-1, 0, 0) or v15.Unit) * math.clamp(
					v15.Magnitude * 0.65,
					8,
					13
				)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					transient,
					Workspace.World.Machines.RiftMachine,
					character
				}
				local raycastResult = Workspace:Raycast(
					v16 + createVector(0, 7, 0),
					createVector(0, -80, 0),
					raycastParams
				)
				local X = v16.X
				local v17

				if raycastResult then
					v17 = raycastResult.Position.Y + v14
				else
					v17 = worldPosition.Y - 2
				end

				local vector2 = Vector3.new(X, v17, v16.Z)
				local v18 = worldPosition:Lerp(vector2, 0.5) + createVector(0, 5, 0)
				tweenNumber(0.9, Enum.EasingStyle.Quad, function(p2)
					if clone.Parent then
						clone:PivotTo(CFrame.new(bezier(worldPosition, v18, vector2, p2)) * CFrame.Angles(
							0,
							p2 * 3.141592653589793 * 3,
							0
						))
						clone:ScaleTo(scale * (0.4 + p2 * 0.6))
					end
				end)
				cue("ImpactBoom", vector2, 0.7)
				tweenNumber(0.35, Enum.EasingStyle.Quad, function(p2)
					if clone.Parent then
						clone:PivotTo(CFrame.new(vector2 + Vector3.new(0, math.sin(p2 * 3.141592653589793) * 1.2, 0)))
					end
				end)
				task.wait(0.25)
				local character2 = Players.LocalPlayer.Character
				local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 and humanoidRootPart2:IsA("BasePart") then
					local position = clone:GetPivot().Position
					tweenNumber(0.55, Enum.EasingStyle.Quad, function(p2)
						if clone.Parent then
							local character3 = Players.LocalPlayer.Character
							local humanoidRootPart3 = character3 and character3:FindFirstChild("HumanoidRootPart")
							local v19

							if humanoidRootPart3 and humanoidRootPart3:IsA("BasePart") then
								v19 = humanoidRootPart3.Position + createVector(0, 1.4, 0)
							else
								v19 = position
							end

							clone:PivotTo(CFrame.new(position:Lerp(v19, p2)))
							clone:ScaleTo(scale * (1 - p2 * 0.75))
						end
					end)
				end

				deliver() -- equivalent call inferred; original call site unknown
				task.wait(0.35)
			end)

			for _, v5 in v4 do
				if not v5.part.Parent then
					continue
				end

				v5.part.Color = v5.color
				v5.part.Material = v5.material
			end

			for _, v5 in v3 do
				if v5.Parent then
					v5:Destroy()
				end
			end

			if not success then
				warn("Laboratory sequence failed: " .. tostring(result))
			end

			deliver() -- equivalent call inferred; original call site unknown
			flag = false
		end)
	end
}
return table.freeze(v)