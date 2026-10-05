local AssetService = game:GetService("AssetService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local controllers = ReplicatedStorage.Controllers
require(controllers.PlayerController)
local datas = ReplicatedStorage.Datas
local Mutations = require(datas.Mutations)
local ServerData = require(datas.ServerData)
local packages = ReplicatedStorage.Packages
local Observers = require(packages.Observers)
require(packages.Signal)
local Trove = require(packages.Trove)
local FFlags = require(packages.FFlags)
local SyncAnimators = require(script.SyncAnimators)
local CloneAsModel = require(script.CloneAsModel)
local ObserveDescendants = require(script.ObserveDescendants)
local RainbowTextures = require(script.RainbowTextures)
local enumItems = Enum.NormalId:GetEnumItems()
local v = {
	FAST_RAINBOW_ENABLED = true,
	LOW_QUALITY_LEVEL = Enum.SavedQualitySetting.QualityLevel6.Value,
	POSITION_UPDATE_INTERVAL_LQ = 1,
	POSITION_UPDATE_INTERVAL_HQ = 0.5,
	MAX_INVALIDATIONS_PER_FRAME_LQ = 8,
	MAX_INVALIDATIONS_PER_FRAME_HQ = 16,
	CAMERA_FACING_TOLERANCE = 0.20943951023931956,
	NO_FAST_RAINBOW_ANIMALS = { "Burrito Bandito" }
}
local gameSettings = UserSettings().GameSettings
local _ = Mutations.Rainbow
local mutationSurfaces = ReplicatedStorage.MutationSurfaces
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v2 = {
	CornerWedgePart = true,
	Part = true,
	MeshPart = true,
	WedgePart = true,
	PartOperation = true,
	UnionOperation = true,
	NegateOperation = true,
	IntersectOperation = true
}
local clone = table.clone(v2)
clone.ParticleEmitter = true
clone.Beam = true
clone.SurfaceAppearance = true
local v3 = {}
local v4 = {}
local v5 = "LQ"

local function noop() end

local function getConfig(p: string)
	return v[`{p}_{v5}`] or v[p]
end

local function bindFFlags()
	local clone2 = table.clone(v)

	for k, v6 in clone2 do
		local formatted = `FastRainbow.{k}`
		v[k] = FFlags:GetInstant(formatted, v6)
		local v7 = k
		FFlags:OnChange(formatted, function(p)
			v[v7] = p
		end)
	end
end

local function registerRainbowTextureAsync(buf: buffer, point: Vector2)
	local v6 = {
		lastUpdate = 0,
		updateInterval = 0,
		imageBuffer = buf
	}
	table.insert(v4, v6)
	local success, result = pcall(function()
		return AssetService:CreateEditableImage({
			Size = point
		})
	end)

	if not (success and result) then
		warn("failed to register optimised rainbow texture:", result)
		return nil
	end

	local success2, result2 = pcall(function()
		local texture = Instance.new("Texture")
		texture.Name = "TintTexture"
		texture.ColorMapContent = Content.fromObject(result)
		return texture
	end)

	if not (success2 and result2) then
		warn("failed to register :", result2)
		return nil
	end

	v6.editable = result
	v6.surfaceAppearance = result2
	result:WritePixelsBuffer(Vector2.zero, point, buf)
	return result2, result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function useDefaultColoring(list, p)
	table.insert(list, p)
	return function()
		table.remove(list, table.find(list, p))
	end
end

return {
	Start = function(_)
		bindFFlags()
		local v6 = nil
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil
		local success, result = pcall(function()
			v6, v7 = registerRainbowTextureAsync(RainbowTextures.solid, Vector2.one)
			assert(v6)
			v8, v9 = registerRainbowTextureAsync(RainbowTextures.stud, Vector2.new(64, 64))
			assert(v9)
			local _ = Vector2.zero
			local _ = v9.Size
			v10 = AssetService:CreateEditableImage({
				Size = v9.Size
			})
			v10:DrawImage(Vector2.zero, v9, Enum.ImageCombineType.Overwrite)
		end)

		if not success then
			warn((`cannot use FastRainbow optimisation because: {result}`))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getRainbowTextureForMaterial(material, materialVariant: string)
			if materialVariant == "Custom Stud" or material == Enum.Material.SmoothPlastic and materialVariant == "" then
				return v8
			end

			if not (material ~= Enum.Material.Plastic and material ~= Enum.Material.Neon) then
				return v6
			end

			return nil
		end

		local v11 = {
			MeshPart = function(data, maid, parent)
				if parent.Transparency == 1 then
					return
				end

				local surfaceAppearance = parent:FindFirstChildOfClass("SurfaceAppearance")

				if surfaceAppearance then
					local model = parent:FindFirstAncestorOfClass("Model")
					local child = model and mutationSurfaces:FindFirstChild(model.Name)

					if child then
						local clone2 = child:Clone()
						clone2:AddTag("__rainbow_managed")
						clone2.Parent = parent
						surfaceAppearance.Parent = clone2
						maid:Add(function()
							if surfaceAppearance.Parent ~= nil then
								surfaceAppearance.Parent = parent
							end

							clone2:Destroy()
						end)
						surfaceAppearance = clone2
					end
				end

				if (v[`FAST_RAINBOW_ENABLED_{v5}`] or v.FAST_RAINBOW_ENABLED) and success and data.fastRainbow then
					if surfaceAppearance then
						local v12 = data.addToSubFastCluster(maid, parent)

						if not v12 then
							data.optOutOfFastRainbow()
							return
						end

						local surfaceAppearance2 = v12:FindFirstChildOfClass("SurfaceAppearance")
						assert(surfaceAppearance2)

						-- equivalent calls inferred from this helper; original call sites unknown
						local function updateTransparency()
							v12.Transparency = parent.Transparency
						end

						updateTransparency() -- equivalent call inferred; original call site unknown
						maid:Add(parent:GetPropertyChangedSignal("Transparency"):Connect(updateTransparency))
						parent.LocalTransparencyModifier = 1
						table.insert(data.colorInstances, surfaceAppearance2)
						maid:Add(function()
							parent.LocalTransparencyModifier = 0
							table.remove(data.colorInstances, table.find(data.colorInstances, surfaceAppearance2))
						end)
						return
					else
						local material = parent.Material
						local materialVariant = parent.MaterialVariant
						local rainbowTextureForMaterial = getRainbowTextureForMaterial(material, materialVariant) -- equivalent call inferred; original call site unknown

						if rainbowTextureForMaterial then
							local v12 = {}

							for _, enumItem in enumItems do
								local v13 = maid:Add(rainbowTextureForMaterial:Clone())
								v13:AddTag("__rainbow_managed")
								v13.Face = enumItem
								v13.StudsPerTileU = 0.5
								v13.StudsPerTileV = 0.5
								v13.Parent = parent
								table.insert(v12, v13)
							end

							-- equivalent calls inferred from this helper; original call sites unknown
							local function updateTransparency()
								local transparency = parent.Transparency

								if transparency <= 0.01 then
									for _, v13 in v12 do
										v13.Transparency = 0
									end

									parent.LocalTransparencyModifier = 0
								else
									for _, v13 in v12 do
										v13.Transparency = transparency
									end

									parent.LocalTransparencyModifier = 1
								end
							end

							updateTransparency() -- equivalent call inferred; original call site unknown
							maid:Add(parent:GetPropertyChangedSignal("Transparency"):Connect(updateTransparency))
							parent.MaterialVariant = ""
							parent.Material = Enum.Material.Plastic
							maid:Add(function()
								parent.LocalTransparencyModifier = 0
								parent.MaterialVariant = materialVariant
								parent.Material = material
							end)
							return
						end
					end
				elseif surfaceAppearance then
					if data.fastRainbow then
						data.optOutOfFastRainbow()
						return
					end

					maid:Add(useDefaultColoring(data.colorInstances, surfaceAppearance))
					return
				end

				if data.fastRainbow then
					data.optOutOfFastRainbow()
					return
				end

				maid:Add(useDefaultColoring(data.colorInstances, parent))
			end,
			BasePart = function(data, maid, p)
				if p.Transparency == 1 then
					return
				end

				if data.fastRainbow then
					data.optOutOfFastRainbow()
					return
				end

				maid:Add(useDefaultColoring(data.colorInstances, p))
			end,
			VFXInstance = function(p, maid, p2)
				maid:Add(useDefaultColoring(p.colorSequenceInstances, p2))
			end
		}
		Observers.observeTag("RainbowModel", function(instance)
			local maid = Trove.new()
			local maid2 = Trove.new()
			local includeParticles = instance:GetAttribute("IncludeParticles")
			local v12 = {
				lastUpdate = 0,
				position = instance:GetPivot().Position,
				updateInterval = 0,
				lastPositionCheck = 0,
				spawnTime = os.clock(),
				colorInstances = {},
				colorSequenceInstances = {},
				fastRainbow = true,
				defaultColor = 0,
				isViewportFrame = 0,
				optOutOfFastRainbow = 0
			}
			local defaultColor

			if instance:IsA("BasePart") and instance:HasTag("RainbowDarken") then
				defaultColor = instance.Color
			end

			v12.defaultColor = defaultColor
			v12.isViewportFrame = instance:FindFirstAncestorOfClass("ViewportFrame") ~= nil
			v12.optOutOfFastRainbow = noop
			local partModel = instance:FindFirstAncestor("Decorations") and instance:FindFirstAncestorOfClass("Model")

			if partModel then
				v12.staticPosition = partModel:GetPivot().Position
			end

			local v14 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function bindDescendants()
				v14 = ObserveDescendants(instance, function(instance2)
					if instance2:HasTag("__rainbow_managed") or instance2:GetAttribute("IgnoreRainbowColor") then
						return
					end

					local className = instance2.ClassName

					if not clone[className] then
						return
					end

					local maid3 = maid:Extend()

					if v2[className] then
						if className == "MeshPart" then
							v11.MeshPart(v12, maid3, instance2)
						else
							local v15 = v12

							if instance2.Transparency ~= 1 then
								if v15.fastRainbow then
									v15.optOutOfFastRainbow()
								else
									maid3:Add(useDefaultColoring(v15.colorInstances, instance2))
								end
							end
						end
					elseif includeParticles and (className == "Beam" or className == "ParticleEmitter") then
						maid3:Add(useDefaultColoring(v12.colorSequenceInstances, instance2))
					end

					return maid3:WrapClean()
				end)
				maid2:Add(v14)
			end

			local v15 = nil

			function v12.addToSubFastCluster(maid3, p)
				if v15 then
					return nil
				end

				local descendants = instance:QueryDescendants("BasePart > Bone")
				local v16 = {}
				local parents = { p }

				for _, descendant in descendants do
					local parent = descendant.Parent

					if not parent or v16[parent] then
						continue
					end

					table.insert(parents, parent)
					v16[parent] = true
				end

				v14(false)
				local scale = instance:IsA("Model") and instance:GetScale() or 1
				local parent2, v18 = CloneAsModel(parents, scale)

				for _, v19 in parent2:QueryDescendants("ParticleEmitter , Beam , BillboardGui") do
					v19:Destroy()
				end

				v14(true)
				local humanoid = Instance.new("Humanoid", parent2)
				local animator = Instance.new("Animator", humanoid)
				humanoid.Name = "AnimationController"
				humanoid.Parent = parent2
				local animationController = instance:FindFirstChildOfClass("AnimationController") or instance:FindFirstChildOfClass("Humanoid")
				local v19 = noop

				if animationController then
					local animator2 = animationController:FindFirstChildOfClass("Animator")

					if animator2 then
						v19 = SyncAnimators(animator2, animator)
					end
				end

				local v20 = v18[1]
				parent2.Name = "_sub_cluster"
				parent2:AddTag("__rainbow_managed")

				if ServerData.IsTradePlaza() then
					parent2:AddTag("MiniBrainrotCull")
				end

				parent2.Parent = workspace.Debris
				local v21 = maid2:Add(function()
					parent2.Parent = nil
					v15 = nil
					v19()
				end)
				maid3:Add(function()
					v20:Destroy()
					local v22 = false

					for _, child in parent2:GetChildren() do
						if child == humanoid or table.find(v18, child) then
							continue
						end

						v22 = true
					end

					if not v22 then
						v21()
					end
				end)
				v15 = parent2
				return v20
			end

			function v12.optOutOfFastRainbow()
				if v12.fastRainbow then
					RunService:IsStudio()
					v12.fastRainbow = false
					maid2:Destroy()
					task.defer(function()
						if v3[instance] == v12 then
							bindDescendants() -- equivalent call inferred; original call site unknown
						end
					end)
				end
			end

			if v12.isViewportFrame or table.find(
				v[`NO_FAST_RAINBOW_ANIMALS_{v5}`] or v.NO_FAST_RAINBOW_ANIMALS,
				instance.Name
			) then
				v12.optOutOfFastRainbow()
			end

			v14 = ObserveDescendants(instance, function(instance2)
				if instance2:HasTag("__rainbow_managed") or instance2:GetAttribute("IgnoreRainbowColor") then
					return
				end

				local className = instance2.ClassName

				if not clone[className] then
					return
				end

				local maid3 = maid:Extend()

				if v2[className] then
					if className == "MeshPart" then
						v11.MeshPart(v12, maid3, instance2)
					else
						local v16 = v12

						if instance2.Transparency ~= 1 then
							if v16.fastRainbow then
								v16.optOutOfFastRainbow()
							else
								maid3:Add(useDefaultColoring(v16.colorInstances, instance2))
							end
						end
					end
				elseif includeParticles and (className == "Beam" or className == "ParticleEmitter") then
					maid3:Add(useDefaultColoring(v12.colorSequenceInstances, instance2))
				end

				return maid3:WrapClean()
			end)
			maid2:Add(v14)
			v3[instance] = v12
			maid:Add(function()
				v3[instance] = nil
			end)
			maid:Add(FFlags:OnChange("FastRainbow.FAST_RAINBOW_ENABLED", function(p)
				if not p and v12.fastRainbow then
					v12.optOutOfFastRainbow()
				end
			end))
			maid:Add(FFlags:OnChange("FastRainbow.NO_FAST_RAINBOW_ANIMALS", function(list)
				if type(list) == "table" and table.find(list, instance.Name) and v12.fastRainbow then
					v12.optOutOfFastRainbow()
				end
			end))
			return maid:WrapClean()
		end, { workspace, localPlayer })
		local v12 = {
			Color3.fromRGB(255, 0, 4),
			Color3.fromRGB(255, 0, 242),
			Color3.fromRGB(0, 132, 255),
			(Color3.fromRGB(17, 255, 0))
		}
		local count = #v12
		local v13 = v12[1]
		local colorSequence = ColorSequence.new(v13)

		local function adaptiveIntervals(_: number)
			local now = os.clock()
			local position = currentCamera.CFrame.Position
			local lookVector = currentCamera.CFrame.LookVector
			local v14 = math.rad(currentCamera.FieldOfView / 2) + (v[`CAMERA_FACING_TOLERANCE_{v5}`] or v.CAMERA_FACING_TOLERANCE)

			for k, v15 in v3 do
				if v15.isViewportFrame then
					v15.updateInterval = 0.022222222222222223
				elseif v15.staticPosition then
					v15.updateInterval = 0.03333333333333333
				else
					if now - v15.lastPositionCheck > (v[`POSITION_UPDATE_INTERVAL_{v5}`] or v.POSITION_UPDATE_INTERVAL) then
						v15.position = k:GetPivot().Position
						v15.lastPositionCheck = now
					end

					local v16 = position - v15.position
					local v17 = math.acos((lookVector:Dot(v16.Unit)))
					local magnitude = v16.Magnitude

					if magnitude > 5000 then
						v15.updateInterval = 60
					elseif v17 < v14 then
						v15.updateInterval = 0.5

						if not v15.fastRainbow then
							v15.updateInterval = 2
						end
					else
						v15.updateInterval = 0.03333333333333333 + magnitude // 25 / 60

						if not v15.fastRainbow then
							v15.updateInterval *= 2
						end
					end
				end
			end
		end

		local count2 = 0

		local function updateColors(_: number)
			local now = os.clock()
			local v14 = (now % count + 1) // 1
			v13 = v12[v14]:Lerp(v12[v14 % count + 1], now % 1)
			colorSequence = ColorSequence.new(v13)
			local HSV, v15 = v13:ToHSV()
			ColorSequence.new(v13)
			local v16 = {}

			for _, v17 in v3 do
				table.insert(v16, v17)
			end

			table.sort(v16, function(a, b)
				if a.isViewportFrame and b.isViewportFrame then
					return a.spawnTime < b.spawnTime
				end

				if a.isViewportFrame or b.isViewportFrame then
					return a.isViewportFrame
				end

				if a.lastUpdate == b.lastUpdate then
					return a.spawnTime < b.spawnTime
				end

				return now - (a.lastUpdate + a.updateInterval) > now - (b.lastUpdate + b.updateInterval)
			end)
			local v17 = v[`MAX_INVALIDATIONS_PER_FRAME_{v5}`] or v.MAX_INVALIDATIONS_PER_FRAME
			local count3 = 0

			for _, v18 in v16 do
				if now - v18.lastUpdate < v18.updateInterval or not (v18.fastRainbow and count3 < v17 or not v18.fastRainbow) then
					continue
				end

				v18.lastUpdate = os.clock()
				local defaultColor = v18.defaultColor

				for _, colorInstance in v18.colorInstances do
					local color = v13

					if defaultColor then
						local _, _, v19 = defaultColor:ToHSV()
						color = Color3.fromHSV(HSV, math.max(v15 - 0.4, 0), (math.min(v19 + 0.2, 1)))
					end

					colorInstance.Color = color
				end

				for _, colorSequenceInstance in v18.colorSequenceInstances do
					colorSequenceInstance.Color = colorSequence
				end

				if v18.fastRainbow then
					count3 += 1
				end
			end

			if not (success and v7) then
				return
			end

			count2 += 1

			-- equivalent calls inferred from this helper; original call sites unknown
			local function tintRainbowTexture(editable, imageBuffer: buffer)
				editable:WritePixelsBuffer(Vector2.zero, editable.Size, imageBuffer)
				editable:DrawRectangle(Vector2.zero, editable.Size, v13, 0, Enum.ImageCombineType.Multiply)
			end

			for k, v18 in v4 do
				if not (v18.editable and v18.imageBuffer and count2 % #v4 == k - 1) then
					continue
				end

				tintRainbowTexture(v18.editable, v18.imageBuffer) -- equivalent call inferred; original call site unknown
			end
		end

		local function updateQualityZone()
			if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
				local _ = not UserInputService.MouseEnabled
			end

			if gameSettings.SavedQualityLevel.Value <= (v[`LOW_QUALITY_LEVEL_{v5}`] or v.LOW_QUALITY_LEVEL) then
				v5 = "LQ"
			else
				v5 = "HQ"
			end
		end

		RunService.Heartbeat:Connect(function(dt)
			debug.profilebegin("fastrainbow:update")
			debug.profilebegin("fastrainbow:adaptive")
			adaptiveIntervals(dt)
			debug.profileend()
			debug.profilebegin("fastrainbow:updateColors")
			updateColors(dt)
			debug.profileend()
			debug.profileend()
		end)
	end
}