game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local SandCastleCharge = {
	Morph = function(p, _, object)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local chargeTime = p.config.ChargeTime or 30

		if object.core and object.core.ui then
			object.core.ui.OnBarEffects_Enabled = false
		end

		local clone = script.ChargeMeter:Clone()
		clone.Parent = reel_bar
		local bar = clone and clone:FindFirstChild("Bar")
		local fill = bar and bar:FindFirstChild("Fill")
		local v = 0
		local sandCastled = false
		p.reelTrove:Add(object.BuildEndingData:Bind(function(p2)
			p2.SandCastled = sandCastled
			return p2
		end))
		local rod = object.core and object.core.rod
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active or sandCastled then
				return
			end

			if rod and rod.CurrentInputDirection == 1 then
				v = math.clamp(v + p2 / chargeTime, 0, 1)
			end

			if fill then
				fill.Size = UDim2.fromScale(v, fill.Size.Y.Scale)
			end

			if v >= 1 then
				sandCastled = true
				object:FreezeFish(1e999)
				object.data.SlashDisabled = true
				object.fx:SpawnShake(object.reel_bar, 0.5, 5, 0.01, true)
				local sandCastle = script.SandCastle

				if sandCastle then
					local fishPosition = object.fishPosition
					local castleY = p.config.CastleY or 0.5
					local clone2 = sandCastle:Clone()
					clone2.AnchorPoint = Vector2.new(0.5, 0.5)
					clone2.Visible = true
					clone2.Parent = reel_bar
					p.reelTrove:Add(clone2)
					local size = clone2.Size
					clone2.Position = UDim2.fromScale(fishPosition, castleY + 0.35)
					clone2.Size = UDim2.fromScale(size.X.Scale * 0.3, size.Y.Scale * 0.3)

					if clone2:IsA("ImageLabel") then
						clone2.ImageTransparency = 1
					end

					object.logicTweens:Create(
						clone2,
						TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Position = UDim2.fromScale(fishPosition, castleY),
							Size = size
						}
					):Play()

					if clone2:IsA("ImageLabel") then
						object.logicTweens:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							ImageTransparency = 0
						}):Play()
					end
				end
			end
		end))
	end
}
setmetatable(SandCastleCharge, module)
return SandCastleCharge