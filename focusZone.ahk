#Requires AutoHotkey v2.0.2

SetTitleMatchMode(2)

; Margem de erro para comparação de posições (em pixels)
MARGIN_ERROR := 30

; Função para obter janelas visíveis e não minimizadas
GetVisibleWindows() {
    visibleWindows := []
    activeWindow := WinExist("A") ; Obtém o handle da janela ativa
    for window in WinGetList() {
        style := WinGetStyle(window)
        exStyle := WinGetExStyle(window)
        title := WinGetTitle(window)
        class := WinGetClass(window)
        if (style & 0x10000000) && !(style & 0x20000000) { ; WS_VISIBLE && !WS_MINIMIZE
            if (title != "" && title != "Program Manager" && class != "NotifyIconOverflowWindow" && !(exStyle &
                0x00000080) && !(exStyle & 0x08000000)) {
                visibleWindows.Push(window)
            }
        }
    }
    return visibleWindows
}

; Função para verificar se uma janela está na mesma área
IsWindowInSameArea(x1, y1, w1, h1, x2, y2, w2, h2) {
    global MARGIN_ERROR
    return (Abs(x1 - x2) <= MARGIN_ERROR &&
    Abs(y1 - y2) <= MARGIN_ERROR &&
    Abs(w1 - w2) <= MARGIN_ERROR &&
    Abs(h1 - h2) <= MARGIN_ERROR)
}

; Função para obter a janela com maior z-index em uma posição específica
GetHighestZWindowAtPosition(targetX, targetY, targetW, targetH) {
    for window in WinGetList() {
        WinGetPos(&x, &y, &w, &h, window)
        if (IsWindowInSameArea(x, y, w, h, targetX, targetY, targetW, targetH)) {
            return window
        }
    }
    return ""
}

; Função para alternar para a janela ao lado (direita ou esquerda)
SwitchToAdjacentWindow(direction) {
    visibleWindows := GetVisibleWindows()
    if (visibleWindows.Length > 0) {
        activeWindow := WinExist("A")
        if (!activeWindow) {
            return
        }
        WinGetPos(&activeX, &activeY, &activeW, &activeH, activeWindow)
        closestWindow := ""
        closestDistance := 99999
        bestAlignment := 99999

        for window in visibleWindows {
            if (window != activeWindow) {
                WinGetPos(&x, &y, &w, &h, window)

                ; Calcula o centro das janelas
                activeWindowCenterY := activeY + (activeH / 2)
                activeWindowCenterX := activeX + (activeW / 2)
                targetWindowCenterY := y + (h / 2)
                targetWindowCenterX := x + (w / 2)

                ; Margem de erro maior para alinhamento
                heightMargin := activeH * 0.7 ; 70% da altura da janela atual
                widthMargin := activeW * 0.7 ; 70% da largura da janela atual

                if (direction = "right" && x > activeX + activeW / 2) {
                    distance := x - (activeX + activeW)
                    ; Verifica se está aproximadamente na mesma altura
                    if (Abs(targetWindowCenterY - activeWindowCenterY) < heightMargin) {
                        if (distance < closestDistance || (distance = closestDistance && Abs(targetWindowCenterY -
                            activeWindowCenterY) < bestAlignment)) {
                            closestDistance := distance
                            bestAlignment := Abs(targetWindowCenterY - activeWindowCenterY)
                            closestWindow := window
                        }
                    }
                }
                else if (direction = "left" && x + w < activeX + activeW / 2) {
                    distance := activeX - (x + w)
                    ; Verifica se está aproximadamente na mesma altura
                    if (Abs(targetWindowCenterY - activeWindowCenterY) < heightMargin) {
                        if (distance < closestDistance || (distance = closestDistance && Abs(targetWindowCenterY -
                            activeWindowCenterY) < bestAlignment)) {
                            closestDistance := distance
                            bestAlignment := Abs(targetWindowCenterY - activeWindowCenterY)
                            closestWindow := window
                        }
                    }
                }
                else if (direction = "up" && y + h < activeY + activeH / 2) {
                    distance := activeY - (y + h)
                    ; Verifica se está aproximadamente na mesma linha vertical
                    if (Abs(targetWindowCenterX - activeWindowCenterX) < widthMargin) {
                        if (distance < closestDistance || (distance = closestDistance && Abs(targetWindowCenterX -
                            activeWindowCenterX) < bestAlignment)) {
                            closestDistance := distance
                            bestAlignment := Abs(targetWindowCenterX - activeWindowCenterX)
                            closestWindow := window
                        }
                    }
                }
                else if (direction = "down" && y > activeY + activeH / 2) {
                    distance := y - (activeY + activeH)
                    ; Verifica se está aproximadamente na mesma linha vertical
                    if (Abs(targetWindowCenterX - activeWindowCenterX) < widthMargin) {
                        if (distance < closestDistance || (distance = closestDistance && Abs(targetWindowCenterX -
                            activeWindowCenterX) < bestAlignment)) {
                            closestDistance := distance
                            bestAlignment := Abs(targetWindowCenterX - activeWindowCenterX)
                            closestWindow := window
                        }
                    }
                }
            }
        }

        if (closestWindow) {
            WinGetPos(&closestX, &closestY, &closestW, &closestH, closestWindow)
            highestZWindow := GetHighestZWindowAtPosition(closestX, closestY, closestW, closestH)
            if (highestZWindow) {
                WinActivate(highestZWindow)
            }
        }
    }
}

; Atalhos para alternar entre janelas adjacentes
#+Right:: SwitchToAdjacentWindow("right") ; Win + Shift + Right
#+Left:: SwitchToAdjacentWindow("left") ; Win + Shift + Left
#+Up:: SwitchToAdjacentWindow("up") ; Win + Shift + Up
#+Down:: SwitchToAdjacentWindow("down") ; Win + Shift + Down
