#Requires AutoHotkey v2.0.2
#SingleInstance Force

SetTitleMatchMode(2)

; Margem de erro para comparação de posições (em pixels)
MARGIN_ERROR := 30

; Variáveis globais para controle das janelas
global selectedIndex := 1 ; Índice da janela selecionada
global windowList := [] ; Lista de janelas na região atual
global lastZoneWindow := 0 ; Última janela que teve foco na zona (renomeado para evitar conflito)

; Função para alternar para a próxima janela
SwitchToWindow(windows, index) {
    if (windows.Length >= index) {
        WinActivate(windows[index])
    }
}

; Função para alternar entre janelas na mesma região
SwitchWindowInSameZone() {
    global lastZoneWindow, selectedIndex, windowList

    activeWindow := WinExist("A") ; Obtém a janela ativa
    if (!activeWindow) {
        return
    }

    ; Obtém a posição da janela ativa
    WinGetPos(&activeX, &activeY, &activeW, &activeH, activeWindow)

    ; Lista de janelas visíveis na mesma região
    visibleWindows := []
    for window in WinGetList() {
        WinGetPos(&x, &y, &w, &h, window)
        if (IsWindowInSameZone(activeX, activeY, activeW, activeH, x, y, w, h)) {
            visibleWindows.Push(window)
        }
    }

    ; Se não houver outras janelas na mesma região, não faz nada
    if (visibleWindows.Length <= 1) {
        return
    }

    ; Se for a primeira chamada, inicia com a segunda janela
    if (!windowList.Length) {
        ; Reorganiza a lista começando com a janela atual
        windowList := [activeWindow]
        for window in visibleWindows {
            if (window != activeWindow) {
                windowList.Push(window)
            }
        }
        selectedIndex := 2 ; Começa com a segunda janela
        lastZoneWindow := activeWindow
    } else {
        ; Avança para a próxima janela
        selectedIndex++
        if (selectedIndex > windowList.Length) {
            selectedIndex := 1
        }
    }

    ; Ativa a janela selecionada
    SwitchToWindow(windowList, selectedIndex)
}

; Função para verificar se uma janela está na mesma área
IsWindowInSameZone(x1, y1, w1, h1, x2, y2, w2, h2) {
    global MARGIN_ERROR
    return (Abs(x1 - x2) <= MARGIN_ERROR &&
    Abs(y1 - y2) <= MARGIN_ERROR &&
    Abs(w1 - w2) <= MARGIN_ERROR &&
    Abs(h1 - h2) <= MARGIN_ERROR)
}

; Função chamada quando Alt é solto
ZoneAltReleased() {
    global selectedIndex, windowList, lastZoneWindow

    ; Reseta as variáveis
    selectedIndex := 1
    windowList := []
    lastZoneWindow := 0
}

; Atalhos para alternar janelas na mesma região
$!sc029:: SwitchWindowInSameZone() ; Alt + ` posição física, tecla acima do tab, independente do símbolo do seu layout
~LAlt Up:: ZoneAltReleased() ; Reseta quando Alt é solto
