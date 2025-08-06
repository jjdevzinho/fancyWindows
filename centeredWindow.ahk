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

            ; Verifica se a janela ainda está centralizada (com tolerância de 2 pixels)
            tolerance := 2
            if (Abs(x - pos.newX) <= tolerance && Abs(y - pos.newY) <= tolerance && Abs(w - pos.newW) <= tolerance &&
            Abs(h - pos.newH) <= tolerance) {
                ; Restaurar posição original
                WinMove(pos.x, pos.y, pos.w, pos.h, hwnd)
                lastPos.Delete(hwnd)
            } else {
                ; Janela foi movida manualmente — remove da memória
                lastPos.Delete(hwnd)
            }
        } else {
            ; Obter informações do monitor atual onde a janela está
            monitorIndex := GetMonitorFromWindow(hwnd)
            MonitorGetWorkArea(monitorIndex, &monLeft, &monTop, &monRight, &monBottom)

            screenW := monRight - monLeft
            screenH := monBottom - monTop
            newW := Round(screenW * 0.60)
            newH := Round(screenH * 0.60)
            newX := Round(monLeft + (screenW - newW) / 2)
            newY := Round(monTop + (screenH - newH) / 2)

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

; Função para obter o monitor onde a janela está localizada
GetMonitorFromWindow(hwnd) {
    WinGetPos(&x, &y, &w, &h, hwnd)
    centerX := x + w / 2
    centerY := y + h / 2

    ; Procura em qual monitor o centro da janela está
    monitorCount := MonitorGetCount()
    loop monitorCount {
        MonitorGetWorkArea(A_Index, &left, &top, &right, &bottom)
        if (centerX >= left && centerX <= right && centerY >= top && centerY <= bottom) {
            return A_Index
        }
    }

    ; Se não encontrar, retorna o monitor primário
    return MonitorGetPrimary()
}
