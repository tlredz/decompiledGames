local createVector = vector.create
local parent = script.Parent
local RunService = game:GetService("RunService")
require(parent.Types)
local v = {}

local function getValue(instance, p: string, p2)
	return instance:GetAttribute((`__moonlite_{p}`)) or p2
end

local function setValue(instance, p: string, p2, p3)
	local formatted = `__moonlite_{p}`

	if p2 == p3 then
		p2 = nil
	end

	instance:SetAttribute(formatted, p2)
end

local function BoundProp(p)
	return function(p2, p3)
		assert(p.Get)
		return {
			Get = function()
				return p.Get(p2, p3)
			end,
			Set = function(p4)
				p.Set(p4, p2, p3)
			end
		}
	end
end

local function LazyAction(callback)
	return function(p)
		return {
			Default = false,
			Set = function(flag: boolean)
				if flag then
					callback(p)
				end
			end
		}
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCameraActive(state, activeCamera, flag: boolean)
	if flag and not state._cameraRenderBound then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCamera()
			local _cameraAttachToPart = state._cameraAttachToPart
			local _cameraLookAtPart = state._cameraLookAtPart

			if _cameraAttachToPart then
				local cFrame = _cameraAttachToPart.CFrame

				if _cameraLookAtPart then
					cFrame = CFrame.new(cFrame.Position, _cameraLookAtPart.Position)
				end

				activeCamera.CFrame = cFrame
			end
		end

		RunService:BindToRenderStep("MoonliteRenderCamera", 1000, updateCamera)
		state._cameraRenderBound = true
		updateCamera() -- equivalent call inferred; original call site unknown

		if not state.KeepCameraType then
			activeCamera.CameraType = Enum.CameraType.Scriptable
		end
	elseif not flag and state._cameraRenderBound then
		RunService:UnbindFromRenderStep("MoonliteRenderCamera")

		if not state.KeepCameraType then
			activeCamera.CameraType = Enum.CameraType.Custom
		end

		state._cameraRenderBound = false
	end
end

local v3 = {
	Get = function(_, p)
		return p._cameraAttachToPart
	end,
	Set = function(cameraAttachToPart, activeCamera, state)
		if cameraAttachToPart then
			state._activeCamera = activeCamera
			state._cameraAttachToPart = cameraAttachToPart
			setCameraActive(state, activeCamera, true) -- equivalent call inferred; original call site unknown
		else
			state._cameraAttachToPart = nil
			setCameraActive(state, activeCamera, false) -- equivalent call inferred; original call site unknown
		end
	end
}
local camera = {
	AttachToPart = function(p, p2)
		assert(v3.Get)
		return {
			Get = function()
				return v3.Get(p, p2)
			end,
			Set = function(p3)
				v3.Set(p3, p, p2)
			end
		}
	end,
	LookAtPart = 0
}
local v4 = {
	Get = function(_, p)
		return p._cameraLookAtPart
	end,
	Set = function(cameraLookAtPart, activeCamera, state)
		if cameraLookAtPart then
			state._activeCamera = activeCamera
			state._cameraLookAtPart = cameraLookAtPart
			setCameraActive(state, activeCamera, true) -- equivalent call inferred; original call site unknown

			if state._updateCamera then
				state._updateCamera()
			end
		else
			state._cameraLookAtPart = nil

			if not state._cameraAttachToPart and state._cameraRenderBound then
				RunService:UnbindFromRenderStep("MoonliteRenderCamera")

				if not state.KeepCameraType then
					activeCamera.CameraType = Enum.CameraType.Custom
				end

				state._cameraRenderBound = false
			end
		end
	end
}

function camera.LookAtPart(p, p2)
	assert(v4.Get)
	return {
		Get = function()
			return v4.Get(p, p2)
		end,
		Set = function(p3)
			v4.Set(p3, p, p2)
		end
	}
end

v.Camera = camera
v.Terrain = {}
local v5 = {
	Camera = {
		AttachToPart = true,
		LookAtPart = true
	},
	Humanoid = {
		AddAccessory = true,
		ChangeState = true,
		EquipTool = true,
		MoveTo = true,
		Move = true,
		PlayEmote = true,
		RemoveAccessories = true,
		TakeDamage = true,
		UnequipTools = true
	},
	ParticleEmitter = {
		Emit = true,
		Clear = true
	},
	Sound = {
		PlayOnce = true,
		SetTime = true,
		Play = true,
		Resume = true,
		Pause = true,
		Stop = true
	}
}

for _, v6 in Enum.Material:GetEnumItems() do
	local v7 = v6

	if not pcall(function()
		workspace.Terrain:GetMaterialColor(v7)
	end) then
		continue
	end

	local v8 = v6
	local v9 = v6
	local v11 = {
		Get = function(object)
			return object:GetMaterialColor(v8)
		end,
		Set = function(color: Color3, object)
			object:SetMaterialColor(v9, color)
		end
	}

	v.Terrain[`MC_{v6.Name}`] = function(p, p2)
		assert(v11.Get)
		return {
			Get = function()
				return v11.Get(p, p2)
			end,
			Set = function(p3)
				v11.Set(p3, p, p2)
			end
		}
	end
