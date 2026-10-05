local createVector = vector.create
DEFAULT_PARENT = workspace:WaitForChild("_WorldOrigin")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local Util2 = require(game.ReplicatedStorage.Util)
local renderDistance = Util2.RenderDistance
local v = {}

local function fn(data)
	local data2 = data.Data
	local tween = data2.Tween(math.min(data2.Time, data.ElapsedTime), 0, 1, data2.Time)

	if data.Mode == "Custom" then
		data2.Function(tween, data.ElapsedTime)
	else
		data.Object[data.Mode] = data2.From + tween * (data2.To - data2.From)
	end
end

local RunService = game:GetService("RunService")
RunService:BindToRenderStep("FXCreatorUpdater", 10050, function(p)
	for k, v2 in pairs(v) do
		v2.ElapsedTime += p
		local data = v2.Data

		if v2.Halt or v2.ElapsedTime < data.Time then
			if v2.Render:WithinRange(p) then
				fn(v2)
			end
		else
			if data.Completed then
				data.Completed()
			end

			v[k] = nil
		end
	end
end)
local v2 = {}
local v3 = {
	Ball = function(_)
		local part = v2.Create.Part()
		v2.Create.SpecialMesh({
			MeshType = "Sphere",
			Parent = part
		})
		return part
	end,
	Block = function(_)
		local part = v2.Create.Part()
		v2.Create.SpecialMesh({
			MeshType = "Brick",
			Parent = part
		})
		return part
	end
}
v2.Create = setmetatable({}, {
	__index = function(_, className)
		return function(options)
			local v4 = options or {}
			local v5 = v3[className]
			local instance

			if v5 then
				instance = v5(v4)
				instance.ClassName = className
			else
				instance = nil
			end

			if not instance then
				instance = Instance.new(className)

				if instance:IsA("BasePart") then
					instance.TopSurface = 0
					instance.BottomSurface = 0
					instance.Material = Enum.Material.SmoothPlastic
					instance.Anchored = true
					instance.CanCollide = false
					instance.Size = createVector(1, 1, 1)
				end
			end

			if v4 then
				if instance.ClassName == "SpecialMesh" then
					v4.Parent.InnerMesh = instance
				end

				local raw = v4.Parent and v4.Parent.Raw
				v4.Parent = nil

				for k, v6 in next, v4, nil do
					instance[k] = v6
				end

				instance.Parent = raw
			end

			if v5 then
				return instance
			end

			return (setmetatable({
				ClassName = className,
				InnerMesh = nil
			}, {
				__index = function(p, p2)
					if p2 == "Raw" then
						return instance
					elseif p2 == "SetDuration" then
						return function(_, p3)
							debris:AddItem(instance, p3)
						end
					elseif p2 == "AddToWorld" then
						return function(_)
							instance.Parent = DEFAULT_PARENT
						end
					elseif p2 == "Size" then
						return rawget(p, "InnerMesh") and rawget(p, "InnerMesh").Scale or instance.Size
					end

					local v6 = instance[p2]

					if type(v6) == "function" then
						return function(...)
							return v6(instance, select(2, ...))
						end
					end

					return v6
				end,
				__newindex = function(p, p2, scale)
					if p2 == "ClassName" or p2 == "InnerMesh" then
						rawset(p, p2, scale)
						return
					end

					local v6 = p2 == "Size" and rawget(p, "InnerMesh")

					if v6 then
						v6.Scale = scale
					else
						instance[p2] = scale
					end
				end
			}))
		end
	end
})

function v2.Animator(object, p2, p3, p4)
	return (setmetatable({}, {
		__index = function(_, mode)
			return function(state)
				if mode ~= "Custom" then
					state.From = state.From or object[mode]
				end

				state.Tween = state.Tween or v2.Tween.ease["in"].linear
				local v4 = typeof(object) == "table" and rawget(object, "RenderPoint") or object
				local v5 = {
					ElapsedTime = 0,
					Render = renderDistance.new(v4, p2, p3, p4),
					Object = object,
					Mode = mode,
					Data = state,
					Halt = state.Halt
				}
				table.insert(v, v5)
				fn(v5)
				return v5
			end
		end
	}))
end

local Util3 = require(game.ReplicatedStorage:WaitForChild("Util"))
v2.Tween = Util3.Tween

function v2.Distance(p)
	return renderDistance.value(p)
end

return {
	Build = function()
		return v2
	end
}