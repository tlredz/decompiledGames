local v = {
	"http://www.roblox.com/asset/?id=8080873815",
	"http://www.roblox.com/asset/?id=8080874285",
	"http://www.roblox.com/asset/?id=8080874625",
	"http://www.roblox.com/asset/?id=8080875235",
	"http://www.roblox.com/asset/?id=8080875698",
	"http://www.roblox.com/asset/?id=8080876182",
	"http://www.roblox.com/asset/?id=8080876640",
	"http://www.roblox.com/asset/?id=8080877157",
	"http://www.roblox.com/asset/?id=8080877620",
	"http://www.roblox.com/asset/?id=8080878132",
	"http://www.roblox.com/asset/?id=8080878548",
	"http://www.roblox.com/asset/?id=8080878963",
	"http://www.roblox.com/asset/?id=8080882774",
	"http://www.roblox.com/asset/?id=131719387"
}

local function func(state)
	if not state.CFrame then
		state.CFrame = CFrame.new()
	end

	state.RotSpeed = state.RotSpeed or 0
	local cFrame = state.CFrame
	local clone = script.template:Clone()
	clone.Mesh.TextureId = v[state.Start or 1]

	if state.VertexColor then
		clone.Mesh.VertexColor = state.VertexColor
	end

	if state.Scale then
		clone.Mesh.Scale = state.Scale
	end

	if state.Transparency then
		clone.Transparency = state.Transparency[1]
	end

	clone.CFrame = cFrame
	clone.Parent = workspace._WorldOrigin
	local scale = clone.Mesh.Scale
	local v2 = 0

	for i = state.Start or 1, #v, state.Step or 1 do
		if v2 > 0.03333333333333333 then
			v2 -= 0.016666666666666666
		else
			local v3 = i / #v
			clone.CFrame = cFrame * CFrame.Angles(
				0,
				4.1887902047863905 + -(1.0471975511965976 + state.RotSpeed) * v3,
				0
			)
			clone.Mesh.TextureId = v[i]

			if state.GrowScale then
				clone.Mesh.Scale = scale + scale * (state.GrowScale - 1) * v3
			end

			if state.Transparency then
				clone.Transparency = state.Transparency[1] + (state.Transparency[2] - state.Transparency[1]) * v3
			end

			if state.FinalVertexColor then
				clone.Mesh.VertexColor = state.VertexColor:Lerp(state.FinalVertexColor, v3)
			end

			v2 = task.wait()
		end
	end

	clone:Destroy()
end

return func