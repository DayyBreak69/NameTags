--==================================================
-- DAYBREAK MULTIPLAYER NAMETAG
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local SETTINGS = {

	-- Display
	Font = Enum.Font.GothamBold,
	DefaultRole = "MEMBER",

	-- Roles
	-- Change usernames here
	Roles = {
		["DayyBreak66"] = "OWNER",
	},

	-- Player-specific tags
	-- Banners are hosted in the GitHub /banners folder.
	-- Use Roblox UserIds when possible so tags stay tied to the correct person.
	-- Banner is ONLY the filename, for example: "DayyBreak66.png"
	-- DisplayName is optional. If omitted, the player's normal Roblox DisplayName is used.
	PlayerTags = {
		-- Recommended: use UserId
		-- [123456789] = {
		--	Role = "FRIEND",
		--	Banner = "Friend1.png",
		--	BackgroundTransparency = 0.05,
		-- },

		["DayyBreak66"] = {
			Role = "OWNER",
			DisplayName = "DayBreak",
			Banner = "Daybreak.png",

			Logo = "Catlogo.png",

			Overlay = {
				-- Banner overlay system. Change Type to test an overlay.
				Enabled = true,
				Type = "Prism",
				Speed = 0.35,
				Glow = true,
				GlowStrength = 2,
				Rotation = 0,
				Pulse = true,
			},

			BackgroundTransparency = 0.05,
		},
		["xOmqhayleealt"] = {
			Role = "Admin",
			DisplayName = "Haylee",
			Banner = "Haylee.png",
			BackgroundTransparency = 0.05,
		},

		["Chloeeafm"] = {
			Role = "Admin",
			DisplayName = "Owned By Nigger",
			Banner = "Chloe123.png",
			BackgroundTransparency = 0.05,
		},
		["Gummaes"] = {
			Role = "Admin",
			DisplayName = "Nigger",
			Banner = "Gummies1.png",
			BackgroundTransparency = 0.05,
		},

		-- ["FriendUsername"] = {
		--	Role = "FRIEND",
		--	DisplayName = "Custom Name",
		--	Banner = "Friend1.png",
		--	BackgroundTransparency = 0.05,
		-- },
	},

	-- Colors
	Orange = Color3.fromRGB(255, 140, 30),
	OrangeBright = Color3.fromRGB(255, 190, 70),

	Chrome = Color3.fromRGB(210, 210, 220),
	Dark = Color3.fromRGB(10, 9, 7),
	DarkInner = Color3.fromRGB(20, 16, 11),

	White = Color3.fromRGB(255, 255, 255),

	-- Main tag
	Width = 280,
	Height = 75,
	HeightOffset = 3.3,

	-- Distance scaling
	DistanceScaling = true,
	NormalDistance = 25,
	MinScale = 0.20,
	MaxScale = 1,

	-- At this distance the full tag becomes the logo
	CircleOnlyDistance = 30,

	-- Circle logo
	CircleDistanceScaling = true,
	CircleSize = 58,
	CircleMinScale = 0.50,
	CircleShrinkStart = 30,

	-- Glow
	GlowEnabled = true,
	GlowSpeed = 2,
	GlowAmount = 0.35,

	-- Name pulse
	NamePulseEnabled = true,
	NamePulseSpeed = 2.5,
	NamePulseAmount = 0.25,

	-- Star
	StarEnabled = true,
	StarRotateSpeed = 20,
	LogoRotateEnabled = true,
	LogoRotateSpeed = 20,

	-- OWNER SPECIAL EFFECT
	OwnerPulseEnabled = true,
	OwnerPulseSpeed = 2.5,
	OwnerPulseAmount = 0.035,
	OwnerRingEnabled = true,
	OwnerRingRotateSpeed = 45,

	-- OWNER RAINBOW NAME
	OwnerRainbowNameEnabled = true,
	OwnerRainbowNameSpeed = 45,

	-- CLICKABLE FRIEND TAGS
	ClickableFriendTagsEnabled = true,
	-- LOGO EFFECT SYSTEM
	-- All 26 effects are available. Enable only the ones you want.
	LogoEffectsEnabled = true,
	LogoEffectsSpeed = 1,
	LogoEffects = {
		"Pulse",
		"Rotation",
		-- "GlowPulse",
		-- "CounterRotation",
		-- "ShineSweep",
		-- "ChromeSweep",
		-- "ColorCycling",
		-- "BrightnessPulse",
		-- "OutlineGlow",
		-- "OuterRing",
		-- "RingRotation",
		-- "OrbitingParticles",
		-- "SparkleFlashes",
		-- "EnergyAura",
		-- "Ripple",
		-- "BreathingEffect",
		-- "Floating",
		-- "Tilt",
		-- "Glitch",
		-- "ChromaticSplit",
		-- "Scanline",
		-- "ParticleBurst",
		-- "Trail",
		-- "ElectricArcs",
		-- "Halo",
		-- "Shockwave",
	},
	LogoPulseAmount = 0.035,
	LogoGlowPulseAmount = 0.25,
	LogoRotationSpeed = 18,
	LogoFloatingAmount = 2,
	LogoTiltAmount = 4,


	-- RAINBOW BANNER BORDER
	RainbowBannerEnabled = true,
	RainbowBannerSpeed = 70, -- smooth continuous movement
	RainbowBannerThickness = 3,
	RainbowBannerGlowThickness = 6,
	RainbowBannerOuterGlowThickness = 10,

	-- Floating
	FloatingEnabled = true,
	FloatSpeed = 1.5,
	FloatAmount = 0.04,

	-- Maximum distance
	MaxDistance = 500,
}

--==================================================
-- SHARED REGISTRY
--==================================================

local REGISTRY_URL = "https://daybreak-nametag-registry.terranjones870.workers.dev"
local REGISTRY_POLL_SECONDS = 5

local ActivePlayers = {}
local registryOnline = false

local function httpRequest(options)
	local requestFunction =
		(syn and syn.request)
		or (http and http.request)
		or http_request
		or request
		or (fluxus and fluxus.request)

	if not requestFunction then
		return nil
	end

	local ok, result = pcall(requestFunction, options)
	if not ok then
		return nil
	end

	return result
end

local function registryRequest(method, path, body)
	if REGISTRY_URL == "" or REGISTRY_URL == "PASTE_YOUR_REGISTRY_URL_HERE" then
		return nil
	end

	local options = {
		Url = REGISTRY_URL:gsub("/+$", "") .. path,
		Method = method,
		Headers = {
			["Content-Type"] = "application/json"
		}
	}

	if body then
		options.Body = game:GetService("HttpService"):JSONEncode(body)
	end

	local ok, result = pcall(httpRequest, options)
	if not ok then
		return nil
	end

	return result
end

--==================================================
-- LOCAL CUSTOM ASSETS
--==================================================

local HttpService = game:GetService("HttpService")
local getAsset = getcustomasset or getsynasset
local AssetCache = {}

--==================================================
-- GITHUB BANNERS
--==================================================
-- Put banner PNGs in: GitHub repo -> banners/
-- Example raw file:
-- https://raw.githubusercontent.com/DayyBreak69/NameTags/main/banners/DayyBreak66.png
local BANNER_BASE_URL =
	"https://raw.githubusercontent.com/DayyBreak69/NameTags/main/banners/"

local BANNER_FOLDER = "DayBreak/Banners"
-- Fresh cache key for each script execution; prevents stale banner images.
local BANNER_SESSION = tostring(math.floor(os.clock() * 1000000))

local function loadLocalAsset(path)
	if not getAsset or not path or path == "" then
		return nil
	end

	if AssetCache[path] then
		return AssetCache[path]
	end

	local ok, asset = pcall(function()
		return getAsset(path)
	end)

	if ok and asset then
		AssetCache[path] = asset
		return asset
	end

	warn("[DayBreak] Could not load local asset:", path)
	return nil
end

local function downloadBanner(filename)
	if not filename or filename == "" then
		return nil
	end

	if not getAsset then
		warn("[DayBreak] Executor does not support getcustomasset/getsynasset.")
		return nil
	end

	local safeName = tostring(filename):gsub("[^%w%._%-]", "_")

	-- Fresh local filename prevents the executor from reusing an older banner.
	local localPath =
		BANNER_FOLDER .. "/" ..
		safeName:gsub("%.[Pp][Nn][Gg]$", "") .. "_" .. BANNER_SESSION .. ".png"

	if not writefile then
		warn("[DayBreak] Executor does not support writefile.")
		return nil
	end

	if makefolder then
		pcall(makefolder, "DayBreak")
		pcall(makefolder, BANNER_FOLDER)
	end

	local url = BANNER_BASE_URL .. safeName
	local body = nil

	-- First try game:HttpGet. Do not inspect the binary contents here;
	-- valid PNG binary data can be represented differently by executors.
	local okHttp, httpBody = pcall(function()
		return game:HttpGet(url)
	end)

	if okHttp and type(httpBody) == "string" and #httpBody > 0 then
		body = httpBody
	end

	-- Fallback to executor HTTP request.
	if not body then
		local result = httpRequest({
			Url = url,
			Method = "GET",
		})

		if result and tonumber(result.StatusCode) == 200 and type(result.Body) == "string" then
			body = result.Body
		end
	end

	if not body then
		warn("[DayBreak] Failed to download banner:", safeName)
		return nil
	end

	local okWrite = pcall(function()
		writefile(localPath, body)
	end)

	if not okWrite then
		warn("[DayBreak] Failed to save banner:", localPath)
		return nil
	end

	AssetCache[localPath] = nil

	local asset = loadLocalAsset(localPath)

	if not asset then
		warn("[DayBreak] Downloaded banner but could not load asset:", safeName)
		return nil
	end

	return asset
