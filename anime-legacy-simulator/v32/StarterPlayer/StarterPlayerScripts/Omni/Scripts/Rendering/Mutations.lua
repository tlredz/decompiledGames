local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(ReplicatedStorage.Omni.Shared.Mutations.Visuals)
local mutations = module.Assets:WaitForChild("Effects"):WaitForChild("Mutations")
local cache = workspace:WaitForChild("Cache")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local folder = nil
local renderSteppedConnection = nil
local v5 = 0
local Mutations = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsLowMode()
	return not (module.Data and module.Data.Settings) or module.Data.Settings["Low Mode"] == true
end

local function IsContextVisible(data)
	local data2 = module.Data

	if not (data2 and data2.Maps) then
		return false
	end

	local v6

	if typeof(data2.Gamemode) == "string" and data2.Gamemode ~= "" and typeof(data2.GamemodeSession) == "string" then
		v6 = data2.GamemodeSession ~= ""
	else
		v6 = false
	end

	if v6 then
		return data.SessionID == data2.GamemodeSession and data.Gamemode == data2.Gamemode
	else
		local v7 = data.SessionID == nil or data.SessionID == "Global"
		local v8 = data.Gamemode == nil or data.Gamemode == ""
		return v7 and v8 and data.MapName == data2.Maps.Current
	end
end

local function IsNear(vector: Vector3)
	local currentCamera = workspace.CurrentCamera
	return currentCamera ~= nil and (currentCamera.CFrame.Position - vector).Magnitude <= Visuals.MaximumDistance
end

