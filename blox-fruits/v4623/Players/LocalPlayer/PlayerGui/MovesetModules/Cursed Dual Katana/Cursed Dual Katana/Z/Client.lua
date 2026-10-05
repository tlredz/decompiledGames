require(game.ReplicatedStorage.MovesetTypes)
local Effect = require(game.ReplicatedStorage.Effect)
local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
local Shared = require(script.Parent.Shared)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local MasterClock = require(game.ReplicatedStorage.Util.MasterClock)
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
		local v = BodyMover.new(character):Create("BodyGyro", {
			CFrame = CFrame.new(rootPart.Position, object:aim())
		})
		local v2 = BodyMover.new(character):Create("BodyPosition", {
			Position = rootPart.Position
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
		local cursedDualKatanaZ = Anims:Get(character, "CursedDualKatanaZ")
		cursedDualKatanaZ:Play()
		cursedDualKatanaZ:AdjustSpeed(1)
		task.spawn(function()
			local new = Effect.new
			local v4

			if isRunning then
				v4 = game.ReplicatedStorage.EffectContainer.CursedDualKatana.Z
			else
				v4 = require(game.ReplicatedStorage.EffectContainer.CursedDualKatana.Z)
			end

			new(v4):replicate({
				ActionID = 1,
				Character = character,
				Humanoid = humanoid,
				MinHoldTime = Shared.MinHoldTime,
				MaxHoldTime = Shared.MaxHoldTime,
				HoldValue = object.holdingInstance,
				Timestamp = MasterClock:GetTime(),
				Player = object.player
			})
			task.wait(Shared.Client.HoldEffectDelay)
			cursedDualKatanaZ.TimePosition = Shared.Client.HoldAnimTimePosition
			cursedDualKatanaZ:AdjustSpeed(0)

			if object.holdingInstance.Value then
				object.holdingInstance.Changed:Wait()
			end

			repeat
				task.wait()
			until character:FindFirstChild(Shared.Client.ReleaseValueName) or v3 == true

			local child = character:FindFirstChild(Shared.Client.ReleaseValueName)

			if child then
				child:Destroy()
			end

			if cursedDualKatanaZ then
				cursedDualKatanaZ:AdjustSpeed(Shared.Client.ReleaseAnimSpeed)
			end

			v:Destroy()
			v2:Destroy()
		end)
		object.remotes.func:InvokeServer("Z")
		cursedDualKatanaZ:AdjustSpeed(Shared.Client.ReleaseAnimSpeed)
		v:Destroy()
		v2:Destroy()
		v3 = true
		humanoid.AutoRotate = true
	end
}