end

--==================================================
-- GITHUB CUSTOM LOGOS
--==================================================
local LOGO_BASE_URL =
	"https://raw.githubusercontent.com/DayyBreak69/NameTags/main/Logos/"

-- CDN fallback. This avoids some executors/network setups that have trouble
-- fetching binary files directly from raw.githubusercontent.com.
local LOGO_CDN_URL =
	"https://cdn.jsdelivr.net/gh/DayyBreak69/NameTags@main/Logos/"

local LOGO_FOLDER = "DayBreak/Logos"
local LOGO_SESSION = tostring(math.floor(os.clock() * 1000000))

local function downloadLogo(filename)
	if not filename or filename == "" then
		return nil
	end

	if not getAsset then
		warn("[DayBreak] Executor does not support getcustomasset/getsynasset.")
		return nil
	end

	local safeName = tostring(filename):gsub("[^%w%._%-]", "_")
	local localPath =
		LOGO_FOLDER .. "/" ..
		safeName:gsub("%.[Pp][Nn][Gg]$", "") .. "_" .. LOGO_SESSION .. ".png"

	if not writefile then
		warn("[DayBreak] Executor does not support writefile.")
		return nil
	end

	if makefolder then
		pcall(makefolder, "DayBreak")
		pcall(makefolder, LOGO_FOLDER)
	end

	-- Try the CDN first, then GitHub Raw.
	local urls = {
		LOGO_CDN_URL .. safeName,
		LOGO_BASE_URL .. safeName,
	}

	local body = nil
	local successfulUrl = nil

	for _, url in ipairs(urls) do
		-- Executor HTTP request first so we can verify the HTTP status.
		local result = httpRequest({
			Url = url,
			Method = "GET",
		})

		if result and tonumber(result.StatusCode) == 200
			and type(result.Body) == "string"
			and #result.Body > 0 then
			body = result.Body
			successfulUrl = url
			break
		end

		-- Fallback to Roblox HttpGet.
		local okHttp, httpBody = pcall(function()
			return game:HttpGet(url)
		end)

		if okHttp and type(httpBody) == "string" and #httpBody > 0 then
			body = httpBody
			successfulUrl = url
			break
		end
	end

	if not body then
		warn("[DayBreak] Failed to download logo:", safeName)
		warn("[DayBreak] Tried CDN and GitHub Raw:", safeName)
		return nil
	end

	local okWrite = pcall(function()
		writefile(localPath, body)
	end)

	if not okWrite then
		warn("[DayBreak] Failed to save logo:", localPath)
		return nil
	end

	AssetCache[localPath] = nil
	local asset = loadLocalAsset(localPath)

	if not asset then
		warn("[DayBreak] Downloaded logo but could not load asset:", safeName)
		warn("[DayBreak] Source:", successfulUrl or "unknown")
		return nil
	end

	return asset
end

local function getTagConfig(player)
	return SETTINGS.PlayerTags[player.UserId]
		or SETTINGS.PlayerTags[player.Name]
		or {}
end

local function isClickableFriend(player)
	-- Only configured non-local players are treated as clickable friends.
	-- Your own nametag is never clickable.
	if player == localPlayer then
		return false
	end

	return SETTINGS.ClickableFriendTagsEnabled
		and (SETTINGS.PlayerTags[player.UserId] ~= nil
			or SETTINGS.PlayerTags[player.Name] ~= nil)
end

local function teleportToPlayerInstantly(targetPlayer)
	if not targetPlayer or targetPlayer == localPlayer then
		return
	end

	local myCharacter = localPlayer.Character
	local targetCharacter = targetPlayer.Character

	if not myCharacter or not targetCharacter then
		return
	end

	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return
	end

	-- Option A: instant teleport directly to their exact position.
	myCharacter:PivotTo(targetRoot.CFrame)
end

--==================================================
-- CUSTOM DISPLAY NAME
--==================================================

local function getNametagName(player)
	local config = getTagConfig(player)
	return config.DisplayName or player.DisplayName
end

--==================================================
-- ROLE
--==================================================

local function getRole(player)
	local config = getTagConfig(player)
	return config.Role or SETTINGS.Roles[player.Name] or SETTINGS.DefaultRole
end

--==================================================
-- REMOVE OLD TAG
--==================================================

local function removeNametag(character)

	if not character then
		return
	end

	-- Clean up tags left behind by previous versions of this script.
	-- Earlier builds used several different BillboardGui names, so removing
	-- only "CustomDayBreakNametag" could leave an old overlay/sweep alive.
	local staleNames = {
		CustomDayBreakNametag = true,
		DayBreakNametag = true,
		DayBreakNameTag = true,
		DayBreakCircleLogo = true,
		DayBreakLogo = true,
	}

	-- Search the entire character hierarchy, not just direct children.
	-- This catches legacy tags/overlays that were parented under Head or
	-- another attachment and could otherwise survive the cleanup.
	for _, child in ipairs(character:GetDescendants()) do
		if child:IsA("BillboardGui") then
			local name = tostring(child.Name)
			if staleNames[name]
				or name:find("DayBreak", 1, true)
				or name:find("Nametag", 1, true)
				or name:find("NameTag", 1, true)
				or name:find("CircleLogo", 1, true)
				or name:find("ChromeSweep", 1, true)
				or name:find("ShineSweep", 1, true) then
				child:Destroy()
			end
		end
	end

	local oldLogo = character:FindFirstChild("DayBreakCircleLogo")
	if oldLogo then
		oldLogo:Destroy()
	end
end

--==================================================
-- CREATE NAMETAG
--==================================================

local function createNametag(player, character)

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head then
		head = character:WaitForChild("Head", 5)
	end

	if not head then
		return
	end

	removeNametag(character)

	--==================================================
	-- MAIN BILLBOARD
	--==================================================

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomDayBreakNametag"
	billboard:SetAttribute("DayBreakNametagVersion", "BannerOverlayV2")
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(
		SETTINGS.Width,
		SETTINGS.Height
	)
	billboard.StudsOffset = Vector3.new(
		0,
		SETTINGS.HeightOffset,
		0
	)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = SETTINGS.MaxDistance
	billboard.ResetOnSpawn = false
	billboard.Parent = character
	-- Explicit root bounds prevent Scale-based descendants from collapsing.
	billboard.Size = UDim2.fromOffset(SETTINGS.Width, SETTINGS.Height)
	billboard.Enabled = true

	--==================================================
	-- OUTER CHROME
	--==================================================

	local outer = Instance.new("Frame")
	outer.Size = UDim2.fromScale(1, 1)
	outer.BackgroundColor3 = SETTINGS.Chrome
	outer.BorderSizePixel = 0
	outer.Parent = billboard

	local outerCorner = Instance.new("UICorner")
	outerCorner.CornerRadius = UDim.new(0, 22)
	outerCorner.Parent = outer

	--==================================================
	-- ORANGE FRAME
	--==================================================

	local orangeFrame = Instance.new("Frame")
	orangeFrame.Size = UDim2.new(1, -6, 1, -6)
	orangeFrame.Position = UDim2.fromOffset(3, 3)
	orangeFrame.BackgroundColor3 = SETTINGS.Orange
	orangeFrame.BorderSizePixel = 0
	orangeFrame.Parent = outer

	local orangeCorner = Instance.new("UICorner")
	orangeCorner.CornerRadius = UDim.new(0, 20)
	orangeCorner.Parent = orangeFrame

	--==================================================
	-- INNER PANEL
	--==================================================

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(1, 1)
	panel.Position = UDim2.fromScale(0, 0)
	panel.AnchorPoint = Vector2.new(0, 0)
	panel.Size = UDim2.new(1, -6, 1, -6)
	panel.Position = UDim2.fromOffset(3, 3)
	panel.BackgroundColor3 = SETTINGS.Dark
	panel.BorderSizePixel = 0

	-- Prevents highlight from escaping
	panel.ClipsDescendants = true
	panel.Parent = orangeFrame

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 18)
	panelCorner.Parent = panel

	--==================================================
	-- PLAYER-SPECIFIC BACKGROUND
	--==================================================

	local tagConfig = getTagConfig(player)
	local backgroundImage

	local bannerFile = tagConfig.Banner
	local asset = nil

	if bannerFile then
		asset = downloadBanner(bannerFile)
	elseif tagConfig.BackgroundFile then
		-- Backwards-compatible local asset support.
		asset = loadLocalAsset(tagConfig.BackgroundFile)
	end

	if asset then
			backgroundImage = Instance.new("ImageLabel")
			backgroundImage.Name = "CustomBackground"
			backgroundImage.Size = UDim2.fromScale(1, 1)
			backgroundImage.Position = UDim2.fromScale(0, 0)
			backgroundImage.BackgroundTransparency = 1
			backgroundImage.Image = asset
			backgroundImage.ImageTransparency = tagConfig.BackgroundTransparency or 0
			backgroundImage.ScaleType = Enum.ScaleType.Stretch
			backgroundImage.ImageColor3 = Color3.new(1, 1, 1)
			backgroundImage.Visible = true
			backgroundImage.ZIndex = 1
			backgroundImage.Parent = panel

			local backgroundCorner = Instance.new("UICorner")
			backgroundCorner.CornerRadius = UDim.new(0, 18)
			backgroundCorner.Parent = backgroundImage
	else
		warn("[DayBreak] No banner asset loaded for", player.Name, "filename:", tostring(bannerFile))
	end

	--==================================================
	-- PANEL GLOW
	--==================================================

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Thickness = 2
	panelStroke.Color = SETTINGS.OrangeBright
	panelStroke.Transparency = 0.15
	panelStroke.Parent = panel

	--==================================================
	-- PROCEDURAL RAINBOW BORDER AROUND THE OUTSIDE
	-- Uses small rounded segments instead of UIGradient-on-UIStroke.
	-- This is intentionally more compatible with clients/executors that
	-- do not render gradient strokes correctly.
	--==================================================

	local rainbowContainer = Instance.new("Frame")
	rainbowContainer.Name = "RainbowBannerBorder"
	rainbowContainer.BackgroundTransparency = 1
