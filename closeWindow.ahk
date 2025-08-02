#Requires AutoHotkey v2.0

; Atalho Win + Q para fechar a janela ativa
#q:: {
    hwnd := WinActive("A")
    winTitle := WinGetTitle(hwnd)
    ; processName := WinGetProcessName(hwnd)
    ; winTitle := RegExReplace(processName, "\.exe$", "", , 1)
    result := MsgBox("Deseja fechar a janela atual: '" winTitle "'?", "Confirmação", "OKCancel")
    if (result = "OK")
        Send("{Alt down}{F4}{Alt up}") ; Envia o comando Alt + F4
}
