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
		local v = rootPart.Size.Y * 0.5 + humanoid.HipHeight
		local aim = object:aim()
		object.remotes.event:FireServer(aim)
		local cframe = CFrame.new(rootPart.Position, aim + createVector(0, 1, 0) * v)
		local v2 = BodyMover.new(character):Create("BodyGyro", {
			CFrame = cframe
		})
		local v3 = BodyMover.new(character):Create("BodyVelocity", {
			Velocity = createVector(0, 0.0001, 0)
		})
		humanoid.AutoRotate = false
		rootPart.CFrame = cframe
		local flag = false
		task.spawn(function()
			while Cast.isAlive(tool, character) and not flag do
				local aim2 = object:aim()
				v2:Set(CFrame.new(rootPart.Position, aim2 + createVector(0, 1, 0) * v))
				object.remotes.event:FireServer(aim2)
				task.wait()
			end
		end)

		if RunService:IsClient() then
			local new = Effect.new
			local v4

			if isRunning then
				v4 = game.ReplicatedStorage.EffectContainer.Sharkman2.Z
			else
				v4 = require(game.ReplicatedStorage.EffectContainer.Sharkman2.Z)
			end

			new(v4):play({
				Character = character,
				Holding = object.holdingInstance
			})
		end

		local sKZWindup = Anims:Get(character, "SK_ZWindup")
		sKZWindup.Stopped:Once(function()
			if flag then
				return
			end

			sKZWindup = Anims:Get(character, "SK_ZHold")
			sKZWindup:Play()
		end)
		sKZWindup:Play()
		task.spawn(function()
			if object.holdingInstance.Value then
				object.holdingInstance.Changed:Wait()
			end

			sKZWindup:Stop()
			Anims:Get(character, "SK_ZDash"):Play()
		end)
		object.remotes.func:InvokeServer("Z")
		rootPart.CFrame = CFrame.lookAt(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1)) + rootPart.Position
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		sKZWindup:Stop()
		flag = true
		v2:Destroy()
		v3:Destroy()
		humanoid.AutoRotate = true
	end
}