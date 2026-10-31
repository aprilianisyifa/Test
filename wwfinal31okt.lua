if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = Workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui", 15) or localPlayer:FindFirstChild("PlayerGui")
local function getPlayerGui()
    if localPlayer then
        local pg = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:FindFirstChild("PlayerGui")
        if pg then return pg end
    end
    return playerGui
end



-- Safe GUI Parent
local targetParent = CoreGui
local successCore, _ = pcall(function() return CoreGui:GetChildren() end)
if not successCore then
    targetParent = playerGui
end

-- Hapus GUI lama jika ada
local oldGui = targetParent:FindFirstChild("WW3_SupremeCommand_GUI") or playerGui:FindFirstChild("WW3_SupremeCommand_GUI")
if oldGui then oldGui:Destroy() end

-- Silent Anti-AFK
if getgenv and getgenv()._WW3_IdledConn then
    pcall(function() getgenv()._WW3_IdledConn:Disconnect() end)
    getgenv()._WW3_IdledConn = nil
end
local idledConn = localPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)
if getgenv then getgenv()._WW3_IdledConn = idledConn end

-- ====================================================================================================
-- REMOTE REFERENCES & DATABASES
-- ====================================================================================================
local Remotes = {
    Placement = ReplicatedStorage:WaitForChild("PlacementRemotes", 5) and ReplicatedStorage.PlacementRemotes:FindFirstChild("PlacementRequest"),
    MilitaryStore = ReplicatedStorage:WaitForChild("MilitaryStoreRemotes", 5) and ReplicatedStorage.MilitaryStoreRemotes:FindFirstChild("MilitaryStoreRequest"),
    MissileAttack = ReplicatedStorage:WaitForChild("MissileAttackRemotes", 5) and ReplicatedStorage.MissileAttackRemotes:FindFirstChild("MissileLaunchRequest"),
    Warship = ReplicatedStorage:WaitForChild("WarshipRemotes", 5) and ReplicatedStorage.WarshipRemotes:FindFirstChild("WarshipLaunchRequest")
}

local MISSILES = {
    { Id = "RT0001", Name = "KA 47M",        Footprint = { W = 2, L = 3 }, DMG = 40,   DPS = 40,   Speed = 89.25, PriceX1 = 200,    PriceX5 = 1000,   Matches = { "133388089113700", "kinzhal", "kh-47m2" } },
    { Id = "RT0002", Name = "Bandit I",      Footprint = { W = 2, L = 3 }, DMG = 90,   DPS = 90,   Speed = 89.25, PriceX1 = 600,    PriceX5 = 3000,   Matches = { "111406394053022", "rattlesnake" } },
    { Id = "RT0003", Name = "R60",           Footprint = { W = 2, L = 3 }, DMG = 150,  DPS = 150,  Speed = 89.25, PriceX1 = 1400,   PriceX5 = 7000,   Matches = { "122604513937852", "82704239908815", "76675308472933", "116986014246397", "134041172433490", "r60", "r-60" } },
    { Id = "RT0004", Name = "Big Dipper",    Footprint = { W = 2, L = 3 }, DMG = 240,  DPS = 240,  Speed = 89.25, PriceX1 = 3100,   PriceX5 = 15500,  Matches = { "118809562102190", "precision strike missile", "dipper" } },
    { Id = "RT0005", Name = "AMG-88",        Footprint = { W = 2, L = 3 }, DMG = 350,  DPS = 350,  Speed = 89.25, PriceX1 = 6100,   PriceX5 = 30500,  Matches = { "74476487753213", "agm_88e", "agm-88", "amg-88" } },
    { Id = "RT0006", Name = "XA-58",         Footprint = { W = 2, L = 3 }, DMG = 500,  DPS = 500,  Speed = 89.25, PriceX1 = 11300,  PriceX5 = 56500,  Matches = { "118721420493302", "x-583", "xa-58", "xa58" } },
    { Id = "RT1001", Name = "Hydra 90",      Footprint = { W = 2, L = 4 }, DMG = 700,  DPS = 700,  Speed = 80.0,  PriceX1 = 20100,  PriceX5 = 100500, Matches = { "107613969304655", "114323811387084", "138657038557102", "74613289768978", "86351969098338", "113064797765395", "hydra" } },
    { Id = "RT1002", Name = "YJ-28S",        Footprint = { W = 2, L = 4 }, DMG = 950,  DPS = 950,  Speed = 75.0,  PriceX1 = 34300,  PriceX5 = 171500, Matches = { "70388515744461", "128835980577337", "117562503731366", "yj-28", "yj28" } },
    { Id = "RT1003", Name = "DF-17S",        Footprint = { W = 2, L = 4 }, DMG = 1250, DPS = 1250, Speed = 75.0,  PriceX1 = 56500,  PriceX5 = 282500, Matches = { "75701057039843", "df_17", "df-17", "df17" } },
    { Id = "RT1004", Name = "Giant Eagle",   Footprint = { W = 3, L = 4 }, DMG = 1600, DPS = 1600, Speed = 70.0,  PriceX1 = 89100,  PriceX5 = 445500, Matches = { "11137612182", "11137614316", "11137613475", "giant eagle", "eagle" } },
    { Id = "RT1005", Name = "Wave 2",        Footprint = { W = 3, L = 4 }, DMG = 2100, DPS = 2100, Speed = 70.0,  PriceX1 = 133400, PriceX5 = 667000, Matches = { "77118635345663", "133320643796584", "127313976009566", "118544327565880", "105273891847033", "wave" } },
    { Id = "RT1006", Name = "AMG-86",        Footprint = { W = 3, L = 4 }, DMG = 2700, DPS = 2700, Speed = 70.0,  PriceX1 = 185700, PriceX5 = 928500, Matches = { "76975999013566", "75735331078330", "83680709157565", "amg-86", "amg86" } },
    { Id = "RT2001", Name = "Militia III",   Footprint = { W = 3, L = 5 }, DMG = 3500, DPS = 3500, Speed = 73.5,  PriceX1 = 231400, PriceX5 = 1157000, Matches = { "116435603056756", "135472054648521", "120045875324220", "militia" } },
    { Id = "RT2002", Name = "Harpoon II",    Footprint = { W = 3, L = 5 }, DMG = 4500, DPS = 4500, Speed = 73.5,  PriceX1 = 416500, PriceX5 = 2082500, Matches = { "90690622186053", "125881250959492", "88999432433984", "85755214175691", "harpoon" } },
    { Id = "RT2003", Name = "Greataxe",      Footprint = { W = 3, L = 5 }, DMG = 6000, DPS = 6000, Speed = 73.5,  PriceX1 = 749600, PriceX5 = 3748000, Matches = { "133420280556723", "85630991157541", "86589242327256", "79467466481183", "119645385946193", "greataxe" } },
    { Id = "RT2004", Name = "USR 1000",      Footprint = { W = 4, L = 5 }, DMG = 8000, DPS = 8000, Speed = 70.0,  PriceX1 = 1300000, PriceX5 = 6500000, Matches = { "80501661029705", "86749196430610", "121147644219688", "87240548566757", "115452850782627", "usr" } },
    { Id = "RT2005", Name = "Shrine RBS 15", Footprint = { W = 4, L = 5 }, DMG = 11000,DPS = 11000,Speed = 70.0,  PriceX1 = 2400000, PriceX5 = 12000000, Matches = { "114707110961920", "123542176605815", "76750123001763", "104767864589833", "109901742485455", "shrine", "rbs" } },
    { Id = "RT9000", Name = "Peace Keeper",  Footprint = { W = 4, L = 6 }, DMG = 25000,DPS = 25000,Speed = 65.0,  PriceX1 = 5000000, PriceX5 = 25000000, Matches = { "81359367741689", "peace keeper", "peacekeeper" } }
}

local MISSILE_BY_ID = {}
for _, m in ipairs(MISSILES) do MISSILE_BY_ID[m.Id] = m end

local WARSHIP_SPECS = {
    WS0001 = { Name = "Specter",    DPS = 157,  HP = 10000 },
    WS1001 = { Name = "Specter",    DPS = 157,  HP = 10000 },
    WS1002 = { Name = "Viper",      DPS = 290,  HP = 18000 },
    WS1003 = { Name = "Devastator", DPS = 480,  HP = 30000 },
    WS2001 = { Name = "Nautilus",   DPS = 750,  HP = 55000 },
    WS2002 = { Name = "Kraken",     DPS = 1100, HP = 90000 },
    WS3001 = { Name = "Leviathan",  DPS = 1800, HP = 150000 },
}

local DEFENSE_SPECS = {
    -- Anti-Air Defenses (DPS & HP)
    AR1001 = { Name = "AP 110",          DPS = 20,  HP = 420 },
    AR1002 = { Name = "AP 150",          DPS = 48,  HP = 700 },
    AR1003 = { Name = "AP 300",          DPS = 77,  HP = 980 },
    AR1011 = { Name = "AP 580",          DPS = 90,  HP = 1050 },
    AR1012 = { Name = "AP 680",          DPS = 115, HP = 1200 },
    AR1013 = { Name = "AP 980",          DPS = 133, HP = 1350 },
    AR2001 = { Name = "Laser Defender",  DPS = 150, HP = 1200 },
    AR2002 = { Name = "Cromwell",        DPS = 170, HP = 1650 },
    AR2003 = { Name = "Anode Defense",   DPS = 210, HP = 2200 },
    AR3001 = { Name = "Vulcan",          DPS = 260, HP = 3000 },
    AR3002 = { Name = "Mini-Shield",     DPS = 0,   HP = 5000 },
    -- Anti-Sea Defenses (DPS & HP)
    AS1001 = { Name = "Defense Barrier", DPS = 53,  HP = 4000 },
    AS1002 = { Name = "AS 440",          DPS = 53,  HP = 1500 },
    AS1003 = { Name = "Laser Breaker",   DPS = 71,  HP = 2000 },
    AS2001 = { Name = "Anode Assault",   DPS = 101, HP = 2600 },
    AS2002 = { Name = "Vulcan-M",        DPS = 160, HP = 3200 },
    AS2003 = { Name = "Quad-Vulcan",     DPS = 202, HP = 3800 },
    AS3001 = { Name = "Centurion",       DPS = 270, HP = 4500 },
    AS3002 = { Name = "Hornet",          DPS = 330, HP = 6000 }
}

local BASE_COORDINATES = {
    [1] = Vector3.new(596.00, 419.48, 0.00),
    [2] = Vector3.new(298.00, 419.48, 516.15),
    [3] = Vector3.new(-298.00, 419.48, 516.15),
    [4] = Vector3.new(-596.00, 419.48, 0.00),
    [5] = Vector3.new(-298.00, 419.48, -516.15),
    [6] = Vector3.new(298.00, 419.48, -516.15)
}
local CENTER_ISLAND_POS = Vector3.new(0, 5, 0)

-- ====================================================================================================
-- GLOBAL STATE OBJECT
-- ====================================================================================================
local State = {
    AutoBuyActive = false,
    AutoDeployActive = false,
    AutoTpBaseEnabled = false,  -- Auto pindah ke 5 titik base tiap 5 detik
    AutoTpBaseLastTime = 0,
    AutoAttackActive = false,
    AutoFarmActive = false,

    RefillEnabled = false,
    RefillTargetStock = 1000,
    RefillMissileId = "RT1006",

    SelectedMissileIndex = 12,   -- AMG-86 (RT1006)
    BuyQuantity = 1000,
    DeployQuantity = 50,
    DeployPosition = "Depan",   -- "Random" | "Belakang" | "Depan" | "Tengah" | "Rapi"
    DeployAlign = "Horizontal",  -- "Horizontal" | "Vertikal"
    DeploySpeed = "Ultra",       -- "Normal" | "Turbo" | "Ultra"
    DeployBlacklistDuration = 7, -- Durasi cooldown blacklist spot gagal (default: 7 detik)
    DeploySmartQueue = true,     -- Default TRUE: Tunggu salvo launch selesai & hindari tabrakan CPU saat perang
    _IsLaunching = false,        -- Flag aktif saat roket sedang dalam sequence peluncuran

    SelectedBaseIndex = 2,
    WeaponType = "Missile",      -- "Missile" | "Warship" | "Kombinasi"
    SelectedMissileTypes = {},   -- Multi-select map: { [ItemId] = true } (default: kosong/belum dipilih)
    SelectedWarshipTypes = {},   -- Multi-select map: { [ItemId] = true } (default: kosong/belum dipilih)
    SelectAllMissiles = false,   -- Default false: user harus memilih jenis misilnya secara eksplisit
    SelectAllWarships = false,   -- Default false: user harus memilih jenis kapalnya secara eksplisit
    ManualLaunchVolley = 5,
    CustomMissileQuota = 0,      -- 0 = gunakan ManualLaunchVolley default; jika > 0 maka batasi total kuota misil yg diluncurkan
    WarshipVolley = 1,
    UnlockX10 = false,
    Unlock150Missiles = false, -- Toggle Gamepass / Unlock kapasitas base 150 misil
    ClusteredLaunchEnabled = true, -- Toggle Sortir Misil Terdekat (Berurutan / Klaster Rapat saat Launch)
    EnemyBuildingRepairRate = 25,
    AutoBreakShield = true,
    CombatAssistantEnabled = true,
    AutoRefreshAssistant = false, -- Default OFF: refresh analisis dilakukan manual atau dinyalakan sesuai kebutuhan
    LoopAttackEnabled = false,    -- Mode Loop Serangan (ON / OFF)
    LoopSpeedMultiplier = 1,      -- Pengali Kecepatan Loop (1x - 10x)
    TargetLoopActive = false,     -- Status aktif serangan loop target (Building/Anti-Air/Anti-Sea)
    AutoComboLoopActive = false,  -- Status aktif Serangan Otomatis Terpadu (Anti-Air -> Anti-Sea & Building acak/padat)
    AutoComboPriorityOverride = nil, -- Prioritas manual sementara saat serangan otomatis berjalan (misal: "AntiShip")
    AutoHarassInterval = 0,       -- Interval detik serang karakter lawan (0 = OFF, >0 = tiap n detik launch 1x misil)
    ActiveLoopCategory = nil,     -- "Buildings" | "AntiAir" | "AntiShip" | "AutoCombo"
    PreferredAAClusterRank = 0,   -- 0 = Auto (Terpadat #1), 1-5 = Klaster #1 s/d #5

    FarmWeapon = "Warship",
    FarmTargets = {},
    FarmRunning = false,
    FarmMinBuildings = 45,
    FarmMinBuildLevel = 14,
    FarmMinShips = 6,
    FarmMaxShips = 8,
    FarmScanInterval = 30,
    FarmFleetCheck = 10,
    FarmSentCooldown = 20,

    FlyEnabled = false,
    FlySpeed = 60,
    DroneViewEnabled = false,
    DroneAltitude = 1100, -- Ketinggian default Drone View (stud)
    DroneOffsetX = 0,    -- Geser Drone View Sumbu X (Kanan / Kiri)
    DroneOffsetZ = 0,    -- Geser Drone View Sumbu Z (Maju / Mundur / Atas / Bawah)
    SpeedHackEnabled = false,
    SpeedHackValue = 48,
    FreezeMode = "OFF",          -- Default OFF sesuai instruksi
    FreezeApplied = false,       -- Status anchoring saat ini
    FreezeAutoLastCycle = 0,     -- Waktu terakhir Auto Freeze melakukan re-freeze (tiap 5 detik)
    NoclipEnabled = true,        -- Default ON (tembus dinding langsung aktif)
    FollowTarget = nil,
    FlingTarget = nil,
    FlingPower = "Rendah",
    FlingAutoRecall = true,
    FlingExecuting = false,     -- True saat proses TP+Kick berlangsung agar tidak di-anchor oleh auto-freeze
    AutoEvadeEnabled = false,   -- Default OFF: Auto teleport menjauh jika musuh < 10 stud
    MissileEvadeEnabled = true, -- Default ON: Auto TP Base jika misil di atas kepala / Y < 20
    LastEvadeTime = 0,          -- Cooldown time tracking untuk auto evade
    AttackModalVisible = false,         -- Toggle GUI Mode Attack Shortcut
    AttackModalAutoRefresh = false,     -- Auto Refresh status analisis di GUI Mode Attack (Default OFF)
    ManualClickAttackEnabled = false,   -- Mode Serang Manual via Klik Minimap / Radar
    ManualClickCount = 0,               -- Penghitung total klik serangan manual pada minimap
    AntiRagdollEnabled = false,
    VibeFlingActive = false,
    FpsSaverEnabled = false,            -- Fitur Opsional Penghemat RAM / Anti-Lag
    GhostMode = false,                  -- Ghost Mode On/Off
    GhostHeight = 0,                    -- Offset Ketinggian Ghost (-1600 s/d +1600, default 0)
    GhostClientController = nil,        -- Dummy Controller Clone di tanah

    -- Pengaturan Grafik Sederhana (Pause Laut & Hilangkan Shadow)
    SeaDisabled = false,
    UltraLowLighting = false,           -- Shadows & PostFX ON/OFF

    -- Mobile Fly Controls State
    MobileFly = {
        Forward = false,
        Backward = false,
        Left = false,
        Right = false,
        Up = false,
        Down = false,
        Container = nil
    },

    -- Dynamic UI References for Callbacks
    UI = {}
}

local function logMessage(msg)
    -- Console logging dinonaktifkan agar tidak membebani memori dan device pemain.
    -- Notifikasi visual tetap disampaikan melalui showToast.
end

local function parseCleanNumber(val)
    if type(val) == "number" then return val end
    local clean = tostring(val or ""):gsub("%D", "")
    return tonumber(clean)
end

-- Formatting Utilities
local function formatNumber(val)
    if type(val) == "string" then val = tonumber((val:gsub(",", ""):gsub("%$", ""):gsub("%s+", ""))) end
    if not val or type(val) ~= "number" then return tostring(val or "0") end
    local formatted = tostring(math.floor(val))
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

-- ====================================================================================================
-- RIGHT-SIDE TOAST NOTIFICATION SYSTEM
-- ====================================================================================================
local toastContainer = nil
local function showToast(title, message, toastType)
    pcall(function()
        if not toastContainer or not toastContainer.Parent then
            local mainGui = targetParent:FindFirstChild("WW3_SupremeCommand_GUI") or playerGui:FindFirstChild("WW3_SupremeCommand_GUI")
            if not mainGui then return end
            toastContainer = Instance.new("Frame", mainGui)
            toastContainer.Name = "WW3_ToastContainer"
            toastContainer.Size = UDim2.new(0, 240, 1, -80)
            toastContainer.Position = UDim2.new(1, -250, 0, 40)
            toastContainer.BackgroundTransparency = 1
            toastContainer.ZIndex = 9999
            local tLayout = Instance.new("UIListLayout", toastContainer)
            tLayout.FillDirection = Enum.FillDirection.Vertical
            tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            tLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            tLayout.Padding = UDim.new(0, 8)
        end

        local colorMap = {
            success = Color3.fromRGB(0, 210, 120),
            info = Color3.fromRGB(0, 180, 255),
            warn = Color3.fromRGB(255, 180, 40),
            danger = Color3.fromRGB(255, 60, 80)
        }
        local accentCol = colorMap[toastType or "info"] or Color3.fromRGB(0, 180, 255)

        local tCard = Instance.new("Frame", toastContainer)
        tCard.Size = UDim2.new(1, 0, 0, 56)
        tCard.BackgroundColor3 = Color3.fromRGB(16, 22, 34)
        tCard.BackgroundTransparency = 0.1
        tCard.ZIndex = 10000
        Instance.new("UICorner", tCard).CornerRadius = UDim.new(0, 8)
        local tStroke = Instance.new("UIStroke", tCard)
        tStroke.Color = accentCol
        tStroke.Thickness = 1.2

        local leftBar = Instance.new("Frame", tCard)
        leftBar.Size = UDim2.new(0, 4, 1, 0)
        leftBar.BackgroundColor3 = accentCol
        leftBar.BorderSizePixel = 0
        Instance.new("UICorner", leftBar).CornerRadius = UDim.new(0, 4)

        local tTitle = Instance.new("TextLabel", tCard)
        tTitle.Size = UDim2.new(1, -16, 0, 18)
        tTitle.Position = UDim2.new(0, 12, 0, 6)
        tTitle.BackgroundTransparency = 1
        tTitle.Font = Enum.Font.GothamBold
        tTitle.Text = tostring(title or "NOTIFIKASI")
        tTitle.TextColor3 = accentCol
        tTitle.TextSize = 11
        tTitle.TextXAlignment = Enum.TextXAlignment.Left

        local tMsg = Instance.new("TextLabel", tCard)
        tMsg.Size = UDim2.new(1, -16, 0, 26)
        tMsg.Position = UDim2.new(0, 12, 0, 24)
        tMsg.BackgroundTransparency = 1
        tMsg.Font = Enum.Font.Gotham
        tMsg.Text = tostring(message or "")
        tMsg.TextColor3 = Color3.fromRGB(230, 240, 255)
        tMsg.TextSize = 10
        tMsg.TextWrapped = true
        tMsg.TextXAlignment = Enum.TextXAlignment.Left

        -- Auto dismiss animation
        task.delay(3.5, function()
            if tCard and tCard.Parent then
                local tw = TweenService:Create(tCard, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                })
                tw:Play()
                task.wait(0.4)
                if tCard and tCard.Parent then tCard:Destroy() end
            end
        end)
    end)
end

-- ====================================================================================================
-- CONFIGURATION STORAGE (wwesaved.json)
-- ====================================================================================================
local CONFIG_FILE_NAME = "wwesaved.json"

local function saveConfigToFile()
    local cfg = {
        RefillTargetStock = State.RefillTargetStock or 1000,
        SelectedMissileIndex = State.SelectedMissileIndex or 1,
        BuyQuantity = State.BuyQuantity or 1,
        DeployQuantity = State.DeployQuantity or 10,
        DeployPosition = State.DeployPosition or "Belakang",
        DeployAlign = State.DeployAlign or "Horizontal",
        DeploySpeed = State.DeploySpeed or "Turbo",
        SelectedBaseIndex = State.SelectedBaseIndex or 2,
        WeaponType = State.WeaponType or "Missile",
        ManualLaunchVolley = State.ManualLaunchVolley or 5,
        WarshipVolley = State.WarshipVolley or 1,
        UnlockX10 = State.UnlockX10,
        ClusteredLaunchEnabled = State.ClusteredLaunchEnabled,
        EnemyBuildingRepairRate = State.EnemyBuildingRepairRate or 25,
        AutoBreakShield = State.AutoBreakShield,
        CombatAssistantEnabled = State.CombatAssistantEnabled,
        AutoRefreshAssistant = State.AutoRefreshAssistant,
        LoopAttackEnabled = State.LoopAttackEnabled,
        FarmMinBuildings = State.FarmMinBuildings or 45,
        FarmMinBuildLevel = State.FarmMinBuildLevel or 14,
        FarmMinShips = State.FarmMinShips or 6,
        FarmMaxShips = State.FarmMaxShips or 8,
        FarmScanInterval = State.FarmScanInterval or 30,
        FarmFleetCheck = State.FarmFleetCheck or 10,
        FarmSentCooldown = State.FarmSentCooldown or 20,
        FlySpeed = State.FlySpeed or 60,
        DroneAltitude = State.DroneAltitude or 120,
        SpeedHackValue = State.SpeedHackValue or 48,
        FreezeMode = State.FreezeMode or "Auto",
        FlingPower = State.FlingPower or "Rendah",
        FlingAutoRecall = State.FlingAutoRecall,
        AntiRagdollEnabled = State.AntiRagdollEnabled
    }

    local encoded = nil
    pcall(function() encoded = HttpService:JSONEncode(cfg) end)
    if not encoded then
        logMessage("❌ Gagal encode konfigurasi JSON!")
        showToast("Simpan Gagal", "Gagal meng-encode data JSON!", "danger")
        return false
    end

    local saved = false
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE_NAME, encoded)
            saved = true
        end
    end)

    if saved then
        logMessage("💾 Konfigurasi berhasil disimpan ke " .. CONFIG_FILE_NAME)
        showToast("Konfigurasi Disimpan", "Pengaturan tersimpan ke " .. CONFIG_FILE_NAME, "success")
        return true
    else
        logMessage("⚠️ Executor tidak mendukung fungsi writefile!")
        showToast("Simpan Offline", "writefile tidak tersedia di executor ini", "warn")
        return false
    end
end

local function loadConfigFromFile()
    local content = nil
    pcall(function()
        if readfile and (not isfile or isfile(CONFIG_FILE_NAME)) then
            content = readfile(CONFIG_FILE_NAME)
        end
    end)

    if not content or content == "" then
        logMessage("ℹ️ File konfigurasi " .. CONFIG_FILE_NAME .. " belum ada.")
        showToast("Config Tidak Ada", "Belum ada file " .. CONFIG_FILE_NAME, "warn")
        return false
    end

    local success, parsed = pcall(function() return HttpService:JSONDecode(content) end)
    if not success or type(parsed) ~= "table" then
        logMessage("❌ Gagal membaca format JSON " .. CONFIG_FILE_NAME)
        showToast("Load Gagal", "Format JSON file rusak!", "danger")
        return false
    end

    if parsed.RefillTargetStock then State.RefillTargetStock = tonumber(parsed.RefillTargetStock) end
    if parsed.SelectedMissileIndex then State.SelectedMissileIndex = tonumber(parsed.SelectedMissileIndex) end
    if parsed.BuyQuantity then State.BuyQuantity = tonumber(parsed.BuyQuantity) end
    if parsed.DeployQuantity then State.DeployQuantity = parsed.DeployQuantity end
    if parsed.DeployPosition then State.DeployPosition = parsed.DeployPosition end
    if parsed.DeployAlign then State.DeployAlign = parsed.DeployAlign end
    if parsed.DeploySpeed then State.DeploySpeed = parsed.DeploySpeed end
    if parsed.SelectedBaseIndex then State.SelectedBaseIndex = tonumber(parsed.SelectedBaseIndex) end
    if parsed.WeaponType then State.WeaponType = parsed.WeaponType end
    if parsed.ManualLaunchVolley then State.ManualLaunchVolley = tonumber(parsed.ManualLaunchVolley) end
    if parsed.WarshipVolley then State.WarshipVolley = tonumber(parsed.WarshipVolley) end
    if parsed.UnlockX10 ~= nil then State.UnlockX10 = parsed.UnlockX10 end
    if parsed.ClusteredLaunchEnabled ~= nil then State.ClusteredLaunchEnabled = parsed.ClusteredLaunchEnabled end
    if parsed.EnemyBuildingRepairRate then State.EnemyBuildingRepairRate = tonumber(parsed.EnemyBuildingRepairRate) end
    if parsed.AutoBreakShield ~= nil then State.AutoBreakShield = parsed.AutoBreakShield end
    if parsed.CombatAssistantEnabled ~= nil then State.CombatAssistantEnabled = parsed.CombatAssistantEnabled end
    if parsed.AutoRefreshAssistant ~= nil then State.AutoRefreshAssistant = parsed.AutoRefreshAssistant end
    if parsed.LoopAttackEnabled ~= nil then State.LoopAttackEnabled = parsed.LoopAttackEnabled end
    if parsed.FarmMinBuildings ~= nil then State.FarmMinBuildings = tonumber(parsed.FarmMinBuildings) end
    if parsed.FarmMinBuildLevel ~= nil then State.FarmMinBuildLevel = tonumber(parsed.FarmMinBuildLevel) end
    if parsed.FarmMinShips ~= nil then State.FarmMinShips = tonumber(parsed.FarmMinShips) end
    if parsed.FarmMaxShips ~= nil then State.FarmMaxShips = tonumber(parsed.FarmMaxShips) end
    if parsed.FarmScanInterval ~= nil then State.FarmScanInterval = tonumber(parsed.FarmScanInterval) end
    if parsed.FarmFleetCheck ~= nil then State.FarmFleetCheck = tonumber(parsed.FarmFleetCheck) end
    if parsed.FarmSentCooldown ~= nil then State.FarmSentCooldown = tonumber(parsed.FarmSentCooldown) end
    if parsed.FlySpeed then State.FlySpeed = tonumber(parsed.FlySpeed) end
    if parsed.DroneAltitude then State.DroneAltitude = tonumber(parsed.DroneAltitude) end
    if parsed.SpeedHackValue then State.SpeedHackValue = tonumber(parsed.SpeedHackValue) end
    if parsed.FreezeMode then State.FreezeMode = parsed.FreezeMode end
    if parsed.FlingPower then State.FlingPower = parsed.FlingPower end
    if parsed.FlingAutoRecall ~= nil then State.FlingAutoRecall = parsed.FlingAutoRecall end
    if parsed.AntiRagdollEnabled ~= nil then State.AntiRagdollEnabled = parsed.AntiRagdollEnabled end

    logMessage("✅ Konfigurasi berhasil dimuat dari " .. CONFIG_FILE_NAME)
    showToast("Konfigurasi Dimuat", "Berhasil menerapkan data dari " .. CONFIG_FILE_NAME, "success")
    return true
end

-- ====================================================================================================
-- CORE SCANNER ENGINES
-- ====================================================================================================
local function checkDescendantMatches(desc, targetId, matchPatterns)
    local dName = desc.Name:lower()
    if desc.Name:upper():find(targetId) then return true end
    if desc:IsA("MeshPart") then
        local mId = tostring(desc.MeshId):lower()
        for _, pat in ipairs(matchPatterns) do
            if mId:find(pat) or dName:find(pat) then return true end
        end
    end
    for _, pat in ipairs(matchPatterns) do
        if dName:find(pat) then return true end
    end
    return false
end

local function getMissileStock(missileItem)
    local totalStock = 0
    local targetId = missileItem.Id:upper()
    local patterns = missileItem.Matches or {}
    local pGui = getPlayerGui()
    local guiLobby = pGui and pGui:FindFirstChild("Gui_Lobby")

    local invFrame = guiLobby and guiLobby:FindFirstChild("InventoryFrame")
    local itemList = invFrame and invFrame:FindFirstChild("ItemList", true)
    if itemList then
        for _, btn in ipairs(itemList:GetChildren()) do
            if btn:IsA("GuiObject") and btn.Name ~= "UIGridLayout" then
                if btn.Name:upper():find(targetId) then
                    local numb = btn:FindFirstChild("Numb", true)
                    local rawText = (numb and numb:IsA("TextLabel")) and numb.Text or ""
                    local n = rawText:gsub("%s+", ""):match("^[xX]?(%d+)")
                    totalStock = totalStock + (parseCleanNumber(n) or 1)
                end
            end
        end
    end

    local toolbar = guiLobby and guiLobby:FindFirstChild("Toolbar")
    if toolbar then
        for slot = 1, 8 do
            local box = toolbar:FindFirstChild("Box" .. slot)
            if box then
                local numb = box:FindFirstChild("Numb")
                local rawText = (numb and numb:IsA("TextLabel")) and numb.Text or ""
                local n = rawText:gsub("%s+", ""):match("^[xX]?(%d+)")
                local slotCount = parseCleanNumber(n) or 0
                if slotCount > 0 then
                    local isMatched = false
                    for _, av in pairs(box:GetAttributes()) do
                        if tostring(av):upper():find(targetId) then isMatched = true; break end
                    end
                    if not isMatched then
                        if box.Name:upper():find(targetId) then
                            isMatched = true
                        else
                            for _, desc in ipairs(box:GetDescendants()) do
                                if checkDescendantMatches(desc, targetId, patterns) then isMatched = true; break end
                            end
                        end
                    end
                    if isMatched then totalStock = totalStock + slotCount end
                end
            end
        end
    end
    return totalStock
end

local function getObjectPosition(obj)
    if obj:IsA("BasePart") then return obj.Position
    elseif obj:IsA("Model") then
        local collide = obj:FindFirstChild("Collide", true)
        if collide and collide:IsA("BasePart") then return collide.Position end
        local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if pp then return pp.Position end
        local ok, piv = pcall(function() return obj:GetPivot().Position end)
        if ok and piv then return piv end
    end
    return Vector3.new(0, 0, 0)
end

local function getObjectHealth(obj)
    local hp = tonumber(obj:GetAttribute("Health"))
    local maxHp = tonumber(obj:GetAttribute("MaxHealth"))
    if hp and hp > 0 then return hp, (maxHp or hp) end

    -- Cek jika ada billboard health bar (BuildHealthBar atau HealthBar)
    local hb = obj:FindFirstChild("BuildHealthBar", true) or obj:FindFirstChild("HealthBar", true)
    if hb then
        for _, child in ipairs(hb:GetDescendants()) do
            if child:IsA("TextLabel") and child.Text ~= "" then
                local cur, total = child.Text:gsub(",", ""):match("(%d+)/(%d+)")
                if cur and total then
                    hp = tonumber(cur)
                    maxHp = tonumber(total)
                    if hp and hp > 0 then return hp, maxHp end
                end
            end
        end
    end

    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    return (hp or 100), (maxHp or hp or 100)
end

local function getMyBaseData()
    local mbFolder = Workspace:FindFirstChild("MilitaryBase") or Workspace:WaitForChild("MilitaryBase", 5)
    if not mbFolder then return nil end

    local myPlotName = localPlayer:GetAttribute("AssignedPlotName")
    local myName = localPlayer.Name:lower()
    local myDisplay = localPlayer.DisplayName and localPlayer.DisplayName:lower()
    local myUserIdStr = tostring(localPlayer.UserId)

    local myBaseCachedIndex = State.MyBaseCachedIndex

    for i = 1, 6 do
        local baseName = "MilitaryBase" .. tostring(i)
        local baseModel = mbFolder:FindFirstChild(baseName)
        if baseModel then
            local isMyBase = false
            if myBaseCachedIndex and myBaseCachedIndex == i then
                isMyBase = true
            end

            if not isMyBase and myPlotName and (myPlotName == baseName or myPlotName == baseModel.Name) then
                isMyBase = true
            end

            local ownerAttr = baseModel:GetAttribute("Owner") or baseModel:GetAttribute("Player") or baseModel:GetAttribute("OwnerName")
            if not isMyBase and ownerAttr then
                local oStr = tostring(ownerAttr):lower()
                if oStr == myName or oStr == myUserIdStr or (myDisplay and oStr == myDisplay) then
                    isMyBase = true
                end
            end

            local baseInfo = baseModel:FindFirstChild("BaseInfo", true)
            local shieldText = "No Shield / Inactive"
            if baseInfo then
                for _, desc in ipairs(baseInfo:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        local t = desc.Text
                        if t:find("Shield") then
                            shieldText = t
                        elseif not isMyBase then
                            local tLow = t:lower()
                            if tLow:find(myName, 1, true) or (myDisplay and tLow:find(myDisplay, 1, true)) then
                                isMyBase = true
                            end
                        end
                    end
                end
            end

            -- Cek PlacementOwnerUserId dari PlacedObjects jika atribut base belum sync
            local placed = baseModel:FindFirstChild("PlacedObjects")
            if not isMyBase and placed then
                for _, obj in ipairs(placed:GetChildren()) do
                    local pUid = tonumber(obj:GetAttribute("PlacementOwnerUserId"))
                    if pUid and pUid == localPlayer.UserId then
                        isMyBase = true
                        break
                    end
                end
            end

            if isMyBase then
                State.MyBaseCachedIndex = i

                local placed = baseModel:FindFirstChild("PlacedObjects")
                local pa = baseModel:FindFirstChild("PlacementArea")
                local rocketCount = 0
                local occupiedMap = {}

                if placed and pa and pa:IsA("BasePart") then
                    for _, obj in ipairs(placed:GetChildren()) do
                        local name = obj.Name
                        local kind = obj:GetAttribute("PlacementKind") or ""
                        if name:find("^Rocket_") or kind == "Rocket" then rocketCount = rocketCount + 1 end

                        local pp = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        local pos = pp and pp.Position or (obj:GetPivot() and obj:GetPivot().Position)

                        if pos then
                            local loc = pa.CFrame:PointToObjectSpace(pos)
                            local gx = math.floor((loc.X + pa.Size.X / 2) / 2 + 0.5)
                            local gz = math.floor((loc.Z + pa.Size.Z / 2) / 2 + 0.5)
                            local objW, objL = 2, 3
                            local isAlive = true

                            if name:find("^Build_") then
                                objW, objL = 10, 10
                                local hp = getObjectHealth(obj)
                                if hp and hp <= 0 then isAlive = false end
                            elseif name:find("^AntiAir_") then
                                objW, objL = 6, 6
                                local hp = getObjectHealth(obj)
                                if hp and hp <= 0 then isAlive = false end
                            end

                            -- Jika gedung sudah hancur (isAlive == false), lahannya bebas dan BISA diisi roket!
                            if isAlive then
                                table.insert(occupiedMap, { GX = gx, GZ = gz, W = objW, L = objL })
                            end
                        end
                    end
                end

                local maxRockets = State.Unlock150Missiles and 150 or 100
                if playerGui then
                    for _, d in ipairs(playerGui:GetDescendants()) do
                        if d:IsA("TextLabel") and d.Text ~= "" then
                            local scope = (d.Name .. " " .. (d.Parent and d.Parent.Name or "")):lower()
                            if scope:find("rocket") or scope:find("missile") then
                                local cur, maxVal = d.Text:gsub("%s+", " "):match("(%d+)%s*/%s*(%d+)")
                                if cur and maxVal then
                                    local parsedMax = tonumber(maxVal)
                                    if parsedMax and parsedMax > 0 then
                                        maxRockets = parsedMax
                                        if parsedMax >= 150 then State.Unlock150Missiles = true end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                if State.Unlock150Missiles and maxRockets < 150 then
                    maxRockets = 150
                end

                return {
                    Index = i,
                    Model = baseModel,
                    PlacementArea = pa,
                    PlacedFolder = placed,
                    CurrentRockets = rocketCount,
                    MaxRockets = maxRockets,
                    Occupied = occupiedMap,
                    ShieldText = shieldText
                }
            end
        end
    end
    return nil
end

local function scanPersonalInfo()
    local info = {
        PlayerName = localPlayer and localPlayer.Name or "Unknown",
        DisplayName = localPlayer and localPlayer.DisplayName or "Unknown",
        UserId = localPlayer and localPlayer.UserId or 0,
        Cash = nil,
        Income = nil,
        BaseSlot = "None",
        Shield = "Inactive",
        RocketsDeployed = 0,
        RocketsMax = 100,
        TotalMissilesStock = 0,
        MissilesBreakdown = {}
    }

    -- 1. Deteksi Cash & Income dari leaderstats, Data, atau Attributes pemain
    if localPlayer then
        local function checkFolder(f)
            if not f then return end
            for _, v in ipairs(f:GetChildren()) do
                local n = v.Name:lower()
                local val = v:IsA("ValueBase") and v.Value or nil
                if val ~= nil then
                    if (n:find("cash") or n:find("money") or n == "gold" or n == "coins" or n == "balance") and not info.Cash then
                        info.Cash = (type(val) == "number") and ("$" .. formatNumber(val)) or tostring(val)
                    elseif (n:find("income") or n:find("sec") or n:find("rate") or n:find("cps")) and not info.Income then
                        info.Income = (type(val) == "number") and ("$" .. formatNumber(val) .. "/s") or tostring(val)
                    end
                end
            end
        end
        checkFolder(localPlayer:FindFirstChild("leaderstats"))
        checkFolder(localPlayer:FindFirstChild("Data"))
        checkFolder(localPlayer:FindFirstChild("Stats"))
        checkFolder(localPlayer:FindFirstChild("PlayerData"))

        for k, v in pairs(localPlayer:GetAttributes()) do
            local n = k:lower()
            if (n:find("cash") or n:find("money") or n == "gold" or n == "coins") and not info.Cash then
                info.Cash = (type(v) == "number") and ("$" .. formatNumber(v)) or tostring(v)
            elseif (n:find("income") or n:find("sec") or n:find("rate")) and not info.Income then
                info.Income = (type(v) == "number") and ("$" .. formatNumber(v) .. "/s") or tostring(v)
            end
        end
    end

    -- 2. Fallback / Deteksi dari PlayerGui
    if playerGui then
        for _, d in ipairs(playerGui:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" then
                local t = d.Text:gsub("^%s+", ""):gsub("%s+$", "")
                local scope = (d.Name .. " " .. (d.Parent and d.Parent.Name or "")):lower()
                if not info.Income and (t:match("/%s*[sS]") or scope:find("income") or scope:find("persec")) then
                    info.Income = t
                elseif not info.Cash and t:match("^%$%s*[%d%.,]+%s*[kKmMbBtT]?$") and (scope:find("cash") or scope:find("money") or scope:find("top")) then
                    info.Cash = t
                end
            end
        end
    end

    info.Cash = info.Cash or "$0"
    info.Income = info.Income or "$0/s"

    local baseData = getMyBaseData()
    if baseData then
        info.BaseSlot = "Base " .. tostring(baseData.Index)
        info.RocketsDeployed = baseData.CurrentRockets
        info.RocketsMax = baseData.MaxRockets
        -- Deteksi Shield dari BaseInfo teks dan atribut
        local sTxt = baseData.ShieldText or ""
        local shieldActive = false
        local shieldDisplay = "Inactive"

        if sTxt ~= "" and not sTxt:lower():find("no shield") and not sTxt:lower():find("inactive") then
            shieldActive = true
            shieldDisplay = sTxt
        end

        local shieldExp = baseData.Model:GetAttribute("DefenseShieldExpiresAtServerTime")
        if shieldExp and tonumber(shieldExp) then
            local rem = tonumber(shieldExp) - Workspace:GetServerTimeNow()
            if rem > 0 then
                shieldActive = true
                local m = math.floor(rem / 60)
                local s = math.floor(rem % 60)
                shieldDisplay = string.format("Active (%02d:%02d)", m, s)
            end
        end

        info.Shield = shieldActive and shieldDisplay or "Inactive"
    end

    local totalStock = 0
    for _, m in ipairs(MISSILES) do
        local st = getMissileStock(m)
        if st > 0 then
            table.insert(info.MissilesBreakdown, { Name = m.Name, Id = m.Id, Count = st })
            totalStock = totalStock + st
        end
    end
    info.TotalMissilesStock = totalStock
    return info
end

-- ====================================================================================================
-- COMBAT TARGETING & IN-BASE UNITS
-- ====================================================================================================
local function scanSingleBase(baseModel, index)
    local ownerName = "Kosong"
    local teamName = nil
    local isLocal = false
    local ownerUserId = nil
    local baseInfo = baseModel:FindFirstChild("BaseInfo", true)
    
    if baseInfo then
        local allTexts = {}
        for _, desc in ipairs(baseInfo:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                local t = desc.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if not t:find("Shield") and not t:find("Base") and not t:find(":") and #t >= 2 then
                    table.insert(allTexts, { Text = t, LabelName = desc.Name:lower(), Label = desc })
                end
            end
        end

        -- 1. Deteksi Pemain yang Valid dari Players:GetPlayers()
        local matchedPlayer = nil
        for _, item in ipairs(allTexts) do
            local t = item.Text
            for _, p in ipairs(Players:GetPlayers()) do
                local pName = p.Name:lower()
                local pDisp = p.DisplayName:lower()
                local tLow = t:lower()
                if pName == tLow or pDisp == tLow or tLow:find(pName, 1, true) or tLow:find(pDisp, 1, true) then
                    matchedPlayer = p
                    ownerName = p.DisplayName
                    ownerUserId = p.UserId
                    break
                end
            end
            if matchedPlayer then break end
        end

        -- 2. Deteksi Nama Tim (Bisa apa saja: 'TEAM-DAXX', 'Arrogancy', dsb)
        for _, item in ipairs(allTexts) do
            local t = item.Text
            local isPlayerName = matchedPlayer and (t:lower() == matchedPlayer.Name:lower() or t:lower() == matchedPlayer.DisplayName:lower())
            if not isPlayerName then
                -- Cek apakah teks ini cocok dengan Tim Roblox dari pemain manapun
                local isKnownTeam = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Team and p.Team.Name:lower() == t:lower() then
                        isKnownTeam = true
                        break
                    end
                end
                if isKnownTeam or item.LabelName:find("team") or t:find("^TEAM%-") or t:find("^Team") then
                    teamName = t
                elseif not teamName and t ~= ownerName then
                    teamName = t
                end
            end
        end

        -- 3. Jika belum ada matchedPlayer, coba fallback ke teks yang bukan teamName
        if not matchedPlayer and #allTexts > 0 then
            for _, item in ipairs(allTexts) do
                if item.Text ~= teamName then
                    ownerName = item.Text
                    break
                end
            end
            if ownerName == "Kosong" and teamName then ownerName = teamName end
        end

        if localPlayer and (ownerName:lower():find(localPlayer.Name:lower(), 1, true) or ownerName:lower():find(localPlayer.DisplayName:lower(), 1, true)) then
            isLocal = true
            ownerUserId = localPlayer.UserId
        end
    end

    -- 4. Deteksi Pemilik dari AssignedPlotName pemain atau atribut base (Sangat berguna saat autoexecute)
    local myAssigned = localPlayer and localPlayer:GetAttribute("AssignedPlotName")
    if myAssigned and (myAssigned == ("MilitaryBase" .. tostring(index)) or (baseModel and myAssigned == baseModel.Name)) then
        isLocal = true
        ownerName = localPlayer.DisplayName or localPlayer.Name
        ownerUserId = localPlayer.UserId
    else
        for _, p in ipairs(Players:GetPlayers()) do
            local pPlot = p:GetAttribute("AssignedPlotName")
            if pPlot and (pPlot == ("MilitaryBase" .. tostring(index)) or (baseModel and pPlot == baseModel.Name)) then
                ownerName = p.DisplayName or p.Name
                ownerUserId = p.UserId
                if p == localPlayer then isLocal = true end
                break
            end
        end
    end

    local ownerAttr = baseModel:GetAttribute("Owner") or baseModel:GetAttribute("Player") or baseModel:GetAttribute("OwnerName")
    if ownerAttr and ownerName == "Kosong" then
        ownerName = tostring(ownerAttr)
        if localPlayer and (ownerName == localPlayer.Name or ownerName == tostring(localPlayer.UserId)) then
            isLocal = true
            ownerUserId = localPlayer.UserId
        end
    end

    local hasShield = false
    local shieldText = "No Shield"
    if baseInfo then
        for _, desc in ipairs(baseInfo:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" and desc.Text:find("Shield") then
                local txt = desc.Text
                local min, sec = txt:match("(%d+):(%d+)")
                if min and sec then
                    local totalSec = (tonumber(min) or 0) * 60 + (tonumber(sec) or 0)
                    if totalSec > 0 then
                        hasShield = true
                        shieldText = string.format("%02d:%02d", tonumber(min) or 0, tonumber(sec) or 0)
                    else
                        shieldText = "00:00 (Habis)"
                    end
                elseif not txt:lower():find("no shield") and not txt:lower():find("inactive") and not txt:lower():find("00:00") then
                    hasShield = true
                    shieldText = txt
                end
            end
        end
    end
    local shieldExp = baseModel:GetAttribute("DefenseShieldExpiresAtServerTime")
    if shieldExp and tonumber(shieldExp) then
        local rem = tonumber(shieldExp) - Workspace:GetServerTimeNow()
        if rem > 0 then
            hasShield = true
            shieldText = string.format("%02d:%02d", math.floor(rem / 60), math.floor(rem % 60))
        end
    end

    local basePos = BASE_COORDINATES[index] or (baseModel:GetPivot() and baseModel:GetPivot().Position) or Vector3.new(0, 0, 0)

    local baseData = {
        Index = index,
        Model = baseModel,
        ModelName = "MilitaryBase" .. tostring(index),
        Owner = ownerName,
        Team = teamName,
        OwnerUserId = ownerUserId,
        IsLocal = isLocal,
        Position = basePos,
        HasShield = hasShield,
        ShieldText = shieldText,
        Buildings = {},
        AntiAir = {},
        AntiShip = {},
        Rockets = {},
        TotalTargets = 0
    }

    local placed = baseModel:FindFirstChild("PlacedObjects")
    if placed then
        for _, obj in ipairs(placed:GetChildren()) do
            local kind = obj:GetAttribute("PlacementKind") or ""
            local name = obj.Name
            local hp, maxHp = getObjectHealth(obj)
            local pos = getObjectPosition(obj)
            local uid = tonumber(obj:GetAttribute("PlacementUid")) or tonumber(name:match("%d+$")) or 0
            local itemId = obj:GetAttribute("PlacementItemId") or name:match("^[A-Za-z]+_([A-Za-z0-9]+)_%d+$") or ""

            -- Ekstrak UserId pemilik asli dari objek jika belum ditemukan
            if not baseData.OwnerUserId then
                local pUid = tonumber(obj:GetAttribute("PlacementOwnerUserId"))
                if pUid and pUid > 0 then
                    baseData.OwnerUserId = pUid
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.UserId == pUid then
                            baseData.Owner = p.DisplayName
                            if localPlayer and p == localPlayer then baseData.IsLocal = true end
                            break
                        end
                    end
                end
            end

            local entry = { Instance = obj, Name = name, ItemId = itemId, Kind = kind, Uid = uid, HP = hp, MaxHP = maxHp, Position = pos }

            if kind == "Build" or name:find("^Build_") then
                local bLv = tonumber(obj:GetAttribute("PlacementLevel")) or tonumber(obj:GetAttribute("BuildLevel")) or tonumber(obj:GetAttribute("Level"))
                if not bLv or bLv <= 0 then
                    local digits = tostring(itemId or ""):match("(%d+)$")
                    bLv = digits and tonumber(digits) or nil
                end
                if not bLv or bLv <= 0 then
                    local fromName = tostring(name or ""):match("^Build_[A-Za-z]*(%d+)_%d+$")
                    bLv = fromName and tonumber(fromName) or 0
                end
                entry.Level = math.floor(tonumber(bLv) or 0)
                table.insert(baseData.Buildings, entry)
                if hp > 0 then baseData.TotalTargets = baseData.TotalTargets + 1 end
            elseif kind == "AntiAir" or name:find("^AntiAir_") then
                table.insert(baseData.AntiAir, entry)
                if hp > 0 then baseData.TotalTargets = baseData.TotalTargets + 1 end
            elseif kind == "AntiShip" or name:find("^AntiShip_") then
                table.insert(baseData.AntiShip, entry)
                if hp > 0 then baseData.TotalTargets = baseData.TotalTargets + 1 end
            elseif kind == "Rocket" or name:find("^Rocket_") then
                table.insert(baseData.Rockets, entry)
            end
        end
    end
    return baseData
end

-- ====================================================================================================
-- CACHED SCANNERS UNTUK MENGHEMAT RAM (Mencegah Table Churning & Garbage Collection Spike)
-- ====================================================================================================
local _cachedAllBases = nil
local _lastBaseScanTime = 0

local function scanAllBases(forceRefresh)
    local now = tick()
    if not forceRefresh and _cachedAllBases and (now - _lastBaseScanTime < 0.5) then
        return _cachedAllBases
    end

    local list = {}
    local mb = Workspace:FindFirstChild("MilitaryBase")
    if not mb then return list end
    for i = 1, 6 do
        local b = mb:FindFirstChild("MilitaryBase" .. i)
        if b then table.insert(list, scanSingleBase(b, i)) end
    end
    _cachedAllBases = list
    _lastBaseScanTime = now
    return list
end

local function getBaseShieldRemaining(baseModel)
    if not baseModel then return 0 end
    local shieldExp = tonumber(baseModel:GetAttribute("DefenseShieldExpiresAtServerTime"))
    if shieldExp then
        local rem = shieldExp - Workspace:GetServerTimeNow()
        return math.max(0, rem)
    end
    return 0
end

local function scanTargetBaseOnly(index)
    local mb = Workspace:FindFirstChild("MilitaryBase")
    if not mb then return nil end
    local b = mb:FindFirstChild("MilitaryBase" .. tostring(index))
    if b then return scanSingleBase(b, index) end
    return nil
end



local _cachedPlacedRockets = nil
local _lastRocketScanTime = 0
local _RecentlyLaunchedUids = {} -- [uid] = expireTick

local function markRocketLaunched(uid)
    if uid then
        _RecentlyLaunchedUids[uid] = tick() + 3.0 -- Dianggap sedang meluncur selama 3 detik
    end
end

local function getMyPlacedRockets(forceRefresh)
    local now = tick()
    if not forceRefresh and _cachedPlacedRockets and (now - _lastRocketScanTime < 0.5) then
        -- Filter roket yang baru saja ditembakkan secara cepat di memori (O(N) in-memory, tanpa scan 3D)
        local filtered = {}
        for _, r in ipairs(_cachedPlacedRockets) do
            local exp = _RecentlyLaunchedUids[r.Uid]
            if not exp or now > exp then
                table.insert(filtered, r)
            end
        end
        return filtered
    end

    local available = {}
    local baseData = getMyBaseData()
    if not baseData or not baseData.PlacedFolder then return available end

    -- Prune berkala agar tabel _RecentlyLaunchedUids tidak menumpuk saat AFK berjam-jam
    for u, exp in pairs(_RecentlyLaunchedUids) do
        if now > exp then
            _RecentlyLaunchedUids[u] = nil
        end
    end

    for _, obj in ipairs(baseData.PlacedFolder:GetChildren()) do
        local kind = obj:GetAttribute("PlacementKind") or ""
        local name = obj.Name
        if kind == "Rocket" or name:find("^Rocket_") then
            local hp = tonumber(obj:GetAttribute("Health")) or 1
            if hp > 0 then
                local uid = tonumber(obj:GetAttribute("PlacementUid")) or tonumber(name:match("%d+$"))
                local itemId = obj:GetAttribute("PlacementItemId") or name:match("Rocket_([A-Za-z0-9]+)_%d+") or "RT0001"
                local exp = uid and _RecentlyLaunchedUids[uid]
                if uid and (not exp or now > exp) then
                    local okPiv, pPos = pcall(function() return obj:GetPivot().Position end)
                    local pos = (okPiv and pPos) or (obj.PrimaryPart and obj.PrimaryPart.Position) or Vector3.new(0, 0, 0)
                    table.insert(available, {
                        Instance = obj,
                        Uid = uid,
                        ItemId = itemId,
                        Position = pos,
                        Spec = MISSILE_BY_ID[itemId] or { Name = "Standard", DMG = 100, Speed = 85 }
                    })
                end
            end
        end
    end
    _cachedPlacedRockets = available
    _lastRocketScanTime = now
    return available
end

local function getMyPlacedWarships()
    local allShips = {}
    local baseData = getMyBaseData()
    if not baseData or not baseData.Model then return allShips end

    local seenUids = {}

    local function inspectObj(obj)
        if not obj or not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
        local kind = tostring(obj:GetAttribute("PlacementKind") or "")
        local name = obj.Name
        local nameLower = name:lower()

        local isWs = (kind == "Warship" or kind == "Ship" or kind == "WS")
            or name:find("^Warship") or name:find("^Ship") or name:find("^WS")
            or nameLower:find("specter") or nameLower:find("viper") or nameLower:find("devastator")
            or nameLower:find("aegis") or nameLower:find("talon") or nameLower:find("obsidian")
            or nameLower:find("kraken") or nameLower:find("nautilus") or nameLower:find("leviathan")

        if isWs then
            local uid = tonumber(obj:GetAttribute("PlacementUid")) or tonumber(name:match("%d+$"))
            if uid and not seenUids[uid] then
                seenUids[uid] = true

                -- 1. Baca HP & Max HP
                local hp = tonumber(obj:GetAttribute("WarshipHealth")) or tonumber(obj:GetAttribute("Health"))
                local maxHp = tonumber(obj:GetAttribute("WarshipMaxHealth")) or tonumber(obj:GetAttribute("MaxHealth"))
                if not hp or hp <= 0 then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hp = hum.Health
                        maxHp = maxHp or hum.MaxHealth
                    else
                        hp = 1
                    end
                end
                maxHp = maxHp or hp or 10000
                local hpPercent = math.floor((hp / math.max(1, maxHp)) * 100)

                -- 2. Baca Peluru (Bullets) & Roket Kapal
                local bullets = tonumber(obj:GetAttribute("WarshipBulletsRemaining"))
                local totalBullets = tonumber(obj:GetAttribute("WarshipBulletTotal")) or 0
                local rocketBullets = tonumber(obj:GetAttribute("WarshipRocketBulletsRemaining"))
                local totalRocketBullets = tonumber(obj:GetAttribute("WarshipRocketBulletTotal")) or 0

                -- 3. Baca Laser Energy & Depletion
                local laserRatio = tonumber(obj:GetAttribute("WarshipLaserEnergyRatio")) or 1
                local laserDepleted = (obj:GetAttribute("WarshipLaserEnergyDepleted") == true)
                local laserEnergy = tonumber(obj:GetAttribute("WarshipLaserEnergy")) or 0

                -- 4. Status Placement & Repair
                local wsState = tostring(obj:GetAttribute("WarshipState") or "Placed")
                local isRepairing = (obj:GetAttribute("IsRepairing") == true)

                -- 5. Cek apakah kapal sedang berlayar / ON MISSION
                local parentName = obj.Parent and obj.Parent.Name or ""
                local isOnMission = (parentName == "WarshipFlights") or (wsState:lower() == "flight") or (wsState:lower() == "mission")

                -- 6. Item ID & Specs
                local itemId = obj:GetAttribute("PlacementItemId") or name:match("([A-Za-z]+%d+)")
                if not itemId or itemId == "" then
                    if nameLower:find("specter") then itemId = "WS1001"
                    elseif nameLower:find("viper") then itemId = "WS1002"
                    elseif nameLower:find("devastator") then itemId = "WS1003"
                    elseif nameLower:find("aegis") then itemId = "WS2001"
                    elseif nameLower:find("talon") then itemId = "WS2002"
                    elseif nameLower:find("obsidian") then itemId = "WS3001"
                    else itemId = "WS1001" end
                end

                local spec = WARSHIP_SPECS[itemId] or { Name = "Warship (" .. itemId .. ")", DPS = 200, HP = 15000 }

                -- 7. EVALUASI KESIAPAN 100% (HP Penuh, Peluru Penuh, Energy Penuh, Berada di Dermaga Base)
                local isHpFull = (hp >= maxHp) or (hpPercent >= 100)
                local isBulletFull = true
                if totalBullets > 0 then
                    isBulletFull = (bullets ~= nil) and (bullets >= totalBullets)
                end
                local isRocketFull = true
                if totalRocketBullets > 0 then
                    isRocketFull = (rocketBullets ~= nil) and (rocketBullets >= totalRocketBullets)
                end
                local isLaserFull = not laserDepleted and (laserRatio >= 0.99)

                -- Kapal BENAR-BENAR SIAP hanya jika:
                -- - Tidak sedang ON MISSION (ada di dock pangkalan)
                -- - HP 100% penuh
                -- - Peluru 100% penuh
                -- - Roket 100% penuh (jika kapal tipe pembawa roket)
                -- - Laser energy 100% penuh (tidak depleted)
                -- - Tidak sedang dalam antrean repair atau proses isi peluru
                local isReady = (not isOnMission)
                    and (not isRepairing)
                    and isHpFull
                    and isBulletFull
                    and isRocketFull
                    and isLaserFull

                local statusDesc = "Siap Tempur"
                if isOnMission then
                    statusDesc = "On Mission (Menyerang)"
                elseif not isHpFull then
                    statusDesc = string.format("Repair HP (%d/%d)", hp, maxHp)
                elseif not isBulletFull then
                    statusDesc = string.format("Isi Peluru (%d/%d)", bullets or 0, totalBullets)
                elseif not isLaserFull then
                    statusDesc = "Isi Laser Energy"
                elseif isRepairing then
                    statusDesc = "Menunggu/Sedang Repair"
                end

                table.insert(allShips, {
                    Instance = obj,
                    Uid = uid,
                    ItemId = itemId,
                    HP = hp,
                    MaxHP = maxHp,
                    HPPercent = hpPercent,
                    Bullets = bullets or totalBullets,
                    TotalBullets = totalBullets,
                    RocketBullets = rocketBullets or totalRocketBullets,
                    TotalRocketBullets = totalRocketBullets,
                    LaserRatio = laserRatio,
                    LaserDepleted = laserDepleted,
                    IsRepairing = isRepairing,
                    IsOnMission = isOnMission,
                    IsReady = isReady,
                    StatusDesc = statusDesc,
                    Spec = spec
                })
            end
        end
    end

    if baseData.PlacedFolder then
        for _, obj in ipairs(baseData.PlacedFolder:GetChildren()) do
            inspectObj(obj)
        end
    end

    for _, obj in ipairs(baseData.Model:GetChildren()) do
        if obj ~= baseData.PlacedFolder and (obj.Name:find("Ship") or obj.Name:find("Dock") or obj.Name:find("Water") or obj.Name:find("WS") or obj:IsA("Folder") or obj:IsA("Model")) then
            inspectObj(obj)
            if obj:IsA("Folder") or obj:IsA("Model") then
                for _, sub in ipairs(obj:GetChildren()) do
                    inspectObj(sub)
                end
            end
        end
    end

    return allShips
end

-- ====================================================================================================
-- TRANSACTION & DEPLOY EXECUTION
-- ====================================================================================================
local function executeBuy(missile, quantity)
    if not Remotes.MilitaryStore then logMessage("MilitaryStoreRequest remote tidak ditemukan!"); return false end
    local q = math.max(1, tonumber(quantity) or 1)

    local n5 = math.floor(q / 5)
    local n1 = q % 5

    local payloadX5 = {
        Category = "Rockets",
        ItemId = missile.Id,
        BuyAmount = 5,
        ButtonName = "BtnBuy5",
        PriceKind = "Cash",
        Amount = 5,
        Count = 5,
        MilitaryStoreCategory = "Rockets",
        MilitaryStoreItemId = missile.Id,
        MilitaryStoreButtonName = "BtnBuy5",
        MilitaryStorePriceKind = "Cash"
    }

    local payloadX1 = {
        Category = "Rockets",
        ItemId = missile.Id,
        BuyAmount = 1,
        ButtonName = "BtnBuy1",
        PriceKind = "Cash",
        Amount = 1,
        Count = 1,
        MilitaryStoreCategory = "Rockets",
        MilitaryStoreItemId = missile.Id,
        MilitaryStoreButtonName = "BtnBuy1",
        MilitaryStorePriceKind = "Cash"
    }

    logMessage(string.format("🛒 Membeli %s total %d unit (%d kali X5, %d kali X1)...", missile.Name, q, n5, n1))

    task.spawn(function()
        -- Eksekusi batch X5
        for i = 1, n5 do
            pcall(function() Remotes.MilitaryStore:FireServer("Buy", payloadX5) end)
            task.wait(0.08)
        end
        -- Eksekusi sisa batch X1
        for i = 1, n1 do
            pcall(function() Remotes.MilitaryStore:FireServer("Buy", payloadX1) end)
            task.wait(0.08)
        end
        logMessage(string.format("✅ Pembelian %s x%d selesai dikirim (%d x X5 + %d x X1)!", missile.Name, q, n5, n1))
        showToast("Beli Sukses", string.format("Membeli %s x%d (%d x X5 + %d x X1)", missile.Name, q, n5, n1), "success")
    end)

    return true
end

-- Dynamic Blacklist Cooldown (Mencegah spam error jika suatu titik ditolak server, namun otomatis reset saat ada roket berkurang/ditembakkan)
local _DeployFailedSpots = {} -- [ "gx_gz" ] = expireTick

local function isSpotBlacklisted(gx, gz)
    local key = gx .. "_" .. gz
    local exp = _DeployFailedSpots[key]
    if exp and tick() < exp then
        return true
    end
    if exp then _DeployFailedSpots[key] = nil end
    return false
end

local function markSpotFailed(gx, gz)
    local key = gx .. "_" .. gz
    local dur = math.max(1, State.DeployBlacklistDuration or 7)
    _DeployFailedSpots[key] = tick() + dur -- Lewati sesuai durasi setting (default 7 detik)
end

local function clearDeployBlacklist()
    _DeployFailedSpots = {}
end

-- Toggle Auto Deploy terpusat agar tombol di GUI Utama & GUI Attack Mode selalu sinkron
local function toggleAutoDeploy(enable)
    if enable == nil then enable = not State.AutoDeployActive end
    State.AutoDeployActive = enable

    if State.UI and State.UI.AutoDeployButtons then
        for _, btn in pairs(State.UI.AutoDeployButtons) do
            if btn and btn.Parent then
                btn.BackgroundColor3 = enable and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(38, 48, 70)
                btn.Text = enable and "🔄 Auto Deploy: ON" or "🔄 Auto Deploy: OFF"
            end
        end
    end
    if enable then
        clearDeployBlacklist()
        showToast("Auto Deploy", "Auto Deploy AKTIF (Blacklist cooldown: " .. (State.DeployBlacklistDuration or 7) .. "s)", "success")
    else
        showToast("Auto Deploy", "Auto Deploy DINONAKTIFKAN", "warn")
    end
    return enable
end

local function toggleUnlock150(enable)
    if enable == nil then enable = not State.Unlock150Missiles end
    State.Unlock150Missiles = enable

    if State.UI and State.UI.Unlock150Buttons then
        for _, btn in pairs(State.UI.Unlock150Buttons) do
            if btn and btn.Parent then
                btn.BackgroundColor3 = enable and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(60, 35, 45)
                local isShort = btn:GetAttribute("IsShort")
                btn.Text = enable and (isShort and "🔓 150: ON" or "🔓 Unlock 150: ON") or (isShort and "🔒 150: OFF" or "🔒 Unlock 150: OFF")
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = enable and Color3.fromRGB(0, 220, 140) or Color3.fromRGB(120, 50, 60)
                end
            end
        end
    end

    if enable then
        showToast("Unlock 150 Aktif", "Batas maksimal deploy base ditingkatkan menjadi 150 misil!", "success")
    else
        showToast("Unlock 150 Nonaktif", "Batas maksimal deploy base kembali ke standar (100 misil)", "info")
    end
    return enable
end

local function toggleUnlockX10(enable)
    if enable == nil then enable = not State.UnlockX10 end
    State.UnlockX10 = enable

    if State.UI and State.UI.UnlockX10Buttons then
        for _, btn in pairs(State.UI.UnlockX10Buttons) do
            if btn and btn.Parent then
                btn.BackgroundColor3 = enable and Color3.fromRGB(0, 150, 90) or Color3.fromRGB(70, 30, 35)
                btn.Text = enable and "🔓 X10: ON" or "🔒 X10: OFF"
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = enable and Color3.fromRGB(0, 220, 140) or Color3.fromRGB(120, 50, 60)
                end
            end
        end
    end

    if enable then
        showToast("X10 Diaktifkan", "Peluncuran akan memprioritaskan batch X10", "success")
    else
        if State.ManualLaunchVolley == 10 then
            State.ManualLaunchVolley = 5
            if State.UI and State.UI.RefreshVolleyColors then
                State.UI.RefreshVolleyColors()
            end
        end
        showToast("X10 Dimatikan", "Peluncuran aman menggunakan batch X5 dan X1", "info")
    end
    return enable
end

local function generatePlacementGrid(baseData, missileItem, countNeeded, positionMode, alignMode)
    local pa = baseData.PlacementArea
    if not pa or not pa:IsA("BasePart") then return {} end

    local areaGridX = math.floor(pa.Size.X / 2)
    local areaGridZ = math.floor(pa.Size.Z / 2)
    local fp = missileItem.Footprint or { W = 2, L = 3 }
    local w, l = fp.W, fp.L

    local minX, maxX = 10, areaGridX - w - 10
    local minZ, maxZ = 10, areaGridZ - l - 10

    local candidates = {}
    local occ = {}
    for _, o in ipairs(baseData.Occupied or {}) do
        table.insert(occ, { GX = o.GX, GZ = o.GZ, W = o.W or 2, L = o.L or 3, IsStatic = true })
    end

    local function isOverlapping(gx, gz)
        if isSpotBlacklisted(gx, gz) then return true end
        for _, o in ipairs(occ) do
            local safePad = o.IsStatic and 1 or 0
            local noOverlap = (gx + w + safePad <= o.GX) or (gx >= o.GX + o.W + safePad) or
                              (gz + l + safePad <= o.GZ) or (gz >= o.GZ + o.L + safePad)
            if not noOverlap then return true end
        end
        return false
    end

    -- Cache Static Slots Khusus Mode "Rapi" (Hanya digenerate 1 kali per missile/area)
    local _StaticRapiSlotsCache = _G._WW3_StaticRapiSlotsCache or {}
    _G._WW3_StaticRapiSlotsCache = _StaticRapiSlotsCache

    -- Mode Khusus "Rapi" (Ultra Fast O(1) Pre-Generated Slot Matrix untuk AMG-86 & Militia III)
    if positionMode == "Rapi" then
        local isMilitia = (missileItem.Id == "RT2001")
        local cacheKey = (isMilitia and "RT2001_" or "RT1006_") .. tostring(areaGridX) .. "_" .. tostring(areaGridZ)
        local staticSlots = _StaticRapiSlotsCache[cacheKey]

        if not staticSlots then
            staticSlots = {}
            local rowStartX = isMilitia and 20 or 19  -- AMG-86: 19, Militia III: 20
            local deltaX = isMilitia and 20 or 19     -- Jarak antar baris
            local stepZ = isMilitia and 8 or 6        -- AMG-86: terpaut 6, Militia: terpaut 8
            local fpW = 8
            local fpZ = isMilitia and 8 or 6
            local maxZBound = areaGridZ - fpZ

            -- Baris 1: X=1, Baris 2: X=rowStartX, Baris 3: X=rowStartX + deltaX, dst.
            local rowList = { 1 }
            for rx = rowStartX, areaGridX - fpW, deltaX do
                table.insert(rowList, rx)
            end

            for _, rx in ipairs(rowList) do
                for gz = 0, maxZBound, stepZ do
                    table.insert(staticSlots, { OriginX = rx, OriginZ = gz, RotationY = 0, RowX = rx })
                end
            end
            _StaticRapiSlotsCache[cacheKey] = staticSlots
        end

        -- Kumpulkan Hash Set roket & obstacle yang saat ini berdiri di base (O(N) sekali jalan)
        local occupiedSpots = {}
        local rowLiveCount = {}
        local placedFolder = baseData.PlacedFolder
        if placedFolder then
            for _, obj in ipairs(placedFolder:GetChildren()) do
                local hp = tonumber(obj:GetAttribute("Health")) or 1
                if hp > 0 then
                    local ox = tonumber(obj:GetAttribute("PlacementOriginX"))
                    local oz = tonumber(obj:GetAttribute("PlacementOriginZ"))
                    if not ox or not oz then
                        local pp = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        local pos = pp and pp.Position or (obj:GetPivot() and obj:GetPivot().Position)
                        if pos then
                            local loc = pa.CFrame:PointToObjectSpace(pos)
                            ox = math.floor((loc.X + pa.Size.X / 2) / 2 + 0.5)
                            oz = math.floor((loc.Z + pa.Size.Z / 2) / 2 + 0.5)
                        end
                    end
                    if ox and oz then
                        local key = ox .. "_" .. oz
                        occupiedSpots[key] = true
                        rowLiveCount[ox] = (rowLiveCount[ox] or 0) + 1
                    end
                end
            end
        end

        -- Masukkan juga bangunan / obstacle static dari baseData.Occupied
        for _, o in ipairs(baseData.Occupied or {}) do
            occupiedSpots[o.GX .. "_" .. o.GZ] = true
        end

        -- Langkah 1: Isi baris yang BENAR-BENAR KOSONG terlebih dahulu (Skip baris yang masih ada misil aktif)
        for _, slot in ipairs(staticSlots) do
            local rx = slot.RowX
            if (rowLiveCount[rx] or 0) == 0 then
                local key = slot.OriginX .. "_" .. slot.OriginZ
                if not occupiedSpots[key] and not isSpotBlacklisted(slot.OriginX, slot.OriginZ) then
                    table.insert(candidates, { OriginX = slot.OriginX, OriginZ = slot.OriginZ, RotationY = 0 })
                    occupiedSpots[key] = true
                    if #candidates >= (countNeeded + 50) then return candidates end
                end
            end
        end

        -- Langkah 2: Jika baris kosong habis, isi slot sisa yang kosong di baris-baris lainnya
        for _, slot in ipairs(staticSlots) do
            local key = slot.OriginX .. "_" .. slot.OriginZ
            if not occupiedSpots[key] and not isSpotBlacklisted(slot.OriginX, slot.OriginZ) then
                table.insert(candidates, { OriginX = slot.OriginX, OriginZ = slot.OriginZ, RotationY = 0 })
                occupiedSpots[key] = true
                if #candidates >= (countNeeded + 50) then return candidates end
            end
        end

        return candidates
    end

    local stepX, stepZ = w, l
    local zStart, zEnd, zStep
    if positionMode == "Depan" then
        -- Depan (Bibir pantai / arah laut): OriginZ bernilai kecil (dimulai dari minZ)
        zStart, zEnd, zStep = minZ, maxZ, stepZ
    elseif positionMode == "Belakang" then
        -- Belakang (Pangkal base / daratan): OriginZ bernilai besar (dimulai dari maxZ)
        zStart, zEnd, zStep = maxZ, minZ, -stepZ
    else
        local midZ = math.floor((minZ + maxZ) / (2 * stepZ)) * stepZ
        zStart, zEnd, zStep = midZ, maxZ, stepZ
    end

    -- Fase 1: Penataan posisi
    if positionMode == "Random" or positionMode == "Acak" then
        -- Kumpulkan seluruh kandidat grid valid tanpa peduli urutan vertikal/horizontal, lalu acak secara acak total (Fisher-Yates)
        local allValidCells = {}
        for gz = minZ, maxZ, stepZ do
            for gx = minX, maxX, stepX do
                table.insert(allValidCells, { OriginX = gx, OriginZ = gz, RotationY = 0 })
            end
        end
        -- Fisher-Yates shuffle
        for i = #allValidCells, 2, -1 do
            local j = math.random(1, i)
            allValidCells[i], allValidCells[j] = allValidCells[j], allValidCells[i]
        end
        for _, cell in ipairs(allValidCells) do
            if not isOverlapping(cell.OriginX, cell.OriginZ) then
                table.insert(candidates, cell)
                table.insert(occ, { GX = cell.OriginX, GZ = cell.OriginZ, W = w, L = l, IsStatic = false })
                if #candidates >= (countNeeded + 300) then return candidates end
            end
        end
    elseif alignMode == "Horizontal" then
        -- Horizontal: Menjalar di sumbu Z terlebih dahulu (gx terluar, gz di dalam)
        for gx = minX, maxX, stepX do
            for gz = zStart, zEnd, zStep do
                if not isOverlapping(gx, gz) then
                    table.insert(candidates, { OriginX = gx, OriginZ = gz, RotationY = 0 })
                    table.insert(occ, { GX = gx, GZ = gz, W = w, L = l, IsStatic = false })
                    if #candidates >= (countNeeded + 300) then return candidates end
                end
            end
        end
    else
        -- Vertikal: Menjalar di sumbu X terlebih dahulu (gz terluar, gx di dalam)
        for gz = zStart, zEnd, zStep do
            for gx = minX, maxX, stepX do
                if not isOverlapping(gx, gz) then
                    table.insert(candidates, { OriginX = gx, OriginZ = gz, RotationY = 0 })
                    table.insert(occ, { GX = gx, GZ = gz, W = w, L = l, IsStatic = false })
                    if #candidates >= (countNeeded + 300) then return candidates end
                end
            end
        end
    end

    -- Fase 2: ADAPTIVE AUTO-FILL (Penyapu Celah Sempit)
    -- Jika kandidat masih kurang (misal stuck di 97/100), pindai sisa pulau dengan step halus per 1 stud
    -- Mengikuti arah preferensi zStart -> zEnd sesuai posisi yang dipilih
    if #candidates < countNeeded then
        local fillZStart = (positionMode == "Depan") and minZ or maxZ
        local fillZEnd   = (positionMode == "Depan") and maxZ or minZ
        local fillZStep  = (positionMode == "Depan") and 1 or -1

        if alignMode == "Horizontal" then
            for gx = minX, maxX, 1 do
                for gz = fillZStart, fillZEnd, fillZStep do
                    if not isOverlapping(gx, gz) then
                        table.insert(candidates, { OriginX = gx, OriginZ = gz, RotationY = 0 })
                        table.insert(occ, { GX = gx, GZ = gz, W = w, L = l, IsStatic = false })
                        if #candidates >= (countNeeded + 100) then return candidates end
                    end
                end
            end
        else
            for gz = fillZStart, fillZEnd, fillZStep do
                for gx = minX, maxX, 1 do
                    if not isOverlapping(gx, gz) then
                        table.insert(candidates, { OriginX = gx, OriginZ = gz, RotationY = 0 })
                        table.insert(occ, { GX = gx, GZ = gz, W = w, L = l, IsStatic = false })
                        if #candidates >= (countNeeded + 100) then return candidates end
                    end
                end
            end
        end
    end

    return candidates
end

local function executeDeployVerified(baseData, missileItem, targetCount, positionMode, alignMode, speedMode)
    local placedFolder = baseData.PlacedFolder
    if not placedFolder or not Remotes.Placement then return 0 end
    local candidates = generatePlacementGrid(baseData, missileItem, targetCount, positionMode, alignMode)
    if #candidates == 0 then logMessage("Slot grid base penuh!"); return 0 end

    local function countLiveRockets()
        local cnt = 0
        for _, obj in ipairs(placedFolder:GetChildren()) do
            if obj.Name:find("^Rocket_") or obj:GetAttribute("PlacementKind") == "Rocket" then
                cnt = cnt + 1
            end
        end
        return cnt
    end

    local startCount = countLiveRockets()
    local successCount = 0
    local candIdx = 1

    local spd = speedMode or State.DeploySpeed or "Ultra"
    local delayTime = 0.008
    local batchSize = 2

    if spd == "Normal" then
        delayTime = 0.03
        batchSize = 1
    elseif spd == "Turbo" then
        delayTime = 0.008
        batchSize = 3
    elseif spd == "Ultra" then
        delayTime = 0.004
        batchSize = 6
    end

    local prevLive = startCount
    local stagnantAttempts = 0

    while successCount < targetCount and candIdx <= #candidates do
        local sentSpots = {}
        for b = 1, batchSize do
            if candIdx <= #candidates and (successCount + (b - 1)) < targetCount then
                local spot = candidates[candIdx]
                candIdx = candIdx + 1
                table.insert(sentSpots, spot)

                pcall(function()
                    Remotes.Placement:FireServer("PlaceRocket", {
                        ItemId = missileItem.Id,
                        OriginX = spot.OriginX,
                        OriginZ = spot.OriginZ,
                        RotationY = spot.RotationY or 0
                    })
                end)
            end
        end

        task.wait(delayTime)

        local afterCount = countLiveRockets()
        if afterCount > startCount then
            successCount = afterCount - startCount
            if afterCount > prevLive then
                prevLive = afterCount
                stagnantAttempts = 0
            else
                stagnantAttempts = stagnantAttempts + 1
            end
        else
            stagnantAttempts = stagnantAttempts + 1
        end

        -- Jika beberapa kali pengiriman remote di titik-titik tersebut tidak membuahkan hasil (server menolak),
        -- tandai spot tersebut ke blacklist cooldown agar dilewati dan tidak di-spam berulang-ulang!
        if stagnantAttempts >= 2 then
            for _, sp in ipairs(sentSpots) do
                markSpotFailed(sp.OriginX, sp.OriginZ)
            end
            stagnantAttempts = 0
        end
    end

    logMessage(string.format("Deploy selesai: %d unit %s terpasang! [%s Speed]", successCount, missileItem.Name, spd))
    return successCount
end

-- ====================================================================================================
-- AUTO-REFILL & AUTO-BUY MISSILES IF DEPLETED
-- ====================================================================================================
local function ensureMissilesReady(missileItem, neededCount)
    if not missileItem then return false end
    local baseData = getMyBaseData()
    if not baseData then return false end

    local stockInBag = getMissileStock(missileItem)
    local q = math.max(1, tonumber(neededCount) or 10)

    if stockInBag > 0 then
        logMessage(string.format("📦 [AUTO DEPLOY] Mengambil %d unit %s dari inventory tas...", math.min(stockInBag, q), missileItem.Name))
        showToast("Auto Deploy", string.format("Memasang %s dari tas...", missileItem.Name), "info")
        local placed = executeDeployVerified(baseData, missileItem, math.min(stockInBag, q), State.DeployPosition, State.DeployAlign, "Ultra")
        task.wait(0.5)
        return placed > 0
    else
        logMessage(string.format("🛒 [AUTO BUY] Stok %s di tas kosong! Membeli otomatis di Military Shop...", missileItem.Name))
        showToast("Auto Beli", string.format("Membeli %s x%d di Military Shop...", missileItem.Name, q), "warn")
        executeBuy(missileItem, q)
        task.wait(0.8)
        local newStock = getMissileStock(missileItem)
        if newStock > 0 then
            logMessage(string.format("📦 [AUTO DEPLOY] Memasang %d unit %s yang baru dibeli...", math.min(newStock, q), missileItem.Name))
            local placed = executeDeployVerified(baseData, missileItem, math.min(newStock, q), State.DeployPosition, State.DeployAlign, "Ultra")
            task.wait(0.5)
            return placed > 0
        end
    end
    return false
end

-- Helper mengurutkan daftar roket agar roket yang posisinya saling berdekatan berada berurutan
local function sortRocketsByProximity(rockets)
    if not rockets or #rockets <= 1 then return rockets end
    local sorted = {}
    for _, r in ipairs(rockets) do table.insert(sorted, r) end

    -- Urutkan koordinat secara grid (berdasarkan sumbu X kemudian Z) agar terbentuk formasi baris/kolom yang rapat
    table.sort(sorted, function(a, b)
        local posA = a.Position or (a.Instance and a.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
        local posB = b.Position or (b.Instance and b.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
        -- Toleransi grid baris 2 stud
        if math.abs(posA.X - posB.X) > 2 then
            return posA.X < posB.X
        end
        return posA.Z < posB.Z
    end)
    return sorted
end

-- ====================================================================================================
-- LAUNCH EXECUTIONS (MISSILE & WARSHIP)
-- ====================================================================================================
local function launchMissileVolley(targetItem, rocketGroup, breakShield)
    if not Remotes.MissileAttack or #rocketGroup == 0 then return false end

    -- Reset cooldown blacklist agar titik bekas roket yang baru ditembakkan ini langsung bisa diisi lagi
    clearDeployBlacklist()

    -- Jika fitur Clustered Launch ON, sortir roket agar yang berdekatan diluncurkan bersamaan
    local inputRockets = rocketGroup
    if State.ClusteredLaunchEnabled then
        inputRockets = sortRocketsByProximity(rocketGroup)
    end

    -- Kelompokkan berdasarkan ItemId agar roket sejenis diluncurkan bersama
    local byItemId = {}
    for _, r in ipairs(inputRockets) do
        local id = r.ItemId or "UNKNOWN"
        if not byItemId[id] then byItemId[id] = {} end
        table.insert(byItemId[id], r.Uid)
    end

    local ownerUserId = tonumber(targetItem.Instance and targetItem.Instance:GetAttribute("PlacementOwnerUserId")) or 0
    local targetPos = targetItem.Position or (targetItem.Instance and targetItem.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
    local anySuccess = false
    local allowX10 = (State.UnlockX10 == true)

    State._IsLaunching = true
    for itemId, uids in pairs(byItemId) do
        local total = #uids
        local cursor = 1

        -- Tandai seluruh roket ini di UID cache sebagai 'sedang meluncur'
        for _, u in ipairs(uids) do
            markRocketLaunched(u)
        end

        -- Hitung partisi presisi (X10 jika unlock, X5, dan X1)
        local batches = {}
        local rem = total
        if allowX10 then
            local n10 = math.floor(rem / 10)
            for _ = 1, n10 do table.insert(batches, 10) end
            rem = rem % 10
        end
        local n5 = math.floor(rem / 5)
        for _ = 1, n5 do table.insert(batches, 5) end
        rem = rem % 5
        for _ = 1, rem do table.insert(batches, 1) end

        local spdMult = math.max(1, State.LoopSpeedMultiplier or 1)
        for _, batchSize in ipairs(batches) do
            local batchUids = {}
            for i = 1, batchSize do
                table.insert(batchUids, uids[cursor])
                cursor = cursor + 1
            end

            local payload = {
                RocketItemId = itemId,
                LaunchCount = batchSize,
                RocketUids = batchUids,
                TargetPosition = targetPos,
                BreakOwnShield = (breakShield == true),
                TargetType = "Placement",
                OwnerUserId = ownerUserId,
                Kind = targetItem.Kind or "Build",
                Uid = targetItem.Uid
            }

            local ok = pcall(function()
                Remotes.MissileAttack:FireServer(payload)
            end)
            if ok then anySuccess = true end

            -- Jika speed multiplier 10x: ZERO DELAY (instant burst)
            -- Jika < 10x: delay halus
            if #batches > 1 and spdMult < 10 then
                local bDelay = math.max(0, 0.012 * (1 - (spdMult - 1) / 9))
                if bDelay > 0.001 then
                    task.wait(bDelay)
                end
            end
        end
    end

    -- Beri jeda 0.8 detik sebelum flag _IsLaunching turun agar sequence salvo benar-benar tuntas
    task.delay(0.8, function()
        State._IsLaunching = false
    end)

    return anySuccess
end

local function launchWarshipArmada(targetBaseData, warshipGroup, breakShield)
    if not Remotes.Warship or #warshipGroup == 0 then return false end
    local count = 0
    local targetPlotName = targetBaseData.ModelName or (targetBaseData.Model and targetBaseData.Model.Name) or ("MilitaryBase" .. tostring(State.SelectedBaseIndex))

    for idx, ws in ipairs(warshipGroup) do
        local payload = {
            WarshipItemId = ws.ItemId,
            WarshipUids = { ws.Uid },
            LaunchCount = 1,
            TargetType = "PlayerIsland",
            TargetPlotName = targetPlotName,
            TargetIslandName = nil,
            BreakOwnShield = (breakShield == true)
        }
        local ok = pcall(function() Remotes.Warship:FireServer(payload) end)
        if ok then count = count + 1 end
        if idx < #warshipGroup then
            task.wait(0.35)
        end
    end
    logMessage(string.format("🚢 [WARSHIP ARMADA] Terkirim %d dari %d kapal yang diminta ke %s", count, #warshipGroup, targetPlotName))
    return count > 0
end

local function launchPveAttack(weaponType, breakShield, customRockets, customWarships)
    local anyFired = false
    local mode = weaponType or State.WeaponType

    if mode == "Warship" or mode == "Kombinasi" then
        if Remotes.Warship then
            local availableShips = customWarships or {}
            if #availableShips == 0 then
                for _, ws in ipairs(getMyPlacedWarships()) do
                    if ws.IsReady and (State.SelectedWarshipTypes[ws.ItemId] or next(State.SelectedWarshipTypes) == nil) then
                        table.insert(availableShips, ws)
                    end
                end
            end

            if #availableShips > 0 then
                local quota = math.min(#availableShips, math.max(1, State.WarshipVolley or 1))
                for i = 1, quota do
                    local ws = availableShips[i]
                    local payload = {
                        WarshipItemId = ws.ItemId,
                        WarshipUids = { ws.Uid },
                        LaunchCount = 1,
                        TargetType = "PveIsland",
                        TargetPlotName = "PVEIsland1",
                        TargetIslandName = "PVEIsland1",
                        BreakOwnShield = (breakShield == true)
                    }
                    local ok = pcall(function() Remotes.Warship:FireServer(payload) end)
                    if ok then anyFired = true end
                    task.wait(0.2)
                end
                logMessage(string.format("🏝️ Meluncurkan %d Warship armada ke PVE Center Island!", quota))
            else
                logMessage("⚠️ Tidak ada warship siap tempur untuk PVE Island!")
            end
        end
    end

    if mode == "Missile" or mode == "Kombinasi" then
        if Remotes.MissileAttack then
            local availableRockets = customRockets or {}
            if #availableRockets == 0 then
                for _, r in ipairs(getMyPlacedRockets()) do
                    if State.SelectedMissileTypes[r.ItemId] or next(State.SelectedMissileTypes) == nil then
                        table.insert(availableRockets, r)
                    end
                end
            end

            if #availableRockets > 0 then
                local targetQuota = (#availableRockets)
                if State.CustomMissileQuota and State.CustomMissileQuota > 0 then
                    targetQuota = math.min(#availableRockets, State.CustomMissileQuota)
                elseif State.ManualLaunchVolley and State.ManualLaunchVolley ~= 999 then
                    targetQuota = math.min(#availableRockets, State.ManualLaunchVolley)
                end

                local group = {}
                for i = 1, targetQuota do table.insert(group, availableRockets[i]) end

                local pveTarget = {
                    Position = CENTER_ISLAND_POS,
                    Kind = "PveHouse",
                    Uid = 1
                }
                local ok = launchMissileVolley(pveTarget, group, breakShield)
                if ok then anyFired = true end
                logMessage(string.format("🏝️ Meluncurkan salvo %d misil ke PVE Center Island!", #group))
            else
                logMessage("⚠️ Tidak ada misil terpilih untuk PVE Island!")
            end
        end
    end

    return anyFired
end

-- Serang Karakter Lawan / Posisi Lawan dengan Misil
local function launchPlayerCharacterAttack(targetPlayer, rocketGroup, breakShield, fallbackPos, targetUserId)
    if not Remotes.MissileAttack or #rocketGroup == 0 then return false end

    local targetPos = fallbackPos
    local ownerUserId = targetUserId or (targetPlayer and targetPlayer.UserId) or 0

    if targetPlayer and targetPlayer.Character then
        local char = targetPlayer.Character
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if root then
            targetPos = root.Position
        end
    end

    if not targetPos then
        logMessage("Koordinat target lawan tidak ditemukan!")
        showToast("Target Error", "Koordinat atau karakter lawan tidak ditemukan!", "warn")
        return false
    end

    local inputRockets = rocketGroup
    if State.ClusteredLaunchEnabled then
        inputRockets = sortRocketsByProximity(rocketGroup)
    end

    local byItemId = {}
    for _, r in ipairs(inputRockets) do
        local id = r.ItemId or "UNKNOWN"
        if not byItemId[id] then byItemId[id] = {} end
        table.insert(byItemId[id], r.Uid)
    end

    local allowX10 = (State.UnlockX10 == true)
    local anySuccess = false

    for itemId, uids in pairs(byItemId) do
        local total = #uids
        local cursor = 1
        local batches = {}
        local rem = total

        if allowX10 then
            local n10 = math.floor(rem / 10)
            for _ = 1, n10 do table.insert(batches, 10) end
            rem = rem % 10
        end
        local n5 = math.floor(rem / 5)
        for _ = 1, n5 do table.insert(batches, 5) end
        rem = rem % 5
        for _ = 1, rem do table.insert(batches, 1) end

        for _, batchSize in ipairs(batches) do
            local batchUids = {}
            for i = 1, batchSize do
                table.insert(batchUids, uids[cursor])
                cursor = cursor + 1
            end

            -- Update posisi real-time jika karakter hidup & bergerak
            if targetPlayer and targetPlayer.Character then
                local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Head")
                if root then targetPos = root.Position end
            end

            local payload = {
                RocketItemId = itemId,
                LaunchCount = batchSize,
                RocketUids = batchUids,
                TargetPosition = targetPos,
                BreakOwnShield = (breakShield == true),
                OwnerUserId = ownerUserId
            }

            local ok = pcall(function() Remotes.MissileAttack:FireServer(payload) end)
            if ok then anySuccess = true end
            if #batches > 1 then task.wait(0.08) end
        end
    end

    return anySuccess
end

-- ====================================================================================================
-- CHARACTER UTILITIES (FLY, SPEED, TELEPORT, FLING SAFE, FREEZE)
-- ====================================================================================================
local function applyCharacterAnchored(anchored)
    State.FreezeApplied = anchored
    local char = localPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchored
            if anchored then
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

local function setFreezeMode(mode)
    State.FreezeMode = mode or "ON"
    if mode == "ON" then
        applyCharacterAnchored(true)
        logMessage("Freeze Karakter diatur ke: ON (Selalu Anchored).")
        showToast("Freeze: ON", "Karakter dibekukan / kebal missile armor", "success")
    elseif mode == "OFF" then
        applyCharacterAnchored(false)
        logMessage("Freeze Karakter diatur ke: OFF.")
        showToast("Freeze: OFF", "Karakter tidak dibekukan (Normal)", "info")
    else
        -- Mode Auto: selalu freeze (auto ON) + re-freeze tiap 5 detik agar karakter hasil respawn langsung terkunci
        State.FreezeMode = "Auto"
        State.FreezeAutoLastCycle = tick()
        applyCharacterAnchored(true)
        logMessage("Freeze Karakter diatur ke: AUTO (Auto ON, re-freeze tiap 5 detik).")
        showToast("Freeze: AUTO", "Auto Freeze ON! Re-freeze tiap 5 detik agar karakter respawn langsung beku.", "info")
    end

    if State.UI and State.UI.UpdateFreezeButtons then
        pcall(function() State.UI.UpdateFreezeButtons() end)
    end
end

local flyConnection = nil
local function toggleFly(enable)
    State.FlyEnabled = enable
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if enable then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "WW3_FlyVelocity"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root

        local bg = Instance.new("BodyGyro")
        bg.Name = "WW3_FlyGyro"
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        bg.CFrame = root.CFrame
        bg.Parent = root
        hum.PlatformStand = true

        flyConnection = RunService.RenderStepped:Connect(function()
            if not State.FlyEnabled or not root.Parent then
                if flyConnection then flyConnection:Disconnect() end
                return
            end
            local camCF = camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            local mf = State.MobileFly

            -- Keyboard Input
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or (mf and mf.Forward) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or (mf and mf.Backward) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or (mf and mf.Left) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) or (mf and mf.Right) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or (mf and mf.Up) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or (mf and mf.Down) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            bv.Velocity = (moveDir.Magnitude > 0) and (moveDir.Unit * State.FlySpeed) or Vector3.new(0, 0, 0)
            bg.CFrame = camCF
        end)

        -- Tampilkan On-Screen Touch Pad jika mode Smartphone/Touch aktif
        if State.MobileFly and State.MobileFly.Container then
            State.MobileFly.Container.Visible = true
        end
        logMessage("Fly diaktifkan (WASD / Touch Controls)")
    else
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if root:FindFirstChild("WW3_FlyVelocity") then root.WW3_FlyVelocity:Destroy() end
        if root:FindFirstChild("WW3_FlyGyro") then root.WW3_FlyGyro:Destroy() end
        hum.PlatformStand = false
        if State.MobileFly and State.MobileFly.Container then
            State.MobileFly.Container.Visible = false
            State.MobileFly.Forward = false
            State.MobileFly.Backward = false
            State.MobileFly.Left = false
            State.MobileFly.Right = false
            State.MobileFly.Up = false
            State.MobileFly.Down = false
        end
        logMessage("Fly dinonaktifkan")
    end
end

local speedConnection = nil
local function toggleSpeed(enable)
    State.SpeedHackEnabled = enable
    if enable then
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = RunService.Heartbeat:Connect(function()
            local h = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = State.SpeedHackValue end
        end)
        logMessage(string.format("Speed Hack aktif (%d)", State.SpeedHackValue))
    else
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        local h = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
        logMessage("Speed normal (16)")
    end
end

local noclipConnection = nil
local function toggleNoclip(enable)
    if enable == nil then enable = not State.NoclipEnabled end
    State.NoclipEnabled = enable
    if enable then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            local char = localPlayer.Character
            if char and State.NoclipEnabled then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        showToast("Noclip", "Noclip AKTIF (tembus dinding)", "success")
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        local char = localPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Torso") then
                    part.CanCollide = true
                end
            end
        end
        showToast("Noclip", "Noclip NONAKTIF", "info")
    end

    if State.UI and State.UI.UpdateNoclipButtons then
        State.UI.UpdateNoclipButtons()
    end
    return enable
end

local function teleportTo(pos)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not pos then return end

    local targetCF = (typeof(pos) == "CFrame") and pos or CFrame.new(pos + Vector3.new(0, 4, 0))
    local wasFreeze = (State.FreezeMode == "ON" or State.FreezeApplied)

    if wasFreeze then
        applyCharacterAnchored(false)
        task.wait(0.03)
    end

    pcall(function()
        root.CFrame = targetCF
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)

    if wasFreeze then
        task.wait(0.04)
        applyCharacterAnchored(true)
    end

    logMessage("Teleport berhasil!")
end

-- Teleport ke 5 titik strategis base lokal: Pojok Kanan Atas, Pojok Kiri Atas, Pojok Kiri Bawah, Pojok Kanan Bawah, Tengah Base
-- Menggunakan mekanisme random tanpa pengulangan spot yang sama berturut-turut
local _lastBaseSpotIndex = nil
local function teleportBaseRandomSpot(silent)
    local baseData = getMyBaseData()
    local pa = baseData and baseData.PlacementArea
    local baseModel = baseData and baseData.Model

    local spots = {}
    if pa and pa:IsA("BasePart") then
        local cf = pa.CFrame
        local halfX = (pa.Size.X / 2) - 15
        local halfZ = (pa.Size.Z / 2) - 15
        spots = {
            { Name = "Pojok Kanan Atas Base", Pos = (cf * CFrame.new(halfX, 4, -halfZ)).Position },
            { Name = "Pojok Kiri Atas Base",  Pos = (cf * CFrame.new(-halfX, 4, -halfZ)).Position },
            { Name = "Pojok Kiri Bawah Base", Pos = (cf * CFrame.new(-halfX, 4, halfZ)).Position },
            { Name = "Pojok Kanan Bawah Base",Pos = (cf * CFrame.new(halfX, 4, halfZ)).Position },
            { Name = "Tengah Base",           Pos = (cf * CFrame.new(0, 4, 0)).Position }
        }
    elseif baseModel and baseModel:IsA("Model") then
        local pivot = baseModel:GetPivot()
        local cf = pivot
        local span = 80
        spots = {
            { Name = "Pojok Kanan Atas Base", Pos = (cf * CFrame.new(span, 4, -span)).Position },
            { Name = "Pojok Kiri Atas Base",  Pos = (cf * CFrame.new(-span, 4, -span)).Position },
            { Name = "Pojok Kiri Bawah Base", Pos = (cf * CFrame.new(-span, 4, span)).Position },
            { Name = "Pojok Kanan Bawah Base",Pos = (cf * CFrame.new(span, 4, span)).Position },
            { Name = "Tengah Base",           Pos = (cf * CFrame.new(0, 4, 0)).Position }
        }
    else
        local myBaseIdx = (baseData and baseData.Index) or State.SelectedBaseIndex or 1
        local center = BASE_COORDINATES[myBaseIdx] or BASE_COORDINATES[1]
        local span = 80
        spots = {
            { Name = "Pojok Kanan Atas Base", Pos = center + Vector3.new(span, 4, -span) },
            { Name = "Pojok Kiri Atas Base",  Pos = center + Vector3.new(-span, 4, -span) },
            { Name = "Pojok Kiri Bawah Base", Pos = center + Vector3.new(-span, 4, span) },
            { Name = "Pojok Kanan Bawah Base",Pos = center + Vector3.new(span, 4, span) },
            { Name = "Tengah Base",           Pos = center + Vector3.new(0, 4, 0) }
        }
    end

    -- Pilih spot random yang TIDAK SAMA dengan spot sebelumnya
    local availableIndices = {}
    for i = 1, #spots do
        if i ~= _lastBaseSpotIndex then
            table.insert(availableIndices, i)
        end
    end
    if #availableIndices == 0 then table.insert(availableIndices, 1) end

    local chosenIndex = availableIndices[math.random(1, #availableIndices)]
    _lastBaseSpotIndex = chosenIndex

    local chosenSpot = spots[chosenIndex]
    local wasFreeze = (State.FreezeMode == "ON" or State.FreezeApplied)
    if wasFreeze then
        applyCharacterAnchored(false)
        task.wait(0.05)
    end

    teleportTo(chosenSpot.Pos)

    if wasFreeze then
        task.wait(0.08)
        applyCharacterAnchored(true)
    end

    logMessage(string.format("⚡ [TELEPORT BASE] Pindah posisi ke: %s (Spot #%d)", chosenSpot.Name, chosenIndex))
    if not silent then
        showToast("Teleport Base", string.format("Pindah ke %s!", chosenSpot.Name), "info")
    end
end

-- Background Loop: Auto TP Base (pindah bergilir ke 5 titik tiap 5 detik)
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoTpBaseEnabled then
            local nowTp = tick()
            if nowTp - (State.AutoTpBaseLastTime or 0) >= 5 then
                State.AutoTpBaseLastTime = nowTp
                pcall(teleportBaseRandomSpot, true)
            end
        end
    end
end)

-- ====================================================================================================
-- AUTO EVADE TP BASE JIKA MISIL BERADA DI ATAS PEMAIN (Y < 20)
-- Default AKTIF: Tanpa ESP, memberikan notifikasi toast & teleport seketika ke base sendiri
-- ====================================================================================================
local _lastMissileEvadeTime = 0

local function performImmediateEvade(missileName, missilePos)
    if not State.MissileEvadeEnabled then return end
    local now = os.clock()
    if now - _lastMissileEvadeTime < 1.5 then return end
    _lastMissileEvadeTime = now

    local char = localPlayer and localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Paksa unanchor sementara jika sedang freeze
    if State.FreezeApplied then
        applyCharacterAnchored(false)
    end

    -- Hitung koordinat target Base
    local baseData = getMyBaseData()
    local pa = baseData and baseData.PlacementArea
    local baseModel = baseData and baseData.Model
    local targetCF = nil

    if pa and pa:IsA("BasePart") then
        local cf = pa.CFrame
        local halfX = math.max(10, (pa.Size.X / 2) - 15)
        local halfZ = math.max(10, (pa.Size.Z / 2) - 15)
        local rx = math.random(-math.floor(halfX), math.floor(halfX))
        local rz = math.random(-math.floor(halfZ), math.floor(halfZ))
        targetCF = cf * CFrame.new(rx, 5, rz)
    elseif baseModel and baseModel:IsA("Model") then
        local rx = math.random(-50, 50)
        local rz = math.random(-50, 50)
        targetCF = baseModel:GetPivot() * CFrame.new(rx, 5, rz)
    else
        local myBaseIdx = (baseData and baseData.Index) or State.MyBaseCachedIndex or State.SelectedBaseIndex or 1
        local center = BASE_COORDINATES[myBaseIdx] or BASE_COORDINATES[1]
        local rx = math.random(-50, 50)
        local rz = math.random(-50, 50)
        targetCF = CFrame.new(center + Vector3.new(rx, 5, rz))
    end

    -- Eksekusi Teleport Seketika
    pcall(function()
        root.CFrame = targetCF
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)

    -- Jika FreezeMode ON, kembalikan anchor setelah karakter berada di titik aman
    if State.FreezeMode == "ON" or State.FreezeMode == "Auto" then
        task.delay(0.08, function()
            if State.FreezeMode == "ON" or State.FreezeMode == "Auto" then
                applyCharacterAnchored(true)
            end
        end)
    end

    local altInfo = missilePos and string.format("Y: %.1f", missilePos.Y) or "<20"
    showToast("🚨 MISIL DI ATAS KITA! (EVADE)", string.format("Misil %s terdeteksi (%s)! Seketika pindah ke Base aman.", tostring(missileName or "Rocket"), altInfo), "danger")
    logMessage(string.format("⚠️ [EVADE TP BASE] Misil %s mendeteksi ancaman di atas pemain (%s)! Evade ke Base sukses.", tostring(missileName or "Rocket"), altInfo))
end

local function hookIncomingMissileEvade()
    -- 1. Jalur Remote: Deteksi event peluncuran misil seketika dari server
    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("MissileAttackRemotes", 15)
        local flightRemote = remotes and remotes:WaitForChild("MissileFlightVisual", 15)
        if flightRemote and flightRemote:IsA("RemoteEvent") then
            flightRemote.OnClientEvent:Connect(function(action, payload)
                if action == "Begin" and type(payload) == "table" then
                    local myChar = localPlayer and localPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if not myRoot then return end

                    local pPos = myRoot.Position
                    local target = payload.TargetPosition
                    if target and typeof(target) == "Vector3" then
                        local horizDist = (Vector3.new(target.X, 0, target.Z) - Vector3.new(pPos.X, 0, pPos.Z)).Magnitude
                        -- Jika koordinat target misil mengarah tepat ke posisi pemain (< 40 stud)
                        if horizDist <= 40 then
                            local rName = payload.RocketItemId or payload.RocketModelName or "Rocket"
                            for _, m in ipairs(MISSILES) do
                                if tostring(rName):find(m.Id) or (m.Matches and table.find(m.Matches, tostring(rName):lower())) then
                                    rName = m.Name
                                    break
                                end
                            end
                            performImmediateEvade(rName, target)
                        end
                    end
                end
            end)
        end
    end)

    -- 2. Jalur Fisik Workspace: Pantau pergerakan visual misil secara real-time
    task.spawn(function()
        local folder = Workspace:WaitForChild("MissileFlightVisuals", 15) or Workspace:FindFirstChild("MissileFlightVisuals")
        if not folder then return end

        local function watchMissile(child)
            task.wait(0.03)
            local rootPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
            if not rootPart then
                local connWait
                connWait = child.DescendantAdded:Connect(function(desc)
                    if desc:IsA("BasePart") then
                        rootPart = desc
                        if connWait then connWait:Disconnect() end
                    end
                end)
                task.wait(0.1)
                if connWait then connWait:Disconnect() end
            end
            if not rootPart then return end

            local mName = child.Name or "Rocket"
            for _, m in ipairs(MISSILES) do
                if child.Name:find(m.Id) or (m.Matches and table.find(m.Matches, child.Name:lower())) then
                    mName = m.Name
                    break
                end
            end

            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not child or not child.Parent or not rootPart or not rootPart.Parent then
                    if conn then conn:Disconnect() end
                    return
                end

                local myChar = localPlayer and localPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local mPos = rootPart.Position
                    local pPos = myRoot.Position

                    local horizDist = (Vector3.new(mPos.X, 0, mPos.Z) - Vector3.new(pPos.X, 0, pPos.Z)).Magnitude
                    local relY = mPos.Y - pPos.Y

                    -- Syarat picu Evade:
                    -- Radius horizontal <= 70 stud DAN
                    -- (Ketinggian absolut mPos.Y < 20 ATAU selisih tinggi di atas kepala relY antara 0 dan 25 stud)
                    if horizDist <= 70 and (mPos.Y < 20 or (relY >= -2 and relY <= 25)) then
                        performImmediateEvade(mName, mPos)
                        if conn then conn:Disconnect() end
                    end
                end
            end)
        end

        folder.ChildAdded:Connect(watchMissile)
        for _, existing in ipairs(folder:GetChildren()) do
            task.spawn(watchMissile, existing)
        end
    end)
end
task.spawn(hookIncomingMissileEvade)

-- ====================================================================================================
-- DRONE VIEW CAMERA CONTROLLER (TOP-DOWN TACTICAL VIEW DENGAN KETINGGIAN DINAMIS)
-- ====================================================================================================
local droneRenderConn = nil
local originalCameraType = nil

local function toggleDroneView(enable)
    if enable == nil then
        enable = not State.DroneViewEnabled
    end
    State.DroneViewEnabled = enable

    if droneRenderConn then
        droneRenderConn:Disconnect()
        droneRenderConn = nil
    end

    if enable then
        originalCameraType = camera.CameraType
        camera.CameraType = Enum.CameraType.Scriptable

        droneRenderConn = RunService.RenderStepped:Connect(function()
            local char = localPlayer.Character
            local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
            local charPos = root and root.Position or Vector3.new(0, 0, 0)
            local offX = State.DroneOffsetX or 0
            local offZ = State.DroneOffsetZ or 0
            local lookTarget = charPos + Vector3.new(offX, 0, offZ)
            local alt = State.DroneAltitude or 120
            local dronePos = lookTarget + Vector3.new(0, alt, 0.05)
            camera.CFrame = CFrame.new(dronePos, lookTarget)
        end)

        logMessage(string.format("🚁 Drone View AKTIF (Ketinggian: %d stud)", State.DroneAltitude or 120))
        showToast("Drone View", string.format("Drone View aktif! Alt: %d stud", State.DroneAltitude or 120), "info")
    else
        camera.CameraType = originalCameraType or Enum.CameraType.Custom
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then camera.CameraSubject = hum end
        logMessage("🚁 Drone View DINONAKTIFKAN.")
        showToast("Drone View", "Kamera kembali normal.", "info")
    end

    if State.UI and State.UI.DroneViewBtn then
        State.UI.DroneViewBtn.BackgroundColor3 = enable and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(45, 55, 75)
        State.UI.DroneViewBtn.Text = enable and "🚁 Drone: ON" or "🚁 Drone"
    end
    if State.UI and State.UI.DroneSliderContainer then
        State.UI.DroneSliderContainer.Visible = enable
    end
    return enable
end

-- ====================================================================================================
-- GHOST MODE ENGINE (DARI ghost2.lua: CLIENT CONTROLLER DI TANAH + REAL CHAR DISPLACED KE Y OFFSET)
-- ====================================================================================================
local GhostConnections = {}
local OriginalGhostPartProps = {}

local function applyGhostVisualToRealChar(realChar)
    table.clear(OriginalGhostPartProps)
    for _, desc in ipairs(realChar:GetDescendants()) do
        if desc:IsA("BasePart") then
            OriginalGhostPartProps[desc] = {
                Transparency = desc.Transparency,
                Color = desc.Color,
                Material = desc.Material,
                CanCollide = desc.CanCollide,
            }
            desc.CanCollide = false
            if desc.Name ~= "HumanoidRootPart" then
                desc.Transparency = math.clamp(desc.Transparency + 0.45, 0.45, 0.8)
                desc.Color = Color3.fromRGB(0, 240, 215)
                desc.Material = Enum.Material.ForceField
            end
        end
    end
end

local function restoreRealCharGhostVisuals(realChar)
    if not realChar then return end
    for part, props in pairs(OriginalGhostPartProps) do
        if part and part.Parent then
            part.Transparency = props.Transparency
            part.Color = props.Color
            part.Material = props.Material
            part.CanCollide = props.CanCollide
        end
    end
    table.clear(OriginalGhostPartProps)
end

local function getControlMoveDirection(realHum)
    if UserInputService:GetFocusedTextBox() then
        return Vector3.zero, false
    end
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.zero, false end

    local forward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
    local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
    if forward.Magnitude > 0 then forward = forward.Unit end
    if right.Magnitude > 0 then right = right.Unit end

    local moveVec = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then moveVec += forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then moveVec -= forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then moveVec += right end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then moveVec -= right end

    if moveVec.Magnitude == 0 and realHum and realHum.MoveDirection.Magnitude > 0 then
        moveVec = realHum.MoveDirection
    end
    if moveVec.Magnitude > 1 then moveVec = moveVec.Unit end
    local isJumping = UserInputService:IsKeyDown(Enum.KeyCode.Space) or (realHum and realHum.Jump)
    return moveVec, isJumping
end

local function lockGhostAboveAndSyncController()
    if not State.GhostMode then return end
    local realChar = localPlayer.Character
    local realHRP = realChar and realChar:FindFirstChild("HumanoidRootPart")
    local realHum = realChar and realChar:FindFirstChildOfClass("Humanoid")
    if not realChar or not realHRP or not realHum then return end

    local ctrl = State.GhostClientController
    if not ctrl or not ctrl.Parent then
        return
    end

    local ctrlHRP = ctrl:FindFirstChild("HumanoidRootPart")
    local ctrlHum = ctrl:FindFirstChildOfClass("Humanoid")
    if not ctrlHRP or not ctrlHum then return end

    -- 1. Kamera mengikuti dummy client controller di tanah
    local cam = workspace.CurrentCamera
    if cam and cam.CameraSubject ~= ctrlHum then
        cam.CameraSubject = ctrlHum
    end

    -- 2. Gerakkan karakter controller di bawah
    local moveDir, isJumping = getControlMoveDirection(realHum)
    ctrlHum.WalkSpeed = realHum.WalkSpeed
    ctrlHum:Move(moveDir, false)
    if isJumping then ctrlHum.Jump = true end

    -- 3. Paksa tubuh asli berada pada CFrame kontrol + Offset Y (GhostHeight)
    pcall(function()
        workspace.FallenPartsDestroyHeight = 0 / 0
    end)
    local targetGhostCF = ctrlHRP.CFrame + Vector3.new(0, State.GhostHeight or 0, 0)
    realHRP.CFrame = targetGhostCF
    realHRP.AssemblyLinearVelocity = Vector3.zero
    realHRP.AssemblyAngularVelocity = Vector3.zero

    -- 4. Sinkronkan pose/animasi
    for _, obj in ipairs(realChar:GetDescendants()) do
        if obj:IsA("Motor6D") and obj.Part0 and obj.Part1 then
            local parentPart = ctrl:FindFirstChild(obj.Parent.Name, true)
            local cloneMotor = parentPart and parentPart:FindFirstChild(obj.Name)
            if cloneMotor and cloneMotor:IsA("Motor6D") then
                cloneMotor.Transform = obj.Transform
            end
        elseif obj:IsA("BasePart") then
            obj.CanCollide = false
        end
    end
end

local function enableGhostMode(customHeight)
    local realChar = localPlayer.Character
    local realHRP = realChar and realChar:FindFirstChild("HumanoidRootPart")
    local realHum = realChar and realChar:FindFirstChildOfClass("Humanoid")
    if not realChar or not realHRP or not realHum then return end

    if State.GhostClientController then
        State.GhostClientController:Destroy()
        State.GhostClientController = nil
    end

    if customHeight ~= nil then
        State.GhostHeight = customHeight
    end

    pcall(function()
        workspace.FallenPartsDestroyHeight = 0 / 0
    end)

    -- Buat Karakter Kontrol Client-Side di Tanah
    local oldArch = realChar.Archivable
    realChar.Archivable = true
    local clone = realChar:Clone()
    realChar.Archivable = oldArch
    if not clone then return end

    clone.Name = "WW3_CLIENT_GHOST_CONTROLLER"
    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("LocalScript") or desc:IsA("Script") or desc:IsA("ForceField") then
            desc:Destroy()
        end
    end

    local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
    local cloneHum = clone:FindFirstChildOfClass("Humanoid")
    if cloneHRP and cloneHum then
        cloneHRP.CFrame = realHRP.CFrame
        cloneHum.WalkSpeed = realHum.WalkSpeed
        cloneHum.JumpPower = realHum.JumpPower
        cloneHum.UseJumpPower = realHum.UseJumpPower
    end

    clone.Parent = workspace
    State.GhostClientController = clone

    applyGhostVisualToRealChar(realChar)
    realHRP.CFrame = cloneHRP.CFrame + Vector3.new(0, State.GhostHeight or 0, 0)
    realHRP.AssemblyLinearVelocity = Vector3.zero
    realHRP.AssemblyAngularVelocity = Vector3.zero

    local cam = workspace.CurrentCamera
    if cam and cloneHum then
        cam.CameraSubject = cloneHum
    end

    State.GhostMode = true

    -- Bind Core Loops
    for _, conn in ipairs(GhostConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(GhostConnections)
    table.insert(GhostConnections, RunService.Stepped:Connect(lockGhostAboveAndSyncController))
    table.insert(GhostConnections, RunService.Heartbeat:Connect(lockGhostAboveAndSyncController))
    table.insert(GhostConnections, RunService.RenderStepped:Connect(lockGhostAboveAndSyncController))

    if State.UI and State.UI.UpdateGhostModeUI then pcall(State.UI.UpdateGhostModeUI) end
    showToast("Ghost Mode ON", string.format("Ghost Mode aktif! Ketinggian Y Offset: %d", State.GhostHeight or 0), "success")
end

local function disableGhostMode()
    State.GhostMode = false
    for _, conn in ipairs(GhostConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(GhostConnections)

    local realChar = localPlayer.Character
    local realHRP = realChar and realChar:FindFirstChild("HumanoidRootPart")
    local realHum = realChar and realChar:FindFirstChildOfClass("Humanoid")

    if State.GhostClientController then
        local ctrlHRP = State.GhostClientController:FindFirstChild("HumanoidRootPart")
        if realHRP and ctrlHRP then
            realHRP.CFrame = ctrlHRP.CFrame
            realHRP.AssemblyLinearVelocity = Vector3.zero
            realHRP.AssemblyAngularVelocity = Vector3.zero
        end
        State.GhostClientController:Destroy()
        State.GhostClientController = nil
    end

    if realChar then
        restoreRealCharGhostVisuals(realChar)
    end

    local cam = workspace.CurrentCamera
    if cam and realHum then
        cam.CameraSubject = realHum
    end

    if State.UI and State.UI.UpdateGhostModeUI then pcall(State.UI.UpdateGhostModeUI) end
    showToast("Ghost Mode OFF", "Karakter kembali normal di tanah.", "info")
end

local function toggleGhostMode(enable, customHeight)
    if enable == nil then
        enable = not State.GhostMode
    end
    if enable then
        enableGhostMode(customHeight)
    else
        disableGhostMode()
    end
end

-- Universal Physical Part Resolver (Cepat, Ringan & Mendukung R6, R15, Fly/Custom Rig)
local function getAnyPhysicalRootPart(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Head")
        or char.PrimaryPart
end

local followConnection = nil
local function toggleFollow(targetPlr, enable)
    if enable and targetPlr then
        State.FollowTarget = targetPlr
        if followConnection then followConnection:Disconnect() end
        followConnection = RunService.Heartbeat:Connect(function()
            local myRoot = getAnyPhysicalRootPart(localPlayer.Character)
            local tChar = targetPlr.Character or Workspace:FindFirstChild(targetPlr.Name)
            local tRoot = getAnyPhysicalRootPart(tChar)
            if myRoot and tRoot then
                -- Cegah terseret ke void desync ekstrem jika target belum ter-stream
                if tRoot.Position.Y > -1000 and tRoot.Position.Y < 20000 then
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4)
                end
            end
        end)
        logMessage("Follow player: " .. targetPlr.DisplayName)
    else
        State.FollowTarget = nil
        if followConnection then followConnection:Disconnect(); followConnection = nil end
        logMessage("Follow berhenti.")
    end

    if State.UI then
        if State.UI.UpdateFollowButtons then State.UI.UpdateFollowButtons() end
        if State.UI.UpdateFollowButtonsList then
            for _, fn in ipairs(State.UI.UpdateFollowButtonsList) do pcall(fn) end
        end
    end
end

-- Safe & High-Momentum Fling / Kick Engine
-- Metode: Memanfaatkan BodyAngularVelocity desync torque + micro-orbit penetrasi tanpa membuat karakter sendiri mental
local function executeSafeFling(targetPlr, isTpKick, customPower)
    if isTpKick == nil then isTpKick = true end
    local tChar = (targetPlr and targetPlr.Character) or (targetPlr and Workspace:FindFirstChild(targetPlr.Name))
    if not targetPlr or not tChar then
        logMessage("Target kick tidak valid!")
        showToast("Kick Gagal", "Target tidak ditemukan / belum spawn", "danger")
        return
    end

    -- Aktifkan Physics Simulation Radius di awal agar momentum instan aktif
    maximizeFlingSimulationRadius()

    local myChar = localPlayer.Character
    local myRoot = getAnyPhysicalRootPart(myChar)
    local tRoot = getAnyPhysicalRootPart(tChar)
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not tRoot then
        showToast("Kick Gagal", "Part fisik karakter/target belum ter-stream", "danger")
        return
    end

    if not isTpKick then
        local currentDist = (myRoot.Position - tRoot.Position).Magnitude
        if currentDist > 25 then
            logMessage(string.format("Target terlalu jauh (%.1f stud)! Gunakan 'TP + Kick' atau dekati target.", currentDist))
            showToast("Jarak Terlalu Jauh", string.format("Jarak: %.0f stud. Dekati target untuk Kick Only!", currentDist), "warn")
            return
        end
    end

    local wasFreezeInitially = (State.FreezeMode == "ON" or State.FreezeApplied)
    -- Tandai bahwa eksekusi Fling sedang berjalan & lepas freeze agar karakter bebas bergerak
    State.FlingExecuting = true
    if wasFreezeInitially then
        applyCharacterAnchored(false)
        task.wait(0.04)
    end

    local originalCF = myRoot.CFrame
    local targetStartPos = tRoot.Position

    -- Jika TP + Kick: Teleport 1 stud ke arah target terlebih dahulu sebelum memulai lontaran
    if isTpKick then
        myRoot.CFrame = CFrame.new(targetStartPos + Vector3.new(0, 0.8, 1), targetStartPos)
        myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        task.wait(0.04)
    end

    local pName = customPower or State.FlingPower or "Rendah"
    local kickModeText = isTpKick and "TP + Kick" or "Kick Only"
    logMessage(string.format("[%s] Menendang %s (Kekuatan: %s)...", kickModeText, targetPlr.DisplayName, tostring(pName)))
    showToast(kickModeText, string.format("Melontarkan %s (%s)...", targetPlr.DisplayName, tostring(pName)), "warn")

    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            hum.PlatformStand = false
            hum.Sit = false
        end)
    end

    -- Pilihan Kecepatan Rotasi / Torsi Fling
    local flingVelocityVal = 100000
    if pName == "Rendah" then
        flingVelocityVal = 35000
    elseif pName == "Sedang" then
        flingVelocityVal = 70000
    elseif pName == "Kuat" then
        flingVelocityVal = 140000
    elseif pName == "Sangat Kuat" or pName == "Ekstrim" then
        flingVelocityVal = 250000
    end

    -- Nonaktifkan collision hanya untuk anggota badan (limbs/accs) agar tidak tersangkut,
    -- TETAPI biarkan HumanoidRootPart / Torso tetap CanCollide = true agar impuls fisik mengenai musuh!
    for _, p in ipairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then
            if p.Name == "HumanoidRootPart" or p.Name == "Torso" or p.Name == "UpperTorso" then
                p.CanCollide = true
            else
                p.CanCollide = false
            end
        end
    end

    -- Pasang BodyAngularVelocity untuk stabilitas transfer impuls
    for _, ch in ipairs(myRoot:GetChildren()) do
        if ch.Name == "WW3_FlingAngular" or ch.Name == "WW3_SafeFling" then ch:Destroy() end
    end
    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "WW3_FlingAngular"
    bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bav.P = 1e6
    -- Fokuskan torsi horizontal dan vertical yang seimbang agar tidak berguling acak ke tanah
    bav.AngularVelocity = Vector3.new(flingVelocityVal * 0.7, flingVelocityVal, flingVelocityVal * 0.7)
    bav.Parent = myRoot

    -- Set CustomPhysicalProperties pada karakter kita agar bermassa sangat padat & licin (tidak mental sendiri)
    for _, p in ipairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function()
                p.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 100, 100)
            end)
        end
    end

    local duration = (pName == "Rendah") and 0.5 or ((pName == "Sedang") and 0.75 or 1.1)
    local startTime = tick()
    local conn

    conn = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local curTRoot = targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
        local curTHum = targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid")
        local curMyChar = localPlayer.Character
        local curMyRoot = curMyChar and curMyChar:FindFirstChild("HumanoidRootPart")

        local flingDisplacement = 0
        if curTRoot and targetStartPos then
            flingDisplacement = (curTRoot.Position - targetStartPos).Magnitude
        end

        local targetFled = false
        if flingDisplacement > 80 or (curTRoot and curTRoot.Position.Y < -80) or (curTHum and curTHum.Health <= 0) then
            targetFled = true
        end

        if elapsed > duration or not curTRoot or not curMyRoot or targetFled then
            conn:Disconnect()
            State.FlingExecuting = false

            -- 1. Bersihkan BodyMovers seketika
            if curMyRoot then
                for _, ch in ipairs(curMyRoot:GetChildren()) do
                    if ch.Name == "WW3_FlingAngular" or ch.Name == "WW3_SafeFling" then ch:Destroy() end
                end
                pcall(function()
                    curMyRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    curMyRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end)
            end

            -- 2. Tentukan posisi finish (Recall ke posisi awal ATAU tetap di posisi kick sekitar target)
            local safeLandCF = nil
            if isTpKick and State.FlingAutoRecall and originalCF then
                safeLandCF = originalCF
            elseif curMyRoot then
                safeLandCF = curMyRoot.CFrame
            end

            -- 3. KEMBALIKAN KE ASAL & FREEZE KEMBALI
            if curMyRoot and safeLandCF then
                curMyRoot.CFrame = safeLandCF
                curMyRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                curMyRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

                -- Langsung anchor karakter
                curMyRoot.Anchored = true
                if wasFreezeInitially or State.FreezeMode == "ON" then
                    applyCharacterAnchored(true)
                else
                    -- Jika sebelumnya tidak freeze, tahan anchor 0.4 detik untuk menyerap momentum sisa, lalu unanchor
                    task.delay(0.4, function()
                        if curMyRoot and curMyRoot.Parent and not State.FreezeApplied and State.FreezeMode ~= "ON" then
                            curMyRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            curMyRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            curMyRoot.Anchored = false
                        end
                    end)
                end
            end

            -- 4. Pulihkan collision seluruh tubuh setelah delay singkat
            task.delay(0.35, function()
                if curMyChar and curMyChar.Parent then
                    for _, p in ipairs(curMyChar:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end
            end)

            if hum and not State.AntiRagdollEnabled then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
                    hum.PlatformStand = false
                    hum.Sit = false
                end)
            end

            -- VERIFIKASI SEBERAPA JAUH TARGET TERLONTAR
            local finalDisplacement = 0
            if curTRoot and targetStartPos then
                finalDisplacement = (curTRoot.Position - targetStartPos).Magnitude
            elseif not curTRoot or (curTHum and curTHum.Health <= 0) then
                finalDisplacement = 999
            end

            if finalDisplacement >= 40 or not curTRoot or (curTHum and curTHum.Health <= 0) then
                logMessage(string.format("✓ %s BERHASIL! Target %s terlontar sejauh %.0f stud!", kickModeText, targetPlr.DisplayName, finalDisplacement))
                showToast("Fling Berhasil!", string.format("✓ %s terlontar %.0f stud!", targetPlr.DisplayName, finalDisplacement), "success")
            else
                logMessage(string.format("⚠️ %s belum maksimal (Perpindahan: %.0f stud). Silakan coba 1x lagi!", kickModeText, finalDisplacement))
                showToast("Belum Maksimal", string.format("Lawan baru bergeser %.0f stud. Coba klik lagi!", finalDisplacement), "warn")
            end
            return
        end

        -- Trik Skid Momentum: Tempatkan kita di posisi pinggang/torso target dengan jitter desync
        local tPos = curTRoot.Position
        local skidOffset = Vector3.new(math.random(-15, 15) / 100, -0.15, math.random(-15, 15) / 100)

        if isTpKick then
            curMyRoot.CFrame = CFrame.new(tPos + skidOffset)
        else
            local dir = (tPos - curMyRoot.Position)
            if dir.Magnitude > 0.4 then
                curMyRoot.CFrame = CFrame.new(tPos + skidOffset, tPos)
            end
        end

        pcall(function()
            curMyRoot.AssemblyLinearVelocity = Vector3.new(flingVelocityVal, flingVelocityVal, flingVelocityVal)
            curMyRoot.AssemblyAngularVelocity = Vector3.new(flingVelocityVal * 2, flingVelocityVal * 2, flingVelocityVal * 2)
        end)
    end)
end

-- ====================================================================================================
-- TP + KICK (ATTACK MODE) — METODE FLING DARI fling.lua
-- Metode: Skid Penetration Cycle (offset vertikal bergantian) + BodyAngularVelocity/BodyThrust
--         + Upward Momentum ekstrim, dengan seluruh part karakter CanCollide = false saat fase fling.
-- Dipakai HANYA oleh tombol TP+Kick di GUI Attack Mode (engine GUI utama tetap tidak diubah).
-- ====================================================================================================
local FLING_METHOD_OFFSETS = {
    CFrame.new(0, -1.5, 0),
    CFrame.new(0, 1.2, 0),
    CFrame.new(0, -0.6, 0),
    CFrame.new(0, -2.2, 0),
    CFrame.new(0, 0, 0)
}

local function maximizeFlingSimulationRadius()
    pcall(function()
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        settings().Physics.AllowSleep = false
        if setsimulationradius then
            setsimulationradius(math.huge, math.huge)
        elseif sethiddenproperty then
            sethiddenproperty(localPlayer, "SimulationRadius", 1e9)
            sethiddenproperty(localPlayer, "MaximumSimulationRadius", 1e9)
        end
    end)
end

local function executeTpKickFlingMethod(targetPlr, isTpKick, customPower)
    if isTpKick == nil then isTpKick = true end
    local tChar = (targetPlr and targetPlr.Character) or (targetPlr and Workspace:FindFirstChild(targetPlr.Name))
    if not targetPlr or not tChar then
        logMessage("Target kick tidak valid!")
        showToast("Kick Gagal", "Target tidak ditemukan / belum spawn", "danger")
        return
    end
    if State.FlingExecuting then
        showToast("Kick Masih Jalan", "Tunggu proses kick sebelumnya selesai dulu.", "warn")
        return
    end

    -- Panggil maximize radius physics di awal sebelum pengecekan
    maximizeFlingSimulationRadius()

    local myChar = localPlayer.Character
    local myRoot = getAnyPhysicalRootPart(myChar)
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local tRoot = getAnyPhysicalRootPart(tChar)
    if not myRoot or not myHum or not tRoot then
        logMessage("RootPart karakter/target tidak ditemukan!")
        showToast("Kick Gagal", "Part fisik karakter atau target tidak ditemukan", "danger")
        return
    end

    if not isTpKick then
        local currentDist = (myRoot.Position - tRoot.Position).Magnitude
        if currentDist > 25 then
            logMessage(string.format("Target terlalu jauh (%.1f stud)! Gunakan 'TP + Kick' atau dekati target.", currentDist))
            showToast("Jarak Terlalu Jauh", string.format("Jarak: %.0f stud. Dekati target untuk Kick Only!", currentDist), "warn")
            return
        end
    end

    local pName = customPower or State.FlingPower or "Rendah"
    local kickModeText = isTpKick and "TP + Kick" or "Kick Only"
    local wasFreezeInitially = (State.FreezeMode == "ON" or State.FreezeApplied)

    -- Kunci auto-freeze/auto-evade selama proses kick (sudah dipakai juga oleh engine lama)
    State.FlingExecuting = true
    if wasFreezeInitially then
        applyCharacterAnchored(false)
        task.wait(0.04)
    end

    local originalCF = myRoot.CFrame
    local targetStartPos = tRoot.Position
    local originalDestroyHeight = workspace.FallenPartsDestroyHeight

    logMessage(string.format("[%s] Menendang %s (Kekuatan: %s) — metode fling.lua...", kickModeText, targetPlr.DisplayName, tostring(pName)))
    showToast(kickModeText, string.format("Melontarkan %s (%s)...", targetPlr.DisplayName, tostring(pName)), "warn")

    -- Fase TP: langsung tempel ke tubuh target sebelum siklus penetrasi dimulai
    if isTpKick then
        pcall(function()
            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
        task.wait(0.04)
    end

    -- Cegah karakter terhapus saat ikut terlontar ke atas (dikembalikan saat selesai)
    pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
    maximizeFlingSimulationRadius()

    local active = true
    local connections = {}
    local offsetIndex = 1
    local startTime = tick()
    local heartbeatConn = nil

    -- Batas waktu tahan per kekuatan (fling.lua sendiri berhenti saat target sudah terlontar jauh)
    local holdTime = 1.0
    if pName == "Sedang" then
        holdTime = 1.35
    elseif pName == "Kuat" then
        holdTime = 1.7
    elseif pName == "Sangat Kuat" or pName == "Ekstrim" then
        holdTime = 2.1
    end

    -- Selama fase fling: seluruh part karakter non-collide agar bebas menembus target & lantai
    table.insert(connections, RunService.Stepped:Connect(function()
        if not active then return end
        local ch = localPlayer.Character
        if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end))

    local function stopFling()
        if not active then return end
        active = false

        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
        for _, c in ipairs(connections) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(connections)

        pcall(function() workspace.FallenPartsDestroyHeight = originalDestroyHeight end)

        -- Hitung perpindahan target sebelum apa pun dibersihkan
        local curTChar = targetPlr and targetPlr.Character
        local curTRoot = curTChar and curTChar:FindFirstChild("HumanoidRootPart")
        local curTHum = curTChar and curTChar:FindFirstChildOfClass("Humanoid")
        local finalDisplacement = 0
        if curTRoot and targetStartPos then
            finalDisplacement = (curTRoot.Position - targetStartPos).Magnitude
        elseif not curTRoot or (curTHum and curTHum.Health <= 0) then
            finalDisplacement = 999
        end

        local curChar = localPlayer.Character
        local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
        local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")

        -- 1. Bersihkan BodyMovers fling & nol-kan momentum
        if curRoot then
            for _, ch in ipairs(curRoot:GetChildren()) do
                if ch.Name == "FlingBAV" or ch.Name == "FlingBT" then ch:Destroy() end
            end
            pcall(function()
                curRoot.AssemblyLinearVelocity = Vector3.zero
                curRoot.AssemblyAngularVelocity = Vector3.zero
                curRoot.Velocity = Vector3.zero
                curRoot.RotVelocity = Vector3.zero
            end)
        end

        -- 2. Recall ke posisi awal (jika Auto Recall aktif) lalu tahan sejenak
        if curRoot then
            if isTpKick and State.FlingAutoRecall and originalCF then
                curRoot.CFrame = originalCF
                pcall(function()
                    curRoot.AssemblyLinearVelocity = Vector3.zero
                    curRoot.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            curRoot.Anchored = true
        end

        if curHum then
            pcall(function()
                curHum.PlatformStand = false
                curHum.Sit = false
                curHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                curHum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end

        -- 3. Kembalikan collision setelah momentum sisa diserap
        task.delay(0.35, function()
            local ch = localPlayer.Character
            if ch and ch.Parent then
                for _, p in ipairs(ch:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)

        -- 4. Freeze kembali sesuai kondisi awal
        if wasFreezeInitially or State.FreezeMode == "ON" then
            applyCharacterAnchored(true)
        else
            task.delay(0.4, function()
                local ch = localPlayer.Character
                local r = ch and ch:FindFirstChild("HumanoidRootPart")
                if r and r.Parent and not State.FreezeApplied and State.FreezeMode ~= "ON" then
                    pcall(function()
                        r.AssemblyLinearVelocity = Vector3.zero
                        r.AssemblyAngularVelocity = Vector3.zero
                        r.Anchored = false
                    end)
                end
            end)
        end

        State.FlingExecuting = false

        if finalDisplacement >= 40 or not curTRoot or (curTHum and curTHum.Health <= 0) then
            logMessage(string.format("✓ %s BERHASIL! Target %s terlontar sejauh %.0f stud!", kickModeText, targetPlr.DisplayName, finalDisplacement))
            showToast("Fling Berhasil!", string.format("✓ %s terlontar %.0f stud!", targetPlr.DisplayName, finalDisplacement), "success")
        else
            logMessage(string.format("⚠️ %s belum maksimal (Perpindahan: %.0f stud). Silakan coba 1x lagi!", kickModeText, finalDisplacement))
            showToast("Belum Maksimal", string.format("Lawan baru bergeser %.0f stud. Coba klik lagi!", finalDisplacement), "warn")
        end
    end

    -- FASE FLING: siklus penetrasi + torsi + dorongan vertikal (metode fling.lua)
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not active then return end

        local curTChar = targetPlr and targetPlr.Character
        local curTRoot = curTChar and curTChar:FindFirstChild("HumanoidRootPart")
        local curTHum = curTChar and curTChar:FindFirstChildOfClass("Humanoid")
        local curChar = localPlayer.Character
        local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
        local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")

        if not curRoot or not curHum or not curTRoot then
            stopFling()
            return
        end

        local displacement = (curTRoot.Position - targetStartPos).Magnitude
        local elapsed = tick() - startTime
        if displacement > 80 or curTRoot.Position.Y < -80 or (curTHum and curTHum.Health <= 0) or elapsed > holdTime then
            stopFling()
            return
        end

        maximizeFlingSimulationRadius()

        -- Humanoid tetap aktif (bukan ragdoll/PlatformStand) agar ownership fisika tetap penuh
        pcall(function()
            curHum.PlatformStand = false
            curHum.Sit = false
            curHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end)

        -- BodyMovers: torsi rotasi + dorongan vertikal
        local bav = curRoot:FindFirstChild("FlingBAV")
        if not bav then
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "FlingBAV"
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bav.AngularVelocity = Vector3.new(0, 999999, 0)
            bav.P = math.huge
            bav.Parent = curRoot
        end

        local bT = curRoot:FindFirstChild("FlingBT")
        if not bT then
            bT = Instance.new("BodyThrust")
            bT.Name = "FlingBT"
            bT.Force = Vector3.new(0, 999999, 0)
            bT.Location = Vector3.new(0, 0, 0)
            bT.Parent = curRoot
        end

        -- Penetrasi bergantian (Skid Cycle) di sekitar HumanoidRootPart target
        local currentOffset = FLING_METHOD_OFFSETS[offsetIndex]
        offsetIndex = (offsetIndex % #FLING_METHOD_OFFSETS) + 1

        local rotAngle = math.rad((tick() * 3600) % 360)
        local targetPredicted = curTRoot.CFrame * currentOffset * CFrame.Angles(rotAngle, rotAngle, rotAngle)
        curRoot.CFrame = targetPredicted

        local launchLinear = Vector3.new(0, 9e7, 0)
        local launchRot = Vector3.new(9e8, 9e8, 9e8)
        pcall(function()
            curRoot.AssemblyLinearVelocity = launchLinear
            curRoot.AssemblyAngularVelocity = launchRot
            curRoot.Velocity = launchLinear
            curRoot.RotVelocity = launchRot
        end)
    end)
end

-- Fitur Ragdoll Manual
local function triggerRagdoll(enable)
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if enable then
        -- Jika Anti-Ragdoll aktif, matikan dulu
        if State.AntiRagdollEnabled then
            State.AntiRagdollEnabled = false
            showToast("Anti-Ragdoll OFF", "Anti-Ragdoll dinonaktifkan untuk mengaktifkan Ragdoll", "info")
        end
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
            hum.PlatformStand = true
        end)
        showToast("Ragdoll Aktif", "Karakter Anda masuk mode ragdoll", "warn")
        logMessage("Ragdoll diaktifkan manual.")
    else
        pcall(function()
            hum.PlatformStand = false
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
        showToast("Ragdoll Nonaktif", "Karakter Anda bangun kembali", "success")
        logMessage("Ragdoll dinonaktifkan.")
    end
end

-- Fitur Anti-Ragdoll Otomatis
local _antiRagdollConn = nil
local function toggleAntiRagdoll(enable)
    State.AntiRagdollEnabled = enable
    if _antiRagdollConn then
        _antiRagdollConn:Disconnect()
        _antiRagdollConn = nil
    end

    local function protectHumanoid(hum)
        if not hum then return end
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            if hum.PlatformStand then hum.PlatformStand = false end
            if hum.Sit then hum.Sit = false end
        end)
    end

    if enable then
        local myChar = localPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        protectHumanoid(hum)

        _antiRagdollConn = RunService.Stepped:Connect(function()
            if not State.AntiRagdollEnabled then return end
            local c = localPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then
                protectHumanoid(h)
                local curState = h:GetState()
                if curState == Enum.HumanoidStateType.Ragdoll or curState == Enum.HumanoidStateType.FallingDown or curState == Enum.HumanoidStateType.PlatformStanding then
                    h:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
        logMessage("Anti-Ragdoll AKTIF! Kebal terpental / jatuh.")
        showToast("Anti-Ragdoll ON", "Kebal terhadap efek ragdoll & knockdown!", "success")
    else
        local myChar = localPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end)
        end
        logMessage("Anti-Ragdoll NONAKTIF.")
        showToast("Anti-Ragdoll OFF", "Anti-ragdoll dinonaktifkan", "info")
    end
end

-- Fitur In-Place Vibration Fling Target (Membuat Player Target Bergetar & Terpental Ekstrim di Tempatnya)
local _vibeFlingConn = nil
local function toggleInPlaceVibrationFling(enable, targetPlr)
    if enable then
        local tPlr = targetPlr or State.FlingTarget
        if not tPlr or not tPlr.Character then
            logMessage("Pilih target player terlebih dahulu!")
            showToast("Vibe Fling Gagal", "Pilih target player terlebih dahulu", "warn")
            State.VibeFlingActive = false
            return false
        end

        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tRoot = tPlr.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot or not tRoot then
            showToast("Vibe Fling Gagal", "RootPart tidak ditemukan", "danger")
            State.VibeFlingActive = false
            return false
        end

        State.VibeFlingActive = true
        if _vibeFlingConn then _vibeFlingConn:Disconnect(); _vibeFlingConn = nil end

        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                hum.PlatformStand = false
                hum.Sit = false
            end)
        end

        for _, ch in ipairs(myRoot:GetChildren()) do
            if ch.Name == "WW3_VibeFling" or ch.Name == "WW3_SafeFling" then ch:Destroy() end
        end

        local power = 100000
        local pName = State.FlingPower or "Rendah"
        if pName == "Rendah" then power = 30000
        elseif pName == "Sedang" then power = 70000
        elseif pName == "Kuat" then power = 140000
        elseif pName == "Sangat Kuat" or pName == "Ekstrim" then power = 280000 end

        local bRot = Instance.new("BodyAngularVelocity")
        bRot.Name = "WW3_VibeFling"
        bRot.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bRot.P = 1e6
        bRot.AngularVelocity = Vector3.new(power, power, power)
        bRot.Parent = myRoot

        local originalCF = myRoot.CFrame
        local step = 0
        local startTime = tick()

        logMessage(string.format("⚡ In-Place Vibration Fling pada %s DIMULAI (%s)!", tPlr.DisplayName, pName))
        showToast("Vibe Target ON", string.format("In-Place Vibration pada %s!", tPlr.DisplayName), "warn")

        _vibeFlingConn = RunService.Heartbeat:Connect(function()
            if not State.VibeFlingActive then
                if _vibeFlingConn then _vibeFlingConn:Disconnect(); _vibeFlingConn = nil end
                return
            end

            local curChar = localPlayer.Character
            local curMyRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
            local curTRoot = tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart")

            if not curMyRoot or not curTRoot then
                toggleInPlaceVibrationFling(false)
                return
            end

            step = step + 1

            -- Menempel tepat di hitbox target dengan mikrovibrasi bolak-balik frekuensi tinggi (In-Place Vibration)
            -- Membombardir fisika target dengan ribuan impuls angular per detik sehingga karakter target bergetar hebat & mental
            local vibeOffset = ((step % 2 == 0) and 0.04 or -0.04)
            local vibeVertical = ((step % 4 < 2) and 0.05 or -0.05)
            curMyRoot.CFrame = CFrame.new(curTRoot.Position + Vector3.new(vibeOffset, vibeVertical, vibeOffset))

            pcall(function()
                curMyRoot.AssemblyAngularVelocity = Vector3.new(power, power, power)
                curMyRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end)
        return true
    else
        State.VibeFlingActive = false
        if _vibeFlingConn then
            _vibeFlingConn:Disconnect()
            _vibeFlingConn = nil
        end

        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, ch in ipairs(myRoot:GetChildren()) do
                if ch.Name == "WW3_VibeFling" or ch.Name == "WW3_SafeFling" then ch:Destroy() end
            end
            pcall(function()
                myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end

        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if hum and not State.AntiRagdollEnabled then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end)
        end

        logMessage("In-Place Vibration Fling pada target dihentikan.")
        showToast("Vibe Target OFF", "In-Place Vibration Fling dihentikan.", "info")
        return false
    end
end

-- ====================================================================================================
-- RAM & FPS SAVER ENGINE (Pembersih Puing, Asap & Partikel Ledakan Lokal)
-- ====================================================================================================
local _fpsCleanerThread = nil

local function cleanExplosionDebris()
    pcall(function()
        -- Hapus puing/debris partikel pecahan bangunan di Workspace
        for _, obj in ipairs(Workspace:GetChildren()) do
            local name = obj.Name:lower()
            if obj:IsA("Debris") or name:find("debris") or name:find("rubble") or name:find("fragment") or name:find("particlegroup") then
                pcall(function() obj:Destroy() end)
            end
        end

        -- Matikan particle emitter asap/api roket lokal jika FPS Saver aktif
        if State.FpsSaverEnabled then
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("ParticleEmitter") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then
                    pcall(function() desc.Enabled = false end)
                end
            end
        end
    end)
end

local function toggleFpsSaver(enable)
    if enable == nil then enable = not State.FpsSaverEnabled end
    State.FpsSaverEnabled = enable

    if enable then
        cleanExplosionDebris()
        if not _fpsCleanerThread then
            _fpsCleanerThread = task.spawn(function()
                while State.FpsSaverEnabled do
                    task.wait(2.5) -- Rutin bersihkan sampah ledakan setiap 2.5 detik
                    cleanExplosionDebris()
                end
                _fpsCleanerThread = nil
            end)
        end
        logMessage("⚡ [RAM SAVER] Pembersih Puing & Partikel Ledakan Diaktifkan.")
        showToast("RAM & FPS Saver: ON", "Puing & partikel ledakan otomatis dibersihkan!", "success")
    else
        State.FpsSaverEnabled = false
        logMessage("⚡ [RAM SAVER] Dinonaktifkan.")
        showToast("RAM Saver: OFF", "Penghemat memori dinonaktifkan.", "info")
    end

    if State.UI and State.UI.UpdateFpsSaverBtns then
        pcall(State.UI.UpdateFpsSaverBtns)
    end
    return enable
end

-- ====================================================================================================
-- SISTEM OPTIMASI GRAFIK RINGAN: PAUSE LAUT & HILANGKAN SHADOW
-- ====================================================================================================
local _terrainInstance = Workspace:FindFirstChildOfClass("Terrain")
local _origTerrainProps = {
    WaterWaveSpeed = 10,
    WaterWaveSize = 0.15,
    WaterReflectance = 1,
    WaterTransparency = 0.3
}
if _terrainInstance then
    pcall(function()
        _origTerrainProps.WaterWaveSpeed = _terrainInstance.WaterWaveSpeed
        _origTerrainProps.WaterWaveSize = _terrainInstance.WaterWaveSize
        _origTerrainProps.WaterReflectance = _terrainInstance.WaterReflectance
        _origTerrainProps.WaterTransparency = _terrainInstance.WaterTransparency
    end)
end

-- 1. PAUSE / MATIKAN ANIMASI LAUT (WAVES & REFLECTION)
local function toggleSeaAnimation(disable)
    if disable == nil then disable = not State.SeaDisabled end
    State.SeaDisabled = disable

    if _terrainInstance then
        pcall(function()
            if disable then
                _terrainInstance.WaterWaveSpeed = 0
                _terrainInstance.WaterWaveSize = 0
                _terrainInstance.WaterReflectance = 0
            else
                _terrainInstance.WaterWaveSpeed = _origTerrainProps.WaterWaveSpeed or 10
                _terrainInstance.WaterWaveSize = _origTerrainProps.WaterWaveSize or 0.15
                _terrainInstance.WaterReflectance = _origTerrainProps.WaterReflectance or 1
            end
        end)
    end
    return disable
end

-- 2. HILANGKAN SHADOW & ULTRA LOW LIGHTING
local function toggleUltraLowLighting(enable)
    if enable == nil then enable = not State.UltraLowLighting end
    State.UltraLowLighting = enable
    local Lighting = game:GetService("Lighting")
    pcall(function()
        if enable then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 2
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") then
                    v.Enabled = false
                end
            end
        else
            Lighting.GlobalShadows = true
            Lighting.Brightness = 1
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") then
                    v.Enabled = true
                end
            end
        end
    end)
    return enable
end



-- Background Loop: Auto Freeze (Hanya aktif saat mode ON / Auto; Tidur lelap saat OFF)
task.spawn(function()
    while true do
        if State.FreezeMode == "OFF" or State.FlingExecuting or State.VibeFlingActive then
            if State.FreezeApplied then applyCharacterAnchored(false) end
            task.wait(1.5) -- Tidur lelap tanpa kalkulasi CPU saat Freeze OFF
        else
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                if State.FreezeMode == "ON" then
                    if not State.FreezeApplied then applyCharacterAnchored(true) end
                    task.wait(0.5)
                elseif State.FreezeMode == "Auto" then
                    if not State.FreezeApplied then applyCharacterAnchored(true) end

                    local nowAuto = tick()
                    if nowAuto - (State.FreezeAutoLastCycle or 0) >= 5 then
                        State.FreezeAutoLastCycle = nowAuto
                        applyCharacterAnchored(false)
                        task.wait(0.12)
                        if State.FreezeMode == "Auto" and not State.FlingExecuting and not State.VibeFlingActive then
                            applyCharacterAnchored(true)
                        end
                        logMessage("🛡️ [AUTO FREEZE] Re-freeze tiap 5 detik (karakter respawn langsung terkunci).")
                    end
                    task.wait(0.2)
                end
            else
                task.wait(0.5)
            end
        end
    end
end)

-- ====================================================================================================
-- AUTOMATION BACKGROUND TASKS
-- ====================================================================================================
local _RefillBuying = false
task.spawn(function()
    while true do
        task.wait(1.2)
        if State.RefillEnabled and not State.AutoBuyActive and not _RefillBuying then
            local missile = MISSILE_BY_ID[State.RefillMissileId] or MISSILES[State.SelectedMissileIndex] or MISSILES[1]
            local currentStock = getMissileStock(missile)
            local diff = (State.RefillTargetStock or 10) - currentStock

            if diff > 0 then
                local batchQty = math.min(diff, 25)
                logMessage(string.format("Refill: Stok %s (%d < target %d), membeli batch %d unit...", missile.Name, currentStock, State.RefillTargetStock, batchQty))

                if Remotes.MilitaryStore then
                    _RefillBuying = true
                    local n5 = math.floor(batchQty / 5)
                    local n1 = batchQty % 5

                    local payloadX5 = {
                        Category = "Rockets",
                        ItemId = missile.Id,
                        BuyAmount = 5,
                        ButtonName = "BtnBuy5",
                        PriceKind = "Cash",
                        Amount = 5,
                        Count = 5,
                        MilitaryStoreCategory = "Rockets",
                        MilitaryStoreItemId = missile.Id,
                        MilitaryStoreButtonName = "BtnBuy5",
                        MilitaryStorePriceKind = "Cash"
                    }
                    local payloadX1 = {
                        Category = "Rockets",
                        ItemId = missile.Id,
                        BuyAmount = 1,
                        ButtonName = "BtnBuy1",
                        PriceKind = "Cash",
                        Amount = 1,
                        Count = 1,
                        MilitaryStoreCategory = "Rockets",
                        MilitaryStoreItemId = missile.Id,
                        MilitaryStoreButtonName = "BtnBuy1",
                        MilitaryStorePriceKind = "Cash"
                    }

                    for i = 1, n5 do
                        if not State.RefillEnabled then break end
                        pcall(function() Remotes.MilitaryStore:FireServer("Buy", payloadX5) end)
                        local checkStock = getMissileStock(missile)
                        if checkStock >= State.RefillTargetStock then
                            logMessage(string.format("🛑 Refill %s: Target tercapai (%d >= %d), stop pembelian.", missile.Name, checkStock, State.RefillTargetStock))
                            break
                        end
                        task.wait(0.08)
                    end

                    local checkStock = getMissileStock(missile)
                    if State.RefillEnabled and checkStock < State.RefillTargetStock then
                        for i = 1, n1 do
                            if not State.RefillEnabled then break end
                            pcall(function() Remotes.MilitaryStore:FireServer("Buy", payloadX1) end)
                            task.wait(0.08)
                        end
                    end

                    task.wait(0.3)
                    _RefillBuying = false
                end
            end
        end
    end
end)

local _isAutoDeployBusy = false
task.spawn(function()
    while true do
        -- Interval cerdas: Jika AutoDeploy tidak aktif atau sedang sibuk, tunggu 1 detik
        if not State.AutoDeployActive or _isAutoDeployBusy then
            task.wait(1.0)
        elseif State.DeploySmartQueue and State._IsLaunching then
            -- SMART QUEUE: Tahan deploy saat salvo roket sedang meluncur agar CPU tidak bentrok & lag
            task.wait(1.0)
        else
            local baseData = getMyBaseData()
            local maxRockets = (baseData and baseData.MaxRockets) or (State.Unlock150Missiles and 150 or 100)
            local curRockets = (baseData and baseData.CurrentRockets) or 0

            -- JIKA BASE SUDAH PENUH: Tidur 3 detik tanpa kalkulasi apa pun (0% CPU load!)
            if curRockets >= maxRockets then
                task.wait(3.0)
            else
                local chosenId = next(State.SelectedMissileTypes)
                local missile = (chosenId and MISSILE_BY_ID[chosenId]) or MISSILES[State.SelectedMissileIndex] or MISSILES[1]
                local currentStock = getMissileStock(missile)

                if baseData and currentStock > 0 then
                    local quota = math.min(currentStock, maxRockets - curRockets, 50)
                    _isAutoDeployBusy = true
                    task.spawn(function()
                        executeDeployVerified(baseData, missile, quota, State.DeployPosition, State.DeployAlign, State.DeploySpeed or "Ultra")
                        _isAutoDeployBusy = false
                    end)
                    -- Setelah deploy, beri jeda wajar 3-4 detik sebelum deploy berikutnya
                    task.wait(3.5)
                else
                    task.wait(2.0)
                end
            end
        end
    end
end)

local function runAutonomousAttack()
    if State.AutoAttackActive then
        State.AutoAttackActive = false
        logMessage("Auto Attack dihentikan.")
        return
    end
    State.AutoAttackActive = true
    logMessage("⚡ Mode Serang Otonomus Dimulai!")

    -- Thread 1: Monitor Status Target tiap 1 detik (Shield aktif atau kabur/keluar)
    task.spawn(function()
        while State.AutoAttackActive do
            task.wait(1.0)
            local allBases = scanAllBases()
            local targetBase = allBases[State.SelectedBaseIndex]

            -- Cek 1: Apakah musuh kabur / base hilang / kosong
            if not targetBase or targetBase.Owner == "Vacant" or targetBase.Owner == "Empty" or #targetBase.Owner <= 1 then
                logMessage("🛑 [CEK TARGET] Lawan kabur atau keluar game! Serangan dihentikan.")
                State.AutoAttackActive = false
                break
            end

            -- Cek 2: Apakah lawan menyalakan Shield
            if targetBase.HasShield then
                logMessage(string.format("🛑 [CEK TARGET] %s (Base %d) MENGAKTIFKAN SHIELD! Seluruh serangan dihentikan.", targetBase.Owner, State.SelectedBaseIndex))
                State.AutoAttackActive = false
                break
            end
        end
    end)

    -- Thread 2: Eksekusi Serangan
    task.spawn(function()
        while State.AutoAttackActive do
            local baseData = getMyBaseData()
            local allBases = scanAllBases()
            local targetBase = allBases[State.SelectedBaseIndex]

            if not targetBase or targetBase.IsLocal or targetBase.TotalTargets == 0 then
                logMessage("Target base tidak valid / seluruh pertahanan hancur!")
                State.AutoAttackActive = false
                break
            end

            if targetBase.HasShield then
                logMessage("Target memakai shield! Menghentikan serangan.")
                State.AutoAttackActive = false
                break
            end

            -- Dapatkan roket yang HANYA dipilih oleh user
            local deployedRockets = getMyPlacedRockets()
            local usableRockets = {}
            for _, r in ipairs(deployedRockets) do
                if State.SelectedMissileTypes[r.ItemId] or next(State.SelectedMissileTypes) == nil then
                    table.insert(usableRockets, r)
                end
            end

            -- Jika roket terpilih habis di base, lakukan auto-deploy dari tas atau auto-buy
            if #usableRockets == 0 then
                local chosenId = next(State.SelectedMissileTypes)
                local chosenItem = (chosenId and MISSILE_BY_ID[chosenId]) or MISSILES[State.SelectedMissileIndex] or MISSILES[1]
                logMessage(string.format("⚠️ [OTONOMUS] Roket %s habis di base! Memeriksa tas & toko...", chosenItem.Name))
                showToast("Amunisi Habis", "Mencoba isi ulang " .. chosenItem.Name .. "...", "warn")
                local refilled = ensureMissilesReady(chosenItem, 10)
                if refilled then
                    deployedRockets = getMyPlacedRockets()
                    for _, r in ipairs(deployedRockets) do
                        if State.SelectedMissileTypes[r.ItemId] or next(State.SelectedMissileTypes) == nil then
                            table.insert(usableRockets, r)
                        end
                    end
                end
            end

            if #usableRockets == 0 then
                logMessage("🛑 [OTONOMUS] Tidak ada roket terpilih yang tersedia di base/tas!"); State.AutoAttackActive = false; break
            end

            -- Kumpulkan seluruh sasaran nyata yang masih hidup (Bangunan, Anti-Air, Anti-Sea)
            local validTargets = {}
            for _, b in ipairs(targetBase.Buildings or {}) do
                if b.HP and b.HP > 0 and b.Instance and b.Instance.Parent then
                    table.insert(validTargets, b)
                end
            end
            for _, aa in ipairs(targetBase.AntiAir or {}) do
                if aa.HP and aa.HP > 0 and aa.Instance and aa.Instance.Parent then
                    table.insert(validTargets, aa)
                end
            end
            for _, as in ipairs(targetBase.AntiShip or {}) do
                if as.HP and as.HP > 0 and as.Instance and as.Instance.Parent then
                    table.insert(validTargets, as)
                end
            end

            if #validTargets > 0 then
                -- Pilih sasaran nyata secara acak di antara yang masih berdiri
                local randomIdx = math.random(1, #validTargets)
                local tgt = validTargets[randomIdx]

                -- Pastikan objek target masih ada di game dan bukan tanah kosong
                if tgt and tgt.Instance and tgt.Instance.Parent then
                    local volleySize = math.min(#usableRockets, State.ManualLaunchVolley or 5)
                    if State.CustomMissileQuota and State.CustomMissileQuota > 0 then
                        volleySize = math.min(volleySize, State.CustomMissileQuota)
                    end

                    local group = {}
                    for idx = 1, volleySize do table.insert(group, usableRockets[idx]) end

                    logMessage(string.format("🎲 [OTONOMUS RANDOM] Menyerang %s (%s, HP: %d) dengan salvo %d roket...", tgt.Name, tgt.Kind or "Build", tgt.HP or 0, #group))
                    launchMissileVolley(tgt, group, State.AutoBreakShield)
                end
            else
                logMessage("🏆 Otonomus: Seluruh bangunan & pertahanan musuh telah hancur rata!")
                showToast("Pangkalan Rata!", "Seluruh sasaran di base lawan telah hancur total!", "success")
                State.AutoAttackActive = false
                break
            end
            task.wait(1.0)
        end
    end)
end

-- ====================================================================================================
-- AUTO FARM ADVANCED ENGINE (PORTED FROM autofarm.lua)
-- ====================================================================================================
local AutoFarmAdv = {
    RunId = 0,
    Busy = false,
    Queue = {},
    Eligible = {},
    SentUids = {},
    LastNotify = {},
    LastScanCount = -1,
    LastFleet = nil,
    LastBaseScans = {},
    TargetCooldown = {},
    StatusText = "Siap. Tekan START.",
    StatusKind = "idle",
    UI = {}
}

function AutoFarmAdv.setStatus(text, kind)
    AutoFarmAdv.StatusText = tostring(text or "")
    AutoFarmAdv.StatusKind = kind or "idle"
    if AutoFarmAdv.UI.StatusMain then
        local colors = {
            ok = Color3.fromRGB(0, 190, 120),
            attack = Color3.fromRGB(0, 200, 255),
            warn = Color3.fromRGB(255, 180, 40),
            danger = Color3.fromRGB(225, 55, 70),
            idle = Color3.fromRGB(145, 168, 195),
        }
        AutoFarmAdv.UI.StatusMain.Text = AutoFarmAdv.StatusText
        AutoFarmAdv.UI.StatusMain.TextColor3 = colors[kind or "idle"] or colors.idle
    end
end

function AutoFarmAdv.collectReadyShips()
    local ships = getMyPlacedWarships()
    local ready = {}
    local now = tick()
    local cd = math.max(1, State.FarmSentCooldown or 20)
    for _, ws in ipairs(ships) do
        if ws.IsReady then
            local sentAt = AutoFarmAdv.SentUids[ws.Uid]
            if not sentAt or (now - sentAt) >= cd then
                table.insert(ready, ws)
            end
        end
    end
    return ready
end

function AutoFarmAdv.countFleet()
    local ships = getMyPlacedWarships()
    local now = tick()
    local cd = math.max(1, State.FarmSentCooldown or 20)
    local data = { Ready = {}, Repair = 0, Reload = 0, Mission = 0, Cooldown = 0 }

    for _, ws in ipairs(ships) do
        if ws.IsReady then
            local sentAt = AutoFarmAdv.SentUids[ws.Uid]
            if sentAt and (now - sentAt) < cd then
                data.Cooldown = data.Cooldown + 1
            else
                table.insert(data.Ready, ws)
            end
        elseif ws.IsOnMission then
            data.Mission = data.Mission + 1
        elseif ws.IsRepairing or (ws.HPPercent or 100) < 100 then
            data.Repair = data.Repair + 1
        else
            data.Reload = data.Reload + 1
        end
    end

    AutoFarmAdv.LastFleet = data
    return data
end

function AutoFarmAdv.requirementText()
    local minLevel = tonumber(State.FarmMinBuildLevel) or 0
    local minB = tonumber(State.FarmMinBuildings) or 45
    if minLevel > 0 then
        return string.format("≥%d bgn lv≥%d", minB, minLevel)
    end
    return string.format("≥%d bangunan", minB)
end

function AutoFarmAdv.evaluateBase(baseData)
    if not baseData then return nil, "empty" end
    if baseData.IsLocal then return nil, "self" end

    local ownerUserId = tonumber(baseData.OwnerUserId)
    if not ownerUserId or ownerUserId <= 0 or (localPlayer and ownerUserId == localPlayer.UserId) then
        return nil, "empty"
    end
    if not Players:GetPlayerByUserId(ownerUserId) then
        return nil, "offline"
    end

    local owner = tostring(baseData.Owner or "")
    local ownerLower = owner:lower()
    if owner == "" or ownerLower == "kosong" or ownerLower == "vacant" or ownerLower == "empty" or ownerLower == "none" then
        return nil, "empty"
    end

    if baseData.HasShield then
        return nil, "shield"
    end

    local minLevel = tonumber(State.FarmMinBuildLevel) or 0
    local aliveBuildings = 0
    local levelBuildings = 0
    local highestLevel = 0
    local aliveAntiAir = 0
    local aliveAntiShip = 0

    for _, building in ipairs(baseData.Buildings or {}) do
        if (tonumber(building.HP) or 0) > 0 then
            aliveBuildings = aliveBuildings + 1
            local buildingLevel = tonumber(building.Level) or 0
            if buildingLevel > highestLevel then highestLevel = buildingLevel end
            if minLevel <= 0 or buildingLevel >= minLevel then
                levelBuildings = levelBuildings + 1
            end
        end
    end
    for _, defense in ipairs(baseData.AntiAir or {}) do
        if (tonumber(defense.HP) or 0) > 0 then aliveAntiAir = aliveAntiAir + 1 end
    end
    for _, defense in ipairs(baseData.AntiShip or {}) do
        if (tonumber(defense.HP) or 0) > 0 then aliveAntiShip = aliveAntiShip + 1 end
    end

    if aliveAntiAir > 0 or aliveAntiShip > 0 then
        return nil, "defense"
    end
    local reqB = tonumber(State.FarmMinBuildings) or 45
    if levelBuildings < reqB then
        if minLevel > 0 and aliveBuildings >= reqB then
            return nil, "level"
        end
        return nil, "buildings"
    end

    return {
        Base = baseData,
        Index = baseData.Index,
        Owner = owner,
        OwnerUserId = ownerUserId,
        Buildings = levelBuildings,
        AliveBuildings = aliveBuildings,
        HighestLevel = highestLevel,
        MinLevel = minLevel,
        AntiAir = aliveAntiAir,
        AntiShip = aliveAntiShip,
    }
end

function AutoFarmAdv.refreshTargets(initial)
    if not State.FarmRunning then return end

    local allBases = scanAllBases()
    local found = {}
    local stats = { valid = 0, shield = 0, defense = 0, buildings = 0, level = 0, empty = 0, offline = 0 }

    for _, baseData in ipairs(allBases) do
        local evaluation, reason = AutoFarmAdv.evaluateBase(baseData)
        if evaluation then
            found[baseData.Index] = evaluation
            stats.valid = stats.valid + 1
        elseif stats[reason] then
            stats[reason] = stats[reason] + 1
        end
    end

    local oldQueue = {}
    for _, idx in ipairs(AutoFarmAdv.Queue) do table.insert(oldQueue, idx) end
    table.clear(AutoFarmAdv.Queue)
    table.clear(AutoFarmAdv.Eligible)

    local queued = {}
    for _, index in ipairs(oldQueue) do
        if found[index] and not queued[index] then
            table.insert(AutoFarmAdv.Queue, index)
            queued[index] = true
        end
    end
    for _, baseData in ipairs(allBases) do
        if found[baseData.Index] and not queued[baseData.Index] then
            table.insert(AutoFarmAdv.Queue, baseData.Index)
            queued[baseData.Index] = true
        end
    end

    table.clear(AutoFarmAdv.LastBaseScans)
    for _, baseData in ipairs(allBases) do
        local aliveBuildings = 0
        local levelBuildings = 0
        local minLv = tonumber(State.FarmMinBuildLevel) or 0
        for _, b in ipairs(baseData.Buildings or {}) do
            if (tonumber(b.HP) or 0) > 0 then
                aliveBuildings = aliveBuildings + 1
                if minLv <= 0 or (tonumber(b.Level) or 0) >= minLv then
                    levelBuildings = levelBuildings + 1
                end
            end
        end
        AutoFarmAdv.LastBaseScans[baseData.Index] = {
            Index = baseData.Index,
            Owner = baseData.Owner,
            IsLocal = baseData.IsLocal,
            HasShield = baseData.HasShield,
            AliveBuildings = aliveBuildings,
            LevelBuildings = levelBuildings,
            AntiAir = #baseData.AntiAir,
            AntiShip = #baseData.AntiShip,
            IsEligible = (found[baseData.Index] ~= nil),
        }
    end

    for k, v in pairs(found) do AutoFarmAdv.Eligible[k] = v end

    local targetCount = #AutoFarmAdv.Queue
    AutoFarmAdv.LastScanCount = targetCount
    if targetCount == 0 then
        if State.FarmRunning then
            AutoFarmAdv.setStatus("Menunggu target layak...", "warn")
        end
    else
        if State.FarmRunning then
            AutoFarmAdv.setStatus(string.format("%d target layak siap diserang.", targetCount), "ok")
        end
    end
    AutoFarmAdv.updateStatus()
end

function AutoFarmAdv.pickTarget(served)
    local queue = AutoFarmAdv.Queue
    local i = 1
    local now = tick()
    local cooldownDuration = math.max(5, State.FarmScanInterval or 30)

    while i <= #queue do
        local index = queue[i]
        local lastAttacked = AutoFarmAdv.TargetCooldown and AutoFarmAdv.TargetCooldown[index]
        if served[index] or (lastAttacked and (now - lastAttacked) < cooldownDuration) then
            i = i + 1
        else
            local all = scanAllBases()
            local liveBase = all[index]
            local evaluation = AutoFarmAdv.evaluateBase(liveBase)
            if evaluation then
                AutoFarmAdv.Eligible[index] = evaluation
                return index, i
            else
                table.remove(queue, i)
                AutoFarmAdv.Eligible[index] = nil
            end
        end
    end
    return nil
end

function AutoFarmAdv.rotateTarget(index, position)
    local queue = AutoFarmAdv.Queue
    if position and queue[position] == index then
        table.remove(queue, position)
    else
        for i, value in ipairs(queue) do
            if value == index then
                table.remove(queue, i)
                break
            end
        end
    end
    table.insert(queue, index)
end

function AutoFarmAdv.pruneSentShips()
    local now = tick()
    for uid, sentAt in pairs(AutoFarmAdv.SentUids) do
        if (now - sentAt) > 180 then
            AutoFarmAdv.SentUids[uid] = nil
        end
    end
end

function AutoFarmAdv.dispatchAuto()
    if not State.FarmRunning or AutoFarmAdv.Busy then return end
    AutoFarmAdv.Busy = true

    local minShips = math.max(1, tonumber(State.FarmMinShips) or 6)
    local maxShips = math.max(minShips, tonumber(State.FarmMaxShips) or 8)

    AutoFarmAdv.pruneSentShips()
    local readyShips = AutoFarmAdv.collectReadyShips()

    if #readyShips < minShips then
        local fleet = AutoFarmAdv.countFleet()
        AutoFarmAdv.setStatus(string.format("Menunggu kapal siap (%d/%d)...", #readyShips, minShips), "warn")
        AutoFarmAdv.updateStatus()
        AutoFarmAdv.Busy = false
        return
    end

    if #AutoFarmAdv.Queue == 0 then
        AutoFarmAdv.setStatus("Menunggu target layak...", "warn")
        AutoFarmAdv.updateStatus()
        AutoFarmAdv.Busy = false
        return
    end

    local remaining = #readyShips
    local cursor = 1
    local served = {}
    local totalSent = 0

    while remaining >= minShips and State.FarmRunning do
        local targetIndex, queuePosition = AutoFarmAdv.pickTarget(served)
        if not targetIndex then break end

        local evaluation = AutoFarmAdv.Eligible[targetIndex]
        local limitPerTarget = math.min(maxShips, remaining)
        local group = {}

        for i = 1, limitPerTarget do
            if readyShips[cursor] then
                table.insert(group, readyShips[cursor])
                cursor = cursor + 1
            end
        end

        if #group == 0 then break end

        AutoFarmAdv.setStatus(string.format("Menyerang %s (%d kapal)...", evaluation.Owner, #group), "attack")
        logMessage(string.format("🚢 [AUTO FARM] Menyerang %s (Base %d, %d bangunan) dengan %d warship...",
            evaluation.Owner, evaluation.Index, evaluation.Buildings, #group))

        local anyFired = launchWarshipArmada(evaluation.Base, group, State.AutoBreakShield)
        if anyFired then
            local now = tick()
            for _, ws in ipairs(group) do
                AutoFarmAdv.SentUids[ws.Uid] = now
            end
            totalSent = totalSent + #group
            remaining = remaining - #group
            served[targetIndex] = true
            AutoFarmAdv.TargetCooldown[targetIndex] = now
            AutoFarmAdv.rotateTarget(targetIndex, queuePosition)

            showToast("Serangan Dikirim", string.format("%d warship meluncur ke Base %d (%s)!", #group, evaluation.Index, evaluation.Owner), "success")
            AutoFarmAdv.updateStatus()
            task.wait(1.2)
        else
            logMessage("⚠️ [AUTO FARM] Peluncuran warship armada gagal atau remote menolak.")
            break
        end

        break
    end

    if totalSent == 0 and #AutoFarmAdv.Queue > 0 then
        AutoFarmAdv.setStatus("Menunggu target / armada...", "warn")
    end

    if remaining > 0 and remaining < minShips and totalSent > 0 then
        AutoFarmAdv.setStatus(string.format("%d warship ditahan (min %d).", remaining, minShips), "warn")
    end

    AutoFarmAdv.updateStatus()
    AutoFarmAdv.Busy = false
end

function AutoFarmAdv.updateStatus()
    local eligibleCount = #AutoFarmAdv.Queue
    local fleet = AutoFarmAdv.countFleet()

    if AutoFarmAdv.UI.StatusDetail1 then
        AutoFarmAdv.UI.StatusDetail1.Text = string.format("Target: %d  •  Siap: %d", eligibleCount, #fleet.Ready)
    end
    if AutoFarmAdv.UI.StatusDetail2 then
        AutoFarmAdv.UI.StatusDetail2.Text = string.format("Repair: %d  •  Reload: %d  •  Misi: %d", fleet.Repair, fleet.Reload, fleet.Mission)
    end
    if AutoFarmAdv.UI.StatusDetail3 then
        if eligibleCount == 0 then
            AutoFarmAdv.UI.StatusDetail3.Text = string.format("Belum ada target %s tanpa AA/AS.", AutoFarmAdv.requirementText())
        else
            local names = {}
            for i = 1, math.min(eligibleCount, 3) do
                local ev = AutoFarmAdv.Eligible[AutoFarmAdv.Queue[i]]
                table.insert(names, ev and ev.Owner or ("Base " .. tostring(AutoFarmAdv.Queue[i])))
            end
            if eligibleCount > 3 then
                table.insert(names, "+" .. tostring(eligibleCount - 3))
            end
            AutoFarmAdv.UI.StatusDetail3.Text = "Antrean: " .. table.concat(names, " → ")
        end
    end
    if AutoFarmAdv.UI.StartBtn then
        AutoFarmAdv.UI.StartBtn.Text = State.FarmRunning and "⏹️ STOP AUTO FARM" or "▶️ START AUTO FARM"
        AutoFarmAdv.UI.StartBtn.BackgroundColor3 = State.FarmRunning and Color3.fromRGB(200, 40, 60) or Color3.fromRGB(0, 180, 100)
    end

    -- Update info bangunan masing-masing base di grid
    if AutoFarmAdv.UI.BaseRows then
        local minLv = tonumber(State.FarmMinBuildLevel) or 0
        for i = 1, 6 do
            local row = AutoFarmAdv.UI.BaseRows[i]
            if row then
                local data = AutoFarmAdv.LastBaseScans[i]
                if data then
                    local ownerShort = data.Owner or "Kosong"
                    if #ownerShort > 10 then ownerShort = ownerShort:sub(1, 9) .. "…" end

                    local buildStr = tostring(data.AliveBuildings or 0)
                    if minLv > 0 then
                        buildStr = string.format("%d (≥lv%d: %d)", data.AliveBuildings or 0, minLv, data.LevelBuildings or 0)
                    end

                    row.NameLabel.Text = string.format("B%d: %s", i, ownerShort)
                    row.CountLabel.Text = buildStr

                    if data.IsLocal then
                        row.NameLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                        row.CountLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                    elseif data.IsEligible then
                        row.NameLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
                        row.CountLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
                    elseif data.HasShield then
                        row.NameLabel.TextColor3 = Color3.fromRGB(255, 180, 40)
                        row.CountLabel.TextColor3 = Color3.fromRGB(255, 180, 40)
                    else
                        row.NameLabel.TextColor3 = Color3.fromRGB(145, 168, 195)
                        row.CountLabel.TextColor3 = Color3.fromRGB(230, 240, 255)
                    end
                else
                    row.NameLabel.Text = string.format("B%d: -", i)
                    row.CountLabel.Text = "-"
                    row.NameLabel.TextColor3 = Color3.fromRGB(145, 168, 195)
                    row.CountLabel.TextColor3 = Color3.fromRGB(145, 168, 195)
                end
            end
        end
    end
end

local function runAutoFarming(uiBtn)
    if State.FarmRunning then
        State.FarmRunning = false
        AutoFarmAdv.RunId = AutoFarmAdv.RunId + 1
        AutoFarmAdv.Busy = false
        table.clear(AutoFarmAdv.Queue)
        table.clear(AutoFarmAdv.Eligible)
        table.clear(AutoFarmAdv.SentUids)
        table.clear(AutoFarmAdv.TargetCooldown)
        AutoFarmAdv.LastFleet = nil

        AutoFarmAdv.setStatus("Auto farm dihentikan.", "idle")
        logMessage("⏹️ Auto Farm Advanced dihentikan.")
        showToast("Auto Farm Stop", "Sesi auto farming dihentikan", "info")
        AutoFarmAdv.updateStatus()
        return
    end

    if not getMyBaseData() then
        showToast("Base Tidak Ditemukan", "Pangkalan milik Anda belum terdeteksi di Workspace!", "danger")
        return
    end

    State.FarmRunning = true
    AutoFarmAdv.RunId = AutoFarmAdv.RunId + 1
    AutoFarmAdv.Busy = false
    AutoFarmAdv.LastScanCount = -1
    local currentRunId = AutoFarmAdv.RunId

    AutoFarmAdv.setStatus("Memindai target...", "ok")
    logMessage("▶️ Auto Farm Advanced dimulai (Mode Otomatis non-stop).")
    showToast("Auto Farm AKTIF", "Mode Otomatis Advanced aktif!", "success")
    AutoFarmAdv.updateStatus()

    AutoFarmAdv.refreshTargets(true)

    -- Loop Scan Target
    task.spawn(function()
        while State.FarmRunning and AutoFarmAdv.RunId == currentRunId do
            local interval = math.max(5, tonumber(State.FarmScanInterval) or 30)
            task.wait(interval)
            if not State.FarmRunning or AutoFarmAdv.RunId ~= currentRunId then break end
            AutoFarmAdv.refreshTargets(false)
        end
    end)

    -- Loop Dispatch Armada
    task.spawn(function()
        task.wait(1.5)
        while State.FarmRunning and AutoFarmAdv.RunId == currentRunId do
            AutoFarmAdv.dispatchAuto()
            local interval = math.max(3, tonumber(State.FarmFleetCheck) or 10)
            task.wait(interval)
        end
    end)
end

local getRankedAAClusters = nil

local function generateBaseDefenseAnalysis(targetBaseIndex)
    local all = scanAllBases()
    local b = all[targetBaseIndex or State.SelectedBaseIndex]
    if not b then
        return "Base tidak ditemukan atau belum termuat."
    end
    if b.IsLocal then
        return string.format("⚠️ Base %d adalah pangkalan Anda sendiri. Silakan pilih base lawan.", targetBaseIndex or State.SelectedBaseIndex)
    end

    local baseModel = b.Model
    local pa = baseModel and (baseModel:FindFirstChild("PlacementArea") or baseModel.PrimaryPart)
    local baseCF = pa and pa.CFrame or CFrame.new(b.Position)
    local baseLen = (pa and pa.Size and pa.Size.Z) or 200

    local function getZoneName(pos)
        if not pos then return "Tengah" end
        local rel = baseCF:PointToObjectSpace(pos)
        local normZ = rel.Z / (baseLen / 2)
        if normZ > 0.33 then
            return "Belakang"
        elseif normZ < -0.33 then
            return "Depan"
        else
            return "Tengah"
        end
    end

    local zones = {
        Belakang = { AA = 0, AADps = 0, AS = 0, ASDps = 0 },
        Tengah = { AA = 0, AADps = 0, AS = 0, ASDps = 0 },
        Depan = { AA = 0, AADps = 0, AS = 0, ASDps = 0 }
    }

    local totalAADps = 0
    local totalASDps = 0

    for _, aa in ipairs(b.AntiAir or {}) do
        if aa.HP and aa.HP > 0 then
            local spec = DEFENSE_SPECS[aa.ItemId]
            local dps = (spec and spec.DPS) or 75
            local z = getZoneName(aa.Position)
            zones[z].AA = zones[z].AA + 1
            zones[z].AADps = zones[z].AADps + dps
            totalAADps = totalAADps + dps
        end
    end

    for _, as in ipairs(b.AntiShip or {}) do
        if as.HP and as.HP > 0 then
            local spec = DEFENSE_SPECS[as.ItemId]
            local dps = (spec and spec.DPS) or 100
            local z = getZoneName(as.Position)
            zones[z].AS = zones[z].AS + 1
            zones[z].ASDps = zones[z].ASDps + dps
            totalASDps = totalASDps + dps
        end
    end

    local textLines = {
        string.format("<font color='#00E5FF'><b>🎯 BASE %d:</b></font> <font color='#FFFFFF'>%s %s</font> | Shield: %s",
            b.Index, b.Owner, (b.Team and b.Team ~= b.Owner) and ("[" .. b.Team .. "]") or "",
            b.HasShield and ("<font color='#00FF88'>🛡️ " .. b.ShieldText .. "</font>") or "<font color='#FF5555'>OFF</font>"),
        string.format("<font color='#FFAA00'><b>🛡️ TOTAL PERTAHANAN:</b></font> <font color='#FF4B72'>Anti-Air: %d unit (DPS: %d)</font> | <font color='#FFB830'>Anti-Sea: %d unit (DPS: %d)</font>",
            #b.AntiAir, totalAADps, #b.AntiShip, totalASDps),
        string.format("  • [BELAKANG]: <font color='#FF4B72'>AA: %d (DPS %d)</font> | <font color='#FFB830'>AS: %d (DPS %d)</font>",
            zones.Belakang.AA, zones.Belakang.AADps, zones.Belakang.AS, zones.Belakang.ASDps),
        string.format("  • [TENGAH]  : <font color='#FF4B72'>AA: %d (DPS %d)</font> | <font color='#FFB830'>AS: %d (DPS %d)</font>",
            zones.Tengah.AA, zones.Tengah.AADps, zones.Tengah.AS, zones.Tengah.ASDps),
        string.format("  • [DEPAN]   : <font color='#FF4B72'>AA: %d (DPS %d)</font> | <font color='#FFB830'>AS: %d (DPS %d)</font>",
            zones.Depan.AA, zones.Depan.AADps, zones.Depan.AS, zones.Depan.ASDps),
        string.format("<font color='#38B6FF'><b>🏢 Sisa Gedung/Bangunan: %d unit</b></font> | <font color='#A0C0E0'>Total Sasaran: %d unit</font>",
            #b.Buildings, b.TotalTargets)
    }

    -- Rekomendasi 5 Lokasi Klaster Anti-Air Terpadat
    local topAA = getRankedAAClusters and getRankedAAClusters(b) or {}
    if #topAA > 0 then
        local clusterRecs = {}
        local medalBadges = { [1] = "🥇#1", [2] = "🥈#2", [3] = "🥉#3", [4] = "🎖️#4", [5] = "🎖️#5" }
        for _, c in ipairs(topAA) do
            local zName = getZoneName(c.Position)
            local isFocused = (State.PreferredAAClusterRank == c.Rank)
            local badgeTag = medalBadges[c.Rank] or string.format("#%d", c.Rank)
            local focusTag = isFocused and " <font color='#00FFCC'><b>[LOCKED]</b></font>" or ""
            table.insert(clusterRecs, string.format("%s %s(%d tetangga)%s", badgeTag, zName, c.Density, focusTag))
        end
        local currentFocusText = (State.PreferredAAClusterRank and State.PreferredAAClusterRank > 0)
            and string.format("<font color='#00FFCC'>Klaster #%d</font>", State.PreferredAAClusterRank)
            or "<font color='#FFDD55'>Auto (Terpadat #1)</font>"
        table.insert(textLines, string.format("<font color='#FF5577'><b>🎯 Top AA:</b></font> %s | Fokus: %s", table.concat(clusterRecs, " | "), currentFocusText))
    end

    return table.concat(textLines, "\n")
end

-- ====================================================================================================
-- UNIVERSAL CLUSTERED TARGETING & LOOP ATTACK ENGINE (BUILDING, ANTI-AIR, ANTI-SEA)
-- ====================================================================================================
getRankedAAClusters = function(baseData)
    if not baseData then return {} end
    local list = baseData.AntiAir or {}
    local alive = {}
    for _, item in ipairs(list) do
        if item.HP and item.HP > 0 then
            table.insert(alive, item)
        end
    end
    if #alive == 0 then return {} end
    if #alive == 1 then
        return { { Target = alive[1], Density = 0, AvgDist = 0, HP = alive[1].HP or 0 } }
    end

    local scores = {}
    for i, a in ipairs(alive) do
        local posA = a.Position or (a.Instance and a.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
        local clusterDensity = 0
        local totalDist = 0

        for j, b in ipairs(alive) do
            if i ~= j then
                local posB = b.Position or (b.Instance and b.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
                local dist = (posA - posB).Magnitude
                if dist < 65 then
                    clusterDensity = clusterDensity + 1
                end
                totalDist = totalDist + dist
            end
        end

        local avgDist = (#alive > 1) and (totalDist / (#alive - 1)) or 9999
        scores[a] = {
            Density = clusterDensity,
            AvgDist = avgDist,
            HP = a.HP or 100
        }
    end

    table.sort(alive, function(a, b)
        local scA = scores[a]
        local scB = scores[b]
        if scA.Density ~= scB.Density then
            return scA.Density > scB.Density
        end
        if math.abs(scA.AvgDist - scB.AvgDist) > 5 then
            return scA.AvgDist < scB.AvgDist
        end
        return scA.HP < scB.HP
    end)

    local result = {}
    for idx = 1, math.min(5, #alive) do
        local itm = alive[idx]
        table.insert(result, {
            Rank = idx,
            Target = itm,
            Density = scores[itm] and scores[itm].Density or 0,
            AvgDist = scores[itm] and scores[itm].AvgDist or 0,
            HP = itm.HP or 0,
            MaxHP = itm.MaxHP or 1000,
            Name = itm.Name or "Anti-Air",
            Position = itm.Position
        })
    end
    return result
end

local function findClusteredTarget(baseData, categoryKey, preferredRank)
    if not baseData then return nil end
    local list = baseData[categoryKey] or {}
    local alive = {}
    for _, item in ipairs(list) do
        if item.HP and item.HP > 0 then
            table.insert(alive, item)
        end
    end
    if #alive == 0 then return nil end
    if #alive == 1 then return alive[1] end

    -- Hitung skor kepadatan (cluster density): cari target yang paling berdekatan/berdempetan dengan target lain
    local scores = {}
    for i, a in ipairs(alive) do
        local posA = a.Position or (a.Instance and a.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
        local clusterDensity = 0
        local totalDist = 0

        for j, b in ipairs(alive) do
            if i ~= j then
                local posB = b.Position or (b.Instance and b.Instance:GetPivot().Position) or Vector3.new(0, 0, 0)
                local dist = (posA - posB).Magnitude
                if dist < 65 then -- Radius jarak berdekatan/berdempetan
                    clusterDensity = clusterDensity + 1
                end
                totalDist = totalDist + dist
            end
        end

        local avgDist = (#alive > 1) and (totalDist / (#alive - 1)) or 9999
        scores[a] = {
            Density = clusterDensity,
            AvgDist = avgDist,
            HP = a.HP or 100
        }
    end

    table.sort(alive, function(a, b)
        local scA = scores[a]
        local scB = scores[b]
        if scA.Density ~= scB.Density then
            return scA.Density > scB.Density -- Utamakan yang memiliki tetangga berdempetan terbanyak
        end
        if math.abs(scA.AvgDist - scB.AvgDist) > 5 then
            return scA.AvgDist < scB.AvgDist -- Utamakan yang rata-rata jaraknya paling dekat
        end
        return scA.HP < scB.HP -- Tie-breaker: HP paling rendah
    end)

    if categoryKey == "AntiAir" and preferredRank and preferredRank > 0 then
        if alive[preferredRank] then
            return alive[preferredRank]
        end
    end

    return alive[1]
end

-- ====================================================================================================
-- SISTEM TARGETING CEPAT & RINGAN (TARGET-LOCK + PRE-FIRE SHIELD IGNORE)
-- ====================================================================================================
local function checkTargetPlayerAlive(ownerUserId, ownerName)
    if ownerUserId and tonumber(ownerUserId) and tonumber(ownerUserId) > 0 then
        local p = Players:GetPlayerByUserId(tonumber(ownerUserId))
        if p and p.Parent then return true, p end
    end
    if ownerName and ownerName ~= "Kosong" and ownerName ~= "Vacant" and ownerName ~= "Empty" then
        local cleanOwner = ownerName:lower():gsub("^team%-[^%s]+%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and (p.Name:lower():find(cleanOwner, 1, true) or p.DisplayName:lower():find(cleanOwner, 1, true)) then
                return true, p
            end
        end
    end
    return false, nil
end

local function toggleGenericTargetLoopAttack(categoryKey, labelName, defaultBtnText, defaultBtnCol, uiButton)

    -- Jika Serangan Otomatis sedang aktif dan user klik tombol kategori (misal: Anti-Sea)
    if State.AutoComboLoopActive then
        if State.AutoComboPriorityOverride == categoryKey then
            -- Klik kedua kali: batalkan prioritas khusus, kembali ke alur normal Serangan Otomatis
            State.AutoComboPriorityOverride = nil
            logMessage(string.format("🔄 [PRIORITAS %s SELESAI] Kembali ke alur Serangan Otomatis biasa.", labelName:upper()))
            showToast("Prioritas Dibatalkan", string.format("Melanjutkan alur Serangan Otomatis normal.", labelName), "info")
            if uiButton then
                uiButton.Text = defaultBtnText
                uiButton.BackgroundColor3 = defaultBtnCol
            end
        else
            -- Set prioritas sementara ke kategori ini sampai habis
            State.AutoComboPriorityOverride = categoryKey
            logMessage(string.format("⚡ [PRIORITAS SEMENTARA] Serangan Otomatis kini memprioritaskan %s sampai habis!", labelName:upper()))
            showToast("Prioritas " .. labelName, string.format("Serangan Otomatis fokus ke %s terlebih dahulu!", labelName), "warn")
            if uiButton then
                uiButton.Text = "⏹️ Lepas Prioritas " .. labelName
                uiButton.BackgroundColor3 = Color3.fromRGB(220, 45, 60)
            end
        end
        return
    end

    if State.TargetLoopActive then
        local wasSame = (State.ActiveLoopCategory == categoryKey)
        State.TargetLoopActive = false
        State.ActiveLoopCategory = nil
        logMessage(string.format("🛑 [LOOP %s] Dihentikan oleh pemain!", labelName:upper()))
        showToast("Loop Attack Stop", string.format("Serangan loop %s dihentikan.", labelName), "info")
        if uiButton then
            uiButton.Text = defaultBtnText
            uiButton.BackgroundColor3 = defaultBtnCol
        end
        if wasSame then return end
    end

    -- 1. Scan Base Target Spesifik Saja (Bukan 6 Base)
    local targetBase = scanTargetBaseOnly(State.SelectedBaseIndex)
    if not targetBase or targetBase.IsLocal then
        logMessage("⚠️ Target base tidak valid! Pilih base musuh terlebih dahulu.")
        showToast("Target Invalid", "Pilih base musuh terlebih dahulu!", "warn")
        return
    end

    -- Cek keberadaan lawan (Bukan shield; shield diabaikan agar bisa pre-fire saat sisa 10-15s)
    local isEnemyInGame = checkTargetPlayerAlive(targetBase.OwnerUserId, targetBase.Owner)
    if not isEnemyInGame and (targetBase.Owner == "Vacant" or targetBase.Owner == "Empty" or #targetBase.Owner <= 1) then
        showToast("Lawan Offline", "Lawan tidak ditemukan atau base kosong!", "warn")
        return
    end

    local firstTarget = findClusteredTarget(targetBase, categoryKey)
    if not firstTarget then
        logMessage(string.format("Tidak ada %s di base lawan!", labelName))
        showToast("Target Kosong", string.format("Tidak ada %s tersisa di base lawan!", labelName), "warn")
        return
    end

    if (State.WeaponType == "Missile" or State.WeaponType == "Kombinasi") and not next(State.SelectedMissileTypes) and not State.SelectAllMissiles then
        logMessage("⚠️ [BATAL SERANG] Anda belum memilih jenis misil! Centang jenis misil di checklist.")
        showToast("Pilih Misil Dulu", "Centang jenis misil di checklist sebelum menyerang!", "warn")
        return
    end

    if State.WeaponType == "Warship" and not next(State.SelectedWarshipTypes) then
        logMessage("⚠️ [BATAL SERANG] Anda belum memilih jenis kapal! Centang jenis warship di checklist.")
        showToast("Pilih Kapal Dulu", "Centang jenis warship di checklist sebelum menyerang!", "warn")
        return
    end

    State.TargetLoopActive = true
    State.ActiveLoopCategory = categoryKey
    logMessage(string.format("🚀 [LOOP %s FAST-PIPELINE] DIMULAI ke Base %d (%s)!", labelName:upper(), State.SelectedBaseIndex, targetBase.Owner))
    showToast(string.format("Loop %s AKTIF", labelName), string.format("Menyerang %s Base %d!", labelName, State.SelectedBaseIndex), "danger")

    if uiButton then
        uiButton.Text = "⏹️ STOP Loop " .. labelName
        uiButton.BackgroundColor3 = Color3.fromRGB(220, 45, 60)
    end

    task.spawn(function()
        local emptyAmunitionRetries = 0
        local lockedTarget = firstTarget

        while State.TargetLoopActive and State.ActiveLoopCategory == categoryKey do
            -- Cek Cepat 1: Lawan keluar server (Instan, tanpa lag)
            local stillAlive = checkTargetPlayerAlive(targetBase.OwnerUserId, targetBase.Owner)
            if not stillAlive and (targetBase.Owner == "Vacant" or targetBase.Owner == "Empty" or #targetBase.Owner <= 1) then
                logMessage(string.format("🛑 [LOOP %s] Lawan keluar server! Serangan dihentikan.", labelName:upper()))
                showToast("Lawan Keluar", "Lawan telah meninggalkan server.", "warn")
                break
            end

            -- Cek Cepat 2: Cek Shield baru dari atribut base langsung (Instan)
            local shieldRem = getBaseShieldRemaining(targetBase.Model)
            if shieldRem > 20 then
                logMessage(string.format("🛑 [LOOP %s] %s mengaktifkan Shield baru (%ds)! Serangan dihentikan.", labelName:upper(), targetBase.Owner, math.floor(shieldRem)))
                showToast("Shield Aktif", "Target mengaktifkan Shield baru! Serangan dihentikan.", "warn")
                break
            end

            -- Target-Lock: Hanya cari target baru jika belum ada atau target terkunci sudah rusak
            if not lockedTarget or (lockedTarget.Instance and lockedTarget.Instance.Parent == nil) or (lockedTarget.HP and lockedTarget.HP <= 0) then
                targetBase = scanTargetBaseOnly(State.SelectedBaseIndex)
                if not targetBase then break end
                lockedTarget = findClusteredTarget(targetBase, categoryKey)
                if not lockedTarget then
                    logMessage(string.format("🏆 [LOOP %s SELESAI] Seluruh sasaran %s lawan telah RATA!", labelName:upper(), labelName))
                    showToast(string.format("%s Musnah", labelName), string.format("Seluruh sasaran %s lawan telah hancur total!", labelName), "success")
                    break
                end
            end

            -- Kesiapan amunisi
            if State.WeaponType == "Warship" then
                local allWs = getMyPlacedWarships()
                local readyWs = {}
                for _, w in ipairs(allWs) do
                    if w.IsReady and State.SelectedWarshipTypes[w.ItemId] then table.insert(readyWs, w) end
                end

                if #readyWs == 0 then
                    task.wait(1.0)
                else
                    local wsQuota = math.min(#readyWs, math.max(1, State.WarshipVolley or 1))
                    local sendWs = {}
                    for i = 1, wsQuota do table.insert(sendWs, readyWs[i]) end
                    launchWarshipArmada(targetBase, sendWs, State.AutoBreakShield)
                    task.wait(0.5)
                end
            else
                local rockets = getMyPlacedRockets()
                local usableRockets = {}
                for _, r in ipairs(rockets) do
                    if State.SelectAllMissiles or State.SelectedMissileTypes[r.ItemId] then
                        table.insert(usableRockets, r)
                    end
                end

                if #usableRockets == 0 then
                    emptyAmunitionRetries = emptyAmunitionRetries + 1
                    if emptyAmunitionRetries > 8 then
                        logMessage(string.format("⚠️ [LOOP %s] Stok misil terpilih habis di base! Menyetop loop.", labelName:upper()))
                        showToast("Misil Habis", "Pasang atau beli misil untuk melanjutkan serangan!", "warn")
                        break
                    else
                        -- Auto Deploy asinkron mengisi di background, cukup tunggu tanpa freeze
                        task.wait(0.35)
                    end
                else
                    emptyAmunitionRetries = 0

                    -- Tentukan kuota peluncuran berdasarkan Salvo Volley pilihan user (X1, X5, X10) atau Custom Quota
                    local targetFireCount = 5
                    if State.CustomMissileQuota and State.CustomMissileQuota > 0 then
                        targetFireCount = State.CustomMissileQuota
                    elseif State.ManualLaunchVolley and State.ManualLaunchVolley ~= 999 then
                        targetFireCount = State.ManualLaunchVolley
                    else
                        targetFireCount = #usableRockets
                    end

                    local fireQuota = math.clamp(targetFireCount, 1, #usableRockets)
                    local fireGroup = {}
                    for i = 1, fireQuota do table.insert(fireGroup, usableRockets[i]) end

                    -- Peluncuran instan paralel
                    task.spawn(function()
                        launchMissileVolley(lockedTarget, fireGroup, State.AutoBreakShield)
                    end)

                    -- Interval jeda antar loop: semakin digeser ke 10x, semakin instan dan brutal
                    local spd = math.max(1, State.LoopSpeedMultiplier or 1)
                    local loopDelay = 0.05 / spd
                    task.wait(loopDelay)
                end
            end
        end

        State.TargetLoopActive = false
        State.ActiveLoopCategory = nil
        if uiButton then
            uiButton.Text = defaultBtnText
            uiButton.BackgroundColor3 = defaultBtnCol
        end
    end)
end

local _autoComboBtnRef = nil

local function toggleAutoComboAttackLoop(uiButton)
    if uiButton then _autoComboBtnRef = uiButton end

    if State.AutoComboLoopActive then
        State.AutoComboLoopActive = false
        if State.ActiveLoopCategory == "AutoCombo" then
            State.TargetLoopActive = false
            State.ActiveLoopCategory = nil
        end
        logMessage("🛑 [SERANGAN OTOMATIS] Dihentikan oleh pemain!")
        showToast("Serangan Otomatis", "Serangan Otomatis Terpadu dihentikan.", "info")
        if _autoComboBtnRef then
            _autoComboBtnRef.Text = "⚡ SERANGAN OTOMATIS"
            _autoComboBtnRef.BackgroundColor3 = Color3.fromRGB(220, 70, 30)
        end
        return
    end

    if not State.LoopAttackEnabled then
        showToast("Loop Tidak Aktif", "Aktifkan toggle [Loop: ON] terlebih dahulu!", "warn")
        return
    end

    -- 1. Scan 1 Base Sasaran Saja (Super Ringan)
    local targetBase = scanTargetBaseOnly(State.SelectedBaseIndex)
    if not targetBase or targetBase.IsLocal then
        logMessage("⚠️ Target base tidak valid! Pilih base musuh terlebih dahulu.")
        showToast("Target Invalid", "Pilih base musuh terlebih dahulu!", "warn")
        return
    end

    -- Cek keberadaan musuh (Abaikan shield saat awal klik agar bisa pre-fire 10-15s sebelum shield padam)
    local isEnemyInGame = checkTargetPlayerAlive(targetBase.OwnerUserId, targetBase.Owner)
    if not isEnemyInGame and (targetBase.Owner == "Vacant" or targetBase.Owner == "Empty" or #targetBase.Owner <= 1) then
        showToast("Lawan Offline", "Lawan tidak ditemukan atau base kosong!", "warn")
        return
    end

    if not next(State.SelectedMissileTypes) and not State.SelectAllMissiles then
        logMessage("⚠️ [BATAL SERANG] Anda belum memilih jenis misil! Centang jenis misil di checklist.")
        showToast("Pilih Misil Dulu", "Centang jenis misil di checklist sebelum memulai serangan otomatis!", "warn")
        return
    end

    State.AutoComboLoopActive = true
    State.TargetLoopActive = true
    State.ActiveLoopCategory = "AutoCombo"

    logMessage(string.format("🚀 [SERANGAN OTOMATIS HIGH-SPEED] DIMULAI ke Base %d (%s)!", State.SelectedBaseIndex, targetBase.Owner))
    showToast("Serangan Otomatis ON", string.format("Menghancurkan Base %d (Pre-Fire Ready)!", State.SelectedBaseIndex), "danger")

    if _autoComboBtnRef then
        _autoComboBtnRef.Text = "⏹️ STOP SERANGAN OTOMATIS"
        _autoComboBtnRef.BackgroundColor3 = Color3.fromRGB(180, 25, 40)
    end

    task.spawn(function()
        local emptyAmunitionRetries = 0
        local lastPlayerHarassTime = tick()
        local lockedTarget = nil
        local targetKind = "Target"

        while State.AutoComboLoopActive and State.ActiveLoopCategory == "AutoCombo" do
            -- Cek Cepat 1: Lawan keluar server (Instan)
            local stillInGame = checkTargetPlayerAlive(targetBase.OwnerUserId, targetBase.Owner)
            if not stillInGame and (targetBase.Owner == "Vacant" or targetBase.Owner == "Empty" or #targetBase.Owner <= 1) then
                logMessage("🛑 [SERANGAN OTOMATIS] Lawan keluar server! Serangan dihentikan.")
                showToast("Lawan Keluar", "Lawan telah meninggalkan permainan / base kosong.", "warn")
                break
            end

            -- Cek Cepat 2: Musuh mengaktifkan Shield baru (hanya jika durasi > 20s agar prefire < 15s tetap jalan)
            local shieldRem = getBaseShieldRemaining(targetBase.Model)
            if shieldRem > 20 then
                logMessage(string.format("🛑 [SERANGAN OTOMATIS] %s mengaktifkan Shield baru (%ds)! Serangan dihentikan.", targetBase.Owner, math.floor(shieldRem)))
                showToast("Shield Aktif", "Target mengaktifkan Shield baru! Serangan otomatis berhenti.", "warn")
                break
            end

            -- Harass Karakter Lawan Jika Diaktifkan
            local harassInterval = tonumber(State.AutoHarassInterval) or 0
            if harassInterval > 0 and (tick() - lastPlayerHarassTime >= harassInterval) then
                lastPlayerHarassTime = tick()
                task.spawn(function()
                    local rList = getMyPlacedRockets()
                    local usableOne = nil
                    for _, r in ipairs(rList) do
                        if State.SelectAllMissiles or State.SelectedMissileTypes[r.ItemId] then usableOne = r; break end
                    end
                    if usableOne then
                        local _, tPlayer = checkTargetPlayerAlive(targetBase.OwnerUserId, targetBase.Owner)
                        local fallbackPos = targetBase.Position or BASE_COORDINATES[State.SelectedBaseIndex]
                        local char = tPlayer and tPlayer.Character
                        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
                        local aimPos = (root and root.Position) or fallbackPos
                        launchPlayerCharacterAttack(tPlayer, { usableOne }, State.AutoBreakShield, aimPos, targetBase.OwnerUserId)
                    end
                end)
            end

            -- Target-Locking: Hanya scan struktur base target jika belum ada atau target aktif sudah hancur
            if not lockedTarget or (lockedTarget.Instance and lockedTarget.Instance.Parent == nil) or (lockedTarget.HP and lockedTarget.HP <= 0) then
                targetBase = scanTargetBaseOnly(State.SelectedBaseIndex)
                if not targetBase then break end

                lockedTarget = nil

                -- Prioritas Interupsi Manual
                if State.AutoComboPriorityOverride then
                    local overrideTarget = findClusteredTarget(targetBase, State.AutoComboPriorityOverride)
                    if overrideTarget then
                        lockedTarget = overrideTarget
                        targetKind = (State.AutoComboPriorityOverride == "AntiShip") and "Prioritas Anti-Sea" or ("Prioritas " .. tostring(State.AutoComboPriorityOverride))
                    else
                        State.AutoComboPriorityOverride = nil
                    end
                end

                -- Prioritas Normal: Anti-Air -> Bangunan/Anti-Sea
                if not lockedTarget then
                    local aaTarget = findClusteredTarget(targetBase, "AntiAir", State.PreferredAAClusterRank)
                    if aaTarget then
                        lockedTarget = aaTarget
                        targetKind = "Anti-Air"
                    else
                        local aliveBuildings = {}
                        for _, b in ipairs(targetBase.Buildings or {}) do if b.HP and b.HP > 0 then table.insert(aliveBuildings, b) end end
                        local aliveAntiSea = {}
                        for _, s in ipairs(targetBase.AntiShip or {}) do if s.HP and s.HP > 0 then table.insert(aliveAntiSea, s) end end

                        if #aliveBuildings == 0 and #aliveAntiSea == 0 then
                            logMessage("🏆 [SERANGAN OTOMATIS SELESAI] SELURUH BANGUNAN & PERTAHANAN LAWAN TELAH RATA TOTAL!")
                            showToast("Pangkalan Rata!", "Seluruh bangunan dan pertahanan musuh telah hancur total!", "success")
                            break
                        end

                        local chooseCategory = "Buildings"
                        if #aliveBuildings > 0 and #aliveAntiSea > 0 then
                            chooseCategory = (math.random(1, 2) == 1) and "Buildings" or "AntiShip"
                        elseif #aliveAntiSea > 0 then
                            chooseCategory = "AntiShip"
                        else
                            chooseCategory = "Buildings"
                        end

                        lockedTarget = findClusteredTarget(targetBase, chooseCategory)
                        targetKind = (chooseCategory == "Buildings") and "Bangunan" or "Anti-Sea"
                    end
                end
            end

            if not lockedTarget then
                logMessage("🏆 [SERANGAN OTOMATIS] Tidak ada target yang tersisa!")
                showToast("Pangkalan Rata!", "Semua target berhasil dihancurkan!", "success")
                break
            end

            -- Ambil Amunisi Roket Sesuai Pilihan Pengguna (Contoh: 28 AMG-86 saja)
            local rockets = getMyPlacedRockets()
            local usableRockets = {}
            for _, r in ipairs(rockets) do
                if State.SelectAllMissiles or State.SelectedMissileTypes[r.ItemId] then
                    table.insert(usableRockets, r)
                end
            end

            if #usableRockets == 0 then
                emptyAmunitionRetries = emptyAmunitionRetries + 1
                if emptyAmunitionRetries > 8 then
                    logMessage("⚠️ [SERANGAN OTOMATIS] Stok misil terpilih habis di base & tas! Menyetop serangan otomatis.")
                    showToast("Misil Habis", "Pasang atau beli misil untuk melanjutkan serangan otomatis!", "warn")
                    break
                else
                    -- Auto Deploy bekerja asinkron di latar belakang, kita cukup tunggu tanpa freezing
                    task.wait(0.35)
                end
            else
                emptyAmunitionRetries = 0

                -- Salvo Dinamis Sesuai Pilihan Pengguna: X1 / X5 / X10 / Custom Quota
                local targetFireCount = 5
                if State.CustomMissileQuota and State.CustomMissileQuota > 0 then
                    targetFireCount = State.CustomMissileQuota
                elseif State.ManualLaunchVolley and State.ManualLaunchVolley ~= 999 then
                    targetFireCount = State.ManualLaunchVolley
                else
                    targetFireCount = #usableRockets
                end

                local fireQuota = math.clamp(targetFireCount, 1, #usableRockets)
                local fireGroup = {}
                for i = 1, fireQuota do table.insert(fireGroup, usableRockets[i]) end

                -- Peluncuran instan paralel
                task.spawn(function()
                    launchMissileVolley(lockedTarget, fireGroup, State.AutoBreakShield)
                end)

                -- Interval jeda antar salvo (kecepatan tembak mengikuti multiplier)
                local spd = math.max(1, State.LoopSpeedMultiplier or 1)
                local loopDelay = 0.05 / spd
                task.wait(loopDelay)
            end
        end

        State.AutoComboLoopActive = false
        if State.ActiveLoopCategory == "AutoCombo" then
            State.TargetLoopActive = false
            State.ActiveLoopCategory = nil
        end
        if _autoComboBtnRef then
            _autoComboBtnRef.Text = "⚡ SERANGAN OTOMATIS"
            _autoComboBtnRef.BackgroundColor3 = Color3.fromRGB(220, 70, 30)
        end
    end)
end

local function stopAllAutomation()
    State.AutoBuyActive = false
    if State.AutoDeployActive then toggleAutoDeploy(false) else State.AutoDeployActive = false end
    State.AutoAttackActive = false
    State.TargetLoopActive = false
    State.AutoComboLoopActive = false
    State.ActiveLoopCategory = nil
    State.AutoFarmActive = false
    State.FarmRunning = false
    State.RefillEnabled = false
    if _autoComboBtnRef then
        _autoComboBtnRef.Text = "⚡ SERANGAN OTOMATIS"
        _autoComboBtnRef.BackgroundColor3 = Color3.fromRGB(220, 70, 30)
    end
    if State.VibeFlingActive then toggleInPlaceVibrationFling(false) end
    if farmStatusGui and farmStatusGui.Parent then farmStatusGui:Destroy(); farmStatusGui = nil end
    logMessage("🛑 [EMERGENCY STOP] SELURUH SISTEM OTOMATIS BERHENTI!")
end

-- ====================================================================================================
-- MODULAR GUI BUILDERS (PREVENTS LOCAL REGISTER OVERFLOW)
-- ====================================================================================================

-- 1. Tab Builder: Informasi Personal
local function buildInfoTab(page)
    local pCard = Instance.new("Frame", page)
    pCard.Size = UDim2.new(1, 0, 0, 110)
    pCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", pCard).CornerRadius = UDim.new(0, 8)
    local s1 = Instance.new("UIStroke", pCard)
    s1.Color = Color3.fromRGB(40, 55, 80)

    local pTitle = Instance.new("TextLabel", pCard)
    pTitle.Size = UDim2.new(1, -20, 0, 22)
    pTitle.Position = UDim2.new(0, 12, 0, 8)
    pTitle.BackgroundTransparency = 1
    pTitle.Text = "👤 PROFIL PEMAIN & KEUANGAN"
    pTitle.Font = Enum.Font.GothamBold
    pTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    pTitle.TextSize = 13
    pTitle.TextXAlignment = Enum.TextXAlignment.Left

    local pDetails = Instance.new("TextLabel", pCard)
    pDetails.Size = UDim2.new(1, -24, 0, 70)
    pDetails.Position = UDim2.new(0, 12, 0, 32)
    pDetails.BackgroundTransparency = 1
    pDetails.Font = Enum.Font.Gotham
    pDetails.TextColor3 = Color3.fromRGB(220, 230, 245)
    pDetails.TextSize = 12
    pDetails.TextWrapped = true
    pDetails.TextXAlignment = Enum.TextXAlignment.Left
    pDetails.TextYAlignment = Enum.TextYAlignment.Top
    pDetails.Text = "Memuat data profil pemain..."

    -- Base Capacity Card
    local cCard = Instance.new("Frame", page)
    cCard.Size = UDim2.new(1, 0, 0, 100)
    cCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", cCard).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", cCard).Color = Color3.fromRGB(40, 55, 80)

    local cTitle = Instance.new("TextLabel", cCard)
    cTitle.Size = UDim2.new(1, -20, 0, 22)
    cTitle.Position = UDim2.new(0, 12, 0, 8)
    cTitle.BackgroundTransparency = 1
    cTitle.Text = "🛡️ STATUS BASE & KAPASITAS TEMPUR"
    cTitle.Font = Enum.Font.GothamBold
    cTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    cTitle.TextSize = 13
    cTitle.TextXAlignment = Enum.TextXAlignment.Left

    local cDetails = Instance.new("TextLabel", cCard)
    cDetails.Size = UDim2.new(1, -24, 0, 60)
    cDetails.Position = UDim2.new(0, 12, 0, 32)
    cDetails.BackgroundTransparency = 1
    cDetails.Font = Enum.Font.Gotham
    cDetails.TextColor3 = Color3.fromRGB(220, 230, 245)
    cDetails.TextSize = 12
    cDetails.TextWrapped = true
    cDetails.TextXAlignment = Enum.TextXAlignment.Left
    cDetails.TextYAlignment = Enum.TextYAlignment.Top
    cDetails.Text = "Memuat status base..."

    -- Stock Scroll Card
    local sCard = Instance.new("Frame", page)
    sCard.Size = UDim2.new(1, 0, 0, 180)
    sCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", sCard).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", sCard).Color = Color3.fromRGB(40, 55, 80)

    local sTitle = Instance.new("TextLabel", sCard)
    sTitle.Size = UDim2.new(1, -20, 0, 22)
    sTitle.Position = UDim2.new(0, 12, 0, 8)
    sTitle.BackgroundTransparency = 1
    sTitle.Text = "📦 STOK MISIL DI TAS & HOTBAR"
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    sTitle.TextSize = 13
    sTitle.TextXAlignment = Enum.TextXAlignment.Left

    local sScroll = Instance.new("ScrollingFrame", sCard)
    sScroll.Size = UDim2.new(1, -24, 0, 140)
    sScroll.Position = UDim2.new(0, 12, 0, 32)
    sScroll.BackgroundTransparency = 1
    sScroll.ScrollBarThickness = 4
    Instance.new("UIListLayout", sScroll).Padding = UDim.new(0, 4)

    local function updateUI()
        pcall(function()
            local info = scanPersonalInfo()
            pDetails.Text = string.format("Nama: %s (@%s) [ID: %d]\nUang (Cash): %s  |  Penghasilan: %s\nTotal Stok Misil di Tas & Hotbar: %d unit",
                info.DisplayName or (localPlayer and localPlayer.DisplayName) or "Unknown",
                info.PlayerName or (localPlayer and localPlayer.Name) or "Unknown",
                info.UserId or (localPlayer and localPlayer.UserId) or 0,
                info.Cash or "$0",
                info.Income or "$0/s",
                info.TotalMissilesStock or 0)

            cDetails.Text = string.format("Base Plot: %s  |  Status Shield: %s\nMisil Terpasang: %d / %d unit\nStatus: %s",
                info.BaseSlot or "Belum Terdeteksi",
                info.Shield or "Inactive",
                info.RocketsDeployed or 0,
                info.RocketsMax or 100,
                (info.RocketsDeployed and info.RocketsMax and info.RocketsDeployed >= info.RocketsMax) and "PENUH (Maksimal)" or "Tersedia slot deploy")

            for _, c in ipairs(sScroll:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
            if info.MissilesBreakdown and #info.MissilesBreakdown > 0 then
                for _, item in ipairs(info.MissilesBreakdown) do
                    local row = Instance.new("TextLabel", sScroll)
                    row.Size = UDim2.new(1, 0, 0, 20)
                    row.BackgroundColor3 = Color3.fromRGB(26, 33, 48)
                    row.Font = Enum.Font.Gotham
                    row.Text = string.format("  • %s (%s): %d unit", item.Name, item.Id, item.Count)
                    row.TextColor3 = Color3.fromRGB(240, 245, 255)
                    row.TextSize = 11
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
                end
                sScroll.CanvasSize = UDim2.new(0, 0, 0, #info.MissilesBreakdown * 24)
            else
                local emptyRow = Instance.new("TextLabel", sScroll)
                emptyRow.Size = UDim2.new(1, 0, 0, 24)
                emptyRow.BackgroundTransparency = 1
                emptyRow.Font = Enum.Font.Gotham
                emptyRow.Text = "  • Tidak ada stok misil di tas/hotbar"
                emptyRow.TextColor3 = Color3.fromRGB(160, 175, 195)
                emptyRow.TextSize = 11
                emptyRow.TextXAlignment = Enum.TextXAlignment.Left
                sScroll.CanvasSize = UDim2.new(0, 0, 0, 24)
            end
        end)
    end
    State.UI.UpdatePersonalInfoUI = updateUI

    local refBtn = Instance.new("TextButton", page)
    refBtn.Size = UDim2.new(1, 0, 0, 34)
    refBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
    refBtn.Text = "🔄 Refresh Data Personal"
    refBtn.Font = Enum.Font.GothamBold
    refBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refBtn.TextSize = 12
    Instance.new("UICorner", refBtn).CornerRadius = UDim.new(0, 8)
    refBtn.MouseButton1Click:Connect(function()
        _cachedPlacedRockets = nil
        _lastRocketScanTime = 0
        State.MyBaseCachedIndex = nil
        getMyPlacedRockets(true)
        updateUI()
        if refreshAttackTabChecklists then
            refreshAttackTabChecklists()
        end
        showToast("Refresh Data", "Data personal & checklist senjata berhasil diperbarui!", "info")
    end)

    task.spawn(function()
        updateUI()
        -- Auto-retry jika di awal autoexecute data belum ter-sync sempurna dari server
        for _ = 1, 10 do
            task.wait(1)
            local b = getMyBaseData()
            if b then
                updateUI()
                break
            end
        end
    end)
end

-- 2. Tab Builder: Missile Setup
local function buildMissileTab(page, mainFrame)
    -- Step 1: Pilih Misil (Padat: 58px)
    local c1 = Instance.new("Frame", page)
    c1.Size = UDim2.new(1, 0, 0, 58)
    c1.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", c1).CornerRadius = UDim.new(0, 6)

    local t1 = Instance.new("TextLabel", c1)
    t1.Size = UDim2.new(1, -20, 0, 16); t1.Position = UDim2.new(0, 10, 0, 6); t1.BackgroundTransparency = 1
    t1.Text = "(Step 1) PILIH MISIL"; t1.Font = Enum.Font.GothamBold; t1.TextColor3 = Color3.fromRGB(0, 220, 255)
    t1.TextSize = 11; t1.TextXAlignment = Enum.TextXAlignment.Left

    local dropBtn = Instance.new("TextButton", c1)
    dropBtn.Size = UDim2.new(1, -20, 0, 26); dropBtn.Position = UDim2.new(0, 10, 0, 24)
    dropBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 55); dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255); dropBtn.TextSize = 11
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)

    local curM = MISSILES[State.SelectedMissileIndex]
    dropBtn.Text = string.format("%s (%s) - DMG: %d | X1: $%s | X5: $%s", curM.Name, curM.Id, curM.DMG, formatNumber(curM.PriceX1), formatNumber(curM.PriceX5))

    -- Step 2: Beli Misil (Padat: 68px)
    local c2 = Instance.new("Frame", page)
    c2.Size = UDim2.new(1, 0, 0, 68); c2.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", c2).CornerRadius = UDim.new(0, 6)

    local t2 = Instance.new("TextLabel", c2)
    t2.Size = UDim2.new(1, -20, 0, 16); t2.Position = UDim2.new(0, 10, 0, 6); t2.BackgroundTransparency = 1
    t2.Text = "(Step 2) BELI MISIL (INPUT ANGKA LALU BUY)"; t2.Font = Enum.Font.GothamBold; t2.TextColor3 = Color3.fromRGB(0, 220, 255)
    t2.TextSize = 11; t2.TextXAlignment = Enum.TextXAlignment.Left

    local qBox = Instance.new("TextBox", c2)
    qBox.Size = UDim2.new(0, 70, 0, 28); qBox.Position = UDim2.new(0, 10, 0, 28)
    qBox.BackgroundColor3 = Color3.fromRGB(28, 36, 52); qBox.Font = Enum.Font.GothamBold
    qBox.Text = "5"; qBox.TextColor3 = Color3.fromRGB(255, 255, 255); qBox.TextSize = 12
    Instance.new("UICorner", qBox).CornerRadius = UDim.new(0, 5)

    local bBtn = Instance.new("TextButton", c2)
    bBtn.Size = UDim2.new(0, 140, 0, 28); bBtn.Position = UDim2.new(0, 90, 0, 28)
    bBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90); bBtn.Text = "⚡ BUY MISIL"
    bBtn.Font = Enum.Font.GothamBold; bBtn.TextColor3 = Color3.fromRGB(255, 255, 255); bBtn.TextSize = 11
    Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0, 5)

    local buySplitHint = Instance.new("TextLabel", c2)
    buySplitHint.Size = UDim2.new(1, -245, 0, 28); buySplitHint.Position = UDim2.new(0, 238, 0, 28)
    buySplitHint.BackgroundTransparency = 1; buySplitHint.Font = Enum.Font.GothamMedium
    buySplitHint.Text = "⚡ 1x (X5)"; buySplitHint.TextColor3 = Color3.fromRGB(160, 225, 255); buySplitHint.TextSize = 10
    buySplitHint.TextXAlignment = Enum.TextXAlignment.Left

    local function updateSplitHint()
        local rawText = qBox.Text:gsub("%D", "")
        local val = tonumber(rawText) or 0
        local n5 = math.floor(val / 5)
        local n1 = val % 5
        local parts = {}
        if n5 > 0 then table.insert(parts, string.format("%dx (X5)", n5)) end
        if n1 > 0 then table.insert(parts, string.format("%dx (X1)", n1)) end
        buySplitHint.Text = "⚡ " .. (#parts > 0 and table.concat(parts, " + ") or "0 unit")
    end

    qBox:GetPropertyChangedSignal("Text"):Connect(function()
        local clean = qBox.Text:gsub("%D+", "")
        if clean ~= qBox.Text then qBox.Text = clean end
        updateSplitHint()
    end)
    updateSplitHint()

    bBtn.MouseButton1Click:Connect(function()
        local rawText = qBox.Text:gsub("%D", "")
        local amount = tonumber(rawText) or 1
        if amount <= 0 then amount = 1 end
        qBox.Text = tostring(amount)
        updateSplitHint()
        executeBuy(MISSILES[State.SelectedMissileIndex], amount)
    end)

    -- Step 3: Deploy Misil (Padat & Rapi: 154px)
    local c3 = Instance.new("Frame", page)
    c3.Size = UDim2.new(1, 0, 0, 154); c3.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", c3).CornerRadius = UDim.new(0, 6)

    local t3 = Instance.new("TextLabel", c3)
    t3.Size = UDim2.new(1, -160, 0, 16); t3.Position = UDim2.new(0, 10, 0, 6); t3.BackgroundTransparency = 1
    t3.Text = "(Step 3) DEPLOY MISIL KE BASE"; t3.Font = Enum.Font.GothamBold; t3.TextColor3 = Color3.fromRGB(0, 220, 255)
    t3.TextSize = 11; t3.TextXAlignment = Enum.TextXAlignment.Left

    -- Tombol Unlock 150 Misil (Gamepass)
    local unlock150Btn = Instance.new("TextButton", c3)
    unlock150Btn.Size = UDim2.new(0, 140, 0, 20); unlock150Btn.Position = UDim2.new(1, -150, 0, 4)
    unlock150Btn.BackgroundColor3 = State.Unlock150Missiles and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(60, 35, 45)
    unlock150Btn.Text = State.Unlock150Missiles and "🔓 Unlock 150: ON" or "🔒 Unlock 150: OFF"
    unlock150Btn.Font = Enum.Font.GothamBold; unlock150Btn.TextColor3 = Color3.fromRGB(255, 255, 255); unlock150Btn.TextSize = 10
    Instance.new("UICorner", unlock150Btn).CornerRadius = UDim.new(0, 4)
    local uStroke = Instance.new("UIStroke", unlock150Btn)
    uStroke.Color = State.Unlock150Missiles and Color3.fromRGB(0, 220, 140) or Color3.fromRGB(120, 50, 60)

    State.UI.Unlock150Buttons = State.UI.Unlock150Buttons or {}
    table.insert(State.UI.Unlock150Buttons, unlock150Btn)

    unlock150Btn.MouseButton1Click:Connect(function()
        toggleUnlock150()
    end)

    -- Baris 1: Kuantitas
    local dBar = Instance.new("Frame", c3)
    dBar.Size = UDim2.new(1, -20, 0, 24); dBar.Position = UDim2.new(0, 10, 0, 26); dBar.BackgroundTransparency = 1
    local dbl = Instance.new("UIListLayout", dBar); dbl.FillDirection = Enum.FillDirection.Horizontal; dbl.Padding = UDim.new(0, 4)

    local dButtons = {}
    for _, qVal in ipairs({ 1, 5, 10, 25, 50, 100, 150, "All" }) do
        local b = Instance.new("TextButton", dBar)
        b.Size = UDim2.new(0, 42, 1, 0)
        b.BackgroundColor3 = (qVal == State.DeployQuantity) and Color3.fromRGB(0, 160, 220) or Color3.fromRGB(32, 40, 58)
        b.Text = tostring(qVal); b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 10
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            State.DeployQuantity = qVal
            for _, o in ipairs(dButtons) do o.BackgroundColor3 = Color3.fromRGB(32, 40, 58) end
            b.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
        end)
        table.insert(dButtons, b)
    end

    -- Baris 2: Posisi, Arah, dan Kecepatan Deploy
    local posBtn = Instance.new("TextButton", c3)
    posBtn.Size = UDim2.new(0, 125, 0, 24); posBtn.Position = UDim2.new(0, 10, 0, 56)
    posBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65); posBtn.Font = Enum.Font.GothamSemibold
    posBtn.Text = "Posisi: " .. State.DeployPosition; posBtn.TextColor3 = Color3.fromRGB(255, 255, 255); posBtn.TextSize = 10
    Instance.new("UICorner", posBtn).CornerRadius = UDim.new(0, 4)
    posBtn.MouseButton1Click:Connect(function()
        if State.DeployPosition == "Random" then State.DeployPosition = "Belakang"
        elseif State.DeployPosition == "Belakang" then State.DeployPosition = "Depan"
        elseif State.DeployPosition == "Depan" then State.DeployPosition = "Tengah"
        elseif State.DeployPosition == "Tengah" then State.DeployPosition = "Rapi"
        else State.DeployPosition = "Random" end
        posBtn.Text = "Posisi: " .. State.DeployPosition
        if State.DeployPosition == "Rapi" then
            State.DeployAlign = "Horizontal"
            if alignBtn then alignBtn.Text = "Arah: Horizontal" end
            showToast("Mode Rapi", "Mode Rapi aktif: Deploy teratur berbaris horizontal (Khusus AMG-86 & Militia III)!", "info")
        end
    end)

    local alignBtn = Instance.new("TextButton", c3)
    alignBtn.Size = UDim2.new(0, 125, 0, 24); alignBtn.Position = UDim2.new(0, 140, 0, 56)
    alignBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65); alignBtn.Font = Enum.Font.GothamSemibold
    alignBtn.Text = "Arah: " .. State.DeployAlign; alignBtn.TextColor3 = Color3.fromRGB(255, 255, 255); alignBtn.TextSize = 10
    Instance.new("UICorner", alignBtn).CornerRadius = UDim.new(0, 4)
    alignBtn.MouseButton1Click:Connect(function()
        State.DeployAlign = (State.DeployAlign == "Horizontal") and "Vertikal" or "Horizontal"
        alignBtn.Text = "Arah: " .. State.DeployAlign
    end)

    local spdBtn = Instance.new("TextButton", c3)
    spdBtn.Size = UDim2.new(0, 135, 0, 24); spdBtn.Position = UDim2.new(0, 270, 0, 56)
    spdBtn.BackgroundColor3 = Color3.fromRGB(45, 36, 65); spdBtn.Font = Enum.Font.GothamBold
    spdBtn.Text = "Speed: " .. (State.DeploySpeed or "Turbo"); spdBtn.TextColor3 = Color3.fromRGB(230, 180, 255); spdBtn.TextSize = 10
    Instance.new("UICorner", spdBtn).CornerRadius = UDim.new(0, 4)
    spdBtn.MouseButton1Click:Connect(function()
        if State.DeploySpeed == "Normal" then State.DeploySpeed = "Turbo"
        elseif State.DeploySpeed == "Turbo" then State.DeploySpeed = "Ultra"
        else State.DeploySpeed = "Normal" end
        spdBtn.Text = "Speed: " .. State.DeploySpeed
        logMessage("Kecepatan deploy diatur ke: " .. State.DeploySpeed)
    end)

    -- Baris 3: Tombol Eksekusi Deploy
    local dNowBtn = Instance.new("TextButton", c3)
    dNowBtn.Size = UDim2.new(0, 160, 0, 26); dNowBtn.Position = UDim2.new(0, 10, 0, 88)
    dNowBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100); dNowBtn.Text = "🚀 Deploy Sekarang"
    dNowBtn.Font = Enum.Font.GothamBold; dNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255); dNowBtn.TextSize = 11
    Instance.new("UICorner", dNowBtn).CornerRadius = UDim.new(0, 5)
    dNowBtn.MouseButton1Click:Connect(function()
        local missile = MISSILES[State.SelectedMissileIndex]
        local baseData = getMyBaseData()
        if not baseData then logMessage("Base belum terdeteksi!"); return end

        local curRockets = baseData.CurrentRockets or 0
        local maxRockets = (State.Unlock150Missiles and 150) or baseData.MaxRockets or 100
        local freeSlots = math.max(0, maxRockets - curRockets)
        if freeSlots <= 0 then
            logMessage(string.format("Base sudah penuh! (%d/%d)", curRockets, maxRockets))
            showToast("Base Penuh", string.format("Kapasitas base telah tercapai (%d/%d)", curRockets, maxRockets), "warn")
            return
        end

        local stock = getMissileStock(missile)
        if stock <= 0 then
            logMessage(string.format("Stok %s habis di inventory!", missile.Name))
            showToast("Stok Habis", string.format("Stok %s kosong di inventory!", missile.Name), "warn")
            return
        end

        local count = State.DeployQuantity
        if count == "All" then
            count = stock
        else
            count = tonumber(count) or 1
        end
        local countToDeploy = math.min(count, stock, freeSlots)
        if countToDeploy <= 0 then return end

        logMessage(string.format("Mempersiapkan deploy %d unit %s (Stok: %d, Slot: %d, Max: %d)...", countToDeploy, missile.Name, stock, freeSlots, maxRockets))

        State._ManualDeploying = true
        task.spawn(function()
            executeDeployVerified(baseData, missile, countToDeploy, State.DeployPosition, State.DeployAlign, State.DeploySpeed)
            State._ManualDeploying = false
        end)
    end)

    local autoDeployBtn = Instance.new("TextButton", c3)
    autoDeployBtn.Size = UDim2.new(0, 130, 0, 26); autoDeployBtn.Position = UDim2.new(0, 175, 0, 88)
    autoDeployBtn.BackgroundColor3 = State.AutoDeployActive and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(38, 48, 70)
    autoDeployBtn.Text = State.AutoDeployActive and "🔄 Auto: ON" or "🔄 Auto: OFF"
    autoDeployBtn.Font = Enum.Font.GothamBold; autoDeployBtn.TextColor3 = Color3.fromRGB(200, 220, 255); autoDeployBtn.TextSize = 10.5
    Instance.new("UICorner", autoDeployBtn).CornerRadius = UDim.new(0, 5)
    State.UI.AutoDeployButtons = State.UI.AutoDeployButtons or {}
    table.insert(State.UI.AutoDeployButtons, autoDeployBtn)
    autoDeployBtn.MouseButton1Click:Connect(function()
        toggleAutoDeploy()
    end)

    local smartQueueBtn = Instance.new("TextButton", c3)
    smartQueueBtn.Size = UDim2.new(0, 100, 0, 26); smartQueueBtn.Position = UDim2.new(0, 310, 0, 88)
    smartQueueBtn.BackgroundColor3 = State.DeploySmartQueue and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(45, 50, 65)
    smartQueueBtn.Text = State.DeploySmartQueue and "⚡ Queue: SMART" or "⚡ Queue: NORMAL"
    smartQueueBtn.Font = Enum.Font.GothamBold
    smartQueueBtn.TextColor3 = State.DeploySmartQueue and Color3.fromRGB(150, 230, 255) or Color3.fromRGB(200, 200, 210)
    smartQueueBtn.TextSize = 9.5
    Instance.new("UICorner", smartQueueBtn).CornerRadius = UDim.new(0, 5)
    smartQueueBtn.MouseButton1Click:Connect(function()
        State.DeploySmartQueue = not State.DeploySmartQueue
        smartQueueBtn.BackgroundColor3 = State.DeploySmartQueue and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(45, 50, 65)
        smartQueueBtn.Text = State.DeploySmartQueue and "⚡ Queue: SMART" or "⚡ Queue: NORMAL"
        smartQueueBtn.TextColor3 = State.DeploySmartQueue and Color3.fromRGB(150, 230, 255) or Color3.fromRGB(200, 200, 210)
        if State.DeploySmartQueue then
            showToast("Smart Queue", "Smart Queue AKTIF: Auto Deploy otomatis ditahan saat salvo roket meluncur (Anti-Lag).", "info")
            logMessage("Mode Auto Deploy: Smart Queue (Anti-Lag)")
        else
            showToast("Normal Queue", "Mode NORMAL AKTIF: Auto Deploy jalan terus tanpa menunggu status salvo.", "warn")
            logMessage("Mode Auto Deploy: Normal (Bypass Queue)")
        end
    end)

    -- Baris 4: Pengaturan Durasi Blacklist Cooldown (Default 7 detik)
    local blRow = Instance.new("Frame", c3)
    blRow.Size = UDim2.new(1, -20, 0, 24); blRow.Position = UDim2.new(0, 10, 0, 120); blRow.BackgroundTransparency = 1
    local bll = Instance.new("UIListLayout", blRow); bll.FillDirection = Enum.FillDirection.Horizontal; bll.Padding = UDim.new(0, 6)

    local blLbl = Instance.new("TextLabel", blRow)
    blLbl.Size = UDim2.new(0, 165, 1, 0); blLbl.BackgroundTransparency = 1
    blLbl.Text = "⏳ Blacklist Cooldown (Gagal):"; blLbl.Font = Enum.Font.GothamBold; blLbl.TextColor3 = Color3.fromRGB(0, 220, 255); blLbl.TextSize = 10
    blLbl.TextXAlignment = Enum.TextXAlignment.Left

    local blMinus = Instance.new("TextButton", blRow)
    blMinus.Size = UDim2.new(0, 24, 1, 0); blMinus.BackgroundColor3 = Color3.fromRGB(36, 45, 65)
    blMinus.Text = "-"; blMinus.Font = Enum.Font.GothamBold; blMinus.TextColor3 = Color3.fromRGB(255, 255, 255); blMinus.TextSize = 12
    Instance.new("UICorner", blMinus).CornerRadius = UDim.new(0, 4)

    local blBox = Instance.new("TextBox", blRow)
    blBox.Size = UDim2.new(0, 45, 1, 0); blBox.BackgroundColor3 = Color3.fromRGB(28, 38, 58)
    blBox.Text = tostring(State.DeployBlacklistDuration or 7)
    blBox.ClearTextOnFocus = false
    blBox.Font = Enum.Font.GothamBold; blBox.TextColor3 = Color3.fromRGB(255, 215, 0); blBox.TextSize = 11
    Instance.new("UICorner", blBox).CornerRadius = UDim.new(0, 4)
    local blStroke = Instance.new("UIStroke", blBox); blStroke.Color = Color3.fromRGB(0, 180, 255); blStroke.Thickness = 1

    local blPlus = Instance.new("TextButton", blRow)
    blPlus.Size = UDim2.new(0, 24, 1, 0); blPlus.BackgroundColor3 = Color3.fromRGB(36, 45, 65)
    blPlus.Text = "+"; blPlus.Font = Enum.Font.GothamBold; blPlus.TextColor3 = Color3.fromRGB(255, 255, 255); blPlus.TextSize = 12
    Instance.new("UICorner", blPlus).CornerRadius = UDim.new(0, 4)

    local blUnitLbl = Instance.new("TextLabel", blRow)
    blUnitLbl.Size = UDim2.new(0, 40, 1, 0); blUnitLbl.BackgroundTransparency = 1
    blUnitLbl.Text = "detik"; blUnitLbl.Font = Enum.Font.GothamSemibold; blUnitLbl.TextColor3 = Color3.fromRGB(180, 200, 220); blUnitLbl.TextSize = 10
    blUnitLbl.TextXAlignment = Enum.TextXAlignment.Left

    local blResetBtn = Instance.new("TextButton", blRow)
    blResetBtn.Size = UDim2.new(0, 80, 1, 0); blResetBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
    blResetBtn.Text = "🧹 Reset Spot"; blResetBtn.Font = Enum.Font.GothamBold; blResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255); blResetBtn.TextSize = 9.5
    Instance.new("UICorner", blResetBtn).CornerRadius = UDim.new(0, 4)

    local function applyBlDuration(dur)
        dur = math.clamp(dur, 1, 60)
        State.DeployBlacklistDuration = dur
        blBox.Text = tostring(dur)
    end

    blMinus.MouseButton1Click:Connect(function()
        applyBlDuration((State.DeployBlacklistDuration or 7) - 1)
    end)
    blPlus.MouseButton1Click:Connect(function()
        applyBlDuration((State.DeployBlacklistDuration or 7) + 1)
    end)
    blBox.FocusLost:Connect(function()
        local val = tonumber(blBox.Text) or 7
        applyBlDuration(val)
    end)
    blResetBtn.MouseButton1Click:Connect(function()
        clearDeployBlacklist()
        showToast("Reset Blacklist", "Daftar titik blacklist dibersihkan! Seluruh grid dapat dicoba deploy kembali.", "info")
    end)

    -- Step 4: Automatic Refill Missile (Padat & Presisi: 70px)
    local c4 = Instance.new("Frame", page)
    c4.Size = UDim2.new(1, 0, 0, 70); c4.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", c4).CornerRadius = UDim.new(0, 6)

    local t4 = Instance.new("TextLabel", c4)
    t4.Size = UDim2.new(1, -20, 0, 16); t4.Position = UDim2.new(0, 10, 0, 6); t4.BackgroundTransparency = 1
    t4.Text = "(Step 4) AUTOMATIC REFILL MISSILE"; t4.Font = Enum.Font.GothamBold; t4.TextColor3 = Color3.fromRGB(0, 220, 255)
    t4.TextSize = 11; t4.TextXAlignment = Enum.TextXAlignment.Left

    local refToggle = Instance.new("TextButton", c4)
    refToggle.Size = UDim2.new(0, 150, 0, 28); refToggle.Position = UDim2.new(0, 10, 0, 28)
    refToggle.BackgroundColor3 = Color3.fromRGB(38, 48, 70); refToggle.Text = "Refill Otomatis: OFF"
    refToggle.Font = Enum.Font.GothamBold; refToggle.TextColor3 = Color3.fromRGB(200, 220, 255); refToggle.TextSize = 11
    Instance.new("UICorner", refToggle).CornerRadius = UDim.new(0, 5)
    local refToggleStroke = Instance.new("UIStroke", refToggle)
    refToggleStroke.Color = Color3.fromRGB(70, 85, 110); refToggleStroke.Thickness = 1

    local tBox = Instance.new("TextBox", c4)
    tBox.Size = UDim2.new(0, 100, 0, 28); tBox.Position = UDim2.new(0, 168, 0, 28)
    tBox.BackgroundColor3 = Color3.fromRGB(28, 36, 52); tBox.Font = Enum.Font.GothamBold
    tBox.Text = tostring(State.RefillTargetStock or 10); tBox.TextColor3 = Color3.fromRGB(255, 255, 255); tBox.TextSize = 11
    Instance.new("UICorner", tBox).CornerRadius = UDim.new(0, 5)

    local saveRefBtn = Instance.new("TextButton", c4)
    saveRefBtn.Size = UDim2.new(0, 80, 0, 28); saveRefBtn.Position = UDim2.new(0, 274, 0, 28)
    saveRefBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220); saveRefBtn.Text = "💾 Simpan"
    saveRefBtn.Font = Enum.Font.GothamBold; saveRefBtn.TextColor3 = Color3.fromRGB(255, 255, 255); saveRefBtn.TextSize = 11
    Instance.new("UICorner", saveRefBtn).CornerRadius = UDim.new(0, 5)

    refToggle.ZIndex = 5
    tBox.ZIndex = 5
    saveRefBtn.ZIndex = 5

    local function saveTargetAction()
        local val = parseCleanNumber(tBox.Text) or 10
        if val <= 0 then val = 1 end
        State.RefillTargetStock = val
        tBox.Text = tostring(val)
        saveRefBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        saveRefBtn.Text = "✓ Tersimpan!"
        task.delay(1.2, function()
            saveRefBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
            saveRefBtn.Text = "💾 Simpan"
        end)
        local curM = MISSILES[State.SelectedMissileIndex]
        local curSt = getMissileStock(curM)
        logMessage(string.format("Target refill %s DIKUNCI: %d unit (Stok saat ini: %d)", curM.Name, val, curSt))
        showToast("Target Refill Disimpan", string.format("%s dikunci ke %d unit (Stok: %d)", curM.Name, val, curSt), "success")
    end

    saveRefBtn.MouseButton1Click:Connect(saveTargetAction)
    tBox.FocusLost:Connect(saveTargetAction)

    local lastToggle = 0
    local function toggleRefill()
        local now = tick()
        if now - lastToggle < 0.25 then return end
        lastToggle = now

        local curVal = parseCleanNumber(tBox.Text) or State.RefillTargetStock or 10
        State.RefillTargetStock = curVal
        tBox.Text = tostring(curVal)

        State.RefillEnabled = not State.RefillEnabled
        State.RefillMissileId = MISSILES[State.SelectedMissileIndex].Id

        refToggle.BackgroundColor3 = State.RefillEnabled and Color3.fromRGB(0, 185, 115) or Color3.fromRGB(38, 48, 70)
        refToggle.TextColor3 = State.RefillEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 220, 255)
        refToggle.Text = State.RefillEnabled and "🟢 Refill Otomatis: ON" or "Refill Otomatis: OFF"
        refToggleStroke.Color = State.RefillEnabled and Color3.fromRGB(80, 255, 180) or Color3.fromRGB(70, 85, 110)

        if State.RefillEnabled then
            local curM = MISSILES[State.SelectedMissileIndex]
            local curSt = getMissileStock(curM)
            logMessage(string.format("Refill AKTIF untuk %s (Target: %d unit | Stok Sekarang: %d)", curM.Name, curVal, curSt))
            showToast("Refill Otomatis ON", string.format("Target: %d unit %s", curVal, curM.Name), "success")
        else
            logMessage("Refill dinonaktifkan.")
            showToast("Refill Otomatis OFF", "Pengisian otomatis dihentikan", "info")
        end
    end

    refToggle.MouseButton1Click:Connect(toggleRefill)
    refToggle.Activated:Connect(toggleRefill)

    -- Dropdown Modal
    local modal = Instance.new("Frame", mainFrame)
    modal.Size = UDim2.new(0, 380, 0, 320); modal.Position = UDim2.new(0.5, -190, 0.5, -160)
    modal.BackgroundColor3 = Color3.fromRGB(16, 22, 32); modal.Visible = false; modal.ZIndex = 20
    Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", modal).Color = Color3.fromRGB(0, 200, 255)

    local mScroll = Instance.new("ScrollingFrame", modal)
    mScroll.Size = UDim2.new(1, -20, 1, -50); mScroll.Position = UDim2.new(0, 10, 0, 40)
    mScroll.BackgroundTransparency = 1; mScroll.ScrollBarThickness = 4; mScroll.ZIndex = 21
    Instance.new("UIListLayout", mScroll).Padding = UDim.new(0, 4)

    for idx, m in ipairs(MISSILES) do
        local ib = Instance.new("TextButton", mScroll)
        ib.Size = UDim2.new(1, 0, 0, 28)
        ib.BackgroundColor3 = (idx % 2 == 0) and Color3.fromRGB(24, 32, 46) or Color3.fromRGB(20, 26, 38)
        ib.Font = Enum.Font.Gotham; ib.Text = string.format(" %s [%s] - DMG: %d | X1: $%s", m.Name, m.Id, m.DMG, formatNumber(m.PriceX1))
        ib.TextColor3 = Color3.fromRGB(240, 245, 255); ib.TextSize = 11; ib.TextXAlignment = Enum.TextXAlignment.Left; ib.ZIndex = 22
        Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 4)
        ib.MouseButton1Click:Connect(function()
            State.SelectedMissileIndex = idx
            local cur = MISSILES[idx]
            dropBtn.Text = string.format("%s (%s) - DMG: %d | X1: $%s | X5: $%s", cur.Name, cur.Id, cur.DMG, formatNumber(cur.PriceX1), formatNumber(cur.PriceX5))
            if State.RefillEnabled then State.RefillMissileId = cur.Id end
            modal.Visible = false
        end)
    end
    mScroll.CanvasSize = UDim2.new(0, 0, 0, #MISSILES * 32)

    local mClose = Instance.new("TextButton", modal)
    mClose.Size = UDim2.new(0, 30, 0, 26); mClose.Position = UDim2.new(1, -38, 0, 6)
    mClose.BackgroundColor3 = Color3.fromRGB(200, 40, 60); mClose.Text = "✕"
    mClose.Font = Enum.Font.GothamBold; mClose.TextColor3 = Color3.fromRGB(255, 255, 255); mClose.TextSize = 12; mClose.ZIndex = 22
    Instance.new("UICorner", mClose).CornerRadius = UDim.new(0, 6)
    mClose.MouseButton1Click:Connect(function() modal.Visible = false end)
    dropBtn.MouseButton1Click:Connect(function() modal.Visible = not modal.Visible end)
end

local getChosenRockets = nil
local getChosenWarships = nil
local executeMissileBatches = nil
local refreshAttackTabChecklists = nil

-- Sinkronisasi Tombol Klik Minimap Manual (Main HUD & Modal Attack)
if not State.UI.ManualClickButtons then
    State.UI.ManualClickButtons = {}
end

local function syncManualClickButtons()
    local isEnabled = State.ManualClickAttackEnabled == true
    local count = State.ManualClickCount or 0
    local bgCol = isEnabled and Color3.fromRGB(220, 50, 70) or Color3.fromRGB(45, 55, 75)
    local strokeCol = isEnabled and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(70, 85, 110)

    for btn, data in pairs(State.UI.ManualClickButtons) do
        if btn and btn.Parent then
            btn.BackgroundColor3 = bgCol
            if data and data.IsModal then
                btn.Text = isEnabled and string.format("🎯 Klik: x%d", count) or "🎯 Klik: OFF"
            else
                btn.Text = isEnabled and string.format("🎯 Klik: ON (x%d)", count) or "🎯 Klik Map: OFF"
            end
            if data and data.Stroke then
                data.Stroke.Color = strokeCol
            end
        else
            State.UI.ManualClickButtons[btn] = nil
        end
    end
end
State.UI.UpdateManualClickBtn = syncManualClickButtons


-- Helper Pemetaan Visual Struktur Base Lawan (Radar / Minimap Base)
local function createBaseRadarWidget(parent, size)
    local radarBox = Instance.new("Frame", parent)
    radarBox.Size = size or UDim2.new(0, 140, 1, -30)
    radarBox.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
    Instance.new("UICorner", radarBox).CornerRadius = UDim.new(0, 6)
    local rStroke = Instance.new("UIStroke", radarBox)
    rStroke.Color = Color3.fromRGB(0, 180, 220); rStroke.Thickness = 1.2; rStroke.Transparency = 0.2

    -- Label Indikator Belakang (Pangkal base - di posisi atas)
    local backTag = Instance.new("TextLabel", radarBox)
    backTag.Size = UDim2.new(1, 0, 0, 14); backTag.Position = UDim2.new(0, 0, 0, 1)
    backTag.BackgroundTransparency = 1; backTag.Font = Enum.Font.GothamBold; backTag.TextSize = 8.5
    backTag.TextColor3 = Color3.fromRGB(150, 165, 190); backTag.Text = "▲ [BELAKANG] ▲"

    -- Label Indikator Depan (Arah laut/depan base - di posisi bawah)
    local frontTag = Instance.new("TextLabel", radarBox)
    frontTag.Size = UDim2.new(1, 0, 0, 14); frontTag.Position = UDim2.new(0, 0, 1, -15)
    frontTag.BackgroundTransparency = 1; frontTag.Font = Enum.Font.GothamBold; frontTag.TextSize = 8.5
    frontTag.TextColor3 = Color3.fromRGB(0, 255, 200); frontTag.Text = "▼ [DEPAN] ▼"

    -- Plot Area Visual (Area kotak pangkalan)
    local plotArea = Instance.new("Frame", radarBox)
    plotArea.Size = UDim2.new(1, -12, 1, -34); plotArea.Position = UDim2.new(0, 6, 0, 16)
    plotArea.BackgroundColor3 = Color3.fromRGB(14, 18, 28); plotArea.ClipsDescendants = true
    Instance.new("UICorner", plotArea).CornerRadius = UDim.new(0, 4)
    local pStroke = Instance.new("UIStroke", plotArea)
    pStroke.Color = Color3.fromRGB(30, 45, 68); pStroke.Thickness = 1

    -- Garis pembatas zona: Belakang, Tengah, Depan
    local line1 = Instance.new("Frame", plotArea)
    line1.Size = UDim2.new(1, 0, 0, 1); line1.Position = UDim2.new(0, 0, 0.33, 0)
    line1.BackgroundColor3 = Color3.fromRGB(35, 55, 80); line1.BorderSizePixel = 0

    local line2 = Instance.new("Frame", plotArea)
    line2.Size = UDim2.new(1, 0, 0, 1); line2.Position = UDim2.new(0, 0, 0.67, 0)
    line2.BackgroundColor3 = Color3.fromRGB(35, 55, 80); line2.BorderSizePixel = 0

    -- Container objek yang di-clear setiap update
    local dotContainer = Instance.new("Frame", plotArea)
    dotContainer.Size = UDim2.new(1, 0, 1, 0); dotContainer.BackgroundTransparency = 1

    -- Legend / Status Bar mini di bawah
    local statusText = Instance.new("TextLabel", plotArea)
    statusText.Size = UDim2.new(1, 0, 1, 0); statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.GothamBold; statusText.TextSize = 9; statusText.TextColor3 = Color3.fromRGB(130, 150, 175)
    statusText.Text = "Pilih base..."; statusText.Visible = false

    -- Object Pooling untuk Dot dan Tombol Klaster agar tidak bocor RAM (No ClearAllChildren)
    local dotPool = {}
    local clusterBtnPool = {}
    -- Penyimpanan koneksi klik per slot (TIDAK boleh disimpan sebagai properti Instance)
    local clusterClickConns = {}

    local function getPooledDot(idx)
        local dot = dotPool[idx]
        if not dot then
            dot = Instance.new("Frame", dotContainer)
            dot.BorderSizePixel = 0
            local corner = Instance.new("UICorner", dot)
            corner.Name = "Corner"
            local stroke = Instance.new("UIStroke", dot)
            stroke.Name = "Stroke"
            stroke.Thickness = 1
            dotPool[idx] = dot
        end
        return dot
    end

    local function getPooledClusterBtn(idx)
        local btn = clusterBtnPool[idx]
        if not btn then
            btn = Instance.new("TextButton", dotContainer)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 8.5
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.ZIndex = 5
            local corner = Instance.new("UICorner", btn)
            corner.CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Name = "Stroke"
            clusterBtnPool[idx] = btn
        end
        return btn
    end

    local function renderBaseMap(targetBaseIndex)
        local all = scanAllBases()
        local b = all[targetBaseIndex or State.SelectedBaseIndex]

        if not b or not b.Model then
            statusText.Visible = true
            statusText.Text = "Base Kosong / Offline"
            for _, d in ipairs(dotPool) do d.Visible = false end
            for _, cb in ipairs(clusterBtnPool) do cb.Visible = false end
            return
        end

        if b.IsLocal then
            statusText.Visible = true
            statusText.Text = "Base Anda Sendiri"
            for _, d in ipairs(dotPool) do d.Visible = false end
            for _, cb in ipairs(clusterBtnPool) do cb.Visible = false end
            return
        end

        statusText.Visible = false

        local pa = b.Model:FindFirstChild("PlacementArea") or b.Model.PrimaryPart
        local baseCF = pa and pa.CFrame or CFrame.new(b.Position)
        local baseLen = (pa and pa.Size and pa.Size.Z) or 200
        local baseWidth = (pa and pa.Size and pa.Size.X) or 160

        -- Hitung Top 5 Klaster Anti-Air Terpadat untuk di-highlight
        local topClusters = getRankedAAClusters(b)
        local aaRankMap = {}
        for rankIdx, cData in ipairs(topClusters) do
            if cData.Target then
                aaRankMap[cData.Target] = rankIdx
            end
        end

        local dotCount = 0
        local clusterBtnCount = 0

        local clusterColors = {
            [1] = Color3.fromRGB(255, 40, 70),   -- Merah (#1)
            [2] = Color3.fromRGB(255, 140, 20),  -- Oranye (#2)
            [3] = Color3.fromRGB(220, 190, 0),   -- Kuning-Emas (#3)
            [4] = Color3.fromRGB(0, 210, 140),   -- Hijau Emerald (#4)
            [5] = Color3.fromRGB(160, 70, 240)   -- Ungu Violet (#5)
        }

        local function addDot(pos, hp, kind, tooltipName, rawItem)
            if not pos then return end
            local rel = baseCF:PointToObjectSpace(pos)
            local nx = math.clamp(0.5 + (rel.Z / baseLen), 0.05, 0.95)
            local nz = math.clamp(0.5 - (rel.X / baseWidth), 0.05, 0.95)

            local isAlive = (hp and hp > 0)
            local rank = (kind == "AA" and rawItem and aaRankMap[rawItem]) or nil

            if kind == "AA" and rank and isAlive then
                clusterBtnCount = clusterBtnCount + 1
                local btn = getPooledClusterBtn(clusterBtnCount)
                local isSelected = (State.PreferredAAClusterRank == rank)
                local bsz = 14
                btn.Size = UDim2.new(0, bsz, 0, bsz)
                btn.Position = UDim2.new(nx, -math.floor(bsz/2), nz, -math.floor(bsz/2))
                btn.BackgroundColor3 = clusterColors[rank] or Color3.fromRGB(0, 160, 240)
                btn.Text = tostring(rank)
                local bStroke = btn:FindFirstChild("Stroke")
                if bStroke then
                    bStroke.Thickness = isSelected and 2 or 1.2
                    bStroke.Color = isSelected and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255)
                end

                -- Re-bind click event bersih (koneksi disimpan di tabel, bukan di Instance)
                if clusterClickConns[clusterBtnCount] then
                    clusterClickConns[clusterBtnCount]:Disconnect()
                    clusterClickConns[clusterBtnCount] = nil
                end
                clusterClickConns[clusterBtnCount] = btn.MouseButton1Click:Connect(function()
                    if State.PreferredAAClusterRank == rank then
                        State.PreferredAAClusterRank = 0
                        showToast("Fokus Klaster AA", "Mode Auto: Menyerang Klaster AA Terpadat (#1)", "info")
                    else
                        State.PreferredAAClusterRank = rank
                        showToast("Fokus Klaster AA", string.format("Fokus Serangan Terkunci ke Klaster Anti-Air #%d!", rank), "success")
                    end
                    if State.UI.UpdateCombatAssistantUI then pcall(State.UI.UpdateCombatAssistantUI) end
                    if State.UI.UpdateModalAnalyzeUI then pcall(State.UI.UpdateModalAnalyzeUI) end
                end)
                btn.Visible = true
            else
                dotCount = dotCount + 1
                local dot = getPooledDot(dotCount)
                local sz = (kind == "AA" or kind == "AS") and 7 or 5
                dot.Size = UDim2.new(0, sz, 0, sz)
                dot.Position = UDim2.new(nx, -math.floor(sz/2), nz, -math.floor(sz/2))

                local corner = dot:FindFirstChild("Corner")
                local stroke = dot:FindFirstChild("Stroke")

                if kind == "AA" then
                    dot.BackgroundColor3 = isAlive and Color3.fromRGB(255, 60, 95) or Color3.fromRGB(80, 35, 45)
                    if corner then corner.CornerRadius = UDim.new(1, 0) end
                elseif kind == "AS" then
                    dot.BackgroundColor3 = isAlive and Color3.fromRGB(255, 185, 45) or Color3.fromRGB(90, 65, 25)
                    if corner then corner.CornerRadius = UDim.new(1, 0) end
                else
                    dot.BackgroundColor3 = isAlive and Color3.fromRGB(50, 175, 255) or Color3.fromRGB(30, 50, 75)
                    if corner then corner.CornerRadius = UDim.new(0, 1.5) end
                end

                if stroke then
                    -- Pakai Transparency (bukan Enabled) agar kompatibel di semua versi Roblox
                    stroke.Transparency = isAlive and 0 or 1
                    stroke.Color = (kind == "AA") and Color3.fromRGB(255, 160, 180) or ((kind == "AS") and Color3.fromRGB(255, 235, 140) or Color3.fromRGB(150, 220, 255))
                end
                dot.Visible = true
            end
        end

        -- Render Buildings
        for _, bg in ipairs(b.Buildings or {}) do
            addDot(bg.Position, bg.HP, "Build", bg.Name, bg)
        end
        -- Render Anti-Air (Layer di atas gedung)
        for _, aa in ipairs(b.AntiAir or {}) do
            addDot(aa.Position, aa.HP, "AA", aa.Name, aa)
        end
        -- Render Anti-Sea (Layer paling atas)
        for _, as in ipairs(b.AntiShip or {}) do
            addDot(as.Position, as.HP, "AS", as.Name, as)
        end

        -- Sembunyikan elemen pool sisa yang tidak terpakai
        for i = dotCount + 1, #dotPool do
            dotPool[i].Visible = false
        end
        for i = clusterBtnCount + 1, #clusterBtnPool do
            clusterBtnPool[i].Visible = false
        end
    end

    -- Visual Marker & Counter Click Attack (Opsi A)
    local clickMarker = Instance.new("Frame", plotArea)
    clickMarker.Size = UDim2.new(0, 18, 0, 18)
    clickMarker.BackgroundColor3 = Color3.fromRGB(255, 40, 70)
    clickMarker.BackgroundTransparency = 0.35
    clickMarker.Visible = false
    clickMarker.ZIndex = 15
    Instance.new("UICorner", clickMarker).CornerRadius = UDim.new(1, 0)
    local cmStroke = Instance.new("UIStroke", clickMarker)
    cmStroke.Color = Color3.fromRGB(255, 230, 80)
    cmStroke.Thickness = 1.5

    local cmLabel = Instance.new("TextLabel", clickMarker)
    cmLabel.Size = UDim2.new(1, 0, 1, 0)
    cmLabel.BackgroundTransparency = 1
    cmLabel.Font = Enum.Font.GothamBold
    cmLabel.Text = "x1"
    cmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cmLabel.TextSize = 8.5
    cmLabel.ZIndex = 16

    -- Event Klik Minimap untuk Serangan Manual (Opsi A: Instant Fire & Hitung Jumlah Klik)
    plotArea.InputBegan:Connect(function(input)
        if not State.ManualClickAttackEnabled then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local all = scanAllBases()
        local b = all[State.SelectedBaseIndex]
        if not b or not b.Model then
            showToast("Manual Attack", "Target base tidak valid atau offline!", "warn")
            return
        end
        if b.IsLocal then
            showToast("Manual Attack", "Tidak dapat menyerang base milik Anda sendiri!", "warn")
            return
        end

        local pa = b.Model:FindFirstChild("PlacementArea") or b.Model.PrimaryPart
        local baseCF = pa and pa.CFrame or CFrame.new(b.Position)
        local baseLen = (pa and pa.Size and pa.Size.Z) or 200
        local baseWidth = (pa and pa.Size and pa.Size.X) or 160

        local absPos = plotArea.AbsolutePosition
        local absSize = plotArea.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then return end

        -- Gunakan input.Position (posisi pointer akurat pada saat klik, bebas offset GuiService/TopBar)
        local clickPosX = input.Position.X
        local clickPosY = input.Position.Y
        if (not clickPosX or clickPosX == 0) and (not clickPosY or clickPosY == 0) then
            local mouseLoc = UserInputService:GetMouseLocation()
            clickPosX = mouseLoc.X
            clickPosY = mouseLoc.Y
        end

        local relClickX = clickPosX - absPos.X
        local relClickY = clickPosY - absPos.Y

        local nx = math.clamp(relClickX / absSize.X, 0.02, 0.98)
        local nz = math.clamp(relClickY / absSize.Y, 0.02, 0.98)

        -- Rumus balik koordinat minimap 2D ke 3D World Position (1:1 simetris dengan addDot)
        local relZ = (nx - 0.5) * baseLen
        local relX = (0.5 - nz) * baseWidth
        local targetWorldPos = baseCF:PointToWorldSpace(Vector3.new(relX, 2, relZ))


        -- Ambil misil yang dipilih user
        local usable = getChosenRockets and getChosenRockets() or {}
        if #usable == 0 then
            showToast("Manual Attack", "Pilih jenis misil di checklist atau pastikan stok roket tersedia!", "warn")
            return
        end

        -- Tentukan kuota tembakan per klik
        local volleyQuota = (State.ManualLaunchVolley == 999) and 5 or math.min(#usable, State.ManualLaunchVolley or 5)
        if State.CustomMissileQuota and State.CustomMissileQuota > 0 then
            volleyQuota = math.min(volleyQuota, State.CustomMissileQuota)
        end
        volleyQuota = math.max(1, math.min(volleyQuota, #usable))

        local rocketsToFire = {}
        for i = 1, volleyQuota do
            table.insert(rocketsToFire, usable[i])
        end

        -- Update hitungan klik global
        State.ManualClickCount = (State.ManualClickCount or 0) + 1

        -- Animasi visual marker titik klik & jumlah hitungan
        clickMarker.Position = UDim2.new(nx, -9, nz, -9)
        cmLabel.Text = "x" .. tostring(State.ManualClickCount)
        clickMarker.Visible = true

        local tw = TweenService:Create(clickMarker, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(nx, -12, nz, -12)
        })
        tw:Play()
        task.delay(0.2, function()
            if clickMarker and clickMarker.Parent then
                TweenService:Create(clickMarker, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(nx, -9, nz, -9)
                }):Play()
            end
        end)

        -- Eksekusi peluncuran langsung ke posisi koordinat world yang diklik
        logMessage(string.format("🎯 [KLIK MANUAL #%d] Meluncurkan %d misil ke Base %d (X:%.0f, Y:%.0f, Z:%.0f)",
            State.ManualClickCount, #rocketsToFire, State.SelectedBaseIndex, targetWorldPos.X, targetWorldPos.Y, targetWorldPos.Z))

        local targetObj = {
            Position = targetWorldPos,
            Instance = b.Model,
            Kind = "Build",
            Uid = 0
        }
        launchMissileVolley(targetObj, rocketsToFire, State.AutoBreakShield)

        if State.UI.UpdateManualClickBtn then
            pcall(State.UI.UpdateManualClickBtn)
        end
    end)

    return {
        Box = radarBox,
        Update = renderBaseMap,
        ResetClickCounter = function()
            State.ManualClickCount = 0
            clickMarker.Visible = false
        end
    }
end



-- 3. Tab Builder: Attack Setup (Komprehensif & Modern)
local function buildAttackTab(page)
    -- Card 1: Target Selection & Player Analysis
    local tbCard = Instance.new("Frame", page)
    tbCard.Size = UDim2.new(1, 0, 0, 114); tbCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", tbCard).CornerRadius = UDim.new(0, 8)

    local tbTitle = Instance.new("TextLabel", tbCard)
    tbTitle.Size = UDim2.new(1, -120, 0, 20); tbTitle.Position = UDim2.new(0, 12, 0, 6); tbTitle.BackgroundTransparency = 1
    tbTitle.Text = "🎯 TARGET BASE (KLIK UNTUK ANALISIS)"; tbTitle.Font = Enum.Font.GothamBold; tbTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    tbTitle.TextSize = 11; tbTitle.TextXAlignment = Enum.TextXAlignment.Left

    local refPlayerBtn = Instance.new("TextButton", tbCard)
    refPlayerBtn.Size = UDim2.new(0, 100, 0, 22); refPlayerBtn.Position = UDim2.new(1, -112, 0, 5)
    refPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220); refPlayerBtn.Text = "🔄 Refresh Base"
    refPlayerBtn.Font = Enum.Font.GothamBold; refPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255); refPlayerBtn.TextSize = 10
    Instance.new("UICorner", refPlayerBtn).CornerRadius = UDim.new(0, 5)

    local bGrid = Instance.new("Frame", tbCard)
    bGrid.Size = UDim2.new(1, -24, 0, 72); bGrid.Position = UDim2.new(0, 12, 0, 32); bGrid.BackgroundTransparency = 1
    local bgl = Instance.new("UIGridLayout", bGrid); bgl.CellSize = UDim2.new(0.32, -4, 0, 32); bgl.CellPadding = UDim2.new(0.02, 0, 0, 6)

    -- Forward declarations for analysis updates
    local updateCombatAssistantUI
    local updateAttackControlsLayout

    local baseBtns = {}
    local function renderBases()
        local all = scanAllBases()
        for idx = 1, 6 do
            local b = all[idx]
            local btn = baseBtns[idx]
            if not btn then
                btn = Instance.new("TextButton", bGrid)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                btn.Font = Enum.Font.GothamMedium; btn.TextSize = 10
                baseBtns[idx] = btn
                btn.MouseButton1Click:Connect(function()
                    State.SelectedBaseIndex = idx
                    renderBases()
                    if updateCombatAssistantUI then updateCombatAssistantUI() end
                end)
            end

            local isSelected = (idx == State.SelectedBaseIndex)
            btn.BackgroundColor3 = isSelected and Color3.fromRGB(0, 150, 235) or Color3.fromRGB(28, 36, 52)

            if b then
                if b.IsLocal then
                    btn.Text = string.format("Base %d (ME)\n%s", idx, b.Owner:sub(1, 8))
                    btn.TextColor3 = Color3.fromRGB(120, 255, 170)
                else
                    btn.Text = string.format("Base %d (%d)%s\n%s", idx, b.TotalTargets, b.HasShield and " 🛡️" or "", b.Owner:sub(1, 8))
                    btn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 225, 245)
                end
            else
                btn.Text = string.format("Base %d\n(Kosong)", idx)
                btn.TextColor3 = Color3.fromRGB(140, 150, 170)
            end
        end
    end
    refPlayerBtn.MouseButton1Click:Connect(renderBases)
    task.spawn(renderBases)

    -- Card 2: Assistant Tempur & Analisis Target (Sinkron dengan GUI Attack Mode)
    local astCard = Instance.new("Frame", page)
    astCard.Size = UDim2.new(1, 0, 0, 175); astCard.BackgroundColor3 = Color3.fromRGB(18, 23, 34)
    Instance.new("UICorner", astCard).CornerRadius = UDim.new(0, 8)
    local astStroke = Instance.new("UIStroke", astCard); astStroke.Color = Color3.fromRGB(35, 55, 85)

    local astHeader = Instance.new("Frame", astCard)
    astHeader.Size = UDim2.new(1, 0, 0, 24); astHeader.BackgroundTransparency = 1

    local astTitle = Instance.new("TextLabel", astHeader)
    astTitle.Size = UDim2.new(1, -250, 1, 0); astTitle.Position = UDim2.new(0, 10, 0, 1); astTitle.BackgroundTransparency = 1
    astTitle.Text = "🔬 ANALISIS PERTAHANAN CANGGIH"; astTitle.Font = Enum.Font.GothamBold; astTitle.TextColor3 = Color3.fromRGB(0, 240, 220)
    astTitle.TextSize = 11; astTitle.TextXAlignment = Enum.TextXAlignment.Left

    local astRefreshRow = Instance.new("Frame", astHeader)
    astRefreshRow.Size = UDim2.new(0, 340, 0, 20); astRefreshRow.Position = UDim2.new(1, -345, 0, 2); astRefreshRow.BackgroundTransparency = 1
    local arl = Instance.new("UIListLayout", astRefreshRow); arl.FillDirection = Enum.FillDirection.Horizontal; arl.Padding = UDim.new(0, 4)

    local manClickBtn = Instance.new("TextButton", astRefreshRow)
    manClickBtn.Size = UDim2.new(0, 105, 1, 0)
    manClickBtn.BackgroundColor3 = State.ManualClickAttackEnabled and Color3.fromRGB(220, 50, 70) or Color3.fromRGB(45, 55, 75)
    manClickBtn.Text = State.ManualClickAttackEnabled and string.format("🎯 Klik: ON (x%d)", State.ManualClickCount or 0) or "🎯 Klik Map: OFF"
    manClickBtn.Font = Enum.Font.GothamBold; manClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255); manClickBtn.TextSize = 8.5
    Instance.new("UICorner", manClickBtn).CornerRadius = UDim.new(0, 4)
    local mcStroke = Instance.new("UIStroke", manClickBtn)
    mcStroke.Color = State.ManualClickAttackEnabled and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(70, 85, 110)
    mcStroke.Thickness = 1

    State.UI.ManualClickButtons[manClickBtn] = { Stroke = mcStroke, IsModal = false }

    manClickBtn.MouseButton1Click:Connect(function()
        State.ManualClickAttackEnabled = not State.ManualClickAttackEnabled
        if not State.ManualClickAttackEnabled then
            State.ManualClickCount = 0
            if astRadar and astRadar.ResetClickCounter then astRadar.ResetClickCounter() end
            showToast("Klik Minimap", "Mode serang manual dinonaktifkan.", "info")
        else
            showToast("Klik Minimap Aktif", "Klik titik mana saja di minimap base untuk meluncurkan misil langsung!", "success")
        end
        if State.UI.UpdateManualClickBtn then
            pcall(State.UI.UpdateManualClickBtn)
        end
    end)


    local astToggle = Instance.new("TextButton", astRefreshRow)
    astToggle.Size = UDim2.new(0, 85, 1, 0)
    astToggle.BackgroundColor3 = State.CombatAssistantEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(45, 55, 75)
    astToggle.Text = State.CombatAssistantEnabled and "Assistant: ON" or "Assistant: OFF"
    astToggle.Font = Enum.Font.GothamBold; astToggle.TextColor3 = Color3.fromRGB(255, 255, 255); astToggle.TextSize = 8.5
    Instance.new("UICorner", astToggle).CornerRadius = UDim.new(0, 4)

    local autoRefBtn = Instance.new("TextButton", astRefreshRow)
    autoRefBtn.Size = UDim2.new(0, 75, 1, 0)
    autoRefBtn.BackgroundColor3 = (State.AutoRefreshAssistant or State.AttackModalAutoRefresh) and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(45, 55, 75)
    autoRefBtn.Text = (State.AutoRefreshAssistant or State.AttackModalAutoRefresh) and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
    autoRefBtn.Font = Enum.Font.GothamBold; autoRefBtn.TextColor3 = Color3.fromRGB(255, 255, 255); autoRefBtn.TextSize = 8.5
    Instance.new("UICorner", autoRefBtn).CornerRadius = UDim.new(0, 4)
    State.UI.AttackTabAutoRefBtn = autoRefBtn

    local manRefBtn = Instance.new("TextButton", astRefreshRow)
    manRefBtn.Size = UDim2.new(0, 60, 1, 0)
    manRefBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    manRefBtn.Text = "🔄 Refresh"
    manRefBtn.Font = Enum.Font.GothamBold; manRefBtn.TextColor3 = Color3.fromRGB(0, 220, 255); manRefBtn.TextSize = 8.5
    Instance.new("UICorner", manRefBtn).CornerRadius = UDim.new(0, 4)

    -- Container Body: Kiri = Teks Analisis, Kanan = Peta Radar Base Lawan
    local astBody = Instance.new("Frame", astCard)
    astBody.Size = UDim2.new(1, -20, 0, 142); astBody.Position = UDim2.new(0, 10, 0, 26); astBody.BackgroundTransparency = 1

    local astLabel = Instance.new("TextLabel", astBody)
    astLabel.Size = UDim2.new(1, -150, 1, 0); astLabel.Position = UDim2.new(0, 0, 0, 0)
    astLabel.BackgroundTransparency = 1; astLabel.Font = Enum.Font.Code; astLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
    astLabel.TextSize = 10.5; astLabel.TextXAlignment = Enum.TextXAlignment.Left; astLabel.TextYAlignment = Enum.TextYAlignment.Top
    astLabel.TextWrapped = true
    astLabel.RichText = true
    astLabel.LineHeight = 1.15
    astLabel.Text = "Memuat analisis pertahanan base..."

    -- Radar visualisasi peta base musuh
    local astRadar = createBaseRadarWidget(astBody, UDim2.new(0, 142, 1, 0))
    astRadar.Box.Position = UDim2.new(1, -142, 0, 0)

    -- Legend indikator di bawah radar
    local rLegend = Instance.new("Frame", astRadar.Box)
    rLegend.Size = UDim2.new(1, 0, 0, 12); rLegend.Position = UDim2.new(0, 0, 1, 2); rLegend.BackgroundTransparency = 1
    local rlLayout = Instance.new("UIListLayout", rLegend); rlLayout.FillDirection = Enum.FillDirection.Horizontal; rlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; rlLayout.Padding = UDim.new(0, 6)

    local function makeDotLegend(color, text)
        local item = Instance.new("Frame", rLegend)
        item.Size = UDim2.new(0, 38, 1, 0); item.BackgroundTransparency = 1
        local d = Instance.new("Frame", item); d.Size = UDim2.new(0, 6, 0, 6); d.Position = UDim2.new(0, 0, 0.5, -3); d.BackgroundColor3 = color; d.BorderSizePixel = 0
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
        local l = Instance.new("TextLabel", item); l.Size = UDim2.new(1, -8, 1, 0); l.Position = UDim2.new(0, 8, 0, 0); l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold; l.TextSize = 7.5; l.TextColor3 = Color3.fromRGB(180, 200, 220); l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = text
    end
    makeDotLegend(Color3.fromRGB(50, 175, 255), "Gedung")
    makeDotLegend(Color3.fromRGB(255, 60, 95), "AA")
    makeDotLegend(Color3.fromRGB(255, 185, 45), "AS")

    updateCombatAssistantUI = function()
        if not State.CombatAssistantEnabled then
            astLabel.Text = "[Assistant Tempur OFF] Klik tombol 'Assistant: OFF' di atas untuk mengaktifkan analisis target."
            astRadar.Update(State.SelectedBaseIndex)
            return
        end
        astLabel.Text = generateBaseDefenseAnalysis(State.SelectedBaseIndex)
        astRadar.Update(State.SelectedBaseIndex)
    end
    State.UI.UpdateCombatAssistantUI = updateCombatAssistantUI

    astToggle.MouseButton1Click:Connect(function()
        State.CombatAssistantEnabled = not State.CombatAssistantEnabled
        astToggle.BackgroundColor3 = State.CombatAssistantEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(45, 55, 75)
        astToggle.Text = State.CombatAssistantEnabled and "Assistant: ON" or "Assistant: OFF"
        updateCombatAssistantUI()
    end)

    autoRefBtn.MouseButton1Click:Connect(function()
        local newState = not (State.AutoRefreshAssistant or State.AttackModalAutoRefresh)
        State.AutoRefreshAssistant = newState
        State.AttackModalAutoRefresh = newState
        autoRefBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(45, 55, 75)
        autoRefBtn.Text = newState and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
        if State.UI.ModalAutoRefBtn then
            State.UI.ModalAutoRefBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(45, 55, 75)
            State.UI.ModalAutoRefBtn.Text = newState and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
        end
        showToast("Auto Refresh", "Realtime auto refresh per detik: " .. (newState and "ON" or "OFF"), "info")
    end)

    manRefBtn.MouseButton1Click:Connect(function()
        renderBases()
        updateCombatAssistantUI()
        if State.UI.UpdateModalAnalyzeUI then pcall(State.UI.UpdateModalAnalyzeUI) end
        showToast("Refresh", "Analisis base & target diperbarui", "info")
    end)

    task.spawn(updateCombatAssistantUI)

    -- Auto-Refresh Loop per Detik (Real-time updates sinkron)
    task.spawn(function()
        while page and page.Parent do
            task.wait(1.0)
            if (State.AutoRefreshAssistant or State.AttackModalAutoRefresh) and State.CombatAssistantEnabled then
                pcall(function()
                    renderBases()
                    updateCombatAssistantUI()
                end)
            end
        end
    end)

    -- Card 3: Pilihan Senjata (Missile, Warship, Kombinasi + Multi-Select)
    local wCard = Instance.new("Frame", page)
    wCard.Size = UDim2.new(1, 0, 0, 175); wCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", wCard).CornerRadius = UDim.new(0, 8)

    local wTitle = Instance.new("TextLabel", wCard)
    wTitle.Size = UDim2.new(1, -20, 0, 20); wTitle.Position = UDim2.new(0, 12, 0, 6); wTitle.BackgroundTransparency = 1
    wTitle.Text = "⚔️ PILIHAN SENJATA & INVENTORY TERPASANG"; wTitle.Font = Enum.Font.GothamBold; wTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    wTitle.TextSize = 11; wTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Mode Button Switcher: Missile -> Warship -> Kombinasi
    local modeRow = Instance.new("Frame", wCard)
    modeRow.Size = UDim2.new(1, -24, 0, 26); modeRow.Position = UDim2.new(0, 12, 0, 28); modeRow.BackgroundTransparency = 1
    local mrl = Instance.new("UIListLayout", modeRow); mrl.FillDirection = Enum.FillDirection.Horizontal; mrl.Padding = UDim.new(0, 6)

    local modeBtns = {}
    for _, mName in ipairs({ "Missile", "Warship", "Kombinasi" }) do
        local mb = Instance.new("TextButton", modeRow)
        mb.Size = UDim2.new(0, 95, 1, 0)
        mb.BackgroundColor3 = (State.WeaponType == mName) and Color3.fromRGB(0, 150, 230) or Color3.fromRGB(30, 38, 55)
        mb.Text = (mName == "Kombinasi") and "🔥 Kombinasi" or ("⚔️ " .. mName)
        mb.Font = Enum.Font.GothamBold; mb.TextColor3 = Color3.fromRGB(255, 255, 255); mb.TextSize = 10
        Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 5)
        mb.MouseButton1Click:Connect(function()
            State.WeaponType = mName
            for k, b in pairs(modeBtns) do b.BackgroundColor3 = (k == mName) and Color3.fromRGB(0, 150, 230) or Color3.fromRGB(30, 38, 55) end
            if refreshWeaponStockChecklist then refreshWeaponStockChecklist() end
            if updateCombatAssistantUI then updateCombatAssistantUI() end
            if updateAttackControlsLayout then updateAttackControlsLayout() end
        end)
        modeBtns[mName] = mb
    end

    -- Scroll Checklist Senjata Terpasang (Multi-Select)
    local wScroll = Instance.new("ScrollingFrame", wCard)
    wScroll.Size = UDim2.new(1, -24, 0, 75); wScroll.Position = UDim2.new(0, 12, 0, 58)
    wScroll.BackgroundColor3 = Color3.fromRGB(15, 20, 30); wScroll.ScrollBarThickness = 3
    Instance.new("UICorner", wScroll).CornerRadius = UDim.new(0, 6)
    local wGrid = Instance.new("UIGridLayout", wScroll); wGrid.CellSize = UDim2.new(0.485, -2, 0, 26); wGrid.CellPadding = UDim2.new(0.02, 0, 0, 4)

    refreshWeaponStockChecklist = function()
        for _, ch in ipairs(wScroll:GetChildren()) do if ch:IsA("GuiObject") then ch:Destroy() end end
        local rList = getMyPlacedRockets()
        local wsList = getMyPlacedWarships()

        -- Hitung jenis roket
        local rCounts = {}
        for _, r in ipairs(rList) do
            rCounts[r.ItemId] = (rCounts[r.ItemId] or 0) + 1
        end
        -- Hitung jenis kapal (Total vs Siap 100%)
        local wsCounts = {}
        local wsReadyCounts = {}
        for _, w in ipairs(wsList) do
            wsCounts[w.ItemId] = (wsCounts[w.ItemId] or 0) + 1
            if w.IsReady then
                wsReadyCounts[w.ItemId] = (wsReadyCounts[w.ItemId] or 0) + 1
            end
        end

        local totalRows = 0

        -- 1. Render Missile Types (HANYA jika mode "Missile" atau "Kombinasi")
        if State.WeaponType == "Missile" or State.WeaponType == "Kombinasi" then
            for id, count in pairs(rCounts) do
                totalRows = totalRows + 1
                local spec = MISSILE_BY_ID[id] or { Name = id }
                local isChecked = (State.SelectedMissileTypes[id] == true)
                local itemBtn = Instance.new("TextButton", wScroll)
                itemBtn.BackgroundColor3 = isChecked and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(35, 42, 58)
                itemBtn.Text = string.format("%s 🚀 %s: %d unit", isChecked and "✅" or "⬜", spec.Name, count)
                itemBtn.Font = Enum.Font.GothamMedium; itemBtn.TextColor3 = isChecked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 205, 225); itemBtn.TextSize = 10
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

                itemBtn.MouseButton1Click:Connect(function()
                    State.SelectedMissileTypes[id] = not State.SelectedMissileTypes[id]
                    refreshWeaponStockChecklist()
                    if updateCombatAssistantUI then updateCombatAssistantUI() end
                end)
            end
        end

        -- 2. Render Warship Types (HANYA jika mode "Warship" atau "Kombinasi")
        if State.WeaponType == "Warship" or State.WeaponType == "Kombinasi" then
            for id, count in pairs(wsCounts) do
                totalRows = totalRows + 1
                local spec = WARSHIP_SPECS[id] or { Name = id }
                local ready = wsReadyCounts[id] or 0
                local isChecked = (State.SelectedWarshipTypes[id] == true)
                local itemBtn = Instance.new("TextButton", wScroll)
                itemBtn.BackgroundColor3 = isChecked and Color3.fromRGB(0, 140, 210) or Color3.fromRGB(35, 42, 58)
                itemBtn.Text = string.format("%s 🚢 %s: %d/%d SIAP", isChecked and "✅" or "⬜", spec.Name, ready, count)
                itemBtn.Font = Enum.Font.GothamMedium
                itemBtn.TextColor3 = isChecked and Color3.fromRGB(255, 255, 255) or ((ready > 0) and Color3.fromRGB(120, 255, 180) or Color3.fromRGB(255, 170, 170))
                itemBtn.TextSize = 10
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

                itemBtn.MouseButton1Click:Connect(function()
                    State.SelectedWarshipTypes[id] = not State.SelectedWarshipTypes[id]
                    refreshWeaponStockChecklist()
                    if updateCombatAssistantUI then updateCombatAssistantUI() end
                end)
            end
        end

        if totalRows == 0 then
            local emptyLbl = Instance.new("TextLabel", wScroll)
            emptyLbl.Size = UDim2.new(1, 0, 1, 0); emptyLbl.BackgroundTransparency = 1
            if State.WeaponType == "Missile" then
                emptyLbl.Text = "Tidak ada roket terpasang di base! Deploy roket di Step 3."
            elseif State.WeaponType == "Warship" then
                emptyLbl.Text = "Tidak ada warship terdeteksi di dock base Anda!"
            else
                emptyLbl.Text = "Tidak ada roket atau warship di base!"
            end
            emptyLbl.TextColor3 = Color3.fromRGB(255, 160, 100); emptyLbl.Font = Enum.Font.Gotham; emptyLbl.TextSize = 10
        end
        wScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(math.max(1, totalRows) / 2) * 30 + 10)
    end
    refreshAttackTabChecklists = refreshWeaponStockChecklist
    task.spawn(function()
        refreshWeaponStockChecklist()
        for _ = 1, 10 do
            task.wait(1)
            local rList = getMyPlacedRockets(true)
            local wsList = getMyPlacedWarships()
            if #rList > 0 or #wsList > 0 then
                refreshWeaponStockChecklist()
                break
            end
        end
    end)

    -- Baris Threshold Repair Building Lawan
    local repRow = Instance.new("Frame", wCard)
    repRow.Size = UDim2.new(1, -24, 0, 28); repRow.Position = UDim2.new(0, 12, 0, 138); repRow.BackgroundTransparency = 1
    local repLabel = Instance.new("TextLabel", repRow)
    repLabel.Size = UDim2.new(0, 190, 1, 0); repLabel.BackgroundTransparency = 1
    repLabel.Text = "Estimasi Repair Building Lawan:"; repLabel.Font = Enum.Font.GothamBold; repLabel.TextColor3 = Color3.fromRGB(180, 205, 230); repLabel.TextSize = 10; repLabel.TextXAlignment = Enum.TextXAlignment.Left

    local repBtns = {}
    for _, rate in ipairs({ 15, 25, 50, 100 }) do
        local rb = Instance.new("TextButton", repRow)
        rb.Size = UDim2.new(0, 45, 1, 0); rb.Position = UDim2.new(0, 195 + (#repBtns * 48), 0, 0)
        rb.BackgroundColor3 = (State.EnemyBuildingRepairRate == rate) and Color3.fromRGB(0, 140, 220) or Color3.fromRGB(30, 40, 58)
        rb.Text = "+" .. rate .. "%"; rb.Font = Enum.Font.GothamBold; rb.TextColor3 = Color3.fromRGB(255, 255, 255); rb.TextSize = 10
        Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 4)
        rb.MouseButton1Click:Connect(function()
            State.EnemyBuildingRepairRate = rate
            for _, b in ipairs(repBtns) do b.BackgroundColor3 = Color3.fromRGB(30, 40, 58) end
            rb.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
            if updateCombatAssistantUI then updateCombatAssistantUI() end
        end)
        table.insert(repBtns, rb)
    end

    -- Card 4: Eksekusi Penyerangan (Building, Anti-Air, Anti-Sea, Kombinasi, Otonomus)
    local lCard = Instance.new("Frame", page)
    lCard.Size = UDim2.new(1, 0, 0, (State.WeaponType == "Kombinasi") and 292 or 262); lCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", lCard).CornerRadius = UDim.new(0, 8)

    local lTitle = Instance.new("TextLabel", lCard)
    lTitle.Size = UDim2.new(1, -290, 0, 20); lTitle.Position = UDim2.new(0, 12, 0, 6); lTitle.BackgroundTransparency = 1
    lTitle.Text = "🚀 EKSEKUSI PENYERANGAN"; lTitle.Font = Enum.Font.GothamBold; lTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    lTitle.TextSize = 10; lTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Slider Pengatur Kecepatan Loop (1x - 10x) di GUI Utama
    local lSpdFrame = Instance.new("Frame", lCard)
    lSpdFrame.Size = UDim2.new(0, 185, 0, 20); lSpdFrame.Position = UDim2.new(1, -282, 0, 5); lSpdFrame.BackgroundTransparency = 1

    local lSpdLbl = Instance.new("TextLabel", lSpdFrame)
    lSpdLbl.Size = UDim2.new(0, 75, 1, 0); lSpdLbl.BackgroundTransparency = 1
    lSpdLbl.Text = string.format("⚡ Spd: %dx", State.LoopSpeedMultiplier or 1)
    lSpdLbl.Font = Enum.Font.GothamBold; lSpdLbl.TextColor3 = Color3.fromRGB(255, 215, 0); lSpdLbl.TextSize = 9
    lSpdLbl.TextXAlignment = Enum.TextXAlignment.Left
    State.UI.MainLoopSpeedLbl = lSpdLbl

    local lTrack = Instance.new("TextButton", lSpdFrame)
    lTrack.Size = UDim2.new(0, 105, 0, 10); lTrack.Position = UDim2.new(0, 78, 0.5, -5)
    lTrack.BackgroundColor3 = Color3.fromRGB(30, 40, 60); lTrack.Text = ""; lTrack.AutoButtonColor = false
    Instance.new("UICorner", lTrack).CornerRadius = UDim.new(0, 5)

    local lFill = Instance.new("Frame", lTrack)
    local curPct = math.clamp(((State.LoopSpeedMultiplier or 1) - 1) / 9, 0, 1)
    lFill.Size = UDim2.new(curPct, 0, 1, 0); lFill.BackgroundColor3 = Color3.fromRGB(0, 210, 255); lFill.BorderSizePixel = 0
    Instance.new("UICorner", lFill).CornerRadius = UDim.new(0, 5)
    State.UI.MainLoopFill = lFill

    local lKnob = Instance.new("Frame", lTrack)
    lKnob.Size = UDim2.new(0, 14, 0, 14); lKnob.Position = UDim2.new(curPct, -7, 0.5, -7)
    lKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); lKnob.BorderSizePixel = 0
    Instance.new("UICorner", lKnob).CornerRadius = UDim.new(1, 0)
    State.UI.MainLoopKnob = lKnob

    local function setLoopSpeed(spd, fromUser)
        spd = math.clamp(math.floor(spd + 0.5), 1, 10)
        State.LoopSpeedMultiplier = spd
        local pct = (spd - 1) / 9
        if State.UI.MainLoopSpeedLbl then State.UI.MainLoopSpeedLbl.Text = string.format("⚡ Spd: %dx", spd) end
        if State.UI.MainLoopFill then State.UI.MainLoopFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.MainLoopKnob then State.UI.MainLoopKnob.Position = UDim2.new(pct, -7, 0.5, -7) end

        if State.UI.ModalLoopSpeedLbl then State.UI.ModalLoopSpeedLbl.Text = string.format("⚡ %dx", spd) end
        if State.UI.ModalLoopFill then State.UI.ModalLoopFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.ModalLoopKnob then State.UI.ModalLoopKnob.Position = UDim2.new(pct, -6, 0.5, -6) end
        if fromUser then
            showToast("Kecepatan Loop", string.format("Kecepatan serangan loop diatur ke %dx", spd), "info")
        end
    end

    local isDraggingMain = false
    local function updateMainFromInput(input)
        local relX = math.clamp(input.Position.X - lTrack.AbsolutePosition.X, 0, lTrack.AbsoluteSize.X)
        local pct = (lTrack.AbsoluteSize.X > 0) and (relX / lTrack.AbsoluteSize.X) or 0
        local spd = 1 + pct * 9
        setLoopSpeed(spd, false)
    end
    lTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingMain = true
            updateMainFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateMainFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingMain then
                isDraggingMain = false
                showToast("Kecepatan Loop", string.format("Kecepatan loop diatur ke %dx", State.LoopSpeedMultiplier or 1), "info")
            end
        end
    end)

    -- Tombol Toggle Loop Attack (ON / OFF)
    local loopAttackBtn = Instance.new("TextButton", lCard)
    loopAttackBtn.Size = UDim2.new(0, 85, 0, 20); loopAttackBtn.Position = UDim2.new(1, -92, 0, 5)
    loopAttackBtn.BackgroundColor3 = State.LoopAttackEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(50, 60, 75)
    loopAttackBtn.Text = State.LoopAttackEnabled and "🔁 Loop: ON" or "🔁 Loop: OFF"
    loopAttackBtn.Font = Enum.Font.GothamBold; loopAttackBtn.TextColor3 = Color3.fromRGB(255, 255, 255); loopAttackBtn.TextSize = 9
    Instance.new("UICorner", loopAttackBtn).CornerRadius = UDim.new(0, 4)
    State.UI.MainLoopAttackBtn = loopAttackBtn

    -- Baris Slider Harass Karakter (0-60 detik, 0 = OFF) di GUI Utama
    local lHarassFrame = Instance.new("Frame", lCard)
    lHarassFrame.Size = UDim2.new(1, -24, 0, 20); lHarassFrame.Position = UDim2.new(0, 12, 0, 28); lHarassFrame.BackgroundTransparency = 1

    local lHarassLbl = Instance.new("TextLabel", lHarassFrame)
    lHarassLbl.Size = UDim2.new(0, 185, 1, 0); lHarassLbl.BackgroundTransparency = 1
    local curSec = State.AutoHarassInterval or 0
    lHarassLbl.Text = (curSec > 0) and string.format("👤 Harass Karakter: %ds (1 misil)", curSec) or "👤 Harass Karakter: OFF"
    lHarassLbl.Font = Enum.Font.GothamBold; lHarassLbl.TextColor3 = (curSec > 0) and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(180, 190, 205); lHarassLbl.TextSize = 9
    lHarassLbl.TextXAlignment = Enum.TextXAlignment.Left
    State.UI.MainHarassLbl = lHarassLbl

    local lhTrack = Instance.new("TextButton", lHarassFrame)
    lhTrack.Size = UDim2.new(1, -240, 0, 10); lhTrack.Position = UDim2.new(0, 190, 0.5, -5)
    lhTrack.BackgroundColor3 = Color3.fromRGB(30, 40, 60); lhTrack.Text = ""; lhTrack.AutoButtonColor = false
    Instance.new("UICorner", lhTrack).CornerRadius = UDim.new(0, 5)

    local curHPct = math.clamp(curSec / 60, 0, 1)
    local lhFill = Instance.new("Frame", lhTrack)
    lhFill.Size = UDim2.new(curHPct, 0, 1, 0); lhFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80); lhFill.BorderSizePixel = 0
    Instance.new("UICorner", lhFill).CornerRadius = UDim.new(0, 5)
    State.UI.MainHarassFill = lhFill

    local lhKnob = Instance.new("Frame", lhTrack)
    lhKnob.Size = UDim2.new(0, 14, 0, 14); lhKnob.Position = UDim2.new(curHPct, -7, 0.5, -7)
    lhKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); lhKnob.BorderSizePixel = 0
    Instance.new("UICorner", lhKnob).CornerRadius = UDim.new(1, 0)
    State.UI.MainHarassKnob = lhKnob

    local lhValLbl = Instance.new("TextLabel", lHarassFrame)
    lhValLbl.Size = UDim2.new(0, 45, 1, 0); lhValLbl.Position = UDim2.new(1, -45, 0, 0); lhValLbl.BackgroundTransparency = 1
    lhValLbl.Text = (curSec > 0) and (curSec .. "s") or "OFF"
    lhValLbl.Font = Enum.Font.GothamBold; lhValLbl.TextColor3 = (curSec > 0) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 160, 175); lhValLbl.TextSize = 9
    lhValLbl.TextXAlignment = Enum.TextXAlignment.Right
    State.UI.MainHarassValLbl = lhValLbl

    local function setHarassInterval(sec, fromUser)
        sec = math.clamp(math.floor(sec + 0.5), 0, 60)
        State.AutoHarassInterval = sec
        local pct = sec / 60
        local txt = (sec > 0) and string.format("👤 Harass Karakter: %ds (1 misil)", sec) or "👤 Harass Karakter: OFF"
        local valTxt = (sec > 0) and (sec .. "s") or "OFF"
        local col = (sec > 0) and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(180, 190, 205)
        local valCol = (sec > 0) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 160, 175)

        if State.UI.MainHarassLbl then State.UI.MainHarassLbl.Text = txt; State.UI.MainHarassLbl.TextColor3 = col end
        if State.UI.MainHarassValLbl then State.UI.MainHarassValLbl.Text = valTxt; State.UI.MainHarassValLbl.TextColor3 = valCol end
        if State.UI.MainHarassFill then State.UI.MainHarassFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.MainHarassKnob then State.UI.MainHarassKnob.Position = UDim2.new(pct, -7, 0.5, -7) end

        if State.UI.ModalHarassLbl then State.UI.ModalHarassLbl.Text = (sec > 0) and string.format("👤 Harass: %ds", sec) or "👤 Harass: OFF"; State.UI.ModalHarassLbl.TextColor3 = col end
        if State.UI.ModalHarassValLbl then State.UI.ModalHarassValLbl.Text = valTxt; State.UI.ModalHarassValLbl.TextColor3 = valCol end
        if State.UI.ModalHarassFill then State.UI.ModalHarassFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.ModalHarassKnob then State.UI.ModalHarassKnob.Position = UDim2.new(pct, -6, 0.5, -6) end

        if fromUser then
            if sec > 0 then
                showToast("Harass Karakter", string.format("Serangan otomatis akan meluncurkan 1 misil ke karakter lawan setiap %d detik!", sec), "info")
            else
                showToast("Harass Karakter", "Fitur serang karakter berkala dinonaktifkan (OFF)", "info")
            end
        end
    end

    local isDraggingHarassMain = false
    local function updateHarassMainFromInput(input)
        local relX = math.clamp(input.Position.X - lhTrack.AbsolutePosition.X, 0, lhTrack.AbsoluteSize.X)
        local pct = (lhTrack.AbsoluteSize.X > 0) and (relX / lhTrack.AbsoluteSize.X) or 0
        setHarassInterval(pct * 60, false)
    end
    lhTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingHarassMain = true
            updateHarassMainFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingHarassMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateHarassMainFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingHarassMain then
                isDraggingHarassMain = false
                setHarassInterval(State.AutoHarassInterval or 0, true)
            end
        end
    end)

    -- Row 1: Kontrol Misil (Salvo X1/X5/X10/MIX + Robux Toggle X10 + Custom Missile Quota)
    local vBar = Instance.new("Frame", lCard)
    vBar.Size = UDim2.new(1, -24, 0, 24); vBar.Position = UDim2.new(0, 12, 0, 28); vBar.BackgroundTransparency = 1
    local vbl = Instance.new("UIListLayout", vBar); vbl.FillDirection = Enum.FillDirection.Horizontal; vbl.Padding = UDim.new(0, 5)

    local vButtons = {}
    local x10BtnRef = nil

    local function refreshVolleyButtonColors()
        for vSize, btn in pairs(vButtons) do
            local isCur = (vSize == "MIX" and State.ManualLaunchVolley == 999) or (State.ManualLaunchVolley == vSize)
            btn.BackgroundColor3 = isCur and Color3.fromRGB(0, 160, 220) or Color3.fromRGB(30, 38, 55)
        end
    end

    for _, vSize in ipairs({ 1, 5, 10, "MIX" }) do
        local b = Instance.new("TextButton", vBar)
        b.Size = (vSize == "MIX") and UDim2.new(0, 38, 1, 0) or UDim2.new(0, 32, 1, 0)
        local isCur = (vSize == "MIX" and State.ManualLaunchVolley == 999) or (State.ManualLaunchVolley == vSize)
        b.BackgroundColor3 = isCur and Color3.fromRGB(0, 160, 220) or Color3.fromRGB(30, 38, 55)
        b.Text = (type(vSize) == "number") and ("X" .. vSize) or tostring(vSize)
        b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 10
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        if vSize == 10 then x10BtnRef = b end

        b.MouseButton1Click:Connect(function()
            if vSize == 10 and not State.UnlockX10 then
                showToast("X10 Terkunci", "Aktifkan toggle 'Unlock X10' jika sudah beli robux!", "warn")
                return
            end
            State.ManualLaunchVolley = (vSize == "MIX") and 999 or vSize
            refreshVolleyButtonColors()
            if vSize == "MIX" then
                showToast("Mode MIX Aktif", State.UnlockX10 and "Mix partisi otomatis: X10 + X5 + X1" or "Mix partisi otomatis: X5 + X1", "info")
            end
        end)
        vButtons[vSize] = b
    end

    -- Toggle Tombol X10 Gamepass (Robux Unlock)
    local x10ToggleBtn = Instance.new("TextButton", vBar)
    x10ToggleBtn.Size = UDim2.new(0, 72, 1, 0)
    x10ToggleBtn.BackgroundColor3 = State.UnlockX10 and Color3.fromRGB(0, 150, 90) or Color3.fromRGB(70, 30, 35)
    x10ToggleBtn.Text = State.UnlockX10 and "🔓 X10: ON" or "🔒 X10: OFF"
    x10ToggleBtn.Font = Enum.Font.GothamBold; x10ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); x10ToggleBtn.TextSize = 9
    Instance.new("UICorner", x10ToggleBtn).CornerRadius = UDim.new(0, 4)
    local x10Stroke = Instance.new("UIStroke", x10ToggleBtn)
    x10Stroke.Color = State.UnlockX10 and Color3.fromRGB(0, 220, 140) or Color3.fromRGB(120, 50, 60)

    State.UI.RefreshVolleyColors = refreshVolleyButtonColors
    State.UI.UnlockX10Buttons = State.UI.UnlockX10Buttons or {}
    table.insert(State.UI.UnlockX10Buttons, x10ToggleBtn)

    x10ToggleBtn.MouseButton1Click:Connect(function()
        toggleUnlockX10()
    end)

    -- Custom Missile Quota Input (Jml Misil)
    local customQuotaLbl = Instance.new("TextLabel", vBar)
    customQuotaLbl.Size = UDim2.new(0, 52, 1, 0); customQuotaLbl.BackgroundTransparency = 1
    customQuotaLbl.Text = "Jml Misil:"; customQuotaLbl.Font = Enum.Font.GothamBold; customQuotaLbl.TextColor3 = Color3.fromRGB(0, 220, 255); customQuotaLbl.TextSize = 10
    customQuotaLbl.TextXAlignment = Enum.TextXAlignment.Right

    local customQuotaBox = Instance.new("TextBox", vBar)
    customQuotaBox.Size = UDim2.new(0, 54, 1, 0); customQuotaBox.BackgroundColor3 = Color3.fromRGB(28, 38, 58)
    customQuotaBox.Text = (State.CustomMissileQuota and State.CustomMissileQuota > 0) and tostring(State.CustomMissileQuota) or ""
    customQuotaBox.PlaceholderText = "Auto"
    customQuotaBox.ClearTextOnFocus = false
    customQuotaBox.Font = Enum.Font.GothamBold; customQuotaBox.TextColor3 = Color3.fromRGB(255, 255, 255); customQuotaBox.TextSize = 10
    Instance.new("UICorner", customQuotaBox).CornerRadius = UDim.new(0, 4)
    local qStroke = Instance.new("UIStroke", customQuotaBox); qStroke.Color = Color3.fromRGB(0, 180, 255); qStroke.Thickness = 1

    customQuotaBox:GetPropertyChangedSignal("Text"):Connect(function()
        local clean = customQuotaBox.Text:gsub("%D+", "")
        if clean ~= customQuotaBox.Text then customQuotaBox.Text = clean end
    end)
    customQuotaBox.FocusLost:Connect(function()
        local val = tonumber(customQuotaBox.Text) or 0
        State.CustomMissileQuota = val
        if val > 0 then
            showToast("Kuota Misil Diset", string.format("Peluncuran dibatasi total %d misil", val), "info")
        else
            showToast("Kuota Default", "Menggunakan jumlah batch standar", "info")
        end
    end)

    -- Toggle Sortir Misil Terdekat (Clustered Launch)
    local clusterToggleBtn = Instance.new("TextButton", vBar)
    clusterToggleBtn.Size = UDim2.new(0, 92, 1, 0)
    clusterToggleBtn.BackgroundColor3 = State.ClusteredLaunchEnabled and Color3.fromRGB(0, 160, 130) or Color3.fromRGB(65, 45, 55)
    clusterToggleBtn.Text = State.ClusteredLaunchEnabled and "🎯 Dekat: ON" or "🎯 Dekat: OFF"
    clusterToggleBtn.Font = Enum.Font.GothamBold; clusterToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); clusterToggleBtn.TextSize = 9
    Instance.new("UICorner", clusterToggleBtn).CornerRadius = UDim.new(0, 4)

    local function syncClusterToggleUI()
        local isEnabled = (State.ClusteredLaunchEnabled == true)
        clusterToggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 160, 130) or Color3.fromRGB(65, 45, 55)
        clusterToggleBtn.Text = isEnabled and "🎯 Dekat: ON" or "🎯 Dekat: OFF"
        if State.UI and State.UI.ModalClusterBtn then
            State.UI.ModalClusterBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 160, 130) or Color3.fromRGB(65, 45, 55)
            State.UI.ModalClusterBtn.Text = isEnabled and "🎯 Dekat: ON" or "🎯 Dekat: OFF"
        end
    end

    clusterToggleBtn.MouseButton1Click:Connect(function()
        State.ClusteredLaunchEnabled = not State.ClusteredLaunchEnabled
        syncClusterToggleUI()
        if State.ClusteredLaunchEnabled then
            logMessage("🎯 Mode Sortir Misil Terdekat diaktifkan (misil yang bersebelahan ditembakkan bersamaan)")
            showToast("Sortir Posisi Aktif", "Misil yang berdekatan diluncurkan terlebih dahulu!", "success")
        else
            logMessage("🎯 Mode Sortir Misil Terdekat dinonaktifkan (urutan bawaan folder/acak)")
            showToast("Sortir Posisi OFF", "Peluncuran kembali menggunakan urutan bawaan", "info")
        end
    end)

    -- Row 2: Kontrol Khusus Jumlah Armada Warship (X1, X2, dst per unit kapal)
    local wsRow = Instance.new("Frame", lCard)
    wsRow.Size = UDim2.new(1, -24, 0, 24); wsRow.Position = UDim2.new(0, 12, 0, 56); wsRow.BackgroundTransparency = 1
    local wsl = Instance.new("UIListLayout", wsRow); wsl.FillDirection = Enum.FillDirection.Horizontal; wsl.Padding = UDim.new(0, 5)

    local wsLbl = Instance.new("TextLabel", wsRow)
    wsLbl.Size = UDim2.new(0, 140, 1, 0); wsLbl.BackgroundTransparency = 1
    wsLbl.Text = "🚢 Jumlah Kapal (Units):"; wsLbl.Font = Enum.Font.GothamBold; wsLbl.TextColor3 = Color3.fromRGB(0, 220, 255)
    wsLbl.TextSize = 10; wsLbl.TextXAlignment = Enum.TextXAlignment.Left

    local wsMinusBtn = Instance.new("TextButton", wsRow)
    wsMinusBtn.Size = UDim2.new(0, 28, 1, 0); wsMinusBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65)
    wsMinusBtn.Text = "-"; wsMinusBtn.Font = Enum.Font.GothamBold; wsMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255); wsMinusBtn.TextSize = 12
    Instance.new("UICorner", wsMinusBtn).CornerRadius = UDim.new(0, 4)

    local wsBox = Instance.new("TextBox", wsRow)
    wsBox.Size = UDim2.new(0, 52, 1, 0); wsBox.BackgroundColor3 = Color3.fromRGB(28, 38, 58)
    wsBox.Text = tostring(State.WarshipVolley or 1)
    wsBox.ClearTextOnFocus = false
    wsBox.Font = Enum.Font.GothamBold; wsBox.TextColor3 = Color3.fromRGB(0, 220, 255); wsBox.TextSize = 11
    Instance.new("UICorner", wsBox).CornerRadius = UDim.new(0, 4)
    local wsStroke = Instance.new("UIStroke", wsBox); wsStroke.Color = Color3.fromRGB(0, 180, 255); wsStroke.Thickness = 1

    local wsPlusBtn = Instance.new("TextButton", wsRow)
    wsPlusBtn.Size = UDim2.new(0, 24, 1, 0); wsPlusBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65)
    wsPlusBtn.Text = "+"; wsPlusBtn.Font = Enum.Font.GothamBold; wsPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255); wsPlusBtn.TextSize = 12
    Instance.new("UICorner", wsPlusBtn).CornerRadius = UDim.new(0, 4)

    local function applyWsVal(val)
        val = math.max(1, tonumber(val) or 1)
        State.WarshipVolley = val
        wsBox.Text = tostring(val)
        if State.UI and State.UI.ModalWsBox then State.UI.ModalWsBox.Text = tostring(val) end
    end

    -- Shortcut Tombol Kuantiti Warship (1, 6, 12, 18)
    local presetValues = { 1, 6, 12, 18 }
    for _, pVal in ipairs(presetValues) do
        local pBtn = Instance.new("TextButton", wsRow)
        pBtn.Size = UDim2.new(0, 26, 1, 0); pBtn.BackgroundColor3 = Color3.fromRGB(32, 44, 68)
        pBtn.Text = tostring(pVal); pBtn.Font = Enum.Font.GothamBold; pBtn.TextColor3 = Color3.fromRGB(0, 220, 255); pBtn.TextSize = 10
        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
        local pStroke = Instance.new("UIStroke", pBtn); pStroke.Color = Color3.fromRGB(50, 75, 115); pStroke.Thickness = 1
        pBtn.MouseButton1Click:Connect(function()
            applyWsVal(pVal)
            showToast("Kuantiti Warship", string.format("Set armada: %d kapal", pVal), "info")
        end)
    end

    local wsAllBtn = Instance.new("TextButton", wsRow)
    wsAllBtn.Size = UDim2.new(0, 56, 1, 0); wsAllBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    wsAllBtn.Text = "MAX SIAP"; wsAllBtn.Font = Enum.Font.GothamBold; wsAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255); wsAllBtn.TextSize = 8.5
    Instance.new("UICorner", wsAllBtn).CornerRadius = UDim.new(0, 4)

    wsMinusBtn.MouseButton1Click:Connect(function()
        applyWsVal((State.WarshipVolley or 1) - 1)
    end)
    wsPlusBtn.MouseButton1Click:Connect(function()
        applyWsVal((State.WarshipVolley or 1) + 1)
    end)
    wsAllBtn.MouseButton1Click:Connect(function()
        local myShips = getMyPlacedWarships()
        local readyCount = 0
        for _, s in ipairs(myShips) do
            if s.IsReady then readyCount = readyCount + 1 end
        end
        local total = (readyCount > 0) and readyCount or math.max(1, #myShips)
        applyWsVal(total)
        showToast("Warship Ready MAX", string.format("Set ke %d kapal siap tempur (dari %d total di base)", readyCount, #myShips), "info")
    end)

    wsBox:GetPropertyChangedSignal("Text"):Connect(function()
        local clean = wsBox.Text:gsub("%D+", "")
        if clean ~= wsBox.Text then wsBox.Text = clean end
    end)
    wsBox.FocusLost:Connect(function()
        local val = tonumber(wsBox.Text)
        if not val or val < 1 then val = 1 end
        State.WarshipVolley = val
        wsBox.Text = tostring(val)
        showToast("Warship Quota", "Jumlah kapal per serangan diset ke " .. val .. " unit", "info")
    end)

    -- Strict Chosen Rockets Handler: Wajib pilih jenis misil terlebih dahulu!
    getChosenRockets = function()
        if not next(State.SelectedMissileTypes) then
            logMessage("⚠️ [BATAL SERANG] Anda belum memilih jenis misil! Centang jenis misil di checklist.")
            showToast("Pilih Misil Dulu", "Silakan centang jenis misil di kotak checklist sebelum menyerang!", "warn")
            return {}
        end

        local all = getMyPlacedRockets()
        local res = {}

        for _, r in ipairs(all) do
            if State.SelectedMissileTypes[r.ItemId] then
                table.insert(res, r)
            end
        end

        -- Jika roket terpilih kosong di base: JANGAN meluncurkan roket lain!
        if #res == 0 then
            local chosenId = next(State.SelectedMissileTypes)
            local chosenItem = (chosenId and MISSILE_BY_ID[chosenId]) or MISSILES[State.SelectedMissileIndex] or MISSILES[1]
            local quotaNeeded = (State.CustomMissileQuota and State.CustomMissileQuota > 0) and State.CustomMissileQuota or 10

            logMessage(string.format("⚠️ Misil terpilih (%s) habis di base! Memeriksa tas & toko...", chosenItem.Name))
            showToast("Misil Habis", string.format("Stok %s habis! Auto deploy/beli...", chosenItem.Name), "warn")

            local refilled = ensureMissilesReady(chosenItem, quotaNeeded)
            if refilled then
                local refreshed = getMyPlacedRockets()
                for _, r in ipairs(refreshed) do
                    if State.SelectedMissileTypes[r.ItemId] then table.insert(res, r) end
                end
            end

            if #res == 0 then
                logMessage("🛑 Misil terpilih tidak tersedia di base, tas, maupun toko!")
                showToast("Amunisi Habis", "Tidak ada misil terpilih yang tersedia untuk diluncurkan!", "danger")
                return {}
            end
        end

        return res
    end

    getChosenWarships = function()
        if not next(State.SelectedWarshipTypes) then
            logMessage("⚠️ [BATAL SERANG] Anda belum memilih jenis kapal! Centang jenis warship di checklist.")
            showToast("Pilih Kapal Dulu", "Silakan centang jenis warship di kotak checklist sebelum menyerang!", "warn")
            return {}
        end

        local all = getMyPlacedWarships()
        local readyList = {}
        for _, w in ipairs(all) do
            if w.IsReady then
                table.insert(readyList, w)
            end
        end

        local res = {}
        for _, w in ipairs(readyList) do
            if State.SelectedWarshipTypes[w.ItemId] then table.insert(res, w) end
        end

        if #res == 0 then
            logMessage("⚠️ Tidak ada kapal terpilih yang 100% SIAP tempur di dock!")
            showToast("Kapal Belum Siap", "Kapal yang dipilih belum siap tempur (HP/peluru belum penuh)", "warn")
        end

        return res
    end

    -- Helper kalkulasi kuota misil dan eksekusi salvo berulang jika CustomMissileQuota aktif
    executeMissileBatches = function(targetObj, usableRockets)
        if #usableRockets == 0 or not targetObj then return end

        local rocketsToFire = usableRockets
        if State.ClusteredLaunchEnabled and sortRocketsByProximity then
            rocketsToFire = sortRocketsByProximity(usableRockets)
        end

        local totalToFire = #rocketsToFire
        if State.CustomMissileQuota and State.CustomMissileQuota > 0 then
            totalToFire = math.min(#rocketsToFire, State.CustomMissileQuota)
        end

        local batchVolley = (State.ManualLaunchVolley == 999) and totalToFire or math.min(totalToFire, State.ManualLaunchVolley or 5)
        batchVolley = math.max(1, batchVolley)

        local fired = 0
        while fired < totalToFire do
            local curSize = math.min(batchVolley, totalToFire - fired)
            local group = {}
            for i = 1, curSize do
                table.insert(group, rocketsToFire[fired + i])
            end
            launchMissileVolley(targetObj, group, State.AutoBreakShield)
            fired = fired + curSize
            if fired < totalToFire then
                task.wait(0.015)
            end
        end
    end

    local actionButtons = {}
    local function createAtkBtn(txt, col, onClick)
        local btn = Instance.new("TextButton", lCard)
        btn.Size = UDim2.new(0.485, -4, 0, 28); btn.BackgroundColor3 = col
        btn.Text = txt; btn.Font = Enum.Font.GothamBold; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextSize = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        btn.MouseButton1Click:Connect(onClick)
        table.insert(actionButtons, btn)
        return btn
    end

    -- 1. Serang Bangunan (Buildings)
    local atkBuildingBtn
    atkBuildingBtn = createAtkBtn("🏢 Serang Bangunan (Buildings)", Color3.fromRGB(40, 120, 200), function()
        -- Aturan: Jika senjata Warship dipilih, mode loop diabaikan (hanya launch armada 1x sesuai kuantiti)
        if State.WeaponType ~= "Warship" and State.LoopAttackEnabled then
            toggleGenericTargetLoopAttack("Buildings", "Building", "🏢 Serang Bangunan (Buildings)", Color3.fromRGB(40, 120, 200), atkBuildingBtn)
            return
        end

        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end
        local chosenTarget = findClusteredTarget(tgt, "Buildings")
        if not chosenTarget and State.WeaponType ~= "Warship" then
            logMessage("Tidak ada bangunan tersisa!")
            showToast("Target Kosong", "Semua bangunan lawan sudah hancur", "warn")
            return
        end

        showToast("Serangan Bangunan", string.format("Menyerang %s di Base %d", (chosenTarget and chosenTarget.Name) or "Base Island", State.SelectedBaseIndex), "info")
        if State.WeaponType == "Missile" or State.WeaponType == "Kombinasi" then
            local r = getChosenRockets()
            if #r > 0 and chosenTarget then
                executeMissileBatches(chosenTarget, r)
            end
        end
        if State.WeaponType == "Warship" or State.WeaponType == "Kombinasi" then
            local ws = getChosenWarships()
            if #ws > 0 then
                local wsQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                local sendWs = {}
                for i = 1, wsQuota do table.insert(sendWs, ws[i]) end
                launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
            else
                logMessage("⚠️ Tidak ada warship yang 100% siap tempur!")
                showToast("Armada Belum Siap", "Tidak ada kapal siap tempur di dock", "warn")
            end
        end
    end)

    -- 2. Serang Anti-Air Defenses
    local atkAntiAirBtn
    atkAntiAirBtn = createAtkBtn("🛡️ Serang Anti-Air Defenses", Color3.fromRGB(180, 50, 80), function()
        if State.LoopAttackEnabled then
            toggleGenericTargetLoopAttack("AntiAir", "Anti-Air", "🛡️ Serang Anti-Air Defenses", Color3.fromRGB(180, 50, 80), atkAntiAirBtn)
            return
        end

        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end

        local chosenTarget = findClusteredTarget(tgt, "AntiAir")
        if not chosenTarget then
            logMessage("Tidak ada pertahanan Anti-Air di base lawan!")
            showToast("Target Kosong", "Tidak ada Anti-Air di base lawan", "warn")
            return
        end

        showToast("Serangan Anti-Air", string.format("Menyerang %s di Base %d", chosenTarget.Name, State.SelectedBaseIndex), "info")
        if State.WeaponType == "Warship" then
            local ws = getChosenWarships()
            if #ws > 0 then
                local wsQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                local sendWs = {}
                for i = 1, wsQuota do table.insert(sendWs, ws[i]) end
                launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
            else
                logMessage("⚠️ Tidak ada warship yang siap tempur!")
            end
        else
            local r = getChosenRockets()
            if #r > 0 then
                executeMissileBatches(chosenTarget, r)
            end

            if State.WeaponType == "Kombinasi" then
                local ws = getChosenWarships()
                if #ws > 0 then
                    local wsQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                    local sendWs = {}
                    for i = 1, wsQuota do table.insert(sendWs, ws[i]) end
                    launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
                end
            end
        end
    end)

    -- 3. Serang Anti-Sea Defenses
    local atkAntiSeaBtn
    atkAntiSeaBtn = createAtkBtn("⚓ Serang Anti-Sea Defenses", Color3.fromRGB(200, 120, 20), function()
        if State.LoopAttackEnabled then
            toggleGenericTargetLoopAttack("AntiShip", "Anti-Sea", "⚓ Serang Anti-Sea Defenses", Color3.fromRGB(200, 120, 20), atkAntiSeaBtn)
            return
        end

        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end

        local chosenTarget = findClusteredTarget(tgt, "AntiShip")
        if not chosenTarget then
            logMessage("Tidak ada pertahanan Anti-Sea di base lawan!")
            showToast("Target Kosong", "Tidak ada Anti-Sea di base lawan", "warn")
            return
        end

        showToast("Serangan Anti-Sea", string.format("Menyerang %s di Base %d", chosenTarget.Name, State.SelectedBaseIndex), "info")
        if State.WeaponType == "Warship" then
            local ws = getChosenWarships()
            if #ws > 0 then
                local wsQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                local sendWs = {}
                for i = 1, wsQuota do table.insert(sendWs, ws[i]) end
                launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
            else
                logMessage("⚠️ Tidak ada warship yang siap tempur!")
            end
        else
            local r = getChosenRockets()
            if #r > 0 then
                executeMissileBatches(chosenTarget, r)
            end

            if State.WeaponType == "Kombinasi" then
                local ws = getChosenWarships()
                if #ws > 0 then
                    local wsQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                    local sendWs = {}
                    for i = 1, wsQuota do table.insert(sendWs, ws[i]) end
                    launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
                end
            end
        end
    end)

    -- Event listener tombol toggle Loop Attack (ON / OFF)
    loopAttackBtn.MouseButton1Click:Connect(function()
        State.LoopAttackEnabled = not State.LoopAttackEnabled
        loopAttackBtn.BackgroundColor3 = State.LoopAttackEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(50, 60, 75)
        loopAttackBtn.Text = State.LoopAttackEnabled and "🔁 Loop: ON" or "🔁 Loop: OFF"
        if State.UI.ModalLoopAttackBtn then
            State.UI.ModalLoopAttackBtn.BackgroundColor3 = State.LoopAttackEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(50, 60, 75)
            State.UI.ModalLoopAttackBtn.Text = State.LoopAttackEnabled and "🔁 Loop: ON" or "🔁 Loop: OFF"
        end
        if not State.LoopAttackEnabled then
            if State.TargetLoopActive then
                State.TargetLoopActive = false
                State.ActiveLoopCategory = nil
                atkBuildingBtn.Text = "🏢 Serang Bangunan (Buildings)"; atkBuildingBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
                atkAntiAirBtn.Text = "🛡️ Serang Anti-Air Defenses"; atkAntiAirBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 80)
                atkAntiSeaBtn.Text = "⚓ Serang Anti-Sea Defenses"; atkAntiSeaBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 20)
            end
            if State.AutoComboLoopActive then
                State.AutoComboLoopActive = false
                if atkAutoComboBtn then
                    atkAutoComboBtn.Text = "⚡ SERANGAN OTOMATIS"
                    atkAutoComboBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 30)
                end
            end
        end
        showToast("Loop Attack", "Mode Loop Attack: " .. (State.LoopAttackEnabled and "ON (Klik tombol serangan untuk loop)" or "OFF (Serangan biasa)"), "info")
    end)


    -- 4. Serangan Kombinasi Warship + Missile
    local atkComboBtn = createAtkBtn("🔥 Serbuan Kombinasi (Fleet+Missile)", Color3.fromRGB(210, 45, 55), function()
        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end
        showToast("Serbuan Kombinasi", string.format("Mengerahkan Armada & Roket ke Base %d", State.SelectedBaseIndex), "danger")
        local ws = getChosenWarships()
        if #ws > 0 then
            local wsQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
            local sendWs = {}
            for i = 1, wsQuota do table.insert(sendWs, ws[i]) end
            logMessage(string.format("Mengerahkan armada %d kapal ke Base %d...", #sendWs, State.SelectedBaseIndex))
            launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
        end
        local r = getChosenRockets()
        local tList = {}
        for _, aa in ipairs(tgt.AntiAir) do if aa.HP > 0 then table.insert(tList, aa) end end
        for _, b in ipairs(tgt.Buildings) do if b.HP > 0 then table.insert(tList, b) end end
        if #r > 0 and #tList > 0 then
            executeMissileBatches(tList[1], r)
        end
    end)

    -- 5. Attack Otonomus Loop (Sasaran Bangunan Acak Setiap Launch)
    local atkOtonomusBtn = createAtkBtn("🤖 Serang Otonomus (Loop)", Color3.fromRGB(120, 50, 180), runAutonomousAttack)

    -- 8. PVE Island (Center Island)
    local atkPveBtn = createAtkBtn("🏝️ Serang PVE Center Island", Color3.fromRGB(0, 160, 140), function()
        showToast("Serang PVE", "Meluncurkan serangan ke Center Island", "info")
        local chosenR = (State.WeaponType == "Missile" or State.WeaponType == "Kombinasi") and getChosenRockets() or nil
        local chosenW = (State.WeaponType == "Warship" or State.WeaponType == "Kombinasi") and getChosenWarships() or nil
        launchPveAttack(State.WeaponType, State.AutoBreakShield, chosenR, chosenW)
    end)

    -- 9. Serang Karakter Lawan (Player Character Attack Langsung)
    local atkCharBtn = createAtkBtn("👤 Serang Karakter Lawan", Color3.fromRGB(220, 60, 80), function()
        local all = scanAllBases()
        local tgt = all[State.SelectedBaseIndex]
        if not tgt or tgt.IsLocal then
            showToast("Target Invalid", "Pilih base lawan yang valid terlebih dahulu!", "warn")
            return
        end

        local targetPlayer = nil
        -- 1. Cari via OwnerUserId jika ada
        if tgt.OwnerUserId then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.UserId == tgt.OwnerUserId then
                    targetPlayer = p
                    break
                end
            end
        end

        -- 2. Cari via matching nama (DisplayName / Name)
        if not targetPlayer and tgt.Owner and tgt.Owner ~= "Kosong" then
            local cleanOwner = tgt.Owner:lower():gsub("^team%-[^%s]+%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer then
                    local pName = p.Name:lower()
                    local pDisp = p.DisplayName:lower()
                    if pName == cleanOwner or pDisp == cleanOwner or pName:find(cleanOwner, 1, true) or pDisp:find(cleanOwner, 1, true) or cleanOwner:find(pName, 1, true) or cleanOwner:find(pDisp, 1, true) then
                        targetPlayer = p
                        break
                    end
                end
            end
        end

        -- 3. Cek koordinat fallback dari base jika karakter belum spawn / tidak ditemukan
        local fallbackPos = tgt.Position or BASE_COORDINATES[State.SelectedBaseIndex]
        local char = targetPlayer and targetPlayer.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
        local aimPos = (root and root.Position) or fallbackPos

        if not aimPos then
            showToast("Target Invalid", "Koordinat base atau karakter lawan tidak ditemukan!", "warn")
            return
        end

        local r = getChosenRockets()
        if #r == 0 then return end

        -- Mengambil tepat 1 misil saja (1x launch = 1 missile)
        local sendGroup = { r[1] }

        local targetLabel = targetPlayer and targetPlayer.DisplayName or tgt.Owner
        showToast("Serang Karakter", string.format("Meluncurkan 1 misil ke posisi %s (Base %d)!", targetLabel, State.SelectedBaseIndex), "danger")
        logMessage(string.format("👤 Meluncurkan 1 misil langsung ke target %s (Base %d, Pos: %.0f, %.0f, %.0f)", targetLabel, State.SelectedBaseIndex, aimPos.X, aimPos.Y, aimPos.Z))
        launchPlayerCharacterAttack(targetPlayer, sendGroup, State.AutoBreakShield, aimPos, tgt.OwnerUserId)
    end)

    -- 10. SERANGAN OTOMATIS (Loop Terpadu: Anti-Air -> Acak/Padat Anti-Sea & Bangunan)
    local atkAutoComboBtn
    atkAutoComboBtn = createAtkBtn("⚡ SERANGAN OTOMATIS", Color3.fromRGB(220, 70, 30), function()
        toggleAutoComboAttackLoop(atkAutoComboBtn)
    end)
    local comboStroke = Instance.new("UIStroke", atkAutoComboBtn)
    comboStroke.Color = Color3.fromRGB(255, 180, 0); comboStroke.Thickness = 1; comboStroke.Transparency = 0.4

    -- Tombol Update/Refresh Semua Status Tempur
    local syncBtn = createAtkBtn("📡 Sync & Refresh", Color3.fromRGB(30, 40, 60), function()
        renderBases()
        refreshWeaponStockChecklist()
        updateCombatAssistantUI()
        logMessage("Status kesiapan tempur & inventory berhasil disinkronkan.")
    end)
    syncBtn.TextColor3 = Color3.fromRGB(0, 220, 255)

    -- Fungsi Layout Dinamis Kontrol Serangan Berdasarkan Pilihan Senjata (Missile / Warship / Kombinasi)
    updateAttackControlsLayout = function()
        local mode = State.WeaponType or "Missile"
        local showMissileRow = (mode == "Missile" or mode == "Kombinasi")
        local showWarshipRow = (mode == "Warship" or mode == "Kombinasi")

        vBar.Visible = showMissileRow
        wsRow.Visible = showWarshipRow
        if lHarassFrame then lHarassFrame.Visible = showMissileRow end

        if mode == "Warship" then
            -- JIKA SENJATA = WARSHIP: Tampilkan Tombol Serang Warship + Serang PVE Center Island (Abaikan & sembunyikan loop)
            wsRow.Position = UDim2.new(0, 12, 0, 28)
            lCard.Size = UDim2.new(1, 0, 0, 168)
            if loopAttackBtn then loopAttackBtn.Visible = false end
            if lSpdFrame then lSpdFrame.Visible = false end

            atkBuildingBtn.Visible = true
            atkBuildingBtn.Text = "🚢 Luncurkan Armada Warship"
            atkBuildingBtn.Size = UDim2.new(1, -24, 0, 32)
            atkBuildingBtn.Position = UDim2.new(0, 12, 0, 58)

            -- Tombol PVE Island tetap tampil dan bisa diserang dengan Warship
            atkPveBtn.Visible = true
            atkPveBtn.Size = UDim2.new(1, -24, 0, 28)
            atkPveBtn.Position = UDim2.new(0, 12, 0, 94)

            -- Sembunyikan tombol serangan spesifik misil
            atkAntiAirBtn.Visible   = false
            atkAntiSeaBtn.Visible   = false
            atkComboBtn.Visible     = false
            atkOtonomusBtn.Visible  = false
            atkCharBtn.Visible      = false
            atkAutoComboBtn.Visible = false

            -- Tombol Sync diletakkan di bawah tombol PVE
            syncBtn.Visible  = true
            syncBtn.Size     = UDim2.new(1, -24, 0, 26)
            syncBtn.Position = UDim2.new(0, 12, 0, 126)
        else
            -- JIKA SENJATA = MISSILE ATAU KOMBINASI: Pulihkan layout tombol lengkap (Responsif 100% mengikuti lebar kartu)
            if loopAttackBtn then loopAttackBtn.Visible = true end
            if lSpdFrame then lSpdFrame.Visible = true end

            atkBuildingBtn.Text = "🏢 Serang Bangunan (Buildings)"
            atkBuildingBtn.Size = UDim2.new(0.5, -18, 0, 28)
            atkAntiAirBtn.Size   = UDim2.new(0.5, -18, 0, 28)
            atkAntiSeaBtn.Size   = UDim2.new(0.5, -18, 0, 28)
            atkComboBtn.Size     = UDim2.new(0.5, -18, 0, 28)
            atkOtonomusBtn.Size  = UDim2.new(0.5, -18, 0, 28)
            atkPveBtn.Size       = UDim2.new(0.5, -18, 0, 28)
            atkCharBtn.Size      = UDim2.new(0.5, -18, 0, 28)
            atkAutoComboBtn.Size = UDim2.new(0.5, -18, 0, 28)
            syncBtn.Size         = UDim2.new(1, -24, 0, 26)

            atkBuildingBtn.Visible  = true
            atkAntiAirBtn.Visible   = true
            atkAntiSeaBtn.Visible   = true
            atkComboBtn.Visible     = true
            atkOtonomusBtn.Visible  = true
            atkPveBtn.Visible       = true
            atkCharBtn.Visible      = true
            atkAutoComboBtn.Visible = true
            syncBtn.Visible         = true

            local btnStartY = 82
            if showMissileRow and showWarshipRow then
                vBar.Position = UDim2.new(0, 12, 0, 52)
                wsRow.Position = UDim2.new(0, 12, 0, 80)
                btnStartY = 112
                lCard.Size = UDim2.new(1, 0, 0, 316)
            else
                vBar.Position = UDim2.new(0, 12, 0, 52)
                btnStartY = 82
                lCard.Size = UDim2.new(1, 0, 0, 286)
            end

            atkBuildingBtn.Position  = UDim2.new(0, 12, 0, btnStartY)
            atkAntiAirBtn.Position    = UDim2.new(0.5, 6, 0, btnStartY)

            atkAntiSeaBtn.Position    = UDim2.new(0, 12, 0, btnStartY + 32)
            atkComboBtn.Position      = UDim2.new(0.5, 6, 0, btnStartY + 32)

            atkOtonomusBtn.Position   = UDim2.new(0, 12, 0, btnStartY + 64)
            atkPveBtn.Position        = UDim2.new(0.5, 6, 0, btnStartY + 64)

            atkCharBtn.Position       = UDim2.new(0, 12, 0, btnStartY + 96)
            atkAutoComboBtn.Position  = UDim2.new(0.5, 6, 0, btnStartY + 96)

            syncBtn.Position          = UDim2.new(0, 12, 0, btnStartY + 128)
            syncBtn.Size              = UDim2.new(1, -24, 0, 26)
        end
    end

    task.spawn(updateAttackControlsLayout)
end

-- 4. Tab Builder: Auto Farming
local function buildFarmTab(page)
    -- 1. Kartu Konfigurasi Auto Farm
    local fCard1 = Instance.new("Frame", page)
    fCard1.Size = UDim2.new(1, 0, 0, 218); fCard1.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", fCard1).CornerRadius = UDim.new(0, 8)
    local cStroke = Instance.new("UIStroke", fCard1)
    cStroke.Color = Color3.fromRGB(36, 48, 70); cStroke.Thickness = 1

    local fTitle1 = Instance.new("TextLabel", fCard1)
    fTitle1.Size = UDim2.new(1, -20, 0, 20); fTitle1.Position = UDim2.new(0, 12, 0, 6); fTitle1.BackgroundTransparency = 1
    fTitle1.Text = "⚙️ PENGATURAN SYARAT AUTO FARM (AUTOFARM ENGINE)"; fTitle1.Font = Enum.Font.GothamBold; fTitle1.TextColor3 = Color3.fromRGB(0, 220, 255)
    fTitle1.TextSize = 11; fTitle1.TextXAlignment = Enum.TextXAlignment.Left

    local specs = {
        { Key = "FarmMinBuildings",  Label = "Minimal Bangunan", Unit = "bangunan", Min = 1, Max = 500, Default = 45 },
        { Key = "FarmMinBuildLevel", Label = "Min Lv Bangunan",  Unit = "0=semua",  Min = 0, Max = 99,  Default = 14 },
        { Key = "FarmMinShips",      Label = "Min Warship",      Unit = "kapal",    Min = 1, Max = 100, Default = 6 },
        { Key = "FarmMaxShips",      Label = "Maks Warship",     Unit = "per target", Min = 1, Max = 100, Default = 8 },
        { Key = "FarmScanInterval",  Label = "Interval Scan",    Unit = "detik",    Min = 5, Max = 600, Default = 30 },
        { Key = "FarmFleetCheck",    Label = "Interval Armada",  Unit = "detik",    Min = 3, Max = 300, Default = 10 },
    }

    for i, sp in ipairs(specs) do
        local rFrame = Instance.new("Frame", fCard1)
        rFrame.Size = UDim2.new(1, -24, 0, 26)
        rFrame.Position = UDim2.new(0, 12, 0, 28 + (i - 1) * 31)
        rFrame.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", rFrame)
        lbl.Size = UDim2.new(0, 140, 1, 0); lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.TextColor3 = Color3.fromRGB(220, 230, 245)
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = sp.Label

        local box = Instance.new("TextBox", rFrame)
        box.Size = UDim2.new(0, 65, 0, 22); box.Position = UDim2.new(0, 145, 0, 2)
        box.BackgroundColor3 = Color3.fromRGB(30, 40, 58); box.Font = Enum.Font.GothamBold
        box.TextSize = 11; box.TextColor3 = Color3.fromRGB(0, 220, 255); box.ClearTextOnFocus = false
        box.Text = tostring(State[sp.Key] or sp.Default)
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local bStroke = Instance.new("UIStroke", box)
        bStroke.Color = Color3.fromRGB(48, 62, 90); bStroke.Thickness = 1

        local uLbl = Instance.new("TextLabel", rFrame)
        uLbl.Size = UDim2.new(0, 100, 1, 0); uLbl.Position = UDim2.new(0, 218, 0, 0); uLbl.BackgroundTransparency = 1
        uLbl.Font = Enum.Font.Gotham; uLbl.TextSize = 9; uLbl.TextColor3 = Color3.fromRGB(140, 160, 185)
        uLbl.TextXAlignment = Enum.TextXAlignment.Left; uLbl.Text = sp.Unit

        box.FocusLost:Connect(function()
            local v = tonumber(box.Text:gsub("%D+", "")) or sp.Default
            if v < sp.Min then v = sp.Min end
            if v > sp.Max then v = sp.Max end
            State[sp.Key] = v
            box.Text = tostring(v)
            saveConfig()
            AutoFarmAdv.updateStatus()
        end)
    end

    -- 2. Tombol Start / Stop Auto Farm
    local sFarmBtn = Instance.new("TextButton", page)
    sFarmBtn.Size = UDim2.new(1, 0, 0, 38)
    sFarmBtn.BackgroundColor3 = State.FarmRunning and Color3.fromRGB(200, 40, 60) or Color3.fromRGB(0, 180, 100)
    sFarmBtn.Text = State.FarmRunning and "⏹️ STOP AUTO FARM" or "▶️ START AUTO FARM"
    sFarmBtn.Font = Enum.Font.GothamBold; sFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255); sFarmBtn.TextSize = 12
    Instance.new("UICorner", sFarmBtn).CornerRadius = UDim.new(0, 8)
    AutoFarmAdv.UI.StartBtn = sFarmBtn

    sFarmBtn.MouseButton1Click:Connect(function()
        runAutoFarming(sFarmBtn)
    end)

    -- 3. Kartu Status Real-Time
    local fCard2 = Instance.new("Frame", page)
    fCard2.Size = UDim2.new(1, 0, 0, 104); fCard2.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", fCard2).CornerRadius = UDim.new(0, 8)
    local sStroke = Instance.new("UIStroke", fCard2)
    sStroke.Color = Color3.fromRGB(36, 48, 70); sStroke.Thickness = 1

    local sTitle = Instance.new("TextLabel", fCard2)
    sTitle.Size = UDim2.new(1, -20, 0, 14); sTitle.Position = UDim2.new(0, 12, 0, 6); sTitle.BackgroundTransparency = 1
    sTitle.Font = Enum.Font.GothamBold; sTitle.TextSize = 9; sTitle.TextColor3 = Color3.fromRGB(140, 160, 185)
    sTitle.TextXAlignment = Enum.TextXAlignment.Left; sTitle.Text = "STATUS AUTO FARM"

    local stMain = Instance.new("TextLabel", fCard2)
    stMain.Size = UDim2.new(1, -24, 0, 18); stMain.Position = UDim2.new(0, 12, 0, 22); stMain.BackgroundTransparency = 1
    stMain.Font = Enum.Font.GothamBold; stMain.TextSize = 11; stMain.TextColor3 = Color3.fromRGB(140, 160, 185)
    stMain.TextXAlignment = Enum.TextXAlignment.Left; stMain.TextTruncate = Enum.TextTruncate.AtEnd
    stMain.Text = State.FarmRunning and "Auto Farm Aktif" or "Siap. Tekan START."
    AutoFarmAdv.UI.StatusMain = stMain

    local det1 = Instance.new("TextLabel", fCard2)
    det1.Size = UDim2.new(1, -24, 0, 14); det1.Position = UDim2.new(0, 12, 0, 42); det1.BackgroundTransparency = 1
    det1.Font = Enum.Font.Code; det1.TextSize = 9; det1.TextColor3 = Color3.fromRGB(220, 235, 255)
    det1.TextXAlignment = Enum.TextXAlignment.Left; det1.Text = "Target: 0  •  Siap: 0"
    AutoFarmAdv.UI.StatusDetail1 = det1

    local det2 = Instance.new("TextLabel", fCard2)
    det2.Size = UDim2.new(1, -24, 0, 14); det2.Position = UDim2.new(0, 12, 0, 58); det2.BackgroundTransparency = 1
    det2.Font = Enum.Font.Code; det2.TextSize = 9; det2.TextColor3 = Color3.fromRGB(220, 235, 255)
    det2.TextXAlignment = Enum.TextXAlignment.Left; det2.Text = "Repair: 0  •  Reload: 0  •  Misi: 0"
    AutoFarmAdv.UI.StatusDetail2 = det2

    local det3 = Instance.new("TextLabel", fCard2)
    det3.Size = UDim2.new(1, -24, 0, 24); det3.Position = UDim2.new(0, 12, 0, 74); det3.BackgroundTransparency = 1
    det3.Font = Enum.Font.Gotham; det3.TextSize = 9; det3.TextColor3 = Color3.fromRGB(140, 160, 185)
    det3.TextXAlignment = Enum.TextXAlignment.Left; det3.TextYAlignment = Enum.TextYAlignment.Top
    det3.TextWrapped = true; det3.TextTruncate = Enum.TextTruncate.AtEnd
    det3.Text = "Belum ada antrean target."
    AutoFarmAdv.UI.StatusDetail3 = det3

    -- 4. Kartu Monitor Info Bangunan Base (1 - 6)
    local fCard3 = Instance.new("Frame", page)
    fCard3.Size = UDim2.new(1, 0, 0, 138); fCard3.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", fCard3).CornerRadius = UDim.new(0, 8)
    local bCardStroke = Instance.new("UIStroke", fCard3)
    bCardStroke.Color = Color3.fromRGB(36, 48, 70); bCardStroke.Thickness = 1

    local bTitle = Instance.new("TextLabel", fCard3)
    bTitle.Size = UDim2.new(1, -20, 0, 14); bTitle.Position = UDim2.new(0, 12, 0, 6); bTitle.BackgroundTransparency = 1
    bTitle.Font = Enum.Font.GothamBold; bTitle.TextSize = 9; bTitle.TextColor3 = Color3.fromRGB(140, 160, 185)
    bTitle.TextXAlignment = Enum.TextXAlignment.Left; bTitle.Text = "🏰 MONITOR BANGUNAN BASE (1 - 6)"

    AutoFarmAdv.UI.BaseRows = {}
    for i = 1, 6 do
        local rFrame = Instance.new("Frame", fCard3)
        rFrame.Size = UDim2.new(1, -24, 0, 16)
        rFrame.Position = UDim2.new(0, 12, 0, 24 + (i - 1) * 18)
        rFrame.BackgroundTransparency = 1

        local nLbl = Instance.new("TextLabel", rFrame)
        nLbl.Size = UDim2.new(0.55, 0, 1, 0); nLbl.BackgroundTransparency = 1
        nLbl.Font = Enum.Font.Code; nLbl.TextSize = 9; nLbl.TextColor3 = Color3.fromRGB(140, 160, 185)
        nLbl.TextXAlignment = Enum.TextXAlignment.Left; nLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nLbl.Text = string.format("B%d: -", i)

        local cLbl = Instance.new("TextLabel", rFrame)
        cLbl.Size = UDim2.new(0.45, 0, 1, 0); cLbl.Position = UDim2.new(0.55, 0, 0, 0); cLbl.BackgroundTransparency = 1
        cLbl.Font = Enum.Font.Code; cLbl.TextSize = 9; cLbl.TextColor3 = Color3.fromRGB(140, 160, 185)
        cLbl.TextXAlignment = Enum.TextXAlignment.Right; cLbl.TextTruncate = Enum.TextTruncate.AtEnd
        cLbl.Text = "-"

        AutoFarmAdv.UI.BaseRows[i] = {
            Frame = rFrame,
            NameLabel = nLbl,
            CountLabel = cLbl,
        }
    end

    -- Update info status awal
    task.spawn(function()
        AutoFarmAdv.updateStatus()
    end)
end

-- 5. Tab Builder: Fitur Tambahan (Utilities)
local function buildExtraTab(page)
    local uCard = Instance.new("Frame", page)
    uCard.Size = UDim2.new(1, 0, 0, 90); uCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", uCard).CornerRadius = UDim.new(0, 8)

    local uTitle = Instance.new("TextLabel", uCard)
    uTitle.Size = UDim2.new(1, -20, 0, 20); uTitle.Position = UDim2.new(0, 12, 0, 6); uTitle.BackgroundTransparency = 1
    uTitle.Text = "🕊️ TERBANG & SPEED BOOST"; uTitle.Font = Enum.Font.GothamBold; uTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    uTitle.TextSize = 12; uTitle.TextXAlignment = Enum.TextXAlignment.Left

    local fBtn = Instance.new("TextButton", uCard)
    fBtn.Size = UDim2.new(0, 130, 0, 30); fBtn.Position = UDim2.new(0, 12, 0, 30)
    fBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65); fBtn.Text = "Fly: OFF [F]"
    fBtn.Font = Enum.Font.GothamBold; fBtn.TextColor3 = Color3.fromRGB(220, 230, 255); fBtn.TextSize = 11
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)
    fBtn.MouseButton1Click:Connect(function()
        toggleFly(not State.FlyEnabled)
        fBtn.BackgroundColor3 = State.FlyEnabled and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(36, 45, 65)
        fBtn.Text = State.FlyEnabled and "Fly: ON [F]" or "Fly: OFF [F]"
    end)

    local spdBtn = Instance.new("TextButton", uCard)
    spdBtn.Size = UDim2.new(0, 130, 0, 30); spdBtn.Position = UDim2.new(0, 150, 0, 30)
    spdBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65); spdBtn.Text = "Speed: OFF (48)"
    spdBtn.Font = Enum.Font.GothamBold; spdBtn.TextColor3 = Color3.fromRGB(220, 230, 255); spdBtn.TextSize = 11
    Instance.new("UICorner", spdBtn).CornerRadius = UDim.new(0, 6)
    spdBtn.MouseButton1Click:Connect(function()
        toggleSpeed(not State.SpeedHackEnabled)
        spdBtn.BackgroundColor3 = State.SpeedHackEnabled and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(36, 45, 65)
        spdBtn.Text = State.SpeedHackEnabled and "Speed: ON (48)" or "Speed: OFF (48)"
    end)

    local frzBtn = Instance.new("TextButton", uCard)
    frzBtn.Size = UDim2.new(0, 150, 0, 30); frzBtn.Position = UDim2.new(0, 288, 0, 30)

    -- Tombol RAM & FPS Saver (Pembersih Puing / Anti-Lag saat Perang)
    local ramTabBtn = Instance.new("TextButton", uCard)
    ramTabBtn.Size = UDim2.new(0, 150, 0, 30); ramTabBtn.Position = UDim2.new(0, 446, 0, 30)
    ramTabBtn.Font = Enum.Font.GothamBold; ramTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ramTabBtn.TextSize = 10
    Instance.new("UICorner", ramTabBtn).CornerRadius = UDim.new(0, 6)

    local function updateFpsSaverAppearance()
        local en = State.FpsSaverEnabled
        ramTabBtn.BackgroundColor3 = en and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(45, 55, 75)
        ramTabBtn.Text = en and "🧹 RAM Saver: ON" or "🧹 RAM Saver: OFF"
    end
    State.UI.UpdateFpsSaverBtns = updateFpsSaverAppearance
    updateFpsSaverAppearance()

    ramTabBtn.MouseButton1Click:Connect(function()
        toggleFpsSaver(not State.FpsSaverEnabled)
    end)

    local function getFreezeBtnAppearance(mode)
        if mode == "Auto" then
            return Color3.fromRGB(0, 150, 220), "❄️ Freeze: AUTO (5s)"
        elseif mode == "ON" then
            return Color3.fromRGB(0, 180, 110), "❄️ Freeze: ON (Kebal)"
        else
            return Color3.fromRGB(45, 55, 75), "❄️ Freeze: OFF"
        end
    end

    local function updateFrzBtnAppearance()
        local col, txt = getFreezeBtnAppearance(State.FreezeMode or "ON")
        frzBtn.BackgroundColor3 = col
        frzBtn.Text = txt
    end

    State.UI.UpdateFreezeBtnTab = updateFrzBtnAppearance
    updateFrzBtnAppearance()
    frzBtn.Font = Enum.Font.GothamBold; frzBtn.TextColor3 = Color3.fromRGB(255, 255, 255); frzBtn.TextSize = 10
    Instance.new("UICorner", frzBtn).CornerRadius = UDim.new(0, 6)

    frzBtn.MouseButton1Click:Connect(function()
        -- Rotasi mode: ON -> OFF -> Auto -> ON
        local cur = State.FreezeMode or "ON"
        local nextMode = "OFF"
        if cur == "ON" then
            nextMode = "OFF"
        elseif cur == "OFF" then
            nextMode = "Auto"
        else
            nextMode = "ON"
        end
        setFreezeMode(nextMode)
    end)

    -- Teleport
    local tCard = Instance.new("Frame", page)
    tCard.Size = UDim2.new(1, 0, 0, 100); tCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", tCard).CornerRadius = UDim.new(0, 8)

    local tTitle = Instance.new("TextLabel", tCard)
    tTitle.Size = UDim2.new(1, -20, 0, 20); tTitle.Position = UDim2.new(0, 12, 0, 6); tTitle.BackgroundTransparency = 1
    tTitle.Text = "⚡ TELEPORT LOKASI & BASE"; tTitle.Font = Enum.Font.GothamBold; tTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    tTitle.TextSize = 12; tTitle.TextXAlignment = Enum.TextXAlignment.Left

    local tGrid = Instance.new("Frame", tCard)
    tGrid.Size = UDim2.new(1, -24, 0, 60); tGrid.Position = UDim2.new(0, 12, 0, 30); tGrid.BackgroundTransparency = 1
    local tgl = Instance.new("UIGridLayout", tGrid); tgl.CellSize = UDim2.new(0.24, -4, 0, 26); tgl.CellPadding = UDim2.new(0.01, 0, 0, 4)

    for i = 1, 6 do
        local b = Instance.new("TextButton", tGrid)
        b.BackgroundColor3 = Color3.fromRGB(30, 38, 55); b.Text = "Base " .. i
        b.Font = Enum.Font.GothamSemibold; b.TextColor3 = Color3.fromRGB(220, 235, 255); b.TextSize = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(function() teleportTo(BASE_COORDINATES[i]) end)
    end
    local cBtn = Instance.new("TextButton", tGrid)
    cBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90); cBtn.Text = "Center Island"
    cBtn.Font = Enum.Font.GothamBold; cBtn.TextColor3 = Color3.fromRGB(0, 220, 255); cBtn.TextSize = 11
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 5)
    cBtn.MouseButton1Click:Connect(function() teleportTo(CENTER_ISLAND_POS) end)

    -- Safe Fling & Kick Card
    local flCard = Instance.new("Frame", page)
    flCard.Size = UDim2.new(1, 0, 0, 290); flCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", flCard).CornerRadius = UDim.new(0, 8)

    local flTitle = Instance.new("TextLabel", flCard)
    flTitle.Size = UDim2.new(1, -20, 0, 20); flTitle.Position = UDim2.new(0, 12, 0, 6); flTitle.BackgroundTransparency = 1
    flTitle.Text = "🦵 TENDANG / FLING, TP TARGET & RAGDOLL"; flTitle.Font = Enum.Font.GothamBold; flTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    flTitle.TextSize = 12; flTitle.TextXAlignment = Enum.TextXAlignment.Left

    local tPlrBtn = Instance.new("TextButton", flCard)
    tPlrBtn.Size = UDim2.new(0, 200, 0, 28); tPlrBtn.Position = UDim2.new(0, 12, 0, 30)
    tPlrBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65); tPlrBtn.Font = Enum.Font.GothamSemibold
    tPlrBtn.Text = "Pilih Player: [Klik]"; tPlrBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tPlrBtn.TextSize = 10
    Instance.new("UICorner", tPlrBtn).CornerRadius = UDim.new(0, 6)

    local function getTargetDistanceText(target)
        if not target then return "N/A" end
        local tChar = target.Character or Workspace:FindFirstChild(target.Name)
        local tRoot = getAnyPhysicalRootPart(tChar)
        local myRoot = getAnyPhysicalRootPart(localPlayer.Character)
        if tRoot and myRoot then
            local dist = (myRoot.Position - tRoot.Position).Magnitude
            return string.format("%.0f stud", dist)
        end
        return "N/A"
    end

    local pIdx = 1
    tPlrBtn.MouseButton1Click:Connect(function()
        local plrs = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= localPlayer then table.insert(plrs, p) end end
        if #plrs == 0 then tPlrBtn.Text = "Tidak ada musuh!"; State.FlingTarget = nil; return end
        pIdx = (pIdx % #plrs) + 1
        State.FlingTarget = plrs[pIdx]
        local dText = getTargetDistanceText(State.FlingTarget)
        tPlrBtn.Text = string.format("Target: %s (%s)", State.FlingTarget.DisplayName, dText)
        showToast("Target Dipilih", string.format("Target: %s (Jarak: %s)", State.FlingTarget.DisplayName, dText), "info")
    end)

    -- Loop Update Jarak Target secara Realtime di tombol jika target dipilih
    task.spawn(function()
        while true do
            task.wait(1.0)
            if State.FlingTarget and tPlrBtn and tPlrBtn.Parent then
                local dText = getTargetDistanceText(State.FlingTarget)
                tPlrBtn.Text = string.format("Target: %s (%s)", State.FlingTarget.DisplayName, dText)
            end
        end
    end)

    -- Tombol TP Sendiri ke Target Player
    local tpPlrBtn = Instance.new("TextButton", flCard)
    tpPlrBtn.Size = UDim2.new(0, 130, 0, 28); tpPlrBtn.Position = UDim2.new(0, 220, 0, 30)
    tpPlrBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220); tpPlrBtn.Text = "⚡ Teleport ke Player"
    tpPlrBtn.Font = Enum.Font.GothamBold; tpPlrBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tpPlrBtn.TextSize = 10
    Instance.new("UICorner", tpPlrBtn).CornerRadius = UDim.new(0, 6)
    tpPlrBtn.MouseButton1Click:Connect(function()
        if not State.FlingTarget then
            logMessage("Pilih target player dulu!")
            showToast("Teleport Gagal", "Target belum dipilih", "danger")
            return
        end
        local tChar = State.FlingTarget.Character or Workspace:FindFirstChild(State.FlingTarget.Name)
        local tRoot = getAnyPhysicalRootPart(tChar)
        if tRoot then
            teleportTo(tRoot.CFrame * CFrame.new(0, 0, 3.5))
            logMessage("Teleport ke " .. State.FlingTarget.DisplayName .. " berhasil!")
            showToast("Teleport Berhasil", "Tiba di lokasi " .. State.FlingTarget.DisplayName, "success")
        else
            showToast("Teleport Gagal", "Part target belum ter-stream di client", "danger")
        end
    end)

    -- Pilihan Kekuatan Kick (Rendah -> Sedang -> Kuat -> Sangat Kuat)
    local pwrRow = Instance.new("Frame", flCard)
    pwrRow.Size = UDim2.new(1, -24, 0, 24); pwrRow.Position = UDim2.new(0, 12, 0, 64); pwrRow.BackgroundTransparency = 1
    local pwrl = Instance.new("UIListLayout", pwrRow); pwrl.FillDirection = Enum.FillDirection.Horizontal; pwrl.Padding = UDim.new(0, 6)

    local pwrLbl = Instance.new("TextLabel", pwrRow)
    pwrLbl.Size = UDim2.new(0, 85, 1, 0); pwrLbl.BackgroundTransparency = 1
    pwrLbl.Text = "Kekuatan Kick:"; pwrLbl.Font = Enum.Font.GothamBold; pwrLbl.TextColor3 = Color3.fromRGB(0, 220, 255); pwrLbl.TextSize = 10
    pwrLbl.TextXAlignment = Enum.TextXAlignment.Left

    local pwrButtons = {}
    local powers = { "Rendah", "Sedang", "Kuat", "Sangat Kuat" }
    for _, pVal in ipairs(powers) do
        local pb = Instance.new("TextButton", pwrRow)
        pb.Size = UDim2.new(0, 72, 1, 0)
        local isCur = (State.FlingPower == pVal) or (pVal == "Sangat Kuat" and State.FlingPower == "Ekstrim")
        pb.BackgroundColor3 = isCur and Color3.fromRGB(220, 80, 40) or Color3.fromRGB(30, 40, 58)
        pb.Text = pVal; pb.Font = Enum.Font.GothamBold; pb.TextColor3 = Color3.fromRGB(255, 255, 255); pb.TextSize = 10
        Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 4)
        pb.MouseButton1Click:Connect(function()
            State.FlingPower = pVal
            for _, b in pairs(pwrButtons) do b.BackgroundColor3 = Color3.fromRGB(30, 40, 58) end
            pb.BackgroundColor3 = Color3.fromRGB(220, 80, 40)
            showToast("Kekuatan Kick", "Kekuatan tendangan diset: " .. pVal, "info")
            logMessage("Kekuatan kick diset ke " .. pVal)
        end)
        pwrButtons[pVal] = pb
    end

    -- Baris Tombol Aksi Kick: TP + Kick & Kick Only
    local kBtn = Instance.new("TextButton", flCard)
    kBtn.Size = UDim2.new(0, 180, 0, 28); kBtn.Position = UDim2.new(0, 12, 0, 94)
    kBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60); kBtn.Text = "🚀 TP + Kick Target"
    kBtn.Font = Enum.Font.GothamBold; kBtn.TextColor3 = Color3.fromRGB(255, 255, 255); kBtn.TextSize = 11
    Instance.new("UICorner", kBtn).CornerRadius = UDim.new(0, 6)
    kBtn.MouseButton1Click:Connect(function()
        if State.FlingTarget then
            executeSafeFling(State.FlingTarget, true)
        else
            logMessage("Pilih target dulu!")
            showToast("Kick Dibatalkan", "Pilih target player terlebih dahulu", "warn")
        end
    end)

    local kOnlyBtn = Instance.new("TextButton", flCard)
    kOnlyBtn.Size = UDim2.new(0, 150, 0, 28); kOnlyBtn.Position = UDim2.new(0, 200, 0, 94)
    kOnlyBtn.BackgroundColor3 = Color3.fromRGB(190, 70, 30); kOnlyBtn.Text = "💥 Kick Only (Tanpa TP)"
    kOnlyBtn.Font = Enum.Font.GothamBold; kOnlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); kOnlyBtn.TextSize = 11
    Instance.new("UICorner", kOnlyBtn).CornerRadius = UDim.new(0, 6)
    kOnlyBtn.MouseButton1Click:Connect(function()
        if State.FlingTarget then
            executeSafeFling(State.FlingTarget, false)
        else
            logMessage("Pilih target dulu!")
            showToast("Kick Dibatalkan", "Pilih target player terlebih dahulu", "warn")
        end
    end)

    -- Toggle Auto Recall & Follow Target
    local recallBtn = Instance.new("TextButton", flCard)
    recallBtn.Size = UDim2.new(0, 180, 0, 26); recallBtn.Position = UDim2.new(0, 12, 0, 128)
    recallBtn.BackgroundColor3 = State.FlingAutoRecall and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(45, 55, 75)
    recallBtn.Text = State.FlingAutoRecall and "Auto Recall: ON" or "Auto Recall: OFF"
    recallBtn.Font = Enum.Font.GothamBold; recallBtn.TextColor3 = Color3.fromRGB(255, 255, 255); recallBtn.TextSize = 10
    Instance.new("UICorner", recallBtn).CornerRadius = UDim.new(0, 5)
    recallBtn.MouseButton1Click:Connect(function()
        State.FlingAutoRecall = not State.FlingAutoRecall
        recallBtn.BackgroundColor3 = State.FlingAutoRecall and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(45, 55, 75)
        recallBtn.Text = State.FlingAutoRecall and "Auto Recall: ON" or "Auto Recall: OFF"
        showToast("Auto Recall", State.FlingAutoRecall and "Karakter akan kembali ke posisi semula setelah kick" or "Karakter tetap berada di posisi target", "info")
    end)

    local folBtn = Instance.new("TextButton", flCard)
    folBtn.Size = UDim2.new(0, 150, 0, 26); folBtn.Position = UDim2.new(0, 200, 0, 128)
    folBtn.BackgroundColor3 = State.FollowTarget and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(36, 45, 65)
    folBtn.Text = State.FollowTarget and "Follow Player: ON" or "Follow Player: OFF"
    folBtn.Font = Enum.Font.GothamBold; folBtn.TextColor3 = Color3.fromRGB(220, 235, 255); folBtn.TextSize = 10
    Instance.new("UICorner", folBtn).CornerRadius = UDim.new(0, 5)

    local function updateExtraFollowBtn()
        if folBtn and folBtn.Parent then
            local isFollowing = State.FollowTarget ~= nil
            folBtn.BackgroundColor3 = isFollowing and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(36, 45, 65)
            folBtn.Text = isFollowing and "Follow Player: ON" or "Follow Player: OFF"
        end
    end
    State.UI.UpdateFollowButtonsList = State.UI.UpdateFollowButtonsList or {}
    table.insert(State.UI.UpdateFollowButtonsList, updateExtraFollowBtn)

    folBtn.MouseButton1Click:Connect(function()
        if State.FollowTarget then
            toggleFollow(nil, false)
            showToast("Follow OFF", "Berhenti mengikuti target", "info")
        else
            if State.FlingTarget then
                toggleFollow(State.FlingTarget, true)
                showToast("Follow ON", "Mengikuti " .. State.FlingTarget.DisplayName, "success")
            else
                showToast("Follow Gagal", "Pilih target terlebih dahulu", "warn")
            end
        end
    end)

    -- Baris Fitur Ragdoll & Anti-Ragdoll
    local ragdollActive = false
    local ragBtn = Instance.new("TextButton", flCard)
    ragBtn.Size = UDim2.new(0, 180, 0, 28); ragBtn.Position = UDim2.new(0, 12, 0, 160)
    ragBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 120); ragBtn.Text = "🤸 Ragdoll Diri Sendiri"
    ragBtn.Font = Enum.Font.GothamBold; ragBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ragBtn.TextSize = 10
    Instance.new("UICorner", ragBtn).CornerRadius = UDim.new(0, 5)

    local antiRagBtn = Instance.new("TextButton", flCard)
    antiRagBtn.Size = UDim2.new(0, 150, 0, 28); antiRagBtn.Position = UDim2.new(0, 200, 0, 160)
    antiRagBtn.BackgroundColor3 = State.AntiRagdollEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(45, 55, 75)
    antiRagBtn.Text = State.AntiRagdollEnabled and "🛡️ Anti-Ragdoll: ON" or "🛡️ Anti-Ragdoll: OFF"
    antiRagBtn.Font = Enum.Font.GothamBold; antiRagBtn.TextColor3 = Color3.fromRGB(255, 255, 255); antiRagBtn.TextSize = 10
    Instance.new("UICorner", antiRagBtn).CornerRadius = UDim.new(0, 5)

    ragBtn.MouseButton1Click:Connect(function()
        ragdollActive = not ragdollActive
        triggerRagdoll(ragdollActive)
        ragBtn.Text = ragdollActive and "🤸 Bangun (Stop Ragdoll)" or "🤸 Ragdoll Diri Sendiri"
        ragBtn.BackgroundColor3 = ragdollActive and Color3.fromRGB(210, 40, 80) or Color3.fromRGB(150, 45, 120)
        if ragdollActive and State.AntiRagdollEnabled then
            antiRagBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
            antiRagBtn.Text = "🛡️ Anti-Ragdoll: OFF"
        end
    end)

    antiRagBtn.MouseButton1Click:Connect(function()
        toggleAntiRagdoll(not State.AntiRagdollEnabled)
        antiRagBtn.BackgroundColor3 = State.AntiRagdollEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(45, 55, 75)
        antiRagBtn.Text = State.AntiRagdollEnabled and "🛡️ Anti-Ragdoll: ON" or "🛡️ Anti-Ragdoll: OFF"
        if State.AntiRagdollEnabled and ragdollActive then
            ragdollActive = false
            ragBtn.Text = "🤸 Ragdoll Diri Sendiri"
            ragBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 120)
        end
    end)

    -- Baris In-Place Vibration Fling Target
    local vibeBtn = Instance.new("TextButton", flCard)
    vibeBtn.Size = UDim2.new(1, -24, 0, 26); vibeBtn.Position = UDim2.new(0, 12, 0, 194)
    vibeBtn.BackgroundColor3 = State.VibeFlingActive and Color3.fromRGB(220, 70, 30) or Color3.fromRGB(36, 48, 70)
    vibeBtn.Text = State.VibeFlingActive and "⚡ In-Place Vibration Target: ON [STOP]" or "⚡ In-Place Vibration Target: OFF [KLIK UNTUK GETARKAN TARGET]"
    vibeBtn.Font = Enum.Font.GothamBold; vibeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); vibeBtn.TextSize = 10
    Instance.new("UICorner", vibeBtn).CornerRadius = UDim.new(0, 5)
    local vStroke = Instance.new("UIStroke", vibeBtn); vStroke.Color = Color3.fromRGB(0, 200, 255); vStroke.Thickness = 1; vStroke.Transparency = 0.5

    vibeBtn.MouseButton1Click:Connect(function()
        if not State.VibeFlingActive and not State.FlingTarget then
            showToast("Pilih Target Dulu", "Pilih target player di tombol atas sebelum vibration fling!", "warn")
            return
        end
        local newState = not State.VibeFlingActive
        local ok = toggleInPlaceVibrationFling(newState, State.FlingTarget)
        vibeBtn.BackgroundColor3 = State.VibeFlingActive and Color3.fromRGB(220, 70, 30) or Color3.fromRGB(36, 48, 70)
        vibeBtn.Text = State.VibeFlingActive and ("⚡ In-Place Vibration Target: ON (" .. (State.FlingTarget and State.FlingTarget.DisplayName or "Target") .. ")") or "⚡ In-Place Vibration Target: OFF [KLIK UNTUK GETARKAN TARGET]"
    end)

    -- Baris Fitur Baru: AUTO EVADE / TELEPORT MENJAUH OTOMATIS (< 10 stud -> Jauhkan 15 stud)
    local autoEvadeBtn = Instance.new("TextButton", flCard)
    autoEvadeBtn.Size = UDim2.new(1, -24, 0, 28); autoEvadeBtn.Position = UDim2.new(0, 12, 0, 226)
    autoEvadeBtn.BackgroundColor3 = State.AutoEvadeEnabled and Color3.fromRGB(0, 175, 110) or Color3.fromRGB(45, 55, 75)
    autoEvadeBtn.Text = State.AutoEvadeEnabled and "🛡️ Auto-Evade (<10 stud): ON (Menjauh 15 stud)" or "🛡️ Auto-Evade (<10 stud): OFF"
    autoEvadeBtn.Font = Enum.Font.GothamBold; autoEvadeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); autoEvadeBtn.TextSize = 11
    Instance.new("UICorner", autoEvadeBtn).CornerRadius = UDim.new(0, 6)
    local aeStroke = Instance.new("UIStroke", autoEvadeBtn); aeStroke.Color = Color3.fromRGB(0, 255, 180); aeStroke.Thickness = 1; aeStroke.Transparency = 0.6

    autoEvadeBtn.MouseButton1Click:Connect(function()
        State.AutoEvadeEnabled = not State.AutoEvadeEnabled
        autoEvadeBtn.BackgroundColor3 = State.AutoEvadeEnabled and Color3.fromRGB(0, 175, 110) or Color3.fromRGB(45, 55, 75)
        autoEvadeBtn.Text = State.AutoEvadeEnabled and "🛡️ Auto-Evade (<10 stud): ON (Menjauh 15 stud)" or "🛡️ Auto-Evade (<10 stud): OFF"
        showToast("Auto-Evade", State.AutoEvadeEnabled and "Auto teleport menjauh 15 stud aktif saat ada player < 10 stud!" or "Auto-Evade dinonaktifkan.", "info")
    end)

    -- Configuration Card (wwesaved.json)
    local cfgCard = Instance.new("Frame", page)
    cfgCard.Size = UDim2.new(1, 0, 0, 75); cfgCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", cfgCard).CornerRadius = UDim.new(0, 8)

    local cfgTitle = Instance.new("TextLabel", cfgCard)
    cfgTitle.Size = UDim2.new(1, -20, 0, 20); cfgTitle.Position = UDim2.new(0, 12, 0, 6); cfgTitle.BackgroundTransparency = 1
    cfgTitle.Text = "💾 FILE KONFIGURASI (wwesaved.json)"; cfgTitle.Font = Enum.Font.GothamBold; cfgTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    cfgTitle.TextSize = 12; cfgTitle.TextXAlignment = Enum.TextXAlignment.Left

    local saveCfgBtn = Instance.new("TextButton", cfgCard)
    saveCfgBtn.Size = UDim2.new(0, 160, 0, 28); saveCfgBtn.Position = UDim2.new(0, 12, 0, 32)
    saveCfgBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 220); saveCfgBtn.Text = "💾 Simpan Config (JSON)"
    saveCfgBtn.Font = Enum.Font.GothamBold; saveCfgBtn.TextColor3 = Color3.fromRGB(255, 255, 255); saveCfgBtn.TextSize = 11
    Instance.new("UICorner", saveCfgBtn).CornerRadius = UDim.new(0, 6)
    saveCfgBtn.MouseButton1Click:Connect(saveConfigToFile)

    local loadCfgBtn = Instance.new("TextButton", cfgCard)
    loadCfgBtn.Size = UDim2.new(0, 160, 0, 28); loadCfgBtn.Position = UDim2.new(0, 185, 0, 32)
    loadCfgBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 140); loadCfgBtn.Text = "📂 Muat Config (JSON)"
    loadCfgBtn.Font = Enum.Font.GothamBold; loadCfgBtn.TextColor3 = Color3.fromRGB(255, 255, 255); loadCfgBtn.TextSize = 11
    Instance.new("UICorner", loadCfgBtn).CornerRadius = UDim.new(0, 6)
    loadCfgBtn.MouseButton1Click:Connect(loadConfigFromFile)
end

-- 6. Tab Builder: Pengaturan Grafik Ringan
local function buildGraphicsTab(page)
    local gCard = Instance.new("Frame", page)
    gCard.Size = UDim2.new(1, 0, 0, 120)
    gCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", gCard).CornerRadius = UDim.new(0, 8)

    local gTitle = Instance.new("TextLabel", gCard)
    gTitle.Size = UDim2.new(1, -20, 0, 20)
    gTitle.Position = UDim2.new(0, 12, 0, 6)
    gTitle.BackgroundTransparency = 1
    gTitle.Text = "⚡ PENGATURAN GRAFIK (RINGAN & HEMAT CPU)"
    gTitle.Font = Enum.Font.GothamBold
    gTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    gTitle.TextSize = 12
    gTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- 1. Tombol Pause Animasi Laut
    local seaBtn = Instance.new("TextButton", gCard)
    seaBtn.Size = UDim2.new(1, -24, 0, 34)
    seaBtn.Position = UDim2.new(0, 12, 0, 32)
    seaBtn.BackgroundColor3 = State.SeaDisabled and Color3.fromRGB(150, 40, 40) or Color3.fromRGB(30, 75, 120)
    seaBtn.Text = State.SeaDisabled and "🌊 Animasi Laut: BEKU / PAUSE (OFF)" or "🌊 Animasi Laut: NORMAL (ON)"
    seaBtn.Font = Enum.Font.GothamBold
    seaBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
    seaBtn.TextSize = 11
    Instance.new("UICorner", seaBtn).CornerRadius = UDim.new(0, 6)
    seaBtn.MouseButton1Click:Connect(function()
        local disabled = toggleSeaAnimation()
        if disabled then
            seaBtn.Text = "🌊 Animasi Laut: BEKU / PAUSE (OFF)"
            seaBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            showToast("Grafik", "Animasi gelombang laut berhasil di-pause!", "info")
        else
            seaBtn.Text = "🌊 Animasi Laut: NORMAL (ON)"
            seaBtn.BackgroundColor3 = Color3.fromRGB(30, 75, 120)
            showToast("Grafik", "Animasi gelombang laut normal kembali.", "info")
        end
    end)

    -- 2. Tombol Hilangkan Shadow & PostFX
    local lightBtn = Instance.new("TextButton", gCard)
    lightBtn.Size = UDim2.new(1, -24, 0, 34)
    lightBtn.Position = UDim2.new(0, 12, 0, 72)
    lightBtn.BackgroundColor3 = State.UltraLowLighting and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(40, 65, 95)
    lightBtn.Text = State.UltraLowLighting and "💡 Shadow & Lighting: HILANG (OFF / Ultra Low)" or "💡 Shadow & Lighting: AKTIF (ON / Standar)"
    lightBtn.Font = Enum.Font.GothamBold
    lightBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
    lightBtn.TextSize = 11
    Instance.new("UICorner", lightBtn).CornerRadius = UDim.new(0, 6)
    lightBtn.MouseButton1Click:Connect(function()
        local enableLow = not State.UltraLowLighting
        toggleUltraLowLighting(enableLow)
        if enableLow then
            lightBtn.Text = "💡 Shadow & Lighting: HILANG (OFF / Ultra Low)"
            lightBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
            showToast("Grafik", "Shadow & Post-Effects dinonaktifkan!", "success")
        else
            lightBtn.Text = "💡 Shadow & Lighting: AKTIF (ON / Standar)"
            lightBtn.BackgroundColor3 = Color3.fromRGB(40, 65, 95)
            showToast("Grafik", "Shadow & Lighting dikembalikan normal.", "info")
        end
    end)
end

local function makeResizable(targetFrame, minSize, maxSize, accentColor)
    local constraint = Instance.new("UISizeConstraint", targetFrame)
    constraint.MinSize = minSize or Vector2.new(320, 240)
    constraint.MaxSize = maxSize or Vector2.new(1600, 1200)

    local handle = Instance.new("ImageButton", targetFrame)
    handle.Name = "ResizeHandle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(1, -16, 1, -16)
    handle.BackgroundTransparency = 1
    handle.Image = "rbxassetid://6031094038" -- Resize grip icon
    handle.ImageColor3 = accentColor or Color3.fromRGB(0, 220, 255)
    handle.ImageTransparency = 0.2
    handle.ZIndex = 9999

    local isResizing = false
    local resizeStartMouse = Vector2.new()
    local resizeStartSize = Vector2.new()

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            resizeStartSize = Vector2.new(targetFrame.AbsoluteSize.X, targetFrame.AbsoluteSize.Y)
            handle.ImageTransparency = 0
            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                    handle.ImageTransparency = 0.2
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseDelta = Vector2.new(input.Position.X, input.Position.Y) - resizeStartMouse
            local newW = math.clamp(resizeStartSize.X + mouseDelta.X, constraint.MinSize.X, constraint.MaxSize.X)
            local newH = math.clamp(resizeStartSize.Y + mouseDelta.Y, constraint.MinSize.Y, constraint.MaxSize.Y)
            targetFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    return handle
end

local function createAttackHUDModal(parentGui)
    local atkModal = Instance.new("Frame", parentGui)
    atkModal.Name = "AttackMode_HUD"
    atkModal.Size = UDim2.new(0, 390, 0, 430)
    atkModal.Position = UDim2.new(0.5, 20, 0.5, -215)
    atkModal.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    atkModal.BorderSizePixel = 0
    atkModal.Active = true
    atkModal.Draggable = true
    atkModal.Visible = State.AttackModalVisible or false
    Instance.new("UICorner", atkModal).CornerRadius = UDim.new(0, 10)
    local amStroke = Instance.new("UIStroke", atkModal)
    amStroke.Color = Color3.fromRGB(255, 80, 50); amStroke.Thickness = 1.5; amStroke.Transparency = 0.3

    makeResizable(atkModal, Vector2.new(320, 260), Vector2.new(900, 950), Color3.fromRGB(255, 100, 60))

    -- Header Modal
    local amHeader = Instance.new("Frame", atkModal)
    amHeader.Size = UDim2.new(1, 0, 0, 36); amHeader.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
    Instance.new("UICorner", amHeader).CornerRadius = UDim.new(0, 10)

    -- Judul Header Attack Mode
    local amTitle = Instance.new("TextLabel", amHeader)
    amTitle.Size = UDim2.new(0, 100, 1, 0); amTitle.Position = UDim2.new(0, 10, 0, 0)
    amTitle.BackgroundTransparency = 1; amTitle.Text = "⚔️ ATTACK HUD"
    amTitle.Font = Enum.Font.GothamBold; amTitle.TextColor3 = Color3.fromRGB(255, 120, 90)
    amTitle.TextSize = 11; amTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Container Header Controls (Flexibel & Responsif saat diperkecil / diperbesar)
    local amControls = Instance.new("Frame", amHeader)
    amControls.Size = UDim2.new(1, -115, 1, 0); amControls.Position = UDim2.new(0, 110, 0, 0)
    amControls.BackgroundTransparency = 1
    local amcl = Instance.new("UIListLayout", amControls)
    amcl.FillDirection = Enum.FillDirection.Horizontal
    amcl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    amcl.VerticalAlignment = Enum.VerticalAlignment.Center
    amcl.Padding = UDim.new(0, 4)

    -- 1. Tombol Auto Deploy
    local amAutoDeploy = Instance.new("TextButton", amControls)
    amAutoDeploy.Size = UDim2.new(0, 56, 0, 24); amAutoDeploy.BackgroundColor3 = State.AutoDeployActive and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(38, 48, 70)
    amAutoDeploy.Text = State.AutoDeployActive and "🔄 Dep:ON" or "🔄 Dep:OFF"
    amAutoDeploy.Font = Enum.Font.GothamBold; amAutoDeploy.TextColor3 = Color3.fromRGB(255, 255, 255); amAutoDeploy.TextSize = 8.5
    Instance.new("UICorner", amAutoDeploy).CornerRadius = UDim.new(0, 5)
    local amadStroke = Instance.new("UIStroke", amAutoDeploy); amadStroke.Color = Color3.fromRGB(0, 220, 150); amadStroke.Thickness = 1
    amAutoDeploy.MouseButton1Click:Connect(toggleAutoDeploy)
    State.UI.AutoDeployButtons = State.UI.AutoDeployButtons or {}
    table.insert(State.UI.AutoDeployButtons, amAutoDeploy)

    -- 2. Tombol Unlock 150
    local amUnlock150 = Instance.new("TextButton", amControls)
    amUnlock150.Size = UDim2.new(0, 50, 0, 24); amUnlock150.BackgroundColor3 = State.Unlock150Missiles and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(60, 35, 45)
    amUnlock150.Text = State.Unlock150Missiles and "🔓 150" or "🔒 150"
    amUnlock150.Font = Enum.Font.GothamBold; amUnlock150.TextColor3 = Color3.fromRGB(255, 255, 255); amUnlock150.TextSize = 8.5
    Instance.new("UICorner", amUnlock150).CornerRadius = UDim.new(0, 5)
    local am150Stroke = Instance.new("UIStroke", amUnlock150); am150Stroke.Color = State.Unlock150Missiles and Color3.fromRGB(0, 220, 140) or Color3.fromRGB(120, 50, 60); am150Stroke.Thickness = 1
    amUnlock150.MouseButton1Click:Connect(toggleUnlock150)
    State.UI.Unlock150Buttons = State.UI.Unlock150Buttons or {}
    table.insert(State.UI.Unlock150Buttons, amUnlock150)

    -- 3. Tombol Unlock X10
    local amUnlockX10 = Instance.new("TextButton", amControls)
    amUnlockX10.Size = UDim2.new(0, 48, 0, 24); amUnlockX10.BackgroundColor3 = State.UnlockX10 and Color3.fromRGB(0, 150, 90) or Color3.fromRGB(70, 30, 35)
    amUnlockX10.Text = State.UnlockX10 and "🔓 X10" or "🔒 X10"
    amUnlockX10.Font = Enum.Font.GothamBold; amUnlockX10.TextColor3 = Color3.fromRGB(255, 255, 255); amUnlockX10.TextSize = 8.5
    Instance.new("UICorner", amUnlockX10).CornerRadius = UDim.new(0, 5)
    local amxStroke = Instance.new("UIStroke", amUnlockX10); amxStroke.Color = State.UnlockX10 and Color3.fromRGB(0, 220, 140) or Color3.fromRGB(120, 50, 60); amxStroke.Thickness = 1
    amUnlockX10.MouseButton1Click:Connect(toggleUnlockX10)
    State.UI.UnlockX10Buttons = State.UI.UnlockX10Buttons or {}
    table.insert(State.UI.UnlockX10Buttons, amUnlockX10)

    -- 4. Tombol Drone View
    local amDroneBtn = Instance.new("TextButton", amControls)
    amDroneBtn.Size = UDim2.new(0, 54, 0, 24); amDroneBtn.BackgroundColor3 = State.DroneViewEnabled and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(45, 55, 75)
    amDroneBtn.Text = State.DroneViewEnabled and "🚁 ON" or "🚁 Drone"
    amDroneBtn.Font = Enum.Font.GothamBold; amDroneBtn.TextColor3 = Color3.fromRGB(255, 255, 255); amDroneBtn.TextSize = 8.5
    Instance.new("UICorner", amDroneBtn).CornerRadius = UDim.new(0, 5)
    local amdStroke = Instance.new("UIStroke", amDroneBtn); amdStroke.Color = Color3.fromRGB(0, 220, 150); amdStroke.Thickness = 1
    State.UI.DroneViewBtn = amDroneBtn

    -- 5. Tombol TP Base
    local amTpBase = Instance.new("TextButton", amControls)
    amTpBase.Size = UDim2.new(0, 48, 0, 24); amTpBase.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
    amTpBase.Text = "🌀 TP"; amTpBase.Font = Enum.Font.GothamBold; amTpBase.TextColor3 = Color3.fromRGB(255, 255, 255); amTpBase.TextSize = 8.5
    Instance.new("UICorner", amTpBase).CornerRadius = UDim.new(0, 5)
    local amtStroke = Instance.new("UIStroke", amTpBase); amtStroke.Color = Color3.fromRGB(80, 240, 255); amtStroke.Thickness = 1
    amTpBase.MouseButton1Click:Connect(function()
        teleportBaseRandomSpot()
    end)

    -- 6. Tombol Close (✕)
    local amClose = Instance.new("TextButton", amControls)
    amClose.Size = UDim2.new(0, 24, 0, 24); amClose.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    amClose.Text = "✕"; amClose.Font = Enum.Font.GothamBold; amClose.TextColor3 = Color3.fromRGB(255, 120, 120); amClose.TextSize = 11
    Instance.new("UICorner", amClose).CornerRadius = UDim.new(0, 5)
    amClose.MouseButton1Click:Connect(function()
        State.AttackModalVisible = false
        atkModal.Visible = false
    end)

    -- Container Kontrol Drone View (Slider Ketinggian + D-Pad Tombol Penggeser Kanan Kiri Atas Bawah)
    local droneSliderCard = Instance.new("Frame", atkModal)
    droneSliderCard.Name = "DroneSliderCard"
    droneSliderCard.Size = UDim2.new(1, -12, 0, 56)
    droneSliderCard.Position = UDim2.new(0, 6, 0, 36)
    droneSliderCard.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
    droneSliderCard.BorderSizePixel = 0
    droneSliderCard.Visible = State.DroneViewEnabled or false
    Instance.new("UICorner", droneSliderCard).CornerRadius = UDim.new(0, 6)
    local dscStroke = Instance.new("UIStroke", droneSliderCard)
    dscStroke.Color = Color3.fromRGB(0, 200, 140); dscStroke.Thickness = 1; dscStroke.Transparency = 0.5
    State.UI.DroneSliderContainer = droneSliderCard

    -- Baris 1: Slider Ketinggian Drone + Tombol Sembunyikan (Hide/Close)
    local dsRow1 = Instance.new("Frame", droneSliderCard)
    dsRow1.Size = UDim2.new(1, 0, 0, 26); dsRow1.Position = UDim2.new(0, 0, 0, 2); dsRow1.BackgroundTransparency = 1

    local dsLabel = Instance.new("TextLabel", dsRow1)
    dsLabel.Size = UDim2.new(0, 95, 1, 0); dsLabel.Position = UDim2.new(0, 8, 0, 0); dsLabel.BackgroundTransparency = 1
    dsLabel.Text = "🚁 Altitude:"; dsLabel.Font = Enum.Font.GothamBold
    dsLabel.TextColor3 = Color3.fromRGB(0, 230, 180); dsLabel.TextSize = 8.5; dsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local dsTrack = Instance.new("TextButton", dsRow1)
    dsTrack.Size = UDim2.new(1, -225, 0, 8); dsTrack.Position = UDim2.new(0, 105, 0.5, -4)
    dsTrack.BackgroundColor3 = Color3.fromRGB(28, 38, 54); dsTrack.Text = ""; dsTrack.AutoButtonColor = false
    Instance.new("UICorner", dsTrack).CornerRadius = UDim.new(0, 4)

    local MIN_DRONE_ALT = 30
    local MAX_DRONE_ALT = 1500
    local curDronePct = math.clamp(((State.DroneAltitude or 120) - MIN_DRONE_ALT) / (MAX_DRONE_ALT - MIN_DRONE_ALT), 0, 1)

    local dsFill = Instance.new("Frame", dsTrack)
    dsFill.Size = UDim2.new(curDronePct, 0, 1, 0); dsFill.BackgroundColor3 = Color3.fromRGB(0, 220, 160); dsFill.BorderSizePixel = 0
    Instance.new("UICorner", dsFill).CornerRadius = UDim.new(0, 4)

    local dsKnob = Instance.new("Frame", dsTrack)
    dsKnob.Size = UDim2.new(0, 12, 0, 12); dsKnob.Position = UDim2.new(curDronePct, -6, 0.5, -6)
    dsKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); dsKnob.BorderSizePixel = 0
    Instance.new("UICorner", dsKnob).CornerRadius = UDim.new(1, 0)

    local dsValLbl = Instance.new("TextLabel", dsRow1)
    dsValLbl.Size = UDim2.new(0, 58, 1, 0); dsValLbl.Position = UDim2.new(1, -118, 0, 0); dsValLbl.BackgroundTransparency = 1
    dsValLbl.Text = string.format("%d stud", State.DroneAltitude or 120)
    dsValLbl.Font = Enum.Font.GothamBold; dsValLbl.TextColor3 = Color3.fromRGB(255, 220, 100); dsValLbl.TextSize = 8.5
    dsValLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Tombol Sembunyikan Panel Kontrol Drone (▲ Sembunyi)
    local hideDroneBtn = Instance.new("TextButton", dsRow1)
    hideDroneBtn.Size = UDim2.new(0, 52, 0, 20); hideDroneBtn.Position = UDim2.new(1, -56, 0, 3)
    hideDroneBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    hideDroneBtn.Text = "▲ Hide"; hideDroneBtn.Font = Enum.Font.GothamBold
    hideDroneBtn.TextColor3 = Color3.fromRGB(200, 225, 255); hideDroneBtn.TextSize = 8.5
    Instance.new("UICorner", hideDroneBtn).CornerRadius = UDim.new(0, 4)
    local hdbStroke = Instance.new("UIStroke", hideDroneBtn)
    hdbStroke.Color = Color3.fromRGB(80, 110, 150); hdbStroke.Thickness = 1

    hideDroneBtn.MouseButton1Click:Connect(function()
        droneSliderCard.Visible = false
        showToast("Panel Drone", "Panel kontrol slider disembunyikan.", "info")
    end)

    local function setDroneAltitude(alt, notify)
        alt = math.clamp(math.floor(alt + 0.5), MIN_DRONE_ALT, MAX_DRONE_ALT)
        State.DroneAltitude = alt
        local pct = (alt - MIN_DRONE_ALT) / (MAX_DRONE_ALT - MIN_DRONE_ALT)
        dsFill.Size = UDim2.new(pct, 0, 1, 0)
        dsKnob.Position = UDim2.new(pct, -6, 0.5, -6)
        dsValLbl.Text = string.format("%d stud", alt)
        if notify then
            showToast("Drone Altitude", string.format("Ketinggian drone: %d stud", alt), "info")
        end
    end

    local isDraggingDrone = false
    local function updateDroneFromInput(input)
        local relX = math.clamp(input.Position.X - dsTrack.AbsolutePosition.X, 0, dsTrack.AbsoluteSize.X)
        local pct = (dsTrack.AbsoluteSize.X > 0) and (relX / dsTrack.AbsoluteSize.X) or 0
        local alt = MIN_DRONE_ALT + pct * (MAX_DRONE_ALT - MIN_DRONE_ALT)
        setDroneAltitude(alt, false)
    end

    dsTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingDrone = true
            updateDroneFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingDrone and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDroneFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingDrone then
                isDraggingDrone = false
                showToast("Drone Altitude", string.format("Ketinggian drone diatur ke %d stud", State.DroneAltitude or 120), "info")
            end
        end
    end)

    -- Baris 2: Tombol Penggeser Drone View (Kiri, Kanan, Atas, Bawah, dan Reset Tengah)
    local dsRow2 = Instance.new("Frame", droneSliderCard)
    dsRow2.Size = UDim2.new(1, -12, 0, 22); dsRow2.Position = UDim2.new(0, 6, 0, 30); dsRow2.BackgroundTransparency = 1

    local panLbl = Instance.new("TextLabel", dsRow2)
    panLbl.Size = UDim2.new(0, 105, 1, 0); panLbl.Position = UDim2.new(0, 2, 0, 0); panLbl.BackgroundTransparency = 1
    panLbl.Text = "🕹️ Pan View:"; panLbl.Font = Enum.Font.GothamBold
    panLbl.TextColor3 = Color3.fromRGB(0, 210, 255); panLbl.TextSize = 8.5; panLbl.TextXAlignment = Enum.TextXAlignment.Left

    local panContainer = Instance.new("Frame", dsRow2)
    panContainer.Size = UDim2.new(1, -110, 1, 0); panContainer.Position = UDim2.new(0, 110, 0, 0); panContainer.BackgroundTransparency = 1
    local pcl = Instance.new("UIListLayout", panContainer)
    pcl.FillDirection = Enum.FillDirection.Horizontal
    pcl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    pcl.VerticalAlignment = Enum.VerticalAlignment.Center
    pcl.Padding = UDim.new(0, 4)

    local function createPanBtn(text, deltaX, deltaZ, isReset)
        local pb = Instance.new("TextButton", panContainer)
        pb.Size = isReset and UDim2.new(0, 46, 0, 20) or UDim2.new(0, 30, 0, 20)
        pb.BackgroundColor3 = isReset and Color3.fromRGB(45, 55, 75) or Color3.fromRGB(28, 38, 56)
        pb.Text = text; pb.Font = Enum.Font.GothamBold
        pb.TextColor3 = isReset and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(220, 240, 255)
        pb.TextSize = isReset and 8.5 or 11
        Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 4)
        local pbs = Instance.new("UIStroke", pb)
        pbs.Color = Color3.fromRGB(60, 80, 110); pbs.Thickness = 1

        local panStep = 35 -- Setiap klik bergeser 35 stud
        pb.MouseButton1Click:Connect(function()
            if isReset then
                State.DroneOffsetX = 0
                State.DroneOffsetZ = 0
                showToast("Drone Center", "Posisi Drone View kembali ke tengah!", "info")
            else
                State.DroneOffsetX = (State.DroneOffsetX or 0) + (deltaX * panStep)
                State.DroneOffsetZ = (State.DroneOffsetZ or 0) + (deltaZ * panStep)
            end
        end)
    end

    createPanBtn("⬆️", 0, -1, false) -- Atas (Maju ke arah North/Z negatif)
    createPanBtn("⬇️", 0, 1, false)  -- Bawah (Mundur ke arah South/Z positif)
    createPanBtn("⬅️", -1, 0, false) -- Kiri (West/X negatif)
    createPanBtn("➡️", 1, 0, false)  -- Kanan (East/X positif)
    createPanBtn("Center", 0, 0, true) -- Reset ke tengah karakter

    local contentScroll = Instance.new("ScrollingFrame", atkModal)
    local function adjustContentScrollLayout()
        if droneSliderCard.Visible then
            contentScroll.Size = UDim2.new(1, -12, 1, -100)
            contentScroll.Position = UDim2.new(0, 6, 0, 96)
        else
            contentScroll.Size = UDim2.new(1, -12, 1, -40)
            contentScroll.Position = UDim2.new(0, 6, 0, 36)
        end
    end
    adjustContentScrollLayout()
    droneSliderCard:GetPropertyChangedSignal("Visible"):Connect(adjustContentScrollLayout)

    amDroneBtn.MouseButton1Click:Connect(function()
        -- Toggle ON / OFF Drone View
        local newStatus = not State.DroneViewEnabled
        toggleDroneView(newStatus)
    end)

    contentScroll.BackgroundTransparency = 1; contentScroll.ScrollBarThickness = 3; contentScroll.CanvasSize = UDim2.new(0, 0, 0, 620)
    local csl = Instance.new("UIListLayout", contentScroll); csl.Padding = UDim.new(0, 5)

    -- Section 1: Pemilihan Target Base / Player
    local secTarget = Instance.new("Frame", contentScroll)
    secTarget.Size = UDim2.new(1, 0, 0, 64); secTarget.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", secTarget).CornerRadius = UDim.new(0, 6)

    local stHeader = Instance.new("Frame", secTarget)
    stHeader.Size = UDim2.new(1, 0, 0, 20); stHeader.BackgroundTransparency = 1

    local stTitle = Instance.new("TextLabel", stHeader)
    stTitle.Size = UDim2.new(1, -100, 1, 0); stTitle.Position = UDim2.new(0, 6, 0, 1); stTitle.BackgroundTransparency = 1
    stTitle.Text = "🎯 PILIH TARGET BASE:"; stTitle.Font = Enum.Font.GothamBold; stTitle.TextColor3 = Color3.fromRGB(0, 220, 255); stTitle.TextSize = 9; stTitle.TextXAlignment = Enum.TextXAlignment.Left

    local refBaseBtn = Instance.new("TextButton", stHeader)
    refBaseBtn.Size = UDim2.new(0, 85, 0, 16); refBaseBtn.Position = UDim2.new(1, -90, 0, 2)
    refBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220); refBaseBtn.Text = "🔄 Refresh"
    refBaseBtn.Font = Enum.Font.GothamBold; refBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); refBaseBtn.TextSize = 8
    Instance.new("UICorner", refBaseBtn).CornerRadius = UDim.new(0, 4)

    local baseGrid = Instance.new("Frame", secTarget)
    baseGrid.Size = UDim2.new(1, -12, 0, 36); baseGrid.Position = UDim2.new(0, 6, 0, 22); baseGrid.BackgroundTransparency = 1
    local bgl = Instance.new("UIGridLayout", baseGrid); bgl.CellSize = UDim2.new(0.155, -2, 0, 34); bgl.CellPadding = UDim2.new(0.012, 0, 0, 0)

    local modalBaseBtns = {}
    local updateModalAnalyzeUI = nil

    local function renderModalBases()
        local all = scanAllBases()
        for idx = 1, 6 do
            local b = all[idx]
            local btn = modalBaseBtns[idx]
            if not btn then
                btn = Instance.new("TextButton", baseGrid)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                btn.Font = Enum.Font.GothamBold; btn.TextSize = 8
                modalBaseBtns[idx] = btn
                btn.MouseButton1Click:Connect(function()
                    State.SelectedBaseIndex = idx
                    renderModalBases()
                    if updateModalAnalyzeUI then updateModalAnalyzeUI() end
                    if State.UI.UpdateCombatAssistantUI then pcall(State.UI.UpdateCombatAssistantUI) end
                end)
            end

            local isSelected = (idx == State.SelectedBaseIndex)
            btn.BackgroundColor3 = isSelected and Color3.fromRGB(0, 150, 235) or Color3.fromRGB(28, 36, 52)
            if b then
                if b.IsLocal then
                    btn.Text = string.format("B%d(ME)\n%s", idx, b.Owner:sub(1, 5))
                    btn.TextColor3 = Color3.fromRGB(120, 255, 170)
                else
                    btn.Text = string.format("B%d%s\n%s", idx, b.HasShield and "🛡️" or "", b.Owner:sub(1, 5))
                    btn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 225, 245)
                end
            else
                btn.Text = string.format("B%d\n(Emp)", idx)
                btn.TextColor3 = Color3.fromRGB(130, 140, 160)
            end
        end
    end

    refBaseBtn.MouseButton1Click:Connect(function()
        renderModalBases()
        if updateModalAnalyzeUI then updateModalAnalyzeUI() end
        if State.UI.UpdateCombatAssistantUI then pcall(State.UI.UpdateCombatAssistantUI) end
        showToast("Refresh Base", "Status pangkalan berhasil diperbarui", "info")
    end)

    -- Section 2: ANALISIS CANGGIH (Sinkron format dengan GUI utama)
    local secAnalyze = Instance.new("Frame", contentScroll)
    secAnalyze.Size = UDim2.new(1, 0, 0, 155); secAnalyze.BackgroundColor3 = Color3.fromRGB(18, 23, 34)
    Instance.new("UICorner", secAnalyze).CornerRadius = UDim.new(0, 6)

    local saHeader = Instance.new("Frame", secAnalyze)
    saHeader.Size = UDim2.new(1, 0, 0, 22); saHeader.BackgroundTransparency = 1

    local saTitle = Instance.new("TextLabel", saHeader)
    saTitle.Size = UDim2.new(0, 170, 1, 0); saTitle.Position = UDim2.new(0, 6, 0, 0); saTitle.BackgroundTransparency = 1
    saTitle.Text = "🔬 ANALISIS PERTAHANAN"; saTitle.Font = Enum.Font.GothamBold; saTitle.TextColor3 = Color3.fromRGB(0, 240, 220); saTitle.TextSize = 10; saTitle.TextXAlignment = Enum.TextXAlignment.Left

    local saControls = Instance.new("Frame", saHeader)
    saControls.Size = UDim2.new(0, 260, 0, 18); saControls.Position = UDim2.new(1, -264, 0, 2); saControls.BackgroundTransparency = 1
    local sacl = Instance.new("UIListLayout", saControls); sacl.FillDirection = Enum.FillDirection.Horizontal; sacl.Padding = UDim.new(0, 4)

    local modalManClickBtn = Instance.new("TextButton", saControls)
    modalManClickBtn.Size = UDim2.new(0, 85, 1, 0)
    modalManClickBtn.BackgroundColor3 = State.ManualClickAttackEnabled and Color3.fromRGB(220, 50, 70) or Color3.fromRGB(45, 55, 75)
    modalManClickBtn.Text = State.ManualClickAttackEnabled and string.format("🎯 Klik: x%d", State.ManualClickCount or 0) or "🎯 Klik: OFF"
    modalManClickBtn.Font = Enum.Font.GothamBold; modalManClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255); modalManClickBtn.TextSize = 8
    Instance.new("UICorner", modalManClickBtn).CornerRadius = UDim.new(0, 4)

    State.UI.ManualClickButtons[modalManClickBtn] = { IsModal = true }

    modalManClickBtn.MouseButton1Click:Connect(function()
        State.ManualClickAttackEnabled = not State.ManualClickAttackEnabled
        if not State.ManualClickAttackEnabled then
            State.ManualClickCount = 0
            if saRadar and saRadar.ResetClickCounter then saRadar.ResetClickCounter() end
            showToast("Klik Minimap", "Mode serang manual dinonaktifkan.", "info")
        else
            showToast("Klik Minimap Aktif", "Klik titik mana saja di minimap base untuk meluncurkan misil langsung!", "success")
        end
        if State.UI.UpdateManualClickBtn then
            pcall(State.UI.UpdateManualClickBtn)
        end
    end)


    local autoRefBtn = Instance.new("TextButton", saControls)
    autoRefBtn.Size = UDim2.new(0, 80, 1, 0)
    autoRefBtn.BackgroundColor3 = (State.AttackModalAutoRefresh or State.AutoRefreshAssistant) and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(45, 55, 75)
    autoRefBtn.Text = (State.AttackModalAutoRefresh or State.AutoRefreshAssistant) and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
    autoRefBtn.Font = Enum.Font.GothamBold; autoRefBtn.TextColor3 = Color3.fromRGB(255, 255, 255); autoRefBtn.TextSize = 8
    Instance.new("UICorner", autoRefBtn).CornerRadius = UDim.new(0, 4)
    State.UI.ModalAutoRefBtn = autoRefBtn

    local refreshBtn = Instance.new("TextButton", saControls)
    refreshBtn.Size = UDim2.new(0, 55, 1, 0); refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 68)
    refreshBtn.Text = "🔄 Refresh"; refreshBtn.Font = Enum.Font.GothamBold; refreshBtn.TextColor3 = Color3.fromRGB(0, 220, 255); refreshBtn.TextSize = 8
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

    -- Container Body: Kiri = Teks Analisis, Kanan = Radar Minimap Base Lawan
    local saBody = Instance.new("Frame", secAnalyze)
    saBody.Size = UDim2.new(1, -12, 0, 128); saBody.Position = UDim2.new(0, 6, 0, 22); saBody.BackgroundTransparency = 1

    local saLabel = Instance.new("TextLabel", saBody)
    saLabel.Size = UDim2.new(1, -118, 1, 0); saLabel.Position = UDim2.new(0, 0, 0, 0)
    saLabel.BackgroundTransparency = 1; saLabel.Font = Enum.Font.Code; saLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
    saLabel.TextSize = 8.5; saLabel.TextXAlignment = Enum.TextXAlignment.Left; saLabel.TextYAlignment = Enum.TextYAlignment.Top
    saLabel.TextWrapped = true; saLabel.LineHeight = 1.12
    saLabel.RichText = true
    saLabel.Text = "Memindai pertahanan base..."

    -- Radar visualisasi peta base musuh
    local saRadar = createBaseRadarWidget(saBody, UDim2.new(0, 112, 1, 0))
    saRadar.Box.Position = UDim2.new(1, -112, 0, 0)

    updateModalAnalyzeUI = function()
        saLabel.Text = generateBaseDefenseAnalysis(State.SelectedBaseIndex)
        saRadar.Update(State.SelectedBaseIndex)
    end
    State.UI.UpdateModalAnalyzeUI = updateModalAnalyzeUI

    autoRefBtn.MouseButton1Click:Connect(function()
        local newState = not (State.AttackModalAutoRefresh or State.AutoRefreshAssistant)
        State.AttackModalAutoRefresh = newState
        State.AutoRefreshAssistant = newState
        autoRefBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(45, 55, 75)
        autoRefBtn.Text = newState and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
        if State.UI.AttackTabAutoRefBtn then
            State.UI.AttackTabAutoRefBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(45, 55, 75)
            State.UI.AttackTabAutoRefBtn.Text = newState and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
        end
        showToast("Auto Refresh", "Realtime auto refresh per detik: " .. (newState and "ON" or "OFF"), "info")
    end)

    refreshBtn.MouseButton1Click:Connect(function()
        renderModalBases()
        updateModalAnalyzeUI()
        if State.UI.UpdateCombatAssistantUI then pcall(State.UI.UpdateCombatAssistantUI) end
        showToast("Refresh Analisis", "Data pertahanan & zona base telah diperbarui", "info")
    end)

    task.spawn(function()
        while atkModal and atkModal.Parent do
            task.wait(1.0)
            if State.AttackModalVisible and (State.AttackModalAutoRefresh or State.AutoRefreshAssistant) then
                pcall(function()
                    renderModalBases()
                    updateModalAnalyzeUI()
                end)
            end
        end
    end)

    -- Section 3: PILIH SENJATA (Missile, Warship, Kombinasi) & CHECKLIST AMUNISI
    local secWeapon = Instance.new("Frame", contentScroll)
    secWeapon.Size = UDim2.new(1, 0, 0, 112); secWeapon.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", secWeapon).CornerRadius = UDim.new(0, 6)

    local swHeader = Instance.new("Frame", secWeapon)
    swHeader.Size = UDim2.new(1, 0, 0, 20); swHeader.BackgroundTransparency = 1

    local swTitle = Instance.new("TextLabel", swHeader)
    swTitle.Size = UDim2.new(0, 160, 1, 0); swTitle.Position = UDim2.new(0, 6, 0, 2); swTitle.BackgroundTransparency = 1
    swTitle.Text = "⚔️ SENJATA & AMUNISI:"; swTitle.Font = Enum.Font.GothamBold; swTitle.TextColor3 = Color3.fromRGB(0, 220, 255); swTitle.TextSize = 9; swTitle.TextXAlignment = Enum.TextXAlignment.Left

    local refreshChkBtn = Instance.new("TextButton", swHeader)
    refreshChkBtn.Size = UDim2.new(0, 85, 0, 16); refreshChkBtn.Position = UDim2.new(1, -90, 0, 2)
    refreshChkBtn.BackgroundColor3 = Color3.fromRGB(35, 48, 70); refreshChkBtn.Text = "🔄 Refresh"
    refreshChkBtn.Font = Enum.Font.GothamBold; refreshChkBtn.TextColor3 = Color3.fromRGB(0, 220, 255); refreshChkBtn.TextSize = 8
    Instance.new("UICorner", refreshChkBtn).CornerRadius = UDim.new(0, 4)

    local swRow = Instance.new("Frame", secWeapon)
    swRow.Size = UDim2.new(1, -12, 0, 22); swRow.Position = UDim2.new(0, 6, 0, 22); swRow.BackgroundTransparency = 1
    local swl = Instance.new("UIListLayout", swRow); swl.FillDirection = Enum.FillDirection.Horizontal; swl.Padding = UDim.new(0, 5)

    -- Scroll Checklist Senjata Terpasang di Modal HUD
    local mScroll = Instance.new("ScrollingFrame", secWeapon)
    mScroll.Size = UDim2.new(1, -12, 0, 60); mScroll.Position = UDim2.new(0, 6, 0, 46)
    mScroll.BackgroundColor3 = Color3.fromRGB(14, 18, 27); mScroll.ScrollBarThickness = 3
    Instance.new("UICorner", mScroll).CornerRadius = UDim.new(0, 5)
    local mGrid = Instance.new("UIGridLayout", mScroll); mGrid.CellSize = UDim2.new(0.485, -2, 0, 22); mGrid.CellPadding = UDim2.new(0.02, 0, 0, 3)

    local renderModalChecklist = nil
    local updateModalControlsLayout = nil

    renderModalChecklist = function()
        for _, ch in ipairs(mScroll:GetChildren()) do if ch:IsA("GuiObject") then ch:Destroy() end end
        local rList = getMyPlacedRockets()
        local wsList = getMyPlacedWarships()

        local rCounts = {}
        for _, r in ipairs(rList) do
            rCounts[r.ItemId] = (rCounts[r.ItemId] or 0) + 1
        end

        local wsCounts = {}
        local wsReadyCounts = {}
        for _, w in ipairs(wsList) do
            wsCounts[w.ItemId] = (wsCounts[w.ItemId] or 0) + 1
            if w.IsReady then
                wsReadyCounts[w.ItemId] = (wsReadyCounts[w.ItemId] or 0) + 1
            end
        end

        local totalRows = 0

        -- Render Roket jika mode Missile atau Kombinasi
        if State.WeaponType == "Missile" or State.WeaponType == "Kombinasi" then
            for id, count in pairs(rCounts) do
                totalRows = totalRows + 1
                local spec = MISSILE_BY_ID[id] or { Name = id }
                local isChecked = (State.SelectedMissileTypes[id] == true)
                local itemBtn = Instance.new("TextButton", mScroll)
                itemBtn.BackgroundColor3 = isChecked and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(35, 42, 58)
                itemBtn.Text = string.format("%s 🚀 %s: %d", isChecked and "✅" or "⬜", spec.Name, count)
                itemBtn.Font = Enum.Font.GothamMedium; itemBtn.TextColor3 = isChecked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 205, 225); itemBtn.TextSize = 8
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

                itemBtn.MouseButton1Click:Connect(function()
                    State.SelectedMissileTypes[id] = not State.SelectedMissileTypes[id]
                    renderModalChecklist()
                    if refreshAttackTabChecklists then pcall(refreshAttackTabChecklists) end
                end)
            end
        end

        -- Render Warship jika mode Warship atau Kombinasi
        if State.WeaponType == "Warship" or State.WeaponType == "Kombinasi" then
            for id, count in pairs(wsCounts) do
                totalRows = totalRows + 1
                local spec = WARSHIP_SPECS[id] or { Name = id }
                local ready = wsReadyCounts[id] or 0
                local isChecked = (State.SelectedWarshipTypes[id] == true)
                local itemBtn = Instance.new("TextButton", mScroll)
                itemBtn.BackgroundColor3 = isChecked and Color3.fromRGB(0, 140, 210) or Color3.fromRGB(35, 42, 58)
                itemBtn.Text = string.format("%s 🚢 %s: %d/%d SIAP", isChecked and "✅" or "⬜", spec.Name, ready, count)
                itemBtn.Font = Enum.Font.GothamMedium
                itemBtn.TextColor3 = isChecked and Color3.fromRGB(255, 255, 255) or ((ready > 0) and Color3.fromRGB(120, 255, 180) or Color3.fromRGB(255, 170, 170))
                itemBtn.TextSize = 8
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

                itemBtn.MouseButton1Click:Connect(function()
                    State.SelectedWarshipTypes[id] = not State.SelectedWarshipTypes[id]
                    renderModalChecklist()
                    if refreshAttackTabChecklists then pcall(refreshAttackTabChecklists) end
                end)
            end
        end

        if totalRows == 0 then
            local emptyLbl = Instance.new("TextLabel", mScroll)
            emptyLbl.Size = UDim2.new(1, 0, 1, 0); emptyLbl.BackgroundTransparency = 1
            emptyLbl.Text = (State.WeaponType == "Missile") and "Tidak ada roket di base!" or ((State.WeaponType == "Warship") and "Tidak ada warship di dock!" or "Tidak ada roket/warship!")
            emptyLbl.TextColor3 = Color3.fromRGB(255, 160, 100); emptyLbl.Font = Enum.Font.Gotham; emptyLbl.TextSize = 9
        end
        mScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(math.max(1, totalRows) / 2) * 25 + 6)
    end

    refreshChkBtn.MouseButton1Click:Connect(function()
        renderModalChecklist()
        showToast("Refresh Senjata", "Inventory roket & kapal berhasil disinkronkan", "info")
    end)

    local wpBtns = {}
    local weapons = { "Missile", "Warship", "Kombinasi" }
    for _, wMode in ipairs(weapons) do
        local wb = Instance.new("TextButton", swRow)
        wb.Size = UDim2.new(0.315, 0, 1, 0)
        local isCur = (State.WeaponType == wMode)
        wb.BackgroundColor3 = isCur and Color3.fromRGB(0, 160, 230) or Color3.fromRGB(30, 40, 58)
        wb.Text = (wMode == "Missile" and "🚀 Missile" or (wMode == "Warship" and "🚢 Warship" or "🔥 Kombinasi"))
        wb.Font = Enum.Font.GothamBold; wb.TextColor3 = Color3.fromRGB(255, 255, 255); wb.TextSize = 9
        Instance.new("UICorner", wb).CornerRadius = UDim.new(0, 5)
        wb.MouseButton1Click:Connect(function()
            State.WeaponType = wMode
            for _, b in pairs(wpBtns) do b.BackgroundColor3 = Color3.fromRGB(30, 40, 58) end
            wb.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
            showToast("Senjata Dipilih", "Mode senjata aktif: " .. wMode, "info")
            renderModalChecklist()
            if updateModalControlsLayout then updateModalControlsLayout() end
            if updateAttackControlsLayout then pcall(updateAttackControlsLayout) end
        end)
        wpBtns[wMode] = wb
    end

    -- Section 4: KUOTA PENYERANGAN & TOMBOL LOOP TERPADU
    local secQuota = Instance.new("Frame", contentScroll)
    secQuota.Size = UDim2.new(1, 0, 0, 68); secQuota.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", secQuota).CornerRadius = UDim.new(0, 6)

    -- Row Quota Misil
    local mQuotaRow = Instance.new("Frame", secQuota)
    mQuotaRow.Size = UDim2.new(1, -12, 0, 22); mQuotaRow.Position = UDim2.new(0, 6, 0, 6); mQuotaRow.BackgroundTransparency = 1
    local mql = Instance.new("UIListLayout", mQuotaRow); mql.FillDirection = Enum.FillDirection.Horizontal; mql.Padding = UDim.new(0, 4)

    local mqTitle = Instance.new("TextLabel", mQuotaRow)
    mqTitle.Size = UDim2.new(0, 75, 1, 0); mqTitle.BackgroundTransparency = 1
    mqTitle.Text = "🚀 Salvo/Launch:"; mqTitle.Font = Enum.Font.GothamBold; mqTitle.TextColor3 = Color3.fromRGB(0, 220, 255); mqTitle.TextSize = 9; mqTitle.TextXAlignment = Enum.TextXAlignment.Left

    local modalVolleyBtns = {}
    for _, vSize in ipairs({ 1, 5, 10, "MIX" }) do
        local vb = Instance.new("TextButton", mQuotaRow)
        vb.Size = (vSize == "MIX") and UDim2.new(0, 32, 1, 0) or UDim2.new(0, 26, 1, 0)
        local isCur = (vSize == "MIX" and State.ManualLaunchVolley == 999) or (State.ManualLaunchVolley == vSize)
        vb.BackgroundColor3 = isCur and Color3.fromRGB(0, 160, 220) or Color3.fromRGB(30, 38, 55)
        vb.Text = (type(vSize) == "number") and ("X" .. vSize) or tostring(vSize)
        vb.Font = Enum.Font.GothamBold; vb.TextColor3 = Color3.fromRGB(255, 255, 255); vb.TextSize = 8
        Instance.new("UICorner", vb).CornerRadius = UDim.new(0, 4)
        vb.MouseButton1Click:Connect(function()
            if vSize == 10 and not State.UnlockX10 then
                showToast("X10 Terkunci", "Nyalakan Unlock X10 di tab Attack utama!", "warn")
                return
            end
            State.ManualLaunchVolley = (vSize == "MIX") and 999 or vSize
            for k, b in pairs(modalVolleyBtns) do
                local cur = (k == "MIX" and State.ManualLaunchVolley == 999) or (State.ManualLaunchVolley == k)
                b.BackgroundColor3 = cur and Color3.fromRGB(0, 160, 220) or Color3.fromRGB(30, 38, 55)
            end
        end)
        modalVolleyBtns[vSize] = vb
    end

    local mqCustomLbl = Instance.new("TextLabel", mQuotaRow)
    mqCustomLbl.Size = UDim2.new(0, 45, 1, 0); mqCustomLbl.BackgroundTransparency = 1
    mqCustomLbl.Text = "Max:"; mqCustomLbl.Font = Enum.Font.GothamBold; mqCustomLbl.TextColor3 = Color3.fromRGB(200, 220, 240); mqCustomLbl.TextSize = 8; mqCustomLbl.TextXAlignment = Enum.TextXAlignment.Right

    local mqCustomBox = Instance.new("TextBox", mQuotaRow)
    mqCustomBox.Size = UDim2.new(0, 44, 1, 0); mqCustomBox.BackgroundColor3 = Color3.fromRGB(28, 38, 58)
    mqCustomBox.Text = (State.CustomMissileQuota and State.CustomMissileQuota > 0) and tostring(State.CustomMissileQuota) or ""
    mqCustomBox.PlaceholderText = "Auto"; mqCustomBox.Font = Enum.Font.GothamBold; mqCustomBox.TextColor3 = Color3.fromRGB(255, 255, 255); mqCustomBox.TextSize = 9
    Instance.new("UICorner", mqCustomBox).CornerRadius = UDim.new(0, 4)
    mqCustomBox:GetPropertyChangedSignal("Text"):Connect(function()
        local clean = mqCustomBox.Text:gsub("%D+", "")
        if clean ~= mqCustomBox.Text then mqCustomBox.Text = clean end
    end)
    mqCustomBox.FocusLost:Connect(function()
        local val = tonumber(mqCustomBox.Text) or 0
        State.CustomMissileQuota = val
        if val > 0 then
            showToast("Kuota Misil", "Total kuota misil dibatasi ke " .. val, "info")
        end
    end)

    local mClusterBtn = Instance.new("TextButton", mQuotaRow)
    mClusterBtn.Size = UDim2.new(0, 68, 1, 0)
    mClusterBtn.BackgroundColor3 = State.ClusteredLaunchEnabled and Color3.fromRGB(0, 160, 130) or Color3.fromRGB(65, 45, 55)
    mClusterBtn.Text = State.ClusteredLaunchEnabled and "🎯 Dekat: ON" or "🎯 Dekat: OFF"
    mClusterBtn.Font = Enum.Font.GothamBold; mClusterBtn.TextColor3 = Color3.fromRGB(255, 255, 255); mClusterBtn.TextSize = 8
    Instance.new("UICorner", mClusterBtn).CornerRadius = UDim.new(0, 4)
    State.UI.ModalClusterBtn = mClusterBtn

    mClusterBtn.MouseButton1Click:Connect(function()
        State.ClusteredLaunchEnabled = not State.ClusteredLaunchEnabled
        local isEnabled = (State.ClusteredLaunchEnabled == true)
        mClusterBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 160, 130) or Color3.fromRGB(65, 45, 55)
        mClusterBtn.Text = isEnabled and "🎯 Dekat: ON" or "🎯 Dekat: OFF"
        if clusterToggleBtn then
            clusterToggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 160, 130) or Color3.fromRGB(65, 45, 55)
            clusterToggleBtn.Text = isEnabled and "🎯 Dekat: ON" or "🎯 Dekat: OFF"
        end
        if State.ClusteredLaunchEnabled then
            showToast("Sortir Posisi Aktif", "Misil yang berdekatan diluncurkan terlebih dahulu!", "success")
        else
            showToast("Sortir Posisi OFF", "Peluncuran kembali menggunakan urutan bawaan", "info")
        end
    end)

    -- Row Quota Warship
    local wQuotaRow = Instance.new("Frame", secQuota)
    wQuotaRow.Size = UDim2.new(1, -12, 0, 22); wQuotaRow.Position = UDim2.new(0, 6, 0, 36); wQuotaRow.BackgroundTransparency = 1
    local wql = Instance.new("UIListLayout", wQuotaRow); wql.FillDirection = Enum.FillDirection.Horizontal; wql.Padding = UDim.new(0, 4)

    local wqTitle = Instance.new("TextLabel", wQuotaRow)
    wqTitle.Size = UDim2.new(0, 75, 1, 0); wqTitle.BackgroundTransparency = 1
    wqTitle.Text = "🚢 Jml Kapal:"; wqTitle.Font = Enum.Font.GothamBold; wqTitle.TextColor3 = Color3.fromRGB(0, 220, 255); wqTitle.TextSize = 9; wqTitle.TextXAlignment = Enum.TextXAlignment.Left

    local wqMinusBtn = Instance.new("TextButton", wQuotaRow)
    wqMinusBtn.Size = UDim2.new(0, 24, 1, 0); wqMinusBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65)
    wqMinusBtn.Text = "-"; wqMinusBtn.Font = Enum.Font.GothamBold; wqMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255); wqMinusBtn.TextSize = 10
    Instance.new("UICorner", wqMinusBtn).CornerRadius = UDim.new(0, 4)

    local wqBox = Instance.new("TextBox", wQuotaRow)
    wqBox.Size = UDim2.new(0, 40, 1, 0); wqBox.BackgroundColor3 = Color3.fromRGB(28, 38, 58)
    wqBox.Text = tostring(State.WarshipVolley or 1); wqBox.Font = Enum.Font.GothamBold; wqBox.TextColor3 = Color3.fromRGB(0, 220, 255); wqBox.TextSize = 10
    Instance.new("UICorner", wqBox).CornerRadius = UDim.new(0, 4)

    local wqPlusBtn = Instance.new("TextButton", wQuotaRow)
    wqPlusBtn.Size = UDim2.new(0, 20, 1, 0); wqPlusBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 65)
    wqPlusBtn.Text = "+"; wqPlusBtn.Font = Enum.Font.GothamBold; wqPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255); wqPlusBtn.TextSize = 10
    Instance.new("UICorner", wqPlusBtn).CornerRadius = UDim.new(0, 4)

    local function applyModalWs(val)
        val = math.max(1, tonumber(val) or 1)
        State.WarshipVolley = val
        wqBox.Text = tostring(val)
        if wsBox and wsBox.Parent then wsBox.Text = tostring(val) end
    end

    -- Shortcut Tombol Kuantiti Warship di Attack Mode HUD (1, 6, 12, 18)
    local presetWsModal = { 1, 6, 12, 18 }
    for _, pVal in ipairs(presetWsModal) do
        local pBtn = Instance.new("TextButton", wQuotaRow)
        pBtn.Size = UDim2.new(0, 22, 1, 0); pBtn.BackgroundColor3 = Color3.fromRGB(32, 44, 68)
        pBtn.Text = tostring(pVal); pBtn.Font = Enum.Font.GothamBold; pBtn.TextColor3 = Color3.fromRGB(0, 220, 255); pBtn.TextSize = 8.5
        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
        local pStroke = Instance.new("UIStroke", pBtn); pStroke.Color = Color3.fromRGB(50, 75, 115); pStroke.Thickness = 1
        pBtn.MouseButton1Click:Connect(function()
            applyModalWs(pVal)
            showToast("Kuantiti Warship", string.format("Set armada: %d kapal", pVal), "info")
        end)
    end

    local wqMaxBtn = Instance.new("TextButton", wQuotaRow)
    wqMaxBtn.Size = UDim2.new(0, 48, 1, 0); wqMaxBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    wqMaxBtn.Text = "MAX SIAP"; wqMaxBtn.Font = Enum.Font.GothamBold; wqMaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255); wqMaxBtn.TextSize = 7.5
    Instance.new("UICorner", wqMaxBtn).CornerRadius = UDim.new(0, 4)
    wqMinusBtn.MouseButton1Click:Connect(function() applyModalWs((State.WarshipVolley or 1) - 1) end)
    wqPlusBtn.MouseButton1Click:Connect(function() applyModalWs((State.WarshipVolley or 1) + 1) end)
    wqMaxBtn.MouseButton1Click:Connect(function()
        local myShips = getMyPlacedWarships()
        local readyCount = 0
        for _, s in ipairs(myShips) do if s.IsReady then readyCount = readyCount + 1 end end
        local total = (readyCount > 0) and readyCount or math.max(1, #myShips)
        applyModalWs(total)
        showToast("Warship Ready MAX", string.format("Set ke %d kapal siap tempur", total), "info")
    end)
    wqBox:GetPropertyChangedSignal("Text"):Connect(function()
        local clean = wqBox.Text:gsub("%D+", "")
        if clean ~= wqBox.Text then wqBox.Text = clean end
    end)
    wqBox.FocusLost:Connect(function()
        local val = tonumber(wqBox.Text) or 1
        applyModalWs(val)
    end)

    -- Section 5: EKSEKUSI PENYERANGAN LENGKAP & TOMBOL LOOP SINKRON
    local secAction = Instance.new("Frame", contentScroll)
    secAction.Size = UDim2.new(1, 0, 0, 210); secAction.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    Instance.new("UICorner", secAction).CornerRadius = UDim.new(0, 6)

    local saActHeader = Instance.new("Frame", secAction)
    saActHeader.Size = UDim2.new(1, 0, 0, 64); saActHeader.BackgroundTransparency = 1

    local saActTitle = Instance.new("TextLabel", saActHeader)
    saActTitle.Size = UDim2.new(1, -95, 0, 18); saActTitle.Position = UDim2.new(0, 6, 0, 2); saActTitle.BackgroundTransparency = 1
    saActTitle.Text = "🚀 EKSEKUSI PENYERANGAN:"; saActTitle.Font = Enum.Font.GothamBold; saActTitle.TextColor3 = Color3.fromRGB(0, 220, 255); saActTitle.TextSize = 9; saActTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Tombol Loop Serangan di Modal (Sinkron dengan Loop di GUI Utama)
    local modalLoopBtn = Instance.new("TextButton", saActHeader)
    modalLoopBtn.Size = UDim2.new(0, 85, 0, 18); modalLoopBtn.Position = UDim2.new(1, -90, 0, 2)
    modalLoopBtn.BackgroundColor3 = State.LoopAttackEnabled and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(50, 60, 75)
    modalLoopBtn.Text = State.LoopAttackEnabled and "🔁 Loop: ON" or "🔁 Loop: OFF"
    modalLoopBtn.Font = Enum.Font.GothamBold; modalLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255); modalLoopBtn.TextSize = 8
    Instance.new("UICorner", modalLoopBtn).CornerRadius = UDim.new(0, 4)
    State.UI.ModalLoopAttackBtn = modalLoopBtn

    -- Baris Slider Pengatur Kecepatan Loop (1x - 10x) di Attack Mode HUD
    local mSpdRow = Instance.new("Frame", saActHeader)
    mSpdRow.Size = UDim2.new(1, -12, 0, 18); mSpdRow.Position = UDim2.new(0, 6, 0, 22); mSpdRow.BackgroundTransparency = 1

    local mSpdTitle = Instance.new("TextLabel", mSpdRow)
    mSpdTitle.Size = UDim2.new(0, 110, 1, 0); mSpdTitle.BackgroundTransparency = 1
    mSpdTitle.Text = "⚡ Kecepatan Loop:"; mSpdTitle.Font = Enum.Font.GothamBold
    mSpdTitle.TextColor3 = Color3.fromRGB(0, 220, 255); mSpdTitle.TextSize = 8.5; mSpdTitle.TextXAlignment = Enum.TextXAlignment.Left

    local mTrack = Instance.new("TextButton", mSpdRow)
    mTrack.Size = UDim2.new(1, -165, 0, 8); mTrack.Position = UDim2.new(0, 115, 0.5, -4)
    mTrack.BackgroundColor3 = Color3.fromRGB(30, 40, 60); mTrack.Text = ""; mTrack.AutoButtonColor = false
    Instance.new("UICorner", mTrack).CornerRadius = UDim.new(0, 4)

    local mFill = Instance.new("Frame", mTrack)
    local curModalPct = math.clamp(((State.LoopSpeedMultiplier or 1) - 1) / 9, 0, 1)
    mFill.Size = UDim2.new(curModalPct, 0, 1, 0); mFill.BackgroundColor3 = Color3.fromRGB(0, 210, 255); mFill.BorderSizePixel = 0
    Instance.new("UICorner", mFill).CornerRadius = UDim.new(0, 4)
    State.UI.ModalLoopFill = mFill

    local mKnob = Instance.new("Frame", mTrack)
    mKnob.Size = UDim2.new(0, 12, 0, 12); mKnob.Position = UDim2.new(curModalPct, -6, 0.5, -6)
    mKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); mKnob.BorderSizePixel = 0
    Instance.new("UICorner", mKnob).CornerRadius = UDim.new(1, 0)
    State.UI.ModalLoopKnob = mKnob

    local mSpdLbl = Instance.new("TextLabel", mSpdRow)
    mSpdLbl.Size = UDim2.new(0, 45, 1, 0); mSpdLbl.Position = UDim2.new(1, -45, 0, 0); mSpdLbl.BackgroundTransparency = 1
    mSpdLbl.Text = string.format("⚡ %dx", State.LoopSpeedMultiplier or 1)
    mSpdLbl.Font = Enum.Font.GothamBold; mSpdLbl.TextColor3 = Color3.fromRGB(255, 215, 0); mSpdLbl.TextSize = 8.5
    mSpdLbl.TextXAlignment = Enum.TextXAlignment.Right
    State.UI.ModalLoopSpeedLbl = mSpdLbl

    local function setModalLoopSpeed(spd, fromUser)
        spd = math.clamp(math.floor(spd + 0.5), 1, 10)
        State.LoopSpeedMultiplier = spd
        local pct = (spd - 1) / 9
        if State.UI.MainLoopSpeedLbl then State.UI.MainLoopSpeedLbl.Text = string.format("⚡ Spd: %dx", spd) end
        if State.UI.MainLoopFill then State.UI.MainLoopFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.MainLoopKnob then State.UI.MainLoopKnob.Position = UDim2.new(pct, -7, 0.5, -7) end

        if State.UI.ModalLoopSpeedLbl then State.UI.ModalLoopSpeedLbl.Text = string.format("⚡ %dx", spd) end
        if State.UI.ModalLoopFill then State.UI.ModalLoopFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.ModalLoopKnob then State.UI.ModalLoopKnob.Position = UDim2.new(pct, -6, 0.5, -6) end
        if fromUser then
            showToast("Kecepatan Loop", string.format("Kecepatan serangan loop diatur ke %dx", spd), "info")
        end
    end

    local isDraggingModal = false
    local function updateModalFromInput(input)
        local relX = math.clamp(input.Position.X - mTrack.AbsolutePosition.X, 0, mTrack.AbsoluteSize.X)
        local pct = (mTrack.AbsoluteSize.X > 0) and (relX / mTrack.AbsoluteSize.X) or 0
        local spd = 1 + pct * 9
        setModalLoopSpeed(spd, false)
    end
    mTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingModal = true
            updateModalFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingModal and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateModalFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingModal then
                isDraggingModal = false
                showToast("Kecepatan Loop", string.format("Kecepatan loop diatur ke %dx", State.LoopSpeedMultiplier or 1), "info")
            end
        end
    end)

    -- Baris Slider Harass Karakter Lawan (0-60 detik) di Attack Mode HUD
    local mHarassRow = Instance.new("Frame", saActHeader)
    mHarassRow.Size = UDim2.new(1, -12, 0, 18); mHarassRow.Position = UDim2.new(0, 6, 0, 42); mHarassRow.BackgroundTransparency = 1

    local mHarassTitle = Instance.new("TextLabel", mHarassRow)
    mHarassTitle.Size = UDim2.new(0, 110, 1, 0); mHarassTitle.BackgroundTransparency = 1
    local curMHSec = State.AutoHarassInterval or 0
    mHarassTitle.Text = (curMHSec > 0) and string.format("👤 Harass: %ds", curMHSec) or "👤 Harass: OFF"
    mHarassTitle.Font = Enum.Font.GothamBold; mHarassTitle.TextColor3 = (curMHSec > 0) and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(180, 190, 205)
    mHarassTitle.TextSize = 8.5; mHarassTitle.TextXAlignment = Enum.TextXAlignment.Left
    State.UI.ModalHarassLbl = mHarassTitle

    local mhTrack = Instance.new("TextButton", mHarassRow)
    mhTrack.Size = UDim2.new(1, -165, 0, 8); mhTrack.Position = UDim2.new(0, 115, 0.5, -4)
    mhTrack.BackgroundColor3 = Color3.fromRGB(30, 40, 60); mhTrack.Text = ""; mhTrack.AutoButtonColor = false
    Instance.new("UICorner", mhTrack).CornerRadius = UDim.new(0, 4)

    local curMHPct = math.clamp(curMHSec / 60, 0, 1)
    local mhFill = Instance.new("Frame", mhTrack)
    mhFill.Size = UDim2.new(curMHPct, 0, 1, 0); mhFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80); mhFill.BorderSizePixel = 0
    Instance.new("UICorner", mhFill).CornerRadius = UDim.new(0, 4)
    State.UI.ModalHarassFill = mhFill

    local mhKnob = Instance.new("Frame", mhTrack)
    mhKnob.Size = UDim2.new(0, 12, 0, 12); mhKnob.Position = UDim2.new(curMHPct, -6, 0.5, -6)
    mhKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); mhKnob.BorderSizePixel = 0
    Instance.new("UICorner", mhKnob).CornerRadius = UDim.new(1, 0)
    State.UI.ModalHarassKnob = mhKnob

    local mhValLbl = Instance.new("TextLabel", mHarassRow)
    mhValLbl.Size = UDim2.new(0, 45, 1, 0); mhValLbl.Position = UDim2.new(1, -45, 0, 0); mhValLbl.BackgroundTransparency = 1
    mhValLbl.Text = (curMHSec > 0) and (curMHSec .. "s") or "OFF"
    mhValLbl.Font = Enum.Font.GothamBold; mhValLbl.TextColor3 = (curMHSec > 0) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 160, 175)
    mhValLbl.TextSize = 8.5; mhValLbl.TextXAlignment = Enum.TextXAlignment.Right
    State.UI.ModalHarassValLbl = mhValLbl

    local function setModalHarassInterval(sec, fromUser)
        sec = math.clamp(math.floor(sec + 0.5), 0, 60)
        State.AutoHarassInterval = sec
        local pct = sec / 60
        local txt = (sec > 0) and string.format("👤 Harass Karakter: %ds (1 misil)", sec) or "👤 Harass Karakter: OFF"
        local modalTxt = (sec > 0) and string.format("👤 Harass: %ds", sec) or "👤 Harass: OFF"
        local valTxt = (sec > 0) and (sec .. "s") or "OFF"
        local col = (sec > 0) and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(180, 190, 205)
        local valCol = (sec > 0) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 160, 175)

        if State.UI.MainHarassLbl then State.UI.MainHarassLbl.Text = txt; State.UI.MainHarassLbl.TextColor3 = col end
        if State.UI.MainHarassValLbl then State.UI.MainHarassValLbl.Text = valTxt; State.UI.MainHarassValLbl.TextColor3 = valCol end
        if State.UI.MainHarassFill then State.UI.MainHarassFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.MainHarassKnob then State.UI.MainHarassKnob.Position = UDim2.new(pct, -7, 0.5, -7) end

        if State.UI.ModalHarassLbl then State.UI.ModalHarassLbl.Text = modalTxt; State.UI.ModalHarassLbl.TextColor3 = col end
        if State.UI.ModalHarassValLbl then State.UI.ModalHarassValLbl.Text = valTxt; State.UI.ModalHarassValLbl.TextColor3 = valCol end
        if State.UI.ModalHarassFill then State.UI.ModalHarassFill.Size = UDim2.new(pct, 0, 1, 0) end
        if State.UI.ModalHarassKnob then State.UI.ModalHarassKnob.Position = UDim2.new(pct, -6, 0.5, -6) end

        if fromUser then
            if sec > 0 then
                showToast("Harass Karakter", string.format("Serangan otomatis akan meluncurkan 1 misil ke target setiap %d detik!", sec), "info")
            else
                showToast("Harass Karakter", "Fitur serang karakter berkala dinonaktifkan (OFF)", "info")
            end
        end
    end

    local isDraggingHarassModal = false
    local function updateHarassModalFromInput(input)
        local relX = math.clamp(input.Position.X - mhTrack.AbsolutePosition.X, 0, mhTrack.AbsoluteSize.X)
        local pct = (mhTrack.AbsoluteSize.X > 0) and (relX / mhTrack.AbsoluteSize.X) or 0
        setModalHarassInterval(pct * 60, false)
    end
    mhTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingHarassModal = true
            updateHarassModalFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingHarassModal and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateHarassModalFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingHarassModal then
                isDraggingHarassModal = false
                setModalHarassInterval(State.AutoHarassInterval or 0, true)
            end
        end
    end)

    local modalActionButtons = {}

    local function syncLoopAttackState(newState)
        State.LoopAttackEnabled = newState
        modalLoopBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(50, 60, 75)
        modalLoopBtn.Text = newState and "🔁 Loop: ON" or "🔁 Loop: OFF"
        if State.UI.MainLoopAttackBtn then
            State.UI.MainLoopAttackBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(50, 60, 75)
            State.UI.MainLoopAttackBtn.Text = newState and "🔁 Loop: ON" or "🔁 Loop: OFF"
        end
        if not newState then
            if State.TargetLoopActive then
                State.TargetLoopActive = false
                State.ActiveLoopCategory = nil
                if modalActionButtons["Building"] then modalActionButtons["Building"].Text = "🏢 Serang Bangunan"; modalActionButtons["Building"].BackgroundColor3 = Color3.fromRGB(40, 120, 200) end
                if modalActionButtons["AntiAir"] then modalActionButtons["AntiAir"].Text = "🛡️ Serang Anti-Air"; modalActionButtons["AntiAir"].BackgroundColor3 = Color3.fromRGB(180, 50, 80) end
                if modalActionButtons["AntiSea"] then modalActionButtons["AntiSea"].Text = "⚓ Serang Anti-Sea"; modalActionButtons["AntiSea"].BackgroundColor3 = Color3.fromRGB(200, 120, 20) end
                if modalActionButtons["Char"] then modalActionButtons["Char"].Text = "👤 Serang Karakter"; modalActionButtons["Char"].BackgroundColor3 = Color3.fromRGB(220, 60, 80) end
            end
            if State.AutoComboLoopActive then
                State.AutoComboLoopActive = false
                if modalActionButtons["Combo"] then modalActionButtons["Combo"].Text = "⚡ SERANGAN OTOMATIS"; modalActionButtons["Combo"].BackgroundColor3 = Color3.fromRGB(220, 65, 30) end
            end
        end
        showToast("Loop Attack", "Mode Loop Attack: " .. (newState and "ON (Klik tombol serangan untuk loop)" or "OFF (Serangan biasa)"), "info")
    end

    modalLoopBtn.MouseButton1Click:Connect(function()
        syncLoopAttackState(not State.LoopAttackEnabled)
    end)

    local actGrid = Instance.new("Frame", secAction)
    actGrid.Size = UDim2.new(1, -12, 0, 192); actGrid.Position = UDim2.new(0, 6, 0, 66); actGrid.BackgroundTransparency = 1
    local agl = Instance.new("UIGridLayout", actGrid); agl.CellSize = UDim2.new(0.485, -2, 0, 27); agl.CellPadding = UDim2.new(0.02, 0, 0, 4)

    local function createModalActBtn(key, text, color, onClick)
        local btn = Instance.new("TextButton", actGrid)
        btn.BackgroundColor3 = color; btn.Text = text; btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextSize = 9
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        btn.MouseButton1Click:Connect(onClick)
        modalActionButtons[key] = btn
        return btn
    end

    createModalActBtn("Combo", "⚡ SERANGAN OTOMATIS", Color3.fromRGB(220, 65, 30), function()
        toggleAutoComboAttackLoop()
    end)

    createModalActBtn("Building", "🏢 Serang Bangunan", Color3.fromRGB(40, 120, 200), function()
        -- Aturan: Jika senjata Warship dipilih, mode loop diabaikan (hanya launch armada 1x sesuai kuantiti)
        if State.WeaponType ~= "Warship" and State.LoopAttackEnabled then
            toggleGenericTargetLoopAttack("Buildings", "Building", "🏢 Serang Bangunan", Color3.fromRGB(40, 120, 200), modalActionButtons["Building"])
            return
        end

        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then
            showToast("Target Invalid", "Pilih base lawan yang valid terlebih dahulu!", "warn")
            return
        end
        local chosenTarget = findClusteredTarget(tgt, "Buildings")
        if State.WeaponType == "Missile" or State.WeaponType == "Kombinasi" then
            local r = getChosenRockets and getChosenRockets() or {}
            if #r > 0 and chosenTarget then
                if executeMissileBatches then executeMissileBatches(chosenTarget, r) else launchMissileVolley(chosenTarget, r, State.AutoBreakShield) end
            end
        end
        if State.WeaponType == "Warship" or State.WeaponType == "Kombinasi" then
            local ws = getChosenWarships and getChosenWarships() or {}
            if #ws > 0 then
                local quota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                local sendWs = {}
                for i = 1, quota do table.insert(sendWs, ws[i]) end
                launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
            end
        end
    end)

    createModalActBtn("AntiAir", "🛡️ Serang Anti-Air", Color3.fromRGB(180, 50, 80), function()
        if State.LoopAttackEnabled then
            toggleGenericTargetLoopAttack("AntiAir", "Anti-Air", "🛡️ Serang Anti-Air", Color3.fromRGB(180, 50, 80), modalActionButtons["AntiAir"])
            return
        end

        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end
        local chosenTarget = findClusteredTarget(tgt, "AntiAir")
        if chosenTarget then
            if State.WeaponType == "Warship" then
                local ws = getChosenWarships and getChosenWarships() or {}
                if #ws > 0 then
                    local quota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                    local sendWs = {}
                    for i = 1, quota do table.insert(sendWs, ws[i]) end
                    launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
                end
            else
                local r = getChosenRockets and getChosenRockets() or {}
                if #r > 0 then
                    if executeMissileBatches then executeMissileBatches(chosenTarget, r) else launchMissileVolley(chosenTarget, r, State.AutoBreakShield) end
                end
                if State.WeaponType == "Kombinasi" then
                    local ws = getChosenWarships and getChosenWarships() or {}
                    if #ws > 0 then
                        local quota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                        local sendWs = {}
                        for i = 1, quota do table.insert(sendWs, ws[i]) end
                        launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
                    end
                end
            end
        else
            showToast("Target Kosong", "Tidak ada Anti-Air di base lawan", "warn")
        end
    end)

    createModalActBtn("AntiSea", "⚓ Serang Anti-Sea", Color3.fromRGB(200, 120, 20), function()
        if State.LoopAttackEnabled then
            toggleGenericTargetLoopAttack("AntiShip", "Anti-Sea", "⚓ Serang Anti-Sea", Color3.fromRGB(200, 120, 20), modalActionButtons["AntiSea"])
            return
        end

        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end
        local chosenTarget = findClusteredTarget(tgt, "AntiShip")
        if chosenTarget then
            if State.WeaponType == "Warship" then
                local ws = getChosenWarships and getChosenWarships() or {}
                if #ws > 0 then
                    local quota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                    local sendWs = {}
                    for i = 1, quota do table.insert(sendWs, ws[i]) end
                    launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
                end
            else
                local r = getChosenRockets and getChosenRockets() or {}
                if #r > 0 then
                    if executeMissileBatches then executeMissileBatches(chosenTarget, r) else launchMissileVolley(chosenTarget, r, State.AutoBreakShield) end
                end
                if State.WeaponType == "Kombinasi" then
                    local ws = getChosenWarships and getChosenWarships() or {}
                    if #ws > 0 then
                        local quota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
                        local sendWs = {}
                        for i = 1, quota do table.insert(sendWs, ws[i]) end
                        launchWarshipArmada(tgt, sendWs, State.AutoBreakShield)
                    end
                end
            end
        else
            showToast("Target Kosong", "Tidak ada Anti-Sea di base lawan", "warn")
        end
    end)

    -- Tombol Serang Karakter Lawan di Attack Mode HUD
    createModalActBtn("Char", "👤 Serang Karakter", Color3.fromRGB(220, 60, 80), function()
        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then
            showToast("Target Invalid", "Pilih base lawan yang valid terlebih dahulu!", "warn")
            return
        end

        local targetPlayer = nil
        if tgt.OwnerUserId then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.UserId == tgt.OwnerUserId then
                    targetPlayer = p
                    break
                end
            end
        end

        if not targetPlayer and tgt.Owner and tgt.Owner ~= "Kosong" then
            local cleanOwner = tgt.Owner:lower():gsub("^team%-[^%s]+%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer then
                    local pName = p.Name:lower()
                    local pDisp = p.DisplayName:lower()
                    if pName == cleanOwner or pDisp == cleanOwner or pName:find(cleanOwner, 1, true) or pDisp:find(cleanOwner, 1, true) or cleanOwner:find(pName, 1, true) or cleanOwner:find(pDisp, 1, true) then
                        targetPlayer = p
                        break
                    end
                end
            end
        end

        local fallbackPos = tgt.Position or BASE_COORDINATES[State.SelectedBaseIndex]
        local char = targetPlayer and targetPlayer.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
        local aimPos = (root and root.Position) or fallbackPos

        if not aimPos then
            showToast("Target Invalid", "Koordinat base atau karakter lawan tidak ditemukan!", "warn")
            return
        end

        local r = getChosenRockets and getChosenRockets() or {}
        if #r == 0 then return end

        -- Mengambil tepat 1 misil saja (1x launch = 1 missile)
        local sendGroup = { r[1] }

        local targetLabel = targetPlayer and targetPlayer.DisplayName or tgt.Owner
        showToast("Serang Karakter", string.format("Meluncurkan 1 misil ke posisi %s (Base %d)!", targetLabel, State.SelectedBaseIndex), "danger")
        logMessage(string.format("👤 Meluncurkan 1 misil langsung ke target %s (Base %d, Pos: %.0f, %.0f, %.0f)", targetLabel, State.SelectedBaseIndex, aimPos.X, aimPos.Y, aimPos.Z))
        launchPlayerCharacterAttack(targetPlayer, sendGroup, State.AutoBreakShield, aimPos, tgt.OwnerUserId)
    end)

    createModalActBtn("Pve", "🏝️ Serang PVE Island", Color3.fromRGB(0, 160, 140), function()
        local chosenR = (State.WeaponType == "Missile" or State.WeaponType == "Kombinasi") and (getChosenRockets and getChosenRockets() or nil) or nil
        local chosenW = (State.WeaponType == "Warship" or State.WeaponType == "Kombinasi") and (getChosenWarships and getChosenWarships() or nil) or nil
        launchPveAttack(State.WeaponType, State.AutoBreakShield, chosenR, chosenW)
    end)

    createModalActBtn("Armada", "🚢 Serang Armada Kapal", Color3.fromRGB(0, 140, 210), function()
        local tgt = scanTargetBaseOnly(State.SelectedBaseIndex)
        if not tgt or tgt.IsLocal then return end
        local ws = getChosenWarships and getChosenWarships() or {}
        if #ws > 0 then
            local sendQuota = math.min(#ws, math.max(1, State.WarshipVolley or 1))
            local sendGroup = {}
            for i = 1, sendQuota do table.insert(sendGroup, ws[i]) end
            launchWarshipArmada(tgt, sendGroup, State.AutoBreakShield)
        end
    end)

    createModalActBtn("Otonomus", "🤖 Serang Otonomus", Color3.fromRGB(120, 50, 180), runAutonomousAttack)
    createModalActBtn("Stop", "🛑 STOP ATTACK", Color3.fromRGB(215, 45, 60), function()
        stopAllAutomation()
        showToast("Stop Attack", "Seluruh serangan otomatis berhasil dihentikan", "warn")
    end)

    -- Dynamic Layout switcher untuk Mode Attack HUD
    updateModalControlsLayout = function()
        local mode = State.WeaponType or "Missile"
        if mode == "Warship" then
            mQuotaRow.Visible = false
            wQuotaRow.Visible = true
            wQuotaRow.Position = UDim2.new(0, 6, 0, 8)
            secQuota.Size = UDim2.new(1, 0, 0, 38)

            -- Aturan Warship: Loop diabaikan, sembunyikan kontrol loop
            if saActHeader then saActHeader.Visible = false end
            for k, btn in pairs(modalActionButtons) do
                if k == "Building" or k == "Pve" or k == "Stop" then
                    btn.Visible = true
                else
                    btn.Visible = false
                end
            end
            if modalActionButtons["Building"] then
                modalActionButtons["Building"].Text = "🚢 Serang Base (Armada)"
            end
            actGrid.Position = UDim2.new(0, 6, 0, 6)
            agl.CellSize = UDim2.new(0.485, -2, 0, 30)
            secAction.Size = UDim2.new(1, 0, 0, 76)
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, 440)
        else
            if saActHeader then saActHeader.Visible = true end
            actGrid.Position = UDim2.new(0, 6, 0, 66)
            mQuotaRow.Visible = (mode == "Missile" or mode == "Kombinasi")
            wQuotaRow.Visible = (mode == "Warship" or mode == "Kombinasi")
            if mode == "Kombinasi" then
                mQuotaRow.Position = UDim2.new(0, 6, 0, 6)
                wQuotaRow.Position = UDim2.new(0, 6, 0, 36)
                secQuota.Size = UDim2.new(1, 0, 0, 68)
            else
                mQuotaRow.Position = UDim2.new(0, 6, 0, 8)
                secQuota.Size = UDim2.new(1, 0, 0, 38)
            end

            for k, btn in pairs(modalActionButtons) do
                btn.Visible = true
            end
            if modalActionButtons["Building"] then
                modalActionButtons["Building"].Text = "🏢 Serang Bangunan"
            end
            agl.CellSize = UDim2.new(0.485, -2, 0, 27)
            secAction.Size = UDim2.new(1, 0, 0, 246)
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, 650)
        end
    end

    task.spawn(function()
        renderModalBases()
        updateModalAnalyzeUI()
        renderModalChecklist()
        updateModalControlsLayout()
    end)

    return atkModal
end

-- ====================================================================================================
-- HELPER GUI RANK: Pencarian pemilik base lawan terpilih & aksi serang 1 misil
-- ====================================================================================================
local function getPlayerForSelectedBase()
    local all = scanAllBases()
    local tgt = all[State.SelectedBaseIndex]
    if not tgt or tgt.IsLocal then return nil, tgt end

    local targetPlayer = nil
    if tgt.OwnerUserId then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId == tgt.OwnerUserId then targetPlayer = p; break end
        end
    end
    if not targetPlayer and tgt.Owner and tgt.Owner ~= "Kosong" then
        local cleanOwner = tgt.Owner:lower():gsub("^team%-[^%s]+%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer then
                local pName = p.Name:lower(); local pDisp = p.DisplayName:lower()
                if pName == cleanOwner or pDisp == cleanOwner or pName:find(cleanOwner, 1, true) or pDisp:find(cleanOwner, 1, true) or cleanOwner:find(pName, 1, true) or cleanOwner:find(pDisp, 1, true) then
                    targetPlayer = p; break
                end
            end
        end
    end
    return targetPlayer, tgt
end

-- Luncurkan 1 misil tepat ke tengah base lawan terpilih (tetap jalan walau lawan pakai shield)
local function attackSelectedBaseCenter()
    local _, tgt = getPlayerForSelectedBase()
    if not tgt or tgt.IsLocal then
        showToast("Target Invalid", "Pilih base lawan yang valid terlebih dahulu!", "warn")
        return false
    end

    local bIdx = (tgt and tgt.Index) or State.SelectedBaseIndex or 1
    -- Menggunakan koordinat presisi teleport base (BASE_COORDINATES) yang selalu tepat di tengah base
    local aimPos = BASE_COORDINATES[bIdx] or tgt.Position or (tgt.Instance and tgt.Instance:GetPivot().Position)
    if not aimPos then
        showToast("Target Invalid", "Koordinat tengah base lawan tidak ditemukan!", "warn")
        return false
    end

    local r = getChosenRockets and getChosenRockets() or {}
    if #r == 0 then return false end

    showToast("Serang Center Base", string.format("Meluncurkan 1 misil ke tengah Base %d (%s)!", bIdx, tgt.Owner or "?"), "danger")
    logMessage(string.format("💥 [RANK] 1 misil ke tengah Base %d (Pos: %.0f, %.0f, %.0f) - abaikan shield.", bIdx, aimPos.X, aimPos.Y, aimPos.Z))
    return launchPlayerCharacterAttack(nil, { r[1] }, true, aimPos, tgt.OwnerUserId)
end

-- Luncurkan 1 misil ke posisi karakter pemilik base lawan terpilih
local function attackSelectedBaseCharacter()
    local targetPlayer, tgt = getPlayerForSelectedBase()
    if not tgt or tgt.IsLocal then
        showToast("Target Invalid", "Pilih base lawan yang valid terlebih dahulu!", "warn")
        return false
    end

    local fallbackPos = tgt.Position or BASE_COORDINATES[State.SelectedBaseIndex]
    local char = targetPlayer and targetPlayer.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
    local aimPos = (root and root.Position) or fallbackPos
    if not aimPos then
        showToast("Target Invalid", "Koordinat base atau karakter lawan tidak ditemukan!", "warn")
        return false
    end

    local r = getChosenRockets and getChosenRockets() or {}
    if #r == 0 then return false end

    local targetLabel = targetPlayer and targetPlayer.DisplayName or tgt.Owner
    showToast("Serang Karakter", string.format("Meluncurkan 1 misil ke posisi %s (Base %d)!", targetLabel, State.SelectedBaseIndex), "danger")
    logMessage(string.format("👤 [RANK] 1 misil ke karakter %s (Base %d, Pos: %.0f, %.0f, %.0f)", targetLabel, State.SelectedBaseIndex, aimPos.X, aimPos.Y, aimPos.Z))
    return launchPlayerCharacterAttack(targetPlayer, { r[1] }, State.AutoBreakShield, aimPos, tgt.OwnerUserId)
end

-- ====================================================================================================
-- GUI RANK (Panel Kecil: Freeze, Auto TP Base, TP+Kick, Serang Base/Karakter)
-- ====================================================================================================
local function createRankGUI(parentGui)
    local rankFrame = Instance.new("Frame", parentGui)
    rankFrame.Name = "RankMode_GUI"
    rankFrame.Size = UDim2.new(0, 280, 0, 378)
    rankFrame.Position = UDim2.new(0.5, 420, 0.5, -189)
    rankFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    rankFrame.BorderSizePixel = 0
    rankFrame.Active = true
    rankFrame.Visible = false
    Instance.new("UICorner", rankFrame).CornerRadius = UDim.new(0, 10)
    local rStroke = Instance.new("UIStroke", rankFrame)
    rStroke.Color = Color3.fromRGB(255, 200, 60); rStroke.Thickness = 1.5; rStroke.Transparency = 0.25

    -- Header (judul + tombol follow + tombol freeze + tombol tutup, bisa digeser)
    local rHeader = Instance.new("Frame", rankFrame)
    rHeader.Size = UDim2.new(1, 0, 0, 30); rHeader.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    Instance.new("UICorner", rHeader).CornerRadius = UDim.new(0, 10)

    local rTitle = Instance.new("TextLabel", rHeader)
    rTitle.Size = UDim2.new(1, -225, 1, 0); rTitle.Position = UDim2.new(0, 8, 0, 0); rTitle.BackgroundTransparency = 1
    rTitle.Text = "🏆 RANK"; rTitle.Font = Enum.Font.GothamBold; rTitle.TextColor3 = Color3.fromRGB(255, 215, 90)
    rTitle.TextSize = 11; rTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Tombol Kabur (Shortcut ke Ghost Mode Y: -1999) di Header Rank GUI
    local rKaburBtn = Instance.new("TextButton", rHeader)
    rKaburBtn.Size = UDim2.new(0, 52, 0, 22); rKaburBtn.Position = UDim2.new(1, -214, 0, 4)
    rKaburBtn.Font = Enum.Font.GothamBold; rKaburBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rKaburBtn.TextSize = 8.5
    rKaburBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 70)
    rKaburBtn.Text = "💨 Kabur"
    Instance.new("UICorner", rKaburBtn).CornerRadius = UDim.new(0, 5)
    local rkStroke = Instance.new("UIStroke", rKaburBtn)
    rkStroke.Color = Color3.fromRGB(255, 100, 140); rkStroke.Thickness = 1

    rKaburBtn.MouseButton1Click:Connect(function()
        if State.GhostMode and (State.GhostHeight == -19999) then
            toggleGhostMode(false)
            showToast("Kabur OFF", "Kembali ke permukaan tanah.", "info")
        else
            toggleGhostMode(true, -19999)
            showToast("KABUR CEPAT (-19999)", "Tubuh asli diparkir di Y: -19999! Aman dari pantauan lawan.", "success")
        end
    end)

    -- Tombol Follow Player di Header Rank GUI
    local rFollowBtn = Instance.new("TextButton", rHeader)
    rFollowBtn.Size = UDim2.new(0, 62, 0, 22); rFollowBtn.Position = UDim2.new(1, -158, 0, 4)
    rFollowBtn.Font = Enum.Font.GothamBold; rFollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rFollowBtn.TextSize = 8.5
    Instance.new("UICorner", rFollowBtn).CornerRadius = UDim.new(0, 5)
    local rfolStroke = Instance.new("UIStroke", rFollowBtn)
    rfolStroke.Color = Color3.fromRGB(0, 220, 150); rfolStroke.Thickness = 1

    local function updateRankHeaderFollow()
        if rFollowBtn and rFollowBtn.Parent then
            local isFollowing = State.FollowTarget ~= nil
            rFollowBtn.BackgroundColor3 = isFollowing and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(38, 48, 70)
            rFollowBtn.Text = isFollowing and "👣 Fol: ON" or "👣 Follow"
            rfolStroke.Color = isFollowing and Color3.fromRGB(0, 240, 160) or Color3.fromRGB(60, 80, 110)
        end
    end
    updateRankHeaderFollow()
    State.UI.UpdateFollowButtonsList = State.UI.UpdateFollowButtonsList or {}
    table.insert(State.UI.UpdateFollowButtonsList, updateRankHeaderFollow)

    rFollowBtn.MouseButton1Click:Connect(function()
        if State.FollowTarget then
            toggleFollow(nil, false)
            showToast("Follow OFF", "Berhenti mengikuti target", "info")
        else
            local targetPlayer, tgt = getPlayerForSelectedBase()
            local targetToFollow = targetPlayer or State.FlingTarget
            if targetToFollow then
                toggleFollow(targetToFollow, true)
                showToast("Follow ON", "Mengikuti " .. targetToFollow.DisplayName, "success")
            else
                showToast("Follow Gagal", "Pilih base musuh atau target terlebih dahulu", "warn")
            end
        end
    end)

    -- Tombol Freeze di Header Rank Mode GUI
    local rFreezeBtn = Instance.new("TextButton", rHeader)
    rFreezeBtn.Size = UDim2.new(0, 62, 0, 22); rFreezeBtn.Position = UDim2.new(1, -92, 0, 4)
    rFreezeBtn.Font = Enum.Font.GothamBold; rFreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rFreezeBtn.TextSize = 8.5
    Instance.new("UICorner", rFreezeBtn).CornerRadius = UDim.new(0, 5)
    local rfbStroke = Instance.new("UIStroke", rFreezeBtn)
    rfbStroke.Color = Color3.fromRGB(0, 220, 255); rfbStroke.Thickness = 1

    local function updateRankHeaderFreezeAppearance()
        local mode = State.FreezeMode or "ON"
        if mode == "ON" then
            rFreezeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
            rFreezeBtn.Text = "❄️ Frz: ON"
        elseif mode == "OFF" then
            rFreezeBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
            rFreezeBtn.Text = "❄️ Frz: OFF"
        else
            rFreezeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
            rFreezeBtn.Text = "❄️ Frz: AUTO"
        end
    end
    updateRankHeaderFreezeAppearance()
    State.UI.UpdateRankHeaderFreeze = updateRankHeaderFreezeAppearance

    rFreezeBtn.MouseButton1Click:Connect(function()
        local cur = State.FreezeMode or "ON"
        local nextMode = "OFF"
        if cur == "ON" then
            nextMode = "OFF"
        elseif cur == "OFF" then
            nextMode = "Auto"
        else
            nextMode = "ON"
        end
        setFreezeMode(nextMode)
    end)

    local rClose = Instance.new("TextButton", rHeader)
    rClose.Size = UDim2.new(0, 22, 0, 22); rClose.Position = UDim2.new(1, -26, 0, 4); rClose.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    rClose.Text = "✕"; rClose.Font = Enum.Font.GothamBold; rClose.TextColor3 = Color3.fromRGB(255, 120, 120); rClose.TextSize = 11
    Instance.new("UICorner", rClose).CornerRadius = UDim.new(0, 5)
    rClose.MouseButton1Click:Connect(function()
        rankFrame.Visible = false
        if State.UI and State.UI.RankHeaderBtn then
            State.UI.RankHeaderBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
        end
    end)

    local rankDragging, rankDragStart, rankStartPos = false, nil, nil
    rHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            rankDragging = true; rankDragStart = input.Position; rankStartPos = rankFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then rankDragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if rankDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - rankDragStart
            rankFrame.Position = UDim2.new(rankStartPos.X.Scale, rankStartPos.X.Offset + delta.X, rankStartPos.Y.Scale, rankStartPos.Y.Offset + delta.Y)
        end
    end)

    local rBody = Instance.new("Frame", rankFrame)
    rBody.Size = UDim2.new(1, -14, 1, -38); rBody.Position = UDim2.new(0, 7, 0, 33); rBody.BackgroundTransparency = 1
    local rList = Instance.new("UIListLayout", rBody)
    rList.Padding = UDim.new(0, 4); rList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Baris Status Info Target & Jarak Karakter (Live Update)
    local distCard = Instance.new("Frame", rBody)
    distCard.Size = UDim2.new(1, 0, 0, 34); distCard.BackgroundColor3 = Color3.fromRGB(22, 28, 42); distCard.LayoutOrder = 1
    Instance.new("UICorner", distCard).CornerRadius = UDim.new(0, 6)
    local dcStroke = Instance.new("UIStroke", distCard)
    dcStroke.Color = Color3.fromRGB(48, 62, 90); dcStroke.Thickness = 1

    local tNameLbl = Instance.new("TextLabel", distCard)
    tNameLbl.Size = UDim2.new(0.55, 0, 1, 0); tNameLbl.Position = UDim2.new(0, 6, 0, 0); tNameLbl.BackgroundTransparency = 1
    tNameLbl.Font = Enum.Font.GothamBold; tNameLbl.TextColor3 = Color3.fromRGB(255, 215, 90); tNameLbl.TextSize = 9.5
    tNameLbl.TextXAlignment = Enum.TextXAlignment.Left; tNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    tNameLbl.Text = "Target: -"

    local distValLbl = Instance.new("TextLabel", distCard)
    distValLbl.Size = UDim2.new(0.45, -12, 1, 0); distValLbl.Position = UDim2.new(0.55, 0, 0, 0); distValLbl.BackgroundTransparency = 1
    distValLbl.Font = Enum.Font.Code; distValLbl.TextColor3 = Color3.fromRGB(0, 220, 255); distValLbl.TextSize = 9.5
    distValLbl.TextXAlignment = Enum.TextXAlignment.Right; distValLbl.TextTruncate = Enum.TextTruncate.AtEnd
    distValLbl.Text = "Jarak: -"

    -- Loop kalkulasi jarak live ke target base & karakter
    task.spawn(function()
        while rankFrame and rankFrame.Parent do
            task.wait(0.3)
            if rankFrame.Visible then
                pcall(function()
                    local targetPlayer, tgt = getPlayerForSelectedBase()
                    local myChar = localPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local tChar = targetPlayer and targetPlayer.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

                    local bIdx = (tgt and tgt.Index) or State.SelectedBaseIndex or 1
                    local tDisp = targetPlayer and targetPlayer.DisplayName or (tgt and tgt.Owner) or ("Base " .. bIdx)
                    if #tDisp > 12 then tDisp = tDisp:sub(1, 11) .. "…" end
                    tNameLbl.Text = string.format("B%d: %s", bIdx, tDisp)

                    if myRoot and tRoot then
                        local d = (myRoot.Position - tRoot.Position).Magnitude
                        distValLbl.Text = string.format("📏 %.0f stud", d)
                        if d < 35 then
                            distValLbl.TextColor3 = Color3.fromRGB(255, 75, 75)
                        elseif d < 120 then
                            distValLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
                        else
                            distValLbl.TextColor3 = Color3.fromRGB(0, 220, 255)
                        end
                    elseif myRoot and tgt then
                        local basePos = BASE_COORDINATES[bIdx] or tgt.Position or (tgt.Instance and tgt.Instance:GetPivot().Position)
                        if basePos then
                            local d = (myRoot.Position - basePos).Magnitude
                            distValLbl.Text = string.format("🏰 %.0f stud", d)
                            distValLbl.TextColor3 = Color3.fromRGB(180, 200, 225)
                        else
                            distValLbl.Text = "Jarak: -"
                            distValLbl.TextColor3 = Color3.fromRGB(150, 160, 175)
                        end
                    else
                        distValLbl.Text = "Jarak: -"
                        distValLbl.TextColor3 = Color3.fromRGB(150, 160, 175)
                    end
                end)
            end
        end
    end)

    -- Baris Freeze: ON / OFF / AUTO
    local fRow = Instance.new("Frame", rBody)
    fRow.Size = UDim2.new(1, 0, 0, 26); fRow.BackgroundTransparency = 1; fRow.LayoutOrder = 2
    local fList = Instance.new("UIListLayout", fRow)
    fList.FillDirection = Enum.FillDirection.Horizontal; fList.VerticalAlignment = Enum.VerticalAlignment.Center; fList.Padding = UDim.new(0, 4)

    local fLbl = Instance.new("TextLabel", fRow)
    fLbl.Size = UDim2.new(0, 60, 1, 0); fLbl.BackgroundTransparency = 1
    fLbl.Text = "❄️ Freeze"; fLbl.Font = Enum.Font.GothamBold; fLbl.TextColor3 = Color3.fromRGB(0, 220, 255); fLbl.TextSize = 9.5
    fLbl.TextXAlignment = Enum.TextXAlignment.Left

    local rankFreezeBtns = {}
    local function updateRankFreezeBtns()
        local mode = State.FreezeMode or "ON"
        for m, btn in pairs(rankFreezeBtns) do
            if btn and btn.Parent then
                local active = (m == mode)
                if m == "ON" then
                    btn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(38, 48, 70)
                elseif m == "OFF" then
                    btn.BackgroundColor3 = active and Color3.fromRGB(95, 105, 125) or Color3.fromRGB(38, 48, 70)
                else
                    btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(38, 48, 70)
                end
                btn.Text = (active and "● " or "") .. m
            end
        end
    end

    for _, m in ipairs({ "ON", "OFF", "AUTO" }) do
        local b = Instance.new("TextButton", fRow)
        b.Size = UDim2.new(0, 62, 0, 24); b.BackgroundColor3 = Color3.fromRGB(38, 48, 70)
        b.Text = m; b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 9
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local mode = m
        b.MouseButton1Click:Connect(function()
            local targetMode = (mode == "AUTO") and "Auto" or mode
            setFreezeMode(targetMode)
        end)
        rankFreezeBtns[m] = b
    end
    State.UI.UpdateRankFreezeBtns = updateRankFreezeBtns
    updateRankFreezeBtns()

    -- Baris Tombol Auto TP Base & Tombol Noclip
    local rowNav = Instance.new("Frame", rBody)
    rowNav.Size = UDim2.new(1, 0, 0, 28); rowNav.BackgroundTransparency = 1; rowNav.LayoutOrder = 3
    local rnl = Instance.new("UIListLayout", rowNav)
    rnl.FillDirection = Enum.FillDirection.Horizontal; rnl.Padding = UDim.new(0, 4)

    local autoTpBtn = Instance.new("TextButton", rowNav)
    autoTpBtn.Size = UDim2.new(0.62, -2, 1, 0)
    autoTpBtn.Font = Enum.Font.GothamBold; autoTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); autoTpBtn.TextSize = 9.5
    Instance.new("UICorner", autoTpBtn).CornerRadius = UDim.new(0, 5)
    local function updateAutoTpBtn()
        local en = State.AutoTpBaseEnabled
        autoTpBtn.BackgroundColor3 = en and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(38, 48, 70)
        autoTpBtn.Text = en and "🌀 Auto TP: ON (5s)" or "🌀 Auto TP: OFF"
    end
    updateAutoTpBtn()
    autoTpBtn.MouseButton1Click:Connect(function()
        State.AutoTpBaseEnabled = not State.AutoTpBaseEnabled
        State.AutoTpBaseLastTime = tick()
        updateAutoTpBtn()
        showToast("Auto TP Base", State.AutoTpBaseEnabled and "Aktif! Pindah otomatis ke 5 titik base tiap 5 detik." or "Auto TP Base dinonaktifkan.", "info")
    end)

    local noclipBtn = Instance.new("TextButton", rowNav)
    noclipBtn.Size = UDim2.new(0.38, -2, 1, 0)
    noclipBtn.Font = Enum.Font.GothamBold; noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255); noclipBtn.TextSize = 9.5
    Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 5)
    local noclipStroke = Instance.new("UIStroke", noclipBtn)
    noclipStroke.Color = Color3.fromRGB(0, 220, 180); noclipStroke.Thickness = 1

    local function updateNoclipBtnAppearance()
        local en = State.NoclipEnabled
        noclipBtn.BackgroundColor3 = en and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(38, 48, 70)
        noclipBtn.Text = en and "👻 Noclip: ON" or "👻 Noclip: OFF"
        noclipStroke.Color = en and Color3.fromRGB(0, 240, 160) or Color3.fromRGB(50, 65, 90)
    end
    updateNoclipBtnAppearance()
    State.UI.UpdateNoclipButtons = updateNoclipBtnAppearance

    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoclip()
    end)

    -- TP + Kick target base terpilih
    local tpKickBtn = Instance.new("TextButton", rBody)
    tpKickBtn.Size = UDim2.new(1, 0, 0, 30); tpKickBtn.LayoutOrder = 4
    tpKickBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
    tpKickBtn.Text = "🚀 TP + Kick Base Terpilih"
    tpKickBtn.Font = Enum.Font.GothamBold; tpKickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpKickBtn.TextScaled = true; tpKickBtn.TextWrapped = true; tpKickBtn.ClipsDescendants = true
    local tpkSizeC = Instance.new("UITextSizeConstraint", tpKickBtn)
    tpkSizeC.MinTextSize = 8; tpkSizeC.MaxTextSize = 10.5
    local tpkPad = Instance.new("UIPadding", tpKickBtn)
    tpkPad.PaddingLeft = UDim.new(0, 6); tpkPad.PaddingRight = UDim.new(0, 6)
    Instance.new("UICorner", tpKickBtn).CornerRadius = UDim.new(0, 6)
    tpKickBtn.MouseButton1Click:Connect(function()
        local targetPlayer, tgt = getPlayerForSelectedBase()
        if not tgt or tgt.IsLocal then
            showToast("Kick Dibatalkan", "Pilih base musuh terlebih dahulu!", "warn")
            return
        end
        if not targetPlayer or not targetPlayer.Character then
            showToast("Target Offline", "Pemain pemilik base tidak berada di server!", "danger")
            return
        end
        executeTpKickFlingMethod(targetPlayer, true, "Rendah")
    end)

    -- Serang Center Base (1 misil, abaikan shield)
    local centerBtn = Instance.new("TextButton", rBody)
    centerBtn.Size = UDim2.new(1, 0, 0, 28); centerBtn.LayoutOrder = 5
    centerBtn.BackgroundColor3 = Color3.fromRGB(200, 90, 30)
    centerBtn.Text = "💥 Serang Center Base (1 misil)"
    centerBtn.Font = Enum.Font.GothamBold; centerBtn.TextColor3 = Color3.fromRGB(255, 255, 255); centerBtn.TextSize = 9.5
    Instance.new("UICorner", centerBtn).CornerRadius = UDim.new(0, 6)
    centerBtn.MouseButton1Click:Connect(function()
        attackSelectedBaseCenter()
    end)

    -- Serang Karakter (1 misil, seperti di GUI Attack Mode)
    local charBtn = Instance.new("TextButton", rBody)
    charBtn.Size = UDim2.new(1, 0, 0, 28); charBtn.LayoutOrder = 6
    charBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
    charBtn.Text = "👤 Serang Karakter (1 misil)"
    charBtn.Font = Enum.Font.GothamBold; charBtn.TextColor3 = Color3.fromRGB(255, 255, 255); charBtn.TextSize = 9.5
    Instance.new("UICorner", charBtn).CornerRadius = UDim.new(0, 6)
    charBtn.MouseButton1Click:Connect(function()
        attackSelectedBaseCharacter()
    end)

    -- Card 7: Ghost Mode (On/Off + Slider -1600 s/d +1600, default 0)
    local ghostCard = Instance.new("Frame", rBody)
    ghostCard.Size = UDim2.new(1, 0, 0, 60); ghostCard.BackgroundColor3 = Color3.fromRGB(20, 26, 38); ghostCard.LayoutOrder = 7
    Instance.new("UICorner", ghostCard).CornerRadius = UDim.new(0, 6)
    local gcStroke = Instance.new("UIStroke", ghostCard)
    gcStroke.Color = Color3.fromRGB(0, 220, 180); gcStroke.Thickness = 1; gcStroke.Transparency = 0.4

    -- Baris Atas Ghost Card: Tombol Toggle ON/OFF & Status Angka
    local gcRow1 = Instance.new("Frame", ghostCard)
    gcRow1.Size = UDim2.new(1, -12, 0, 24); gcRow1.Position = UDim2.new(0, 6, 0, 4); gcRow1.BackgroundTransparency = 1

    local ghostToggleBtn = Instance.new("TextButton", gcRow1)
    ghostToggleBtn.Size = UDim2.new(0.55, -4, 1, 0)
    ghostToggleBtn.BackgroundColor3 = State.GhostMode and Color3.fromRGB(0, 180, 140) or Color3.fromRGB(38, 48, 68)
    ghostToggleBtn.Text = State.GhostMode and "👻 Ghost: ON" or "👻 Ghost: OFF"
    ghostToggleBtn.Font = Enum.Font.GothamBold; ghostToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ghostToggleBtn.TextSize = 9.5
    Instance.new("UICorner", ghostToggleBtn).CornerRadius = UDim.new(0, 5)

    local ghostValLbl = Instance.new("TextLabel", gcRow1)
    ghostValLbl.Size = UDim2.new(0.45, 0, 1, 0); ghostValLbl.Position = UDim2.new(0.55, 2, 0, 0); ghostValLbl.BackgroundTransparency = 1
    ghostValLbl.Font = Enum.Font.Code; ghostValLbl.TextColor3 = Color3.fromRGB(0, 240, 220); ghostValLbl.TextSize = 9.5
    ghostValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ghostValLbl.Text = string.format("Y: %+d", State.GhostHeight or 0)

    local function updateGhostModeUI()
        if ghostToggleBtn and ghostToggleBtn.Parent then
            ghostToggleBtn.BackgroundColor3 = State.GhostMode and Color3.fromRGB(0, 180, 140) or Color3.fromRGB(38, 48, 68)
            ghostToggleBtn.Text = State.GhostMode and "👻 Ghost: ON" or "👻 Ghost: OFF"
        end
        if ghostValLbl and ghostValLbl.Parent then
            ghostValLbl.Text = string.format("Y: %+d", State.GhostHeight or 0)
        end
    end
    State.UI.UpdateGhostModeUI = updateGhostModeUI

    ghostToggleBtn.MouseButton1Click:Connect(function()
        toggleGhostMode()
    end)

    -- Baris Bawah Ghost Card: Slider Track (-5000 s/d +5000)
    local MIN_GHOST_H = -5000
    local MAX_GHOST_H = 5000

    local gTrack = Instance.new("TextButton", ghostCard)
    gTrack.Size = UDim2.new(1, -16, 0, 8); gTrack.Position = UDim2.new(0, 8, 0, 38)
    gTrack.BackgroundColor3 = Color3.fromRGB(28, 36, 52); gTrack.Text = ""; gTrack.AutoButtonColor = false
    Instance.new("UICorner", gTrack).CornerRadius = UDim.new(0, 4)

    local gFill = Instance.new("Frame", gTrack)
    gFill.BackgroundColor3 = Color3.fromRGB(0, 220, 180); gFill.BorderSizePixel = 0
    Instance.new("UICorner", gFill).CornerRadius = UDim.new(0, 4)

    local gKnob = Instance.new("Frame", gTrack)
    gKnob.Size = UDim2.new(0, 14, 0, 14); gKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    gKnob.BackgroundColor3 = Color3.fromRGB(240, 255, 255); gKnob.BorderSizePixel = 0
    Instance.new("UICorner", gKnob).CornerRadius = UDim.new(1, 0)
    local gkStroke = Instance.new("UIStroke", gKnob); gkStroke.Color = Color3.fromRGB(0, 180, 140); gkStroke.Thickness = 1.5

    local function updateGhostSliderVisual(val)
        local pct = math.clamp((val - MIN_GHOST_H) / (MAX_GHOST_H - MIN_GHOST_H), 0, 1)
        gFill.Size = UDim2.new(pct, 0, 1, 0)
        gKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        ghostValLbl.Text = string.format("Y: %+d", math.floor(val))
    end
    updateGhostSliderVisual(State.GhostHeight or 0)

    local isDraggingGhostSlider = false
    local function applyGhostSliderInput(input)
        local trackAbsPos = gTrack.AbsolutePosition.X
        local trackAbsWidth = gTrack.AbsoluteSize.X
        if trackAbsWidth <= 0 then return end
        local clickX = input.Position.X
        local pct = math.clamp((clickX - trackAbsPos) / trackAbsWidth, 0, 1)
        local val = math.floor(MIN_GHOST_H + (pct * (MAX_GHOST_H - MIN_GHOST_H)))
        State.GhostHeight = val
        updateGhostSliderVisual(val)
    end

    gTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingGhostSlider = true
            applyGhostSliderInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingGhostSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            applyGhostSliderInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingGhostSlider = false
        end
    end)

    return rankFrame
end

local function assembleGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WW3_SupremeCommand_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = targetParent

    local atkModalHUD = createAttackHUDModal(screenGui)
    local rankGuiFrame = createRankGUI(screenGui)

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 620, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -310, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local sMain = Instance.new("UIStroke", mainFrame)
    sMain.Color = Color3.fromRGB(0, 180, 255); sMain.Thickness = 1.5; sMain.Transparency = 0.3

    makeResizable(mainFrame, Vector2.new(460, 320), Vector2.new(1400, 1000), Color3.fromRGB(0, 200, 255))

    -- Minimized Bar
    local miniBar = Instance.new("Frame", screenGui)
    miniBar.Size = UDim2.new(0, 470, 0, 42); miniBar.Position = UDim2.new(0.5, -235, 0.05, 0)
    miniBar.BackgroundColor3 = Color3.fromRGB(15, 20, 30); miniBar.Visible = false; miniBar.Active = true; miniBar.Draggable = true
    Instance.new("UICorner", miniBar).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", miniBar).Color = Color3.fromRGB(0, 200, 255)

    local mTitle = Instance.new("TextLabel", miniBar)
    mTitle.Size = UDim2.new(0, 120, 1, 0); mTitle.Position = UDim2.new(0, 10, 0, 0); mTitle.BackgroundTransparency = 1
    mTitle.Text = "⚡ WW3 HUD"; mTitle.Font = Enum.Font.GothamBold; mTitle.TextColor3 = Color3.fromRGB(0, 220, 255); mTitle.TextSize = 12

    local mStop = Instance.new("TextButton", miniBar)
    mStop.Size = UDim2.new(0, 60, 0, 26); mStop.Position = UDim2.new(0, 135, 0, 8); mStop.BackgroundColor3 = Color3.fromRGB(220, 45, 60)
    mStop.Text = "🛑 STOP"; mStop.Font = Enum.Font.GothamBold; mStop.TextColor3 = Color3.fromRGB(255, 255, 255); mStop.TextSize = 10
    Instance.new("UICorner", mStop).CornerRadius = UDim.new(0, 6)
    mStop.MouseButton1Click:Connect(stopAllAutomation)

    local mFly = Instance.new("TextButton", miniBar)
    mFly.Size = UDim2.new(0, 55, 0, 26); mFly.Position = UDim2.new(0, 200, 0, 8); mFly.BackgroundColor3 = Color3.fromRGB(30, 40, 58)
    mFly.Text = "🕊️ FLY"; mFly.Font = Enum.Font.GothamBold; mFly.TextColor3 = Color3.fromRGB(200, 220, 255); mFly.TextSize = 10
    Instance.new("UICorner", mFly).CornerRadius = UDim.new(0, 6)
    mFly.MouseButton1Click:Connect(function() toggleFly(not State.FlyEnabled) end)

    local mAtkModal = Instance.new("TextButton", miniBar)
    mAtkModal.Size = UDim2.new(0, 75, 0, 26); mAtkModal.Position = UDim2.new(0, 260, 0, 8); mAtkModal.BackgroundColor3 = Color3.fromRGB(220, 70, 30)
    mAtkModal.Text = "⚔️ MODE ATK"; mAtkModal.Font = Enum.Font.GothamBold; mAtkModal.TextColor3 = Color3.fromRGB(255, 255, 255); mAtkModal.TextSize = 9
    Instance.new("UICorner", mAtkModal).CornerRadius = UDim.new(0, 6)
    mAtkModal.MouseButton1Click:Connect(function()
        State.AttackModalVisible = not State.AttackModalVisible
        atkModalHUD.Visible = State.AttackModalVisible
    end)

    local mAtk = Instance.new("TextButton", miniBar)
    mAtk.Size = UDim2.new(0, 60, 0, 26); mAtk.Position = UDim2.new(0, 340, 0, 8); mAtk.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
    mAtk.Text = "🤖 AUTO"; mAtk.Font = Enum.Font.GothamBold; mAtk.TextColor3 = Color3.fromRGB(255, 255, 255); mAtk.TextSize = 10
    Instance.new("UICorner", mAtk).CornerRadius = UDim.new(0, 6)
    mAtk.MouseButton1Click:Connect(runAutonomousAttack)

    local mExp = Instance.new("TextButton", miniBar)
    mExp.Size = UDim2.new(0, 36, 0, 26); mExp.Position = UDim2.new(1, -44, 0, 8); mExp.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    mExp.Text = "🔲"; mExp.Font = Enum.Font.GothamBold; mExp.TextColor3 = Color3.fromRGB(255, 255, 255); mExp.TextSize = 12
    Instance.new("UICorner", mExp).CornerRadius = UDim.new(0, 6)
    mExp.MouseButton1Click:Connect(function() miniBar.Visible = false; mainFrame.Visible = true end)

    -- Header Bar
    local hBar = Instance.new("Frame", mainFrame)
    hBar.Size = UDim2.new(1, 0, 0, 42); hBar.BackgroundColor3 = Color3.fromRGB(18, 23, 35); hBar.BorderSizePixel = 0
    Instance.new("UICorner", hBar).CornerRadius = UDim.new(0, 12)

    local hTitle = Instance.new("TextLabel", hBar)
    hTitle.Size = UDim2.new(0, 180, 1, 0); hTitle.Position = UDim2.new(0, 14, 0, 0); hTitle.BackgroundTransparency = 1
    hTitle.Text = "⚡ WW3 COMMAND HUD"; hTitle.Font = Enum.Font.GothamBold; hTitle.TextColor3 = Color3.fromRGB(255, 255, 255); hTitle.TextSize = 13; hTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Container Header Controls (Responsif mengikuti lebar GUI)
    local hControls = Instance.new("Frame", hBar)
    hControls.Size = UDim2.new(1, -190, 1, 0); hControls.Position = UDim2.new(0, 185, 0, 0); hControls.BackgroundTransparency = 1
    local hcl = Instance.new("UIListLayout", hControls)
    hcl.FillDirection = Enum.FillDirection.Horizontal
    hcl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    hcl.VerticalAlignment = Enum.VerticalAlignment.Center
    hcl.Padding = UDim.new(0, 5)

    -- Shortcut Tombol Buka/Tutup GUI Mode Attack & Tombol TP Base
    local modeAtkHeaderBtn = Instance.new("TextButton", hControls)
    modeAtkHeaderBtn.Size = UDim2.new(0, 88, 0, 26); modeAtkHeaderBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 30)
    modeAtkHeaderBtn.Text = "⚔️ Mode Attack"; modeAtkHeaderBtn.Font = Enum.Font.GothamBold; modeAtkHeaderBtn.TextColor3 = Color3.fromRGB(255, 255, 255); modeAtkHeaderBtn.TextSize = 9.5
    Instance.new("UICorner", modeAtkHeaderBtn).CornerRadius = UDim.new(0, 6)
    local mahStroke = Instance.new("UIStroke", modeAtkHeaderBtn); mahStroke.Color = Color3.fromRGB(255, 180, 0); mahStroke.Thickness = 1
    modeAtkHeaderBtn.MouseButton1Click:Connect(function()
        State.AttackModalVisible = not State.AttackModalVisible
        atkModalHUD.Visible = State.AttackModalVisible
        modeAtkHeaderBtn.BackgroundColor3 = State.AttackModalVisible and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(220, 70, 30)
        showToast("Mode Attack GUI", State.AttackModalVisible and "GUI Mode Attack dibuka!" or "GUI Mode Attack ditutup.", "info")
    end)

    local rankHeaderBtn = Instance.new("TextButton", hControls)
    rankHeaderBtn.Size = UDim2.new(0, 56, 0, 26); rankHeaderBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
    rankHeaderBtn.Text = "🏆 Rank"; rankHeaderBtn.Font = Enum.Font.GothamBold; rankHeaderBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rankHeaderBtn.TextSize = 9.5
    Instance.new("UICorner", rankHeaderBtn).CornerRadius = UDim.new(0, 6)
    local rhbStroke = Instance.new("UIStroke", rankHeaderBtn); rhbStroke.Color = Color3.fromRGB(255, 220, 90); rhbStroke.Thickness = 1
    State.UI.RankHeaderBtn = rankHeaderBtn
    rankHeaderBtn.MouseButton1Click:Connect(function()
        rankGuiFrame.Visible = not rankGuiFrame.Visible
        rankHeaderBtn.BackgroundColor3 = rankGuiFrame.Visible and Color3.fromRGB(0, 180, 115) or Color3.fromRGB(180, 140, 20)
        showToast("GUI Rank", rankGuiFrame.Visible and "GUI Rank dibuka!" or "GUI Rank ditutup.", "info")
    end)

    local tpBaseHeaderBtn = Instance.new("TextButton", hControls)
    tpBaseHeaderBtn.Size = UDim2.new(0, 38, 0, 26); tpBaseHeaderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    tpBaseHeaderBtn.Text = "🌀 TP"; tpBaseHeaderBtn.Font = Enum.Font.GothamBold; tpBaseHeaderBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tpBaseHeaderBtn.TextSize = 9.5
    Instance.new("UICorner", tpBaseHeaderBtn).CornerRadius = UDim.new(0, 6)
    local tpbStroke = Instance.new("UIStroke", tpBaseHeaderBtn); tpbStroke.Color = Color3.fromRGB(80, 240, 255); tpbStroke.Thickness = 1
    tpBaseHeaderBtn.MouseButton1Click:Connect(function()
        teleportBaseRandomSpot()
    end)

    -- Tombol Toggle Auto Evade Misil (Y < 20)
    local evadeHeaderBtn = Instance.new("TextButton", hControls)
    evadeHeaderBtn.Size = UDim2.new(0, 78, 0, 26)
    evadeHeaderBtn.Font = Enum.Font.GothamBold; evadeHeaderBtn.TextColor3 = Color3.fromRGB(255, 255, 255); evadeHeaderBtn.TextSize = 9.5
    Instance.new("UICorner", evadeHeaderBtn).CornerRadius = UDim.new(0, 6)
    local ehbStroke = Instance.new("UIStroke", evadeHeaderBtn); ehbStroke.Thickness = 1

    local function updateEvadeBtnAppearance()
        local en = State.MissileEvadeEnabled
        evadeHeaderBtn.BackgroundColor3 = en and Color3.fromRGB(0, 175, 115) or Color3.fromRGB(45, 55, 75)
        evadeHeaderBtn.Text = en and "🛡️ Evade: ON" or "🛡️ Evade: OFF"
        ehbStroke.Color = en and Color3.fromRGB(80, 255, 180) or Color3.fromRGB(60, 75, 100)
    end
    updateEvadeBtnAppearance()
    State.UI.UpdateEvadeButton = updateEvadeBtnAppearance

    evadeHeaderBtn.MouseButton1Click:Connect(function()
        State.MissileEvadeEnabled = not State.MissileEvadeEnabled
        updateEvadeBtnAppearance()
        showToast("Auto Evade Misil", State.MissileEvadeEnabled and "AKTIF: Otomatis kabur ke Base jika ada misil di atas (Y < 20)." or "NONAKTIF: Karakter tidak akan kabur otomatis saat ada misil di atas.", State.MissileEvadeEnabled and "success" or "warn")
    end)

    -- Tombol Freeze di Header Bar (Menggantikan Save & Load di Header)
    local freezeHeaderBtn = Instance.new("TextButton", hControls)
    freezeHeaderBtn.Size = UDim2.new(0, 84, 0, 26)
    Instance.new("UICorner", freezeHeaderBtn).CornerRadius = UDim.new(0, 6)
    local fhbStroke = Instance.new("UIStroke", freezeHeaderBtn); fhbStroke.Color = Color3.fromRGB(0, 220, 255); fhbStroke.Thickness = 1

    local function updateHeaderFreezeAppearance()
        local mode = State.FreezeMode or "ON"
        if mode == "ON" then
            freezeHeaderBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
            freezeHeaderBtn.Text = "❄️ Freeze: ON"
        elseif mode == "OFF" then
            freezeHeaderBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
            freezeHeaderBtn.Text = "❄️ Freeze: OFF"
        else
            freezeHeaderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
            freezeHeaderBtn.Text = "❄️ Freeze: AUTO"
        end
    end

    State.UI.UpdateFreezeButtons = function()
        pcall(updateHeaderFreezeAppearance)
        if State.UI.UpdateFreezeBtnTab then
            pcall(State.UI.UpdateFreezeBtnTab)
        end
        if State.UI.UpdateRankFreezeBtns then
            pcall(State.UI.UpdateRankFreezeBtns)
        end
        if State.UI.UpdateRankHeaderFreeze then
            pcall(State.UI.UpdateRankHeaderFreeze)
        end
    end
    updateHeaderFreezeAppearance()

    freezeHeaderBtn.Font = Enum.Font.GothamBold; freezeHeaderBtn.TextColor3 = Color3.fromRGB(255, 255, 255); freezeHeaderBtn.TextSize = 9.5
    freezeHeaderBtn.MouseButton1Click:Connect(function()
        local cur = State.FreezeMode or "ON"
        local nextMode = "OFF"
        if cur == "ON" then
            nextMode = "OFF"
        elseif cur == "OFF" then
            nextMode = "Auto"
        else
            nextMode = "ON"
        end
        setFreezeMode(nextMode)
    end)

    local mStopAll = Instance.new("TextButton", hControls)
    mStopAll.Size = UDim2.new(0, 72, 0, 26); mStopAll.BackgroundColor3 = Color3.fromRGB(215, 45, 60)
    mStopAll.Text = "🛑 STOP ALL"; mStopAll.Font = Enum.Font.GothamBold; mStopAll.TextColor3 = Color3.fromRGB(255, 255, 255); mStopAll.TextSize = 9.5
    Instance.new("UICorner", mStopAll).CornerRadius = UDim.new(0, 6)
    mStopAll.MouseButton1Click:Connect(stopAllAutomation)

    local minBtn = Instance.new("TextButton", hControls)
    minBtn.Size = UDim2.new(0, 28, 0, 26); minBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    minBtn.Text = "─"; minBtn.Font = Enum.Font.GothamBold; minBtn.TextColor3 = Color3.fromRGB(200, 220, 255); minBtn.TextSize = 13
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false; miniBar.Visible = true end)

    local clsBtn = Instance.new("TextButton", hControls)
    clsBtn.Size = UDim2.new(0, 28, 0, 26); clsBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    clsBtn.Text = "✕"; clsBtn.Font = Enum.Font.GothamBold; clsBtn.TextColor3 = Color3.fromRGB(255, 120, 120); clsBtn.TextSize = 13
    Instance.new("UICorner", clsBtn).CornerRadius = UDim.new(0, 6)
    clsBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Dragging
    local dragStart, startPos, dragging
    hBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 150, 1, -42); sidebar.Position = UDim2.new(0, 0, 0, 42); sidebar.BackgroundColor3 = Color3.fromRGB(16, 20, 28); sidebar.BorderSizePixel = 0
    local sList = Instance.new("UIListLayout", sidebar); sList.SortOrder = Enum.SortOrder.LayoutOrder; sList.Padding = UDim.new(0, 6)
    local sPad = Instance.new("UIPadding", sidebar); sPad.PaddingTop = UDim.new(0, 10); sPad.PaddingLeft = UDim.new(0, 8); sPad.PaddingRight = UDim.new(0, 8)

    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Size = UDim2.new(1, -150, 1, -42); contentArea.Position = UDim2.new(0, 150, 0, 42); contentArea.BackgroundColor3 = Color3.fromRGB(13, 16, 23); contentArea.BorderSizePixel = 0

    local tabPages = {}
    local function createTab(name)
        local sf = Instance.new("ScrollingFrame", contentArea)
        sf.Size = UDim2.new(1, 0, 1, 0); sf.BackgroundTransparency = 1; sf.ScrollBarThickness = 4; sf.Visible = false
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        local p = Instance.new("UIPadding", sf); p.PaddingTop = UDim.new(0, 12); p.PaddingLeft = UDim.new(0, 14); p.PaddingRight = UDim.new(0, 14); p.PaddingBottom = UDim.new(0, 20)
        local layout = Instance.new("UIListLayout", sf)
        layout.Padding = UDim.new(0, 12)

        local function updateCanvas()
            local totalY = layout.AbsoluteContentSize.Y + p.PaddingTop.Offset + p.PaddingBottom.Offset + 12
            sf.CanvasSize = UDim2.new(0, 0, 0, math.max(0, totalY))
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.defer(updateCanvas)

        tabPages[name] = sf
        return sf
    end

    local infoPage = createTab("Info")
    local missilePage = createTab("Missile")
    local attackPage = createTab("Attack")
    local farmPage = createTab("Farm")
    local extraPage = createTab("Extra")
    local graphicsPage = createTab("Graphics")

    local navButtons = {}
    local function addNav(name, text, targetTab, order)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, 0, 0, 36); btn.BackgroundColor3 = Color3.fromRGB(24, 30, 42); btn.Text = "  " .. text
        btn.Font = Enum.Font.GothamSemibold; btn.TextColor3 = Color3.fromRGB(180, 200, 220); btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left; btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        navButtons[name] = btn

        btn.MouseButton1Click:Connect(function()
            for tN, p in pairs(tabPages) do p.Visible = (tN == targetTab) end
            for bN, b in pairs(navButtons) do
                b.BackgroundColor3 = (bN == name) and Color3.fromRGB(0, 160, 240) or Color3.fromRGB(24, 30, 42)
                b.TextColor3 = (bN == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 200, 220)
            end
        end)
    end

    addNav("Info", "📊 Info Personal", "Info", 1)
    addNav("Missile", "🚀 Missile Setup", "Missile", 2)
    addNav("Attack", "⚔️ Attack Setup", "Attack", 3)
    addNav("Farm", "🌾 Auto Farming", "Farm", 4)
    addNav("Extra", "🛠️ Fitur Tambahan", "Extra", 5)
    addNav("Graphics", "🎨 Pengaturan Grafik", "Graphics", 6)

    -- Sidebar Emergency Stops
    local div = Instance.new("Frame", sidebar)
    div.Size = UDim2.new(1, 0, 0, 2); div.BackgroundColor3 = Color3.fromRGB(35, 42, 58); div.LayoutOrder = 10

    local function addSideStop(text, cb, order)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(40, 24, 28); btn.Text = text
        btn.Font = Enum.Font.GothamBold; btn.TextColor3 = Color3.fromRGB(255, 90, 100); btn.TextSize = 11; btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(180, 50, 60)
        btn.MouseButton1Click:Connect(cb)
    end

    addSideStop("🛑 Stop Buy", function() State.AutoBuyActive = false; State.RefillEnabled = false; logMessage("Auto Buy DIHENTIKAN.") end, 11)
    addSideStop("🛑 Stop Deploy", function() toggleAutoDeploy(false); logMessage("Auto Deploy DIHENTIKAN.") end, 12)
    addSideStop("🛑 Stop Attack", function()
        State.AutoAttackActive = false
        State.TargetLoopActive = false
        State.ActiveLoopCategory = nil
        State.FarmRunning = false
        logMessage("Auto Attack & Target Loop DIHENTIKAN.")
    end, 13)

    -- Build each modular tab
    buildInfoTab(infoPage)
    buildMissileTab(missilePage, mainFrame)
    buildAttackTab(attackPage)
    buildFarmTab(farmPage)
    buildExtraTab(extraPage)
    buildGraphicsTab(graphicsPage)

    -- Default Active Tab
    infoPage.Visible = true
    navButtons["Info"].BackgroundColor3 = Color3.fromRGB(0, 160, 240)
    navButtons["Info"].TextColor3 = Color3.fromRGB(255, 255, 255)

    -- ================================================================================================
    -- TOUCH / MOBILE FLY CONTROLS PAD (UNTUK SMARTPHONE / TABLET)
    -- ================================================================================================
    local function createMobileFlyControls(guiParent)
        local padContainer = Instance.new("Frame", guiParent)
        padContainer.Name = "WW3_MobileFlyControls"
        padContainer.Size = UDim2.new(1, 0, 1, 0)
        padContainer.BackgroundTransparency = 1
        padContainer.Visible = false
        padContainer.ZIndex = 9999

        State.MobileFly.Container = padContainer

        -- D-Pad Kiri (Maju, Mundur, Kiri, Kanan)
        local dpadFrame = Instance.new("Frame", padContainer)
        dpadFrame.Size = UDim2.new(0, 150, 0, 150)
        dpadFrame.Position = UDim2.new(0, 20, 1, -170)
        dpadFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
        dpadFrame.BackgroundTransparency = 0.35
        Instance.new("UICorner", dpadFrame).CornerRadius = UDim.new(0, 16)
        local dStroke = Instance.new("UIStroke", dpadFrame)
        dStroke.Color = Color3.fromRGB(0, 180, 255); dStroke.Thickness = 1.5; dStroke.Transparency = 0.4

        local dTitle = Instance.new("TextLabel", dpadFrame)
        dTitle.Size = UDim2.new(1, 0, 0, 16); dTitle.Position = UDim2.new(0, 0, 0, 2)
        dTitle.BackgroundTransparency = 1; dTitle.Text = "🕹️ FLY DIRECTION"
        dTitle.Font = Enum.Font.GothamBold; dTitle.TextColor3 = Color3.fromRGB(0, 220, 255); dTitle.TextSize = 8

        local function makeDirBtn(name, text, pos, pressKey)
            local b = Instance.new("TextButton", dpadFrame)
            b.Name = name; b.Size = UDim2.new(0, 42, 0, 42); b.Position = pos
            b.BackgroundColor3 = Color3.fromRGB(24, 32, 48); b.Text = text
            b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 16
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            local st = Instance.new("UIStroke", b); st.Color = Color3.fromRGB(0, 140, 220); st.Thickness = 1

            local function setDir(isPressed)
                State.MobileFly[pressKey] = isPressed
                b.BackgroundColor3 = isPressed and Color3.fromRGB(0, 170, 240) or Color3.fromRGB(24, 32, 48)
            end
            b.MouseButton1Down:Connect(function() setDir(true) end)
            b.MouseButton1Up:Connect(function() setDir(false) end)
            b.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setDir(false)
                end
            end)
            return b
        end

        makeDirBtn("BtnUp", "▲", UDim2.new(0.5, -21, 0, 20), "Forward")
        makeDirBtn("BtnDown", "▼", UDim2.new(0.5, -21, 1, -46), "Backward")
        makeDirBtn("BtnLeft", "◄", UDim2.new(0, 6, 0.5, -21), "Left")
        makeDirBtn("BtnRight", "►", UDim2.new(1, -48, 0.5, -21), "Right")

        -- Altitude Pad Kanan (Naik / Turun & Tombol Matikan Fly)
        local altFrame = Instance.new("Frame", padContainer)
        altFrame.Size = UDim2.new(0, 75, 0, 150)
        altFrame.Position = UDim2.new(1, -95, 1, -170)
        altFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
        altFrame.BackgroundTransparency = 0.35
        Instance.new("UICorner", altFrame).CornerRadius = UDim.new(0, 16)
        local aStroke = Instance.new("UIStroke", altFrame)
        aStroke.Color = Color3.fromRGB(0, 220, 140); aStroke.Thickness = 1.5; aStroke.Transparency = 0.4

        local aTitle = Instance.new("TextLabel", altFrame)
        aTitle.Size = UDim2.new(1, 0, 0, 16); aTitle.Position = UDim2.new(0, 0, 0, 2)
        aTitle.BackgroundTransparency = 1; aTitle.Text = "ALTITUDE"
        aTitle.Font = Enum.Font.GothamBold; aTitle.TextColor3 = Color3.fromRGB(0, 255, 170); aTitle.TextSize = 8

        local function makeAltBtn(name, text, pos, pressKey)
            local b = Instance.new("TextButton", altFrame)
            b.Name = name; b.Size = UDim2.new(0, 58, 0, 36); b.Position = pos
            b.BackgroundColor3 = Color3.fromRGB(24, 38, 48); b.Text = text
            b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.TextSize = 13
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", b); st.Color = Color3.fromRGB(0, 200, 140); st.Thickness = 1

            local function setAlt(isPressed)
                State.MobileFly[pressKey] = isPressed
                b.BackgroundColor3 = isPressed and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(24, 38, 48)
            end
            b.MouseButton1Down:Connect(function() setAlt(true) end)
            b.MouseButton1Up:Connect(function() setAlt(false) end)
            b.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setAlt(false)
                end
            end)
            return b
        end

        makeAltBtn("BtnElevUp", "🚀 UP", UDim2.new(0.5, -29, 0, 20), "Up")
        makeAltBtn("BtnElevDown", "⚓ DOWN", UDim2.new(0.5, -29, 0, 62), "Down")

        -- Tombol Cepat Exit Fly di Smartphone
        local stopFlyBtn = Instance.new("TextButton", altFrame)
        stopFlyBtn.Size = UDim2.new(0, 58, 0, 34); stopFlyBtn.Position = UDim2.new(0.5, -29, 1, -40)
        stopFlyBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 60); stopFlyBtn.Text = "🛑 OFF"
        stopFlyBtn.Font = Enum.Font.GothamBold; stopFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); stopFlyBtn.TextSize = 11
        Instance.new("UICorner", stopFlyBtn).CornerRadius = UDim.new(0, 8)
        stopFlyBtn.MouseButton1Click:Connect(function()
            toggleFly(false)
        end)
    end

    createMobileFlyControls(screenGui)
    return screenGui
end

-- Keybind F for Fly (Keyboard PC)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F then
        toggleFly(not State.FlyEnabled)
    end
end)

-- ====================================================================================================
-- STARTUP ASSET PRELOADER DENGAN PERSENTASE BAR (0% - 100%)
-- Menjamin semua data pemain, pangkalan, roket, & armada warship termuat sempurna sebelum GUI aktif
-- ====================================================================================================
local function runStartupAssetPreloader()
    local pGui = getPlayerGui()
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "WW3_StartupPreloader"
    loaderGui.ResetOnSpawn = false
    loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loaderGui.Parent = targetParent

    local loadFrame = Instance.new("Frame", loaderGui)
    loadFrame.Size = UDim2.new(0, 420, 0, 160)
    loadFrame.Position = UDim2.new(0.5, -210, 0.5, -80)
    loadFrame.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
    loadFrame.BorderSizePixel = 0
    Instance.new("UICorner", loadFrame).CornerRadius = UDim.new(0, 12)
    local lStroke = Instance.new("UIStroke", loadFrame)
    lStroke.Color = Color3.fromRGB(0, 180, 255); lStroke.Thickness = 1.5

    local titleLbl = Instance.new("TextLabel", loadFrame)
    titleLbl.Size = UDim2.new(1, -24, 0, 24); titleLbl.Position = UDim2.new(0, 12, 0, 14)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "⚡ WW3 SUPREME COMMAND - INITIALIZING..."
    titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextColor3 = Color3.fromRGB(0, 220, 255); titleLbl.TextSize = 13

    local statusLbl = Instance.new("TextLabel", loadFrame)
    statusLbl.Size = UDim2.new(1, -24, 0, 20); statusLbl.Position = UDim2.new(0, 12, 0, 44)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Menghubungkan ke server game..."
    statusLbl.Font = Enum.Font.Gotham; statusLbl.TextColor3 = Color3.fromRGB(190, 210, 235); statusLbl.TextSize = 11

    local barBg = Instance.new("Frame", loadFrame)
    barBg.Size = UDim2.new(1, -24, 0, 18); barBg.Position = UDim2.new(0, 12, 0, 76)
    barBg.BackgroundColor3 = Color3.fromRGB(20, 28, 42)
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 9)
    local bStroke = Instance.new("UIStroke", barBg); bStroke.Color = Color3.fromRGB(35, 55, 80)

    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 9)
    local fillGrad = Instance.new("UIGradient", barFill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 200))
    })

    local percentLbl = Instance.new("TextLabel", loadFrame)
    percentLbl.Size = UDim2.new(1, -24, 0, 20); percentLbl.Position = UDim2.new(0, 12, 0, 102)
    percentLbl.BackgroundTransparency = 1
    percentLbl.Text = "0%"
    percentLbl.Font = Enum.Font.GothamBold; percentLbl.TextColor3 = Color3.fromRGB(255, 255, 255); percentLbl.TextSize = 12

    local function setProgress(pct, message)
        pct = math.clamp(pct, 0, 100)
        statusLbl.Text = message
        percentLbl.Text = string.format("%d%%", pct)
        TweenService:Create(barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(pct / 100, 0, 1, 0)
        }):Play()
    end

    task.spawn(function()
        -- Langkah 1: Sinkronisasi Workspace & Remote (15%)
        setProgress(15, "Menunggu sinkronisasi Workspace & Remotes...")
        pcall(function()
            local mbFolder = Workspace:WaitForChild("MilitaryBase", 6)
        end)
        task.wait(0.3)

        -- Langkah 2: Mengidentifikasi Pangkalan Pemain (35%)
        setProgress(35, "Memindai pangkalan pemain (Base Plot)...")
        local baseFound = nil
        for attempt = 1, 12 do
            local ok, res = pcall(getMyBaseData)
            if ok and res then
                baseFound = res
                break
            end
            task.wait(0.25)
        end
        if baseFound then
            setProgress(45, string.format("Base terdeteksi: MilitaryBase%d", baseFound.Index))
        else
            setProgress(45, "Base plot sedang disinkronisasi dari server...")
        end
        task.wait(0.2)

        -- Langkah 3: Membaca Roket & Stok Tas (65%)
        setProgress(65, "Memindai persediaan misil di tas & pangkalan...")
        pcall(function() getMyPlacedRockets(true) end)
        task.wait(0.2)

        -- Langkah 4: Membaca Armada Kapal (Warships) (85%)
        setProgress(85, "Memeriksa status armada Warship...")
        pcall(getMyPlacedWarships)
        task.wait(0.2)

        -- Langkah 5: Memindai Base Lawan & Pertahanan (95%)
        setProgress(95, "Memindai seluruh pangkalan 1-6 & pertahanan...")
        pcall(function() scanAllBases(true) end)
        task.wait(0.3)

        -- Langkah 6: Selesai 100%
        setProgress(100, "✅ Seluruh data siap! Membuka Command HUD...")
        task.wait(0.4)

        -- Buka GUI Utama
        local okGui, errGui = pcall(assembleGUI)
        if not okGui then
            warn("Error assembleGUI:", errGui)
        end

        -- Hapus Preloader
        TweenService:Create(loadFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        loaderGui:Destroy()
        -- Freeze default OFF dan Noclip default ON sesuai instruksi
        setFreezeMode("OFF")
        toggleNoclip(true)

        showToast("WW3 Supreme Command", "Sistem siap tempur! Freeze: OFF | Noclip: ON.", "success")
    end)
end

runStartupAssetPreloader()

print([[
============================================================
 WW3 SUPREME COMMAND HUD (ww3.lua) V2 MODULAR READY!
 • Error limit 200 local registers teratasi sepenuhnya!
 • Preloader asset bar & Smartphone Fly touch controls aktif!
============================================================
]])
