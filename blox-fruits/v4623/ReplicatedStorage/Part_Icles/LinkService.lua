local RunService = game:GetService("RunService")
local PartConstants = require(script.Parent.PartConstants)
local preRender = RunService:IsClient() and RunService.PreRender or RunService.Heartbeat
local v = {
	Weld = true,
	Follow = true,
	Pivot = true,
	WeldWithoutRotation = true
}

local function _readPart1CF(instance)
	if instance:IsA("Model") then
		local success, pivot = pcall(instance.GetPivot, instance)

		if success and pivot then
			return pivot
		end

		return CFrame.new()
	elseif instance:IsA("Attachment") then
		return instance.WorldCFrame
	else
		return instance.CFrame
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _classifyPart1(instance)
	if instance:IsA("Model") then
		return "Model"
	end

	if instance:IsA("Attachment") then
		return "Attachment"
	end

	return "Part"
end

local LinkService = {}
LinkService._active = false
LinkService._connection = nil
LinkService._links = {}
LinkService._anchorSnapshot = {}
LinkService._warnedNotActive = false

function LinkService:_captureAndAnchor(folder)
	if folder:IsA("BasePart") then
		local anchored = folder.Anchored
		folder.Anchored = true
		return anchored
	else
		if not folder:IsA("Model") then
			return nil
		end

		local anchoredsByPart = {}

		for _, part in ipairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			anchoredsByPart[part] = part.Anchored
			part.Anchored = true
		end

		return anchoredsByPart
	end
end

function LinkService:_restoreAnchor(instance)
	local anchored = self._anchorSnapshot[instance]
	self._anchorSnapshot[instance] = nil

	if anchored == nil then
		return
	end

	if instance:IsA("BasePart") and instance.Parent then
		instance.Anchored = anchored
	elseif instance:IsA("Model") and type(anchored) == "table" then
		for k, anchored2 in pairs(anchored) do
			if k.Parent then
				k.Anchored = anchored2
			end
		end
	end
end

function LinkService:Activate()
	if self._active then
		return
	end

	self._active = true
	self._connection = preRender:Connect(function(p)
		self:_tick(p)
	end)
end

function LinkService:Deactivate()
	if not self._active then
		return
	end

	self._active = false

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end

	for k in pairs(self._links) do
		self._links[k] = nil
		self:_restoreAnchor(k)
	end
end

function LinkService:Link(instance, target, p2, p3)
	if not (instance and target and instance ~= target and (instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Attachment"))) then
		return
	end

	if not (instance.Parent and target.Parent) then
		return
	end

	local mode = not v[p2] and "Weld" or p2

	if not (self._active or self._warnedNotActive) then
		self._warnedNotActive = true
		warn("[Part-Icles LinkService] Link called before Activate(); the link won't update until you call LinkService:Activate(). This warning fires once.")
	end

	local linkCFrame = PartConstants.resolveLinkCFrame(target)
	local worldCFrame

	if instance:IsA("Model") then
		local success, pivot = pcall(instance.GetPivot, instance)
		worldCFrame = success and pivot or CFrame.new()
	elseif instance:IsA("Attachment") then
		worldCFrame = instance.WorldCFrame
	else
		worldCFrame = instance.CFrame
	end

	if self._anchorSnapshot[instance] == nil and not self._links[instance] then
		self._anchorSnapshot[instance] = self:_captureAndAnchor(instance)
	else
		self:_captureAndAnchor(instance)
	end

	self._links[instance] = {
		target = target,
		mode = mode,
		offsetCF = linkCFrame:ToObjectSpace(worldCFrame),
		rotation = worldCFrame.Rotation,
		expiresAt = p3 and os.clock() + p3 or nil,
		partKind = _classifyPart1(instance)
	}
end

function LinkService:Clear(p)
	if not self._links[p] then
		return
	end

	self._links[p] = nil
	self:_restoreAnchor(p)
end

function LinkService:IsLinked(p2)
	return self._links[p2] ~= nil
end

function LinkService:_tick(_)
	local now = os.clock()

	for k, _link in pairs(self._links) do
		if k.Parent and _link.target.Parent then
			if _link.expiresAt and _link.expiresAt <= now then
				self:Clear(k)
			else
				local linkCFrame = PartConstants.resolveLinkCFrame(_link.target)
				local cFrame

				if _link.mode == "Weld" then
					cFrame = linkCFrame * _link.offsetCF
				else
					cFrame = CFrame.new((linkCFrame * _link.offsetCF).Position) * _link.rotation
				end

				if _link.partKind == "Model" then
					local v3 = k
					pcall(function()
						v3:PivotTo(cFrame)
					end)
				elseif _link.partKind == "Attachment" then
					local parent = k.Parent

					if parent and parent:IsA("BasePart") then
						k.CFrame = parent.CFrame:ToObjectSpace(cFrame)
					end
				else
					k.CFrame = cFrame
				end
			end
		else
			self:Clear(k)
		end
	end
end

return LinkService