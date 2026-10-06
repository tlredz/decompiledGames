local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local ColorizeSourceModule = require(studioLiteFolder:WaitForChild("ColorizeSourceModule"))
script.Parent.Text = ColorizeSourceModule:ColorizeSource(script.Parent.ContentText, false, false)