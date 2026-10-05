local ContentProvider = game:GetService("ContentProvider")
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local ScreenHost = require(script.Parent.ScreenHost)
local Pool = require(script.Parent.Pool)
local StaticPass = require(script.Parent.StaticPass)
return function(p)
	local v = {}

	local function resolveImageParent(data, sourceItem)
		if data.EmitParent then
			return data.EmitParent
		end

		if not sourceItem then
			return ScreenHost.get()
		end

		local parent = sourceItem.Parent

		while parent and parent ~= game do
			if parent:GetAttribute("_PartIcleEmit") then
				return sourceItem.Parent
			else
				parent = parent.Parent
			end
		end

		return ScreenHost.get()
	end

	local function gatherFlipbookDecals(imageFlipbooks)
		if not imageFlipbooks then
			return nil
		end

		local decals = {}

		for _, decal in ipairs(imageFlipbooks:GetChildren()) do
			if decal:IsA("Decal") then
				table.insert(decals, decal)
			end
		end

		table.sort(decals, function(a, b)
			local name = tonumber(a.Name)
			local name2 = tonumber(b.Name)

			if name and name2 then
				return name < name2
			end

			return a.Name < b.Name
		end)
		return #decals > 0 and decals or nil
	end

	local function preloadEmitAssets(data, flipbookDecals)
		local v2 = {}

		if flipbookDecals then
			for _, v3 in ipairs(flipbookDecals) do
				table.insert(v2, v3)
			end
		end

		if data.Image and data.Image ~= "" then
			table.insert(v2, data.Image)
		end

		if #v2 == 0 then
			return
		end

		task.spawn(function()
			pcall(ContentProvider.PreloadAsync, ContentProvider, v2)
		end)
	end

	local function preloadAndWait(object, renderTemplate, data, list)
		if not (object and renderTemplate) then
			return
		end

		local _preloadedAssets = object._preloadedAssets

		if not _preloadedAssets or _preloadedAssets[renderTemplate] then
			return
		end

		local v2 = {}

		if list then
			for _, v3 in ipairs(list) do
				table.insert(v2, v3)
			end
		end

		if data.Image and data.Image ~= "" then
			table.insert(v2, data.Image)
		end

		_preloadedAssets[renderTemplate] = true

		if #v2 == 0 then
			return
		end

		pcall(ContentProvider.PreloadAsync, ContentProvider, v2)
	end

	local function resolveFrame(state, p2, p3)
		if p2 <= 0 then
			return 0
		end

		local flipbookMode = state.FlipbookMode
		local _currentRandomFrame

		if flipbookMode == Enum.ParticleFlipbookMode.OneShot then
			_currentRandomFrame = math.min(
				math.floor((not (state.LifeTime > 0) and 1 or math.min(1, p3 / state.LifeTime) or 1) * p2),
				p2 - 1
			)
		elseif flipbookMode == Enum.ParticleFlipbookMode.PingPong then
			local v2 = (not (state.LifeTime > 0) and 1 or math.min(1, p3 / state.LifeTime) or 1) * 2
			local v3

			if v2 <= 1 then
				v3 = math.floor(v2 * p2)
			else
				v3 = math.floor((2 - v2) * p2)
			end

			_currentRandomFrame = math.max(0, (math.min(v3, p2 - 1)))
		elseif flipbookMode == Enum.ParticleFlipbookMode.Random then
			local flipbookFramerate = state.FlipbookFramerate or 24
			local lastRandomInterval = math.floor(p3 / (flipbookFramerate > 0 and 1 / flipbookFramerate or 1))

			if state._lastRandomInterval ~= lastRandomInterval then
				state._lastRandomInterval = lastRandomInterval
				state._currentRandomFrame = math.random(0, p2 - 1)
			end

			_currentRandomFrame = state._currentRandomFrame or math.random(0, p2 - 1)
		else
			_currentRandomFrame = math.floor(p3 * state.FlipbookFramerate + (state.FlipbookStartOffset or 0) * p2) % p2
		end

		if state.FlipbookReverse then
			_currentRandomFrame = p2 - 1 - _currentRandomFrame
		end

		return _currentRandomFrame
	end

	local function applyFlipbookFrame(state, p2)
		if not state.FlipbookFramerate or state.FlipbookFramerate <= 0 then
			return
		end

		if state.FlipbookSource == "Decals" and state.FlipbookDecals then
			local count = #state.FlipbookDecals

			if count == 0 then
				return
			end

			local frame = resolveFrame(state, count, p2)

			if frame == state._lastFlipbookFrame then
				return
			end

			state._lastFlipbookFrame = frame
			local flipbookDecal = state.FlipbookDecals[frame + 1]

			if flipbookDecal and flipbookDecal.Texture then
				state.VisualPart.Image = flipbookDecal.Texture
			end
		elseif state.FlipbookSource == "Spritesheet" then
			local v2 = math.max(1, state.GridCols or 1)
			local v3 = math.max(1, state.GridRows or 1)
			local frame = resolveFrame(state, v2 * v3, p2)
			local sheetSize = state.SheetSize

			if not (sheetSize and frame ~= state._lastFlipbookFrame) then
				return
			end

			state._lastFlipbookFrame = frame
			local v5 = sheetSize.X / v2
			local v6 = sheetSize.Y / v3
			state.VisualPart.ImageRectSize = Vector2.new(v5, v6)
			state.VisualPart.ImageRectOffset = Vector2.new(frame % v2 * v5, math.floor(frame / v2) * v6)
		end
	end

	local function _simulateForward2D(data, p2, p3, p4, p5)
		local v2 = p4 / 60
		local X = (data.ImgAcceleration or Vector2.new()).X
		local Y = (data.ImgAcceleration or Vector2.new()).Y
		local imgDrag = data.ImgDrag or 0
		local v3 = 0
		local v4 = 0
		local total = 0
		local total2 = 0

		for i = 1, 60 do
			local v6 = not data.ImgSpeed and 0 or Graph.QueryPointsWithTime(i / 60, data.ImgSpeed, p5.ImgSpeed) * 100
			v3 += X * 100 * v2
			v4 += Y * 100 * v2

			if imgDrag > 0 then
				local v7 = math.max(0, 1 - imgDrag * v2)
				v3 *= v7
				v4 *= v7
			end

			total += (v6 * p2 + v3) * v2
			total2 += (v6 * p3 + v4) * v2
		end

		return total, total2, v3, v4
	end

	function p._computeImageLabelEndState(_, p2, p3, p4, p5, p6)
		return _simulateForward2D(p2, p3, p4, p5, p6)
	end

	local function buildImageLabelPData(data, visualPart, sourceItem, p3)
		local flipbookDecals = gatherFlipbookDecals(data.ImageFlipbooks)
		local imgEmissionAngle = data.ImgEmissionAngle or 90
		local imgSpreadAngle = data.ImgSpreadAngle or 0
		local v3 = math.rad(imgEmissionAngle + (math.random() * 2 - 1) * imgSpreadAngle)
		local dirX = math.cos(v3)
		local dirY = -math.sin(v3)
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local v6 = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local seeds = {
			ImageTransparency = not data.ImageTransparency and {} or Graph.GenerateSeed(data.ImageTransparency) or {},
			BackgroundTransparency = not data.BackgroundTransparency and {} or Graph.GenerateSeed(data.BackgroundTransparency) or {},
			ImgSpeed = not data.ImgSpeed and {} or Graph.GenerateSeed(data.ImgSpeed) or {},
			ImgRotSpeed = not data.ImgRotSpeed and {} or Graph.GenerateSeed(data.ImgRotSpeed) or {},
			SizeScaleX = not data.SizeScaleX and {} or Graph.GenerateSeed(data.SizeScaleX) or {},
			SizeScaleY = not data.SizeScaleY and {} or Graph.GenerateSeed(data.SizeScaleY) or {},
			Timescale = not data.ImgTimescale and {} or Graph.GenerateSeed(data.ImgTimescale) or {}
		}
		local randomValueFromRange2 = Range.RandomValueFromRange(data.ImgRotRange or NumberRange.new(0))
		local imgSizeUDim = data.ImgSizeUDim or UDim2.fromOffset(100, 100)

		if data.ImageTransparency then
			visualPart.ImageTransparency = Graph.QueryPointsWithTime(0, data.ImageTransparency, seeds.ImageTransparency)
		end

		if data.BackgroundTransparency then
			visualPart.BackgroundTransparency = Graph.QueryPointsWithTime(
				0,
				data.BackgroundTransparency,
				seeds.BackgroundTransparency
			)
		end

		if data.ImageColor3 then
			visualPart.ImageColor3 = Graph.QueryColorPointWithTime(0, data.ImageColor3)
		end

		if data.BackgroundColor3 then
			visualPart.BackgroundColor3 = Graph.QueryColorPointWithTime(0, data.BackgroundColor3)
		end

		visualPart.Image = data.Image or ""
		visualPart.ScaleType = data.ImgScaleType or Enum.ScaleType.Stretch
		visualPart.ResampleMode = data.ImgResampleMode or Enum.ResamplerMode.Default
		visualPart.AnchorPoint = data.ImgAnchorPoint or Vector2.new(0.5, 0.5)
		visualPart.ZIndex = data.ImgZIndex or 1
		visualPart.Rotation = randomValueFromRange2
		local v8 = not data.SizeScaleX and 1 or Graph.QueryPointsWithTime(0, data.SizeScaleX, seeds.SizeScaleX) or 1
		local v9 = not data.SizeScaleY and 1 or Graph.QueryPointsWithTime(0, data.SizeScaleY, seeds.SizeScaleY) or 1
		visualPart.Size = UDim2.new(
			imgSizeUDim.X.Scale * v8,
			imgSizeUDim.X.Offset * v8,
			imgSizeUDim.Y.Scale * v9,
			imgSizeUDim.Y.Offset * v9
		)
		visualPart.Position = data.ImgPosition or UDim2.fromScale(0.5, 0.5)
		local flipbookFramerate = not data.ImgFlipbookFramerate and 10 or Range.RandomValueFromRange(data.ImgFlipbookFramerate)
		local imgFlipbookMode = data.ImgFlipbookMode or Enum.ParticleFlipbookMode.Loop
		local v11 = data.ImgFlipbookStartRandom and imgFlipbookMode == Enum.ParticleFlipbookMode.Loop
		local v12 = 0
		local flipbookStartOffset = 0
		local sheetSize = data.SheetSize
		local imgFlipbookSource = data.ImgFlipbookSource or "Decals"

		if imgFlipbookSource == "Spritesheet" and not sheetSize and data.Image and data.Image ~= "" and not v[data.Image] then
			v[data.Image] = true
			warn(string.format(
				"Part-Icles: Spritesheet flipbook  -  sheet dimensions unknown for %s. Emit will render full sheet until dimensions resolve.",
				data.Image
			))
		end

		if imgFlipbookSource == "Decals" then
			visualPart.ImageRectSize = Vector2.new(0, 0)
			visualPart.ImageRectOffset = Vector2.new(0, 0)

			if flipbookDecals and #flipbookDecals > 0 then
				local count = #flipbookDecals

				if v11 then
					v12 = math.random(0, count - 1)
					flipbookStartOffset = v12 / count
				end

				local v14 = flipbookDecals[v12 + 1]

				if v14 and v14.Texture and v14.Texture ~= "" then
					visualPart.Image = v14.Texture
				end
			end
		elseif imgFlipbookSource == "Spritesheet" and sheetSize then
			local v14 = math.max(1, data.ImgGridCols or 1)
			local v15 = math.max(1, data.ImgGridRows or 1)
			local v16 = v14 * v15

			if v11 and v16 > 0 then
				v12 = math.random(0, v16 - 1)
				flipbookStartOffset = v12 / v16
			end

			local v17 = sheetSize.X / v14
			local v18 = sheetSize.Y / v15
			visualPart.ImageRectSize = Vector2.new(v17, v18)
			visualPart.ImageRectOffset = Vector2.new(v12 % v14 * v17, math.floor(v12 / v14) * v18)
		end

		local v14 = {
			Type = "ImageLabel",
			VisualPart = visualPart,
			StartTime = os.clock(),
			LifeTime = v6,
			TotalKeyFrames = math.max(1, data.TotalKeyFrames or 100),
			CurrentStep = 0,
			PartLife = data.PartLife or 0,
			BasePosition = data.ImgPosition or UDim2.fromScale(0.5, 0.5),
			BaseSize = imgSizeUDim,
			DirX = dirX,
			DirY = dirY,
			EnvVelX = 0,
			EnvVelY = 0,
			PosX = 0,
			PosY = 0,
			AccelX = (data.ImgAcceleration or Vector2.new()).X,
			AccelY = (data.ImgAcceleration or Vector2.new()).Y,
			Drag = data.ImgDrag or 0,
			InitialRotation = randomValueFromRange2,
			RotMode = data.ImgRotMode or "OverLife",
			AccRot = 0,
			InvertMotion = data.ImgInvertMotion or false,
			Graphs = {
				ImageTransparency = data.ImageTransparency,
				BackgroundTransparency = data.BackgroundTransparency,
				ImgSpeed = data.ImgSpeed,
				ImgRotSpeed = data.ImgRotSpeed,
				SizeScaleX = data.SizeScaleX,
				SizeScaleY = data.SizeScaleY,
				ImageColor3 = data.ImageColor3,
				BackgroundColor3 = data.BackgroundColor3,
				Timescale = data.ImgTimescale
			},
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.ImgTimescale, seeds.Timescale, v6),
			FlipbookSource = data.ImgFlipbookSource or "Decals",
			FlipbookMode = data.ImgFlipbookMode or Enum.ParticleFlipbookMode.Loop,
			FlipbookFramerate = flipbookFramerate,
			FlipbookStartOffset = flipbookStartOffset,
			FlipbookReverse = data.ImgFlipbookReverse or false,
			FlipbookDecals = flipbookDecals,
			SheetSize = sheetSize,
			GridCols = data.ImgGridCols or 8,
			GridRows = data.ImgGridRows or 1,
			IsAnimate = p3 or nil,
			AnimateItem = p3 and sourceItem or nil
		}

		if data.ImgInvertMotion then
			local posX, posY, envVelX, envVelY = _simulateForward2D(data, dirX, dirY, v6, seeds)
			v14.PosX = posX
			v14.PosY = posY
			v14.EnvVelX = envVelX
			v14.EnvVelY = envVelY
			v14._effectiveElapsed = v6
			v14._invertDtSign = -1
		end

		StaticPass.apply(v14)

		if v14._staticSizeScaleX and v14._staticSizeScaleY then
			v14._staticSizeScaleX = nil
			v14._staticSizeScaleY = nil
		end

		return v14
	end

	function p.EmitImageLabel(object, sourceItem, link, p2)
		local data = object:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		preloadAndWait(object, data.RenderTemplate, data, nil)
		local folder = Pool.acquireOrClone(data.RenderTemplate, "ImageLabel", data.Pool)
		folder.Archivable = false
		folder.Visible = true
		local imageFlipbooks = folder:FindFirstChild("ImageFlipbooks")

		if imageFlipbooks then
			imageFlipbooks:Destroy()
		end

		local imageLabelPData = buildImageLabelPData(data, folder, sourceItem, false)
		imageLabelPData.Link = link
		imageLabelPData._sourceItem = sourceItem
		p._seedTsOverride(imageLabelPData, sourceItem)
		imageLabelPData.Events = data.Events

		if data.Pool ~= false then
			imageLabelPData._sourceRT = data.RenderTemplate
			imageLabelPData._poolKind = "ImageLabel"
		end

		preloadEmitAssets(data, imageLabelPData.FlipbookDecals)
		folder.Parent = resolveImageParent(data, sourceItem)
		object:_registerEmit(imageLabelPData, p2)

		for _, image in folder:GetDescendants() do
			if image:GetAttribute("Transformed") and image:IsA("ImageLabel") then
				object:EnableEmit(image, nil, p2)
			end
		end
	end

	function p.EmitImageLabelAnimate(object, sourceItem, link, p2)
		if object.ActiveAnimates[sourceItem] then
			return
		end

		local data = object:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		preloadAndWait(object, data.RenderTemplate, data, nil)
		local clone = data.RenderTemplate:Clone()
		clone.Archivable = false
		clone.Visible = true
		clone:SetAttribute("_PartIcleEmit", true)
		local imageFlipbooks = clone:FindFirstChild("ImageFlipbooks")

		if imageFlipbooks then
			imageFlipbooks:Destroy()
		end

		local imageLabelPData = buildImageLabelPData(data, clone, sourceItem, true)
		imageLabelPData.Link = link
		imageLabelPData._sourceItem = sourceItem
		p._seedTsOverride(imageLabelPData, sourceItem)
		imageLabelPData.Events = data.Events
		preloadEmitAssets(data, imageLabelPData.FlipbookDecals)
		clone.Parent = resolveImageParent(data, sourceItem)
		object.ActiveAnimates[sourceItem] = imageLabelPData
		object:_registerEmit(imageLabelPData, p2)

		for _, image in clone:GetDescendants() do
			if image:GetAttribute("Transformed") and image:IsA("ImageLabel") then
				object:EnableEmit(image, nil, p2)
			end
		end
	end

	function p.UpdateImageLabel(_, state, p2, p3)
		local visualPart = state.VisualPart

		if not (visualPart and visualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

		local v2 = math.min(math.max((p3 - state.StartTime) / state.LifeTime, 0), 1)
		local v3

		if state._tsOverride == nil or not (p3 < (state._tsOverrideUntil or 0)) then
			v3 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v2,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v3 = state._tsOverride
		end

		local v4 = p2 * v3

		if state._invertDtSign then
			v4 *= state._invertDtSign
		end

		local lifeTime = state.LifeTime
		local _effectiveElapsed = state._effectiveElapsed or 0
		local v5 = _effectiveElapsed + (state._timeFrozen and 0 or v4)
		local effectiveElapsed = v5 < 0 and 0 or v5

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local v7 = effectiveElapsed - _effectiveElapsed
		local v8 = lifeTime <= effectiveElapsed
		local v9 = effectiveElapsed <= 0
		local v10 = effectiveElapsed / lifeTime
		local v11 = v2 >= 1 and (v8 or v9)
		local v12 = v10 > 1 and 1 or v10
		local v13 = v12 < 0 and 0 or v12
		local graphs = state.Graphs
		local seeds = state.Seeds
		state.AccumulatedDT = (state.AccumulatedDT or 0) + v7
		local currentStep = math.floor(v13 * state.TotalKeyFrames)

		if currentStep ~= state.CurrentStep then
			local accumulatedDT = state.AccumulatedDT
			state.AccumulatedDT = 0
			state.CurrentStep = currentStep
			local v15 = currentStep / state.TotalKeyFrames
			local v16 = 0

			if state._staticImgSpeed then
				v16 = state._staticImgSpeed * 100
			elseif graphs.ImgSpeed then
				v16 = Graph.QueryPointsWithTime(v15, graphs.ImgSpeed, seeds.ImgSpeed) * 100
			end

			if v16 ~= 0 and state.Drag > 0 then
				v16 *= math.exp(-state.Drag * effectiveElapsed)
			end

			state.EnvVelX += state.AccelX * 100 * accumulatedDT
			state.EnvVelY += state.AccelY * 100 * accumulatedDT

			if state.Drag > 0 then
				local v17 = math.max(0, 1 - state.Drag * accumulatedDT)
				state.EnvVelX *= v17
				state.EnvVelY *= v17
			end

			local v17 = v16 * state.DirX + state.EnvVelX
			local v18 = v16 * state.DirY + state.EnvVelY
			state.PosX += v17 * accumulatedDT
			state.PosY += v18 * accumulatedDT
			local basePosition = state.BasePosition
			visualPart.Position = UDim2.new(
				basePosition.X.Scale,
				basePosition.X.Offset + state.PosX,
				basePosition.Y.Scale,
				basePosition.Y.Offset + state.PosY
			)
			local _staticImgRotSpeed = nil

			if state._staticImgRotSpeed then
				_staticImgRotSpeed = state._staticImgRotSpeed
			elseif graphs.ImgRotSpeed then
				_staticImgRotSpeed = Graph.QueryPointsWithTime(v15, graphs.ImgRotSpeed, seeds.ImgRotSpeed)
			end

			if _staticImgRotSpeed then
				local v19

				if state.RotMode == "Speed" then
					state.AccRot += _staticImgRotSpeed * accumulatedDT
					v19 = state.InitialRotation + state.AccRot
				else
					v19 = state.InitialRotation + _staticImgRotSpeed
				end

				if v19 ~= state._lastRotation then
					visualPart.Rotation = v19
					state._lastRotation = v19
				end
			end

			local _staticSizeScaleX = state._staticSizeScaleX or graphs.SizeScaleX
			local _staticSizeScaleY = state._staticSizeScaleY or graphs.SizeScaleY

			if (_staticSizeScaleX or _staticSizeScaleY) and not state.SkipSize then
				local _staticSizeScaleX2 = state._staticSizeScaleX or not graphs.SizeScaleX and 1 or Graph.QueryPointsWithTime(
					v15,
					graphs.SizeScaleX,
					seeds.SizeScaleX
				) or 1
				local _staticSizeScaleY2 = state._staticSizeScaleY or not graphs.SizeScaleY and 1 or Graph.QueryPointsWithTime(
					v15,
					graphs.SizeScaleY,
					seeds.SizeScaleY
				) or 1

				if _staticSizeScaleX2 ~= state._lastSizeX or _staticSizeScaleY2 ~= state._lastSizeY then
					local baseSize = state.BaseSize
					visualPart.Size = UDim2.new(
						baseSize.X.Scale * _staticSizeScaleX2,
						baseSize.X.Offset * _staticSizeScaleX2,
						baseSize.Y.Scale * _staticSizeScaleY2,
						baseSize.Y.Offset * _staticSizeScaleY2
					)
					state._lastSizeX = _staticSizeScaleX2
					state._lastSizeY = _staticSizeScaleY2
				end
			end

			if graphs.ImageTransparency and not state.SkipTransparency then
				visualPart.ImageTransparency = Graph.QueryPointsWithTime(
					v15,
					graphs.ImageTransparency,
					seeds.ImageTransparency
				)
			end

			if graphs.BackgroundTransparency and not state.SkipTransparency then
				visualPart.BackgroundTransparency = Graph.QueryPointsWithTime(
					v15,
					graphs.BackgroundTransparency,
					seeds.BackgroundTransparency
				)
			end

			if graphs.ImageColor3 and not state.SkipColor then
				visualPart.ImageColor3 = Graph.QueryColorPointWithTime(v15, graphs.ImageColor3)
			end

			if graphs.BackgroundColor3 and not state.SkipColor then
				visualPart.BackgroundColor3 = Graph.QueryColorPointWithTime(v15, graphs.BackgroundColor3)
			end
		end

		applyFlipbookFrame(state, effectiveElapsed)
		return v11
	end

	function p._refreshImageLabelAnimateNonSpatial(_, state, data)
		if not data then
			return
		end

		local imgEmissionAngle = data.ImgEmissionAngle or 90
		local imgSpreadAngle = data.ImgSpreadAngle or 0
		local v2 = math.rad(imgEmissionAngle + (math.random() * 2 - 1) * imgSpreadAngle)
		local dirX = math.cos(v2)
		local dirY = -math.sin(v2)
		state.DirX = dirX
		state.DirY = dirY

		if data.ImgAcceleration then
			state.AccelX = data.ImgAcceleration.X
			state.AccelY = data.ImgAcceleration.Y
		end

		if data.ImgDrag ~= nil then
			state.Drag = data.ImgDrag
		end

		if data.ImgPosition then
			state.BasePosition = data.ImgPosition
		end

		if data.ImgSizeUDim then
			state.BaseSize = data.ImgSizeUDim
		end

		if data.ImgRotMode then
			state.RotMode = data.ImgRotMode
		end

		if data.ImgRotRange then
			state.InitialRotation = Range.RandomValueFromRange(data.ImgRotRange)
		end

		if data.ImgFlipbookSource then
			state.FlipbookSource = data.ImgFlipbookSource
		end

		if data.ImgFlipbookMode then
			state.FlipbookMode = data.ImgFlipbookMode
		end

		if data.ImgFlipbookFramerate then
			state.FlipbookFramerate = Range.RandomValueFromRange(data.ImgFlipbookFramerate)
		end

		if data.ImgFlipbookReverse ~= nil then
			state.FlipbookReverse = data.ImgFlipbookReverse
		end

		if data.ImgGridCols then
			state.GridCols = data.ImgGridCols
		end

		if data.ImgGridRows then
			state.GridRows = data.ImgGridRows
		end

		if data.SheetSize ~= nil then
			state.SheetSize = data.SheetSize
		end

		if data.ImageFlipbooks then
			state.FlipbookDecals = gatherFlipbookDecals(data.ImageFlipbooks)
		end

		if data.ImgTimescale and state.Graphs then
			state.Graphs.Timescale = data.ImgTimescale
			state.Seeds.Timescale = Graph.GenerateSeed(data.ImgTimescale)
		end
	end
end