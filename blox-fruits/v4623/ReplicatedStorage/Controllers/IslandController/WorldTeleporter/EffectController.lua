local RunService = game:GetService("RunService")
local MeshScroller = require(script.MeshScroller)
local Profiles = require(script.Profiles)
local Groups = require(script.Groups)
local Shading = require(script.Shading)
local Motion = require(script.Motion)
local TeleportSequence = require(script.TeleportSequence)
local Template = require(script.Template)
local Ambience = require(script.Ambience)

function bindDestroying(instance, callback)
	local destroying = instance.Destroying

	if typeof(destroying) == "RBXScriptSignal" then
		return destroying:Connect(callback)
	end

	return nil
end

function refreshScene(data)
	Shading.apply(data._Scene, data._Time)
	data._Ambience:Apply(data._Scene.Profile.Ambient, data._Scene.Visibility.Ambient)
end

function applyProfile(data, p, flag: boolean?)
	data._Scene.Profile = Profiles.copy(p)
	Motion.tune(data._Springs, data._Scene.Profile)

	if flag then
		Motion.snap(data._Springs)
	end

	refreshScene(data)
	Motion.applyGeometry(data._Scene.Groups, data._Springs, data._MeshSpin)
end

function patchGlobal(p, flag: boolean?, callback)
	if p._IsDestroyed then
		return
	end

	local copy = Profiles.copy(p._Scene.Profile)
	callback(copy.Global)
	applyProfile(p, copy, flag)
end

function stepSpin(p, p2: number)
	local profile = p._Scene.Profile
	local result = {}

	for _, v in Profiles.MESH_KEYS do
		local mesh = p._Scene.Groups.Meshes[v]
		local v2 = profile.Meshes[v].SpinSpeed * profile.Global.Speed

		if not (mesh and v2 ~= 0) then
			continue
		end

		p._MeshSpin[mesh] = (p._MeshSpin[mesh] or 0) + math.rad(v2 * p2)
		result[v] = true
	end

	return result
end

local class = {}
class.__index = class

function class:GetProfile()
	return Profiles.copy(self._Scene.Profile)
end

function class:SetProfile(p2, flag: boolean?)
	if self._IsDestroyed then
		return
	end

	applyProfile(self, p2, flag)
end

function class:ApplyPreset(p: string, flag: boolean?)
	local v = Profiles.PRESETS[p]
	assert(v, (`unknown effect preset "{p}"`))
	self:SetProfile(v, flag)
end

function class.SetHeight(p, height: number, flag: boolean?)
	patchGlobal(p, flag, function(p2)
		p2.Height = height
	end)
end

function class.SetBrightness(p, brightness: number)
	patchGlobal(p, nil, function(p2)
		p2.Brightness = brightness
	end)
end

function class.SetOpacity(p, opacity: number)
	patchGlobal(p, nil, function(p2)
		p2.Opacity = opacity
	end)
end

function class.SetSpeed(p, speed: number)
	patchGlobal(p, nil, function(p2)
		p2.Speed = speed
	end)
end

function class.SetTint(p, tint: Color3, tintAlpha: number)
	patchGlobal(p, nil, function(p2)
		p2.Tint = tint
		p2.TintAlpha = tintAlpha
	end)
end

function class.SetMotion(p, p2)
	patchGlobal(p, nil, function(p3)
		p3.Motion = table.clone(p2)
	end)
end

function class:GetVisibility()
	return Groups.copyVisibility(self._Scene.Visibility)
end

function class:SetVisibility(p2)
	if self._IsDestroyed then
		return
	end

	self._Scene.Visibility = Groups.copyVisibility(p2)
	refreshScene(self)
end

function class:SetVisible(flag: boolean)
	self:SetVisibility(Groups.fillVisibility(flag))
end

function class:GetCounts()
	return Groups.count(self._Scene.Groups)
end

function class:SetPaused(isPaused: boolean)
	self._IsPaused = isPaused
end

function class:CollapseHeights(value: number?)
	if self._IsDestroyed then
		return
	end

	Motion.collapseHeights(self._Springs, value or 0)
	Motion.tune(self._Springs, self._Scene.Profile)
	self._IsGeometryDirty = true
end

function class:IsSettled()
	return Motion.isSettled(self._Springs)
end

function class:Step(p: number)
	if self._IsDestroyed or self._IsPaused then
		return
	end

	self._Time += p
	self._Scene.Scroller:Step(p)
	local v = Motion.step(self._Springs, p)
	local v2 = stepSpin(self, p)

	if v or self._IsGeometryDirty then
		self._IsGeometryDirty = false
		Motion.applyGeometry(self._Scene.Groups, self._Springs, self._MeshSpin)
	else
		for k in v2 do
			Motion.applyMeshGeometry(self._Scene.Groups, self._Springs, self._MeshSpin, k)
		end
	end

	Shading.stepPulses(self._Scene, self._Time)
end

function class:Teleport(p2, callback)
	assert(not self._IsDestroyed, "effect controller destroyed")
	return TeleportSequence.play(self.Instance, p2, callback)
end

function class:Destroy()
	if self._IsDestroyed then
		return
	end

	self._IsDestroyed = true

	for _, _Connection in self._Connections do
		_Connection:Disconnect()
	end

	table.clear(self._Connections)
	self._Ambience:Destroy()
	self._Scene.Scroller:Destroy()

	if self._OwnsInstance then
		self.Instance:Destroy()
	else
		Groups.restoreAll(self._Scene.Groups)
	end
end

local function new(copy, p)
	local groups = Groups.collect(copy)
	local copy2 = Profiles.copy(p or Profiles.DEFAULT)
	local object = setmetatable({
		Instance = copy,
		_Scene = {
			Groups = groups,
			Profile = copy2,
			Visibility = Groups.fillVisibility(true),
			Scroller = MeshScroller.new(copy)
		},
		_Ambience = Ambience.new(groups.Anchor.Part),
		_Springs = Motion.build(copy2),
		_MeshSpin = {},
		_Connections = {},
		_Time = 0,
		_IsPaused = false,
		_IsGeometryDirty = false,
		_IsDestroyed = false,
		_OwnsInstance = false
	}, class)
	applyProfile(object, copy2, true)
	table.insert(object._Connections, RunService.Heartbeat:Connect(function(dt: number)
		object:Step(dt)
	end))
	local v2 = bindDestroying(copy, function()
		object:Destroy()
	end)

	if v2 then
		table.insert(object._Connections, v2)
	end

	return object
end

local EffectController = {}
EffectController.Profiles = Profiles

function EffectController.allVisible()
	return Groups.fillVisibility(true)
end

EffectController.new = new

function EffectController.fromTemplate(p, parent, p2, flag: boolean?)
	local copy = Template.copy(p)
	local success, result = pcall(function()
		local v = new(copy, p2)
		v._OwnsInstance = true

		if flag == false then
			v:SetVisible(false)
		end

		copy.Parent = parent
		return v
	end)

	if not success then
		copy:Destroy()
		error(result, 0)
	end

	return result
end

EffectController.copyTemplate = Template.copy
return EffectController