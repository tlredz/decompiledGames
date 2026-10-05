require(game.ReplicatedStorage.MovesetTypes)
local Effect = require(game.ReplicatedStorage.Effect)
local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
local Shared = require(script.Parent.Shared)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local Aim = require(game.ReplicatedStorage.MovesetUtil.Aim)

-- equivalent calls inferred from this helper; original call sites unknown
local function isActiveTool(p)
	local tool = p.tool

	if tool then
		return tool:IsDescendantOf(p.character)
	end

	return p.character.Parent ~= nil
end

return {
	onInput = function(object, _: string, _, _)
		local character = object.character
		local rootPart = object.rootPart
		local humanoid = object.humanoid
		humanoid.AutoRotate = false
		local cframe = CFrame.new(rootPart.Position, object:aim())
		local v = BodyMover.new(character):Create("BodyGyro", {
			CFrame = cframe
		})
		local v2 = BodyMover.new(character):Create("BodyPosition", {
			Position = (cframe * Shared.Client.BodyPositionOffset).Position
		})
		object.remotes.event:FireServer(Aim.raiseLowAim(object:aim(), rootPart.Position, 2, 4))
		local v3 = false
		task.spawn(function()
			while true do
				local activeTool = isActiveTool(object) -- equivalent call inferred; original call site unknown

				if not activeTool or v3 then
					break
				end

				local v5 = Aim.raiseLowAim(object:aim(), rootPart.Position, 2, 4)
				v:Set(CFrame.new(rootPart.Position, v5))
				object.remotes.event:FireServer(v5)
				task.wait()
			end
		end)
		local cursedDualKatanaX = Anims:Get(character, "CursedDualKatanaX")
		cursedDualKatanaX:Play()
		local v4 = nil
		task.spawn(function()
			local new = Effect.new
			local v5

			if isRunning then
				v5 = game.ReplicatedStorage.EffectContainer.CursedDualKatana.X
			else
				v5 = require(game.ReplicatedStorage.EffectContainer.CursedDualKatana.X)
			end

			new(v5):replicate({
				Root = rootPart,
				Humanoid = humanoid,
				Character = character,
				HoldValue = object.holdingInstance,
				Player = object.player
			})
			task.wait(Shared.Client.HoldEffectDelay)
			cursedDualKatanaX.TimePosition = Shared.Client.HoldAnimTimePosition
			cursedDualKatanaX:AdjustSpeed(0)

			if object.holdingInstance.Value then
				object.holdingInstance.Changed:Wait()
			end

			v2:Destroy()

			if not v3 then
				v4 = BodyMover.new(character):Create("BodyVelocity", {
					Duration = Shared.Client.HoverDuration,
					Velocity = Shared.Client.HoverVelocity
				})
			end

			task.wait(Shared.Client.ReleaseAnimDelay)
			cursedDualKatanaX.TimePosition = Shared.Client.ReleaseAnimTimePosition
			cursedDualKatanaX:AdjustSpeed(Shared.Client.ReleaseAnimSpeed)
		end)
		object.remotes.func:InvokeServer("X")
		cursedDualKatanaX:AdjustSpeed(Shared.Client.ReleaseAnimSpeed)
		v3 = true

		if v4 then
			v4:Destroy()
		end

		v:Destroy()
		v2:Destroy()
		humanoid.AutoRotate = true
	end
}