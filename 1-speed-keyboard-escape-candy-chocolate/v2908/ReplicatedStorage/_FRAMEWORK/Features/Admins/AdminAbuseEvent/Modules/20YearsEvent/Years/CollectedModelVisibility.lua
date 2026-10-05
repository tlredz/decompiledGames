return {
	hide = function(folder)
		local v = {}

		local function hideDescendant(descendant)
			if v[descendant] then
				return
			end

			if descendant:IsA("BasePart") then
				local localTransparencyModifier = descendant.LocalTransparencyModifier

				v[descendant] = function()
					descendant.LocalTransparencyModifier = localTransparencyModifier
				end

				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				local transparency = descendant.Transparency

				v[descendant] = function()
					descendant.Transparency = transparency
				end

				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") or descendant:IsA("LayerCollector") or descendant:IsA("ProximityPrompt") then
				local enabled = descendant.Enabled

				v[descendant] = function()
					descendant.Enabled = enabled
				end

				descendant.Enabled = false
			end
		end

		local descendantAddedConnection = folder.DescendantAdded:Connect(hideDescendant)
		local descendantRemovingConnection = folder.DescendantRemoving:Connect(function(descendant)
			local v2 = v[descendant]

			if v2 then
				v2()
				v[descendant] = nil
			end
		end)

		for _, descendant in folder:GetDescendants() do
			hideDescendant(descendant)
		end

		return function()
			descendantAddedConnection:Disconnect()
			descendantRemovingConnection:Disconnect()

			for k, v2 in v do
				if k.Parent then
					v2()
				end
			end

			table.clear(v)
		end
	end
}