local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:_GetItem(p)
	for _, object in pairs(FighterController.Objects) do
		local item = object:GetItem(p)

		if item then
			return item
		end
	end
end

function class:_SetupWrap(instance, object)
	local v = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_wrap()
		WrapController:ResetWrap(v)
		v = WrapController:RecordOriginalWrapProperties(instance)
		WrapController:ApplyWrap(v, object:GetWrap(), true)
	end

	instance.DescendantAdded:Connect(function(descendant)
		if descendant:HasTag("Wrappable") then
			update_wrap() -- equivalent call inferred; original call site unknown
		end
	end)
	update_wrap() -- equivalent call inferred; original call site unknown
end

function class:_ObjectAdded(folder)
	folder:WaitForChild("Hitbox")
	local objectID = folder:GetAttribute("ObjectID")
	local hitboxDelay = folder:GetAttribute("HitboxDelay")
	local placedByUserID = folder:GetAttribute("PlacedByUserID")
	local teamID = folder:GetAttribute("TeamID")
	local _GetItem = self:_GetItem(objectID)

	if _GetItem then
		_GetItem.ViewModel:PlayHideMineSound(folder)
		self:_SetupWrap(folder, _GetItem)
	end

	local v = placedByUserID == Players.LocalPlayer.UserId or FighterController.LocalFighter and FighterController.LocalFighter:Get("TeamID") and FighterController.LocalFighter:Get("TeamID") == teamID
	local v2 = v and 0.5 or 1
	local halfHitboxDelay = hitboxDelay / 2
	local v4 = 0
	local v5 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_transparency(p)
		p.LocalTransparencyModifier = v5[p] and not v and 1 or v2 * v4
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function set(p)
		v4 = p

		for k in pairs(v5) do
			update_transparency(k) -- equivalent call inferred; original call site unknown
		end
	end

	local function add_object(descendant)
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
			v5[descendant] = descendant:HasTag("DontShowToEnemies") or false
			update_transparency(descendant) -- equivalent call inferred; original call site unknown
		end
	end

	folder.DescendantAdded:Connect(add_object)

	for _, descendant in pairs(folder:GetDescendants()) do
		add_object(descendant)
	end

	set(0) -- equivalent call inferred; original call site unknown
	wait(hitboxDelay / 2)
	local lastTime = tick()

	while folder:IsDescendantOf(workspace) and tick() < lastTime + halfHitboxDelay do
		set(math.clamp((tick() - lastTime) / halfHitboxDelay, 0, 1)) -- equivalent call inferred; original call site unknown
		RunService.RenderStepped:Wait()
	end

	set(1) -- equivalent call inferred; original call site unknown
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("SubspaceTripmine"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("SubspaceTripmine")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return class._new()