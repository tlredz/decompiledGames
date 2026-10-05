local UIAnimationEffects = {}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
UIAnimationEffects.complementaryEasingStyleInToOutMap = {
	[Enum.EasingStyle.Back] = Enum.EasingStyle.Quad,
	[Enum.EasingStyle.Bounce] = Enum.EasingStyle.Back,
	[Enum.EasingStyle.Circular] = Enum.EasingStyle.Circular,
	[Enum.EasingStyle.Cubic] = Enum.EasingStyle.Quart,
	[Enum.EasingStyle.Elastic] = Enum.EasingStyle.Elastic,
	[Enum.EasingStyle.Exponential] = Enum.EasingStyle.Exponential,
	[Enum.EasingStyle.Linear] = Enum.EasingStyle.Linear,
	[Enum.EasingStyle.Quad] = Enum.EasingStyle.Sine,
	[Enum.EasingStyle.Quart] = Enum.EasingStyle.Sine,
	[Enum.EasingStyle.Quint] = Enum.EasingStyle.Back,
	[Enum.EasingStyle.Sine] = Enum.EasingStyle.Sine
}
local complementaryEasingInToOutMap = {
	[Enum.EasingStyle.Back] = {
		[Enum.EasingDirection.Out] = {
			Style = Enum.EasingStyle.Quad,
			Direction = Enum.EasingDirection.Out
		},
		[Enum.EasingDirection.In] = {
			Style = Enum.EasingStyle.Back,
			Direction = Enum.EasingDirection.In
		},
		[Enum.EasingDirection.InOut] = {
			Style = Enum.EasingStyle.Back,
			Direction = Enum.EasingDirection.InOut
		}
	}
}
local bounce = Enum.EasingStyle.Bounce
complementaryEasingInToOutMap[bounce] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Back,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Bounce,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Bounce,
		Direction = Enum.EasingDirection.InOut
	}
}
local circular = Enum.EasingStyle.Circular
complementaryEasingInToOutMap[circular] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Circular,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Circular,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Circular,
		Direction = Enum.EasingDirection.InOut
	}
}
local cubic = Enum.EasingStyle.Cubic
complementaryEasingInToOutMap[cubic] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Quad,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Quad,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Quad,
		Direction = Enum.EasingDirection.InOut
	}
}
local elastic = Enum.EasingStyle.Elastic
complementaryEasingInToOutMap[elastic] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Elastic,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Elastic,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Elastic,
		Direction = Enum.EasingDirection.InOut
	}
}
local exponential = Enum.EasingStyle.Exponential
complementaryEasingInToOutMap[exponential] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Exponential,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Exponential,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Exponential,
		Direction = Enum.EasingDirection.InOut
	}
}
local linear = Enum.EasingStyle.Linear
complementaryEasingInToOutMap[linear] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Linear,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Linear,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Linear,
		Direction = Enum.EasingDirection.Out
	}
}
local quad = Enum.EasingStyle.Quad
complementaryEasingInToOutMap[quad] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.Out
	}
}
local quart = Enum.EasingStyle.Quart
complementaryEasingInToOutMap[quart] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Cubic,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Cubic,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Cubic,
		Direction = Enum.EasingDirection.Out
	}
}
local quint = Enum.EasingStyle.Quint
complementaryEasingInToOutMap[quint] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out
	}
}
local sine = Enum.EasingStyle.Sine
complementaryEasingInToOutMap[sine] = {
	[Enum.EasingDirection.Out] = {
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.Out
	},
	[Enum.EasingDirection.In] = {
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.In
	},
	[Enum.EasingDirection.InOut] = {
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.InOut
	}
}
UIAnimationEffects.complementaryEasingInToOutMap = complementaryEasingInToOutMap

function UIAnimationEffects.GrowShrink(p, p2: number, udim: UDim2, value: number)
	local v14 = value or 4
	local uDim = UDim2.new(udim.X.Scale, udim.X.Offset + v14, udim.Y.Scale, udim.Y.Offset + v14)
	local tween = TweenService:Create(p, TweenInfo.new(p2 / 1.64, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = uDim
	})
	tween.Completed:Once(function(p3)
		if p3 == Enum.PlaybackState.Completed then
			TweenService:Create(p, TweenInfo.new(p2 / 2.56, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = udim
			}):Play()
		end
	end)
	tween:Play()
	return tween