rainbowContainer.Visible = false -- Disable rainbow pillar border
	rainbowContainer.BorderSizePixel = 0
	rainbowContainer.Size = UDim2.fromScale(1, 1)
	rainbowContainer.AnchorPoint = Vector2.new(0, 0)
	rainbowContainer.Position = UDim2.fromScale(0, 0)
	rainbowContainer.ClipsDescendants = false
	rainbowContainer.ZIndex = 50
	rainbowContainer.Parent = billboard

	local rainbowSegments = {}
	local RAINBOW_SEGMENT_COUNT = 61
	local RAINBOW_THICKNESS = SETTINGS.RainbowBannerThickness
	local RAINBOW_RADIUS = 20

	for i = 1, RAINBOW_SEGMENT_COUNT do
		local segment = Instance.new("Frame")
		segment.Name = "RainbowSegment" .. i
		segment.BackgroundColor3 = Color3.fromHSV((i - 1) / RAINBOW_SEGMENT_COUNT, 1, 1)
		segment.BorderSizePixel = 0
		segment.AnchorPoint = Vector2.new(0.5, 0.5)
		segment.ZIndex = 50
		segment.Parent = rainbowContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = segment

		local glow = Instance.new("UIStroke")
		glow.Name = "SoftGlow"
		glow.Thickness = 2
		glow.Transparency = 0.70
		glow.Color = segment.BackgroundColor3
		glow.ZIndex = 49
		glow.Parent = segment

		table.insert(rainbowSegments, {frame = segment, glow = glow})
	end

	local rainbowLastWidth = 0
	local rainbowLastHeight = 0

	local function buildRainbowBorder()
		local size = rainbowContainer.AbsoluteSize
		local w, h = size.X, size.Y
		if w <= 1 or h <= 1 then
			return
		end

		if math.abs(w - rainbowLastWidth) < 0.5 and math.abs(h - rainbowLastHeight) < 0.5 then
			return
		end
		rainbowLastWidth = w
		rainbowLastHeight = h

		local radius = math.min(RAINBOW_RADIUS, (h * 0.5) - 1, (w * 0.5) - 1)
		local points = {}

		local function addPoint(x, y)
			table.insert(points, Vector2.new(x, y))
		end

		-- Top edge
		for i = 0, 7 do
			local t = i / 7
			addPoint(radius + (w - 2 * radius) * t, 0)
		end
		-- Top-right corner
		for i = 1, 8 do
			local a = -math.pi / 2 + (math.pi / 2) * (i / 8)
			addPoint(w - radius + math.cos(a) * radius, radius + math.sin(a) * radius)
		end
		-- Right edge
		for i = 1, 7 do
			local t = i / 7
			addPoint(w, radius + (h - 2 * radius) * t)
		end
		-- Bottom-right corner
		for i = 1, 8 do
			local a = 0 + (math.pi / 2) * (i / 8)
			addPoint(w - radius + math.cos(a) * radius, h - radius + math.sin(a) * radius)
		end
		-- Bottom edge
		for i = 1, 7 do
			local t = i / 7
			addPoint(w - radius - (w - 2 * radius) * t, h)
		end
		-- Bottom-left corner
		for i = 1, 8 do
			local a = math.pi / 2 + (math.pi / 2) * (i / 8)
			addPoint(radius + math.cos(a) * radius, h - radius + math.sin(a) * radius)
		end
		-- Left edge
		for i = 1, 7 do
			local t = i / 7
			addPoint(0, h - radius - (h - 2 * radius) * t)
		end
		-- Top-left corner
		for i = 1, 8 do
			local a = math.pi + (math.pi / 2) * (i / 8)
			addPoint(radius + math.cos(a) * radius, radius + math.sin(a) * radius)
		end

		for i, data in ipairs(rainbowSegments) do
			local p1 = points[i]
			local p2 = points[(i % #points) + 1]
			if p1 and p2 then
				local delta = p2 - p1
				local length = delta.Magnitude + 2
				local midpoint = (p1 + p2) * 0.5
				data.frame.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
				data.frame.Size = UDim2.fromOffset(length, RAINBOW_THICKNESS)
				data.frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			end
		end
	end

	buildRainbowBorder()

	--==================================================
	-- STAR CIRCLE
	--==================================================

	local starCircle = Instance.new("Frame")
	starCircle.Size = UDim2.fromOffset(58, 58)
	starCircle.Position = UDim2.new(0, 8, 0.5, -29)
	starCircle.BackgroundColor3 = SETTINGS.DarkInner
	starCircle.BorderSizePixel = 0
	starCircle.ClipsDescendants = true
	starCircle.ZIndex = 2
	starCircle.Parent = panel

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = starCircle

	local circleStroke = Instance.new("UIStroke")
	circleStroke.Thickness = 2
	circleStroke.Color = SETTINGS.Orange
	circleStroke.Transparency = 0.1
	circleStroke.Parent = starCircle

	--==================================================
	-- CUSTOM LOGO / STAR FALLBACK
	--==================================================

	local customLogoAsset = nil
	if tagConfig.Logo then
		customLogoAsset = downloadLogo(tagConfig.Logo)
	end

	local starGlow = Instance.new("TextLabel")
	starGlow.BackgroundTransparency = 1
	starGlow.Size = UDim2.new(1, 20, 1, 20)
	starGlow.Position = UDim2.fromOffset(-10, -10)
	starGlow.Text = "★"
	starGlow.TextColor3 = SETTINGS.OrangeBright
	starGlow.TextTransparency = 0.65
	starGlow.TextScaled = true
	starGlow.Font = Enum.Font.GothamBlack
	starGlow.ZIndex = 2
	starGlow.Visible = customLogoAsset == nil
	starGlow.Parent = starCircle

	local star = Instance.new("TextLabel")
	star.BackgroundTransparency = 1
	star.Size = UDim2.fromScale(1, 1)
	star.Text = "★"
	star.TextColor3 = SETTINGS.White
	star.TextScaled = true
	star.Font = Enum.Font.GothamBlack
	star.TextStrokeColor3 = SETTINGS.Orange
	star.TextStrokeTransparency = 0.2
	star.ZIndex = 3
	star.Visible = customLogoAsset == nil
	star.Parent = starCircle

	local customLogo = nil
	local logoVisual = Instance.new("Frame")
	logoVisual.Name = "LogoVisual"
	logoVisual.Size = UDim2.new(1, -8, 1, -8)
	logoVisual.Position = UDim2.fromScale(0.5, 0.5)
	logoVisual.AnchorPoint = Vector2.new(0.5, 0.5)
	logoVisual.BackgroundTransparency = 1
	logoVisual.BorderSizePixel = 0
	logoVisual.ZIndex = 3
	logoVisual.ClipsDescendants = false
	logoVisual.Parent = starCircle

	local logoVisualScale = Instance.new("UIScale")
	logoVisualScale.Scale = 1
	logoVisualScale.Parent = logoVisual

	if customLogoAsset and customLogoAsset ~= "" then
		customLogo = Instance.new("ImageLabel")
		customLogo.Name = "customLogo"
		customLogo.BackgroundTransparency = 1
		customLogo.BorderSizePixel = 0
		customLogo.Size = UDim2.fromScale(1, 1)
		customLogo.Position = UDim2.fromScale(0, 0)
		customLogo.AnchorPoint = Vector2.new(0, 0)
		customLogo.Image = customLogoAsset
		customLogo.ScaleType = Enum.ScaleType.Fit
		customLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
		customLogo.ZIndex = 3
		customLogo.Visible = true
		customLogo.ClipsDescendants = true
		customLogo.Parent = logoVisual

		local customLogoCorner = Instance.new("UICorner")
		customLogoCorner.CornerRadius = UDim.new(1, 0)
		customLogoCorner.Parent = customLogo

		local customLogoAspect = Instance.new("UIAspectRatioConstraint")
		customLogoAspect.AspectRatio = 1
		customLogoAspect.Parent = customLogo
	else
		starGlow.Parent = logoVisual
		star.Parent = logoVisual
	end

	--==================================================
	-- OWNER RING
	--==================================================

	local ownerRing = Instance.new("Frame")
	ownerRing.Name = "OwnerRing"
	ownerRing.BackgroundTransparency = 1
	ownerRing.BorderSizePixel = 0
	ownerRing.Size = UDim2.new(1, -2, 1, -2)
	ownerRing.Position = UDim2.new(0, 1, 0, 1)
	ownerRing.ZIndex = 4
	ownerRing.Parent = starCircle

	local ownerRingCorner = Instance.new("UICorner")
	ownerRingCorner.CornerRadius = UDim.new(1, 0)
	ownerRingCorner.Parent = ownerRing

	local ownerRingStroke = Instance.new("UIStroke")
	ownerRingStroke.Thickness = 2
	ownerRingStroke.Color = SETTINGS.OrangeBright
	ownerRingStroke.Transparency = 0.15
	ownerRingStroke.Parent = ownerRing

	local ownerBadge = Instance.new("TextLabel")
	ownerBadge.Name = "OwnerBadge"
	ownerBadge.BackgroundTransparency = 0
	ownerBadge.BackgroundColor3 = SETTINGS.OrangeBright
	ownerBadge.BorderSizePixel = 0
	ownerBadge.Size = UDim2.new(0, 52, 0, 16)
	ownerBadge.Position = UDim2.new(0.5, -26, 1, -3)
	ownerBadge.ZIndex = 6
	ownerBadge.Font = Enum.Font.GothamBold
	ownerBadge.Text = "OWNER"
	ownerBadge.TextColor3 = Color3.fromRGB(20, 12, 5)
	ownerBadge.TextSize = 10
	ownerBadge.Parent = starCircle

	local ownerBadgeCorner = Instance.new("UICorner")
	ownerBadgeCorner.CornerRadius = UDim.new(0, 8)
	ownerBadgeCorner.Parent = ownerBadge



	--==================================================
	-- BANNER OVERLAY SYSTEM (REBUILT)
	--==================================================
	-- The previous overlay implementation mixed several rendering methods
	-- (rotated gradients, sweep frames, and shared strip logic). That made
	-- different overlay types interfere with each other and made it hard to
	-- tell whether an effect was actually being created.
	--
	-- This version gives every overlay its own objects and keeps the overlay
	-- strictly inside the banner area. ChromeSweep is intentionally excluded.

	local overlayConfig = tagConfig.Overlay or {
		Enabled = true,
		Type = "Prism",
		Speed = 0.35,
		Opacity = 0.55,
		Glow = true,
	}

	local overlayType = tostring(overlayConfig.Type or "Prism")
	local overlaySpeed = tonumber(overlayConfig.Speed) or 1.2
	local overlayOpacity = math.clamp(tonumber(overlayConfig.Opacity) or 0.55, 0, 1)

	local overlayFolder = Instance.new("Frame")
	overlayFolder.Name = "BannerOverlay"
	overlayFolder.Size = UDim2.new(1, -66, 1, 0)
	overlayFolder.Position = UDim2.fromOffset(64, 0)
	overlayFolder.BackgroundTransparency = 1
	overlayFolder.BorderSizePixel = 0
	overlayFolder.ClipsDescendants = true
	overlayFolder.ZIndex = 2
	overlayFolder.Visible = overlayConfig.Enabled ~= false
	overlayFolder.Parent = panel

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, 16)
	overlayCorner.Parent = overlayFolder

	local overlayObjects = {}
	local movingObjects = {}
	local twinkleObjects = {}

	local function addOverlay(name)
		local obj = Instance.new("Frame")
		obj.Name = name
		obj.BackgroundTransparency = 1
		obj.BorderSizePixel = 0
		obj.ZIndex = 2
		obj.Parent = overlayFolder
		table.insert(overlayObjects, obj)
		return obj
	end

	local function addGradient(obj, sequence, rotation)
		local g = Instance.new("UIGradient")
		g.Color = sequence
		g.Rotation = rotation or 0
		g.Parent = obj
		return g
	end

	local rainbowSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,120,0)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0,255,80)),
		ColorSequenceKeypoint.new(0.64, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(70,100,255)),
		ColorSequenceKeypoint.new(0.92, Color3.fromRGB(180,0,255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,180)),
	})

	local function addWash(name, sequence, transparency)
		local f = addOverlay(name)
		f.Size = UDim2.fromScale(1, 1)
		f.Position = UDim2.fromScale(0, 0)
		f.BackgroundColor3 = Color3.new(1,1,1)
		f.BackgroundTransparency = math.clamp(transparency + 0.05, 0, 1)
		addGradient(f, sequence, 0)
		return f
	end

	local function addSweep(name, width, sequence, transparency)
		local f = addOverlay(name)
		f.Size = UDim2.new(0, width, 1, 0)
		f.Position = UDim2.new(-0.25, 0, 0, 0)
		f.BackgroundColor3 = Color3.new(1,1,1)
		f.BackgroundTransparency = transparency
		addGradient(f, sequence, 0)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1,0)
		c.Parent = f
		table.insert(movingObjects, f)
		return f
	end

	if overlayConfig.Enabled ~= false then
		if overlayType == "ChromeSweep" then
			-- Permanently disabled. This is the original artifact.
			overlayFolder.Visible = false

		elseif overlayType == "Starlight" then
			for i = 1, 24 do
				local f = addOverlay("Star" .. i)
				local size = (i % 4 == 0) and 6 or ((i % 2 == 0) and 5 or 4)
				f.Size = UDim2.fromOffset(size, size)
				f.Position = UDim2.fromScale(
					((i * 0.173) % 0.92) + 0.04,
					((i * 0.317) % 0.82) + 0.05
				)
				f.BackgroundColor3 = (i % 4 == 0)
					and Color3.fromRGB(140,220,255)
					or Color3.new(1,1,1)
				f.BackgroundTransparency = 0.05
				local glow = Instance.new("UIStroke")
				glow.Thickness = 1
				glow.Transparency = 0.35
				glow.Color = f.BackgroundColor3
				glow.Parent = f
				local c = Instance.new("UICorner")
				c.CornerRadius = UDim.new(1,0)
				c.Parent = f
				table.insert(twinkleObjects, f)
			end

		elseif overlayType == "Prism" then
			for i = 1, 5 do
				local f = addOverlay("Prism" .. i)
				f.Size = UDim2.new(0, 7, 1, 0)
				f.Position = UDim2.new(-0.4 - i * 0.28, 0, 0, 0)
				local prismColors = {
					Color3.fromRGB(255,70,120),
					Color3.fromRGB(255,170,60),
					Color3.fromRGB(80,255,190),
					Color3.fromRGB(80,170,255),
					Color3.fromRGB(210,80,255),
				}
				f.BackgroundColor3 = prismColors[i]
				f.BackgroundTransparency = 0.35
				local g = Instance.new("UIGradient")
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, prismColors[i]),
					ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
					ColorSequenceKeypoint.new(1, prismColors[i]),
				})
				g.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.85),
					NumberSequenceKeypoint.new(0.5, 0.10),
					NumberSequenceKeypoint.new(1, 0.85),
				})
				g.Parent = f
				table.insert(movingObjects, f)
			end

		elseif overlayType == "SpeedLines" then
			for i = 1, 8 do
				local f = addOverlay("SpeedLine" .. i)
				f.Size = UDim2.new(0, 3, 1, 0)
				f.Position = UDim2.new(-0.5 - i * 0.20, 0, 0, 0)
				f.BackgroundColor3 = Color3.new(1,1,1)
				f.BackgroundTransparency = 0.88
				table.insert(movingObjects, f)
			end

		elseif overlayType == "Holographic" then
			addWash("Holographic", ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,70,220)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(70,190,255)),
				ColorSequenceKeypoint.new(0.66, Color3.fromRGB(180,70,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,70,220)),
			}), 1 - math.min(overlayOpacity, 0.45))

		elseif overlayType == "Iridescent" then
			addWash("Iridescent", ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,190,230)),
				ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180,230,255)),
				ColorSequenceKeypoint.new(0.7, Color3.fromRGB(225,190,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,240,190)),
			}), 0.70)

		elseif overlayType == "RainbowFlow" or overlayType == "RainbowPulse" or overlayType == "NeonRainbow" then
			local f = addWash("Rainbow", rainbowSequence, overlayType == "NeonRainbow" and 0.52 or 0.68)
			f:SetAttribute("RainbowFlow", true)

		elseif overlayType == "Aurora" then
			addWash("Aurora", ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20,255,150)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40,150,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(190,60,255)),
			}), 0.62)

		elseif overlayType == "MetallicFlow" then
			addWash("Metallic", ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(70,70,80)),
				ColorSequenceKeypoint.new(0.30, Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(140,140,150)),
				ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(60,60,70)),
			}), 0.62)

		elseif overlayType == "GlassSweep" then
			addSweep("GlassSweep", 26, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(120,190,255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245,250,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(120,190,255)),
			}), 0.72)

		elseif overlayType == "DiamondShine" then
			addSweep("DiamondShine", 18, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
			}), 0.82)

		elseif overlayType == "Gloss" then
			addSweep("Gloss", 22, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
			}), 0.88)

		elseif overlayType == "EnergyPulse" then
			addSweep("EnergyPulse", 30, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(70,130,255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(70,130,255)),
			}), 0.78)

		elseif overlayType == "LaserSweep" then
			addSweep("LaserSweep", 5, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,50,50)),
				ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,50,50)),
			}), 0.40)

		elseif overlayType == "Scanline" then
			local f = addOverlay("Scanline")
			f.Size = UDim2.new(1,0,0,2)
			f.Position = UDim2.fromScale(0,-0.1)
			f.BackgroundColor3 = Color3.new(1,1,1)
			f.BackgroundTransparency = 0.45
			table.insert(movingObjects, f)

		elseif overlayType == "Glitch" or overlayType == "Static" then
			for i = 1, 7 do
				local f = addOverlay("Glitch" .. i)
				f.Size = UDim2.new(1,0,0,2 + (i % 2))
				f.Position = UDim2.fromScale(0, (i - 1) / 7)
				f.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255,80,150) or Color3.fromRGB(80,220,255)
				f.BackgroundTransparency = overlayType == "Glitch" and 0.50 or 0.72
				table.insert(movingObjects, f)
			end

		elseif overlayType == "ColorShift" or overlayType == "Sunset" or overlayType == "Ocean"
			or overlayType == "Fire" or overlayType == "Ice" or overlayType == "Electric"
			or overlayType == "Lava" or overlayType == "Toxic" or overlayType == "ShadowFlame"
			or overlayType == "Cyber" or overlayType == "Galaxy" or overlayType == "Cosmic"
			or overlayType == "Void" then
			local palettes = {
				ColorShift = ColorSequence.new(Color3.fromRGB(255,70,100), Color3.fromRGB(70,150,255)),
				Sunset = ColorSequence.new(Color3.fromRGB(255,100,30), Color3.fromRGB(140,40,190)),
				Ocean = ColorSequence.new(Color3.fromRGB(0,70,160), Color3.fromRGB(0,220,255)),
				Fire = ColorSequence.new(Color3.fromRGB(120,0,0), Color3.fromRGB(255,190,0)),
				Ice = ColorSequence.new(Color3.fromRGB(40,130,255), Color3.fromRGB(220,255,255)),
				Electric = ColorSequence.new(Color3.fromRGB(80,120,255), Color3.fromRGB(220,100,255)),
				Lava = ColorSequence.new(Color3.fromRGB(70,0,0), Color3.fromRGB(255,60,0)),
				Toxic = ColorSequence.new(Color3.fromRGB(20,80,0), Color3.fromRGB(180,255,0)),
				ShadowFlame = ColorSequence.new(Color3.fromRGB(20,0,30), Color3.fromRGB(180,30,80)),
				Cyber = ColorSequence.new(Color3.fromRGB(0,255,255), Color3.fromRGB(220,0,255)),
				Galaxy = ColorSequence.new(Color3.fromRGB(20,0,70), Color3.fromRGB(80,20,180)),
				Cosmic = ColorSequence.new(Color3.fromRGB(10,0,50), Color3.fromRGB(100,30,220)),
				Void = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(45,0,70)),
			}
			addWash("ColorWash", palettes[overlayType], 0.60)
		else
			-- Unknown type: create a visible but harmless fallback so the user
			-- can immediately tell that the overlay system is alive.
			local f = addOverlay("OverlayFallback")
			f.Size = UDim2.fromScale(1,1)
			f.BackgroundColor3 = Color3.fromRGB(255,80,180)
			f.BackgroundTransparency = 0.82
		end
	end

	local overlayTime = 0

	--==================================================
	-- PLAYER NAME
	--==================================================

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromOffset(185, 30)
	nameLabel.Position = UDim2.fromOffset(78, 10)
	nameLabel.BackgroundTransparency = 1

	-- Custom name from PlayerTags, or Roblox DisplayName if none is set
	nameLabel.Text = getNametagName(player)

	nameLabel.TextColor3 = SETTINGS.White
	nameLabel.TextSize = 19
	nameLabel.Font = SETTINGS.Font

	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center

	nameLabel.TextStrokeColor3 = SETTINGS.Orange
	nameLabel.TextStrokeTransparency = 0.15

	-- OWNER ONLY: moving rainbow across the player's name.
	-- UIGradient is applied directly to the TextLabel so the colors
	-- follow the letters instead of affecting the banner border.
	local ownerNameGradient = Instance.new("UIGradient")
	ownerNameGradient.Name = "OwnerRainbowName"
	ownerNameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 120, 0)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0, 255, 70)),
		ColorSequenceKeypoint.new(0.64, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(70, 100, 255)),
		ColorSequenceKeypoint.new(0.92, Color3.fromRGB(180, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 180)),
	})
	-- Keep the gradient on the actual text. Rotation is used instead of
	-- Offset so the full rainbow remains visible while it continuously moves.
	ownerNameGradient.Rotation = 0
	ownerNameGradient.Offset = Vector2.new(0, 0)
	ownerNameGradient.Enabled = (getRole(player) == "OWNER") and SETTINGS.OwnerRainbowNameEnabled
	ownerNameGradient.Parent = nameLabel

	nameLabel.ZIndex = 6
	nameLabel.Parent = panel

	--==================================================
	-- ROLE
	--==================================================

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.fromOffset(185, 20)
	subtitle.Position = UDim2.fromOffset(79, 39)
	subtitle.BackgroundTransparency = 1

	subtitle.Text = "★ " .. getRole(player)

	subtitle.TextColor3 = SETTINGS.OrangeBright
	subtitle.TextSize = 11
	subtitle.Font = Enum.Font.GothamBold

	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Center

	subtitle.TextStrokeColor3 = SETTINGS.Dark
	subtitle.TextStrokeTransparency = 0.4

	subtitle.ZIndex = 6
	subtitle.Parent = panel

	--==================================================
	-- MOVING HIGHLIGHT
	--==================================================

	local highlight = Instance.new("Frame")
	highlight.Size = UDim2.fromOffset(55, 2)
	highlight.Position = UDim2.fromOffset(-55, 7)
	highlight.BackgroundColor3 = SETTINGS.White
	highlight.BackgroundTransparency = 0.15
	highlight.BorderSizePixel = 0
	highlight.ZIndex = 5
	highlight.Parent = panel

	local highlightCorner = Instance.new("UICorner")
	highlightCorner.CornerRadius = UDim.new(1, 0)
	highlightCorner.Parent = highlight

	--==================================================
	-- CLICKABLE FRIEND TAG
	--==================================================
	-- Invisible button over the full nametag.
	-- Your own tag is excluded by isClickableFriend().
	if isClickableFriend(player) then
		local friendClickButton = Instance.new("TextButton")
		friendClickButton.Name = "FriendTeleportButton"
		friendClickButton.Size = UDim2.fromScale(1, 1)
		friendClickButton.Position = UDim2.fromScale(0, 0)
		friendClickButton.BackgroundTransparency = 1
		friendClickButton.BorderSizePixel = 0
		friendClickButton.Text = ""
		friendClickButton.AutoButtonColor = false
		friendClickButton.Active = true
		friendClickButton.Selectable = false
		friendClickButton.ZIndex = 100
		friendClickButton.Parent = billboard

		friendClickButton.MouseButton1Click:Connect(function()
			teleportToPlayerInstantly(player)
		end)
	end

	--==================================================
	-- CIRCLE-ONLY BILLBOARD
	--==================================================

	local logoBillboard = Instance.new("BillboardGui")
	logoBillboard.Name = "DayBreakCircleLogo"
	logoBillboard.Adornee = head
	logoBillboard.Size = UDim2.fromOffset(
		SETTINGS.CircleSize,
		SETTINGS.CircleSize
	)
	logoBillboard.StudsOffset = Vector3.new(
		0,
		SETTINGS.HeightOffset,
		0
	)
	logoBillboard.AlwaysOnTop = true
	logoBillboard.MaxDistance = SETTINGS.MaxDistance
	logoBillboard.ResetOnSpawn = false
	logoBillboard.Enabled = false
	logoBillboard.Parent = character

	-- Make the distant circular tag clickable too.
	if isClickableFriend(player) then
		local distantClickButton = Instance.new("TextButton")
		distantClickButton.Name = "FriendTeleportButton"
		distantClickButton.Size = UDim2.fromScale(1, 1)
		distantClickButton.Position = UDim2.fromScale(0, 0)
		distantClickButton.BackgroundTransparency = 1
		distantClickButton.BorderSizePixel = 0
		distantClickButton.Text = ""
		distantClickButton.AutoButtonColor = false
		distantClickButton.Active = true
		distantClickButton.Selectable = false
		distantClickButton.ZIndex = 100
		distantClickButton.Parent = logoBillboard

		distantClickButton.MouseButton1Click:Connect(function()
			teleportToPlayerInstantly(player)
		end)
	end

	--==================================================
	-- LOGO CIRCLE
	--==================================================

	local logoCircle = Instance.new("Frame")
	logoCircle.Size = UDim2.fromScale(1, 1)
	logoCircle.BackgroundColor3 = SETTINGS.DarkInner
	logoCircle.BorderSizePixel = 0
	logoCircle.ClipsDescendants = true
	logoCircle.Parent = logoBillboard

	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(1, 0)
	logoCorner.Parent = logoCircle

	local logoStroke = Instance.new("UIStroke")
	logoStroke.Thickness = 2
	logoStroke.Color = SETTINGS.Orange
	logoStroke.Transparency = 0.1
	logoStroke.Parent = logoCircle

	--==================================================
	-- CUSTOM LOGO / STAR FALLBACK
	--==================================================

	local logoGlow = Instance.new("TextLabel")
	logoGlow.BackgroundTransparency = 1
	logoGlow.Size = UDim2.new(1, 20, 1, 20)
	logoGlow.Position = UDim2.fromOffset(-10, -10)
	logoGlow.Text = "★"
	logoGlow.TextColor3 = SETTINGS.OrangeBright
	logoGlow.TextTransparency = 0.65
	logoGlow.TextScaled = true
	logoGlow.Font = Enum.Font.GothamBlack
	logoGlow.ZIndex = 1
	logoGlow.Visible = customLogoAsset == nil
	logoGlow.Parent = logoCircle

	local logoStar = Instance.new("TextLabel")
	logoStar.BackgroundTransparency = 1
	logoStar.Size = UDim2.fromScale(1, 1)
	logoStar.Text = "★"
	logoStar.TextColor3 = SETTINGS.White
	logoStar.TextScaled = true
	logoStar.Font = Enum.Font.GothamBlack
	logoStar.TextStrokeColor3 = SETTINGS.Orange
	logoStar.TextStrokeTransparency = 0.2
	logoStar.ZIndex = 2
	logoStar.Visible = customLogoAsset == nil
	logoStar.Parent = logoCircle

	local customLogoDistant = nil
	local distantLogoVisual = Instance.new("Frame")
	distantLogoVisual.Name = "LogoVisual"
	distantLogoVisual.Size = UDim2.new(1, -8, 1, -8)
	distantLogoVisual.Position = UDim2.fromScale(0.5, 0.5)
	distantLogoVisual.AnchorPoint = Vector2.new(0.5, 0.5)
	distantLogoVisual.BackgroundTransparency = 1
	distantLogoVisual.BorderSizePixel = 0
	distantLogoVisual.ZIndex = 3
	distantLogoVisual.ClipsDescendants = false
	distantLogoVisual.Parent = logoCircle

	local distantLogoVisualScale = Instance.new("UIScale")
	distantLogoVisualScale.Scale = 1
	distantLogoVisualScale.Parent = distantLogoVisual

	if customLogoAsset and customLogoAsset ~= "" then
		customLogoDistant = Instance.new("ImageLabel")
		customLogoDistant.Name = "customLogoDistant"
		customLogoDistant.BackgroundTransparency = 1
		customLogoDistant.BorderSizePixel = 0
		customLogoDistant.Size = UDim2.fromScale(1, 1)
		customLogoDistant.Position = UDim2.fromScale(0, 0)
		customLogoDistant.AnchorPoint = Vector2.new(0, 0)
		customLogoDistant.Image = customLogoAsset
		customLogoDistant.ScaleType = Enum.ScaleType.Fit
		customLogoDistant.ImageColor3 = Color3.fromRGB(255, 255, 255)
		customLogoDistant.ZIndex = 3
		customLogoDistant.Visible = true
		customLogoDistant.ClipsDescendants = true
		customLogoDistant.Parent = distantLogoVisual

		local customLogoDistantCorner = Instance.new("UICorner")
		customLogoDistantCorner.CornerRadius = UDim.new(1, 0)
		customLogoDistantCorner.Parent = customLogoDistant

		local customLogoDistantAspect = Instance.new("UIAspectRatioConstraint")
		customLogoDistantAspect.AspectRatio = 1
		customLogoDistantAspect.Parent = customLogoDistant
	else
		logoGlow.Parent = distantLogoVisual
		logoStar.Parent = distantLogoVisual
	end

	--==================================================
	-- OWNER DISTANT RING
	--==================================================

	local ownerRingDistant = Instance.new("Frame")
	ownerRingDistant.Name = "OwnerRingDistant"
	ownerRingDistant.BackgroundTransparency = 1
	ownerRingDistant.BorderSizePixel = 0
	ownerRingDistant.Size = UDim2.new(1, -2, 1, -2)
	ownerRingDistant.Position = UDim2.new(0, 1, 0, 1)
	ownerRingDistant.ZIndex = 4
	ownerRingDistant.Parent = logoCircle

	local ownerRingDistantCorner = Instance.new("UICorner")
	ownerRingDistantCorner.CornerRadius = UDim.new(1, 0)
	ownerRingDistantCorner.Parent = ownerRingDistant

	local ownerRingDistantStroke = Instance.new("UIStroke")
	ownerRingDistantStroke.Thickness = 2
	ownerRingDistantStroke.Color = SETTINGS.OrangeBright
	ownerRingDistantStroke.Transparency = 0.15
	ownerRingDistantStroke.Parent = ownerRingDistant



	--==================================================
	-- LOGO EFFECTS
	-- These effects never change the logo's base Position/Size.
	-- UIScale + a centered wrapper prevent the previous "off" behavior.
	--==================================================

	local logoEffectNames = {}
	for _, effectName in ipairs(SETTINGS.LogoEffects or {}) do
		logoEffectNames[effectName] = true
	end

	local function logoFxOn(name)
		-- HARD BLOCK legacy sweep effects. These can recreate the old
		-- ChromeSweep-looking artifact even when the config list is clean.
		if name == "ChromeSweep" or name == "ShineSweep" or name == "Scanline" then
			return false
		end
		return SETTINGS.LogoEffectsEnabled ~= false and logoEffectNames[name] == true
	end

	local logoFxSpeed = tonumber(SETTINGS.LogoEffectsSpeed) or 1

	-- Effect containers stay outside the logo image itself.
	local logoFx = Instance.new("Frame")
	logoFx.Name = "LogoEffects"
	logoFx.Size = UDim2.fromScale(1,1)
	logoFx.Position = UDim2.fromScale(0,0)
	logoFx.BackgroundTransparency = 1
	logoFx.BorderSizePixel = 0
	logoFx.ClipsDescendants = false
	logoFx.ZIndex = 5
	logoFx.Parent = starCircle

	local function fxFrame(name, z)
		local f=Instance.new("Frame")
		f.Name=name
		f.Size=UDim2.fromScale(1,1)
		f.Position=UDim2.fromScale(0,0)
		f.BackgroundTransparency=1
		f.BorderSizePixel=0
		f.ZIndex=z or 5
		f.Parent=logoFx
		return f
	end

	local fxGlow, fxRing, fxHalo, fxSweep, fxScan, fxRipple, fxShock
	local orbit, sparkles, bursts, arcs = {}, {}, {}, {}
	local trail = {}

	if logoFxOn("GlowPulse") or logoFxOn("OutlineGlow") then
		fxGlow=fxFrame("Glow",4)
		fxGlow.Size=UDim2.new(1,8,1,8)
		fxGlow.Position=UDim2.new(0,-4,0,-4)
		local s=Instance.new("UIStroke")
		s.Thickness=logoFxOn("OutlineGlow") and 2 or 5
		s.Transparency=0.35
		s.Color=SETTINGS.OrangeBright
		s.Parent=fxGlow
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(1,0)
		c.Parent=fxGlow
	end

	if logoFxOn("OuterRing") or logoFxOn("RingRotation") or logoFxOn("CounterRotation") then
		fxRing=fxFrame("OuterRing",6)
		fxRing.Size=UDim2.new(1,10,1,10)
		fxRing.Position=UDim2.new(0,-5,0,-5)
		local s=Instance.new("UIStroke")
		s.Thickness=2
		s.Transparency=0.12
		s.Color=SETTINGS.OrangeBright
		s.Parent=fxRing
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(1,0)
		c.Parent=fxRing
	end

	if logoFxOn("Halo") then
		fxHalo=fxFrame("Halo",3)
		fxHalo.Size=UDim2.new(1,22,1,22)
		fxHalo.Position=UDim2.new(0,-11,0,-11)
		local s=Instance.new("UIStroke")
		s.Thickness=6
		s.Transparency=0.65
		s.Color=SETTINGS.OrangeBright
		s.Parent=fxHalo
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(1,0)
		c.Parent=fxHalo
	end

	if false and logoFxOn("ShineSweep") then
		fxSweep=fxFrame("Sweep",8)
		fxSweep.Size=UDim2.new(0,6,1,0)
		fxSweep.Position=UDim2.fromScale(-0.15,0)
		fxSweep.Rotation=0
		fxSweep.BackgroundTransparency=0.82
		fxSweep.ClipsDescendants=true
		local g=Instance.new("UIGradient")
		g.Color=ColorSequence.new(
			ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1,Color3.new(1,1,1))
		)
		g.Parent=fxSweep
	end

	if false and logoFxOn("Scanline") then
		fxScan=fxFrame("Scanline",9)
		fxScan.Size=UDim2.new(1,0,0,2)
		fxScan.BackgroundColor3=Color3.new(1,1,1)
		fxScan.BackgroundTransparency=0.15
	end

	if logoFxOn("EnergyAura") then
		fxHalo=fxHalo or fxFrame("EnergyAura",3)
		fxHalo.Size=UDim2.new(1,10,1,10)
		fxHalo.Position=UDim2.new(0,-5,0,-5)
		fxHalo.BackgroundColor3=SETTINGS.OrangeBright
		fxHalo.BackgroundTransparency=0.92
		local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fxHalo
	end

	if logoFxOn("Ripple") then
		fxRipple=fxFrame("Ripple",7)
		fxRipple.Size=UDim2.fromOffset(4,4)
		fxRipple.Position=UDim2.fromScale(0.5,0.5)
		local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=0.1; s.Color=SETTINGS.OrangeBright; s.Parent=fxRipple
		local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fxRipple
	end

	if logoFxOn("Shockwave") then
		fxShock=fxFrame("Shockwave",7)
		fxShock.Size=UDim2.fromOffset(4,4)
		fxShock.Position=UDim2.fromScale(0.5,0.5)
		local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=0.1; s.Color=SETTINGS.OrangeBright; s.Parent=fxShock
		local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fxShock
	end

	if logoFxOn("OrbitingParticles") then
		for i=1,8 do
			local p=fxFrame("Orbit"..i,8)
			p.Size=UDim2.fromOffset(3,3)
			p.BackgroundColor3=SETTINGS.OrangeBright
			local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=p
			orbit[i]=p
		end
	end

	if logoFxOn("SparkleFlashes") then
		for i=1,5 do
			local s=fxFrame("Spark"..i,10)
			s.Size=UDim2.fromOffset(5,5)
			s.BackgroundColor3=Color3.new(1,1,1)
			s.BackgroundTransparency=1
			s.Rotation=45
			s.Position=UDim2.fromScale(0.1+i*0.17,0.15+((i*0.29)%0.65))
			sparkles[i]=s
		end
	end

	if logoFxOn("ParticleBurst") then
		for i=1,10 do
			local p=fxFrame("Burst"..i,9)
			p.Size=UDim2.fromOffset(3,3)
			p.BackgroundColor3=SETTINGS.OrangeBright
			p.BackgroundTransparency=1
			local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=p
			bursts[i]=p
		end
	end

	if logoFxOn("Trail") and customLogo then
		for i=1,3 do
			local t=Instance.new("ImageLabel")
			t.Name="Trail"..i
			t.BackgroundTransparency=1
			t.Size=UDim2.fromScale(0.92,0.92)
			t.Position=UDim2.fromScale(0.04,0.04)
			t.Image=customLogoAsset
			t.ScaleType=Enum.ScaleType.Fit
			t.ImageTransparency=1
			t.ImageColor3=SETTINGS.OrangeBright
			t.ZIndex=2
			t.Parent=logoFx
			trail[i]=t
		end
	end

	if logoFxOn("ElectricArcs") then
		for i=1,6 do
			local a=fxFrame("Arc"..i,10)
			a.Size=UDim2.fromOffset(12,2)
			a.BackgroundColor3=Color3.fromRGB(255,210,120)
			a.Rotation=i*60
			arcs[i]=a
		end
	end

	local logoFxTime=0
	local burstClock=0
	local sparkleClock=0


	--==================================================
	-- ANIMATION
	--==================================================

	local startTime = tick()

	local connection

	connection = RunService.RenderStepped:Connect(function(deltaTime)

		if not character or not character.Parent or not head or not head.Parent then
			if connection then connection:Disconnect() end
			return
		end

		local camera = workspace.CurrentCamera

		if not camera then
			return
		end

		local distance = (
			camera.CFrame.Position - head.Position
		).Magnitude

		local time = tick() - startTime

		--==================================================
		-- FULL TAG / LOGO SWITCH
		--==================================================

		if distance >= SETTINGS.CircleOnlyDistance then
			billboard.Enabled = false
			logoBillboard.Enabled = true
		else
			billboard.Enabled = true
			logoBillboard.Enabled = false
		end

		--==================================================
		-- FULL TAG SCALE
		--==================================================

		if SETTINGS.DistanceScaling then

			local scale =
				SETTINGS.NormalDistance /
				math.max(distance, 1)

			scale = math.clamp(
				scale,
				SETTINGS.MinScale,
				SETTINGS.MaxScale
			)

			billboard.Size = UDim2.fromOffset(
				SETTINGS.Width * scale,
				SETTINGS.Height * scale
			)

		end

		--==================================================
		-- CIRCLE SCALE
		--==================================================

		if SETTINGS.CircleDistanceScaling then

			local circleDistance = math.max(
				distance,
				SETTINGS.CircleShrinkStart
			)

			local shrinkRange =
				SETTINGS.MaxDistance -
				SETTINGS.CircleShrinkStart

			local progress =
				(circleDistance - SETTINGS.CircleShrinkStart)
				/ shrinkRange

			progress = math.clamp(progress, 0, 1)

			-- Smooth easing
			local smooth =
				progress *
				progress *
				(3 - 2 * progress)

			local circleScale =
				1 -
				(
					(1 - SETTINGS.CircleMinScale)
					* smooth
				)

			local size =
				SETTINGS.CircleSize *
				circleScale

			logoBillboard.Size =
				UDim2.fromOffset(size, size)

		end

		--==================================================
		-- CONTINUOUS RAINBOW BORDER ANIMATION
		-- Each segment gets a smoothly moving HSV hue.
		--==================================================

		buildRainbowBorder()

		if SETTINGS.RainbowBannerEnabled then
			rainbowContainer.Visible = false
			local hueOffset = (time * SETTINGS.RainbowBannerSpeed / 360) % 1
			for i, data in ipairs(rainbowSegments) do
				local hue = ((i - 1) / RAINBOW_SEGMENT_COUNT + hueOffset) % 1
				local color = Color3.fromHSV(hue, 1, 1)
				data.frame.BackgroundColor3 = color
				data.glow.Color = color
			end
		else
			rainbowContainer.Visible = false
		end

		--==================================================
		-- GLOW
		--==================================================

		if SETTINGS.GlowEnabled then

			local glow =
				(math.sin(time * SETTINGS.GlowSpeed) + 1) / 2

			local transparency =
				0.15 +
				glow * SETTINGS.GlowAmount

			panelStroke.Transparency = transparency
			circleStroke.Transparency = transparency
			logoStroke.Transparency = transparency

			orangeFrame.BackgroundColor3 =
				SETTINGS.Orange:Lerp(
					SETTINGS.OrangeBright,
					glow * 0.25
				)

			starGlow.TextTransparency =
				0.55 + glow * 0.25

			logoGlow.TextTransparency =
				0.55 + glow * 0.25

		end

		--==================================================
		-- NAME PULSE
		--==================================================

		if SETTINGS.NamePulseEnabled then

			local pulse =
				(math.sin(time * SETTINGS.NamePulseSpeed) + 1) / 2

			nameLabel.TextTransparency =
				pulse * SETTINGS.NamePulseAmount

			nameLabel.TextStrokeTransparency =
				0.1 +
				pulse * SETTINGS.NamePulseAmount

		end

		--==================================================
		-- OWNER RAINBOW NAME
		--==================================================

		if ownerNameGradient then
			if getRole(player) == "OWNER" and SETTINGS.OwnerRainbowNameEnabled then
				ownerNameGradient.Enabled = true
				-- Rotate the rainbow through the letters continuously.
				ownerNameGradient.Rotation = (time * SETTINGS.OwnerRainbowNameSpeed) % 360
			else
				ownerNameGradient.Enabled = false
			end
		end

		--==================================================
		-- STAR ROTATION
		--==================================================

		if SETTINGS.StarEnabled and not logoFxOn("Rotation") then
			local rotation = (time * SETTINGS.StarRotateSpeed) % 360
			star.Rotation = rotation
			starGlow.Rotation = rotation
			logoStar.Rotation = rotation
			logoGlow.Rotation = rotation
		end

		--==================================================
		-- CATLOGO ROTATION
		--==================================================

		-- Logo rotation is controlled only by the logo effect system.
		if logoFxOn("Rotation") then
			local r = (time * SETTINGS.LogoRotationSpeed * logoFxSpeed) % 360
			logoVisual.Rotation = r
			distantLogoVisual.Rotation = r
		else
			logoVisual.Rotation = 0
			distantLogoVisual.Rotation = 0
		end

		--==================================================
		-- OWNER EFFECT
		--==================================================

		if SETTINGS.OwnerPulseEnabled and getRole(player) == "OWNER" then
			local pulse = (math.sin(time * SETTINGS.OwnerPulseSpeed) + 1) * 0.5
			local scale = 1 + (pulse * SETTINGS.OwnerPulseAmount)

			ownerRing.Size = UDim2.new(
				scale, -2,
				scale, -2
			)
			ownerRing.Position = UDim2.new(
				0.5, -(scale * starCircle.AbsoluteSize.X - 2) / 2,
				0.5, -(scale * starCircle.AbsoluteSize.Y - 2) / 2
			)

			ownerRingStroke.Transparency = 0.05 + (pulse * 0.35)
			ownerRingDistantStroke.Transparency = 0.05 + (pulse * 0.35)
		end

		if SETTINGS.OwnerRingEnabled and getRole(player) == "OWNER" then
			local ownerRotation = (time * SETTINGS.OwnerRingRotateSpeed) % 360
			ownerRing.Rotation = ownerRotation
			ownerRingDistant.Rotation = ownerRotation
		end

		--==================================================
		-- FLOATING
		--==================================================

		if SETTINGS.FloatingEnabled then

			local float =
				math.sin(time * SETTINGS.FloatSpeed)
				* SETTINGS.FloatAmount

			billboard.StudsOffset =
				Vector3.new(
					0,
					SETTINGS.HeightOffset + float,
					0
				)

			logoBillboard.StudsOffset =
				Vector3.new(
					0,
					SETTINGS.HeightOffset + float,
					0
				)

		end


		--==================================================
		-- BANNER OVERLAY ANIMATION
		--==================================================

		if overlayFolder and overlayFolder.Parent then
			if overlayConfig.Enabled ~= false and overlayType ~= "ChromeSweep" then
				overlayFolder.Visible = true
				overlayTime += math.min(deltaTime, 0.1) * overlaySpeed
				local ot = overlayTime

				for i, f in ipairs(movingObjects) do
					if overlayType == "Prism" then
						local speed = 0.16 + i * 0.018
						f.Position = UDim2.new(-0.45 + ((ot * speed) % 1.55), 0, 0, 0)
					elseif overlayType == "SpeedLines" then
						local speed = 0.28 + i * 0.035
						f.Position = UDim2.new(-0.35 + ((ot * speed) % 1.45), 0, 0, 0)
					elseif overlayType == "Scanline" then
						f.Position = UDim2.fromScale(0, -0.08 + ((ot * 0.45) % 1.16))
					elseif overlayType == "Glitch" or overlayType == "Static" then
						f.Visible = math.random() > (overlayType == "Glitch" and 0.25 or 0.08)
					else
						local progress = -0.30 + ((ot * 0.30) % 1.55)
						f.Position = UDim2.new(progress, 0, 0, 0)
					end
				end

				for i, f in ipairs(twinkleObjects) do
					f.BackgroundTransparency = 0.08 + math.abs(math.sin(ot * 2.2 + i * 1.7)) * 0.48
				end

				for _, obj in ipairs(overlayObjects) do
					local g = obj:FindFirstChildOfClass("UIGradient")
					if g then
						if overlayType == "RainbowFlow" or overlayType == "RainbowPulse"
							or overlayType == "NeonRainbow" or overlayType == "Holographic"
							or overlayType == "Iridescent" or overlayType == "Aurora"
							or overlayType == "MetallicFlow" or overlayType == "ColorShift"
							or overlayType == "Sunset" or overlayType == "Ocean"
							or overlayType == "Fire" or overlayType == "Ice" or overlayType == "Electric"
							or overlayType == "Lava" or overlayType == "Toxic" or overlayType == "ShadowFlame"
							or overlayType == "Cyber" or overlayType == "Galaxy" or overlayType == "Cosmic"
							or overlayType == "Void" then
							g.Offset = Vector2.new(((ot * 0.12) % 1.2) - 0.1, 0)
						else
							g.Offset = Vector2.new(0, 0)
						end
					end
				end

				if overlayType == "RainbowPulse" then
					overlayFolder.BackgroundTransparency = 0.90 - math.abs(math.sin(ot * 2)) * 0.08
				end
			else
				overlayFolder.Visible = false
			end
		end

		--==================================================
		-- LOGO EFFECT ANIMATION
		--==================================================

		logoFxTime += (1/60) * logoFxSpeed
		local lt = logoFxTime

		-- Never alter base logo geometry. UIScale keeps the center fixed.
		local logoScale = 1
		if logoFxOn("Pulse") then
			logoScale *= 1 + math.sin(lt*2) * (SETTINGS.LogoPulseAmount or 0.035)
		end
		if logoFxOn("BreathingEffect") then
			logoScale *= 1 + math.sin(lt*1.15) * 0.018
		end
		logoVisualScale.Scale = logoScale
		distantLogoVisualScale.Scale = logoScale

		if logoFxOn("Floating") then
			local fy = math.sin(lt*1.3) * (SETTINGS.LogoFloatingAmount or 2)
			logoVisual.Position = UDim2.new(0.5,0,0.5,fy)
			distantLogoVisual.Position = UDim2.new(0.5,0,0.5,fy)
		else
			logoVisual.Position = UDim2.fromScale(0.5,0.5)
			distantLogoVisual.Position = UDim2.fromScale(0.5,0.5)
		end

		if logoFxOn("Tilt") and not logoFxOn("Rotation") then
			local tilt = math.sin(lt*1.5) * (SETTINGS.LogoTiltAmount or 4)
			logoVisual.Rotation = tilt
			distantLogoVisual.Rotation = tilt
		end

		if logoFxOn("BrightnessPulse") and customLogo then
			customLogo.ImageTransparency = 0.05 + ((math.sin(lt*2)+1)*0.075)
		end
		if logoFxOn("BreathingEffect") and customLogo then
			customLogo.ImageTransparency = 0.04 + ((math.sin(lt*1.15)+1)*0.045)
		end

		if logoFxOn("ColorCycling") and customLogo then
			local h = (lt*0.055)%1
			customLogo.ImageColor3 = Color3.fromHSV(0.07+h*0.12,0.22,1)
			if customLogoDistant then
				customLogoDistant.ImageColor3 = customLogo.ImageColor3
			end
		elseif customLogo then
			customLogo.ImageColor3 = Color3.new(1,1,1)
			if customLogoDistant then customLogoDistant.ImageColor3 = Color3.new(1,1,1) end
		end

		if fxGlow then
			local s=fxGlow:FindFirstChildOfClass("UIStroke")
			if s then
				s.Transparency = logoFxOn("GlowPulse") and (0.15+((math.sin(lt*2)+1)*0.3)) or 0.35
			end
		end

		if fxRing and (logoFxOn("RingRotation") or logoFxOn("CounterRotation")) then
			fxRing.Rotation = (-lt*45) % 360
		end

		if fxSweep then
			fxSweep.Position = UDim2.fromScale(-0.3+((lt*0.4)%1.6),-0.15)
		end
		if fxScan then
			fxScan.Position = UDim2.fromScale(0,-0.1+((lt*0.55)%1.2))
		end
		if fxHalo and logoFxOn("EnergyAura") then
			local aura=1+(math.sin(lt*2)+1)*0.08
			fxHalo.Size=UDim2.new(1,aura*10,1,aura*10)
			fxHalo.Position=UDim2.new(0,-aura*5,0,-aura*5)
		end

		if fxRipple then
			local p=(lt%2.4)/2.4
			local d=4+p*65
			fxRipple.Size=UDim2.fromOffset(d,d)
			fxRipple.Position=UDim2.new(0.5,-d/2,0.5,-d/2)
			local s=fxRipple:FindFirstChildOfClass("UIStroke")
			if s then s.Transparency=p end
		end
		if fxShock then
			local p=((lt+1.2)%3)/3
			local d=4+p*80
			fxShock.Size=UDim2.fromOffset(d,d)
			fxShock.Position=UDim2.new(0.5,-d/2,0.5,-d/2)
			local s=fxShock:FindFirstChildOfClass("UIStroke")
			if s then s.Transparency=p end
		end

		for i,p in ipairs(orbit) do
			local a=lt*1.5+(i/#orbit)*math.pi*2
			local r=0.53
			p.Position=UDim2.new(0.5+math.cos(a)*r,-1.5,0.5+math.sin(a)*r,-1.5)
		end

		sparkleClock += 1/60
		if #sparkles>0 and sparkleClock>0.35 then
			sparkleClock=0
			for _,s in ipairs(sparkles) do s.BackgroundTransparency=1 end
			local pick=sparkles[math.random(1,#sparkles)]
			pick.BackgroundTransparency=0.1
		end

		burstClock += 1/60
		if #bursts>0 and burstClock>2.2 then
			burstClock=0
			for i,p in ipairs(bursts) do
				local a=(i/#bursts)*math.pi*2
				p:SetAttribute("BX",math.cos(a)*0.22)
				p:SetAttribute("BY",math.sin(a)*0.22)
				p:SetAttribute("BT",lt)
				p.BackgroundTransparency=0.1
			end
		end
		for _,p in ipairs(bursts) do
			local st=p:GetAttribute("BT")
			if st then
				local q=math.clamp((lt-st)/0.7,0,1)
				p.Position=UDim2.new(0.5+(p:GetAttribute("BX") or 0)*q,-1.5,0.5+(p:GetAttribute("BY") or 0)*q,-1.5)
				p.BackgroundTransparency=q
			end
		end

		for i,tr in ipairs(trail) do
			tr.ImageTransparency=0.82+i*0.04
			tr.Rotation=logoVisual.Rotation-i*2
		end

		for i,a in ipairs(arcs) do
			a.Visible=math.sin(lt*14+i*1.9)>0.35
			a.Rotation=i*60+math.sin(lt*8+i)*15
		end

		if logoFxOn("Glitch") and math.random()<0.04 then
			logoVisual.Position=UDim2.new(0.5,math.random(-2,2),0.5,math.random(-2,2))
			distantLogoVisual.Position=logoVisual.Position
		end
	
		--==================================================
		-- MOVING HIGHLIGHT
		--==================================================

		local highlightProgress =
			(time * 0.4) % 1.5

		highlight.Position =
			UDim2.new(
				highlightProgress - 0.4,
				0,
				0,
				7
			)
	end)

end

--==================================================
-- SHARED REGISTRY FUNCTIONS
--==================================================

local function heartbeat()
	local result = registryRequest("POST", "/heartbeat", {
		userId = localPlayer.UserId,
		username = localPlayer.Name,
		displayName = localPlayer.DisplayName
	})

	if not result then
		registryOnline = false
		return false
	end

	local status = tonumber(result.StatusCode) or 0
	registryOnline = status >= 200 and status < 300
	return registryOnline
end

local function refreshActivePlayers()
	local result = registryRequest("GET", "/players")

	if not result then
		ActivePlayers = {
			[localPlayer.UserId] = true
		}
		registryOnline = false
		return false
	end

	local status = tonumber(result.StatusCode) or 0
	if status < 200 or status >= 300 then
		ActivePlayers = {
			[localPlayer.UserId] = true
		}
		registryOnline = false
		return false
	end

	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(result.Body or "")
	end)

	if not ok or type(decoded) ~= "table" or type(decoded.players) ~= "table" then
		ActivePlayers = {
			[localPlayer.UserId] = true
		}
		registryOnline = false
		return false
	end

	local newActive = {}

	for _, entry in ipairs(decoded.players) do
		local userId = tonumber(entry.userId)
		if userId then
			newActive[userId] = true
		end
	end

	-- Always keep the local executor visible.
	newActive[localPlayer.UserId] = true

	ActivePlayers = newActive
	registryOnline = true

	return true
end

local function isActivePlayer(player)
	return player == localPlayer or ActivePlayers[player.UserId] == true
end

-- Configured players always get a tag, even if they have never executed the script.
-- This lets you assign custom banners/roles to specific friends.
local function shouldShowNametag(player)
	return isActivePlayer(player)
		or SETTINGS.PlayerTags[player.UserId] ~= nil
		or SETTINGS.PlayerTags[player.Name] ~= nil
end

local function syncNametags()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character

		if character then
			if shouldShowNametag(player) then
				if not character:FindFirstChild("CustomDayBreakNametag") then
					task.spawn(function()
						createNametag(player, character)
					end)
				end
			else
				removeNametag(character)
			end
		end
	end
end

-- Start the local player in the registry before creating tags.
task.spawn(function()
	-- If no registry is configured, keep the script usable locally.
	if REGISTRY_URL == "" or REGISTRY_URL == "PASTE_YOUR_REGISTRY_URL_HERE" then
		ActivePlayers[localPlayer.UserId] = true
		syncNametags()
		return
	end

	while true do
		heartbeat()
		refreshActivePlayers()
		syncNametags()
		task.wait(REGISTRY_POLL_SECONDS)
	end
end)

--==================================================
-- PLAYER SETUP
--==================================================

local function setupPlayer(player)

	local function setupCharacter(character)

		task.wait(0.5)

		if character and character.Parent then
			if shouldShowNametag(player) then
				createNametag(player, character)
			end
		end
	end

	-- Already spawned
	if player.Character then
		task.spawn(function()
			setupCharacter(player.Character)
		end)
	end

	-- Respawn
	player.CharacterAdded:Connect(setupCharacter)
end

--==================================================
-- EXISTING PLAYERS
--==================================================

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		setupPlayer(player)
	end)
end

--==================================================
-- NEW PLAYERS
--==================================================

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)
end)
