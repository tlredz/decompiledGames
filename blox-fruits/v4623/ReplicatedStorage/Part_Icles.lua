local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Particles = require(script.Particles)
local PlayHandle = require(script.PlayHandle)
local PartIcles = {
	Beam = {},
	_focused = true,
	_unfocusedAt = 0
}

if RunService:IsClient() then
	PartIcles._focusConn = UserInputService.WindowFocused:Connect(function()
		PartIcles._focused = true
		PartIcles._unfocusedAt = 0
	end)
	PartIcles._blurConn = UserInputService.WindowFocusReleased:Connect(function()
		PartIcles._focused = false
		PartIcles._unfocusedAt = os.clock()
	end)
end

PartIcles.ActiveEmits = {}
PartIcles.ActiveLoops = {}
PartIcles.ActiveAnimates = {}
PartIcles.ActiveChainLoops = {}
PartIcles._evenCycleStore = {}
PartIcles.Connection = nil
PartIcles._CachedFolder = nil
PartIcles._engineGen = 0
PartIcles.MAX_ACTIVE_PARTICLES = 1000
PartIcles._capWarnLastAt = 0
PartIcles._lingerVisualCount = 0
PartIcles._preloadedAssets = setmetatable({}, {
	__mode = "k"
})
local GetData = require(script.GetData)
GetData(PartIcles)
local Transform = require(script.Transform)
Transform(PartIcles)
local Update = require(script.Update)
Update(PartIcles)
local UpdateBeam = require(script.UpdateBeam)
UpdateBeam(PartIcles)
local Timescale = require(script.Timescale)
Timescale(PartIcles)
local Emit = require(script.Emit)
Emit(PartIcles)
local EmitAnimate = require(script.EmitAnimate)
EmitAnimate(PartIcles)
local EmitModel = require(script.EmitModel)
EmitModel(PartIcles)
local UpdateModel = require(script.UpdateModel)
UpdateModel(PartIcles)
local PointLight = require(script.PointLight)
PointLight(PartIcles)
local Highlight = require(script.Highlight)
Highlight(PartIcles)
local Lightning = require(script.Lightning)
Lightning(PartIcles)
local CameraShake = require(script.CameraShake)
CameraShake(PartIcles)
local Rocks = require(script.Rocks)
Rocks(PartIcles)
local Rope = require(script.Rope)
Rope(PartIcles)
local TrailEmitter = require(script.TrailEmitter)
TrailEmitter(PartIcles)
local ScreenEmit = require(script.ScreenEmit)
ScreenEmit(PartIcles)
local ImageEmit = require(script.ImageEmit)
ImageEmit(PartIcles)
local LinkTrack = require(script.LinkTrack)
LinkTrack(PartIcles)
local Orientation = require(script.Orientation)
Orientation(PartIcles)
local ZOffset = require(script.ZOffset)
ZOffset(PartIcles)
local Engine = require(script.Engine)
Engine(PartIcles)
local EngineReplay = require(script.EngineReplay)
EngineReplay(PartIcles)
local PreSimulate = require(script.PreSimulate)
PreSimulate(PartIcles)
local RegisterEmit = require(script.RegisterEmit)
RegisterEmit(PartIcles)
local Lifecycle = require(script.Lifecycle)
Lifecycle(PartIcles)

function PartIcles:_warnIfNotActivated(p)
	if self.Connection or self._notActivatedWarned then
		return
	end

	self._notActivatedWarned = true
	warn(string.format(
		"[Part-Icles] :%s() called before :Activate()  -  particles will not update until the engine is activated. Call Particle:Activate() once at startup.",
		p
	))
end

function PartIcles._applyEmitVisualPasses(object, state)
	local type2 = state.Type

	if type2 ~= "Part" and type2 ~= "Model" and type2 ~= "Attachment" then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local position = currentCamera and currentCamera.CFrame.Position
	local v = state.Orientation and state.Orientation ~= "None"
	local v2 = state.ZOffset and state.ZOffset ~= 0

	if v or v2 then
		state._postUpdateCF = type2 == "Model" and state.VisualPart:GetPivot() or state.VisualPart.CFrame
	end

	if v then
		object:ApplyOrientation(state, 0.016666666666666666, position)
	end

	if v2 then
		object:ApplyZOffset(state, position)
	end
end

