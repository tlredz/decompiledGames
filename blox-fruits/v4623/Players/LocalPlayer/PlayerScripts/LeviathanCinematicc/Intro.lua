local createVector = vector.create

for _, cFrameValue in pairs(script["Leviathan Intro"][1].CFrame:GetDescendants()) do
	if cFrameValue:IsA("CFrameValue") then
		cFrameValue.Value -= createVector(5000, 0, 5000)
	end
end

for _, child in pairs(script.Enemies:GetChildren()) do
	child:SetPrimaryPartCFrame(child.PrimaryPart.CFrame - createVector(5000, 0, 5000))
end

return function()
	local ModuleScript = require(script.Enemies.Leviathan.Animations.ModuleScript)
	local moduleScript = ModuleScript()
	local numberValue = Instance.new("NumberValue", workspace)
	numberValue.Name = "LeviIntroValue"
	local v2 = {
		script.Enemies["Leviathan Segment1"]:Clone(),
		script.Enemies["Leviathan Segment2"]:Clone(),
		script.Enemies["Leviathan Segment3"]:Clone(),
		script.Enemies.Leviathan:Clone()
	}
	local Animation = require(script.Animation)
	local AnimationController = require(script.Parent.AnimationController)
	local animator = AnimationController.new(v2[4])
	local track = animator:LoadAnimation(moduleScript.Idle)
	local track2 = animator:LoadAnimation(moduleScript.Appear)
	local v3 = {}

	for i = 1, 3 do
		v3[i] = {}
		local rootPart = v2[i].RootPart

		while #rootPart:GetChildren() > 0 and #rootPart:GetChildren() < 4 do
			rootPart = rootPart:FindFirstChildOfClass("Bone")
			table.insert(v3[i], rootPart)
		end
	end

	local function UpdateAnimation()
		local value = numberValue.Value

		for i = 1, 4 do
			if value < (i - 1) * 1.2 then
				v2[i].Parent = game.ReplicatedStorage
			else
				v2[i].Parent = workspace

				if i < 4 then
					local v4 = math.floor((value - (i - 1) * 1.2) * 2 * 60 + 0.008333333333333333) + 1

					if v4 > 150 then
						v4 = (v4 - 150) % 13 + 150
					end

					for k, cFrame in pairs(Animation[v4]) do
						v3[i][k].CFrame = cFrame
					end
				else
					local timePosition = value - (i - 1) * 1.2

					if timePosition > 5.833 then
						track2._TimePosition = -1
						track.TimePosition = timePosition - 5.833
					else
						track._TimePosition = -1
						track2.TimePosition = timePosition
					end
				end
			end
		end
	end

	numberValue.Changed:Connect(UpdateAnimation)
	local PlayCinematic = require(script.Parent.PlayCinematic)
	local v4 = PlayCinematic.new(script["Leviathan Intro"])

	function v4:Destroy()
		self.IsPlaying = false

		for _, v5 in pairs(v2) do
			v5:Destroy()
		end

		numberValue:Destroy()
		moduleScript = {}
	end

	return v4
end