local v = {
	"rbxassetid://8279864587",
	"rbxassetid://8279868671",
	"rbxassetid://8279870152",
	"rbxassetid://8279871616",
	"rbxassetid://8279875789",
	"rbxassetid://8279888716",
	"rbxassetid://8279889941",
	"rbxassetid://8279891385",
	"rbxassetid://8279894730",
	"rbxassetid://8279898424",
	"rbxassetid://8279899738"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function(p)
	task.spawn(function()
		local parent = script.Parent

		if not (parent and parent:FindFirstChild("Mesh")) then
			return
		end

		local v2 = {}

		for i, texture in ipairs(v) do
			local decal = Instance.new("Decal")
			decal.Name = "Frame_" .. i
			decal.Texture = texture
			decal.Transparency = 1
			decal.Color3 = p or Color3.fromRGB(1000, 1000, 1000)
			decal.Face = Enum.NormalId.Back
			decal.Parent = parent
			table.insert(v2, decal)
		end

		local count = #v2
		PeodizService.ForLoop({
			Step = count
		}, function(p2)
			local v3 = math.clamp(math.floor(p2 * count), 1, count)

			for i, v4 in ipairs(v2) do
				v4.Transparency = i == v3 and 0 or 1
			end
		end)

		for _, v3 in ipairs(v2) do
			v3:Destroy()
		end
	end)
end