end

local color = Color3.new(1, 1, 1)
local v7 = {
	Get = function(instance)
		return instance:GetPivot()
	end,
	Set = function(cframe: CFrame, instance)
		instance:PivotTo(cframe)
	end
}
local model = {
	CFrame = function(p, p2)
		assert(v7.Get)
		return {
			Get = function()
				return v7.Get(p, p2)
			end,
			Set = function(p3)
				v7.Set(p3, p, p2)
			end
		}
	end,
	Color = 0,
	Scale = 0,
	Reflectance = 0,
	Transparency = 0
}
local v8 = {
	Get = function(instance)
		return instance:GetAttribute("__moonlite_Color") or color
	end,
	Set = function(color2: Color3, folder)
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			local color3 = part.Color
			local __moonlite_Color = part:GetAttribute("__moonlite_Color") or color3

			if __moonlite_Color == color2 then
				continue
			end

			local v10

			if color2 ~= __moonlite_Color then
				v10 = color2
			end

			part:SetAttribute("__moonlite_Color", v10)
			part.Color = color2
		end

		if color2 == color then
			color2 = nil
		end

		folder:SetAttribute("__moonlite_Color", color2)
	end
}

function model.Color(p, p2)
	assert(v8.Get)
	return {
		Get = function()
			return v8.Get(p, p2)
		end,
		Set = function(p3)
			v8.Set(p3, p, p2)
		end
	}
end

local v9 = {
	Get = function(object)
		return object:GetScale()
	end,
	Set = function(p: number, instance)
		instance:ScaleTo(p)
	end
}

function model.Scale(p, p2)
	assert(v9.Get)
	return {
		Get = function()
			return v9.Get(p, p2)
		end,
		Set = function(p3)
			v9.Set(p3, p, p2)
		end
	}
end

local v10 = {
	Get = function(instance)
		return instance:GetAttribute("__moonlite_Reflectance") or 0
	end,
	Set = function(p: number, folder)
		if (folder:GetAttribute("__moonlite_Reflectance") or 0) ~= p then
			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				local reflectance = part.Reflectance
				local __moonlite_BaseReflectance = part:GetAttribute("__moonlite_BaseReflectance") or reflectance
				part.Reflectance = __moonlite_BaseReflectance + (1 - __moonlite_BaseReflectance) * p
			end

			if p == 0 then
				p = nil
			end

			folder:SetAttribute("__moonlite_Reflectance", p)
		end
	end
}

function model.Reflectance(p, p2)
	assert(v10.Get)
	return {
		Get = function()
			return v10.Get(p, p2)
		end,
		Set = function(p3)
			v10.Set(p3, p, p2)
		end
	}
end

local v11 = {
	Get = function(instance)
		return instance:GetAttribute("__moonlite_Transparency") or 0
	end,
	Set = function(localTransparencyModifier: number, folder)
		if (folder:GetAttribute("__moonlite_Transparency") or 0) ~= localTransparencyModifier then
			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = localTransparencyModifier
				end
			end

			if localTransparencyModifier == 0 then
				localTransparencyModifier = nil
			end

			folder:SetAttribute("__moonlite_Transparency", localTransparencyModifier)
		end
	end
}

function model.Transparency(p, p2)
	assert(v11.Get)
	return {
		Get = function()
			return v11.Get(p, p2)
		end,
		Set = function(p3)
			v11.Set(p3, p, p2)
		end
	}
end

v.Model = model

local function fn(p)
	p.Jump = true
end

local humanoid = {
	AddAccessory = function(p)
		return {
			Default = nil,
			Set = function(p2)
				if p2 then
					pcall(p.AddAccessory, p, p2)
				end
			end
		}
	end,
	ChangeState = function(self)
		return {
			Default = Enum.HumanoidStateType.None,
			Set = function(p)
				self:ChangeState(p)
			end
		}
	end,
	EquipTool = function(p)
		return {
			Default = nil,
			Set = function(p2)
				if p2 then
					pcall(p.EquipTool, p, p2)
				end
			end
		}
	end,
	Jump = function(p)
		return {
			Default = false,
			Set = function(flag: boolean)
				if flag then
					fn(p)
				end
			end
		}
	end,
	MoveTo = function(self)
		local moveToDefault = self:GetAttribute("MoveToDefault")

		if typeof(moveToDefault) ~= "Vector3" then
			local rootPart = self.RootPart
			moveToDefault = not rootPart and createVector(0, 0, 0) or rootPart.Position
			self:SetAttribute("MoveToDefault", moveToDefault)
		end

		return {
			Default = moveToDefault,
			Set = function(position: Vector3)
				self:MoveTo(position)
			end
		}
	end,
	Move = function(self)
		local moveDefault = self:GetAttribute("MoveDefault")

		if typeof(moveDefault) ~= "Vector3" then
			local rootPart = self.RootPart
			moveDefault = not rootPart and createVector(0, 0, 0) or rootPart.CFrame.LookVector
			self:SetAttribute("MoveDefault", moveDefault)
		end

		return {
			Default = moveDefault,
			Set = function(vector2: Vector3)
				self:Move(vector2)
			end
		}
	end,
	PlayEmote = function(self)
		return {
			Default = "",
			Set = function(p: string)
				self:PlayEmote(p)
			end
		}
	end,
	RemoveAccessories = 0,
	Sit = 0,
	TakeDamage = 0,
	UnequipTools = 0
}

