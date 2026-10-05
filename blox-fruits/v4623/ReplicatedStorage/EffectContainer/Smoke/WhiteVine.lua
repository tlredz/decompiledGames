local createVector = vector.create
local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(1, Enum.EasingStyle.Quad),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

local v2 = {
	"rbxassetid://9894827223",
	"rbxassetid://9894827063",
	"rbxassetid://9894826891",
	"rbxassetid://9894826815",
	"rbxassetid://9894826681",
	"rbxassetid://9894826543",
	"rbxassetid://9894826429",
	"rbxassetid://9894826269",
	"rbxassetid://9894826136",
	"rbxassetid://9894826010",
	"rbxassetid://9894825876",
	"rbxassetid://9894825727",
	"rbxassetid://9894825614",
	"rbxassetid://9894825499",
	"rbxassetid://9894825325",
	"rbxassetid://9894825138",
	"rbxassetid://9894824933",
	"rbxassetid://9894824768",
	"rbxassetid://9894824630",
	"rbxassetid://9894824437",
	"rbxassetid://9894824331",
	"rbxassetid://9894824213",
	"rbxassetid://9894824083",
	"rbxassetid://9894823864",
	"rbxassetid://9894823757",
	"rbxassetid://9894823636",
	"rbxassetid://9894823529",
	"rbxassetid://9894823441",
	"rbxassetid://9894823366",
	"rbxassetid://9894823302",
	"rbxassetid://9894823171",
	"rbxassetid://9894823064",
	"rbxassetid://9894822968",
	"rbxassetid://9894822830"
}

for k, v3 in pairs(v2) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v2[k] = Graphics.ScaleDown(v3)
end

local v3 = { Color3.fromRGB(400, 400, 400), Color3.fromRGB(0, 0, 0) }

local function PlayFlipbook(clone)
	local texture = clone:FindFirstChild("Texture")
	texture.Color3 = v3[math.random(1, #v3)]
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(texture, TweenInfo.new(0.25), {
		Transparency = -1
	}):Play()
	local v4 = math.random() / 100
	resume(create(function()
		for i = 1, #v2 do
			task.wait(v4 * 3)
			texture.Texture = v2[i]
		end

		clone:Destroy()
	end))
end

return function(player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 600 then
		return
	end

	local clones = {}

	for _, emitter in pairs(script:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		table.insert(clones, clone)
		clone.Enabled = true
		clone.Parent = character.RightLowerArm
	end

	Sound:Play("SmokeCharge", humanoidRootPart.Position)

	repeat
		wait()
	until not player.Holding or not player.Holding:IsDescendantOf(workspace) or humanoid.Health <= 0 or not player.Holding.Value

	Sound:Play("SmokeVine", humanoidRootPart.Position)

	if character == game.Players.LocalPlayer.Character then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("ShakeCam"):replicate({
			2.5,
			4,
			0.1,
			0.75,
			createVector(0.15, 0.15, 0.15),
			createVector(1, 1, 1)
		})
	end

	local cFrame = CFrame.new(humanoidRootPart.Position) * CFrame.new(0, -2, 0)
	local clone = script.eff:Clone()
	clone.Parent = _WorldOrigin
	clone.Name = clone.Name
	clone.CFrame = cFrame
	Debris:AddItem(clone, 4)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		if child:GetAttribute("EmitDelay") and child:GetAttribute("EmitDelay") ~= 0 then
			local v5 = child
			task.delay(child:GetAttribute("EmitDelay"), function()
				v5:Emit(v5:GetAttribute("EmitCount"))
			end)
		else
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	task.delay(0.25, function()
		if character == game.Players.LocalPlayer.Character then
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ShakeCam"):replicate({
				3.5,
				8,
				0,
				1.5,
				createVector(0.25, 0.25, 0.25),
				createVector(1, 1, 1)
			})
		end

		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude < 300 then
			local clone2 = script.Blur:Clone()
			clone2.Parent = game.Lighting
			TweenService:Create(clone2, v[2], {
				Size = 0
			}):Play()
			Debris:AddItem(clone2, 1)
		end

		for _ = 1, 7 do
			Random.new():NextNumber(0.8, 1.2)
			local cFrame2 = clone.CFrame * CFrame.new(0, math.random(15, 60), 0) * CFrame.Angles(
				0,
				math.random(-180, 180),
				0
			)
			local clone2 = script.Wind:Clone()
			clone2.Parent = _WorldOrigin
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame2
			local scale = clone2.Mesh.Scale * Random.new():NextNumber(1.5, 3.5)
			clone2.Mesh.Scale *= Random.new():NextNumber(0.25, 0.5)
			TweenService:Create(clone2.Mesh, v[1], {
				Scale = scale
			}):Play()
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, 5, 0)
			}):Play()
			PlayFlipbook(clone2)
			task.wait()
		end

		for _, emitter in pairs(clones) do
			if emitter == nil then
				continue
			end

			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
				Debris:AddItem(emitter, 1)
			else
				emitter:Destroy()
			end
		end
	end)
end