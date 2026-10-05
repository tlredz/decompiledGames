local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.BoatTween
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local scaleParticle2 = Util.ScaleParticle2
local SharkPalettes = require(ReplicatedStorage.EffectContainer.NPC.ChainShark.SharkPalettes)
return function(player)
	local character = player.Character
	local offset = player.Offset or CFrame.new(0, -2, -5)
	local scale = player.Scale or 1
	local colorSet = player.ColorSet or 1
	local head = character and character:FindFirstChild("Head")

	if head then
		if (workspace.CurrentCamera.CFrame.Position - head.Position).Magnitude > 1000 then
			return
		end

		local bite = SharkPalettes[colorSet].Bite
		local v = {
			Flash = ColorSequence.new(bite[1]),
			Glint = ColorSequence.new(bite[2]),
			Spikes = ColorSequence.new({
				ColorSequenceKeypoint.new(0, bite[2]),
				ColorSequenceKeypoint.new(0.371, bite[3]),
				ColorSequenceKeypoint.new(0.737, bite[2]),
				ColorSequenceKeypoint.new(1, bite[2])
			}),
			Splatter = ColorSequence.new(bite[2])
		}
		local parent = Util.Sound:Play(
			player.OtherSound and "SpikeHit" or "MetalPierce",
			head.Position,
			nil,
			math.random(110, 130) / 100,
			player.OtherSound and 0.5 or 1.54
		)
		local chorusSoundEffect = Instance.new("ChorusSoundEffect")
		chorusSoundEffect.Rate = 2.6
		chorusSoundEffect.Mix = 1
		chorusSoundEffect.Depth = 0.44
		chorusSoundEffect.Parent = parent
		local clone = script.BiteModel:Clone()
		debris:AddItem(clone, 2)
		clone:PivotTo(head.CFrame * offset)
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone.Center.Attachment:GetChildren()) do
			if v[child.Name] then
				child.Color = v[child.Name]
			end

			scaleParticle2(child, scale, true)
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end
end