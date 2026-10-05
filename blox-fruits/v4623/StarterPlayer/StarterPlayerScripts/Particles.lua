local descendants = {}
local descendants2 = {}
workspace._WorldOrigin.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("ParticleEmitter") then
		table.insert(descendants, descendant)
	elseif descendant:IsA("Trail") then
		table.insert(descendants2, descendant)
	elseif descendant:IsA("BasePart") and (descendant.CanCollide or descendant.CanTouch) then
		print(descendant:GetFullName())
	end
end)
workspace._WorldOrigin.DescendantRemoving:Connect(function(effect)
	if effect:IsA("ParticleEmitter") then
		local index = table.find(descendants, effect)

		if index then
			table.remove(descendants, index)
		end
	else
		local index = effect:IsA("Trail") and table.find(descendants2, effect)

		if index then
			table.remove(descendants2, index)
		end
	end
end)

while true do
	local count = 0
	local count2 = 0

	for _, v in ipairs(descendants) do
		if v.Enabled then
			count += 1
		end
	end

	for _, v in ipairs(descendants2) do
		if v.Enabled then
			count2 += 1
		end
	end

	print("#particles", count, "#trail", count2)
	task.wait(5)
end