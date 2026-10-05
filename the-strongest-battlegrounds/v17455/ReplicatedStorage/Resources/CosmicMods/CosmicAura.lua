local createVector = vector.create
local CosmicAura = {}
local currentCamera = workspace.CurrentCamera
local auraAssets = script.AuraAssets
game:GetService("CollectionService")
local AssetService = game:GetService("AssetService")

local function meshPartFromAssetId(p: number)
	local success, result = pcall(function()
		return AssetService:CreateMeshPartAsync(Content.fromAssetId(p), {
			RenderFidelity = Enum.RenderFidelity.Precise,
			CollisionFidelity = Enum.CollisionFidelity.Box,
			FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
		})
	end)

	if success then
		return result
	end

	return nil
end

Random.new()
game:GetService("RunService")
local library = require(game.ReplicatedStorage.library)
local playTween = library.PlayTween
local _ = library.RaiseZIndex
local v = {}

local function cleanupTask(connection)
	if not connection then
		return
	end

	if typeof(connection) == "RBXScriptConnection" then
		pcall(function()
			connection:Disconnect()
		end)
	elseif type(connection) == "thread" then
		pcall(function()
			task.cancel(connection)
		end)
	elseif typeof(connection) == "Instance" then
		pcall(function()
			connection:Destroy()
		end)
	elseif type(connection) == "function" then
		pcall(connection)
	elseif type(connection) == "table" then
		if type(connection.Disconnect) == "function" then
			pcall(function()
				connection:Disconnect()
			end)
		elseif type(connection.Destroy) == "function" then
			pcall(function()
				connection:Destroy()
			end)
		end
	end
end

local function cleanupState(state)
	if not state or state.cleaned then
		return
	end

	state.cleaned = true
	state.alive = false

	if state.character and v[state.character] == state then
		v[state.character] = nil
	end

	local clean = state.clean
	state.clean = {}

	for _, v2 in pairs(clean) do
		cleanupTask(v2)
	end

	if state.weldUpdate then
		local weldUpdate = state.weldUpdate
		state.weldUpdate = nil
		task.delay(1.1, function()
			if weldUpdate then
				weldUpdate:Disconnect()
			end
		end)
	end
end

local function rememberCharacterState(state, folder)
	state.basePartState = state.basePartState or {}
	state.decalState = state.decalState or {}

	for k in pairs(state.basePartState) do
		if k and k.Name == "HumanoidRootPart" then
			state.basePartState[k] = nil
		end
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" and state.basePartState[descendant] == nil then
			local collisionGroup = nil
			local v2 = descendant
			pcall(function()
				collisionGroup = v2.CollisionGroup
			end)
			state.basePartState[descendant] = {
				Transparency = descendant.Transparency,
				CanCollide = descendant.CanCollide,
				CanTouch = descendant.CanTouch,
				CanQuery = descendant.CanQuery,
				Massless = descendant.Massless,
				CollisionGroup = collisionGroup
			}
		elseif descendant:IsA("Decal") and state.decalState[descendant] == nil then
			state.decalState[descendant] = {
				Transparency = descendant.Transparency
			}
		end
	end
end

