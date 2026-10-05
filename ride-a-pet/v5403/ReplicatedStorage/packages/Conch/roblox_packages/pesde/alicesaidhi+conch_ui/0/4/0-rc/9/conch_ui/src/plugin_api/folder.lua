local module = require("./package_version")
require("./semver")
local parent = game:FindFirstChild("plugins_api")
local v2 = {}
local Folder = {}

function Folder.get_plugins_api_folder()
	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "plugins_api"
		parent.Parent = game
	end

	return parent
end

function Folder.obtain_plugins_api(name: string, data)
	if v2[name] then
		return v2[name]
	end

	local folder = Instance.new("Folder")
	folder:SetAttribute("major-userfacing", data.major)
	folder:SetAttribute("minor-userfacing", data.minor)
	folder:SetAttribute("patch-userfacing", data.patch)
	folder:SetAttribute("major-package", module.major)
	folder:SetAttribute("minor-package", module.minor)
	folder:SetAttribute("patch-package", module.patch)
	folder:AddTag("api")
	folder.Name = name

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "plugins_api"
		parent.Parent = game
	end

	folder.Parent = parent
	return folder
end

function Folder.find_plugins_api(p: string)
	local result = {}

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "plugins_api"
		parent.Parent = game
	end

	for _, folder in parent:QueryDescendants((`#{p} Folder .api`)) do
		table.insert(result, {
			folder = folder,
			version = {
				major = folder:GetAttribute("userfacing-major"),
				minor = folder:GetAttribute("userfacing-minor"),
				patch = folder:GetAttribute("userfacing-patch")
			},
			package_version = {
				major = folder:GetAttribute("package-major"),
				minor = folder:GetAttribute("package-minor"),
				patch = folder:GetAttribute("package-patch")
			}
		})
	end

	return result
end

function Folder.wait_for_first_api(childName: string)
	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "plugins_api"
		parent.Parent = game
	end

	local child = parent:WaitForChild(childName)
	return {
		folder = child,
		version = {
			major = child:GetAttribute("userfacing-major"),
			minor = child:GetAttribute("userfacing-minor"),
			patch = child:GetAttribute("userfacing-patch")
		},
		package_version = {
			major = child:GetAttribute("package-major"),
			minor = child:GetAttribute("package-minor"),
			patch = child:GetAttribute("package-patch")
		}
	}
end

return Folder