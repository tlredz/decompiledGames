local module = require("@game/ReplicatedStorage/Omni")
local frames = module.Interface:WaitForChild("Frames")
return {
	Init = function()
		for _, frame in frames:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local preset = frame:GetAttribute("Preset") or "Default"

			if not module.Frame:Create(frame, preset) then
				continue
			end

			local close = frame:FindFirstChild("Close")

			if not close then
				continue
			end

			local main = close:FindFirstChild("Main")

			if not (main and main:IsA("GuiButton")) then
				continue
			end

			local v = frame
			module.Button:Create(main, "Close"):BindFunction("Click", function()
				module.Frame:Close(v.Name)
			end)
		end
	end
}