end

function UIAnimationEffects.WiggleWithDampening(p, p2: number, p3: number)
	local rotation = math.sign(p.Rotation)
	local v14

	if rotation == 0 then
		if p3 then
			v14 = math.sign(p3)
		else
			v14 = math.random(-1, 1)
		end
	else
		v14 = -rotation
	end

	local rotation2 = v14 * (not p3 and 15 or math.abs(p3))
	local tween = TweenService:Create(p, TweenInfo.new(p2 * 0.1785, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Rotation = rotation2
	})
	tween.Completed:Once(function(p4)
		if p4 == Enum.PlaybackState.Completed then
			local tween2 = TweenService:Create(
				p,
				TweenInfo.new(p2 * 0.4642, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Rotation = -rotation2 * 0.5
				}
			)
			tween2.Completed:Once(function(p5)
				if p5 == Enum.PlaybackState.Completed then
					TweenService:Create(
						p,
						TweenInfo.new(p2 * 0.3571, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Rotation = 0
						}
					):Play()
				end
			end)
			tween2:Play()
		end
	end)
	tween:Play()
end

function UIAnimationEffects:SlingIconTo(p, duration: number, value: number?)
	local v14 = value or 1
	local clone = self:Clone()
	self.Visible = false
	clone.Visible = true
	clone.Name = "SlingAnimationIcon"
	clone.Parent = self:FindFirstAncestorWhichIsA("ScreenGui")
	clone.ZIndex = 9999
	clone.Size = UDim2.new(0, self.AbsoluteSize.X, 0, self.AbsoluteSize.Y)
	clone.Position = UDim2.new(0, self.AbsolutePosition.X, 0, self.AbsolutePosition.Y) + UDim2.new(
		0,
		clone.AbsoluteSize.X * clone.AnchorPoint.X,
		0,
		clone.AbsoluteSize.Y * clone.AnchorPoint.Y
	)
	Debris:AddItem(clone, duration)
	local vector = Vector2.new(
		p.AbsolutePosition.X - self.AbsolutePosition.X,
		p.AbsolutePosition.Y - self.AbsolutePosition.Y
	)
	local v15 = math.clamp(-vector.X / clone.Parent.AbsoluteSize.X * 250 * v14, -30, 30)
	UIAnimationEffects.GrowShrink(
		clone,
		duration,
		UDim2.new(0, p.AbsoluteSize.X, 0, p.AbsoluteSize.Y),
		math.abs(vector.X) / clone.Parent.AbsoluteSize.X * 250 * v14
	)
	TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
		Position = UDim2.new(0, p.AbsolutePosition.X, 0, p.AbsolutePosition.Y) + UDim2.new(
			0,
			clone.AbsoluteSize.X * clone.AnchorPoint.X,
			0,
			clone.AbsoluteSize.Y * clone.AnchorPoint.Y
		),
		Rotation = v15 * 2
	}):Play()
	task.wait(duration * 0.5)

	if not clone then
		return -v15
	end

	TweenService:Create(clone, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, p.AbsolutePosition.X, 0, p.AbsolutePosition.Y) + UDim2.new(
			0,
			clone.AbsoluteSize.X * clone.AnchorPoint.X,
			0,
			clone.AbsoluteSize.Y * clone.AnchorPoint.Y
		)
	})
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Rotation = 0
		}
	)
	tween.Completed:Once(function(p2)
		if p2 == Enum.PlaybackState.Completed then
			Debris:AddItem(clone, 0)
		end
	end)
	tween:Play()
	tween.Completed:Wait()
	return -v15
end

