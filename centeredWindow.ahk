#Requires AutoHotkey v2.0

global lastPos := Map()

Hotkey("#Enter", ToggleWindowPosition)

ToggleWindowPosition(*) {
    hwnd := WinGetID("A")
    if !hwnd
        return

    try {
        WinRestore(hwnd)
        WinGetPos(&x, &y, &w, &h, hwnd)

        if lastPos.Has(hwnd) {
            pos := lastPos[hwnd]

            ; Verifica se a janela ainda está centralizada
            if (x = pos.newX && y = pos.newY && w = pos.newW && h = pos.newH) {
                ; Restaurar posição original
                WinMove(pos.x, pos.y, pos.w, pos.h, hwnd)
                lastPos.Delete(hwnd)
            } else {
                ; Janela foi movida manualmente — atualiza posição salva
                lastPos.Delete(hwnd)
            }
        } else {
            ; Salvar posição atual e centralizar
            screenW := A_ScreenWidth
            screenH := A_ScreenHeight
            newW := screenW * 0.60
            newH := screenH * 0.60
            newX := (screenW - newW) / 2
            newY := (screenH - newH) / 2

            lastPos[hwnd] := {
                x: x, y: y, w: w, h: h,
                newX: newX, newY: newY, newW: newW, newH: newH
            }

            WinMove(newX, newY, newW, newH, hwnd)
        }
    } catch Error as e {
        ; Silencioso, sem TrayTip
    }
}