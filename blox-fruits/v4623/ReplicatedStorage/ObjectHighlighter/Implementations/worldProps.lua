local _ = workspace.CurrentCamera
return function()
	local v = {}
	return {
		onBeforeRender = function(_, _)
			return true
		end,
		onRender = function(_, p, p2, _)
			p2.CFrame = p.CFrame
		end,
		onAdded = function(instance, p, _)
			v[instance] = {}
			table.insert(v[instance], instance:GetPropertyChangedSignal("Color"):Connect(function()
				p.Color = instance.Color
			end))
			table.insert(v[instance], instance:GetPropertyChangedSignal("Size"):Connect(function()
				p.Size = instance.Size
			end))
			table.insert(v[instance], instance:GetPropertyChangedSignal("Transparency"):Connect(function()
				p.Transparency = instance.Transparency
			end))
		end,
		onRemoved = function(p, _, _)
			if v[p] then
				for _, connection in next, v[p], nil do
					connection:Disconnect()
				end

				v[p] = nil
			end
		end
	}
end