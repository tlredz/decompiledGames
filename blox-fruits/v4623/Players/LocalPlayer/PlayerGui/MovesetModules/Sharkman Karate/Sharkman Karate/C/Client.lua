local createVector = vector.create
require(game.ReplicatedStorage.MovesetTypes)
local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage.Effect)
local RunService2 = game:GetService("RunService")
local isRunning = RunService2:IsRunning()
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local Cast = require(game.ReplicatedStorage.MovesetUtil.Cast)
return {
	onInput = function(object, _: string, _, _)
		local character = object.character
		local rootPart = object.rootPart
		local humanoid = object.humanoid
		local tool = object.tool
		local aim = object:aim()
		object.remotes.event:FireServer(aim)
		local v = rootPart.Size.Y * 0.5 + humanoid.HipHeight
		local cframe = CFrame.new(rootPart.Position, aim + createVector(0, 1, 0) * v)
		local v2 = BodyMover.new(character):Create("BodyGyro", {
			CFrame = cframe
		})
		local v3 = BodyMover.new(character):Create("BodyVelocity", {
			Velocity = createVector(0, 0.001, 0)
		})
		humanoid.AutoRotate = false
		rootPart.CFrame = cframe
		local v4 = false
		task.spawn(function()
			while Cast.isAlive(tool, character) and not v4 and object.holdingInstance.Value ~= false do
				local aim2 = object:aim()
				v2:Set(CFrame.new(rootPart.Position, aim2 + createVector(0, 1, 0) * v))
				object.remotes.event:FireServer(aim2)
				task.wait()
			end
		end)

		if RunService:IsClient() then
			local new = Effect.new
			local v5

			if isRunning then
				v5 = game.ReplicatedStorage.EffectContainer.Sharkman2.C
			else
				v5 = require(game.ReplicatedStorage.EffectContainer.Sharkman2.C)
			end

			new(v5):play({
				Character = character,
				Holding = object.holdingInstance
			})
		end

		local sKCCharge = Anims:Get(character, "SK_CCharge")
		sKCCharge:Play()
		task.spawn(function()
			if object.holdingInstance.Value then
				object.holdingInstance.Changed:Wait()
			end

			v4 = true
			sKCCharge:Stop()
			Anims:Get(character, "SK_CFire"):Play(nil, nil, 0.75)
		end)
		object.remotes.func:InvokeServer("C")
		v4 = true
		v2:Destroy()
		v3:Destroy()
		humanoid.AutoRotate = true
	end
}