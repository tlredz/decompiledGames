local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)

function Flipbook(instance, p: number, list)
	local decal = instance:FindFirstChildOfClass("Decal")

	if decal and list then
		decal.Transparency = 1
		coroutine.wrap(function()
			PeodizService.ForLoop({
				Step = #list,
				WaitTime = 1 / p
			}, function(p2)
				local v = math.floor(p2 * #list)
				decal.Transparency -= #list * 0.025
				decal.Texture = list[v]
			end)
			decal.Texture = ""
		end)()
	end
end

return function()
	local attachments = {}
	local attachments2 = {}

	for _, attachment in pairs(script.Parent:GetChildren()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		local name = attachment.Name

		if string.sub(name, string.len(name), (string.len(name))) == "1" then
			attachments2[#attachments2 + 1] = attachment
		end

		if string.sub(name, string.len(name), (string.len(name))) ~= "2" then
			continue
		end

		attachments[#attachments + 1] = attachment
	end

	for _, v in pairs(attachments2) do
		v.Beam.Transparency = NumberSequence.new(0, 1)
		v.Wave.Transparency = NumberSequence.new(0, 1)
	end

	for _, child in pairs(script.Parent.Parent:GetChildren()) do
		if child.Name == "fx" then
			child.sp2:Emit(25)
		end
	end

	local v = 0
	Flipbook(script.Parent.Parent.ff, 60, {
		"rbxassetid://15444887918",
		"rbxassetid://15444887707",
		"rbxassetid://15444887612",
		"rbxassetid://15444887530",
		"rbxassetid://15444887419",
		"rbxassetid://15444887315",
		"rbxassetid://15444887221",
		"rbxassetid://15444887136",
		"rbxassetid://15444887017",
		"rbxassetid://15444886912",
		"rbxassetid://15444886826",
		"rbxassetid://15444886766",
		"rbxassetid://15444886685",
		"rbxassetid://15444886613",
		"rbxassetid://15444886528",
		"rbxassetid://15444886375",
		""
	})
	task.spawn(function()
		task.wait(0.05)
		task.spawn(function()
			PeodizService.new({
				Time = 0.5,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p)
				v = p * 100
			end)
		end)
		PeodizService.new({
			Time = 0.8
		}, function(_)
			for _, v2 in pairs(attachments2) do
				v2.Beam.Transparency = NumberSequence.new(v / 100, 1)
				v2.Wave.Transparency = NumberSequence.new(v / 100, 1)
			end
		end)
	end)

	for _, v2 in pairs(attachments) do
		v2.Position = Vector3.new(v2.Position.X, 0, v2.Position.Z)
		game.TweenService:Create(v2, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = Vector3.new(v2.Position.X, 20, v2.Position.Z)
		}):Play()
	end
end