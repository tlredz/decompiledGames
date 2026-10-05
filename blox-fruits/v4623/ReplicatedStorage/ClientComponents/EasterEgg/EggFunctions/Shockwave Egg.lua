local createVector = vector.create
local Effect = require(game.ReplicatedStorage.Effect)
local v = {}
return function(p)
	local primaryPart = p.Egg.PrimaryPart
	local v2 = {}
	local _UID = p._UID
	local clone

	if v[_UID] == nil then
		clone = script.TremorBall:Clone()
		clone.Anchored = true
		clone.Material = "Neon"
		clone.Transparency = 0
		clone.Mesh.Scale = Vector3.new()
		clone.Color = Color3.fromRGB(128, 187, 219)
		clone.Size = createVector(1, 1, 1)
		clone.CFrame = primaryPart.CFrame
		clone.Parent = primaryPart
		clone.Size = primaryPart.Size
		local ReplicatedTween = require(game.ReplicatedStorage.Util.ReplicatedTween)
		ReplicatedTween:Create(clone.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {
			Scale = createVector(2, 2, 2)
		}):Play()
		clone.ParticleEmitter2:Emit(1)
		Effect.new("QuakePulse"):play({
			Part = clone
		})
	else
		clone = nil
	end

	primaryPart.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)

		if not playerFromCharacter or v2[playerFromCharacter] then
			return
		end

		local humanoid = parent:FindFirstChildWhichIsA("Humanoid")

		if not humanoid then
			return
		end

		v2[playerFromCharacter] = true
		task.delay(1, function()
			v2[playerFromCharacter] = nil
		end)

		if v[_UID] then
			local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
			EasterNetwork.TryCollectEgg(_UID)
		else
			local primaryPart2 = parent.PrimaryPart

			if primaryPart2 then
				v[_UID] = true

				if clone then
					clone:Destroy()
				end

				Effect.new("BisentoV1-2.SkillX"):play({
					player = playerFromCharacter,
					hrp = primaryPart,
					origin = primaryPart.CFrame.Position
				})
				local unit = Vector3.new(math.random(-5, 5), math.random(5, 10), math.random(-5, 5)).Unit
				humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
				task.wait()
				primaryPart2.AssemblyLinearVelocity = unit * 300
				task.delay(1, function()
					humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
				end)
			end
		end
	end)
end