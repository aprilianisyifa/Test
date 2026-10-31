--[[
    gunungkembar.lua
    Fitur:
    1. Fly (Terbang) + Kontrol arah (WASD / Space / Shift)
    2. Speedhack (Lari Cepat)
    3. Noclip (Menembus Dinding/Objek)
    4. Save & Load Lokasi Koordinat (Disimpan di file JSON)
    5. Teleport ke Lokasi Tersimpan & Teleport ke Player
    6. Follow Player (Mengikuti player target secara otomatis)
    7. GUI Sederhana, Tab Navigation, Draggable, & Scalable
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- FILE SYSTEM HELPER (JSON Save / Load)
--------------------------------------------------------------------------------
local SAVE_FILE_NAME = "gunungkembar_coords.json"
local SavedCoordinates = {}

local function readFileSafe(filename)
    if isfile and isfile(filename) then
        local success, result = pcall(readfile, filename)
        if success then return result end
    end
    return nil
end

local function writeFileSafe(filename, content)
    if writefile then
        pcall(writefile, filename, content)
    end
end

local function loadCoordinates()
    local raw = readFileSafe(SAVE_FILE_NAME)
    if raw then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if success and type(decoded) == "table" then
            SavedCoordinates = decoded
            return
        end
    end
    SavedCoordinates = {}
end

local function saveCoordinates()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(SavedCoordinates)
    end)
    if success and encoded then
        writeFileSafe(SAVE_FILE_NAME, encoded)
    end
end

loadCoordinates()

--------------------------------------------------------------------------------
-- KONFIGURASI & STATE
--------------------------------------------------------------------------------
local Config = {
    Fly = {
        Enabled = false,
        Speed = 50,
    },
    Speed = {
        Enabled = false,
        Value = 50,
        DefaultWalkSpeed = 16,
    },
    Noclip = {
        Enabled = false,
    },
    Follow = {
        Enabled = false,
        TargetName = "",
        Distance = 4,
    }
}

-- Target GUI Parent
local function getGuiParent()
    local success, parent = pcall(function()
        return CoreGui
    end)
    if success and parent then
        return parent
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local parentGui = getGuiParent()
local existing = parentGui:FindFirstChild("GunungKembarGui")
if existing then
    existing:Destroy()
end

local function getRoot(char)
    char = char or LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function getHumanoid(char)
    char = char or LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------------------------------------
-- SISTEM TERBANG (FLY)
--------------------------------------------------------------------------------
local bodyVelocity, bodyGyro
local flyConnection

local moveKeys = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false,
}

local function startFly()
    local rootPart = getRoot()
    local humanoid = getHumanoid()
    if not rootPart or not humanoid then return end

    humanoid.PlatformStand = true

    if not bodyVelocity or not bodyVelocity.Parent then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart
    end

    if not bodyGyro or not bodyGyro.Parent then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 10000
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
    end

    if flyConnection then flyConnection:Disconnect() end

    flyConnection = RunService.RenderStepped:Connect(function()
        if not Config.Fly.Enabled or not rootPart or not rootPart.Parent then return end

        local moveDir = Vector3.zero
        local camCFrame = Camera.CFrame

        if moveKeys.Forward then moveDir = moveDir + camCFrame.LookVector end
        if moveKeys.Backward then moveDir = moveDir - camCFrame.LookVector end
        if moveKeys.Left then moveDir = moveDir - camCFrame.RightVector end
        if moveKeys.Right then moveDir = moveDir + camCFrame.RightVector end
        if moveKeys.Up then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if moveKeys.Down then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir.Unit * Config.Fly.Speed
        else
            bodyVelocity.Velocity = Vector3.zero
        end

        bodyGyro.CFrame = camCFrame
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    local humanoid = getHumanoid()
    if humanoid then
        humanoid.PlatformStand = false
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then moveKeys.Forward = true end
    if input.KeyCode == Enum.KeyCode.S then moveKeys.Backward = true end
    if input.KeyCode == Enum.KeyCode.A then moveKeys.Left = true end
    if input.KeyCode == Enum.KeyCode.D then moveKeys.Right = true end
    if input.KeyCode == Enum.KeyCode.Space then moveKeys.Up = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then moveKeys.Down = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then moveKeys.Forward = false end
    if input.KeyCode == Enum.KeyCode.S then moveKeys.Backward = false end
    if input.KeyCode == Enum.KeyCode.A then moveKeys.Left = false end
    if input.KeyCode == Enum.KeyCode.D then moveKeys.Right = false end
    if input.KeyCode == Enum.KeyCode.Space then moveKeys.Up = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then moveKeys.Down = false end
end)

