local Cfg = (...)

if not Cfg then
    error("No se pasó el parámetro de configuración del script")
end

if _G.JYR9MC9P then
    print("[AutoPlayMapper] Ya hay un script activo")
    return
end

local VirtualInput = game:GetService("VirtualInputManager")
local UserInput = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Cam = workspace.CurrentCamera
local random = Random.new()
local inMatch = false
local pause = false
local active = true
local playerSlot = 1
local keys = { "A", "S", "D", "F" }
local tracks = {}
local conns = {}

function Print(args)
    if Cfg.logs then
        print(table.concat({ "[RoBeats Autoplay] ", args }))
    end
end

local function Pause(p)
    if p then
        Print("Pausado")
    else
        Print("Reanudado")
    end
    pause = p
end

local function RandomDist()
    if Cfg.superAccuracy then
        return 0.5
    end
    return (random:NextNumber(Cfg.limBottom, Cfg.limUpper) + random:NextNumber(Cfg.limBottom, Cfg.limUpper) + random:NextNumber(Cfg.limBottom, Cfg.limUpper)) / 3
end

local Track = {}
function Track:new(nid)
    local Self = {
        ID = nid,
        Pressed = false,
        RandomDist = RandomDist(),
        CFrame = CFrame.new()
    }

    function Self:Press(press)
        if press then
            Self.RandomDist = RandomDist()
        end
        Self.Pressed = press
        VirtualInput:SendKeyEvent(press, keys[self.ID], false, game)
    end

    return Self
end

local trackPositions = {
    {
        CFrame.new(-309.007, 387.952, -181.099) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(39.375 - 90), math.rad(90)),
        CFrame.new(-306.872, 387.952, -178.562) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(43.125 - 90), math.rad(90)),
        CFrame.new(-304.528, 387.952, -176.218) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(46.875 - 90), math.rad(90)),
        CFrame.new(-301.991, 387.952, -174.083) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(50.625 - 90), math.rad(90))
    },
    {
        CFrame.new(-301.991, 387.952, -235.647) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-50.625 - 90), math.rad(90)),
        CFrame.new(-304.528, 387.952, -233.512) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-46.875 - 90), math.rad(90)),
        CFrame.new(-306.872, 387.952, -231.168) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-43.125 - 90), math.rad(90)),
        CFrame.new(-309.007, 387.952, -228.631) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-39.375 - 90), math.rad(90))
    },
    {
        CFrame.new(-247.443, 387.952, -228.631) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-140.625 - 90), math.rad(90)),
        CFrame.new(-249.578, 387.952, -231.168) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-136.875 - 90), math.rad(90)),
        CFrame.new(-251.922, 387.952, -233.512) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-133.125 - 90), math.rad(90)),
        CFrame.new(-254.459, 387.952, -235.647) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(-129.375 - 90), math.rad(90))
    },
    {
        CFrame.new(-254.459, 387.952, -174.083) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(129.375 - 90), math.rad(90)),
        CFrame.new(-251.922, 387.952, -176.218) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(133.125 - 90), math.rad(90)),
        CFrame.new(-249.578, 387.952, -178.562) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(136.875 - 90), math.rad(90)),
        CFrame.new(-247.443, 387.952, -181.099) *
        CFrame.fromEulerAngles(math.rad(0), math.rad(140.625 - 90), math.rad(90))
    }
}

local function GetNearestTrack(pos)
    local nearestTrack = nil;
    local distLowest = 200000;
    for index, track in ipairs(tracks) do
        local dist = (pos - track.CFrame.Position).Magnitude

        if dist < distLowest then
            distLowest = dist
            nearestTrack = track
        end
    end
    return nearestTrack, distLowest
end

local function UpdateSingleNote(obj)
    local track, distance = GetNearestTrack(obj.CFrame.Position)
    if not track then
        return
    end
    local dot = (obj.CFrame.Position - track.CFrame.Position):Dot(track.CFrame.LookVector)
    if dot > Cfg.limUpper + 1 then
        obj:SetAttribute("hit", false)
    end
    if not obj:GetAttribute("hit") and dot <= track.RandomDist then
        track:Press(true)
        obj:SetAttribute("hit", true)
        task.wait(random:NextNumber(Cfg.keyDelayMin, Cfg.keyDelayMax))
        track:Press(false)
    end
end

local function UpdateLongNote(obj)
    local track, distance = GetNearestTrack(obj.CFrame.Position)
    if not track then
        return
    end
    local dot = (obj.CFrame.Position - track.CFrame.Position):Dot(track.CFrame.LookVector)
    local dot_end = ((obj.CFrame.Position + obj.CFrame.LookVector * (obj.Height / 2)) - track.CFrame.Position):Dot(track.CFrame
        .LookVector)
    local dot_start = dot - obj.Height / 2
    if dot_start > Cfg.limUpper + 1 then
        obj:SetAttribute("hit", false)
        obj:SetAttribute("holding", false)
    end
    if not obj:GetAttribute("hit") and not obj:GetAttribute("holding") and dot_start <= track.RandomDist and dot_end >
        track.RandomDist then
        track:Press(true)
        obj:SetAttribute("holding", true)
    end
    if not obj:GetAttribute("hit") and obj:GetAttribute("holding") and dot_end <= track.RandomDist then
        track:Press(false)
        obj:SetAttribute("holding", false)
        obj:SetAttribute("hit", true)
    end
