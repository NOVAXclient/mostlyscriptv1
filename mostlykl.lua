--========================================================
-- MOSTLY SCRIPT V1 | PANDA AUTH + JOIN DISCORD
--========================================================

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
if not player then
    warn("[Mostly Auth] LocalPlayer unavailable.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")

local DISCORD_INVITE = "https://discord.gg/GWPrNZ7ZTc"

-- Remove older auth windows
for _, name in ipairs({
    "MostlyAuthUI",
    "PandaAuthWindow",
    "MostlyKeySystem"
}) do
    local oldGui = playerGui:FindFirstChild(name)
    if oldGui then
        oldGui:Destroy()
    end
end

-- Prevent duplicate instances
local sessionToken = tostring(os.clock()) .. "_" ..
    tostring(math.random(100000, 999999))

playerGui:SetAttribute("MostlyAuthSession", sessionToken)

local function isCurrentSession()
    return playerGui:GetAttribute("MostlyAuthSession") == sessionToken
end

--========================================================
-- UI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MostlyAuthUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainWindow"
frame.Size = UDim2.fromOffset(370, 220)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(57, 125, 255)
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

local function makeLabel(name, text, position, size, textSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 247, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = textSize
    label.TextWrapped = true
    label.Parent = frame
    return label
end

local title = makeLabel(
    "Title",
    "MOSTLY SCRIPT V1",
    UDim2.fromOffset(15, 10),
    UDim2.new(1, -30, 0, 32),
    21
)
title.Font = Enum.Font.GothamBold

local subtitle = makeLabel(
    "Subtitle",
    "Enter your key to unlock the script",
    UDim2.fromOffset(15, 43),
    UDim2.new(1, -30, 0, 23),
    12
)
subtitle.TextColor3 = Color3.fromRGB(155, 166, 188)

--========================================================
-- KEY INPUT
--========================================================

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Position = UDim2.fromOffset(18, 76)
keyBox.Size = UDim2.new(1, -36, 0, 40)
keyBox.BackgroundColor3 = Color3.fromRGB(34, 40, 56)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Paste your key here..."
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(145, 155, 175)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.Parent = frame

local keyPadding = Instance.new("UIPadding")
keyPadding.PaddingLeft = UDim.new(0, 10)
keyPadding.PaddingRight = UDim.new(0, 10)
keyPadding.Parent = keyBox

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 8)
keyCorner.Parent = keyBox

--========================================================
-- BUTTONS
--========================================================

local function makeButton(name, text, position, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = position
    button.Size = UDim2.new(0.5, -24, 0, 36)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = true
    button.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    return button
end

local BLUE = Color3.fromRGB(57, 125, 255)
local GREEN = Color3.fromRGB(65, 220, 145)
local RED = Color3.fromRGB(255, 90, 100)
local MUTED = Color3.fromRGB(165, 175, 195)

local checkButton = makeButton(
    "CheckKey",
    "CHECK KEY",
    UDim2.fromOffset(18, 124),
    BLUE
)

local joinButton = makeButton(
    "JoinDiscord",
    "JOIN DC",
    UDim2.new(0.5, 6, 0, 124),
    Color3.fromRGB(88, 101, 242)
)

local status = makeLabel(
    "Status",
    "Connecting to Panda Auth...",
    UDim2.fromOffset(15, 165),
    UDim2.new(1, -30, 0, 40),
    11
)
status.TextColor3 = MUTED

local function setStatus(message, color)
    if not gui.Parent or not isCurrentSession() then
        return
    end

    status.Text = message
    status.TextColor3 = color or MUTED
end

--========================================================
-- JOIN DISCORD
--========================================================

joinButton.Activated:Connect(function()
    if not isCurrentSession() then
        return
    end

    -- Try an executor-provided URL opener first.
    local opened = false

    if type(openurl) == "function" then
        opened = pcall(function()
            openurl(DISCORD_INVITE)
        end)
    end

    -- Try Roblox's browser API if the runtime allows it.
    if not opened then
        opened = pcall(function()
            GuiService:OpenBrowserWindow(DISCORD_INVITE)
        end)
    end

    if opened then
        setStatus("Opening Discord invite...", GREEN)
        return
    end

    -- Clipboard fallback.
    if type(setclipboard) == "function" then
        local copied = pcall(function()
            setclipboard(DISCORD_INVITE)
        end)

        if copied then
            setStatus("Invite copied! Paste it into Discord.", GREEN)
            return
        end
    end

    print("[Mostly] Discord invite:", DISCORD_INVITE)
    setStatus("Invite: discord.gg/GWPrNZ7ZTc", MUTED)
end)

--========================================================
-- LOAD PANDA AUTH
--========================================================

local PUSL
local authReady = false
local authorized = false
local checking = false

task.spawn(function()
    local loaded, library = pcall(function()
        return loadstring(
            game:HttpGet("https://secure.pandauth.com/pv4/lib")
        )()
    end)

    if not isCurrentSession() then
        return
    end

    if not loaded or type(library) ~= "table" then
        setStatus("Could not load Panda Auth. Check console.", RED)
        warn("[Panda Auth] Library load failed:", library)
        return
    end

    if type(library.configure) ~= "function"
        or type(library.validate) ~= "function" then
        setStatus("Panda Auth functions are unavailable.", RED)
        warn("[Panda Auth] Required functions are missing.")
        return
    end

    local configured, configError = pcall(function()
        library.configure({
            serviceId = "mostlyscript"
        })
    end)

    if not isCurrentSession() then
        return
    end

    if not configured then
        setStatus("Panda Auth configuration failed.", RED)
        warn("[Panda Auth] Configuration error:", configError)
        return
    end

    PUSL = library
    authReady = true

    setStatus("Ready. Enter your key.", GREEN)
    print("[Panda Auth] Ready.")
end)

--========================================================
-- CHECK KEY
--========================================================

local function checkKey()
    if not isCurrentSession() or checking or authorized then
        return
    end

    if not authReady or not PUSL then
        setStatus("Authentication is not ready yet.", MUTED)
        return
    end

    local key = keyBox.Text:match("^%s*(.-)%s*$")

    if key == "" then
        setStatus("Please enter your key first.", RED)
        return
    end

    checking = true
    checkButton.Text = "CHECKING..."
    checkButton.BackgroundColor3 = Color3.fromRGB(43, 91, 180)
    setStatus("Validating key...", MUTED)

    task.spawn(function()
        local ok, result = pcall(function()
            return PUSL.validate(key)
        end)

        if not isCurrentSession() or not gui.Parent then
            return
        end

        if ok and type(result) == "table"
            and result.success == true then

            authorized = true
            setStatus("Key accepted! Loading script...", GREEN)

            task.wait(0.5)

            if isCurrentSession() and gui.Parent then
                gui:Destroy()
            end
        else
            checking = false
            checkButton.Text = "CHECK KEY"
            checkButton.BackgroundColor3 = BLUE

            setStatus("Invalid key or verification failed.", RED)

            if not ok then
                warn("[Panda Auth] Validation error:", result)
            elseif type(result) == "table" then
                warn("[Panda Auth] Validation rejected:", result.error)
            end
        end
    end)
end

checkButton.Activated:Connect(checkKey)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        checkKey()
    end
end)

--========================================================
-- WAIT FOR AUTHENTICATION
--========================================================

while not authorized do
    if not isCurrentSession() then
        return
    end

    task.wait(0.1)
end

--========================================================
-- PASTE YOUR MAIN MOSTLY SCRIPT BELOW THIS LINE
-- Do not add another key system UI.
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
    Background = Color3.fromRGB(12, 15, 23),
    Window = Color3.fromRGB(19, 23, 34),
    Sidebar = Color3.fromRGB(15, 19, 29),
    Card = Color3.fromRGB(27, 32, 46),
    CardHover = Color3.fromRGB(38, 45, 62),
    Stroke = Color3.fromRGB(54, 64, 86),
    Blue = Color3.fromRGB(57, 125, 255),
    BlueLight = Color3.fromRGB(92, 161, 255),
    Text = Color3.fromRGB(244, 247, 255),
    Muted = Color3.fromRGB(151, 162, 184),
    Green = Color3.fromRGB(50, 204, 135),
    Red = Color3.fromRGB(247, 83, 100),
    Gold = Color3.fromRGB(255, 190, 54),
}

--============================================================
-- STATE
--============================================================

local destroyed = false
local panelOpen = true

local farming = false
local farmThreadRunning = false
local activeFarmVehicle
local activeFarmCharacter

-- Money Farm tuning.
local LIFT_HEIGHT = 7
local LIFT_DURATION = 0.12
local ROTATION_DURATION = 0.12
local LAND_DURATION = 0.12
local FARM_PAUSE = 0.12

-- Landing brake tuning.
local BRAKE_DURATION = 0.45
local BRAKE_INTERVAL = 0.03

local autoWheelie = false
local wheelieAngle = 25
local wheelieConnection
local wheelieAttachment
local wheelieTorque
local wheelieRoot
local wheelieSeat

local antiAfkEnabled = false
local antiAfkGeneration = 0
local ANTI_AFK_INTERVAL = 17 * 60

local antiCrashEnabled = false
local antiCrashSeat
local antiCrashConnection
local antiCrashPending = false

local speedChangerEnabled = false
local speedTargetKmh = 120
local speedConnection
local speedTrackedVehicle
local originalSeatSettings = {}

local SPEED_MIN = 1
local SPEED_MAX = 1000
local STUDS_PER_SECOND_PER_KMH = 1 / 1.008
local SPEED_ACCELERATION = 120