--------------------------------------------------------------------------------
-- SISTEM LARI CEPAT (SPEEDHACK)
--------------------------------------------------------------------------------
local function updateSpeed()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = Config.Speed.Enabled and Config.Speed.Value or Config.Speed.DefaultWalkSpeed
    end
end

RunService.Stepped:Connect(function()
    if Config.Speed.Enabled then
        local humanoid = getHumanoid()
        if humanoid and humanoid.WalkSpeed ~= Config.Speed.Value then
            humanoid.WalkSpeed = Config.Speed.Value
        end
    end
end)

--------------------------------------------------------------------------------
-- SISTEM NOCLIP (TEMBUS DINDING)
--------------------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Config.Noclip.Enabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- TELEPORT & FOLLOW PLAYER
--------------------------------------------------------------------------------
local function teleportToCFrame(targetCFrame)
    local root = getRoot()
    if root then
        root.CFrame = targetCFrame + Vector3.new(0, 2, 0)
    end
end

local function findPlayer(nameQuery)
    nameQuery = nameQuery:lower():gsub("%s+", "")
    if nameQuery == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Name:lower():find(nameQuery) or p.DisplayName:lower():find(nameQuery) then
                return p
            end
        end
    end
    return nil
end

-- Loop Follow Player
RunService.RenderStepped:Connect(function()
    if Config.Follow.Enabled then
        local targetPlayer = nil
        if Config.Follow.TargetPlayer and Config.Follow.TargetPlayer.Parent then
            targetPlayer = Config.Follow.TargetPlayer
        elseif Config.Follow.TargetName and Config.Follow.TargetName ~= "" then
            targetPlayer = findPlayer(Config.Follow.TargetName)
        end

        if targetPlayer and targetPlayer.Character then
            local targetRoot = getRoot(targetPlayer.Character)
            local myRoot = getRoot()
            if targetRoot and myRoot then
                local backOffset = -targetRoot.CFrame.LookVector * Config.Follow.Distance
                local targetPos = targetRoot.Position + backOffset + Vector3.new(0, 0.5, 0)
                myRoot.CFrame = CFrame.new(targetPos, targetRoot.Position)
            end
        end
    end
end)

-- Reset saat respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if Config.Fly.Enabled then
        task.wait(0.5)
        startFly()
    end
    updateSpeed()
end)

--------------------------------------------------------------------------------
-- GUI UTAMA (TAB SYSTEM, MODERN & SCALABLE)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GunungKembarGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 430)
MainFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 62)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Header Title
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⛰️ Gunung Kembar v2"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- Tab Navigation Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 30)
TabBar.Position = UDim2.new(0, 8, 0, 42)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabBar

-- Content Area
local PagesFolder = Instance.new("Folder")
PagesFolder.Name = "Pages"
PagesFolder.Parent = MainFrame

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -16, 1, -84)
    page.Position = UDim2.new(0, 8, 0, 78)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = PagesFolder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    return page
end

local MainTab = createPage("Main")
local TeleportTab = createPage("Teleport")
local PlayerTab = createPage("Player")

local currentTab = nil
local tabButtons = {}

local function switchTab(name)
    for tabName, btn in pairs(tabButtons) do
        local page = PagesFolder:FindFirstChild(tabName .. "Page")
        if tabName == name then
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(48, 120, 240)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            page.Visible = false
            btn.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
            btn.TextColor3 = Color3.fromRGB(170, 170, 180)
        end
    end
end

local function addTabButton(name, displayName)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = displayName
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(170, 170, 180)
    btn.AutoButtonColor = false
    btn.Parent = TabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    tabButtons[name] = btn
end

addTabButton("Main", "⚡ Movement")
addTabButton("Teleport", "📍 Coords")
addTabButton("Player", "👤 Player")

--------------------------------------------------------------------------------
-- WIDGET HELPERS
--------------------------------------------------------------------------------
local function createToggleButton(parent, defaultText, initialStatus, onToggle)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local isEnabled = initialStatus

    local function refreshVisual()
        if isEnabled then
            button.BackgroundColor3 = Color3.fromRGB(38, 142, 85)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = defaultText .. ": ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
            button.TextColor3 = Color3.fromRGB(180, 180, 190)
            button.Text = defaultText .. ": OFF"
        end
    end

    button.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        refreshVisual()
        onToggle(isEnabled)
    end)

    refreshVisual()
    return button
end

local function createNumberInput(parent, label, defaultValue, onValChanged)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = Color3.fromRGB(190, 190, 200)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.38, 0, 1, 0)
    box.Position = UDim2.new(0.62, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 12
    box.Text = tostring(defaultValue)
    box.ClearTextOnFocus = false
    box.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num and num > 0 then
            onValChanged(num)
        else
            box.Text = tostring(defaultValue)
        end
    end)

    return row
