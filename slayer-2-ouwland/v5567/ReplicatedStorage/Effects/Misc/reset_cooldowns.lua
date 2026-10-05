local Players = game:GetService("Players")
return function(p: string?)
	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local SHC = character:FindFirstChild("SHC")

	if SHC == nil then
		return
	end

	for _, numberValue in SHC:GetChildren() do
		if numberValue:IsA("NumberValue") and numberValue.Name ~= p then
			numberValue:Destroy()
		end
	end
end