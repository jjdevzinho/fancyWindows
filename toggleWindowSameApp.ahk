#Requires AutoHotkey v2.0.2
#SingleInstance Force

SetTitleMatchMode(2)

; Variáveis globais para controle das janelas
global selectedIndex := 1 ; Índice da janela selecionada
global windowList := [] ; Lista de janelas do mesmo programa
global lastAppWindow := 0 ; Última janela que teve foco (renomeado para evitar conflito)
global currentAppId := "" ; Identificador da aplicação atual

; Variáveis globais para destaque visual
global highlightGui := ""
global highlightTimer := ""
global currentHighlightedWindow := ""

; Função para alternar para a próxima janela
SwitchToWindowApp(windows, index) {
    if (windows.Length >= index) {
        targetWindow := windows[index]
        ; Verifica se a janela ainda existe antes de tentar ativar
        try {
            if (WinExist(targetWindow)) {
                WinActivate(targetWindow)
            }
        } catch {
            ; Se falhar, tenta encontrar uma janela válida na lista
            for i, window in windows {
                try {
                    if (WinExist(window)) {
                        WinActivate(window)
                        return
                    }
                } catch {
                    continue
                }
            }
        }
    }
}

; Função para obter um identificador único da aplicação
GetAppIdentifier(window) {
    processName := WinGetProcessName(window)
    windowClass := WinGetClass(window)
    windowTitle := WinGetTitle(window)

    ; Para aplicações modernas (UWP/Store apps), tenta obter informações mais específicas
    try {
        ; Tenta obter o caminho completo do executável
        processPath := ProcessGetPath(WinGetPID(window))
        if (processPath != "") {
            ; Para apps UWP/Store, também inclui parte do título para maior especificidade
            if (processPath ~= "ApplicationFrameHost|WWAHost|RuntimeBroker") {
                ; Extrai uma palavra-chave do título para apps UWP
                titleKey := RegExReplace(windowTitle, "^([^\s-]+).*", "$1")
                return processPath . "|" . windowClass . "|" . titleKey
            }
            ; Usa o caminho completo como identificador mais preciso
            return processPath . "|" . windowClass
        }
    }

    ; Para aplicações tradicionais e casos onde não conseguimos o caminho
    ; Também inclui uma parte do título para maior especificidade
    titleKey := RegExReplace(windowTitle, "^([^\s-]+).*", "$1")
    return processName . "|" . windowClass . "|" . titleKey
}

; Função para verificar se duas janelas pertencem ao mesmo aplicativo
IsSameApplication(window1, window2) {
    return GetAppIdentifier(window1) == GetAppIdentifier(window2)
}

; Função para alternar entre janelas do mesmo programa
SwitchWindowSameApp() {
    global lastAppWindow, selectedIndex, windowList, currentAppId

    activeWindow := WinExist("A") ; Obtém a janela ativa
    if (!activeWindow) {
        return
    }

    ; Obtém o identificador único da aplicação ativa
    activeAppId := GetAppIdentifier(activeWindow)

    ; Lista de janelas da mesma aplicação
    sameAppWindows := []
    for window in WinGetList() {
        try {
            ; Verifica se a janela ainda existe e tem título
            if (WinExist(window)) {
                windowTitle := WinGetTitle(window)

                ; Verifica se é realmente a mesma aplicação e tem título
                if (windowTitle != "" && IsSameApplication(activeWindow, window)) {
                    sameAppWindows.Push(window)
                }
            }
        } catch {
            ; Se houver erro ao acessar a janela, pula para a próxima
            continue
        }
    }

    ; Se houver apenas uma janela do mesmo programa, não faz nada
    if (sameAppWindows.Length <= 1) {
        return
    }

    ; Se mudou de programa ou é primeira chamada, reinicia a lista
    if (activeAppId != currentAppId || !windowList.Length) {
        ; Reorganiza a lista começando com a janela atual
        windowList := [activeWindow]
        for window in sameAppWindows {
            if (window != activeWindow) {
                windowList.Push(window)
            }
        }
        selectedIndex := 2 ; Começa com a segunda janela
        currentAppId := activeAppId
        lastAppWindow := activeWindow
    } else {
        ; Avança para a próxima janela
        selectedIndex++
        if (selectedIndex > windowList.Length) {
            selectedIndex := 1
        }
    }

    ; Filtra janelas inválidas da lista antes de ativar
    validWindows := []
    for window in windowList {
        try {
            if (WinExist(window)) {
                validWindows.Push(window)
            }
        } catch {
            continue
        }
    }

    ; Se não há janelas válidas, abandona
    if (!validWindows.Length) {
        return
    }

    ; Ajusta o índice se necessário
    if (selectedIndex > validWindows.Length) {
        selectedIndex := 1
    }

    ; Ativa a janela selecionada
    SwitchToWindowApp(validWindows, selectedIndex)
}

; Função chamada quando Win é solto
WinReleased() {
    global selectedIndex, windowList, lastAppWindow, currentAppId

    ; Reseta as variáveis
    selectedIndex := 1
    windowList := []
    lastAppWindow := 0
    currentAppId := ""
}

; Atalho para alternar janelas do mesmo programa
$#sc029:: SwitchWindowSameApp() ; Win + ` posição física, tecla acima do tab, independente do símbolo do seu layout
~LWin Up:: WinReleased() ; Reseta quando Win é solto
~RWin Up:: WinReleased() ; Reseta quando Win direito é solto
