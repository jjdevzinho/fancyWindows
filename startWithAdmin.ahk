#Requires AutoHotkey v2.0.2

; Modo admin, remova se não precisar gerenciar janelas com privilégios elevados
if !A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

#Include globalFocusBorder.ahk

#Include focusZone.ahk

; Falha quando usa globalFocusBorderFixed.ahk
#Include toggleWindowSameZone.ahk

#Include toggleWindowSameApp.ahk

#Include maxRestoreWindow.ahk
#Include maxMinWindow.ahk

#Include closeWindow.ahk
#Include centeredWindow.ahk