#Requires AutoHotkey v2.0

global lastPos := Map()

Hotkey("#Enter", ToggleWindowPosition)

ToggleWindowPosition(*) {
    hwnd := WinGetID("A")
    if !hwnd
        return

    try {
        ; Aguarda um pouco para garantir que a janela não está em transição
        Sleep(50)

        ; Captura o estado atual da janela
        currentState := WinGetMinMax(hwnd)

        ; Se a janela estiver maximizada ou minimizada, restaura primeiro
        if (currentState != 0) {
            WinRestore(hwnd)
            Sleep(100) ; Aguarda a restauração completar
        }

        ; Aguarda mais um pouco e captura a posição real após possível restauração
        Sleep(50)
        WinGetPos(&x, &y, &w, &h, hwnd)

        if lastPos.Has(hwnd) {
            pos := lastPos[hwnd]

            ; Verifica se a janela ainda está centralizada (com tolerância de 5 pixels)
            tolerance := 5
            if (Abs(x - pos.newX) <= tolerance && Abs(y - pos.newY) <= tolerance && Abs(w - pos.newW) <= tolerance &&
            Abs(h - pos.newH) <= tolerance) {
                ; Restaurar posição original
                WinMove(pos.x, pos.y, pos.w, pos.h, hwnd)
                lastPos.Delete(hwnd)
            } else {
                ; Janela foi movida manualmente — atualiza com a nova posição
                UpdateWindowPosition(hwnd, x, y, w, h)
            }
        } else {
            ; Primeira vez ou janela foi removida do mapa — centraliza
            CenterWindow(hwnd, x, y, w, h)
        }
    } catch Error as e {
        ; Se houver erro, remove da memória para evitar estados inconsistentes
        if lastPos.Has(hwnd) {
            lastPos.Delete(hwnd)
        }
    }
}

; Função para centralizar a janela
CenterWindow(hwnd, currentX, currentY, currentW, currentH) {
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
        x: currentX, y: currentY, w: currentW, h: currentH,
        newX: newX, newY: newY, newW: newW, newH: newH
    }

    WinMove(newX, newY, newW, newH, hwnd)
}

; Função para atualizar a posição da janela no mapa
UpdateWindowPosition(hwnd, currentX, currentY, currentW, currentH) {
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
        x: currentX, y: currentY, w: currentW, h: currentH,
        newX: newX, newY: newY, newW: newW, newH: newH
    }

    WinMove(newX, newY, newW, newH, hwnd)
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

; Função para verificar se uma janela ainda existe e limpar entradas inválidas
CleanupInvalidWindows() {
    toRemove := []
    for hwnd in lastPos {
        if !WinExist("ahk_id " . hwnd) {
            toRemove.Push(hwnd)
        }
    }
    for hwnd in toRemove {
        lastPos.Delete(hwnd)
    }
}

; Executa limpeza periodicamente
SetTimer(CleanupInvalidWindows, 30000) ; A cada 30 segundos