end

local function createActionBtn(parent, text, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or Color3.fromRGB(38, 100, 210)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(onClick)
    return btn
end

--------------------------------------------------------------------------------
-- TAB 1: MOVEMENT (FLY, SPEED, NOCLIP)
--------------------------------------------------------------------------------
createToggleButton(MainTab, "Fly (Terbang)", Config.Fly.Enabled, function(state)
    Config.Fly.Enabled = state
    if state then startFly() else stopFly() end
end)

createNumberInput(MainTab, "Fly Speed:", Config.Fly.Speed, function(newVal)
    Config.Fly.Speed = newVal
end)

createToggleButton(MainTab, "Speedhack", Config.Speed.Enabled, function(state)
    Config.Speed.Enabled = state
    updateSpeed()
end)

createNumberInput(MainTab, "Walk Speed:", Config.Speed.Value, function(newVal)
    Config.Speed.Value = newVal
    if Config.Speed.Enabled then updateSpeed() end
end)

createToggleButton(MainTab, "Noclip (Tembus)", Config.Noclip.Enabled, function(state)
    Config.Noclip.Enabled = state
end)

--------------------------------------------------------------------------------
-- TAB 2: SAVE / LOAD KOORDINAT (JSON) & TELEPORT
--------------------------------------------------------------------------------
local LocInputBox = Instance.new("TextBox")
LocInputBox.Size = UDim2.new(1, 0, 0, 30)
LocInputBox.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
LocInputBox.BorderSizePixel = 0
LocInputBox.Font = Enum.Font.Gotham
LocInputBox.PlaceholderText = "Nama tempat..."
LocInputBox.Text = ""
LocInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
LocInputBox.TextSize = 12
LocInputBox.ClearTextOnFocus = false
LocInputBox.Parent = TeleportTab

local LocInputCorner = Instance.new("UICorner")
LocInputCorner.CornerRadius = UDim.new(0, 6)
LocInputCorner.Parent = LocInputBox

local CoordsListContainer = Instance.new("Frame")
CoordsListContainer.Size = UDim2.new(1, 0, 0, 0)
CoordsListContainer.AutomaticSize = Enum.AutomaticSize.Y
CoordsListContainer.BackgroundTransparency = 1
CoordsListContainer.Parent = TeleportTab

local CoordsListLayout = Instance.new("UIListLayout")
CoordsListLayout.Padding = UDim.new(0, 5)
CoordsListLayout.Parent = CoordsListContainer

local function renderSavedLocations()
    for _, child in ipairs(CoordsListContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local sortedKeys = {}
    for name in pairs(SavedCoordinates) do
        table.insert(sortedKeys, name)
    end
    table.sort(sortedKeys)

    if #sortedKeys == 0 then
        local emptyMsg = Instance.new("Frame")
        emptyMsg.Size = UDim2.new(1, 0, 0, 24)
        emptyMsg.BackgroundTransparency = 1
        emptyMsg.Parent = CoordsListContainer

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextColor3 = Color3.fromRGB(130, 130, 140)
        lbl.TextSize = 11
        lbl.Text = "Belum ada lokasi tersimpan."
        lbl.Parent = emptyMsg
        return
    end

    for _, name in ipairs(sortedKeys) do
        local data = SavedCoordinates[name]

        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 32)
        item.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        item.BorderSizePixel = 0
        item.Parent = CoordsListContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 5)
        c.Parent = item

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Text = name
        nameLabel.Parent = item

        -- TP Button
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.22, 0, 0, 24)
        tpBtn.Position = UDim2.new(0.52, 0, 0.5, -12)
        tpBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 75)
        tpBtn.BorderSizePixel = 0
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.TextSize = 11
        tpBtn.Parent = item

        local tpC = Instance.new("UICorner")
        tpC.CornerRadius = UDim.new(0, 4)
        tpC.Parent = tpBtn

        tpBtn.MouseButton1Click:Connect(function()
            if data and data.X and data.Y and data.Z then
                teleportToCFrame(CFrame.new(data.X, data.Y, data.Z))
            end
        end)

        -- Delete Button
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.2, 0, 0, 24)
        delBtn.Position = UDim2.new(0.77, 0, 0.5, -12)
        delBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        delBtn.BorderSizePixel = 0
        delBtn.Font = Enum.Font.GothamBold
        delBtn.Text = "Hapus"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.TextSize = 10
        delBtn.Parent = item

        local delC = Instance.new("UICorner")
        delC.CornerRadius = UDim.new(0, 4)
        delC.Parent = delBtn

        delBtn.MouseButton1Click:Connect(function()
            SavedCoordinates[name] = nil
            saveCoordinates()
            renderSavedLocations()
        end)
    end
