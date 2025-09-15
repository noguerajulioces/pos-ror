' ============================================================================
' POS-RoR Advanced Invisible Launcher
' Ejecuta el servidor sin ventanas y con manejo robusto de errores
' ============================================================================

Option Explicit

Dim WshShell, fso, scriptPath, batFile, logFile, configFile
Dim projectDir, maxRetries, retryDelay

' Inicializar objetos
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Configuración
scriptPath = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
batFile = scriptPath & "pos-server-manager.bat"
logFile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\POS-RoR-Logs\invisible-launcher.log"
projectDir = "/mnt/c/pos-ror-feature-foot"
maxRetries = 3
retryDelay = 5000 ' 5 segundos

' Crear directorio de logs si no existe
CreateLogDirectory

' Iniciar proceso principal
Main

' ============================================================================
' FUNCIONES PRINCIPALES
' ============================================================================

Sub Main()
    WriteLog "=== POS-RoR Invisible Launcher Iniciado ==="
    
    ' Verificar archivos necesarios
    If Not VerifyFiles() Then
        WriteLog "ERROR: Archivos necesarios no encontrados"
        Exit Sub
    End If
    
    ' Verificar si ya está ejecutándose
    If IsServerRunning() Then
        WriteLog "INFO: Servidor ya está ejecutándose"
        Exit Sub
    End If
    
    ' Intentar iniciar el servidor con reintentos
    Dim attempt
    For attempt = 1 To maxRetries
        WriteLog "INFO: Intento " & attempt & " de " & maxRetries
        
        If StartServer() Then
            WriteLog "SUCCESS: Servidor iniciado correctamente"
            Exit Sub
        Else
            WriteLog "WARNING: Intento " & attempt & " falló"
            If attempt < maxRetries Then
                WriteLog "INFO: Esperando " & (retryDelay/1000) & " segundos antes del siguiente intento"
                WScript.Sleep retryDelay
            End If
        End If
    Next
    
    WriteLog "ERROR: No se pudo iniciar el servidor después de " & maxRetries & " intentos"
End Sub

Function VerifyFiles()
    VerifyFiles = False
    
    ' Verificar que el archivo .bat existe
    If Not fso.FileExists(batFile) Then
        WriteLog "ERROR: Archivo .bat no encontrado: " & batFile
        Exit Function
    End If
    
    ' Verificar WSL disponible
    Dim result
    result = WshShell.Run("wsl.exe --list --quiet", 0, True)
    If result <> 0 Then
        WriteLog "ERROR: WSL no está disponible"
        Exit Function
    End If
    
    VerifyFiles = True
End Function

Function IsServerRunning()
    IsServerRunning = False
    
    Dim result
    result = WshShell.Run("wsl.exe -c ""pgrep -f 'bin/dev|rails server|puma' > /dev/null""", 0, True)
    If result = 0 Then
        IsServerRunning = True
    End If
End Function

Function StartServer()
    StartServer = False
    
    WriteLog "INFO: Ejecutando servidor..."
    
    ' Ejecutar el .bat de forma invisible
    Dim result
    result = WshShell.Run("""" & batFile & """ start", 0, True)
    
    If result = 0 Then
        ' Esperar un momento y verificar que se inició
        WScript.Sleep 3000
        If IsServerRunning() Then
            StartServer = True
        End If
    End If
End Function

Sub CreateLogDirectory()
    Dim logDir
    logDir = WshShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\POS-RoR-Logs"
    
    If Not fso.FolderExists(logDir) Then
        fso.CreateFolder(logDir)
    End If
End Sub

Sub WriteLog(message)
    On Error Resume Next
    
    Dim logFileObj, timestamp
    timestamp = Now()
    
    Set logFileObj = fso.OpenTextFile(logFile, 8, True)
    logFileObj.WriteLine timestamp & " - " & message
    logFileObj.Close
    
    On Error GoTo 0
End Sub
