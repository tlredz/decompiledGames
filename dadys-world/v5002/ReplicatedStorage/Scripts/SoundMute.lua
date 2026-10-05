for _, sound in pairs(script.Parent.HumanoidRootPart:GetChildren()) do
	if sound:IsA("Sound") then
		sound.Volume = 0
	end
end