end

local function UpdateNotes(obj)
    if inMatch and obj.Transparency < 0.6 then
        if obj.Radius == obj.Height then
            UpdateSingleNote(obj)
        elseif obj.CFrame.LookVector.Y < 0.1 and obj.Radius > 0.25 then
            UpdateLongNote(obj)
        end
    end
end

local function ConfigTracks()
    local nearestTracks = nil;
    local distLowest = 200000;
    for index, track_pos in ipairs(trackPositions) do
        local dist = (Cam.CFrame.Position - track_pos[2].Position).Magnitude
        if dist < distLowest then
            distLowest = dist
            nearestTracks = track_pos
            playerSlot = index
        end
    end
    if nearestTracks then
        for c = 1, #tracks, 1 do
            tracks[c].CFrame = nearestTracks[c]
            if tracks[c].Presionado then
                tracks[c]:Press(false)
            end
        end
    end
end

local function ReadMusicInfo(songInfoMenu)
    task.wait()
    if songInfoMenu then
        local dspTitle = songInfoMenu.SongTitleDisplay
        local dspArtist = songInfoMenu.ArtistDisplay
        local dspDesc = songInfoMenu.DescriptionBack.TextLabel
        local dspDiff = songInfoMenu.SongDifficultySection.Display
        local imgElem = songInfoMenu.SongPanel.ColorSection.PrimaryColorIcon
        local imgSubElem = songInfoMenu.SongPanel.ColorSection.SecondaryColorIcon
        local imgArt = songInfoMenu.SongPanel.AlbumArt

        local music = {}

        local txtMapStart, mapperStart = dspDesc.Text:find("Map by ")
        if mapperStart then
            music.mapper = dspDesc.Text:sub(mapperStart + 1, dspDesc.Text:len() - 1)
        else
            music.mapper = "Desconocido"
        end

        music.art = imgArt.Image
        music.name = dspTitle.Text:gsub(" %(Easy%)", ""):gsub(" %(Hard%)", "")
        music.artist = dspArtist.Text
        music.diff = dspDiff.Text
        music.desc = dspDesc.Text
        Print("Información de música:")
        Print("Nombre\t" .. music.name)
        Print("Artista\t" .. music.artist)
        Print("Mapper\t" .. music.mapper)
        Print("Dificultad\t" .. music.diff)
    else
        Print("No se pudo leer la información de la música")
    end
end

local function ConfigKey(ctrlPopup)
    task.wait(3)
    local txtKey = ctrlPopup.SurfaceGui.Frame.Letter.Text
    if txtKey ~= "Tap!" then
        local track, distance = GetNearestTrack(ctrlPopup.CFrame.Position)
        if track then
            keys[track.ID] = txtKey
        end
    end
end

local function MatchStarted()
    Print("Inició una partida")
    task.wait(2)
    ConfigTracks()
    inMatch = true
end

local function MatchEnded()
    Print("Terminó una partida")
    inMatch = false
end

local function Destroy()
    Print("Destruyendo")
    for i, v in ipairs(conns) do
        v:Disconnect();
    end
    _G.JYR9MC9P = false
    if script then
        script:Destroy()
    end
end

local function OnDescendantAdded(obj)
    if obj.Name == "RankBar" then
        coroutine.wrap(MatchStarted)()
    end
    if obj.Name == "DescriptionBack" then
        coroutine.wrap(ReadMusicInfo)(obj.Parent)-- Popup.MainSurface.SurfaceGui.Frame
    end
    if obj.Name == "ControlPopup" then
        coroutine.wrap(ConfigKey)(obj)
    end
    if obj.ClassName == "CylinderHandleAdornment" then
        table.insert(conns, obj:GetPropertyChangedSignal("CFrame"):Connect(function()
            if not pause then
                UpdateNotes(obj)
            end
        end))
    end
end

local function OnDescendantRemoved(obj)
    if obj.Name == "RankBar" then
        if inMatch then
            MatchEnded()
        end
    end
end

local function InputBegan(input, gameProcessedEvent)
    local txt = tostring(input.KeyCode)
    if txt:match(Cfg.keyPause) then
        Pause(not pause)
    end
    if txt:match(Cfg.keyDestroy) then
        Destroy()
    end
end

Print("RoBeats Autoplay de @ARLUNOJO")
Print("Iniciando...")

for id = 1, 4, 1 do
    tracks[id] = Track:new(id)
end

table.insert(conns, workspace.DescendantAdded:Connect(OnDescendantAdded))
table.insert(conns, workspace.DescendantRemoving:Connect(OnDescendantRemoved))
table.insert(conns, UserInput.InputBegan:Connect(InputBegan))

for idx, obj in next, workspace:GetDescendants() do
    OnDescendantAdded(obj)
end

_G.JYR9MC9P = true
Print("Listo")
Print("Entra a cualquier música")

return Cfg
-- @ARLUNOJO
