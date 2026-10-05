local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local remoteFunction = require3(ReplicatedStorage2.Packages.Net):RemoteFunction("EncryptedAssetService/Fetch")
local EncryptedAssetController = {}

function EncryptedAssetController:RequestAsset(value)
	local v = remoteFunction:InvokeServer(type(value) == "string" and { value } or value)

	for k, v2 in v do
		local v3 = k
		local v4 = v2
		xpcall(function()
			ContentProvider:RegisterSessionEncryptedAsset(v3, v4)
		end, warn)
	end
end

function EncryptedAssetController:Start()
	self:RequestAsset({
		"rbxassetid://121746225545509",
		"rbxassetid://139683901913363",
		"rbxassetid://122138306164149",
		"rbxassetid://83905175287537",
		"rbxassetid://86553108866816",
		"rbxassetid://78966882139691",
		"rbxassetid://73110745626575",
		"rbxassetid://107342460864353",
		"rbxassetid://115869696246143",
		"rbxassetid://102956681439667",
		"rbxassetid://99341770298165",
		"rbxassetid://118014503283696",
		"rbxassetid://102871828431069",
		"rbxassetid://71710365991688",
		"rbxassetid://127435667839269",
		"rbxassetid://88013971827229",
		"rbxassetid://106516285430693",
		"rbxassetid://77955113474614"
	})
end

return EncryptedAssetController