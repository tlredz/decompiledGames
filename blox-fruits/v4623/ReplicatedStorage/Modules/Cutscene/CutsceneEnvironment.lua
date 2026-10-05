local v = {
	RunService = game:GetService("RunService")
}
local modules = {
	Maid = require(game.ReplicatedStorage.Util.Maid),
	Signal = require(game.ReplicatedStorage.Util.Signal)
}
require(script.Parent.Types)
local class = {}
class.__index = class
local v3 = {}
local cframe = CFrame.new(0, -1000000, 0)
local count = 0

function v3:cloneTemplate()
	local archivable = self.Archivable
	self.Archivable = true
	local success, result = pcall(self.Clone, self)
	self.Archivable = archivable

	if not success then
		error(`Failed to clone cutscene environment template "{self.Name}": {tostring(result)}`, 3)
	end

	return result
end

function v3.call(callback, ...)
	if callback == nil then
		return true, nil
	end

	local v4 = table.pack(...)
	local v5, v6 = xpcall(function()
		callback(table.unpack(v4, 1, v4.n))
	end, debug.traceback)

	if v5 then
		return v5, nil
	end

	return v5, (tostring(v6))
end

function v3.cleanupCallback(p, ...)
	local v4, v5 = v3.call(p, ...)

	if not v4 then
		warn((`[CutsceneEnvironment] Cleanup failed: {v5}`))
	end
end

function v3:materialize()
	if self._model then
		return
	end

	local model = Instance.new("Model")
	model.Name = `CutsceneEnvironment_{self._config.Name or self._id}`
	model:SetAttribute("CutsceneEnvironment", true)
	model:SetAttribute("Preloaded", true)
	local v4, v5 = v3.call(function()
		local template = self._config.Template

		if template then
			local template_2 = v3.cloneTemplate(template)
			template_2.Parent = model
		end

		local build = self._config.Build

		if build then
			build(model)
		end
	end)

	if not v4 then
		model:Destroy()
		error(v5 or "Cutscene environment failed to materialize", 3)
	end

	if self._config.CFrame then
		model:PivotTo(self._config.CFrame)
	end

	self._loadCFrame = model:GetPivot()
	model:PivotTo(self._config.PreloadCFrame or cframe)
	model.Parent = workspace
	self._model = model
	self._maid.Model = model
end

function class.new(options)
	assert(v.RunService:IsClient(), "CutsceneEnvironment can only be constructed on the client")
	count += 1
	local maid = modules.Maid.new()
	local signal = modules.Signal()
	local self = setmetatable({
		_maid = maid,
		_runtimeMaid = nil,
		_config = options or {},
		_model = nil,
		_loadCFrame = CFrame.identity,
		_id = count,
		_loaded = false,
		_destroyed = false,
		Failed = signal
	}, class)
	maid:GiveTask(signal)
	return self
end

function class.is(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function class:GetModel()
	self:Preload()
	return self._model
end

function class:GetPivot()
	self:Preload()
	return self._loadCFrame
end

function class:IsLoaded()
	return self._loaded
end

function class:Preload()
	assert(not self._destroyed, "CutsceneEnvironment is destroyed")
	v3.materialize(self)
	return self
end

function class:Load()
	assert(not self._destroyed, "CutsceneEnvironment is destroyed")
	self:Preload()

	if self._loaded then
		return self
	end

	local _model = self._model
	_model:PivotTo(self._loadCFrame)
	_model:SetAttribute("Preloaded", false)
	self._loaded = true
	local v4, v5 = v3.call(self._config.Loaded, _model)

	if v4 then
		v4, v5 = v3.call(self._config.Update, _model, 0)
	end

	if not v4 then
		v3.cleanupCallback(self._config.Unloaded, _model)
		self._loaded = false
		_model:SetAttribute("Preloaded", true)
		_model:PivotTo(self._config.PreloadCFrame or cframe)
		error(v5 or "Cutscene environment failed to load", 2)
	end

	local maid = modules.Maid.new()
	self._runtimeMaid = maid
	self._maid.Runtime = maid
	maid:GiveTask(v.RunService.RenderStepped:Connect(function(dt: number)
		self:RenderStepped(dt)
	end))
	return self
end

function class:Unload()
	if not self._loaded then
		return self
	end

	self._loaded = false
	self._runtimeMaid = nil
	self._maid.Runtime = nil
	local _model = self._model

	if not _model then
		return self
	end

	v3.cleanupCallback(self._config.Unloaded, _model)
	_model:SetAttribute("Preloaded", true)
	_model:PivotTo(self._config.PreloadCFrame or cframe)

	if _model.Parent == nil then
		_model.Parent = workspace
	end

	return self
end

function class:RenderStepped(p: number)
	if not self._loaded then
		return
	end

	local _model = self._model

	if not _model then
		return
	end

	local v4, v5 = v3.call(self._config.Update, _model, p)

	if v4 then
		return
	end

	local v6 = v5 or "Cutscene environment update failed"
	warn((`[CutsceneEnvironment] RenderStepped failed: {v6}`))
	self.Failed:Fire(v6)
	self:Unload()
end

function class:Destroy()
	if self._destroyed then
		return
	end

	self:Unload()
	self._destroyed = true
	local _model = self._model

	if _model then
		v3.cleanupCallback(self._config.Destroying, _model)
	end

	self._model = nil
	self._maid:DoCleaning()
end

return table.freeze(class)