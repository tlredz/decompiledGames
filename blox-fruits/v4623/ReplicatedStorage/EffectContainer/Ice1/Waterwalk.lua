local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local _ = workspace._WorldOrigin
local _ = workspace.Map
require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local v = {
	TweenInfo.new(0.1, Enum.EasingStyle.Back),
	TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, ice, _, _)
	local clone = ice:Clone()
	clone.CFrame = cFrame
	return clone
end

local random = Random.new()
return function(data)
	local cFrame = data.CFrame

	if not data.RespectHeight then
		local vector2 = Vector3.new(cFrame.X, -3.8, cFrame.Z)
		cFrame = CFrame.new(vector2, vector2 + cFrame.LookVector)
	end

	if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.Position - cFrame.p).magnitude > 300 then
			return
		end
	elseif (workspace.CurrentCamera.CFrame.Position - cFrame.p).magnitude > 300 then
		return
	end

	local effect = createEffect(cFrame * CFrame.Angles(0, Random.new():NextNumber(0, 3.14), 0), script.ice) -- equivalent call inferred; original call site unknown

	if data.NonCollide then
		effect.CanCollide = false
	else
		Sound:Play("Ice_walk", cFrame)
	end

	local size = effect.Size * 1.15
	effect.Size = size / 2 * random:NextNumber(1, 2)
	effect.Parent = workspace
	TweenService:Create(effect, v[1], {
		Size = size
	}):Play()

	for _, emitter in pairs(effect:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") * 0.5)
		end
	end

	task.delay(0.75, function()
		local tween = TweenService:Create(effect, v[2], {
			Size = createVector(0, 0, 0)
		})
		tween.Completed:Connect(function()
			effect.Transparency = 1
		end)
		tween:Play()
		task.wait(0.5)
		effect:Destroy()
	end)
end