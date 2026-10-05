local TweenService = game:GetService("TweenService")
local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Spritesheets)
local Util = {
	Types = {
		ImageData = Type.strictInterface({
			Image = Type.union(Type.string, function(p)
				if typeof(p) == "Content" then
					return true
				end

				return false, (`expected Content, got {typeof(p)}`)
			end),
			ImageRectOffset = Type.Vector2,
			ImageRectSize = Type.Vector2
		})
	}
}
local v = {
	number = function(p: number, p2: number, p3: number)
		return (math.lerp(p, p2, p3))
	end,
	boolean = function(flag: boolean, flag2: boolean, p: number)
		if p > 0.5 then
			return flag2
		end

		return flag
	end,
	string = function(p: string, p2: string, p3: number)
		if p3 > 0.5 then
			return p2
		end

		return p
	end,
	Color3 = function(color: Color3, color2: Color3, p: number)
		return color:Lerp(color2, p)
	end,
	Vector2 = function(point: Vector2, point2: Vector2, p: number)
		return point:Lerp(point2, p)
	end,
	UDim = function(udim: UDim, udim2: UDim, p: number)
		return UDim.new(math.lerp(udim.Scale, udim2.Scale, p), (math.lerp(udim.Offset, udim2.Offset, p)))
	end,
	UDim2 = function(udim: UDim2, udim2: UDim2, p: number)
		return udim:Lerp(udim2, p)
	end
}
local object = setmetatable({}, {
	__mode = "k"
})

local function lerp(value, p, value2: number)
	local typeName = typeof(value)
	local v2 = v[typeName]

	if v2 ~= nil then
		return v2(value, p, value2)
	end

	error((`CANNOT TWEEN TYPE "{typeName}"`))
end

function Util.tweenBinding(object2, callback, p, p2: number, p3, p4)
	local typeName = typeof(p)
	local typeName2 = typeof(object2:getValue())

	if typeName ~= typeName2 then
		error((`TweenBinding failed because types don't match ({typeName2} != {typeName})`))
	end

	local v2 = object[object2]

	if v2 then
		pcall(task.cancel, v2)
	end

	object[object2] = task.spawn(function()
		local value = object2:getValue()
		local total = 0

		repeat
			local v3 = total / p2
			callback(lerp(value, p, TweenService:GetValue(v3, p3, p4)))
			total += task.wait()
		until v3 >= 1

		object[object2] = nil
		callback(p)
	end)
end

return Util