end

createActionBtn(TeleportTab, "💾 Simpan Posisi Sekarang", Color3.fromRGB(40, 110, 200), function()
    local text = LocInputBox.Text:gsub("^%s*(.-)%s*$", "%1")
    if text == "" then
        text = "Loc_" .. tostring(#SavedCoordinates + 1)
    end

    local root = getRoot()
    if root then
        local pos = root.Position
        SavedCoordinates[text] = {
            X = math.floor(pos.X * 10) / 10,
            Y = math.floor(pos.Y * 10) / 10,
            Z = math.floor(pos.Z * 10) / 10,
        }
        saveCoordinates()
        LocInputBox.Text = ""
        renderSavedLocations()
    end
end)

createActionBtn(TeleportTab, "🔄 Reload File JSON", Color3.fromRGB(60, 60, 75), function()
    loadCoordinates()
    renderSavedLocations()
end)

renderSavedLocations()

--------------------------------------------------------------------------------
-- TAB 3: TELEPORT & FOLLOW PLAYER (REAL-TIME LIST & JARAK)
--------------------------------------------------------------------------------
local playerListItems = {}

local SearchInputBox = Instance.new("TextBox")
SearchInputBox.Size = UDim2.new(1, 0, 0, 30)
SearchInputBox.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
SearchInputBox.BorderSizePixel = 0
SearchInputBox.Font = Enum.Font.Gotham
SearchInputBox.PlaceholderText = "🔍 Cari player..."
SearchInputBox.Text = ""
SearchInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchInputBox.TextSize = 12
SearchInputBox.ClearTextOnFocus = false
SearchInputBox.Parent = PlayerTab

local SearchBoxCorner = Instance.new("UICorner")
SearchBoxCorner.CornerRadius = UDim.new(0, 6)
SearchBoxCorner.Parent = SearchInputBox

createNumberInput(PlayerTab, "Jarak Follow:", Config.Follow.Distance, function(newVal)
    Config.Follow.Distance = newVal
end)

local PlayerListContainer = Instance.new("Frame")
PlayerListContainer.Size = UDim2.new(1, 0, 0, 0)
PlayerListContainer.AutomaticSize = Enum.AutomaticSize.Y
PlayerListContainer.BackgroundTransparency = 1
PlayerListContainer.Parent = PlayerTab

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 5)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Parent = PlayerListContainer

local function getDistanceToPlayer(targetPlayer)
    local myRoot = getRoot()
    if myRoot and targetPlayer.Character then
        local targetRoot = getRoot(targetPlayer.Character)
        if targetRoot then
            return math.floor((myRoot.Position - targetRoot.Position).Magnitude)
        end
    end
    return nil
end

local function updatePlayerCardVisual(targetPlayer, cardData)
    local isFollowingThis = Config.Follow.Enabled and Config.Follow.TargetPlayer == targetPlayer
    if isFollowingThis then
        cardData.FollowBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
        cardData.FollowBtn.Text = "Following"
    else
        cardData.FollowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        cardData.FollowBtn.Text = "Follow"
    end

    local dist = getDistanceToPlayer(targetPlayer)
    if dist then
        cardData.DistLabel.Text = tostring(dist) .. " studs"
        cardData.DistLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    else
        cardData.DistLabel.Text = "Dead / N/A"
        cardData.DistLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
    end
end

