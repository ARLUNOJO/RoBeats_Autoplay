# RoBeats Autoplay
Script Luau para que RoBeats se juegue automáticamente :yo_cuando:
# Uso
Simplemente corre el script en tu executor de preferencia
```luau
-- RoBeats Autoplay de @ARLUNOJO
-- Configura el autoplay aquí:
local Cfg = {
    -- Tecla para pausar y reanudar el autoplay
    keyPause = "PageDown"
    , -- Tecla para destruir el script
    keyDestroy = "End"
    , -- Indica si se jugará con la mejor precisión posible (lo que permitan tus fps) [true - false]
    superAccuracy = false
    , -- Imprimir registros en consola [true - false]
    logs = true
    , -- [Limites de aleatoriedad y hit box para tocar notas, en roblox studs en relación a la posición de los receptores de notas. Afecta la presición]
    limUpper = 3.25,
    limBottom = -1.40
    , -- [Retrasos al simular presionar teclas, en segundos]
    keyDelayMax = 0.026,
    keyDelayMin = 0.007
}
-- Fin
loadstring(game:HttpGet("https://raw.githubusercontent.com/ARLUNOJO/RoBeats_Autoplay/refs/heads/main/AutoPlay.luau"))(Cfg)
```
Pon cualquier música y se jugará automáticamente
