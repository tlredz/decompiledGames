local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local color = Color3.fromRGB(180, 30, 30)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local function isInvisPart(instance)
	return CollectionService:HasTag(instance, "InvisPart")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setModelVisible(folder, flag: boolean)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") or flag and CollectionService:HasTag(part, "InvisPart") then
			continue
		end

		part.LocalTransparencyModifier = flag and 0 or 1
	end
end

local v = Component.new({
	Tag = "BellonaRoyalGuard",
	Ancestors = { Workspace }
})

local function tweenModelTransparency(folder, transparency: number)
	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and (transparency ~= 0 or not CollectionService:HasTag(part, "InvisPart"))) then
			continue
		end

		TweenService:Create(part, tweenInfo, {
			Transparency = transparency
		}):Play()
	end
end

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("Model") then
		return
	end

	self.guardId = instance:GetAttribute("GuardId")
	self.state = instance:GetAttribute("State")

	if not (self.guardId and self.state) then
		return
	end

	self.model = instance
	self.replion = Replion.Client:WaitReplion("BellonaRoyalGuards")
	self._originalColors = {}
	self._glowing = false
	self._wasCompleted = false
end

function v:_storeOriginalColors()
	if next(self._originalColors) then
		return
	end

	for _, part in ipairs(self.model:GetDescendants()) do
		if part:IsA("BasePart") then
			self._originalColors[part] = part.Color
		end
	end
end

function v:_setGlow(glowing: boolean)
	if self._glowing == glowing then
		return
	end

	self._glowing = glowing

	for k, _originalColor in pairs(self._originalColors) do
		if not k.Parent then
			continue
		end

		if glowing then
			_originalColor = color
		end

		k.Color = _originalColor
		local material

		if glowing then
			material = Enum.Material.Neon
		else
			material = Enum.Material.Slate
		end

		k.Material = material
	end
end

function v:_apply(flag: boolean?)
	if not (self.replion and self.model) then
		return
	end

	local wasCompleted = (self.replion:Get("RoyalGuards") or {})[self.guardId] == true

	if self.state == "Default" then
		if wasCompleted and not self._wasCompleted then
			if flag then
				local model = self.model

				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = 1
					end
				end
			else
				tweenModelTransparency(self.model, 1)
			end
		elseif not wasCompleted and self._wasCompleted then
			setModelVisible(self.model, true) -- equivalent call inferred; original call site unknown
		end

		for _, proximityPrompt in ipairs(self.model:GetDescendants()) do
			if proximityPrompt:IsA("ProximityPrompt") then
				proximityPrompt.Enabled = not wasCompleted
			end
		end

		if self.guardId == "Guard1" and not wasCompleted then
			self:_storeOriginalColors()
			self:_setGlow(Workspace:GetAttribute("WarSurgeActive") ~= nil)
		elseif self._glowing then
			self:_setGlow(false)
		end
	elseif self.state == "Completed" then
		if wasCompleted and not self._wasCompleted then
			if flag then
				setModelVisible(self.model, true) -- equivalent call inferred; original call site unknown
			else
				tweenModelTransparency(self.model, 0)
			end
		elseif not wasCompleted and self._wasCompleted then
			local model = self.model

			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 1
				end
			end
		end
	end

	self._wasCompleted = wasCompleted
end

function v:Start()
	if not self.replion then
		return
	end

	self._wasCompleted = (self.replion:Get("RoyalGuards") or {})[self.guardId] == true

	if self.state == "Default" then
		setModelVisible(self.model, not self._wasCompleted)
	elseif self.state == "Completed" then
		setModelVisible(self.model, self._wasCompleted)
	end

	self.trove:Add(self.replion:OnDataChange(function()
		self:_apply(false)
	end))
	self.trove:Add(Workspace:GetAttributeChangedSignal("WarSurgeActive"):Connect(function()
		self:_apply(false)
	end))
end

function v:Stop()
	if self._glowing then
		self:_setGlow(false)
	end

	self.trove:Clean()
end

return v