local function renderPlayerList()
    for _, item in pairs(playerListItems) do
        if item.Frame and item.Frame.Parent then
            item.Frame:Destroy()
        end
    end
    playerListItems = {}

    local query = SearchInputBox.Text:lower():gsub("%s+", "")
    local allPlayers = Players:GetPlayers()

    for _, p in ipairs(allPlayers) do
        if p ~= LocalPlayer then
            local pName = p.Name
            local dName = p.DisplayName
            local matches = (query == "") or (pName:lower():find(query, 1, true) ~= nil) or (dName:lower():find(query, 1, true) ~= nil)

            if matches then
                local item = Instance.new("Frame")
                item.Name = "Player_" .. p.UserId
                item.Size = UDim2.new(1, 0, 0, 42)
                item.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
                item.BorderSizePixel = 0
                item.Parent = PlayerListContainer

                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, 6)
                c.Parent = item

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
                nameLabel.Position = UDim2.new(0, 8, 0, 2)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Font = Enum.Font.GothamSemibold
                nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
                nameLabel.TextSize = 11
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Text = dName .. " (@" .. pName .. ")"
                nameLabel.Parent = item

                local distLabel = Instance.new("TextLabel")
                distLabel.Size = UDim2.new(0.5, 0, 0, 16)
                distLabel.Position = UDim2.new(0, 8, 0, 22)
                distLabel.BackgroundTransparency = 1
                distLabel.Font = Enum.Font.Gotham
                distLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
                distLabel.TextSize = 10
                distLabel.TextXAlignment = Enum.TextXAlignment.Left
                distLabel.Text = "... studs"
                distLabel.Parent = item

                -- Tombol TP
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0.18, 0, 0, 26)
                tpBtn.Position = UDim2.new(0.52, 0, 0.5, -13)
                tpBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 75)
                tpBtn.BorderSizePixel = 0
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.Text = "TP"
                tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                tpBtn.TextSize = 11
                tpBtn.Parent = item

                local tpC = Instance.new("UICorner")
                tpC.CornerRadius = UDim.new(0, 5)
                tpC.Parent = tpBtn

                tpBtn.MouseButton1Click:Connect(function()
                    if p.Character then
                        local targetRoot = getRoot(p.Character)
                        if targetRoot then
                            teleportToCFrame(targetRoot.CFrame)
                        end
                    end
                end)

                -- Tombol Follow
                local followBtn = Instance.new("TextButton")
                followBtn.Size = UDim2.new(0.26, 0, 0, 26)
                followBtn.Position = UDim2.new(0.72, 0, 0.5, -13)
                followBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                followBtn.BorderSizePixel = 0
                followBtn.Font = Enum.Font.GothamBold
                followBtn.Text = "Follow"
                followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                followBtn.TextSize = 10
                followBtn.Parent = item

                local followC = Instance.new("UICorner")
                followC.CornerRadius = UDim.new(0, 5)
                followC.Parent = followBtn

                followBtn.MouseButton1Click:Connect(function()
                    if Config.Follow.Enabled and Config.Follow.TargetPlayer == p then
                        -- Matikan follow jika sudah mem-follow orang ini
                        Config.Follow.Enabled = false
                        Config.Follow.TargetPlayer = nil
                        Config.Follow.TargetName = ""
                    else
                        -- Mulai follow orang ini
                        Config.Follow.Enabled = true
                        Config.Follow.TargetPlayer = p
                        Config.Follow.TargetName = p.Name
                    end

                    for otherPlayer, otherCard in pairs(playerListItems) do
                        updatePlayerCardVisual(otherPlayer, otherCard)
                    end
                end)

                local cardData = {
                    Frame = item,
                    DistLabel = distLabel,
                    FollowBtn = followBtn
                }
                playerListItems[p] = cardData
                updatePlayerCardVisual(p, cardData)
            end
        end
    end
end

-- Update jarak player setiap frame (real-time)
local updateTicker = 0
RunService.RenderStepped:Connect(function(dt)
    updateTicker = updateTicker + dt
    if updateTicker >= 0.15 then
        updateTicker = 0
        if PlayerTab.Visible then
            for targetPlayer, cardData in pairs(playerListItems) do
                if targetPlayer.Parent == Players and cardData.DistLabel and cardData.DistLabel.Parent then
                    local dist = getDistanceToPlayer(targetPlayer)
                    if dist then
                        cardData.DistLabel.Text = tostring(dist) .. " studs"
                        cardData.DistLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
                    else
                        cardData.DistLabel.Text = "Dead / N/A"
                        cardData.DistLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
                    end

                    local isFollowingThis = Config.Follow.Enabled and Config.Follow.TargetPlayer == targetPlayer
                    if isFollowingThis and cardData.FollowBtn.Text ~= "Following" then
                        cardData.FollowBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
                        cardData.FollowBtn.Text = "Following"
                    elseif not isFollowingThis and cardData.FollowBtn.Text ~= "Follow" then
                        cardData.FollowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        cardData.FollowBtn.Text = "Follow"
                    end
                end
            end
        end
    end
end)

-- Event listener saat ada player masuk / keluar / search query diubah
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    renderPlayerList()
end)

Players.PlayerRemoving:Connect(function(p)
    if Config.Follow.TargetPlayer == p then
        Config.Follow.Enabled = false
        Config.Follow.TargetPlayer = nil
    end
    renderPlayerList()
end)

SearchInputBox:GetPropertyChangedSignal("Text"):Connect(function()
    renderPlayerList()
end)

renderPlayerList()

-- Default tab
switchTab("Main")

print("[GunungKembar] v2 loaded successfully! Koordinat tersimpan di: " .. SAVE_FILE_NAME)
