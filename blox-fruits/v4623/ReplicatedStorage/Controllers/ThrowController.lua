local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
local Future = require(game.ReplicatedStorage.Packages.Future)
require(game.ReplicatedStorage.Packages.SimpleError)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Trajectory = require(game.ReplicatedStorage.Util.Trajectory)
local Types = require(script.Types)
local Effects = require(script.Effects)
local v = nil
local class = {}
class.__index = class
class.MAX_SPEED_RBX = Effects.MAX_SPEED
class.MAX_RANGE_RBX = 300
class.Types = {
	ThrowData = Types.Types.ThrowData,
	ThrowableConfig = Types.Types.ThrowableConfig,
	AimData = Trajectory.Types.AimData,
	ImpactData = Types.Types.ImpactData
}
class.TAGS = {
	THROWABLE = "THROWABLE"
}
class.Remotes = {
	OnItemServerHit = Net:RemoteEvent("OnItemServerHit"),
	OnThrowReplicated = Net:RemoteEvent("OnThrowReplicated"),
	GetItemModels = Net:RemoteFunction("GetThrowableItemModels")
}

function class:_DrawThrow(data)
	local v2, v3 = class.Types.ThrowData(data)

	if not v2 then
		warn((`[ThrowController] Received invalid throw data: {v3}`))
		return
	end

	local character = data.Thrower.Character

	if not character then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart or (primaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local model = self:GetModel(data.Throwable.ItemName)

	if not model:isOk() then
		warn((`[ThrowController] Failed to get model for item "{data.Throwable.ItemName}": {model:unwrapErr().Message}`))
		return
	end

	local v4 = Effects.fire(character, model:unwrap(), data.Throwable, data.Aim, function(p)
		if p and data.Throwable.SplashEnabled ~= false then
			Effects.splash(p)
		end
	end)

	if v4:isErr() then
		warn((`[ThrowController] Failed to play throw effect: {v4:unwrapErr().Message}`))
		return
	end

	local unwrapped = v4:unwrap()

	if unwrapped.Type == "Async" then
		task.delay(10, unwrapped.CleanUp)
	end
end

function class.readConfig(tool)
	if not tool:IsA("Tool") then
		return Result.err({
			Type = "BadTool",
			Message = "Expected a Tool instance"
		})
	end

	if not tool:HasTag(class.TAGS.THROWABLE) then
		return Result.err({
			Type = "NotThrowable",
			Message = "Tool is not marked as throwable"
		})
	end

	local hitRadius = tool:GetAttribute("HitRadius")

	if type(hitRadius) ~= "number" or hitRadius <= 0 then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool is missing a valid HitRadius attribute"
		})
	end

	local influence = tool:GetAttribute("Influence")

	if typeof(influence) ~= "NumberSequence" then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool is missing a valid Influence attribute"
		})
	end

	local effectName = tool:GetAttribute("EffectName")

	if type(effectName) ~= "string" then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool is missing a valid EffectName attribute"
		})
	end

	local innerColor = tool:GetAttribute("InnerColor")

	if typeof(innerColor) ~= "Color3" then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool is missing a valid InnerColor attribute"
		})
	end

	local outerColor = tool:GetAttribute("OuterColor")

	if typeof(outerColor) ~= "Color3" then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool is missing a valid OuterColor attribute"
		})
	end

	local effectDuration = tool:GetAttribute("EffectDuration")

	if type(effectDuration) ~= "number" or effectDuration < 0 then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool is missing a valid EffectDuration attribute"
		})
	end

	local maxRange = tool:GetAttribute("MaxRange")

	if maxRange ~= nil and (type(maxRange) ~= "number" or maxRange <= 0) then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool has an invalid MaxRange attribute"
		})
	end

	local maxSpeed = tool:GetAttribute("MaxSpeed")

	if maxSpeed ~= nil and (type(maxSpeed) ~= "number" or maxSpeed <= 0) then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool has an invalid MaxSpeed attribute"
		})
	end

	local splashEnabled = tool:GetAttribute("SplashEnabled")

	if splashEnabled ~= nil and type(splashEnabled) ~= "boolean" then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool has an invalid SplashEnabled attribute"
		})
	end

	local throwIgnoreTag = tool:GetAttribute("ThrowIgnoreTag")

	if throwIgnoreTag ~= nil and (type(throwIgnoreTag) ~= "string" or throwIgnoreTag == "") then
		return Result.err({
			Type = "MissingAttributes",
			Message = "Tool has an invalid ThrowIgnoreTag attribute"
		})
	end

	local v2 = {
		ItemName = tool.Name,
		HitRadius = hitRadius,
		Influence = influence,
		EffectName = effectName,
		InnerColor = innerColor,
		OuterColor = outerColor,
		EffectDuration = effectDuration,
		MaxRange = maxRange,
		MaxSpeed = maxSpeed,
		SplashEnabled = splashEnabled,
		ThrowIgnoreTag = throwIgnoreTag
	}
	table.freeze(v2)
	return Result.ok(v2)
