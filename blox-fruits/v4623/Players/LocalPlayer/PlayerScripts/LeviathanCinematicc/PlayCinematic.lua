local PlayCinematic = {}

function PlayCinematic.new(anim)
	local object = setmetatable({}, {
		__index = PlayCinematic
	})
	object.anim = anim
	object._Objects = {}
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(anim.Value)

	for childName, item in pairs(jSONDecode.Items) do
		local game2 = game

		for i = 2, #item.Path.InstanceNames do
			local currentCamera = game2:FindFirstChild(item.Path.InstanceNames[i])

			if item.Path.InstanceNames[i] == "CurrentCamera" then
				currentCamera = game.workspace.CurrentCamera
			end

			if currentCamera and currentCamera.ClassName == item.Path.InstanceTypes[i] then
				game2 = currentCamera
			else
				if currentCamera then
					for _, child in pairs(game2:GetChildren()) do
						if child.Name == item.Path.InstanceNames[i] and child.ClassName == item.Path.InstanceTypes[i] then
						end
					end
				end

				game2 = nil
				break
			end
		end

		if not (game2 and game2.ClassName == item.Path.ItemType) then
			continue
		end

		local child = anim:FindFirstChild(childName)

		if not child then
			continue
		end

		object._Objects[game2] = {}

		for _, child2 in pairs(child:GetChildren()) do
			local v = {
				Default = child2.default.Value,
				Frames = {}
			}

			for _, folder in pairs(child2:GetChildren()) do
				if folder:IsA("Folder") then
					table.insert(v.Frames, { tonumber(folder.Name) / 60, folder.Values[0].Value })
				end
			end

			table.sort(v.Frames, function(a, b)
				return a[1] < b[1]
			end)
			object._Objects[game2][child2.Name] = v
		end
	end

	object.Length = jSONDecode.Information.Length / 60
	object.TimePosition = 0
	object.IsPlaying = false
	return object
end

function PlayCinematic:Play()
	if self.IsPlaying then
		return
	end

	self.IsPlaying = true
	local Effect = require(game.ReplicatedStorage.Effect)
	Effect.new("BlindCam"):replicate({
		Color = Color3.new(0.03, 0.03, 0.03),
		Duration = 0.75,
		Fade = 0.25,
		ZIndex = -10
	})
	task.spawn(function()
		local cFrame = workspace.CurrentCamera.CFrame
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("LeviathanIntro", Enum.RenderPriority.Camera.Value + 1, function()
			workspace.CurrentCamera.CFrame = cFrame
		end)

		while self.TimePosition < self.Length and self.IsPlaying do
			for k, _Object in pairs(self._Objects) do
				for k2, v in pairs(_Object) do
					if typeof(k[k2]) == "boolean" then
						local default = v.Default

						for _, frame in pairs(v.Frames) do
							if frame[1] <= self.TimePosition then
								default = frame[2]
							else
								break
							end
						end

						k[k2] = default
					else
						local v2 = { 0, v.Default }
						local v3 = { self.Length, v.Default }

						for _, frame in pairs(v.Frames) do
							if frame[1] <= self.TimePosition then
								v3 = frame
								v2 = v3
								v3 = v2
							else
								v3 = frame
								break
							end
						end

						local v5 = math.clamp((self.TimePosition - v2[1]) / (v3[1] - v2[1]), 0, 1)

						if typeof(k[k2]) == "number" then
							k[k2] = (v3[2] - v2[2]) * v5 + v2[2]
						else
							k[k2] = v2[2]:lerp(v3[2], v5)
						end
					end
				end
			end

			cFrame = workspace.CurrentCamera.CFrame
			self.TimePosition = math.min(self.Length, self.TimePosition + task.wait())
		end

		workspace.CurrentCamera.FieldOfView = 70
		self.IsPlaying = false
		local TweenService = game:GetService("TweenService")
		TweenService:Create(game.Lighting.Blur, TweenInfo.new(0.2), {
			Size = 0
		}):Play()
		local RunService2 = game:GetService("RunService")
		RunService2:UnbindFromRenderStep("LeviathanIntro")
	end)
end

return PlayCinematic