local function fn2(object)
	object:RemoveAccessories()
end

function humanoid:RemoveAccessories()
	return {
		Default = false,
		Set = function(flag: boolean)
			if flag then
				fn2(self)
			end
		end
	}
end

function humanoid:Sit()
	return {
		Set = function(sit: boolean)
			self.Sit = sit
		end
	}
end

function humanoid:TakeDamage()
	return {
		Set = function(p: number)
			self:TakeDamage(p)
		end
	}
end

local function fn3(object)
	object:UnequipTools()
end

function humanoid:UnequipTools()
	return {
		Default = false,
		Set = function(flag: boolean)
			if flag then
				fn3(self)
			end
		end
	}
end

v.Humanoid = humanoid

local function fn4(object)
	object:Clear()
end

v.ParticleEmitter = {
	Clear = function(self)
		return {
			Default = false,
			Set = function(flag: boolean)
				if flag then
					fn4(self)
				end
			end
		}
	end,
	Emit = function(self)
		local emitCount = self:GetAttribute("EmitCount")
		return {
			Default = type(emitCount) ~= "number" and 0 or emitCount,
			Set = function(p: number)
				if p > 0 then
					self:Emit(p)
				end
			end
		}
	end
}

local function fn5(instance)
	local clone = instance:Clone()
	clone.Parent = instance.Parent
	clone.PlayOnRemove = true
	clone:Destroy()
end

local sound = {
	PlayOnce = function(p)
		return {
			Default = false,
			Set = function(flag: boolean)
				if flag then
					fn5(p)
				end
			end
		}
	end,
	SetTime = function(self)
		return {
			Default = 0,
			Set = function(timePosition: number)
				self.TimePosition = timePosition
			end
		}
	end,
	Play = 0,
	Resume = 0,
	Pause = 0,
	Stop = 0
}

local function fn6(object)
	object:Play()
end

function sound:Play()
	return {
		Default = false,
		Set = function(flag: boolean)
			if flag then
				fn6(self)
			end
		end
	}
end

local function fn7(object)
	object:Resume()
end

function sound:Resume()
	return {
		Default = false,
		Set = function(flag: boolean)
			if flag then
				fn7(self)
			end
		end
	}
end

local function fn8(object)
	object:Pause()
end

function sound:Pause()
	return {
		Default = false,
		Set = function(flag: boolean)
			if flag then
				fn8(self)
			end
		end
	}
end

local function fn9(object)
	object:Stop()
end

function sound:Stop()
	return {
		Default = false,
		Set = function(flag: boolean)
			if flag then
				fn9(self)
			end
		end
	}
end

v.Sound = sound
local v15 = {}
local v16 = {}
local v17 = {}
local v18 = {
	__index = function(p, p2: string)
		local _target = p._target
		local className = _target.ClassName
		local v19 = v16[className]

		if v19 == nil then
			v19 = {}

			for className2, v20 in v do
				if not _target:IsA(className2) then
					continue
				end

				for k, v21 in v20 do
					v19[k] = v21
				end
			end

			v16[className] = v19
		end

		local v20 = v19[p2]
		local v21

		if v20 then
			v21 = v20(_target, p._work)
			rawset(p, p2, v21)
		end

		return v21
	end
}

local function get(work, instance, p2: string)
	local v19 = v17[instance]

	if not v19 then
		v19 = setmetatable({
			_target = instance,
			_work = work
		}, v18)
		instance.Destroying:Connect(function()
			if v17[instance] == v19 then
				v17[instance] = nil
			end
		end)
		v17[instance] = assert(v19)
	end

	return v19[p2]
end

local function static(instance, p: string)
	local className = instance.ClassName

	if v15[className] then
		return v15[className][p] == true
	end

	local v19 = {}

	for className2, v20 in pairs(v5) do
		if not instance:IsA(className2) then
			continue
		end

		for k, v21 in v20 do
			v19[k] = v21
		end
	end

	v15[className] = v19
	return v15[className][p] == true
end

return {
	Get = get,
	Static = static,
	Index = v
}