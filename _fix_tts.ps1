param()

$root = "d:\Flutter_2025\Arabic Alphabet\arabic_learning_app"

function Process-File {
    param(
        [string]$relPath,
        [string]$flagAfterLine,     # trimmed text of line AFTER which to add flag
        [string]$methodStartLine,   # trimmed text of the method declaration
        [string]$flagDecl           # the flag declaration line to add
    )
    
    $fullPath = Join-Path $root $relPath
    $content = [System.IO.File]::ReadAllText($fullPath)
    $lines = $content -split "`r?`n"
    $output = [System.Collections.ArrayList]::new()
    $flagAdded = $false
    $state = "normal"  # normal, in_method, skip_delayed, skip_if_mounted, in_speak, after_speak
    $braceDepth = 0
    $methodBraceStart = 0
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $trimmed = $line.Trim()
        
        # Add flag after designated line (if flagAfterLine is not empty)
        if (-not $flagAdded -and $flagAfterLine -ne "" -and $trimmed -eq $flagAfterLine) {
            [void]$output.Add($line)
            [void]$output.Add($flagDecl)
            $flagAdded = $true
            continue
        }
        
        if ($state -eq "normal") {
            # Detect the method we want to fix
            if ($trimmed -eq $methodStartLine) {
                # Check if next line has Future.delayed
                $nextTrimmed = if ($i + 1 -lt $lines.Count) { $lines[$i+1].Trim() } else { "" }
                if ($nextTrimmed -match "Future\.delayed") {
                    $state = "in_method"
                    [void]$output.Add($line)
                    # Add guard lines
                    if ($flagDecl -ne "") {
                        [void]$output.Add("    if (_hasPlayedIntro) return;")
                        [void]$output.Add("    _hasPlayedIntro = true;")
                    }
                    continue
                }
            }
            [void]$output.Add($line)
        }
        elseif ($state -eq "in_method") {
            # Skip the Future.delayed line
            if ($trimmed -match "Future\.delayed") {
                continue
            }
            # Skip "if (mounted) {"
            if ($trimmed -eq "if (mounted) {") {
                continue
            }
            # Replace .speak( with .speakScreenIntro(
            if ($line -match "AppTtsService\.instance\.speak\(") {
                $newLine = $line -replace "AppTtsService\.instance\.speak\(", "AppTtsService.instance.speakScreenIntro("
                [void]$output.Add($newLine)
                $state = "in_speak"
                continue
            }
            [void]$output.Add($line)
        }
        elseif ($state -eq "in_speak") {
            # We're inside the speakScreenIntro call arguments
            # Look for the closing ");"
            if ($trimmed -eq ");") {
                # Add isMounted parameter before closing
                # Determine indentation from the line
                $indent = $line -replace "\S.*$", ""
                [void]$output.Add("${indent}isMounted: () => mounted,")
                [void]$output.Add($line)
                $state = "after_speak"
                continue
            }
            [void]$output.Add($line)
        }
        elseif ($state -eq "after_speak") {
            # We expect either "}" (from if(mounted)) then "}" (method close)
            # or just "}" (method close)
            if ($trimmed -eq "}") {
                # Check if next non-empty line is also "}"
                $nextIdx = $i + 1
                while ($nextIdx -lt $lines.Count -and $lines[$nextIdx].Trim() -eq "") {
                    $nextIdx++
                }
                if ($nextIdx -lt $lines.Count -and $lines[$nextIdx].Trim() -eq "}") {
                    # This is the if(mounted) close, skip it; next one is method close
                    continue
                }
                # This is the method close
                [void]$output.Add($line)
                $state = "normal"
                continue
            }
            [void]$output.Add($line)
        }
    }
    
    # Detect original line ending
    $lineEnding = if ($content.Contains("`r`n")) { "`r`n" } else { "`n" }
    $result = $output -join $lineEnding
    # Ensure file ends with newline
    if (-not $result.EndsWith($lineEnding)) {
        $result += $lineEnding
    }
    [System.IO.File]::WriteAllText($fullPath, $result)
    Write-Host "OK: $relPath"
}

# 1. writing_practice_view_body.dart
Process-File `
    "lib\features\writing_practice\presentation\views\widgets\writing_practice_view_body.dart" `
    "List<int> _unlockedLetters = [0];" `
    "Future<void> _initInstructionTts() async {" `
    "  bool _hasPlayedIntro = false;"

# 2. word_training_view_body.dart
Process-File `
    "lib\features\word_training\presentation\views\widgets\word_training_view_body.dart" `
    "bool _isPlaying = false;" `
    "Future<void> _initInstructionTts() async {" `
    "  bool _hasPlayedIntro = false;"

# 3. word_search_view_body.dart
Process-File `
    "lib\features\word_search\presentation\views\widgets\word_search_view_body.dart" `
    "bool isDragging = false;" `
    "Future<void> _initInstructionTts() async {" `
    "  bool _hasPlayedIntro = false;"

# 4. memory_game_view_body.dart  
Process-File `
    "lib\features\memory_game\presentation\views\widgets\memory_game_view_body.dart" `
    "int totalPairs = 6;" `
    "Future<void> _initInstructionTts() async {" `
    "  bool _hasPlayedIntro = false;"

# 5. pronunciation_practice_view_body.dart  
Process-File `
    "lib\features\pronunciation_practice\presentation\views\widgets\pronunciation_practice_view_body.dart" `
    "int _totalAttempts = 0;" `
    "Future<void> _initInstructionTts() async {" `
    "  bool _hasPlayedIntro = false;"

# 6. svg_letter_tracing_view.dart
Process-File `
    "lib\features\letter_tracing\presentation\views\svg_letter_tracing_view.dart" `
    "final double touchTolerance = 40.0;" `
    "Future<void> _initInstructionTts() async {" `
    "  bool _hasPlayedIntro = false;"

# 7. automated_letter_trace_screen.dart
Process-File `
    "lib\features\writing_practice\presentation\views\widgets\automated_letter_trace_screen.dart" `
    "bool _isInteractingWithBoard = false;" `
    "Future<void> _playIntro() async {" `
    "  bool _hasPlayedIntro = false;"

# 8. svg_number_tracing_view.dart
Process-File `
    "lib\features\math\presentation\views\svg_number_tracing_view.dart" `
    "final double touchTolerance = 40.0;" `
    "Future<void> _speakIntro() async {" `
    "  bool _hasPlayedIntro = false;"

# 9. number_ordering_view.dart
Process-File `
    "lib\features\math\presentation\views\number_ordering_view.dart" `
    "_initRound();" `
    "Future<void> _playIntro() async {" `
    "  bool _hasPlayedIntro = false;"

Write-Host "`nAll done!"