function UIAnimationEffects.ConnectButtonHoverAndActivationFX(instance, p, state)
	local connections = {}

	if not state.HoverEnd and typeof(state.Hover) == "table" then
		local v14 = UIAnimationEffects.complementaryEasingInToOutMap[state.Hover.info.EasingStyle][state.Hover.info.EasingDirection]
		state.HoverEnd = {
			info = TweenInfo.new(
				math.clamp(state.Hover.info.Time * 0.5, math.min(0.1, state.Hover.info.Time), 0.5),
				v14.Style,
				v14.Direction
			),
			properties = {}
		}
	end

	if typeof(state.HoverEnd) == "table" and not state.HoverEnd.properties and typeof(state.Hover) == "table" then
		for k, _ in state.Hover.properties do
			state.HoverEnd.properties[k] = p[k]
		end
	end

	local flag = false

	local function HoverBegan()
		if flag then
			return
		end

		if typeof(state.Hover) == "table" then
			TweenService:Create(p, state.Hover.info, state.Hover.properties):Play()
		elseif typeof(state.Hover) == "function" then
			state.Hover(p)
		end
	end

	local function HoverEnded()
		if flag then
			return
		end

		if typeof(state.HoverEnd) == "table" then
			TweenService:Create(p, state.HoverEnd.info, state.HoverEnd.properties):Play()
		elseif typeof(state.HoverEnd) == "function" then
			state.HoverEnd(p)
		end
	end

	table.insert(connections, instance.MouseEnter:Connect(HoverBegan))

	if state.HoverEnd then
		table.insert(connections, instance.MouseLeave:Connect(HoverEnded))
	end

	assert(
		not state.Activated,
		(`UIAnimationEffects.ConnectButtonHoverAndActivationFX: tweenDescriptions.Activated provided instead of tweenDescriptions.Activate - this is a typo! Full Instance Name: {instance:GetFullName()}`)
	)

	if state.Activate then
		table.insert(connections, instance.Activated:Connect(function()
			local v14 = nil

			if typeof(state.Activate) == "table" then
				flag = true
				local tween = TweenService:Create(p, state.Activate.info, state.Activate.properties)
				tween:Play()
				v14 = tween.Completed:Wait()
			elseif typeof(state.Activate) == "function" then
				flag = true
				local tween = state.Activate(p)

				if typeof(tween) == "Instance" and tween:IsA("Tween") then
					v14 = tween.Completed:Wait()
				end
			end

			if v14 ~= Enum.PlaybackState.Cancelled then
				flag = false

				if instance.GuiState == Enum.GuiState.Hover then
					HoverBegan()
				elseif instance.GuiState == Enum.GuiState.Idle then
					HoverEnded()
				end
			end
		end))
	end

	return connections
end

function UIAnimationEffects:PopIn(udim: UDim2, duration: number, value: number?, value2: number?, p2: number?)
	local rotation = p2 or self.Rotation
	local rotation2 = rotation + (value or 45)
	local rotation3 = rotation + (value2 or -15)
	TweenService:Create(self, TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Rotation = rotation2
	}):Cancel()
	self.Rotation = rotation2
	local tween = TweenService:Create(
		self,
		TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Rotation = rotation3
		}
	)
	TweenService:Create(self, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = udim
	}):Play()
	tween.Completed:Once(function(p3)
		if p3 == Enum.PlaybackState.Completed then
			TweenService:Create(
				self,
				TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Rotation = rotation
				}
			):Play()
		end
	end)
	tween:Play()
	task.wait(duration)
end

function UIAnimationEffects:PopOut(duration: number, udim: UDim2, value: number?)
	if self:GetAttribute("PoppingOut") then
		return
	end

	self:SetAttribute("PoppingOut", true)
	local size = udim or UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(self, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Rotation = value or 15,
		Size = size
	})
	tween.Completed:Once(function(p)
		if self then
			self:SetAttribute("PoppingOut", nil)

			if p == Enum.PlaybackState.Completed then
				self.Visible = false
			end
		end
	end)
	tween:Play()
	return tween
end

function UIAnimationEffects:SetVisibilityWithPopInOutFX(flag: boolean, udim: UDim2?, value: number?, value2: number?)
	local v14 = value2 or 0
	local v15 = udim or UDim2.new(1, 0, 1, 0)
	local v16 = value or 1

	if flag then
		if not self.Visible or self:GetAttribute("PoppingOut") then
			self.Size = UDim2.new(0, 0, 0, 0)
			self.Visible = true
			task.spawn(UIAnimationEffects.PopIn, self, v15, 0.3236 * v16, -v14, v14 * 0.333, 0)
		end
	elseif self.Visible then
		task.spawn(UIAnimationEffects.PopOut, self, 0.1618 * v16, UDim2.new(0, 0, 0, 0), -v14)
	end
end

return UIAnimationEffects