local function restoreCharacterState(p, folder)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(folder)

	if folder then
		local _ = folder.Parent
	end

	if playerFromCharacter then
		local _ = playerFromCharacter.Character
	end

	if playerFromCharacter then
		local _ = playerFromCharacter.Character == folder
	end

	if p and p.basePartState then
		local count = 0

		for _ in pairs(p.basePartState) do
			count += 1
		end

		local torso = folder and folder:FindFirstChild("Torso")
		local head = folder and folder:FindFirstChild("Head")

		if torso then
			local _ = torso.Transparency
			local _ = torso.LocalTransparencyModifier
			local _ = p.basePartState[torso] == nil
		end

		if head then
			local _ = head.Transparency
			local _ = head.LocalTransparencyModifier
			local _ = p.basePartState[head] == nil
		end

		local transparencyChangedConnection = nil

		if torso then
			transparencyChangedConnection = torso:GetPropertyChangedSignal("Transparency"):Connect(function()
				local _ = torso.Transparency
				local _ = "\n" .. debug.traceback()
			end)
			task.delay(2, function()
				if transparencyChangedConnection then
					transparencyChangedConnection:Disconnect()
				end
			end)
		end

		for k, v2 in pairs(p.basePartState) do
			if not (k and k.Parent) then
				continue
			end

			k.Transparency = v2.Transparency
			k.CanCollide = v2.CanCollide
			k.CanTouch = v2.CanTouch
			k.CanQuery = v2.CanQuery
			k.Massless = v2.Massless

			if not v2.CollisionGroup then
				continue
			end

			local v3 = k
			local v4 = v2
			pcall(function()
				v3.CollisionGroup = v4.CollisionGroup
			end)
		end

		if torso then
			local _ = torso.Transparency
			local _ = torso.LocalTransparencyModifier
		end

		if head then
			local _ = head.Transparency
			local _ = head.LocalTransparencyModifier
		end

		task.delay(0.5, function()
			if torso and torso.Parent then
				local _ = torso.Transparency
				local _ = torso.LocalTransparencyModifier
			end

			if head and head.Parent then
				local _ = head.Transparency
				local _ = head.LocalTransparencyModifier
			end
		end)
		task.delay(1.2, function()
			if torso and torso.Parent then
				local _ = torso.Transparency
				local _ = torso.LocalTransparencyModifier
			end

			if head and head.Parent then
				local _ = head.Transparency
				local _ = head.LocalTransparencyModifier
			end
		end)
	end

	local humanoidRootPart = folder and folder:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		humanoidRootPart.Transparency = 1
	end

	if p and p.decalState then
		for k, v2 in pairs(p.decalState) do
			if k and k.Parent then
				k.Transparency = v2.Transparency
			end
		end
	else
		local v2 = {
			"Left Arm",
			"Right Arm",
			"Left Leg",
			"Right Leg",
			"Torso"
		}

		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" or string.match(
				string.lower(part.Name),
				"hitbox"
			) then
				continue
			end

			if not (tostring(part) ~= "FakeHead" and table.find(v2, (tostring(part)))) then
				continue
			end

			part.Transparency = 0
		end

		local head = folder:FindFirstChild("Head")

		if head then
			for _, decal in pairs(head:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Transparency = 0
				end
			end
		end
	end
end

local function applyNoPhysics(part)
	if part and part:IsA("BasePart") then
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		pcall(function()
			part.CollisionGroup = "nocol"
		end)
		pcall(function()
			part.RootPriority = -127
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeWeldSafe(part)
	if part and part:IsA("BasePart") then
		part.Anchored = false
		applyNoPhysics(part)
	end
end

local function removeHighlightJoint(instance)
	if not instance or instance.Name == "HL_Weld" then
		return
	end

	if instance:IsA("JointInstance") or instance:IsA("Constraint") or instance:IsA("WeldConstraint") then
		instance:Destroy()
	end
end

local function makeHighlightWeldSafe(part)
	if not part then
		return
	end

	if part:IsA("BasePart") and part and part:IsA("BasePart") then
		part.Anchored = false
		applyNoPhysics(part)
	end

	for _, descendant in ipairs(part:GetDescendants()) do
		if descendant:IsA("BasePart") then
			makeWeldSafe(descendant) -- equivalent call inferred; original call site unknown
		elseif descendant and descendant.Name ~= "HL_Weld" and (descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("WeldConstraint")) then
			descendant:Destroy()
		end
	end
end

local function GetAssetId(meshId)
	if not meshId then
		return nil
	end

	local v2 = 0
	local v3 = nil

	for k in tostring(meshId):gmatch("%d+") do
		if not (v2 < #k) then
			continue
		end

		v2 = #k
		v3 = k
	end

	return v3 and tonumber(v3) or nil
end

function CosmicAura.On(p)
	local char = p.Char
	local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(char)
	local basePartState = v[char] and v[char].basePartState
	local decalState = v[char] and v[char].decalState

	if v[char] then
		CosmicAura.Off({
			Char = char
		})
	end

	local v2 = {
		character = char,
		clean = {},
		alive = true,
		cleaned = false,
		basePartState = basePartState or {},
		decalState = decalState or {}
	}
	v[char] = v2
	rememberCharacterState(v2, char)

	local function AuraOn()
		local folder = Instance.new("Folder")
		folder.Name = "CosmicStuff"
		folder.Parent = game.Workspace.Thrown
		v2.folder = folder
		local thread = task.delay(100, function()
			if v[char] == v2 and folder and folder.Parent then
				CosmicAura.Off({
					Char = char
				})
			end
		end)
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "CosmicValue"
		objectValue.Value = folder
		objectValue.Parent = char
		v2.cosmicValue = objectValue
		local clean = v2.clean
		table.insert(clean, thread)
		table.insert(clean, (folder:GetPropertyChangedSignal("Parent"):Connect(function()
			if not folder.Parent then
				CosmicAura.Off({
					Char = char
				})
			end
		end)))
		local model = Instance.new("Model")
		model.Name = "Accessories"
		model.Parent = folder
		local objectValue2 = Instance.new("ObjectValue")

		local function sort(instance)
			for _, child in pairs(instance:GetChildren()) do
				if child:IsA("BasePart") then
					local v3 = child
					task.delay(0.9, function()
						if v2.alive and objectValue.Parent then
							v3.Transparency = 1
						end
					end)
				elseif child:IsA("Accessory") then
					local handle = child:FindFirstChild("Handle")

					if handle then
						local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

						if specialMesh then
							if v2.alive and objectValue.Parent then
								handle.Transparency = 1
							end

							local assetId = GetAssetId(specialMesh.MeshId)
							local success, result = pcall(function()
								return AssetService:CreateMeshPartAsync(Content.fromAssetId(assetId), {
									RenderFidelity = Enum.RenderFidelity.Precise,
									CollisionFidelity = Enum.CollisionFidelity.Box,
									FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
								})
							end)

							if not success then
								result = nil
							end

							if result then
								local X = specialMesh.Scale.X
								result.CanCollide = false
								result.CanQuery = false
								result.CanTouch = false
								result.Anchored = false
								result.Massless = true
								result.CollisionGroup = "nocol"
								result.Size *= X
								result.Material = Enum.Material.Neon
								result.Name = child.Name
								result.Color = Color3.new(0, 0, 0)
								result.CFrame = handle.CFrame
								result.Parent = model
								local weld = Instance.new("Weld")
								weld.Part0 = result
								weld.Part1 = handle
								weld.Parent = result
								result.Transparency = 0

								for _, child2 in pairs(auraAssets.TextureList:GetChildren()) do
									local clone = child2:Clone()
									clone.Parent = result

									if clone:IsA("Texture") then
										clone.Transparency = 0
									end
								end
							end
						end
					end
				end
			end
		end

		sort(char)
		local fakeHead = char:FindFirstChild("FakeHead")

		if fakeHead then
			sort(fakeHead)
		end

		for _, decal in pairs(char.Head:GetChildren()) do
			if decal:IsA("Decal") then
				decal.Transparency = 1
			end
		end

		table.insert(clean, objectValue2)
		local meshIds = {}
		local v3 = {}

		for _, child in pairs(char:GetChildren()) do
			if child.Name == "CharacterMesh" then
				meshIds[string.split(tostring(child.BodyPart), ".")[3]] = tostring(child.MeshId)
			end
		end

		local v4 = {
			["Right Arm"] = "RightArm",
			["Left Arm"] = "LeftArm",
			["Right Leg"] = "RightLeg",
			["Left Leg"] = "LeftLeg",
			Torso = "Torso",
			Head = "Head"
		}
		local specialMesh = char:WaitForChild("Head"):FindFirstChildOfClass("SpecialMesh")
		local head = specialMesh.MeshId ~= "" and specialMesh.MeshId ~= "0" and GetAssetId(specialMesh.MeshId)

		if head then
			meshIds.Head = head
		end

		local clone = auraAssets.BlackBody:Clone()
		local clone2 = auraAssets.Aura:Clone()

		for _, child in pairs(clone:GetChildren()) do
			local child2 = char:FindFirstChild(child.Name)

			if child2 then
				local v6 = v4[child.Name]

				if v6 and meshIds[v6] and meshIds[v6] ~= 0 then
					local v8 = meshIds[v6]
					local success, result = pcall(function()
						return AssetService:CreateMeshPartAsync(Content.fromAssetId(v8), {
							RenderFidelity = Enum.RenderFidelity.Precise,
							CollisionFidelity = Enum.CollisionFidelity.Box,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if not success then
						result = nil
					end

					if result then
						result.Massless = true
						result.CollisionGroup = "nocol"
						result.CanQuery = false
						result.CanTouch = false
						result.CanCollide = false
						result.Anchored = true
						result.Material = Enum.Material.Neon
						result.Name = child.Name
						result.Color = Color3.new(0, 0, 0)
						result.CFrame = humanoidRootPart.CFrame
						result.Parent = clone

						for _, child3 in pairs(child:GetChildren()) do
							child3.Parent = result

							if child3:IsA("Motor6D") then
								child3.Part0 = result
							else
								child3:IsA("Texture")
							end
						end

						local _ = result.Name == "Head"

						if result.Name == "Torso" then
							for _, child3 in pairs(clone:GetChildren()) do
								if child3.Name == "Plane" then
									child3.Transparency = 1
								end
							end

							folder:SetAttribute("NotR6", true)
						end

						if result.Name == "Head" then
							clone.Head.Transparency = 0.99
						end

						if result.Name == "Right Arm" then
							clone["Cube.002"]:Destroy()
						end

						if result.Name == "Left Arm" then
							clone["Cube.001"]:Destroy()
						end

						child:Destroy()
						child = result
					end
				end

				local weld = Instance.new("Weld")
				weld.Part0 = child
				weld.C0 = CFrame.new(0, 0, 0)
				weld.Part1 = child2
				weld.Parent = child
				child.Material = Enum.Material.Neon
				child.Massless = true
				child.CanQuery = false
				child.CanTouch = false
				child.Anchored = false
				child.CanCollide = false
				child.CollisionGroup = "nocol"
				local part = child2
				task.delay(0.9, function()
					if v2.alive and objectValue.Parent then
						part.Transparency = 1
					end
				end)
			end

			for _, texture in pairs(child:GetChildren()) do
				texture:IsA("Texture")
			end

			local _ = child.Transparency == 1
			task.delay(1.5, function()
				char.Head.Transparency = 0.98
				local decal = char.Head:FindFirstChildOfClass("Decal")

				if decal then
					decal.Transparency = 1
				end

				wait(0.5)
				char.Head.Transparency = 0.99
			end)
		end

		clone.Parent = folder
		task.spawn(function()
			if not v2.alive then
				return
			end

			for _, part in pairs(clone2:GetChildren()) do
				local child = char:FindFirstChild(part.Name)

				if not (child and part:IsA("BasePart")) then
					continue
				end

				part.CanCollide = false
				part.Massless = true
				part.CanQuery = false
				part.CanTouch = false
				part.CollisionGroup = "nocol"
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.C0 = CFrame.new(0, 0, 0)
				weld.Part1 = child
				weld.Parent = part
			end

			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart
			weld.C0 = CFrame.new(0, 0, 0)
			weld.Part1 = clone2.Wider
			weld.Parent = humanoidRootPart
			table.insert(clean, weld)

			if not (v2.alive and folder.Parent) then
				clone2:Destroy()
				return
			end

			clone2.Parent = folder

			for _, effect in ipairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") and effect.TimeScale < 0.7 then
					local timeScale = effect.TimeScale
					effect.TimeScale = 0
					local TweenService = game:GetService("TweenService")
					TweenService:Create(effect, TweenInfo.new(2), {
						TimeScale = timeScale
					}):Play()
				elseif effect:IsA("Beam") then
					local transparency = effect.Transparency
					effect.Transparency = NumberSequence.new(1)
					playTween(effect, {
						Time = 1,
						EasingStyle = "Sine",
						Goal = {
							Transparency = transparency
						}
					})
				end
			end
		end)
		task.spawn(function()
			if not v2.alive then
				return
			end

			local clone3 = auraAssets.Constellations:Clone()

			for _, part in pairs(clone3:GetChildren()) do
				local child = char:FindFirstChild(part.Name)

				if not (child and part:IsA("BasePart")) then
					continue
				end

				part.CanCollide = false
				part.Massless = true
				part.CanQuery = false
				part.CanTouch = false
				part.CollisionGroup = "nocol"
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.C0 = CFrame.new(0, 0, 0)
				weld.Part1 = child
				weld.Parent = part
			end

			for _, beam in pairs(clone3:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local transparency = beam.Transparency
				beam.Transparency = NumberSequence.new(1)
				playTween(beam, {
					Time = 1,
					EasingStyle = "Sine",
					Goal = {
						Transparency = transparency
					}
				})
			end

			if not (v2.alive and folder.Parent) then
				clone3:Destroy()
				return
			end

			clone3.Parent = folder
			local v6 = {}

			for _, descendant in ipairs(clone3:GetDescendants()) do
				if descendant.Name == "Constellation" then
					table.insert(v6, {
						Attachment = descendant,
						BasePosition = descendant.Position,
						CurrentOffset = createVector(0, 0, 0),
						PhaseOffset = math.random() * 3.141592653589793 * 2,
						LagOffset = createVector(0, 0, 0)
					})
				end
			end

			local cFrame = humanoidRootPart.CFrame
			local random = Random.new()
			local total = 0
			local total2 = 1

			for _, v7 in ipairs(v6) do
				v7.WobbleSpeed = 0.5 * (0.7 + random:NextNumber() * 0.6)
				v7.WobbleAmplitude = 0.15 * (0.8 + random:NextNumber() * 0.4)
				v7.XFreqMult = 0.4 + random:NextNumber() * 0.2
				v7.YFreqMult = 1.1 + random:NextNumber() * 0.4
				v7.ZFreqMult = 0.5 + random:NextNumber() * 0.4
			end

			table.insert(v3, function(p2)
				if not (v2.alive and clone3.Parent) then
					return
				end

				local now = tick()
				local cFrame2 = humanoidRootPart.CFrame
				local v7 = cFrame2.Position - cFrame.Position
				local vectorToObjectSpace = cFrame2:VectorToObjectSpace(v7)
				local vector2 = Vector3.new(
					vectorToObjectSpace.X * 0.15,
					vectorToObjectSpace.Y * 0.15 * 0.1,
					vectorToObjectSpace.Z * 0.15
				)
				local v8 = Vector3.new(v7.X, 0, v7.Z).Magnitude / p2
				local v9 = vectorToObjectSpace.Z / p2
				local v10, v11

				if v9 < -1 then
					v10 = 0.1
					v11 = 35
				elseif v9 > 1 then
					v10 = 0.05
					v11 = 25
				else
					v10 = 0.1
					v11 = 35
				end

				local v12 = 1 - math.exp(-p2 / v10)
				total += (v9 - total) * v12
				local v13 = v8 < 2 and 1 or 0
				local v14 = 1 - math.exp(-p2 * 5)
				total2 += (v13 - total2) * v14

				for _, v15 in ipairs(v6) do
					local attachment = v15.Attachment
					local basePosition = v15.BasePosition

					if not attachment then
						continue
					end

					v15.LagOffset += vector2

					if v15.LagOffset.Magnitude > 1 then
						v15.LagOffset = v15.LagOffset.Unit * 1
					end

					local v16 = 1 - math.exp(-p2 * 10)
					v15.LagOffset = v15.LagOffset:Lerp(createVector(0, 0, 0), v16)
					local v17 = now * v15.WobbleSpeed + v15.PhaseOffset
					local wobbleAmplitude = v15.WobbleAmplitude
					local v18 = basePosition + Vector3.new(
						math.sin(v17 * v15.XFreqMult) * wobbleAmplitude * 0.5,
						math.sin(v17 * v15.YFreqMult) * wobbleAmplitude,
						math.cos(v17 * v15.ZFreqMult) * wobbleAmplitude * 0.5
					) * total2 + v15.LagOffset
					local v19 = 1 - math.exp(-p2 * v11)
					v15.CurrentOffset = v15.CurrentOffset:Lerp(v18, v19)
					attachment.Position = v15.CurrentOffset
				end

				cFrame = cFrame2
			end)
		end)
		local v6 = {}
		local _ = {
			Front = createVector(0, 0, -1),
			Back = createVector(0, 0, 1),
			Left = createVector(-1, 0, 0),
			Right = createVector(1, 0, 0),
			Top = createVector(0, 1, 0),
			Bottom = createVector(0, -1, 0)
		}
		local v7 = {
			Front = {
				rx = 1,
				lz = 0,
				uy = -1,
				lzY = 0
			},
			Back = {
				rx = -1,
				lz = 0,
				uy = -1,
				lzY = 0
			},
			Left = {
				rx = 0,
				lz = -1,
				uy = -1,
				lzY = 0
			},
			Right = {
				rx = 0,
				lz = 1,
				uy = -1,
				lzY = 0
			},
			Top = {
				rx = 1,
				lz = 0,
				uy = 0,
				lzY = -1
			},
			Bottom = {
				rx = 1,
				lz = 0,
				uy = 0,
				lzY = 1
			}
		}

		local function registerTexture(texture)
			local face = texture:GetAttribute("Face") or tostring(texture.Face)
			local v8 = Enum.NormalId[face]

			if not v8 then
				return
			end

			table.insert(v6, {
				texture = texture,
				map = v7[v8.Name]
			})
		end

		local function collectScrollTextures()
			table.clear(v6)

			for _, texture in pairs(clone:GetDescendants()) do
				if not (texture:IsA("Texture") and (texture:IsDescendantOf(clone) or texture:IsDescendantOf(model))) then
					continue
				end

				registerTexture(texture)
			end

			for _, texture in pairs(model:GetDescendants()) do
				if not (texture:IsA("Texture") and (texture:IsDescendantOf(clone) or texture:IsDescendantOf(model))) then
					continue
				end

				registerTexture(texture)
			end
		end

		collectScrollTextures()
		local now = os.clock()
		local clone3 = auraAssets.HighLight:Clone()
		clone3.Parent = folder
		v2.highlightModel = clone3
		makeHighlightWeldSafe(clone3)
		table.insert(clean, clone3.DescendantAdded:Connect(function(instance)
			if instance:IsA("BasePart") then
				makeWeldSafe(instance) -- equivalent call inferred; original call site unknown
			elseif instance then
				if instance.Name == "HL_Weld" then
					return
				end

				if instance:IsA("JointInstance") or instance:IsA("Constraint") or instance:IsA("WeldConstraint") then
					instance:Destroy()
				end
			end
		end))
		local handlesByClone = {}
		local v8 = {}
		local v9 = {}
		local v10 = {
			"Glow",
			"fire3",
			"Debris",
			"Debris1"
		}
		local total = 0
		local total2 = 0
		local v11 = 0
		local v12 = {
			"Head",
			"Torso",
			"Left Arm",
			"Right Arm",
			"Left Leg",
			"Right Leg"
		}

		for _, child in pairs(model:GetChildren()) do
			local child2 = char:FindFirstChild(child.Name)

			for _, accessory in pairs(char:GetChildren()) do
				if not accessory:IsA("Accessory") then
					continue
				end

				local handle = accessory:FindFirstChild("Handle")

				if not (handle and GetAssetId(handle:FindFirstChildOfClass("SpecialMesh").MeshId) == GetAssetId(child.MeshId)) then
					continue
				end

				child2 = accessory
			end

			if fakeHead and not child2 then
				for _, accessory in pairs(fakeHead:GetChildren()) do
					if not accessory:IsA("Accessory") then
						continue
					end

					local handle = accessory:FindFirstChild("Handle")

					if not (handle and GetAssetId(handle:FindFirstChildOfClass("SpecialMesh").MeshId) == GetAssetId(child.MeshId)) then
						continue
					end

					child2 = accessory
				end
			end

			if not (child2 and child2:FindFirstChild("Handle")) then
				continue
			end

			local clone4 = child:Clone()
			clone4:ClearAllChildren()
			clone4.Anchored = false
			clone4.Color = Color3.new(1, 1, 1)
			clone4.Parent = clone3
			clone4.Size *= 1.05
			makeWeldSafe(clone4) -- equivalent call inferred; original call site unknown
			handlesByClone[clone4] = child2.Handle
		end

		local v13 = {}
		task.spawn(function()
			local lastTime = tick()

			while v2.alive and clone3.Parent and tick() - lastTime < 3 do
				for _, v14 in pairs(v8) do
					if table.find(v13, v14) then
						continue
					end

					local clone4 = v14:Clone()
					clone4:ClearAllChildren()
					clone4.Anchored = false
					clone4.Color = Color3.new(1, 1, 1)
					clone4.Parent = clone3
					makeWeldSafe(clone4) -- equivalent call inferred; original call site unknown
					local v16 = v14
					local sizeChangedConnection = v14:GetPropertyChangedSignal("Size"):Connect(function()
						if v2.alive and clone4.Parent then
							clone4.Size = v16.Size * 1.05
						end
					end)
					local v17 = clone4
					local v18 = v14
					local transparencyChangedConnection = v14:GetPropertyChangedSignal("Transparency"):Connect(function()
						if v2.alive and v17.Parent then
							v17.Transparency = v18.Transparency
						end
					end)
					table.insert(clean, sizeChangedConnection)
					table.insert(clean, transparencyChangedConnection)
					clone4.Size *= 1.05
					v9[clone4] = v14
					table.insert(v13, v14)
				end

				task.wait(0.1)
			end
		end)

		for _, part in clone3:GetChildren() do
			local surfaceGui = part:IsA("BasePart") and (part:FindFirstChildOfClass("SurfaceGui") or part:FindFirstChildOfClass("Decal"))

			if surfaceGui then
				surfaceGui.ZOffset = -10
			end

			local v14 = v4[part.Name]

			if not (v14 and meshIds[v14] and meshIds[v14] ~= 0) then
				continue
			end

			local v16 = meshIds[v14]
			local success, result = pcall(function()
				return AssetService:CreateMeshPartAsync(Content.fromAssetId(v16), {
					RenderFidelity = Enum.RenderFidelity.Precise,
					CollisionFidelity = Enum.CollisionFidelity.Box,
					FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
				})
			end)

			if not success then
				result = nil
			end

			if not result then
				continue
			end

			result.CanCollide = false
			result.Anchored = false
			result.Massless = true
			result.CanQuery = false
			result.CanTouch = false
			result.CollisionGroup = "nocol"
			result.Material = Enum.Material.Neon
			result.Name = part.Name
			result.Color = Color3.new(1, 1, 1)
			result.CFrame = humanoidRootPart.CFrame
			result.Parent = clone3

			for _, motor6D in pairs(part:GetChildren()) do
				motor6D.Parent = result

				if motor6D:IsA("Motor6D") then
					motor6D.Part0 = result
				end
			end

			makeHighlightWeldSafe(result)

			if result.Name == "Torso" then
				for _, child in pairs(clone3:GetChildren()) do
					if child.Name == "Plane" then
						child.Transparency = 1
					end
				end

				folder:SetAttribute("NotR6", true)
			end

			if result.Name == "Right Arm" then
				clone3["Cube.002"]:Destroy()

				for _, descendant in pairs(clone2["Right Arm"]:GetDescendants()) do
					if table.find(v10, descendant.Name) then
						descendant.Enabled = false
					end
				end
			end

			if result.Name == "Left Arm" then
				clone3["Cube.001"]:Destroy()

				for _, descendant in pairs(clone2["Left Arm"]:GetDescendants()) do
					if table.find(v10, descendant.Name) then
						descendant.Enabled = false
					end
				end
			end

			part:Destroy()
		end

		for _, part in pairs(clone3:GetChildren()) do
			if not (part:IsA("BasePart") and part and part:IsA("BasePart")) then
				continue
			end

			part.Anchored = false
			applyNoPhysics(part)
		end

		table.insert(v3, function()
			local now2 = os.clock()
			local v14 = now2 - now
			now = now2
			local cFrame = currentCamera.CFrame
			local X = cFrame.RightVector.X
			local Z = cFrame.LookVector.Z
			local Y = cFrame.UpVector.Y
			local v15 = math.clamp(
				((currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude - 2) / 13,
				0,
				1
			)
			local v16 = v15 * -2 + 8
			local v17 = (v15 * 0.9 + 0.1) * 0.1
			total += v17 * v14
			total2 += v17 * v14 * 0.5

			if math.abs(v16 - v11) > 0.03 then
				v11 = v16

				for _, v18 in ipairs(v6) do
					v18.texture.StudsPerTileU = v16
					v18.texture.StudsPerTileV = v16
				end
			end

			for _, v18 in ipairs(v6) do
				local texture = v18.texture
				local map = v18.map
				local v19 = 1 * texture.ZIndex
				texture.OffsetStudsU = total + (map.rx * X + map.lz * Z) * v19
				texture.OffsetStudsV = total2 + (map.uy * Y + map.lzY * Z) * v19
			end
		end)

		local function computeDesiredHighlightCF(instance, vector2: Vector3, p2: number, p3: number)
			local v14 = instance.Position - vector2
			local unit = (v14.Magnitude < 1e-6 and createVector(0, 0, 1) or v14).Unit
			local vectorToWorldSpace = CFrame.fromAxisAngle(createVector(0, 1, 0), p2):VectorToWorldSpace(unit)
			local v15 = instance.Position + vectorToWorldSpace * p3
			return CFrame.new(v15) * (instance.CFrame - instance.Position)
		end

		local function getOrCreateHighlightWeld(instance, part)
			makeWeldSafe(instance) -- equivalent call inferred; original call site unknown
			local hL_Weld = instance:FindFirstChild("HL_Weld")

			if hL_Weld and hL_Weld:IsA("Weld") then
				hL_Weld.Part0 = part
				hL_Weld.Part1 = instance
				hL_Weld.C1 = CFrame.new()
				return hL_Weld
			else
				local weld = Instance.new("Weld")
				weld.Name = "HL_Weld"
				weld.Part0 = part
				weld.Part1 = instance
				weld.C0 = CFrame.new()
				weld.C1 = CFrame.new()
				weld.Parent = instance
				return weld
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateHighlightViaWeld(part, part2, position: Vector3, p2: number, p3: number)
			local highlightWeld = getOrCreateHighlightWeld(part, part2)
			local v14 = computeDesiredHighlightCF(part2, position, p2, p3)
			highlightWeld.C0 = part2.CFrame:ToObjectSpace(v14)
		end

		local _ = Enum.RenderPriority.Last.Value

		-- equivalent calls inferred from this helper; original call sites unknown
		local function flatUnit(lookVector: Vector3)
			local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

			if vector2.Magnitude < 1e-6 then
				return createVector(0, 0, 1)
			end

			return vector2.Unit
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function expAlpha(dt: number, p2: number)
			return 1 - math.exp(-p2 * dt)
		end

		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function smoothstep(p2: number)
			return p2 * p2 * (3 - p2 * 2)
		end

		local vector2 = nil
		local total3 = 0
		local localTransparencyModifiers = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ensureBase(p2)
			if localTransparencyModifiers[p2] == nil then
				localTransparencyModifiers[p2] = p2.LocalTransparencyModifier
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyFadeToPart(part, p2: number)
			ensureBase(part) -- equivalent call inferred; original call site unknown
			part.LocalTransparencyModifier = math.clamp(localTransparencyModifiers[part] + p2, 0, 1)
		end

		local RunService = game:GetService("RunService")
		v2.weldUpdate = RunService.RenderStepped:Connect(function(dt)
			if not clone3.Parent then
				return
			end

			if not (char and char.Parent) then
				char = playerFromCharacter.Character

				if not char then
					return
				end
			end

			local cFrame = currentCamera.CFrame
			local position = cFrame.Position

			for _, childName in ipairs(v12) do
				local part = char:FindFirstChild(childName)
				local part2 = clone3:FindFirstChild(childName)

				if not (part and part2 and part:IsA("BasePart") and part2:IsA("BasePart")) then
					continue
				end

				updateHighlightViaWeld(part2, part, position, 0.08726646259971647, 0.6) -- equivalent call inferred; original call site unknown
			end

			for part, part2 in pairs(handlesByClone) do
				if not (part and part2 and part:IsA("BasePart") and part2:IsA("BasePart")) then
					continue
				end

				updateHighlightViaWeld(part, part2, position, 0.08726646259971647, 0.6) -- equivalent call inferred; original call site unknown
			end

			for part, part2 in pairs(v9) do
				if not (part and part2 and part:IsA("BasePart") and part2:IsA("BasePart")) then
					continue
				end

				updateHighlightViaWeld(part, part2, position, 0.08726646259971647, 0.6) -- equivalent call inferred; original call site unknown
			end

			if v2.alive then
				local v14 = flatUnit(cFrame.LookVector) -- equivalent call inferred; original call site unknown

				if vector2 then
					local v15 = math.acos((math.clamp(vector2:Dot(v14), -1, 1))) / math.max(dt, 0.004166666666666667)
					local v16 = 1 - math.exp(dt * -25)
					total3 += (v15 - total3) * v16
				else
					total3 = 0
				end

				vector2 = v14
				local v16 = smoothstep(math.clamp((total3 - 9.42477796076938) / 37.69911184307752, 0, 1))
				local highlightFade = v2.highlightFade or 0
				local v17 = expAlpha(dt, highlightFade < v16 and 40 or 1) -- equivalent call inferred; original call site unknown
				local highlightFade2 = highlightFade + (v16 - highlightFade) * v17
				v2.highlightFade = highlightFade2

				for _, part in ipairs(clone3:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					applyFadeToPart(part, highlightFade2) -- equivalent call inferred; original call site unknown
				end

				for _, v19 in pairs(v3) do
					v19(dt)
				end
			end
		end)
		table.insert(clean, (char:GetPropertyChangedSignal("Parent"):Connect(function()
			if not char.Parent then
				CosmicAura.Off({
					Char = char
				})
			end
		end)))
		table.insert(clean, (humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if humanoid.Health <= 0 then
				CosmicAura.Off({
					Char = char
				})
			end
		end)))
	end

	shared.sfx({
		SoundId = "rbxassetid://120982287598800",
		Parent = char.Torso,
		Volume = 0.2,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		RollOffMaxDistance = 85,
		Looped = true,
		Name = "aurasfxcosmic"
	}):Play()
	AuraOn(char)
	char.Head.Transparency = 0.98
	local decal = char.Head:FindFirstChildOfClass("Decal")

	if decal then
		decal.Transparency = 1
	end

	if v[char] ~= v2 then
		return
	end

	local childAddedConnection = char.ChildAdded:Connect(function(child)
		if tostring(child) == "CancelUltimate" then
			CosmicAura.Off({
				Char = char
			})
		end
	end)
	table.insert(v2.clean, childAddedConnection)
end

function CosmicAura.Off(p)
	local char = p.Char

	local function AuraOff()
		local v2 = v[char]
		local cosmicValue = char:FindFirstChild("CosmicValue")
		local folder = v2 and v2.folder
		cleanupState(v2)

		for _, sound in pairs(char:GetDescendants()) do
			if not (sound:IsA("Sound") and sound.Name == "aurasfxcosmic") then
				continue
			end

			local TweenService = game:GetService("TweenService")
			TweenService:Create(sound, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Volume = 0
			}):Play()
			game.Debris:AddItem(sound, 2)
		end

		if cosmicValue then
			folder = cosmicValue.Value or folder
			cosmicValue:Destroy()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function doRestore()
			if not char then
				return
			end

			local v3 = v[char]

			if v3 and v3 ~= v2 then
				return
			end

			restoreCharacterState(v2, char)
		end

		if folder and folder.Parent then
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Texture") or descendant:IsA("Decal") then
					local TweenService = game:GetService("TweenService")
					TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
					local TweenService = game:GetService("TweenService")
					TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 1
					}):Play()
				elseif descendant:IsA("Beam") then
					playTween(descendant, {
						Time = 1,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
					game.Debris:AddItem(descendant, 1)
				end
			end

			task.delay(1.1, function()
				if folder and folder.Parent then
					folder:Destroy()
				end

				doRestore() -- equivalent call inferred; original call site unknown
			end)
		else
			task.delay(0.06, doRestore)
		end
	end

	AuraOff(char)
end

return CosmicAura