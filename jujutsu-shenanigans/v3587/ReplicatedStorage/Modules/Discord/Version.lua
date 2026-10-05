local function parseVersion(VERSION: string)
	local match, v, v2, prerelease = VERSION:match("^v?(%d+)%.(%d+)%.(%d+)(.*)$")

	if not match then
		return {
			major = 1,
			minor = 0,
			patch = 0,
			prerelease = VERSION
		}
	end

	local v4 = {
		major = tonumber(match) or 1,
		minor = tonumber(v) or 0,
		patch = tonumber(v2) or 0,
		prerelease = 0
	}

	if not prerelease or prerelease == "" or not prerelease then
		prerelease = nil
	end

	v4.prerelease = prerelease
	return v4
end

local Version = {
	VERSION = "1.0.3",
	BUILD_DATE = "2026-06-25 20:13:20 UTC",
	BUILD_TIMESTAMP = 1782418400
}
Version.Components = parseVersion(Version.VERSION)

function Version.GetVersion(p)
	return p.VERSION
end

function Version.GetBuildDate(p)
	return p.BUILD_DATE
end

function Version.GetBuildTimestamp(p)
	return p.BUILD_TIMESTAMP
end

function Version.GetMajor(p)
	return p.Components.major
end

function Version.GetMinor(p)
	return p.Components.minor
end

function Version.GetPatch(p)
	return p.Components.patch
end

function Version.GetPrerelease(p)
	return p.Components.prerelease
end

function Version.IsPrerelease(p)
	return p.Components.prerelease ~= nil
end

function Version.ToString(p)
	return string.format("Discord Roblox SDK %s (built %s)", p.VERSION, p.BUILD_DATE)
end

function Version.ToTable(data)
	return {
		version = data.VERSION,
		buildDate = data.BUILD_DATE,
		buildTimestamp = data.BUILD_TIMESTAMP,
		components = data.Components
	}
end

return Version