local function GetState(instance)
	local attribute = instance:GetAttribute(Visuals.StateAttribute)

	if typeof(attribute) ~= "string" then
		return {}
	end

	local success, result = pcall(module.Services.HttpService.JSONDecode, module.Services.HttpService, attribute)

	if success and typeof(result) == "table" then
		return result
	end

	return {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetScale(entity)
	return entity.Model:GetScale() / (entity.BaseScale or 1)
end

local function IsEntityVisible(record)
	local entity = record.Entity

	if entity.Destroyed or entity.PreDestroyed or not entity.Instance.Parent then
		return false
	end

	if not (entity.Model:IsDescendantOf(workspace) and entity.HRP.Parent) or record.Kind == "Enemy" and entity.Instance:GetAttribute("Died") then
		return false
	end

	local position = entity.HRP.Position
	local currentCamera = workspace.CurrentCamera
	local v6

	if currentCamera == nil then
		v6 = false
	else
		v6 = (currentCamera.CFrame.Position - position).Magnitude <= Visuals.MaximumDistance
	end

	if not v6 then
		return false
	end

	if record.Kind == "Enemy" then
		v4.MapName = entity.Instance:GetAttribute("MapName")
		v4.Gamemode = entity.Instance:GetAttribute("Gamemode")
		v4.SessionID = entity.Instance:GetAttribute("SessionID")
		return (IsContextVisible(v4))
	else
		if not (record.State.Context and IsContextVisible(record.State.Context)) then
			return false
		end

		local character = entity.Owner and entity.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoidRootPart == nil or humanoid == nil or not (humanoid.Health > 0) then
			return false
		else
			local position2 = humanoidRootPart.Position
			local currentCamera2 = workspace.CurrentCamera

			if currentCamera2 == nil then
				return false
			else
				return (currentCamera2.CFrame.Position - position2).Magnitude <= Visuals.MaximumDistance
			end
		end
	end
end

local function HasState(p)
	local state = p.State

	if p.Kind == "Fighter" then
		return state.Names ~= nil and next(state.Names) ~= nil
	else
		return state.Effects ~= nil and next(state.Effects) ~= nil
	end
end

local function ScaleSequence(size, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in size.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function SetScale(state, p: number)
	local scale = math.max(0.01, p)

	if state.Scale == scale then
		return
	end

	state.Scale = scale

	for _, property in state.Properties do
		local node = property.Node

		if node:IsA("BasePart") then
			node.Size = property.Size * scale
		elseif node:IsA("Attachment") then
			node.Position = property.Position * scale
		elseif node:IsA("ParticleEmitter") then
			node.Size = ScaleSequence(property.Size, scale)
			node.Speed = NumberRange.new(property.Speed.Min * scale, property.Speed.Max * scale)
			node.Acceleration = property.Acceleration * scale
		elseif node:IsA("Beam") then
			node.Width0 = property.Width0 * scale
			node.Width1 = property.Width1 * scale
			node.CurveSize0 = property.CurveSize0 * scale
			node.CurveSize1 = property.CurveSize1 * scale
		elseif node:IsA("SpecialMesh") then
			node.Scale = property.Scale * scale
			node.Offset = property.Offset * scale
		end
	end
end

local function IsPlaced(cframe: CFrame, cframe2: CFrame)
	if (cframe2.Position - cframe.Position).Magnitude > Visuals.PlaceTolerance or (cframe2.LookVector - cframe.LookVector).Magnitude > Visuals.PlaceTolerance then
		return false
	end

	return (cframe2.UpVector - cframe.UpVector).Magnitude <= Visuals.PlaceTolerance
end

local function PositionGroup(state, pivot: CFrame, scale: number)
	if state.Scale == scale and state.Pivot then
		local pivot2 = state.Pivot
		local v6

		if (pivot.Position - pivot2.Position).Magnitude > Visuals.PlaceTolerance or (pivot.LookVector - pivot2.LookVector).Magnitude > Visuals.PlaceTolerance then
			v6 = false
		else
			v6 = (pivot.UpVector - pivot2.UpVector).Magnitude <= Visuals.PlaceTolerance
		end

		if v6 then
			return
		end
	end

	state.Pivot = pivot
	state.Scale = scale

	for _, part in state.Parts do
		part.Node.CFrame = pivot * CFrame.new(part.Offset.Position * scale) * part.Offset.Rotation
	end
end

local function RemoveEntry(state)
	if state.Destroyed then
		return
	end

	state.Destroyed = true
	v2[state] = nil
	table.clear(state.Pending)

	if state.Tween then
		state.Tween:Cancel()
		state.Tween = nil
	end

	if state.Record and state.Record.Effects[state.Name] == state then
		state.Record.Effects[state.Name] = nil
	end

	state.Holder:Destroy()
end

local function FadeAngel(state, flag: boolean)
	if not state.Angel then
		return
	end

	if state.Tween then
		state.Tween:Cancel()
	end

	local angelFadeIn

	if flag then
		angelFadeIn = Visuals.AngelFadeIn
	else
		angelFadeIn = Visuals.AngelFadeOut
	end

	local v6

	if flag then
		v6 = Enum.EasingDirection.Out
	else
		v6 = Enum.EasingDirection.In
	end

	state.Tween = module.Services.TweenService:Create(
		state.Angel,
		TweenInfo.new(angelFadeIn, Enum.EasingStyle.Quad, v6),
		{
			Transparency = not flag and 1 or state.AngelTransparency
		}
	)
	state.Tween:Play()
end

local function SetRunning(effect, running: boolean)
	if effect.Running == running then
		return
	end

	effect.Running = running
	table.clear(effect.Pending)

	if running then
		effect.RemoveAt = nil

		for _, emitter in effect.Emitters do
			table.insert(effect.Pending, {
				Node = emitter,
				At = os.clock() + (emitter:GetAttribute("EmitDelay") or 0),
				Continuous = true
			})
		end
	else
		effect.RemoveAt = os.clock() + effect.Tail + Visuals.CleanupPadding

		for _, emitter in effect.Emitters do
			emitter.Enabled = false
		end
	end

	FadeAngel(effect, running)
end

local function GetRoot()
	if folder and folder.Parent then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = "Mutations"
	folder:SetAttribute(Visuals.ManagedAttribute, true)
	folder.Parent = cache
	return folder
end

local function CreateEntry(name: string, scale: number, cframe: CFrame, cframe2: CFrame?)
	local v6 = Visuals.List[name]
	local child = v6 and mutations:FindFirstChild(v6.Folder)

	if child and v6.Template then
		child = child:FindFirstChild(v6.Template)
	end

	if not child then
		return nil
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = name
	folder2:SetAttribute(Visuals.ManagedAttribute, true)
	local clone = child:Clone()
	clone.Parent = folder2
	local result = {
		Name = name,
		Holder = folder2,
		Groups = {},
		Properties = {},
		Emitters = {},
		Beams = {},
		Pending = {},
		Tail = 0,
		BurstTail = 0,
		Origin = cframe,
		Target = cframe2
	}

	for _, model in v6.Beam and { clone.Part1, clone.Part2 } or { clone } do
		local pivot

		if model:IsA("Model") then
			pivot = model:GetPivot()
		else
			pivot = model.CFrame
		end

		local descendants = model:GetDescendants()
		table.insert(descendants, model)
		local v7 = {
			Parts = {}
		}

		for _, part in descendants do
			if part:IsA("BasePart") then
				table.insert(v7.Parts, {
					Node = part,
					Offset = pivot:ToObjectSpace(part.CFrame)
				})
			end
		end

		table.insert(result.Groups, v7)
	end

	for _, descendant in folder2:GetDescendants() do
		descendant:SetAttribute(Visuals.ManagedAttribute, true)
		local v7 = {
			Node = descendant
		}

		if descendant:IsA("BasePart") then
			v7.Size = descendant.Size
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = false

			if name == "Light" and descendant.Name == "Angel" then
				result.Angel = descendant
				result.AngelTransparency = descendant.Transparency
				descendant.Transparency = 1
			end
		elseif descendant:IsA("Attachment") then
			v7.Position = descendant.Position
		elseif descendant:IsA("ParticleEmitter") then
			v7.Size = descendant.Size
			v7.Speed = descendant.Speed
			v7.Acceleration = descendant.Acceleration
			descendant.Enabled = false
			result.Tail = math.max(result.Tail, descendant.Lifetime.Max)
			result.BurstTail = math.max(
				result.BurstTail,
				(descendant:GetAttribute("EmitDelay") or 0) + descendant.Lifetime.Max
			)
			table.insert(result.Emitters, descendant)
		elseif descendant:IsA("Beam") then
			v7.Width0 = descendant.Width0
			v7.Width1 = descendant.Width1
			v7.CurveSize0 = descendant.CurveSize0
			v7.CurveSize1 = descendant.CurveSize1
			descendant.Enabled = false
			table.insert(result.Beams, descendant)
		else
			if not descendant:IsA("SpecialMesh") then
				continue
			end

			v7.Scale = descendant.Scale
			v7.Offset = descendant.Offset
		end

		table.insert(result.Properties, v7)
	end

	SetScale(result, scale)
	PositionGroup(result.Groups[1], cframe, scale)

	if result.Groups[2] then
		PositionGroup(result.Groups[2], cframe2 or cframe, scale)
	end

	if not (folder and folder.Parent) then
		folder = Instance.new("Folder")
		folder.Name = "Mutations"
		folder:SetAttribute(Visuals.ManagedAttribute, true)
		folder.Parent = cache
	end

	folder2.Parent = folder
	v2[result] = true
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearRecord(p)
	for _, effect in p.Effects do
		RemoveEntry(effect)
	end
end

local function RefreshRecord(record)
	if next(record.Effects) == nil then
		local state = record.State
		local v6

		if record.Kind == "Fighter" then
			if state.Names == nil then
				v6 = false
			else
				v6 = next(state.Names) ~= nil
			end
		elseif state.Effects == nil then
			v6 = false
		else
			v6 = next(state.Effects) ~= nil
		end

		if not v6 then
			return
		end
	end

	if not module.Data or not module.Data.Settings or module.Data.Settings["Low Mode"] == true or not IsEntityVisible(record) then
		ClearRecord(record) -- equivalent call inferred; original call site unknown
	else
		local state = record.State
		local scale = GetScale(record.Entity) -- equivalent call inferred; original call site unknown
		local serverTimeNow = workspace:GetServerTimeNow()
		table.clear(v3)

		if record.Kind == "Fighter" then
			for _, v7 in state.Names or {} do
				local v8 = Visuals.List[v7]

				if v8 and (v8.Passive or v8.Buff and state.Buff == v7 and serverTimeNow < (state.ExpiresAt or 0)) then
					v3[v7] = true
				end
			end
		else
			for k, v7 in state.Effects or {} do
				if Visuals.List[k] and v7.Stacks > 0 and (not v7.ExpiresAt or serverTimeNow < v7.ExpiresAt) then
					v3[k] = true
				end
			end
		end

		for k in v3 do
			local effect = record.Effects[k]

			if not effect then
				effect = CreateEntry(k, scale, record.Entity.HRP.CFrame)

				if effect then
					effect.Record = record
					record.Effects[k] = effect
				end
			end

			if effect then
				SetRunning(effect, true)
			end
		end

		for k, effect in record.Effects do
			if not v3[k] and effect.Running ~= false then
				effect.Running = false
				table.clear(effect.Pending)
				effect.RemoveAt = os.clock() + effect.Tail + Visuals.CleanupPadding

				for _, emitter in effect.Emitters do
					emitter.Enabled = false
				end

				FadeAngel(effect, false)
			end

			SetScale(effect, scale)
		end
	end
end

local function ResolveEndpoint(p)
	local v6 = v["Enemy:" .. p.ID]

	if v6 and v6.State.Revision ~= p.Revision then
		return nil, false
	end

	if v6 and not v6.Entity.Destroyed and not v6.Entity.PreDestroyed and v6.Entity.HRP.Parent and not v6.Entity.Instance:GetAttribute("Died") then
		return v6.Entity.HRP.CFrame, true
	end

	return nil, true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Stop()
	if not renderSteppedConnection then
		return
	end

	renderSteppedConnection:Disconnect()
	renderSteppedConnection = nil
end

local function Step()
	local now = os.clock()
	local v6 = not module.Data or not module.Data.Settings or module.Data.Settings["Low Mode"] == true

	if now - v5 >= Visuals.RefreshInterval then
		v5 = now

		for _, v7 in v do
			RefreshRecord(v7)
		end
	end

	for k in v2 do
		if v6 or k.RemoveAt and k.RemoveAt <= now then
			RemoveEntry(k)
		else
			local v7

			if k.Record then
				local entity = k.Record.Entity

				if entity.Destroyed or entity.PreDestroyed or not entity.HRP.Parent then
					RemoveEntry(k)
				else
					k.Origin = entity.HRP.CFrame
					PositionGroup(k.Groups[1], k.Origin, k.Scale)

					if k.Groups[2] then
						PositionGroup(k.Groups[2], k.Target, k.Scale)
					end

					for i = #k.Pending, 1, -1 do
						v7 = k.Pending[i]

						if now < v7.At then
							continue
						end

						if v7.Continuous then
							v7.Node.Enabled = true
						else
							v7.Node:Emit(v7.Node:GetAttribute("EmitCount") or v7.Node.Rate)
						end

						table.remove(k.Pending, i)
					end

					if k.BeamUntil and k.BeamUntil <= now then
						k.BeamUntil = nil

						for k2, beam in k.Beams do
							beam.Enabled = false
						end
					end
				end
			else
				if k.Event then
					local event = k.Event

					if not IsContextVisible(event.Origin) or event.Target and not IsContextVisible(event.Target) then
						RemoveEntry(k)
						continue
					end

					local v8, v9 = ResolveEndpoint(event.Origin)
					local v10, v11

					if event.Target then
						v10, v11 = ResolveEndpoint(event.Target)
					end

					if not v9 or v11 == false then
						RemoveEntry(k)
						continue
					end

					if Visuals.List[k.Name].Beam then
						k.Origin = v8 or k.Origin
						k.Target = v10 or k.Target
					end

					local position = k.Origin.Position
					local currentCamera = workspace.CurrentCamera
					local v12

					if currentCamera == nil then
						v12 = false
					else
						v12 = (currentCamera.CFrame.Position - position).Magnitude <= Visuals.MaximumDistance
					end

					if not v12 then
						if k.Target then
							local position2 = k.Target.Position
							local currentCamera2 = workspace.CurrentCamera
							local v13

							if currentCamera2 == nil then
								v13 = false
							else
								v13 = (currentCamera2.CFrame.Position - position2).Magnitude <= Visuals.MaximumDistance
							end

							if v13 then
								PositionGroup(k.Groups[1], k.Origin, k.Scale)

								if k.Groups[2] then
									PositionGroup(k.Groups[2], k.Target, k.Scale)
								end

								for i = #k.Pending, 1, -1 do
									v7 = k.Pending[i]

									if now < v7.At then
										continue
									end

									if v7.Continuous then
										v7.Node.Enabled = true
									else
										v7.Node:Emit(v7.Node:GetAttribute("EmitCount") or v7.Node.Rate)
									end

									table.remove(k.Pending, i)
								end

								if k.BeamUntil and k.BeamUntil <= now then
									k.BeamUntil = nil

									for k2, beam in k.Beams do
										beam.Enabled = false
									end
								end

								continue
							end
						end

						RemoveEntry(k)
						continue
					end
				end

				PositionGroup(k.Groups[1], k.Origin, k.Scale)

				if k.Groups[2] then
					PositionGroup(k.Groups[2], k.Target, k.Scale)
				end

				for i = #k.Pending, 1, -1 do
					v7 = k.Pending[i]

					if now < v7.At then
						continue
					end

					if v7.Continuous then
						v7.Node.Enabled = true
					else
						v7.Node:Emit(v7.Node:GetAttribute("EmitCount") or v7.Node.Rate)
					end

					table.remove(k.Pending, i)
				end

				if k.BeamUntil and k.BeamUntil <= now then
					k.BeamUntil = nil

					for k2, beam in k.Beams do
						beam.Enabled = false
					end
				end
			end
		end
	end

	if next(v2) == nil and next(v) == nil then
		Stop() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Start()
	if renderSteppedConnection then
		return
	end

	renderSteppedConnection = module.Services.RunService.RenderStepped:Connect(Step)
end

function Mutations.Attach(kind: string, entity)
	local v6 = kind .. ":" .. entity.ID
	local v7 = v[v6]

	if v7 then
		Mutations.Detach(kind, v7.Entity)
	end

	local record = {
		Kind = kind,
		Entity = entity,
		State = GetState(entity.Instance),
		Effects = {}
	}
	v[v6] = record
	record.Connection = entity.Instance.AttributeChanged:Connect(function(p3)
		if p3 == Visuals.StateAttribute then
			local state = GetState(entity.Instance)

			if state.Revision ~= record.State.Revision then
				ClearRecord(record) -- equivalent call inferred; original call site unknown
			end

			record.State = state
		end

		if p3 == Visuals.StateAttribute or p3 == "Died" then
			RefreshRecord(record)
		end
	end)
	RefreshRecord(record)
	Start() -- equivalent call inferred; original call site unknown
end

function Mutations.Detach(p: string, p2)
	local v6 = p .. ":" .. p2.ID
	local v7 = v[v6]

	if not v7 or v7.Entity ~= p2 then
		return
	end

	v7.Connection:Disconnect()
	ClearRecord(v7) -- equivalent call inferred; original call site unknown
	v[v6] = nil
end

function Mutations.Pulse(name: string, event)
	local v6 = Visuals.List[name]

	if not (v6 and v6.Burst) or not module.Data or not module.Data.Settings or module.Data.Settings["Low Mode"] == true then
		return
	end

	if typeof(event) ~= "table" or typeof(event.Origin) ~= "table" then
		return
	end

	if typeof(event.Time) ~= "number" or math.abs(workspace:GetServerTimeNow() - event.Time) > 2 then
		return
	end

	if not IsContextVisible(event.Origin) or v6.Beam and not (event.Target and IsContextVisible(event.Target)) then
		return
	end

	local position = event.Origin.Position
	local currentCamera = workspace.CurrentCamera
	local v7

	if currentCamera == nil then
		v7 = false
	else
		v7 = (currentCamera.CFrame.Position - position).Magnitude <= Visuals.MaximumDistance
	end

	local v8, v9, v10, v11, v12, entity, scale, v13

	if v7 then
		v8, v9 = ResolveEndpoint(event.Origin)

		if not v9 then
			return
		end

		if event.Target then
			v10, v11 = ResolveEndpoint(event.Target)

			if not v11 then
				return
			end
		end

		v12 = v["Enemy:" .. event.Origin.ID]

		if v12 then
			entity = v12.Entity
			scale = GetScale(entity)
		else
			scale = event.Origin.Scale or 1
		end

		v13 = CreateEntry(
			name,
			scale,
			v8 or CFrame.new(event.Origin.Position),
			v10 or event.Target and CFrame.new(event.Target.Position)
		)

		if not v13 then
			return
		end

		v13.Event = event
		v13.RemoveAt = os.clock() + math.max(v13.BurstTail, Visuals.BeamDuration) + Visuals.CleanupPadding

		for k, emitter in v13.Emitters do
			table.insert(v13.Pending, {
				Node = emitter,
				At = os.clock() + (emitter:GetAttribute("EmitDelay") or 0)
			})
		end

		if v6.Beam then
			v13.BeamUntil = os.clock() + Visuals.BeamDuration

			for k, beam in v13.Beams do
				beam.Enabled = true
			end
		end

		Start() -- equivalent call inferred; original call site unknown
	elseif event.Target then
		local position2 = event.Target.Position
		local currentCamera2 = workspace.CurrentCamera
		local v14

		if currentCamera2 == nil then
			v14 = false
		else
			v14 = (currentCamera2.CFrame.Position - position2).Magnitude <= Visuals.MaximumDistance
		end

		if v14 then
			v8, v9 = ResolveEndpoint(event.Origin)

			if not v9 then
				return
			end

			if event.Target then
				v10, v11 = ResolveEndpoint(event.Target)

				if not v11 then
					return
				end
			end

			v12 = v["Enemy:" .. event.Origin.ID]

			if v12 then
				entity = v12.Entity
				scale = GetScale(entity)
			else
				scale = event.Origin.Scale or 1
			end

			v13 = CreateEntry(
				name,
				scale,
				v8 or CFrame.new(event.Origin.Position),
				v10 or event.Target and CFrame.new(event.Target.Position)
			)

			if not v13 then
				return
			end

			v13.Event = event
			v13.RemoveAt = os.clock() + math.max(v13.BurstTail, Visuals.BeamDuration) + Visuals.CleanupPadding

			for k, emitter in v13.Emitters do
				table.insert(v13.Pending, {
					Node = emitter,
					At = os.clock() + (emitter:GetAttribute("EmitDelay") or 0)
				})
			end

			if v6.Beam then
				v13.BeamUntil = os.clock() + Visuals.BeamDuration

				for k, beam in v13.Beams do
					beam.Enabled = true
				end
			end

			Start() -- equivalent call inferred; original call site unknown
		end
	end
end

function Mutations.Refresh()
	for _, v6 in v do
		RefreshRecord(v6)
	end

	if IsLowMode() then
		for k in v2 do
			RemoveEntry(k)
		end
	end
end

function Mutations.Destroy()
	for _, v6 in v do
		v6.Connection:Disconnect()
	end

	table.clear(v)

	for k in v2 do
		RemoveEntry(k)
	end

	Stop() -- equivalent call inferred; original call site unknown

	if folder then
		folder:Destroy()
		folder = nil
	end
end

module:OnDataChanged({ "Settings", "Low Mode" }, Mutations.Refresh)
script.Destroying:Connect(Mutations.Destroy)
return Mutations