local stabilizerEnabled = false
local stabilizerConnection
local stabilizerTorque
local stabilizerAttachment
local stabilizerRoot
local stabilizerVehicle
local stabilizerSeat

local rainbowEnabled = false
local rainbowRunning = false
local goldGlowEnabled = false
local glowHighlight
local glowLight

local savedAppearance = {}

local wheelieDragging = false
local speedDragging = false
local windowDragging = false
local windowDragStart
local windowStartPosition
local windowDragInput

local refreshStatus
local refreshStabilizer

-- Keep connections so cleanup can disconnect them.
local connections = {}

local function trackConnection(connection)
    table.insert(connections, connection)
    return connection
end

--============================================================
-- REMOVE OLDER GUI
--============================================================

local oldGui = playerGui:FindFirstChild("MostlyScriptV1")
if oldGui then
    oldGui:Destroy()
end

--============================================================
-- HELPERS
--============================================================

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function outline(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function makeGradient(obj, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(color1, color2)
    g.Rotation = rotation or 0
    g.Parent = obj
    return g
end

local function makeLabel(parent, name, text, pos, size, fontSize, color, font)
    local obj = Instance.new("TextLabel")
    obj.Name = name
    obj.Position = pos
    obj.Size = size
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = color or C.Text
    obj.TextSize = fontSize or 13
    obj.Font = font or Enum.Font.Gotham
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.TextYAlignment = Enum.TextYAlignment.Center
    obj.TextWrapped = true
    obj.Parent = parent
    return obj
end

local function makeButton(parent, name, text, pos, size, color)
    local obj = Instance.new("TextButton")
    obj.Name = name
    obj.Position = pos
    obj.Size = size
    obj.BackgroundColor3 = color or C.Card
    obj.BorderSizePixel = 0
    obj.Text = text
    obj.TextColor3 = C.Text
    obj.TextSize = 12
    obj.Font = Enum.Font.GothamBold
    obj.AutoButtonColor = false
    obj.Parent = parent

    corner(obj, 9)
    outline(obj, C.Stroke, 1, 0.15)

    return obj
end

local function makeCard(parent, name, pos, size)
    local obj = Instance.new("Frame")
    obj.Name = name
    obj.Position = pos
    obj.Size = size
    obj.BackgroundColor3 = C.Card
    obj.BorderSizePixel = 0
    obj.Parent = parent

    corner(obj, 13)
    outline(obj, C.Stroke, 1, 0.2)

    return obj
end

local function setToggle(btn, enabled, text)
    btn.Text = text or (enabled and "ON" or "OFF")
    btn.BackgroundColor3 = enabled and C.Green or C.CardHover
end

local function setWarning(btn, text)
    btn.Text = text
    btn.BackgroundColor3 = C.Red
end

local function safeDestroy(obj)
    if obj then
        pcall(function()
            obj:Destroy()
        end)
    end
end

local function safeDisconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function tween(obj, duration, properties)
    if not obj or not obj.Parent then
        return
    end

    local animation = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.18,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    animation:Play()
    return animation
end

--============================================================
-- GUI ROOT
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MostlyScriptV1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 50
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.fromOffset(750, 500)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.BackgroundColor3 = C.Window
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

corner(main, 18)
outline(main, C.Stroke, 1.2, 0)

local mainScale = Instance.new("UIScale")
mainScale.Name = "ResponsiveScale"
mainScale.Scale = 1
mainScale.Parent = main

local shadow = Instance.new("Frame")
shadow.Name = "WindowShadow"
shadow.Size = UDim2.fromOffset(766, 516)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.fromScale(0.5, 0.5)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.55
shadow.BorderSizePixel = 0
shadow.Parent = gui
shadow.ZIndex = 0

corner(shadow, 20)

local shadowScale = Instance.new("UIScale")
shadowScale.Scale = 1
shadowScale.Parent = shadow

main.ZIndex = 1

local function updateResponsiveScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local widthScale = (viewport.X - 24) / 750
    local heightScale = (viewport.Y - 24) / 516
    local scaleValue = math.clamp(
        math.min(widthScale, heightScale, 1),
        0.55,
        1
    )

    mainScale.Scale = scaleValue
    shadowScale.Scale = scaleValue
end

updateResponsiveScale()

if workspace.CurrentCamera then
    trackConnection(
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize")
            :Connect(updateResponsiveScale)
    )
end

--============================================================
-- SIDEBAR
--============================================================

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = C.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main

corner(sidebar, 18)
makeGradient(sidebar, Color3.fromRGB(22, 28, 44), C.Sidebar, 90)

local brandIcon = Instance.new("Frame")
brandIcon.Position = UDim2.fromOffset(17, 23)
brandIcon.Size = UDim2.fromOffset(38, 38)
brandIcon.BackgroundColor3 = C.Blue
brandIcon.BorderSizePixel = 0
brandIcon.Parent = sidebar

corner(brandIcon, 11)
makeGradient(brandIcon, C.BlueLight, C.Blue, 45)

local brandMark = makeLabel(
    brandIcon, "BrandMark", "M",
    UDim2.fromScale(0, 0), UDim2.fromScale(1, 1),
    20, C.Text, Enum.Font.GothamBlack
)
brandMark.TextXAlignment = Enum.TextXAlignment.Center

makeLabel(
    sidebar, "BrandTitle", "MOSTLY",
    UDim2.fromOffset(63, 20), UDim2.fromOffset(85, 23),
    15, C.Text, Enum.Font.GothamBlack
)

makeLabel(
    sidebar, "BrandSubtitle", "SCRIPT / V1",
    UDim2.fromOffset(63, 44), UDim2.fromOffset(85, 17),
    9, C.Muted, Enum.Font.GothamBold
)

makeLabel(
    sidebar, "NavCaption", "WORKSPACE",
    UDim2.fromOffset(17, 88), UDim2.fromOffset(120, 18),
    9, C.Muted, Enum.Font.GothamBold
)

local moneyTab = makeButton(
    sidebar, "MoneyTab", "  ◈    MONEY",
    UDim2.fromOffset(10, 115), UDim2.new(1, -20, 0, 42), C.Blue
)
moneyTab.TextXAlignment = Enum.TextXAlignment.Left

local scooterTab = makeButton(
    sidebar, "ScooterTab", "  ✦    SCOOTER",
    UDim2.fromOffset(10, 164), UDim2.new(1, -20, 0, 42), C.Sidebar
)
scooterTab.TextXAlignment = Enum.TextXAlignment.Left

local miscTab = makeButton(
    sidebar, "MiscTab", "  ⚙    MISC",
    UDim2.fromOffset(10, 213), UDim2.new(1, -20, 0, 42), C.Sidebar
)
miscTab.TextXAlignment = Enum.TextXAlignment.Left

local panicButton = makeButton(
    sidebar, "PanicButton", "  ⏻    PANIC STOP",
    UDim2.fromOffset(10, 270), UDim2.new(1, -20, 0, 39), C.Red
)
panicButton.TextXAlignment = Enum.TextXAlignment.Left

makeLabel(
    sidebar, "KeyboardHint", "RIGHT SHIFT  ·  HIDE",
    UDim2.new(0, 15, 1, -48), UDim2.new(1, -25, 0, 18),
    8, C.Muted, Enum.Font.GothamBold
)

--============================================================
-- HEADER / STATUS
--============================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Position = UDim2.fromOffset(160, 0)
header.Size = UDim2.new(1, -160, 0, 82)
header.BackgroundTransparency = 1
header.Active = true
header.Parent = main

local pageTitle = makeLabel(
    header, "PageTitle", "Money Center",
    UDim2.fromOffset(23, 15), UDim2.new(1, -155, 0, 30),
    22, C.Text, Enum.Font.GothamBold
)

local pageSubtitle = makeLabel(
    header, "PageSubtitle", "Vehicle controls and utilities",
    UDim2.fromOffset(24, 47), UDim2.new(1, -165, 0, 19),
    10, C.Muted
)

local statusPill = Instance.new("Frame")
statusPill.Name = "StatusPill"
statusPill.AnchorPoint = Vector2.new(1, 0)
statusPill.Position = UDim2.new(1, -18, 0, 23)
statusPill.Size = UDim2.fromOffset(100, 30)
statusPill.BackgroundColor3 = C.Card
statusPill.BorderSizePixel = 0
statusPill.Parent = header

corner(statusPill, 15)
outline(statusPill, C.Stroke, 1, 0.2)

local statusDot = Instance.new("Frame")
statusDot.Position = UDim2.fromOffset(9, 11)
statusDot.Size = UDim2.fromOffset(8, 8)
statusDot.BackgroundColor3 = C.Muted
statusDot.BorderSizePixel = 0
statusDot.Parent = statusPill

corner(statusDot, 4)

local statusText = makeLabel(
    statusPill, "StatusText", "STANDBY",
    UDim2.fromOffset(22, 0), UDim2.new(1, -26, 1, 0),
    9, C.Muted, Enum.Font.GothamBold
)
statusText.TextWrapped = false

--============================================================
-- PAGES
--============================================================

local pageArea = Instance.new("Frame")
pageArea.Name = "PageArea"
pageArea.Position = UDim2.fromOffset(175, 85)
pageArea.Size = UDim2.new(1, -193, 1, -100)
pageArea.BackgroundTransparency = 1
pageArea.ClipsDescendants = true
pageArea.Parent = main

local moneyPage = Instance.new("Frame")
moneyPage.Name = "MoneyPage"
moneyPage.Size = UDim2.fromScale(1, 1)
moneyPage.BackgroundTransparency = 1
moneyPage.Parent = pageArea

local function makeHiddenScrollPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollBarThickness = 0
    page.ScrollBarImageTransparency = 1
    page.ScrollBarImageColor3 = C.Window
    page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    page.Visible = false
    page.Parent = pageArea
    return page
end

local scooterPage = makeHiddenScrollPage("ScooterPage")
local miscPage = makeHiddenScrollPage("MiscPage")

local openButton = makeButton(
    gui, "ReopenButton", "✦   OPEN MOSTLY",
    UDim2.new(0, 14, 0.5, -20), UDim2.fromOffset(155, 40), C.Blue
)
openButton.Visible = false
makeGradient(openButton, C.BlueLight, C.Blue, 0)

--============================================================
-- MONEY PAGE
--============================================================

local farmCard = makeCard(
    moneyPage, "FarmCard",
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 108)
)

makeLabel(
    farmCard, "FarmTitle", "MONEY FARM",
    UDim2.fromOffset(16, 13), UDim2.new(1, -145, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    farmCard, "FarmDescription", "5 backflips + 5 full spins",
    UDim2.fromOffset(16, 40), UDim2.new(1, -145, 0, 20),
    10, C.Muted
)

makeLabel(
    farmCard, "FarmSubtext", "FAST MODE · 0.12s ROTATIONS",
    UDim2.fromOffset(16, 69), UDim2.new(1, -145, 0, 16),
    9, C.BlueLight, Enum.Font.GothamBold
)

local farmButton = makeButton(
    farmCard, "FarmButton", "START FARM",
    UDim2.new(1, -132, 0.5, -20), UDim2.fromOffset(116, 40), C.Blue
)

local wheelieCard = makeCard(
    moneyPage, "WheelieCard",
    UDim2.fromOffset(0, 118), UDim2.new(1, 0, 0, 132)
)

makeLabel(
    wheelieCard, "WheelieTitle", "AUTO WHEELIE",
    UDim2.fromOffset(15, 9), UDim2.new(1, -120, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    wheelieCard, "WheelieDescription", "Hold a wheelie angle while steering",
    UDim2.fromOffset(15, 34), UDim2.new(1, -25, 0, 18),
    10, C.Muted
)

local wheelieButton = makeButton(
    wheelieCard, "WheelieButton", "OFF",
    UDim2.new(1, -90, 0, 9), UDim2.fromOffset(74, 30), C.CardHover
)

local wheelieLabel = makeLabel(
    wheelieCard, "WheelieAngleLabel", "ANGLE   25°",
    UDim2.fromOffset(15, 61), UDim2.new(1, -25, 0, 18),
    10, C.Muted, Enum.Font.GothamBold
)

local wheelieSlider = Instance.new("Frame")
wheelieSlider.Name = "WheelieSlider"
wheelieSlider.Position = UDim2.fromOffset(17, 94)
wheelieSlider.Size = UDim2.new(1, -34, 0, 8)
wheelieSlider.BackgroundColor3 = C.Stroke
wheelieSlider.BorderSizePixel = 0
wheelieSlider.Active = true
wheelieSlider.Parent = wheelieCard

corner(wheelieSlider, 4)

local wheelieFill = Instance.new("Frame")
wheelieFill.Size = UDim2.new((wheelieAngle - 5) / 75, 0, 1, 0)
wheelieFill.BackgroundColor3 = C.Blue
wheelieFill.BorderSizePixel = 0
wheelieFill.Parent = wheelieSlider

corner(wheelieFill, 4)

local wheelieKnob = Instance.new("TextButton")
wheelieKnob.Name = "WheelieKnob"
wheelieKnob.Size = UDim2.fromOffset(16, 16)
wheelieKnob.AnchorPoint = Vector2.new(0.5, 0.5)
wheelieKnob.Position = UDim2.new((wheelieAngle - 5) / 75, 0, 0.5, 0)
wheelieKnob.BackgroundColor3 = C.Text
wheelieKnob.BorderSizePixel = 0
wheelieKnob.Text = ""
wheelieKnob.Parent = wheelieSlider

corner(wheelieKnob, 8)
outline(wheelieKnob, C.Blue, 2, 0)

local antiAfkCard = makeCard(
    moneyPage, "AntiAfkCard",
    UDim2.fromOffset(0, 260), UDim2.new(1, 0, 0, 76)
)

makeLabel(
    antiAfkCard, "AntiAfkTitle", "ANTI AFK",
    UDim2.fromOffset(15, 8), UDim2.new(1, -105, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    antiAfkCard, "AntiAfkDescription", "Attempts movement every 17 minutes",
    UDim2.fromOffset(15, 34), UDim2.new(1, -105, 0, 28),
    9, C.Muted
)

local antiAfkButton = makeButton(
    antiAfkCard, "AntiAfkButton", "OFF",
    UDim2.new(1, -87, 0.5, -17), UDim2.fromOffset(72, 34), C.CardHover
)

--============================================================
-- SCOOTER PAGE
--============================================================

local rainbowCard = makeCard(
    scooterPage, "RainbowCard",
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 75)
)

makeLabel(
    rainbowCard, "RainbowTitle", "RAINBOW FINISH",
    UDim2.fromOffset(15, 11), UDim2.new(1, -110, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    rainbowCard, "RainbowDescription", "Animated color cycling",
    UDim2.fromOffset(15, 37), UDim2.new(1, -110, 0, 18),
    10, C.Muted
)

local rainbowButton = makeButton(
    rainbowCard, "RainbowButton", "ENABLE",
    UDim2.new(1, -95, 0.5, -18), UDim2.fromOffset(80, 36), C.CardHover
)

local glowCard = makeCard(
    scooterPage, "GlowCard",
    UDim2.fromOffset(0, 84), UDim2.new(1, 0, 0, 75)
)

makeLabel(
    glowCard, "GlowTitle", "GOLD GLOW",
    UDim2.fromOffset(15, 11), UDim2.new(1, -110, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    glowCard, "GlowDescription", "Gold outline and point light",
    UDim2.fromOffset(15, 37), UDim2.new(1, -110, 0, 18),
    10, C.Muted
)

local glowButton = makeButton(
    glowCard, "GoldGlowButton", "ENABLE",
    UDim2.new(1, -95, 0.5, -18), UDim2.fromOffset(80, 36), C.CardHover
)

local restoreCard = makeCard(
    scooterPage, "RestoreCard",
    UDim2.fromOffset(0, 168), UDim2.new(1, 0, 0, 61)
)

makeLabel(
    restoreCard, "RestoreTitle", "RESTORE APPEARANCE",
    UDim2.fromOffset(15, 6), UDim2.new(1, -110, 0, 22),
    11, C.Text, Enum.Font.GothamBold
)

makeLabel(
    restoreCard, "RestoreDescription", "Return saved colors",
    UDim2.fromOffset(15, 29), UDim2.new(1, -110, 0, 18),
    9, C.Muted
)

local restoreButton = makeButton(
    restoreCard, "RestoreButton", "RESTORE",
    UDim2.new(1, -95, 0.5, -17), UDim2.fromOffset(80, 34), C.Blue
)

local paletteCard = makeCard(
    scooterPage, "PaletteCard",
    UDim2.fromOffset(0, 238), UDim2.new(1, 0, 0, 330)
)

makeLabel(
    paletteCard, "PaletteTitle", "CUSTOM COLOR PALETTE",
    UDim2.fromOffset(14, 8), UDim2.new(1, -28, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

local paletteStatus = makeLabel(
    paletteCard, "PaletteStatus", "Sit on scooter, then select a color",
    UDim2.fromOffset(14, 30), UDim2.new(1, -28, 0, 18),
    9, C.Muted
)

local paletteSwatches = {}

local paletteStyles = {
    {1.00, 1.00},
    {0.78, 1.00},
    {0.55, 1.00},
    {0.32, 1.00},
    {1.00, 0.76},
    {0.78, 0.54},
    {0.72, 0.34},
}

for row = 1, 8 do
    for col = 1, 12 do
        local color

        if row == 8 then
            local v = (col - 1) / 11
            color = Color3.new(v, v, v)
        else
            local style = paletteStyles[row]
            color = Color3.fromHSV((col - 1) / 12, style[1], style[2])
        end

        local swatch = Instance.new("TextButton")
        swatch.Name = string.format("Palette_%02d_%02d", row, col)
        swatch.Position = UDim2.fromOffset(
            14 + (col - 1) * 40,
            55 + (row - 1) * 30
        )
        swatch.Size = UDim2.fromOffset(34, 25)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.Text = ""
        swatch.AutoButtonColor = false
        swatch.Parent = paletteCard

        corner(swatch, 5)

        local swatchStroke = outline(swatch, C.Stroke, 1, 0.08)

        local hex = string.format(
            "#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )

        table.insert(paletteSwatches, {
            Button = swatch,
            Color = color,
            Stroke = swatchStroke,
            Hex = hex,
        })
    end
end

makeLabel(
    scooterPage, "ScooterNote",
    "Textured surfaces may not support plain color tinting.",
    UDim2.fromOffset(2, 574), UDim2.new(1, -4, 0, 30),
    9, C.Muted
)

--============================================================
-- MISC PAGE
--============================================================

local antiCrashCard = makeCard(
    miscPage, "AntiCrashCard",
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 120)
)

makeLabel(
    antiCrashCard, "AntiCrashTitle", "ANTI CRASH",
    UDim2.fromOffset(15, 10), UDim2.new(1, -110, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    antiCrashCard, "AntiCrashDescription",
    "Attempts to re-seat you after an unexpected ejection",
    UDim2.fromOffset(15, 37), UDim2.new(1, -25, 0, 31),
    10, C.Muted
)

local antiCrashButton = makeButton(
    antiCrashCard, "AntiCrashButton", "OFF",
    UDim2.new(1, -87, 0, 8), UDim2.fromOffset(72, 32), C.CardHover
)

local antiCrashStatus = makeLabel(
    antiCrashCard, "AntiCrashStatus", "Status: disabled",
    UDim2.fromOffset(15, 82), UDim2.new(1, -25, 0, 22),
    9, C.Muted, Enum.Font.GothamBold
)

local speedCard = makeCard(
    miscPage, "SpeedCard",
    UDim2.fromOffset(0, 132), UDim2.new(1, 0, 0, 150)
)

makeLabel(
    speedCard, "SpeedTitle", "SCOOTER SPEED CHANGER",
    UDim2.fromOffset(15, 8), UDim2.new(1, -110, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

local speedButton = makeButton(
    speedCard, "SpeedChangerButton", "OFF",
    UDim2.new(1, -87, 0, 8), UDim2.fromOffset(72, 32), C.CardHover
)

local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Position = UDim2.fromOffset(15, 39)
speedInput.Size = UDim2.fromOffset(92, 30)
speedInput.BackgroundColor3 = C.CardHover
speedInput.BorderSizePixel = 0
speedInput.Text = tostring(speedTargetKmh)
speedInput.PlaceholderText = "1–1000"
speedInput.PlaceholderColor3 = C.Muted
speedInput.TextColor3 = C.Text
speedInput.TextSize = 12
speedInput.Font = Enum.Font.GothamBold
speedInput.ClearTextOnFocus = false
speedInput.TextXAlignment = Enum.TextXAlignment.Center
speedInput.Parent = speedCard

corner(speedInput, 8)
outline(speedInput, C.Stroke, 1, 0.15)

local speedApplyButton = makeButton(
    speedCard, "SpeedApplyButton", "SET",
    UDim2.fromOffset(115, 39), UDim2.fromOffset(62, 30), C.Blue
)

local speedReadout = makeLabel(
    speedCard, "SpeedReadout", "120 KM/H",
    UDim2.fromOffset(187, 39), UDim2.new(1, -200, 0, 30),
    12, C.BlueLight, Enum.Font.GothamBold
)
speedReadout.TextWrapped = false

local speedSliderBack = Instance.new("Frame")
speedSliderBack.Name = "SpeedSlider"
speedSliderBack.Position = UDim2.fromOffset(17, 83)
speedSliderBack.Size = UDim2.new(1, -34, 0, 8)
speedSliderBack.BackgroundColor3 = C.Stroke
speedSliderBack.BorderSizePixel = 0
speedSliderBack.Active = true
speedSliderBack.Parent = speedCard

corner(speedSliderBack, 4)

local speedSliderFill = Instance.new("Frame")
speedSliderFill.Size = UDim2.new((speedTargetKmh - 1) / 999, 0, 1, 0)
speedSliderFill.BackgroundColor3 = C.Blue
speedSliderFill.BorderSizePixel = 0
speedSliderFill.Parent = speedSliderBack

corner(speedSliderFill, 4)

local speedSliderKnob = Instance.new("TextButton")
speedSliderKnob.Name = "SpeedSliderKnob"
speedSliderKnob.Size = UDim2.fromOffset(16, 16)
speedSliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
speedSliderKnob.Position = UDim2.new((speedTargetKmh - 1) / 999, 0, 0.5, 0)
speedSliderKnob.BackgroundColor3 = C.Text
speedSliderKnob.Text = ""
speedSliderKnob.BorderSizePixel = 0
speedSliderKnob.Parent = speedSliderBack

corner(speedSliderKnob, 8)
outline(speedSliderKnob, C.Blue, 2, 0)

local speedStatus = makeLabel(
    speedCard, "SpeedStatus", "Disabled · choose 1–1000 km/h",
    UDim2.fromOffset(15, 105), UDim2.new(1, -25, 0, 20),
    9, C.Muted
)

local stabilizerCard = makeCard(
    miscPage, "StabilizerCard",
    UDim2.fromOffset(0, 292), UDim2.new(1, 0, 0, 115)
)

makeLabel(
    stabilizerCard, "StabilizerTitle", "STABILIZE",
    UDim2.fromOffset(15, 9), UDim2.new(1, -110, 0, 22),
    12, C.Text, Enum.Font.GothamBold
)

makeLabel(
    stabilizerCard, "StabilizerDescription",
    "Reduce tilt and wobble. Requires Speed Changer ON.",
    UDim2.fromOffset(15, 36), UDim2.new(1, -25, 0, 30),
    10, C.Muted
)

local stabilizerButton = makeButton(
    stabilizerCard, "StabilizerButton", "OFF",
    UDim2.new(1, -87, 0, 8), UDim2.fromOffset(72, 32), C.CardHover
)

local stabilizerStatus = makeLabel(
    stabilizerCard, "StabilizerStatus",
    "Disabled · requires Speed Changer ON",
    UDim2.fromOffset(15, 78), UDim2.new(1, -25, 0, 22),
    9, C.Muted
)

makeLabel(
    miscPage, "MiscNote",
    "Client-side physics changes can be overridden by the game's own vehicle controller.",
    UDim2.fromOffset(2, 420), UDim2.new(1, -4, 0, 34),
    9, C.Muted
)

--============================================================
-- VEHICLE DETECTION / COLOR TARGET
--============================================================

local function getVehicle()
    local character = player.Character
    if not character then return nil, nil, nil end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil, nil, nil end

    local seat = humanoid.SeatPart
    if not seat then return nil, nil, nil end

    local model = seat:FindFirstAncestorOfClass("Model")
    if not model then return nil, nil, nil end

    return model, seat, model.PrimaryPart or seat
end

local function getPaintVehicle()
    local vehicle, seat = getVehicle()
    if not vehicle or not seat then return nil end

    local model = vehicle

    while model.Parent and model.Parent:IsA("Model") do
        local parentModel = model.Parent
        local otherSeatFound = false

        for _, item in ipairs(parentModel:GetDescendants()) do
            if (item:IsA("Seat") or item:IsA("VehicleSeat"))
                and item ~= seat
                and not item:IsDescendantOf(model) then

                otherSeatFound = true
                break
            end
        end

        if otherSeatFound then break end
        model = parentModel
    end

    return model
end

--============================================================
-- STATUS + TAB SWITCHING
--============================================================

refreshStatus = function()
    if destroyed then return end

    local name = "STANDBY"
    local color = C.Muted

    if farming then
        name, color = "FARMING", C.Green
    elseif autoWheelie then
        name, color = "WHEELIE", C.BlueLight
    elseif speedChangerEnabled then
        name, color = "SPEED", C.BlueLight
    elseif stabilizerEnabled then
        name, color = "STABILIZE", C.Green
    elseif antiCrashEnabled then
        name, color = "ANTI CRASH", C.Gold
    elseif antiAfkEnabled then
        name, color = "ANTI AFK", C.Gold
    end

    statusText.Text = name
    statusText.TextColor3 = color
    statusDot.BackgroundColor3 = color
end

local function showTab(name)
    local money = name == "MONEY"
    local scooter = name == "SCOOTER"
    local misc = name == "MISC"

    moneyPage.Visible = money
    scooterPage.Visible = scooter
    miscPage.Visible = misc

    if money then
        pageTitle.Text = "Money Center"
        pageSubtitle.Text = "Farm · wheelie · anti AFK"
    elseif scooter then
        pageTitle.Text = "Scooter Studio"
        pageSubtitle.Text = "Color palette · appearance"
    else
        pageTitle.Text = "Miscellaneous"
        pageSubtitle.Text = "Speed · stabilize · anti crash"
    end

    local function styleTab(btn, selected)
        btn.BackgroundColor3 = selected and C.Blue or C.Sidebar
        btn.TextColor3 = selected and C.Text or C.Muted

        local s = btn:FindFirstChildOfClass("UIStroke")
        if s then
            s.Color = selected and C.BlueLight or C.Stroke
            s.Transparency = selected and 0.1 or 0.65
        end
    end

    styleTab(moneyTab, money)
    styleTab(scooterTab, scooter)
    styleTab(miscTab, misc)
end

trackConnection(moneyTab.Activated:Connect(function()
    if not destroyed then showTab("MONEY") end
end))

trackConnection(scooterTab.Activated:Connect(function()
    if not destroyed then showTab("SCOOTER") end
end))

trackConnection(miscTab.Activated:Connect(function()
    if not destroyed then showTab("MISC") end
end))

--============================================================
-- COLOR PALETTE: SAVE / RESTORE / APPLY
--============================================================

local function saveAppearance(instance)
    if savedAppearance[instance] then return end

    if instance:IsA("BasePart") then
        savedAppearance[instance] = {
            Kind = "Part",
            Color = instance.Color,
            Material = instance.Material,
            MaterialVariant = instance.MaterialVariant,
            Reflectance = instance.Reflectance,
        }
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        savedAppearance[instance] = {
            Kind = "Texture",
            Color3 = instance.Color3,
        }
    end
end

local function restoreOriginalColors()
    rainbowEnabled = false
    setToggle(rainbowButton, false, "ENABLE")

    for instance, data in pairs(savedAppearance) do
        if instance and instance.Parent then
            pcall(function()
                if data.Kind == "Part" and instance:IsA("BasePart") then
                    instance.Color = data.Color
                    instance.Material = data.Material
                    instance.MaterialVariant = data.MaterialVariant
                    instance.Reflectance = data.Reflectance
                elseif data.Kind == "Texture"
                    and (instance:IsA("Decal") or instance:IsA("Texture")) then
                    instance.Color3 = data.Color3
                end
            end)
        end
    end

    table.clear(savedAppearance)

    paletteStatus.Text = "Original appearance restored"
    paletteStatus.TextColor3 = C.Muted

    for _, swatch in ipairs(paletteSwatches) do
        swatch.Stroke.Color = C.Stroke
        swatch.Stroke.Thickness = 1
    end
end

local function applyScooterColor(color, hex)
    if destroyed then return end

    local vehicle = getPaintVehicle()
    if not vehicle then
        paletteStatus.Text = "Sit on your scooter first"
        paletteStatus.TextColor3 = C.Red
        return
    end

    rainbowEnabled = false
    setToggle(rainbowButton, false, "ENABLE")

    local painted = 0
    local failed = 0

    local function paint(obj)
        if obj:IsA("BasePart") then
            saveAppearance(obj)

            local ok = pcall(function()
                obj.Color = color
            end)

            if ok then painted += 1 else failed += 1 end

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            saveAppearance(obj)

            local ok = pcall(function()
                obj.Color3 = color
            end)

            if ok then painted += 1 else failed += 1 end
        end
    end

    if vehicle:IsA("BasePart") then
        paint(vehicle)
    end

    for _, obj in ipairs(vehicle:GetDescendants()) do
        paint(obj)
    end

    for _, swatch in ipairs(paletteSwatches) do
        local selected = swatch.Hex == hex
        swatch.Stroke.Color = selected and C.Text or C.Stroke
        swatch.Stroke.Thickness = selected and 2 or 1
    end

    if painted > 0 then
        paletteStatus.Text = string.format(
            "Applied %s to %d parts/textures",
            hex,
            painted
        )

        paletteStatus.TextColor3 = failed > 0 and C.Gold or C.Green
    else
        paletteStatus.Text = "No paintable parts found"
        paletteStatus.TextColor3 = C.Red
    end
end

--============================================================
-- RAINBOW / GOLD GLOW
--============================================================

local function startRainbowLoop()
    if rainbowRunning then return end
    rainbowRunning = true

    task.spawn(function()
        local hue = 0

        while rainbowEnabled and not destroyed do
            local vehicle = getPaintVehicle()

            if vehicle and vehicle.Parent then
                hue = (hue + 0.035) % 1
                local index = 0

                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        saveAppearance(part)
                        index += 1

                        pcall(function()
                            part.Color = Color3.fromHSV(
                                (hue + index * 0.035) % 1,
                                0.9,
                                1
                            )
                        end)
                    end
                end
            end

            task.wait(0.07)
        end

        rainbowRunning = false
    end)
end

local function removeGoldGlow()
    goldGlowEnabled = false
    safeDestroy(glowHighlight)
    safeDestroy(glowLight)
    glowHighlight = nil
    glowLight = nil
    setToggle(glowButton, false, "ENABLE")
end

local function enableGoldGlow()
    local vehicle, _, root = getVehicle()

    if not vehicle or not root then
        setWarning(glowButton, "SIT FIRST")
        return
    end

    removeGoldGlow()
    goldGlowEnabled = true

    glowHighlight = Instance.new("Highlight")
    glowHighlight.Name = "MostlyGoldHighlight"
    glowHighlight.Adornee = getPaintVehicle() or vehicle
    glowHighlight.FillColor = C.Gold
    glowHighlight.OutlineColor = Color3.fromRGB(255, 233, 160)
    glowHighlight.FillTransparency = 0.58
    glowHighlight.OutlineTransparency = 0.05
    glowHighlight.Parent = gui

    glowLight = Instance.new("PointLight")
    glowLight.Name = "MostlyGoldLight"
    glowLight.Color = C.Gold
    glowLight.Brightness = 1.5
    glowLight.Range = 15
    glowLight.Parent = root

    setToggle(glowButton, true)
end

--============================================================
-- WHEELIE
--============================================================

local function stopWheelie()
    autoWheelie = false

    safeDisconnect(wheelieConnection)
    wheelieConnection = nil

    safeDestroy(wheelieTorque)
    safeDestroy(wheelieAttachment)

    wheelieTorque = nil
    wheelieAttachment = nil
    wheelieRoot = nil
    wheelieSeat = nil

    setToggle(wheelieButton, false)

    if refreshStabilizer then refreshStabilizer() end
    refreshStatus()
end

local function startWheelie()
    local vehicle, seat, root = getVehicle()

    if not vehicle or not seat or not root or not root:IsA("BasePart") then
        setWarning(wheelieButton, "SIT FIRST")

        task.delay(1.3, function()
            if not destroyed and not autoWheelie then
                setToggle(wheelieButton, false)
            end
        end)

        return
    end

    stopWheelie()

    autoWheelie = true
    wheelieRoot = root
    wheelieSeat = seat

    wheelieAttachment = Instance.new("Attachment")
    wheelieAttachment.Name = "MostlyWheelieAttachment"
    wheelieAttachment.CFrame = root.CFrame:ToObjectSpace(seat.CFrame)
    wheelieAttachment.Parent = root

    wheelieTorque = Instance.new("Torque")
    wheelieTorque.Name = "MostlyWheelieTorque"
    wheelieTorque.Attachment0 = wheelieAttachment
    wheelieTorque.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    wheelieTorque.Parent = root

    setToggle(wheelieButton, true)
    refreshStatus()

    wheelieConnection = RunService.Heartbeat:Connect(function()
        if destroyed or not autoWheelie then return end

        local _, currentSeat, currentRoot = getVehicle()

        if currentSeat ~= wheelieSeat
            or currentRoot ~= wheelieRoot
            or not wheelieTorque then

            stopWheelie()
            return
        end

        local look = wheelieSeat.CFrame.LookVector
        local pitch = math.asin(math.clamp(look.Y, -1, 1))
        local errorAngle = math.rad(wheelieAngle) - pitch

        local pitchAxis = wheelieSeat.CFrame.RightVector
        local angularSpeed =
            wheelieRoot.AssemblyAngularVelocity:Dot(pitchAxis)

        local speed = wheelieRoot.AssemblyLinearVelocity.Magnitude
        local speedFactor = math.clamp(speed / 100, 0, 1.5)

        local mass = math.max(wheelieRoot.AssemblyMass, 1)
        local bounds = Vector3.new(3, 2, 5)

        local ok, measured = pcall(function()
            local model = currentSeat:FindFirstAncestorOfClass("Model")
            return model and model:GetExtentsSize()
        end)

        if ok and measured then
            bounds = measured
        end

        local inertia = math.max(
            mass * (bounds.Y * bounds.Y + bounds.Z * bounds.Z) / 12,
            mass * 0.2
        )

        local torque = inertia * (
            (90 + 35 * speedFactor) * errorAngle
            - (18 + 8 * speedFactor) * angularSpeed
        )

        local maximum = inertia * (180 + 60 * speedFactor)
        torque = math.clamp(torque, -maximum, maximum)

        wheelieTorque.Torque = Vector3.new(torque, 0, 0)
    end)

    if refreshStabilizer then refreshStabilizer() end
end

--============================================================
-- SPEED CHANGER
--============================================================

local function updateSpeedControls()
    speedTargetKmh = math.clamp(
        math.floor(speedTargetKmh + 0.5),
        SPEED_MIN,
        SPEED_MAX
    )

    local alpha = (speedTargetKmh - SPEED_MIN) / (SPEED_MAX - SPEED_MIN)

    speedInput.Text = tostring(speedTargetKmh)
    speedReadout.Text = string.format("%d KM/H", speedTargetKmh)
    speedSliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    speedSliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
end

local function setSpeedTarget()
    local value = tonumber(speedInput.Text)

    if not value or value ~= value then
        speedStatus.Text = "Enter a number from 1 to 1000"
        speedStatus.TextColor3 = C.Red
        speedInput.Text = tostring(speedTargetKmh)
        return
    end

    speedTargetKmh = math.clamp(
        math.floor(value + 0.5),
        SPEED_MIN,
        SPEED_MAX
    )

    updateSpeedControls()

    speedStatus.Text = speedChangerEnabled
        and string.format("Active · target %d km/h", speedTargetKmh)
        or string.format("Disabled · target %d km/h", speedTargetKmh)

    speedStatus.TextColor3 = speedChangerEnabled and C.Green or C.Muted
end

local function restoreSpeedSettings()
    for seat, data in pairs(originalSeatSettings) do
        if seat and seat.Parent and seat:IsA("VehicleSeat") then
            pcall(function()
                seat.MaxSpeed = data.MaxSpeed
                seat.Torque = data.Torque
            end)
        end
    end

    table.clear(originalSeatSettings)
    speedTrackedVehicle = nil
end

local function applySeatSpeed(vehicle)
    local targetStuds = speedTargetKmh * STUDS_PER_SECOND_PER_KMH

    for _, obj in ipairs(vehicle:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            if not originalSeatSettings[obj] then
                originalSeatSettings[obj] = {
                    MaxSpeed = obj.MaxSpeed,
                    Torque = obj.Torque,
                }
            end

            local original = originalSeatSettings[obj]

            pcall(function()
                obj.MaxSpeed = targetStuds
                obj.Torque = math.max(
                    original.Torque,
                    math.min(targetStuds * 10, 15000)
                )
            end)
        end
    end
end

local function stopSpeedChanger()
    speedChangerEnabled = false

    safeDisconnect(speedConnection)
    speedConnection = nil

    restoreSpeedSettings()
    setToggle(speedButton, false)

    speedStatus.Text = string.format(
        "Disabled · target %d km/h",
        speedTargetKmh
    )

    speedStatus.TextColor3 = C.Muted

    if refreshStabilizer then refreshStabilizer() end
    refreshStatus()
end

local function startSpeedChanger()
    speedChangerEnabled = true
    setToggle(speedButton, true)

    speedStatus.Text = "Enabled · sit on scooter to apply"
    speedStatus.TextColor3 = C.Gold
    refreshStatus()

    if refreshStabilizer then refreshStabilizer() end

    speedConnection = RunService.Heartbeat:Connect(function(dt)
        if destroyed or not speedChangerEnabled then return end

        local vehicle, seat, root = getVehicle()

        if not vehicle or not seat or not root then
            speedStatus.Text = "Enabled · sit on scooter to apply"
            speedStatus.TextColor3 = C.Gold

            if speedTrackedVehicle then
                restoreSpeedSettings()
            end

            return
        end

        if speedTrackedVehicle ~= vehicle then
            restoreSpeedSettings()
            speedTrackedVehicle = vehicle
            applySeatSpeed(vehicle)
        else
            applySeatSpeed(vehicle)
        end

        speedStatus.Text = string.format(
            "Active · target %d km/h",
            speedTargetKmh
        )

        speedStatus.TextColor3 = C.Green

        local assembly = root.AssemblyRootPart or root

        if not assembly or not assembly.Parent then
            return
        end

        local look = seat.CFrame.LookVector
        local forward = Vector3.new(look.X, 0, look.Z)

        if forward.Magnitude < 0.001 then return end

        forward = forward.Unit

        local velocity = assembly.AssemblyLinearVelocity
        local forwardSpeed = velocity:Dot(forward)
        local throttle = 0

        if seat:IsA("VehicleSeat") then
            throttle = seat.ThrottleFloat
        elseif UIS:IsKeyDown(Enum.KeyCode.W)
            or UIS:IsKeyDown(Enum.KeyCode.Up) then

            throttle = 1
        elseif UIS:IsKeyDown(Enum.KeyCode.S)
            or UIS:IsKeyDown(Enum.KeyCode.Down) then

            throttle = -1
        end

        local targetStuds = speedTargetKmh * STUDS_PER_SECOND_PER_KMH
        local change = 0

        if throttle > 0.05 then
            local nextSpeed = math.min(
                targetStuds,
                forwardSpeed + SPEED_ACCELERATION * math.max(dt, 0)
            )

            change = nextSpeed - forwardSpeed

        elseif math.abs(throttle) < 0.05 and forwardSpeed > targetStuds then
            local nextSpeed = math.max(
                targetStuds,
                forwardSpeed - SPEED_ACCELERATION * math.max(dt, 0)
            )

            change = nextSpeed - forwardSpeed
        end

        if math.abs(change) > 0.001 then
            pcall(function()
                assembly.AssemblyLinearVelocity = velocity + forward * change
            end)
        end
    end)
end

--============================================================
-- STABILIZE
--============================================================

local function clearStabilizer()
    safeDestroy(stabilizerTorque)
    safeDestroy(stabilizerAttachment)

    stabilizerTorque = nil
    stabilizerAttachment = nil
    stabilizerRoot = nil
    stabilizerVehicle = nil
    stabilizerSeat = nil
end

local function stopStabilizerLoop()
    safeDisconnect(stabilizerConnection)
    stabilizerConnection = nil

    clearStabilizer()
end

refreshStabilizer = function()
    if destroyed or not stabilizerEnabled or not speedChangerEnabled then
        stopStabilizerLoop()

        if stabilizerEnabled and not speedChangerEnabled then
            stabilizerStatus.Text = "ON · waiting for Speed Changer"
            stabilizerStatus.TextColor3 = C.Gold
        elseif not stabilizerEnabled then
            stabilizerStatus.Text = "Disabled · requires Speed Changer ON"
            stabilizerStatus.TextColor3 = C.Muted
        end

        return
    end

    stabilizerStatus.Text = "ON · stabilizing when seated"
    stabilizerStatus.TextColor3 = C.Green

    if stabilizerConnection then return end

    stabilizerConnection = RunService.Heartbeat:Connect(function()
        if destroyed or not stabilizerEnabled or not speedChangerEnabled then
            stopStabilizerLoop()
            return
        end

        local vehicle, seat, root = getVehicle()

        if not vehicle or not seat or not root then
            clearStabilizer()
            stabilizerStatus.Text = "ON · sit on scooter to stabilize"
            stabilizerStatus.TextColor3 = C.Gold
            return
        end

        local assembly = root.AssemblyRootPart or root

        if not assembly or not assembly.Parent then
            clearStabilizer()
            return
        end

        if stabilizerRoot ~= assembly
            or stabilizerVehicle ~= vehicle
            or stabilizerSeat ~= seat
            or not stabilizerTorque
            or not stabilizerTorque.Parent then

            clearStabilizer()

            stabilizerRoot = assembly
            stabilizerVehicle = vehicle
            stabilizerSeat = seat

            stabilizerAttachment = Instance.new("Attachment")
            stabilizerAttachment.Name = "MostlyStabilizerAttachment"
            stabilizerAttachment.Parent = assembly

            stabilizerTorque = Instance.new("Torque")
            stabilizerTorque.Name = "MostlyStabilizerTorque"
            stabilizerTorque.Attachment0 = stabilizerAttachment
            stabilizerTorque.RelativeTo = Enum.ActuatorRelativeTo.World
            stabilizerTorque.Parent = assembly
        end

        local up = assembly.CFrame.UpVector
        local worldUp = Vector3.yAxis
        local omega = assembly.AssemblyAngularVelocity
        local bounds = Vector3.new(3, 2, 5)

        local ok, measured = pcall(function()
            return vehicle:GetExtentsSize()
        end)

        if ok and measured then
            bounds = measured
        end

        local mass = math.max(assembly.AssemblyMass, 1)

        local inertia = math.max(
            mass * (bounds.X * bounds.X + bounds.Z * bounds.Z) / 12,
            mass * 0.2
        )

        local speedFactor = math.clamp(
            assembly.AssemblyLinearVelocity.Magnitude / 100,
            0,
            1.5
        )

        local kp = 24 + 10 * speedFactor
        local kd = 8 + 3 * speedFactor
        local torqueWorld

        if autoWheelie then
            local forward = seat.CFrame.LookVector
            local flatForward = Vector3.new(forward.X, 0, forward.Z)

            if flatForward.Magnitude > 0.001 then
                flatForward = flatForward.Unit

                local right = assembly.CFrame.RightVector
                local rollAngle = math.asin(math.clamp(right.Y, -1, 1))
                local rollRate = omega:Dot(flatForward)

                torqueWorld = flatForward * inertia
                    * (kp * rollAngle - kd * rollRate)
            else
                torqueWorld = Vector3.zero
            end
        else
            local cross = up:Cross(worldUp)
            local axis = cross.Magnitude > 0.001 and cross.Unit or Vector3.zero
            local angle = math.acos(math.clamp(up:Dot(worldUp), -1, 1))
            local tiltError = axis * angle
            local noYawOmega = omega - worldUp * omega:Dot(worldUp)

            torqueWorld = inertia * (kp * tiltError - kd * noYawOmega)
        end

        torqueWorld = Vector3.new(torqueWorld.X, 0, torqueWorld.Z)

        local maximum = inertia * (110 + 45 * speedFactor)

        if torqueWorld.Magnitude > maximum then
            torqueWorld = torqueWorld.Unit * maximum
        end

        stabilizerTorque.Torque = torqueWorld

        stabilizerStatus.Text = "Active · stabilizing"
        stabilizerStatus.TextColor3 = C.Green
    end)
end

--============================================================
-- ANTI CRASH
--============================================================

local function validSeat(seat)
    return seat
        and seat.Parent
        and (seat:IsA("Seat") or seat:IsA("VehicleSeat"))
        and seat:FindFirstAncestorOfClass("Model") ~= nil
end

local function bindAntiCrashCharacter(character)
    safeDisconnect(antiCrashConnection)
    antiCrashConnection = nil

    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then return end

    if validSeat(humanoid.SeatPart) then
        antiCrashSeat = humanoid.SeatPart
    end

    antiCrashConnection = humanoid.Seated:Connect(function(isSeated, seat)
        if isSeated then
            if validSeat(seat) then
                antiCrashSeat = seat
                antiCrashStatus.Text = "Status: scooter seat tracked"
                antiCrashStatus.TextColor3 = C.Green
            end

            return
        end

        if not antiCrashEnabled or antiCrashPending then
            return
        end

        local savedCharacter = character
        local savedHumanoid = humanoid
        local savedSeat = antiCrashSeat

        if not validSeat(savedSeat) then
            return
        end

        antiCrashPending = true

        antiCrashStatus.Text = "Status: attempting re-seat..."
        antiCrashStatus.TextColor3 = C.Gold

        task.spawn(function()
            local deadline = os.clock() + 4

            while os.clock() < deadline
                and antiCrashEnabled
                and not destroyed
                and player.Character == savedCharacter
                and savedCharacter.Parent
                and savedHumanoid.Health > 0
                and not savedHumanoid.SeatPart do

                if not validSeat(savedSeat) then break end

                local root = savedCharacter:FindFirstChild("HumanoidRootPart")

                if not root
                    or (root.Position - savedSeat.Position).Magnitude > 40 then
                    break
                end

                if not savedSeat.Occupant
                    or savedSeat.Occupant == savedHumanoid then

                    pcall(function()
                        savedSeat:Sit(savedHumanoid)
                    end)
                end

                task.wait(0.2)
            end

            if antiCrashEnabled
                and savedHumanoid.Parent
                and not savedHumanoid.SeatPart then

                antiCrashStatus.Text = "Status: re-seat failed"
                antiCrashStatus.TextColor3 = C.Red
            end

            antiCrashPending = false
        end)
    end)
end

local function startAntiCrash()
    antiCrashEnabled = true

    setToggle(antiCrashButton, true)
    bindAntiCrashCharacter(player.Character)

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid and validSeat(humanoid.SeatPart) then
        antiCrashSeat = humanoid.SeatPart
        antiCrashStatus.Text = "Status: armed · seat tracked"
        antiCrashStatus.TextColor3 = C.Green
    else
        antiCrashStatus.Text = "Status: sit on scooter to track seat"
        antiCrashStatus.TextColor3 = C.Gold
    end

    refreshStatus()
end

local function stopAntiCrash()
    antiCrashEnabled = false
    antiCrashPending = false

    safeDisconnect(antiCrashConnection)
    antiCrashConnection = nil

    setToggle(antiCrashButton, false)

    antiCrashStatus.Text = "Status: disabled"
    antiCrashStatus.TextColor3 = C.Muted

    refreshStatus()
end

--============================================================
-- ANTI AFK
--============================================================

local function startAntiAfk()
    antiAfkEnabled = true
    antiAfkGeneration += 1

    local generation = antiAfkGeneration

    setToggle(antiAfkButton, true)
    refreshStatus()

    task.spawn(function()
        while not destroyed
            and antiAfkEnabled
            and generation == antiAfkGeneration do

            task.wait(ANTI_AFK_INTERVAL)

            if destroyed
                or not antiAfkEnabled
                or generation ~= antiAfkGeneration then

                break
            end

            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 and not humanoid.SeatPart then
                pcall(function()
                    humanoid:Move(Vector3.new(0, 0, -1), true)
                end)

                task.wait(0.15)

                if humanoid.Parent then
                    pcall(function()
                        humanoid:Move(Vector3.zero, true)
                    end)
                end
            else
                warn("Mostly Anti AFK: a genuine keyboard input isn't guaranteed.")
            end
        end
    end)
end

local function stopAntiAfk()
    antiAfkEnabled = false
    antiAfkGeneration += 1

    setToggle(antiAfkButton, false)
    refreshStatus()
end

--============================================================
-- MONEY FARM: TRANSFORM, LAND AND BRAKE
--============================================================

local function pivotVehicleAndDriver(vehicle, targetPivot)
    if not vehicle or not vehicle.Parent then
        return false
    end

    local character = activeFarmCharacter

    if not character or not character.Parent then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local seat = humanoid and humanoid.SeatPart

    if not seat or not seat:IsDescendantOf(vehicle) then
        return false
    end

    local oldPivot = vehicle:GetPivot()
    local delta = targetPivot * oldPivot:Inverse()
    local characterPivot = character:GetPivot()

    local success = pcall(function()
        vehicle:PivotTo(targetPivot)
        character:PivotTo(delta * characterPivot)
    end)

    return success
end

local function brakeVehicle(vehicle, duration)
    if not vehicle or not vehicle.Parent then
        return
    end

    duration = duration or BRAKE_DURATION

    -- Each independent assembly has its own velocity. Collect them
    -- once and damp both linear and rotational movement for a short time.
    local assemblies = {}

    local function rememberAssembly(part)
        if not part:IsA("BasePart") or part.Anchored then
            return
        end

        local assembly = part.AssemblyRootPart or part
        if assembly and assembly.Parent and not assembly.Anchored then
            assemblies[assembly] = true
        end
    end

    rememberAssembly(vehicle)

    for _, object in ipairs(vehicle:GetDescendants()) do
        rememberAssembly(object)
    end

    local started = os.clock()

    while not destroyed
        and vehicle.Parent
        and os.clock() - started < duration do

        -- If the scooter has been removed or assemblies have changed,
        -- stop trying to brake objects that no longer exist.
        for assembly in pairs(assemblies) do
            if assembly and assembly.Parent and not assembly.Anchored then
                pcall(function()
                    assembly.AssemblyLinearVelocity = Vector3.zero
                    assembly.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end

        task.wait(BRAKE_INTERVAL)
    end
end

local function animateVehicle(vehicle, startPivot, targetPivot, duration)
    if duration <= 0 then
        return pivotVehicleAndDriver(vehicle, targetPivot)
    end

    local started = os.clock()

    while farming and not destroyed do
        if not vehicle or not vehicle.Parent then
            return false
        end

        local alpha = math.clamp(
            (os.clock() - started) / duration,
            0,
            1
        )

        -- Smoothstep makes the lift and landing less abrupt.
        local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
        local target = startPivot:Lerp(targetPivot, smoothAlpha)

        if not pivotVehicleAndDriver(vehicle, target) then
            return false
        end

        if alpha >= 1 then
            return true
        end

        RunService.Heartbeat:Wait()
    end

    return false
end

local function rotateVehicle(vehicle, axis)
    if not vehicle or not vehicle.Parent then
        return false
    end

    local startPivot = vehicle:GetPivot()
    local started = os.clock()

    while farming and not destroyed do
        if not vehicle.Parent then
            return false
        end

        local alpha = math.clamp(
            (os.clock() - started) / math.max(ROTATION_DURATION, 0.01),
            0,
            1
        )

        local rotation

        if axis == "X" then
            -- One full flip.
            rotation = CFrame.Angles(math.pi * 2 * alpha, 0, 0)
        else
            -- One full spin.
            rotation = CFrame.Angles(0, math.pi * 2 * alpha, 0)
        end

        if not pivotVehicleAndDriver(vehicle, startPivot * rotation) then
            return false
        end

        if alpha >= 1 then
            return true
        end

        RunService.Heartbeat:Wait()
    end

    return false
end

local function performFarmCycle(vehicle)
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    local seat = humanoid and humanoid.SeatPart

    if not vehicle
        or not vehicle.Parent
        or not character
        or not seat
        or not seat:IsDescendantOf(vehicle) then

        return false
    end

    activeFarmVehicle = vehicle
    activeFarmCharacter = character

    local originalPivot = vehicle:GetPivot()
    local liftedPivot = originalPivot + Vector3.new(0, LIFT_HEIGHT, 0)
    local landed = false

    local success, result = pcall(function()
        -- Lift.
        if not animateVehicle(
            vehicle,
            originalPivot,
            liftedPivot,
            LIFT_DURATION
        ) then
            return false
        end

        -- Five flips.
        for _ = 1, 5 do
            if not rotateVehicle(vehicle, "X") then
                return false
            end
        end

        -- Five spins.
        for _ = 1, 5 do
            if not rotateVehicle(vehicle, "Y") then
                return false
            end
        end

        if not farming or destroyed then
            return false
        end

        -- Return to the original position before applying the brake.
        if not animateVehicle(
            vehicle,
            vehicle:GetPivot(),
            originalPivot,
            LAND_DURATION
        ) then
            return false
        end

        landed = true
        return true
    end)

    -- Always try to put the scooter back where it started.
    -- Even when the farm is stopped, don't leave it raised if the
    -- character is still seated in the same vehicle.
    if vehicle and vehicle.Parent then
        pcall(function()
            local currentCharacter = activeFarmCharacter
            local currentHumanoid = currentCharacter
                and currentCharacter:FindFirstChildOfClass("Humanoid")

            local currentSeat = currentHumanoid
                and currentHumanoid.SeatPart

            local riderStillInVehicle = currentCharacter
                and currentCharacter.Parent
                and currentSeat
                and currentSeat:IsDescendantOf(vehicle)

            if riderStillInVehicle then
                pivotVehicleAndDriver(vehicle, originalPivot)
            end
        end)

        -- NEW: braking is applied after attempting the landing restore.
        -- It prevents leftover translation and spin from carrying the
        -- scooter away immediately after the farm cycle.
        if landed or (vehicle and vehicle.Parent) then
            brakeVehicle(vehicle, BRAKE_DURATION)
        end
    end

    activeFarmVehicle = nil
    activeFarmCharacter = nil

    if not success then
        warn("[Mostly Farm] " .. tostring(result))
        return false
    end

    return result == true
end

local function setFarmOff()
    farming = false

    farmButton.Text = "START FARM"
    farmButton.BackgroundColor3 = C.Blue

    refreshStatus()
end

local function startFarmLoop()
    if farmThreadRunning then
        return
    end

    farmThreadRunning = true

    task.spawn(function()
        while farming and not destroyed do
            local vehicle = getVehicle()

            if not vehicle then
                setFarmOff()
                break
            end

            local success = performFarmCycle(vehicle)

            -- Stop cleanly on errors or when the rider leaves the seat.
            if not success then
                if farming and not destroyed then
                    setFarmOff()
                end

                break
            end

            if farming and not destroyed then
                task.wait(FARM_PAUSE)
            end
        end

        activeFarmVehicle = nil
        activeFarmCharacter = nil
        farmThreadRunning = false

        if not destroyed then
            farmButton.Text = "START FARM"
            farmButton.BackgroundColor3 = C.Blue
            refreshStatus()
        end
    end)
end

--============================================================
-- BUTTON EVENTS
--============================================================

trackConnection(farmButton.Activated:Connect(function()
    if destroyed then return end

    if farming then
        setFarmOff()
        return
    end

    if not getVehicle() then
        setWarning(farmButton, "SIT ON SCOOTER")

        task.delay(1.4, function()
            if not destroyed and not farming then
                farmButton.Text = "START FARM"
                farmButton.BackgroundColor3 = C.Blue
            end
        end)

        return
    end

    farming = true

    if autoWheelie then
        stopWheelie()
    end

    farmButton.Text = "STOP FARM"
    farmButton.BackgroundColor3 = C.Red

    refreshStatus()
    startFarmLoop()
end))

trackConnection(wheelieButton.Activated:Connect(function()
    if destroyed then return end

    if autoWheelie then
        stopWheelie()
    else
        startWheelie()
    end
end))

trackConnection(antiAfkButton.Activated:Connect(function()
    if destroyed then return end

    if antiAfkEnabled then
        stopAntiAfk()
    else
        startAntiAfk()
    end
end))

trackConnection(antiCrashButton.Activated:Connect(function()
    if destroyed then return end

    if antiCrashEnabled then
        stopAntiCrash()
    else
        startAntiCrash()
    end
end))

trackConnection(speedButton.Activated:Connect(function()
    if destroyed then return end

    if speedChangerEnabled then
        stopSpeedChanger()
    else
        startSpeedChanger()
    end
end))

trackConnection(stabilizerButton.Activated:Connect(function()
    if destroyed then return end

    stabilizerEnabled = not stabilizerEnabled
    setToggle(stabilizerButton, stabilizerEnabled)

    if refreshStabilizer then
        refreshStabilizer()
    end

    refreshStatus()
end))

trackConnection(speedApplyButton.Activated:Connect(function()
    if not destroyed then
        setSpeedTarget()
    end
end))

trackConnection(speedInput.FocusLost:Connect(function(enterPressed)
    if not destroyed then
        setSpeedTarget()
    end
end))

trackConnection(rainbowButton.Activated:Connect(function()
    if destroyed then return end

    if rainbowEnabled then
        rainbowEnabled = false
        restoreOriginalColors()
        return
    end

    if not getPaintVehicle() then
        setWarning(rainbowButton, "SIT FIRST")
        return
    end

    rainbowEnabled = true
    setToggle(rainbowButton, true, "ON")
    startRainbowLoop()
end))

trackConnection(glowButton.Activated:Connect(function()
    if destroyed then return end

    if goldGlowEnabled then
        removeGoldGlow()
    else
        enableGoldGlow()
    end
end))

trackConnection(restoreButton.Activated:Connect(function()
    if not destroyed then
        restoreOriginalColors()
    end
end))

for _, swatch in ipairs(paletteSwatches) do
    trackConnection(swatch.Button.Activated:Connect(function()
        applyScooterColor(swatch.Color, swatch.Hex)
    end))
end

--============================================================
-- SLIDER INPUT
--============================================================

local function updateWheelieSlider(x)
    local left = wheelieSlider.AbsolutePosition.X
    local width = wheelieSlider.AbsoluteSize.X

    if width <= 0 then return end

    local alpha = math.clamp((x - left) / width, 0, 1)

    wheelieAngle = math.floor(5 + alpha * 75 + 0.5)

    wheelieFill.Size = UDim2.new(alpha, 0, 1, 0)
    wheelieKnob.Position = UDim2.new(alpha, 0, 0.5, 0)

    wheelieLabel.Text = string.format("ANGLE   %d°", wheelieAngle)
end

local function updateSpeedSlider(x)
    local left = speedSliderBack.AbsolutePosition.X
    local width = speedSliderBack.AbsoluteSize.X

    if width <= 0 then return end

    local alpha = math.clamp((x - left) / width, 0, 1)

    speedTargetKmh = math.floor(
        SPEED_MIN + alpha * (SPEED_MAX - SPEED_MIN) + 0.5
    )

    updateSpeedControls()
end

trackConnection(wheelieSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        wheelieDragging = true
        updateWheelieSlider(input.Position.X)
    end
end))

trackConnection(wheelieKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        wheelieDragging = true
        updateWheelieSlider(input.Position.X)
    end
end))

trackConnection(speedSliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        speedDragging = true
        updateSpeedSlider(input.Position.X)
    end
end))

trackConnection(speedSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        speedDragging = true
        updateSpeedSlider(input.Position.X)
    end
end))

trackConnection(UIS.InputChanged:Connect(function(input)
    if destroyed then return end

    if wheelieDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateWheelieSlider(input.Position.X)
    end

    if speedDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateSpeedSlider(input.Position.X)
    end
end))

trackConnection(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        wheelieDragging = false
        speedDragging = false
    end
end))

--============================================================
-- HIDE / SHOW
--============================================================

local function hidePanel()
    panelOpen = false
    main.Visible = false
    shadow.Visible = false
    openButton.Visible = true
end

local function showPanel()
    panelOpen = true
    main.Visible = true
    shadow.Visible = true
    openButton.Visible = false
end

trackConnection(openButton.Activated:Connect(function()
    if not destroyed then
        showPanel()
    end
end))

trackConnection(UIS.InputBegan:Connect(function(input, processed)
    if processed or destroyed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        if panelOpen then
            hidePanel()
        else
            showPanel()
        end
    end
end))

--============================================================
-- WINDOW DRAGGING
--============================================================

trackConnection(header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        windowDragging = true
        windowDragStart = input.Position
        windowStartPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                windowDragging = false
            end
        end)
    end
end))

trackConnection(header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        windowDragInput = input
    end
end))

trackConnection(UIS.InputChanged:Connect(function(input)
    if destroyed or not windowDragging then return end

    if input == windowDragInput
        or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - windowDragStart

        main.Position = UDim2.new(
            windowStartPosition.X.Scale,
            windowStartPosition.X.Offset + delta.X,
            windowStartPosition.Y.Scale,
            windowStartPosition.Y.Offset + delta.Y
        )

        shadow.Position = UDim2.new(
            main.Position.X.Scale,
            main.Position.X.Offset,
            main.Position.Y.Scale,
            main.Position.Y.Offset
        )
    end
end))

--============================================================
-- PANIC STOP / CLEANUP
--============================================================

local function cleanup()
    if destroyed then return end

    -- Stop the farm worker first so it doesn't start another cycle.
    farming = false

    if activeFarmVehicle and activeFarmVehicle.Parent then
        -- Cancelled sequences should still attempt a landing brake.
        task.spawn(function()
            if activeFarmVehicle and activeFarmVehicle.Parent then
                brakeVehicle(activeFarmVehicle, BRAKE_DURATION)
            end
        end)
    end

    if wheelieConnection then
        wheelieConnection:Disconnect()
        wheelieConnection = nil
    end

    safeDestroy(wheelieTorque)
    safeDestroy(wheelieAttachment)

    wheelieTorque = nil
    wheelieAttachment = nil
    wheelieRoot = nil
    wheelieSeat = nil
    autoWheelie = false

    antiAfkEnabled = false
    antiAfkGeneration += 1

    antiCrashEnabled = false
    antiCrashPending = false

    safeDisconnect(antiCrashConnection)
    antiCrashConnection = nil

    stabilizerEnabled = false
    stopStabilizerLoop()

    speedChangerEnabled = false
    safeDisconnect(speedConnection)
    speedConnection = nil
    restoreSpeedSettings()

    rainbowEnabled = false
    rainbowRunning = false

    removeGoldGlow()
    restoreOriginalColors()

    destroyed = true

    for _, connection in ipairs(connections) do
        safeDisconnect(connection)
    end

    table.clear(connections)

    if gui.Parent then
        gui:Destroy()
    end
end

trackConnection(panicButton.Activated:Connect(cleanup))

trackConnection(player.CharacterAdded:Connect(function(character)
    -- Don't let a farm loop keep running with a previous character.
    farming = false

    farmButton.Text = "START FARM"
    farmButton.BackgroundColor3 = C.Blue

    activeFarmVehicle = nil
    activeFarmCharacter = nil

    if autoWheelie then
        if wheelieConnection then
            wheelieConnection:Disconnect()
            wheelieConnection = nil
        end

        safeDestroy(wheelieTorque)
        safeDestroy(wheelieAttachment)

        wheelieTorque = nil
        wheelieAttachment = nil
        wheelieRoot = nil
        wheelieSeat = nil
        autoWheelie = false

        setToggle(wheelieButton, false)
    end

    if antiCrashEnabled then
        task.defer(function()
            if not destroyed
                and antiCrashEnabled
                and character == player.Character then

                bindAntiCrashCharacter(character)
                antiCrashStatus.Text = "Status: waiting for scooter"
                antiCrashStatus.TextColor3 = C.Gold
            end
        end)
    end
end))

--============================================================
-- INITIALIZE
--============================================================

updateSpeedControls()
showTab("MONEY")
refreshStatus()

print("[Mostly Script V1] Loaded with Money Farm landing brake.")