function PartIcles:Emit(instance, p, p2)
	if not (instance and instance.Parent) then
		return
	end

	self:_warnIfNotActivated("Emit")
	local MAX_ACTIVE_PARTICLES = self.MAX_ACTIVE_PARTICLES or 1000

	if MAX_ACTIVE_PARTICLES <= #self.ActiveEmits + (self._lingerVisualCount or 0) then
		local now = os.clock()

		if now - (self._capWarnLastAt or 0) >= 1 then
			self._capWarnLastAt = now
			warn(("[Part-Icles] active particle cap (%d) reached  -  new emits skipped (user Module code still runs)."):format(MAX_ACTIVE_PARTICLES))
		end
	elseif instance:IsA("Beam") and instance:FindFirstChild("PartIcleProperties") then
		self:EmitBeam(instance, p, p2)
	elseif instance:IsA("Beam") or instance:IsA("Trail") and not instance:FindFirstChild("PartIcleProperties") then
		local emitDuration = instance:GetAttribute("EmitDuration")
		local v = 0

		if typeof(emitDuration) == "number" then
			v = emitDuration
		elseif emitDuration ~= nil then
			local match, v2 = tostring(emitDuration):match("([%-%.%d]+)%s*,%s*([%-%.%d]+)")
			v = match and v2 and math.max(tonumber(match) or 0, tonumber(v2) or 0) or tonumber((tostring(emitDuration))) or 0
		end

		if v > 0 then
			task.delay(instance:GetAttribute("EmitDelay") or 0, function()
				if instance and instance.Parent then
					instance.Enabled = true
					task.delay(v, function()
						if instance and instance.Parent then
							instance.Enabled = false
						end
					end)
				end
			end)
		end
	elseif instance:IsA("Trail") then
		self:EmitTrail(instance, p, p2)
	elseif instance:IsA("PointLight") then
		self:EmitPointLight(instance, p, p2)
	elseif instance:IsA("Highlight") then
		self:EmitHighlight(instance, p, p2)
	elseif instance:IsA("Attachment") then
		self:EmitAttachment(instance, p, p2)
	elseif instance:IsA("Model") then
		self:EmitModel(instance, p, p2)
	elseif instance:IsA("BlurEffect") then
		self:EmitBlur(instance, p, p2)
	elseif instance:IsA("BloomEffect") then
		self:EmitBloom(instance, p, p2)
	elseif instance:IsA("ColorCorrectionEffect") then
		self:EmitColorCorrection(instance, p, p2)
	elseif instance:IsA("Atmosphere") then
		self:EmitAtmosphere(instance, p, p2)
	elseif instance:IsA("ImageLabel") then
		self:EmitImageLabel(instance, p, p2)
	elseif PartIcles._isLightning(instance) then
		self:EmitLightning(instance, p, p2)
	elseif PartIcles._isCameraShake(instance) then
		self:EmitCameraShake(instance, p, p2)
	elseif PartIcles._isRocks(instance) then
		self:EmitRocks(instance, p, p2)
	elseif PartIcles._isRope(instance) then
		self:EmitRope(instance, p, p2)
	elseif instance:IsA("BasePart") then
		self:EmitPart(instance, p, p2)
	end
end

local Duration = require(script.Duration)

function PartIcles.await(duration)
	if duration == nil or type(duration) ~= "number" or duration <= 0 then
		return
	end

	task.wait(duration)
end

function PartIcles:_absoluteEmitFire(instance, p, p2)
	if instance:GetAttribute("Transformed") then
		self:EnableEmit(instance, nil, p2)
		return
	end

	local _makeAliveCheck = self:_makeAliveCheck()

	if instance:IsA("ParticleEmitter") then
		if p then
			return
		end

		local emitCount = tonumber(instance:GetAttribute("EmitCount")) or 1
		local emitDelay = tonumber(instance:GetAttribute("EmitDelay")) or 0
		local emitDuration = tonumber(instance:GetAttribute("EmitDuration")) or 0

		if emitCount <= 0 and emitDuration <= 0 then
			return
		end

		local nativeGen = Particles.ReadNativeGen(instance)

		local function doEmit()
			if not (_makeAliveCheck() and Particles.IsNativeGenCurrent(instance, nativeGen)) then
				return
			end

			if emitCount > 0 then
				instance:Emit(emitCount)
			end

			if emitDuration > 0 then
				Particles.SetEnabledForDuration(instance, emitDuration)
			end
		end

		if emitDelay > 0 then
			task.delay(emitDelay, doEmit)
		else
			doEmit()
		end
	elseif instance:IsA("Trail") then
		if p then
			return
		end

		Particles.EnableEmitSingle(instance, _makeAliveCheck)
	elseif instance:IsA("Beam") then
		if p then
			return
		end

		local emitDuration = tonumber(instance:GetAttribute("EmitDuration")) or 0
		local emitDelay = tonumber(instance:GetAttribute("EmitDelay")) or 0

		if emitDuration > 0 then
			local nativeGen = Particles.ReadNativeGen(instance)

			local function doEmit()
				if _makeAliveCheck() and Particles.IsNativeGenCurrent(instance, nativeGen) then
					Particles.SetEnabledForDuration(instance, emitDuration)
				end
			end

			if emitDelay > 0 then
				task.delay(emitDelay, doEmit)
			elseif _makeAliveCheck() then
				if not Particles.IsNativeGenCurrent(instance, nativeGen) then
					return
				end

				Particles.SetEnabledForDuration(instance, emitDuration)
			end
		end
	else
		local v

		if instance:IsA("BasePart") or instance:IsA("Attachment") then
			v = not p
		else
			v = instance:IsA("Model") and not p
		end

		if v then
			Particles.EnableEmit(instance, _makeAliveCheck)
		end

		local v2 = v or p

		for _, part in instance:GetChildren() do
			if not (not instance:IsA("BasePart") or not part:IsA("BasePart") or part:GetAttribute("Transformed")) then
				continue
			end

			self:_absoluteEmitFire(part, v2, p2)
		end
	end
