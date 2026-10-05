local createVector = vector.create
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = Util.Misc
local FX = require(game.ReplicatedStorage.FX)
local _ = workspace.Terrain
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local slash = FX:WaitForChild("Dough").Shockwaves.Slash.Slash
local v = {
	Shockwave = {
		"",
		"rbxassetid://10772868208",
		"rbxassetid://10772868208",
		"rbxassetid://10772868111",
		"rbxassetid://10772868111",
		"rbxassetid://10772868028",
		"rbxassetid://10772868028",
		"rbxassetid://10772868028",
		"rbxassetid://10772867913",
		"rbxassetid://10772867771",
		"rbxassetid://10772867613",
		"rbxassetid://10772867466",
		"rbxassetid://10772867360",
		"rbxassetid://10772867201",
		"rbxassetid://10772867076",
		"rbxassetid://10772866957",
		"rbxassetid://10772867076",
		"rbxassetid://10772867201",
		"rbxassetid://10772867360",
		"rbxassetid://10772866854",
		"rbxassetid://10772867466",
		"rbxassetid://10772867613",
		"rbxassetid://10772867771",
		"rbxassetid://10772866762",
		"rbxassetid://10772867913",
		"rbxassetid://10772868028",
		"rbxassetid://10772866676",
		"rbxassetid://10772866578",
		"rbxassetid://10772868111",
		"rbxassetid://10772868208",
		""
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function adjustColorToBrightness(data, value)
	local v2 = 0.49019607843137253 * (value or 1)
	return Color3.new(data.r + v2, data.g + v2, data.b + v2)
end

return function(data)
	local cFrame = data.CFrame
	local color = data.Color or Color3.new(1, 1, 1)
	local scale = data.Scale or 1
	local vectorOffset = data.VectorOffset or createVector(0, 0, 0)
	local transparency = data.Transparency or 0
	local brightness = data.Brightness or 1
	local duration = data.Duration or data.Lifetime or 1
	local rotationSpeed = data.RotationSpeed or 1
	local ease = data.Ease or { "out", "quad" }
	local player = data.player
	local race = data.race
	local v2 = scale
	local v3 = transparency
	local v4 = brightness
	local v5

	if typeof(color) == "table" then
		v5 = color[1]
		color = color[2]
	else
		v5 = color
	end

	if typeof(scale) == "table" then
		v2 = scale[1]
		scale = scale[2]
	end

	if typeof(transparency) == "table" then
		v3 = transparency[1]
		transparency = transparency[2]
	end

	if typeof(brightness) == "table" then
		v4 = brightness[1]
		brightness = brightness[2]
	end

	local clone = slash:Clone()

	if not clone.Mesh:GetAttribute("Scale") then
		clone.Mesh:SetAttribute("Scale", clone.Mesh.Scale)
	end

	local decal = clone.Decal
	decal.Color3 = adjustColorToBrightness(v5, v4)
	clone.Mesh.Scale = clone.Mesh:GetAttribute("Scale") * v2
	clone.CFrame = data.CFrame
	clone.Parent = _WorldOrigin

	if race == "Draco" then
		Util.ColorShiftObjectDescendants(clone, player, "DracoRaceVFXColors", true)
		Util.SyncColorsOnChange(clone, player, "DracoRaceVFXColors", true)
	end

	Util.Debris:AddItem(clone, duration + 1)
	local v7 = #v.Shockwave * 1 / 60
	local v8 = math.max(duration * v7, v7)
	local v9 = 0
	Util.DistributedLoop:add(function(p, p2)
		local v10 = math.min(1, p / v8)

		if not clone:IsDescendantOf(workspace) then
			return true
		end

		local v11 = Util.Tween.ease[ease[1]][ease[2]](v10, 0, 1, 1)
		v9 = v9 % 6.283185307179586 + rotationSpeed * 2 * 3.141592653589793 * (p2 / v8)

		if v2 ~= scale then
			local v12 = nil

			if typeof(v2) == "Vector3" then
				v12 = v2:Lerp(scale, v11)
			elseif typeof(v2) == "number" then
				v12 = Util.Tween.point(v2, scale, v11)
			end

			clone.Mesh.Scale = clone.Mesh:GetAttribute("Scale") * v12
		end

		if v3 ~= transparency then
			clone.Decal.Transparency = Util.Tween.point(v3, transparency, v11)
		end

		local v12 = v4

		if v4 ~= brightness then
			v12 = Util.Tween.point(v4, brightness, v11)
		end

		if v5 ~= color then
			local decal2 = clone.Decal
			decal2.Color3 = adjustColorToBrightness(v5:Lerp(color, v10), v12)
		end

		clone.Decal.Texture = v.Shockwave[math.clamp(math.floor(#v.Shockwave * v11), 1, #v.Shockwave)]
		clone.CFrame = cFrame * CFrame.Angles(0, v9, 0) + vectorOffset * v11

		if v10 ~= 1 then
			return
		end

		clone:Destroy()
		return true
	end)
end