end

function class.getEquippedThrowableFromCharacter(instance)
	for _, tool in instance:GetChildren() do
		if not (tool:IsA("Tool") and tool:HasTag(class.TAGS.THROWABLE)) then
			continue
		end

		local config = class.readConfig(tool)

		if config:isErr() then
			return Result.err(config:unwrapErr())
		end

		return Result.ok(Option.some(tool))
	end

	return Result.ok(Option.none())
end

function class:Throw(p, callback)
	return Future.from(function()
		if not RunService:IsClient() then
			return Result.err({
				Type = "BadDomain",
				Message = "Throw can only be called from a client"
			})
		end

		if not self._IsAlive then
			return Result.err({
				Type = "ServiceUninitialized",
				Message = "ThrowController is not initialized"
			})
		end

		local v2, v3 = class.Types.ThrowData(p)

		if not v2 then
			return Result.err({
				Type = "InvalidAimData",
				Message = `Invalid aim data: {v3}`
			})
		end

		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			return Result.err({
				Type = "BadPlayerCharacter",
				Message = "No local player found"
			})
		end

		local character = localPlayer.Character

		if not character then
			return Result.err({
				Type = "BadPlayerCharacter",
				Message = "Player has no character"
			})
		end

		local equippedThrowableFromCharacter = class.getEquippedThrowableFromCharacter(character)

		if equippedThrowableFromCharacter:isErr() then
			return Result.err((equippedThrowableFromCharacter:unwrapErr()))
		end

		local unwrapped = equippedThrowableFromCharacter:unwrap()

		if unwrapped:isNone() then
			return Result.err({
				Type = "BadPlayerCharacter",
				Message = "Player is not holding a throwable tool"
			})
		end

		local unwrapped2 = unwrapped:unwrap()
		self:_DrawThrow(p)
		local v4 = callback(unwrapped2.Name, p.Aim)

		if v4 == nil then
			return Result.ok(Option.none())
		end

		if v4.Type == "ImpactData" then
			return Result.ok(Option.some(v4))
		end

		return Result.err(v4)
	end)
end

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if v == self then
		v = nil
	end

	for _, _Connection in self._Connections do
		_Connection:Disconnect()
	end

	if self._ThrowablesFolder then
		self._ThrowablesFolder:Destroy()
	end

	setmetatable(self, nil)
	table.clear(self)
end

function class:GetIfInitialized()
	if v == self and v and v._IsAlive then
		return true
	end

	return false
end

function class:GetModel(childName: string)
	if not RunService:IsClient() then
		return Result.err({
			Type = "BadDomain",
			Message = "Throw can only be called from a client"
		})
	end

	if not self._IsAlive then
		return Result.err({
			Type = "ServiceUninitialized",
			Message = "ThrowController is not initialized"
		})
	end

	if not self._ThrowablesFolder then
		return Result.err({
			Type = "MissingFolder",
			Message = "Throwable models folder is missing"
		})
	end

	local model = self._ThrowablesFolder:FindFirstChild(childName)

	if model and model:IsA("Model") then
		return Result.ok(model:Clone())
	end

	return Result.err({
		Type = "NoModelFound",
		Message = `No model found for item name "{childName}"`
	})
end

function class.init()
	local v2 = v

	if v2 and v2:GetIfInitialized() then
		return function()
			v2:Destroy()
		end
	end

	local object = setmetatable({
		_IsAlive = true,
		_Connections = {}
	}, class)
	task.spawn(function()
		local folder = class.Remotes.GetItemModels:InvokeServer()

		if object._IsAlive and folder and folder:IsA("Folder") then
			object._ThrowablesFolder = folder
		end
	end)
	table.insert(object._Connections, class.Remotes.OnThrowReplicated.OnClientEvent:Connect(function(p)
		if p.Thrower == Players.LocalPlayer then
			return
		end

		object:_DrawThrow(p)
	end))

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	v = object
	return function()
		object:Destroy()
	end
end

return ServiceProxy(function()
	return v or class
end)