end

function PartIcles:AbsoluteEmit(p, p2, p3)
	self:_warnIfNotActivated("AbsoluteEmit")

	if not p then
		return 0
	end

	self:_absoluteEmitFire(p, p2, p3)
	return Duration.computeMaxDuration(p, 0)
end

function PartIcles:AbsoluteEmitAt(folder, cframe, options)
	self:_warnIfNotActivated("AbsoluteEmitAt")

	if not (folder and cframe) then
		return nil, 0
	end

	local v = options or {}
	local maxDuration = Duration.computeMaxDuration(folder, 0)
	local playToken = {
		Alive = true,
		Loops = {},
		Clones = {},
		Duration = maxDuration
	}
	local v3 = PlayHandle.new(self, playToken)
	local v4

	if v.LinkOverride == true then
		v4 = v.Link ~= nil
	else
		v4 = false
	end

	if folder:GetAttribute("Transformed") then
		if v.Link ~= nil then
			self:SetLink(folder, v.Link, v.LinkMode or "Weld")
		end

		if v.EmitParent ~= nil then
			self:SetEmitParent(folder, v.EmitParent)
		end

		local v5 = {
			ChainCtx = v.ChainCtx,
			UseFullOrigin = v.UseFullOrigin ~= false,
			IgnoreLink = v.IgnoreLink == true,
			_playToken = playToken
		}

		if not v4 then
			v5.EventOriginCF = cframe
			v5.EventOriginResolver = v.OriginResolver
		end

		self:EnableEmit(folder, nil, v5)
		return v3, maxDuration
	else
		if not (folder:IsA("BasePart") or folder:IsA("Model") or folder:IsA("Attachment")) then
			return nil, 0
		end

		local cFrame = nil

		if folder:IsA("Model") then
			local success, pivot = pcall(folder.GetPivot, folder)

			if success then
				cFrame = pivot
			end
		elseif folder:IsA("BasePart") then
			cFrame = folder.CFrame
		elseif folder:IsA("Attachment") then
			cFrame = folder.WorldCFrame
		end

		local function readWorldCF(instance)
			if instance:IsA("Model") then
				local success, pivot = pcall(instance.GetPivot, instance)
				return success and pivot or nil
			end

			if instance:IsA("Attachment") then
				return instance.WorldCFrame
			end

			if instance:IsA("BasePart") then
				return instance.CFrame
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function originFor(p)
			if not cFrame then
				return cframe
			end

			local v5 = readWorldCF(p)

			if v5 then
				return cframe * cFrame:ToObjectSpace(v5)
			end

			return cframe
		end

		local function ctxFor(instance)
			local v5 = {
				ChainCtx = v.ChainCtx,
				UseFullOrigin = v.UseFullOrigin ~= false,
				IgnoreLink = v.IgnoreLink == true,
				_playToken = playToken
			}

			if v4 then
				return v5
			end

			local eventOriginCF = originFor(instance) -- equivalent call inferred; original call site unknown
			v5.EventOriginCF = eventOriginCF
			v5.EventOriginResolver = v.OriginResolver
			return v5
		end

		if (v.ApplyToAll or v4) and (v.Link ~= nil or v.EmitParent ~= nil) then
			local applyAuthoring

			applyAuthoring = function(instance)
				if instance:GetAttribute("Transformed") then
					if v.Link ~= nil then
						self:SetLink(instance, v.Link, v.LinkMode or "Weld")
					end

					if v.EmitParent ~= nil then
						self:SetEmitParent(instance, v.EmitParent)
					end
				end

				for _, child in instance:GetChildren() do
					applyAuthoring(child)
				end
			end

			applyAuthoring(folder)
		end

		local walkTransformed

		walkTransformed = function(instance)
			if instance:GetAttribute("Transformed") then
				self:EnableEmit(instance, nil, (ctxFor(instance)))
				return
			end

			for _, child in instance:GetChildren() do
				walkTransformed(child)
			end
		end

		walkTransformed(folder)

		if v.SkipClone then
			Particles.EnableEmit(folder, self:_makeAliveCheck())
			return v3, maxDuration
		end

		local function _underTransformedAncestor(effect)
			local parent = effect.Parent

			while parent and parent ~= folder do
				if parent:GetAttribute("Transformed") then
					return true
				else
					parent = parent.Parent
				end
			end

			return false
		end

		local v5 = false

		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			if effect:GetAttribute("Transformed") or _underTransformedAncestor(effect) then
				continue
			end

			v5 = true
			break
		end

		if not v5 then
			return v3, maxDuration
		end

		local success, result = pcall(folder.Clone, folder)

		if not (success and result) then
			return v3, maxDuration
		end

		pcall(function()
			result.Archivable = false
		end)

		for _, descendant in ipairs(result:GetDescendants()) do
			if not descendant:GetAttribute("Transformed") then
				continue
			end

			local v7 = descendant
			pcall(function()
				v7:Destroy()
			end)
		end

		if result:IsA("BasePart") then
			pcall(function()
				result.Anchored = true
			end)
		end

		for _, part in ipairs(result:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local v7 = part
			pcall(function()
				v7.Anchored = true
			end)
		end

		if v.UseFullOrigin == false and cFrame then
			cframe = CFrame.new(cframe.Position) * cFrame.Rotation
		end

		if result:IsA("Model") then
			pcall(function()
				result:PivotTo(cframe)
			end)
		elseif result:IsA("BasePart") then
			pcall(function()
				result.CFrame = cframe
			end)
		elseif result:IsA("Attachment") then
			pcall(function()
				result:Destroy()
			end)
			return v3, maxDuration
		end

		result.Parent = self:GetFolder()
		table.insert(playToken.Clones, result)
		self:_absoluteEmitFire(result, nil, nil)
		task.delay(maxDuration or 60, function()
			if result and result.Parent then
				pcall(function()
					result:Destroy()
				end)
			end
		end)
		return v3, maxDuration
	end
end

local TexturePin = require(script.TexturePin)

-- equivalent calls inferred from this helper; original call sites unknown
local function _isPreloadable(effect)
	return effect:GetAttribute("Transformed") or effect:IsA("ParticleEmitter") or effect:IsA("Trail")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _walk(p, p2, callback)
	if not p then
		return
	end

	local visit

	visit = function(effect)
		if _isPreloadable(effect) and (p2 or effect:GetAttribute("PreloadTexture") == true) then
			callback(effect)
		end

		for _, child in effect:GetChildren() do
			visit(child)
		end
	end

	visit(p)
end

function PartIcles.Preload(_, p, p2)
	_walk(p, p2, TexturePin.pinSubtree) -- equivalent call inferred; original call site unknown
end

function PartIcles.Deload(_, p, p2)
	_walk(p, p2, TexturePin.unpinSubtree) -- equivalent call inferred; original call site unknown
end

PartIcles.LinkService = require(script.LinkService)

function PartIcles:SetLink(parent, instance, linkMode)
	if not (parent and parent:GetAttribute("Transformed")) then
		return
	end

	if instance == "camera" then
		pcall(function()
			parent:SetAttribute("LinkSource", "Camera")
		end)
	elseif instance == nil then
		pcall(function()
			parent:SetAttribute("LinkSource", "None")
		end)
		local link = parent:FindFirstChild("Link")

		if link and link:IsA("ObjectValue") then
			link.Value = nil
		end
	elseif typeof(instance) == "Instance" then
		local v = parent:FindFirstChild("Link")

		if not v then
			v = Instance.new("ObjectValue")
			v.Name = "Link"
			v.Parent = parent
		end

		v.Value = instance
		pcall(function()
			parent:SetAttribute("LinkSource", "Object")
		end)
	end

	if linkMode then
		pcall(function()
			parent:SetAttribute("LinkMode", linkMode)
		end)
	end
end

function PartIcles:SetEmitParent(parent, instance)
	if not (parent and parent:GetAttribute("Transformed")) then
		return
	end

	if instance == nil then
		local emitParent = parent:FindFirstChild("EmitParent")

		if emitParent then
			pcall(function()
				emitParent:Destroy()
			end)
		end
	else
		if typeof(instance) ~= "Instance" then
			return
		end

		local v = parent:FindFirstChild("EmitParent")

		if not v then
			v = Instance.new("ObjectValue")
			v.Name = "EmitParent"
			v.Parent = parent
		end

		v.Value = instance
	end
end

return PartIcles