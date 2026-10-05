local createVector = vector.create
local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
local Auras = require(shared.Auras)
local Trove = require(shared.Trove)
local Emotes = require(shared.Emotes)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function useAuraSetup(instance, object, p, value: number?)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if instance then
			local clone = instance:Clone()
			local v = object ~= nil
			local current = p and p.current
			Auras.BindEffect(clone)
			local v2 = Trove.new()
			local descendants = {}

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") then
					table.insert(descendants, descendant)
				elseif descendant:IsA("Trail") then
					descendant.Enabled = false
				elseif descendant:IsA("ParticleEmitter") then
					local speed = descendant.Speed

					if speed.Min < 0.01 then
						descendant.Speed = NumberRange.new(0.01, (math.max(0.01, speed.Max)))
					end

					descendant.LockedToPart = true
					descendant.ZOffset *= value
				elseif descendant:IsA("Beam") then
					descendant.ZOffset *= value
				end
			end

			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Size = UDim2.fromOffset(180, 245)
			billboardGui.Adornee = clone
			billboardGui.Parent = clone
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://17732143513"
			imageLabel.ScaleType = Enum.ScaleType.Crop
			imageLabel.Parent = billboardGui
			local absoluteSizeChangedConnection

			if current then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function update()
					local absoluteSize = current.AbsoluteSize
					billboardGui.Size = UDim2.fromOffset(absoluteSize.X * 1.03 + 2, absoluteSize.Y * 1.06 + 2)
				end

				update() -- equivalent call inferred; original call site unknown
				absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
			else
				absoluteSizeChangedConnection = nil
			end

			local function scaleEmoteWithAura()
				if object then
					v2:Add((Emotes.AttachEffectToCharacter(clone, object, localPlayer.UserId)))

					for _, v4 in object:QueryDescendants("WrapLayer") do
						v4.Enabled = false
						local v5 = v4
						task.delay(0.1, function()
							v5.Enabled = true
						end)
					end

					billboardGui.Adornee = clone
				end
			end

			local function scaleStandaloneAura()
				local model = Instance.new("Model")
				model.Name = "AuraPreview"
				model:SetAttribute("UserId", localPlayer.UserId)
				v2:Add(model)

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.Parent = model
					elseif descendant:IsA("Trail") then
						descendant.Enabled = false
					elseif descendant:IsA("ParticleEmitter") then
						local speed = descendant.Speed

						if speed.Min < 0.01 then
							local v3 = math.max(0.01, speed.Max)
							descendant.Speed = NumberRange.new(0.01, v3)
						end

						descendant.TimeScale = 0.5
						descendant.LockedToPart = true
						descendant.Enabled = true
						descendant.ZOffset /= 20
					elseif descendant:IsA("Beam") then
						descendant.ZOffset /= 20
					end
				end

				clone.Size *= 3.5

				for _, v4 in descendants do
					v4.Parent = model
				end

				clone.Parent = model
				clone.Anchored = true
				model.PrimaryPart = clone
				model:ScaleTo(value or 0.03)
				setState(model)
			end

			if v then
				scaleEmoteWithAura()
			else
				scaleStandaloneAura()
			end

			billboardGui.StudsOffsetWorldSpace = createVector(0, 0, 1) * (clone.Size.Z / 2 + 0.5)
			return function()
				if absoluteSizeChangedConnection then
					absoluteSizeChangedConnection:Disconnect()
				end

				v2:Clean()
			end
		elseif not object then
			setState(nil)
		end
	end, {
		instance,
		object,
		p,
		value
	})
	return state
end

return useAuraSetup