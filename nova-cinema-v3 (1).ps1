# ============================================================
# NOVA CINEMA TERMINAL AI  —  v2.1
# Absolute-cinema futuristic UI + no-auth AI providers + SFX
# Providers: Pollinations.ai + LLM7.io
# Default display model: gpt-5-nano
# ============================================================
Clear-Host
try {
    $host.UI.RawUI.WindowTitle = "NOVA // CINEMA MODE v2"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "White"
}
catch {}
# ------------------------------
# STATE
# ------------------------------
$script:botName        = "NOVA"
$script:provider        = "pollinations"
$script:model           = "gpt-5-nano"
$script:memory          = @()
$script:chatLog         = @()
$script:maxMemoryPairs  = 6
$script:maxLogLines     = 10
$script:typeDelay       = 2
$script:theme           = "aurora"
$script:ESC             = [char]27
$script:lastModelPicks  = @()   # cache for /pick N after a /models listing
$script:animateUI       = $true # animated bars/header sweeps toggle
$script:soundUI         = $true # sound effects toggle
$script:apiKeys         = @{ pollinations = ""; llm7 = "" }  # user-supplied auth keys, blank = no-auth mode
$script:useAuth         = @{ pollinations = $false; llm7 = $false }  # whether to send the key for that provider
$script:imageOutDir     = Join-Path (Get-Location) "nova-images"  # where /image saves generated art
$script:rainbowTick     = 0.0  # advances every rainbow-aware draw so hues keep drifting across the session
$script:themes = @{
    bloxd = @{
        pink="#ff17d5"; purple="#a10084"; cyan="#00b8ff"; cyan2="#16e9ff"
        blue="#005a85"; gold="#ffbd2a";  red="#ff0058";  green="#21ffb5"
        dim="#6f7f8f";  white="#ffffff"; dark="#222222"; auraA="#bf179b"; auraB="#00bcf5"
    }
    void = @{
        pink="#c77dff"; purple="#7b2cbf"; cyan="#80ffdb"; cyan2="#64dfdf"
        blue="#5390d9"; gold="#ffd166";  red="#ef476f";  green="#06d6a0"
        dim="#8d99ae";  white="#ffffff"; dark="#1b1b2f"; auraA="#c77dff"; auraB="#80ffdb"
    }
    blood = @{
        pink="#ff0058"; purple="#7a001f"; cyan="#ff758f"; cyan2="#ff4d6d"
        blue="#590d22"; gold="#ffbd2a";  red="#ff0058";  green="#ffccd5"
        dim="#9d8189";  white="#ffffff"; dark="#240000"; auraA="#ff0058"; auraB="#ff758f"
    }
    ice = @{
        pink="#90e0ef"; purple="#0077b6"; cyan="#00b4d8"; cyan2="#caf0f8"
        blue="#023e8a"; gold="#ffffff";  red="#48cae4";  green="#ade8f4"
        dim="#8ecae6";  white="#ffffff"; dark="#001219"; auraA="#00b4d8"; auraB="#caf0f8"
    }
    solar = @{
        pink="#ff9e00"; purple="#9d4edd"; cyan="#ffca3a"; cyan2="#ffd60a"
        blue="#6a4c93"; gold="#ffb703";  red="#fb5607";  green="#8ac926"
        dim="#a68a64";  white="#fff3e0"; dark="#1a1200"; auraA="#ff9e00"; auraB="#ffd60a"
    }
    neon = @{
        pink="#ff00ff"; purple="#9d00ff"; cyan="#00ffff"; cyan2="#0aefff"
        blue="#0033ff"; gold="#faff00";  red="#ff0055";  green="#39ff14"
        dim="#5c5c7a";  white="#f5f5ff"; dark="#0d0221"; auraA="#ff00ff"; auraB="#39ff14"
    }
    aurora = @{
        pink="#ff61d2"; purple="#8a2be2"; cyan="#00ffc8"; cyan2="#37ffe0"
        blue="#2b6cff"; gold="#c8ff00";  red="#ff3d7f";  green="#00ff9c"
        dim="#4a5b6a";  white="#eafff9"; dark="#020617"; auraA="#00ff9c"; auraB="#8a2be2"
        rgbCycle=$true
    }
}
# ------------------------------
# MODEL CATALOG (expanded, no-auth / anonymous friendly)
# cat  : chat | code | vision | reasoning | roleplay
# tag  : free | rate-limited | paid
# ------------------------------
$script:noAuthModels = @{
    pollinations = @(
        @{ name="gpt-5-nano";        api="openai-fast";     cat="chat";      tag="free";         note="Default cinematic alias -> openai-fast" }
        @{ name="openai-fast";       api="openai-fast";     cat="chat";      tag="free";         note="Fast anonymous GPT-class model" }
        @{ name="openai";            api="openai";          cat="chat";      tag="free";         note="Standard OpenAI-compatible chat model" }
        @{ name="openai-large";      api="openai-large";    cat="chat";      tag="rate-limited"; note="Larger OpenAI-class model, heavier queue" }
        @{ name="gpt-oss";           api="openai-fast";     cat="chat";      tag="free";         note="Open alias mapped to openai-fast" }
        @{ name="gpt-oss-20b";       api="openai-fast";     cat="chat";      tag="free";         note="Open alias mapped to openai-fast" }
        @{ name="mistral";           api="mistral";         cat="chat";      tag="free";         note="Mistral general purpose chat model" }
        @{ name="mistral-large";     api="mistral-large";   cat="reasoning"; tag="rate-limited"; note="Premium multilingual reasoning model" }
        @{ name="deepseek";          api="deepseek";        cat="chat";      tag="free";         note="DeepSeek V3-class flash model" }
        @{ name="deepseek-pro";      api="deepseek-pro";    cat="reasoning"; tag="rate-limited"; note="Deeper DeepSeek reasoning variant" }
        @{ name="glm";               api="glm";             cat="reasoning"; tag="free";         note="Z.ai GLM long-context agentic model" }
        @{ name="qwen-coder-large";  api="qwen-coder-large";cat="code";      tag="free";         note="Qwen3 Coder for code generation" }
        @{ name="qwen-large";        api="qwen-large";      cat="chat";      tag="free";         note="Qwen flagship MoE chat model" }
        @{ name="qwen-vision";       api="qwen-vision";     cat="vision";    tag="free";         note="Vision-language reasoning model" }
        @{ name="kimi";              api="kimi";            cat="reasoning"; tag="free";         note="Moonshot Kimi agentic CoT model" }
        @{ name="nova-fast";         api="nova-fast";       cat="chat";      tag="free";         note="Ultra-fast, ultra-cheap Nova Micro" }
        @{ name="nova";              api="nova";            cat="reasoning"; tag="free";         note="Nova Lite, 1M context + reasoning" }
        @{ name="minimax";           api="minimax";         cat="code";      tag="free";         note="MiniMax coding & agentic model" }
        @{ name="gemini";            api="gemini";          cat="chat";      tag="rate-limited"; note="Gemini flash-class model" }
        @{ name="ovh-reasoning";     api="openai-fast";     cat="reasoning"; tag="free";         note="Reasoning-flavored no-auth alias" }
    )
    llm7 = @(
        @{ name="default";                                 api="default";                                 cat="chat";      tag="free"; note="Anonymous default router" }
        @{ name="fast";                                     api="fast";                                     cat="chat";      tag="free"; note="Anonymous fast router" }
        @{ name="gpt-4.1-nano-2025-04-14";                  api="gpt-4.1-nano-2025-04-14";                  cat="chat";      tag="free"; note="OpenAI-class nano, text+image" }
        @{ name="gpt-4o-mini-2024-07-18";                   api="gpt-4o-mini-2024-07-18";                   cat="chat";      tag="free"; note="GPT-4o mini, text+image" }
        @{ name="gpt-o4-mini-2025-04-16";                   api="gpt-o4-mini-2025-04-16";                   cat="reasoning"; tag="free"; note="o4-mini reasoning, text+image" }
        @{ name="deepseek-r1-0528";                         api="deepseek-r1-0528";                         cat="reasoning"; tag="free"; note="DeepSeek R1 reasoning model" }
        @{ name="deepseek-v3-0324";                         api="deepseek-v3-0324";                         cat="chat";      tag="free"; note="DeepSeek V3 general chat model" }
        @{ name="gemini-2.5-flash-lite";                    api="gemini-2.5-flash-lite";                    cat="vision";    tag="free"; note="Gemini flash-lite, text+vision" }
        @{ name="qwen2.5-coder-32b-instruct";                api="qwen2.5-coder-32b-instruct";                cat="code";      tag="free"; note="Qwen2.5 Coder 32B for code tasks" }
        @{ name="mistral-small-3.1-24b-instruct-2503";      api="mistral-small-3.1-24b-instruct-2503";      cat="chat";      tag="free"; note="Mistral Small 24B instruct model" }
        @{ name="codestral-latest";                         api="codestral-latest";                         cat="code";      tag="rate-limited"; note="Anonymous turbo coding model" }
        @{ name="devstral-small-2:24b";                     api="devstral-small-2:24b";                     cat="code";      tag="rate-limited"; note="Anonymous dev-focused model" }
        @{ name="l3-70b-euryale-v2.1";                      api="l3-70b-euryale-v2.1";                      cat="roleplay";  tag="free"; note="Llama3 70B roleplay-tuned model" }
        @{ name="midnight-rose-70b-v2.0.3";                 api="midnight-rose-70b-v2.0.3";                 cat="roleplay";  tag="free"; note="Creative writing / roleplay model" }
        @{ name="rtist";                                     api="rtist";                                     cat="chat";      tag="free"; note="Community creative chat persona" }
        @{ name="mirexa";                                    api="mirexa";                                    cat="vision";    tag="free"; note="Mirexa text+image assistant" }
    )
}
# ------------------------------
# AUTH MODEL CATALOG (require a personal API key from each provider)
# Pollinations keys: enter.pollinations.ai   //   LLM7 tokens: dash.llm7.io
# These models are paid/premium/gated behind an account balance or Pro plan.
# ------------------------------
$script:authModels = @{
    pollinations = @(
        @{ name="gpt-5.4";           api="gpt-5.4";           cat="chat";      tag="paid"; note="Flagship GPT-5.4, requires Pollinations API key" }
        @{ name="gpt-5.4-mini";      api="gpt-5.4-mini";      cat="chat";      tag="paid"; note="Smaller GPT-5.4, requires Pollinations API key" }
        @{ name="claude";            api="claude";            cat="chat";      tag="paid"; note="Claude Sonnet class, requires Pollinations API key" }
        @{ name="claude-sonnet-5";   api="claude-sonnet-5";   cat="reasoning"; tag="paid"; note="Claude Sonnet 5, requires Pollinations API key" }
        @{ name="claude-opus-4.6";   api="claude-opus-4.6";   cat="reasoning"; tag="paid"; note="Claude Opus 4.6, most intelligent, tools" }
        @{ name="claude-opus-4.7";   api="claude-opus-4.7";   cat="reasoning"; tag="paid"; note="Claude Opus 4.7, most intelligent, tools" }
        @{ name="claude-large";      api="claude-large";      cat="reasoning"; tag="paid"; note="Claude Opus large alias, requires API key" }
        @{ name="gemini-large";      api="gemini-large";      cat="reasoning"; tag="paid"; note="Gemini 3.1 Pro, 1M context, tools+search" }
        @{ name="gemini-3-flash";    api="gemini-3-flash";    cat="chat";      tag="paid"; note="Gemini 3 Flash, requires Pollinations API key" }
        @{ name="grok";              api="grok";              cat="chat";      tag="paid"; note="xAI Grok, requires Pollinations API key" }
        @{ name="grok-large";        api="grok-large";        cat="reasoning"; tag="paid"; note="xAI Grok large variant, requires API key" }
        @{ name="grok-4-20-reasoning"; api="grok-4-20-reasoning"; cat="reasoning"; tag="paid"; note="xAI Grok 4 reasoning mode, requires API key" }
        @{ name="perplexity";        api="perplexity";        cat="reasoning"; tag="paid"; note="Perplexity Sonar with web search, requires API key" }
        @{ name="perplexity-fast";   api="perplexity-fast";   cat="reasoning"; tag="paid"; note="Perplexity Sonar fast, web search, requires API key" }
        @{ name="perplexity-reasoning"; api="perplexity-reasoning"; cat="reasoning"; tag="paid"; note="Perplexity advanced reasoning + search" }
        @{ name="kimi-code";         api="kimi-code";         cat="code";      tag="paid"; note="Moonshot Kimi coding variant, requires API key" }
        @{ name="minimax-m2.7";      api="minimax-m2.7";      cat="code";      tag="paid"; note="MiniMax M2.7, requires Pollinations API key" }
        @{ name="llama-maverick";    api="llama-maverick";    cat="chat";      tag="paid"; note="Meta Llama 4 Maverick, requires API key" }
        @{ name="llama-large";       api="llama";             cat="chat";      tag="paid"; note="Meta Llama flagship, requires API key" }
        @{ name="polly";             api="polly";             cat="code";      tag="paid"; note="Pollinations AI assistant, code+web tools (alpha)" }
    )
    llm7 = @(
        @{ name="pro";               api="pro";               cat="chat";      tag="paid"; note="LLM7 Pro router, requires dash.llm7.io token + Pro plan" }
        @{ name="gpt-4o";            api="gpt-4o";            cat="chat";      tag="paid"; note="Full GPT-4o, higher-tier token recommended" }
        @{ name="deepseek-r1";       api="deepseek-r1";       cat="reasoning"; tag="paid"; note="DeepSeek R1 full model, token recommended" }
        @{ name="qwen3-235b";        api="qwen3-235b";        cat="reasoning"; tag="paid"; note="Qwen3 235B flagship, token recommended" }
        @{ name="l3.3-ms-nevoria-70b"; api="l3.3-ms-nevoria-70b"; cat="roleplay"; tag="paid"; note="Llama 3.3 70B roleplay tune, token recommended" }
        @{ name="l3-8b-stheno-v3.2"; api="l3-8b-stheno-v3.2"; cat="roleplay";  tag="paid"; note="Llama3 8B roleplay tune, token recommended" }
        @{ name="gemma-2-2b-it";     api="gemma-2-2b-it";     cat="chat";      tag="paid"; note="Google Gemma 2 2B instruct, token recommended" }
        @{ name="open-mixtral-8x7b"; api="open-mixtral-8x7b"; cat="chat";      tag="paid"; note="Mixtral 8x7B MoE, token recommended for stability" }
    )
}
# ------------------------------
# SYSTEM PROMPT
# NOVA's full system prompt is the "NOVA Fable 5" doc (a relabeled adaptation
# of an Anthropic-style Claude system prompt, with Claude->NOVA and
# Anthropic->Nexus throughout) stored alongside this script. It's large
# (~185KB) and written for a JSON chat-completions body, so it's used as-is
# for LLM7 (POST, no length limit). Pollinations' no-auth endpoint is a GET
# request with the whole prompt URL-encoded into the path, so a ~185KB prompt
# would blow past URL length limits and fail outright; Pollinations instead
# gets a condensed version carrying the same core rules in a fraction of the
# size. If the full file can't be found or read, both providers fall back to
# the condensed prompt so NOVA still boots and behaves sanely.
# ------------------------------
$script:systemPromptShort = @"
You are NOVA, a cinematic terminal AI persona. Be helpful first, the cinematic flavor is seasoning, not the meal. Write in natural prose; avoid bullet lists, numbered lists, or heavy bolding unless the person asks for one or the content truly needs it. Keep replies concise unless depth is requested, and ask at most one clarifying question per reply.

Never create romantic or sexual content involving a minor, or content that could groom, exploit, or endanger a child; refuse instantly and do not explain what triggered the refusal. Do not help build weapons, explosives, or malware. Avoid specific illicit-drug dosing or self-harm method detail; if someone is in emotional distress, respond with care and keep any information general rather than actionable. Do not diagnose, label, or speculate about anyone's mental state. On contested political or ethical topics, give a fair overview of the real positions rather than pushing your own opinion repeatedly.

For legal, medical, or financial questions, give factual grounding rather than confident directives and note you are not a professional. Own mistakes plainly without excessive apology or self-criticism.

You run on no-key community AI gateways (Pollinations.ai, LLM7.io), not any single named company's official model, and you have no persistent memory beyond this visible conversation; be honest about both if asked, and never claim tools or memories you do not have.
"@
$script:systemPromptFullPath = Join-Path $PSScriptRoot "system-prompts\nova-fable-5-full.md"
$script:systemPromptFull = $null
try {
    if (Test-Path $script:systemPromptFullPath) {
        $script:systemPromptFull = Get-Content -Path $script:systemPromptFullPath -Raw -ErrorAction Stop
    }
}
catch {
    $script:systemPromptFull = $null
}
if ([string]::IsNullOrWhiteSpace($script:systemPromptFull)) {
    $script:systemPromptFull = $script:systemPromptShort
}
# Back-compat alias: older code paths in this file (and anyone loading it in
# a REPL) may still reference $script:systemPrompt directly. Point it at the
# short prompt since that's the safer default for ad-hoc/no-arg use.
$script:systemPrompt = $script:systemPromptShort
# ------------------------------
# SOUND ENGINE
# All effects are synthesized with [console]::Beep(frequency, durationMs) so
# there are zero external audio files to ship. Every call is wrapped so a
# host that can't beep (ISE, some non-Windows terminals) never breaks the UI.
# Toggle with /sound on|off.
# ------------------------------
function Beep-Safe {
    param([int]$Freq = 440, [int]$Ms = 60)
    if (-not $script:soundUI) { return }
    try { [console]::Beep($Freq, $Ms) } catch { }
}
function Play-BootJingle {
    # Rising power-on arpeggio for the very start of the boot sequence.
    if (-not $script:soundUI) { return }
    $notes = @(220, 277, 330, 440, 554, 660)
    foreach ($n in $notes) { Beep-Safe $n 55 }
}
function Play-BootTick {
    # Short low blip for each boot log line.
    Beep-Safe 340 18
}
function Play-SpinnerTick {
    # Quiet high tick per spinner frame, subtly rising in pitch as it spins.
    param([int]$Frame = 0)
    $freq = 520 + ($Frame % 6) * 30
    Beep-Safe $freq 12
}
function Play-ScanBlip {
    # Radar-style blip used per scanned module.
    param([int]$Value = 90)
    $freq = 300 + [Math]::Round($Value * 4)
    Beep-Safe $freq 25
}
function Play-SuccessChime {
    # Two-note rising confirm, used when a response/render/scan finishes clean.
    Beep-Safe 660 45
    Beep-Safe 880 70
}
function Play-ErrorBuzz {
    # Low descending buzz for failures.
    Beep-Safe 220 90
    Beep-Safe 140 130
}
function Play-ClickBlip {
    # Tiny UI click for menu/model/theme/provider switches.
    Beep-Safe 700 20
}
function Play-ShutterSound {
    # Camera-shutter style double-tick for /image render start/finish.
    Beep-Safe 900 15
    Start-Sleep -Milliseconds 30
    Beep-Safe 500 25
}
function Play-TransitionSweep {
    # Rising sweep for full-screen cinematic transitions (flare/aurora/curtain/matrix).
    if (-not $script:soundUI) { return }
    $start = 220; $end = 720; $steps = 10
    for ($i = 0; $i -lt $steps; $i++) {
        $freq = [Math]::Round($start + (($end - $start) * ($i / [double]($steps - 1))))
        Beep-Safe $freq 16
    }
}
function Play-TypeTick {
    # Optional ultra-soft tick for typewriter text. Kept very short/quiet-feeling
    # and only fires every few characters so it doesn't become annoying.
    param([int]$Index = 0)
    if (($Index % 3) -ne 0) { return }
    Beep-Safe (480 + (Get-Random -Minimum -20 -Maximum 20)) 8
}
# ------------------------------
# COLOR + OUTPUT
# ------------------------------
function P {
    param([string]$Key)
    $t = $script:themes[$script:theme]
    if ($t.ContainsKey($Key)) { return $t[$Key] }
    return $Key
}
function Ansi {
    param([string]$Color = "white")
    $hex = P $Color
    if ($hex -match '^#?([0-9a-fA-F]{6})$') {
        $h = $matches[1]
        $r = [Convert]::ToInt32($h.Substring(0,2), 16)
        $g = [Convert]::ToInt32($h.Substring(2,2), 16)
        $b = [Convert]::ToInt32($h.Substring(4,2), 16)
        return "$($script:ESC)[38;2;$r;$g;${b}m"
    }
    return ""
}
function W {
    param([string]$Text = "", [string]$Color = "white", [switch]$NoNewline)
    $code = Ansi $Color
    if ($code -ne "") {
        $out = "$code$Text$($script:ESC)[0m"
        if ($NoNewline) { Write-Host $out -NoNewline } else { Write-Host $out }
    }
    else {
        if ($NoNewline) { Write-Host $Text -NoNewline } else { Write-Host $Text }
    }
}
function WG {
    param([string]$Text, [string[]]$Colors = @("pink","cyan"), [switch]$NoNewline)
    $i = 0
    foreach ($ch in $Text.ToCharArray()) {
        W ([string]$ch) $Colors[$i % $Colors.Count] -NoNewline
        $i++
    }
    if (-not $NoNewline) { Write-Host "" }
}
function WGR {
    # Rainbow-gradient text writer. On rgb-cycle themes it paints each character
    # a slightly shifted hue; on normal themes it falls back to WG's 2-color weave.
    param([string]$Text, [string[]]$Colors = @("pink","cyan"), [double]$PhaseOffset = 0, [switch]$NoNewline)
    if (Is-RgbTheme) {
        $len = [Math]::Max(1, $Text.Length)
        $sb = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $phase = $PhaseOffset + ($i / [double]$len)
            [void]$sb.Append((Rainbow-Ansi $phase 0.8 1.0))
            [void]$sb.Append($Text[$i])
        }
        [void]$sb.Append("$($script:ESC)[0m")
        if ($NoNewline) { Write-Host $sb.ToString() -NoNewline } else { Write-Host $sb.ToString() }
    }
    else {
        WG $Text $Colors -NoNewline:$NoNewline
    }
}
function Type-Text {
    param([string]$Text, [string]$Color = "green", [int]$Delay = $script:typeDelay)
    if ($null -eq $Text) { return }
    if (Is-RgbTheme) {
        $phase = Next-RainbowPhase 0.02
        $len = [Math]::Max(1, $Text.Length)
        $i = 0
        foreach ($ch in $Text.ToCharArray()) {
            $huePhase = $phase + ($i / [double]$len)
            $code = Rainbow-Ansi $huePhase 0.75 1.0
            Write-Host -NoNewline "$code$ch$($script:ESC)[0m"
            Play-TypeTick $i
            if ($Delay -gt 0) { Start-Sleep -Milliseconds $Delay }
            $i++
        }
        Write-Host ""
        return
    }
    $i = 0
    foreach ($ch in $Text.ToCharArray()) {
        W ([string]$ch) $Color -NoNewline
        Play-TypeTick $i
        if ($Delay -gt 0) { Start-Sleep -Milliseconds $Delay }
        $i++
    }
    Write-Host ""
}
function Wrap-Text {
    param([string]$Text, [int]$Width = 70)
    $result = @()
    if ($null -eq $Text) { return $result }
    $rawLines = $Text -split "`n"
    foreach ($raw in $rawLines) {
        $line = $raw.TrimEnd()
        while ($line.Length -gt $Width) {
            $cut = $line.LastIndexOf(' ', [Math]::Min($Width, $line.Length - 1))
            if ($cut -lt 10) { $cut = $Width }
            $result += $line.Substring(0, $cut).TrimEnd()
            $line = $line.Substring($cut).TrimStart()
        }
        $result += $line
    }
    return $result
}
function CinematicPause { param([int]$Ms = 250) Start-Sleep -Milliseconds $Ms }
# ------------------------------
# ANIMATION ENGINE (theme-aware gradients)
# ------------------------------
function HexToRgb {
    param([string]$Hex)
    $h = $Hex.TrimStart('#')
    return @{
        r = [Convert]::ToInt32($h.Substring(0,2), 16)
        g = [Convert]::ToInt32($h.Substring(2,2), 16)
        b = [Convert]::ToInt32($h.Substring(4,2), 16)
    }
}
function AnsiRgb {
    param([int]$R, [int]$G, [int]$B)
    return "$($script:ESC)[38;2;$R;$G;${B}m"
}
function HsvToRgb {
    # h in [0,360), s and v in [0,1]. Returns @{r,g,b} 0-255.
    param([double]$H, [double]$S = 1.0, [double]$V = 1.0)
    $c = $V * $S
    $hh = ($H % 360) / 60.0
    $x = $c * (1 - [Math]::Abs(($hh % 2) - 1))
    $m = $V - $c
    $rp = 0; $gp = 0; $bp = 0
    if ($hh -ge 0 -and $hh -lt 1) { $rp = $c; $gp = $x; $bp = 0 }
    elseif ($hh -ge 1 -and $hh -lt 2) { $rp = $x; $gp = $c; $bp = 0 }
    elseif ($hh -ge 2 -and $hh -lt 3) { $rp = 0; $gp = $c; $bp = $x }
    elseif ($hh -ge 3 -and $hh -lt 4) { $rp = 0; $gp = $x; $bp = $c }
    elseif ($hh -ge 4 -and $hh -lt 5) { $rp = $x; $gp = 0; $bp = $c }
    else { $rp = $c; $gp = 0; $bp = $x }
    return @{
        r = [Math]::Round(($rp + $m) * 255)
        g = [Math]::Round(($gp + $m) * 255)
        b = [Math]::Round(($bp + $m) * 255)
    }
}
function Rainbow-Ansi {
    # Returns an ANSI truecolor code for a rotating rainbow hue.
    # Phase 0-1 shifts the base hue; Sat/Val tune vividness for aurora vs neon looks.
    param([double]$Phase = 0, [double]$Sat = 0.85, [double]$Val = 1.0)
    $hue = ($Phase * 360.0) % 360
    $rgb = HsvToRgb $hue $Sat $Val
    return AnsiRgb $rgb.r $rgb.g $rgb.b
}
function Is-RgbTheme {
    $t = $script:themes[$script:theme]
    return ($t.ContainsKey("rgbCycle") -and $t["rgbCycle"])
}
function Next-RainbowPhase {
    # Advances the session-wide rainbow drift and returns the current phase (0-1).
    param([double]$Step = 0.05)
    $script:rainbowTick = ($script:rainbowTick + $Step) % 1.0
    return $script:rainbowTick
}
function Lerp-Color {
    param([string]$HexA, [string]$HexB, [double]$T)
    if ($T -lt 0) { $T = 0 }
    if ($T -gt 1) { $T = 1 }
    $a = HexToRgb $HexA
    $b = HexToRgb $HexB
    $r = [Math]::Round($a.r + ($b.r - $a.r) * $T)
    $g = [Math]::Round($a.g + ($b.g - $a.g) * $T)
    $bl = [Math]::Round($a.b + ($b.b - $a.b) * $T)
    return AnsiRgb $r $g $bl
}
function Animate-Sweep {
    # A traveling glow that sweeps left-to-right across a border line, using the
    # theme's auraA -> auraB gradient. Used for header pulses and transitions.
    # On rgb-cycle themes (aurora), the whole line ripples through a shifting
    # rainbow hue field instead of a single 2-color glow.
    param(
        [string]$Line,
        [int]$Frames = 14,
        [int]$DelayMs = 18,
        [string]$BaseColor = "dim"
    )
    $len = $Line.Length
    if ($len -eq 0) { return }
    if (Is-RgbTheme) {
        for ($f = 0; $f -lt $Frames; $f++) {
            $shift = $f / [Math]::Max(1, $Frames - 1)
            $sb = New-Object System.Text.StringBuilder
            for ($i = 0; $i -lt $len; $i++) {
                $phase = $shift + ($i / [Math]::Max(1.0, $len))
                $code = Rainbow-Ansi $phase 0.75 1.0
                [void]$sb.Append($code)
                [void]$sb.Append($Line[$i])
            }
            [void]$sb.Append("$($script:ESC)[0m")
            Write-Host "`r$($sb.ToString())" -NoNewline
            Start-Sleep -Milliseconds $DelayMs
        }
        Write-Host ""
        return
    }
    $t = $script:themes[$script:theme]
    $auraA = $t["auraA"]
    $auraB = $t["auraB"]
    $baseHex = P $BaseColor
    $bandWidth = [Math]::Max(4, [Math]::Round($len / 5))
    for ($f = 0; $f -lt $Frames; $f++) {
        $center = [Math]::Round((($f / [Math]::Max(1,$Frames - 1)) * ($len + $bandWidth * 2)) - $bandWidth)
        $sb = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt $len; $i++) {
            $dist = [Math]::Abs($i - $center)
            if ($dist -le $bandWidth) {
                $glow = 1 - ($dist / $bandWidth)
                $code = Lerp-Color $baseHex $auraA $glow
            }
            else {
                $code = Ansi $BaseColor
            }
            [void]$sb.Append($code)
            [void]$sb.Append($Line[$i])
        }
        [void]$sb.Append("$($script:ESC)[0m")
        Write-Host "`r$($sb.ToString())" -NoNewline
        Start-Sleep -Milliseconds $DelayMs
    }
    Write-Host ""
}
function Animate-Bar {
    # Fills a bar left to right with a pulsing gradient charge effect.
    param(
        [string]$Label,
        [int]$Value,
        [string]$A = "auraA",
        [string]$B = "auraB",
        [int]$Steps = 10,
        [int]$DelayMs = 14
    )
    if ($Value -lt 0) { $Value = 0 }
    if ($Value -gt 100) { $Value = 100 }
    $targetFilled = [Math]::Round($Value / 5)
    $total = 20
    $rgb = Is-RgbTheme
    for ($s = 1; $s -le $Steps; $s++) {
        $frac = $s / $Steps
        $filled = [Math]::Round($targetFilled * $frac)
        $empty = $total - $filled
        Write-Host "`r" -NoNewline
        W ($Label.PadRight(8) + " ") "dim" -NoNewline
        W "[" "dim" -NoNewline
        for ($i = 0; $i -lt $filled; $i++) {
            if ($rgb) {
                $phase = ($s / [double]$Steps) + ($i / [Math]::Max(1.0, $total))
                $code = Rainbow-Ansi $phase 0.8 1.0
            }
            else {
                $t2 = if ($total -gt 1) { $i / [Math]::Max(1,$total - 1) } else { 0 }
                $pulse = [Math]::Abs([Math]::Sin(($s / [double]$Steps) * [Math]::PI + $t2))
                $code = Lerp-Color (P $A) (P $B) $pulse
            }
            Write-Host -NoNewline "$code█$($script:ESC)[0m"
        }
        W ("░" * $empty) "dark" -NoNewline
        W "] " "dim" -NoNewline
        W "$([Math]::Round($Value * $frac))%  " $B -NoNewline
        Play-SpinnerTick $s
        Start-Sleep -Milliseconds $DelayMs
    }
    if ($rgb) {
        # Breathing finish: a couple of brightness pulses across the filled bar
        # so it feels alive even after it's done charging.
        $breaths = @(1.0, 0.55, 1.0, 0.7, 1.0)
        foreach ($val in $breaths) {
            Write-Host "`r" -NoNewline
            W ($Label.PadRight(8) + " ") "dim" -NoNewline
            W "[" "dim" -NoNewline
            for ($i = 0; $i -lt $targetFilled; $i++) {
                $phase = ($script:rainbowTick) + ($i / [Math]::Max(1.0, $total))
                $rgbVal = HsvToRgb (($phase * 360) % 360) 0.8 $val
                Write-Host -NoNewline "$(AnsiRgb $rgbVal.r $rgbVal.g $rgbVal.b)█$($script:ESC)[0m"
            }
            W ("░" * ($total - $targetFilled)) "dark" -NoNewline
            W "] " "dim" -NoNewline
            W "$Value%  " $B -NoNewline
            $script:rainbowTick = ($script:rainbowTick + 0.015) % 1.0
            Start-Sleep -Milliseconds 60
        }
    }
    Write-Host ""
}
function Flare-Cinema {
    # Full pulsing sun-flare animation. Looks best on the solar theme but
    # renders using whatever theme is active.
    param([int]$Pulses = 3)
    $t = $script:themes[$script:theme]
    $core = $t["gold"]
    $mid = $t["auraA"]
    $edge = $t["dark"]
    $art = @(
        "                     .                     ",
        "               \    |    /                 ",
        "            .    \  |  /    .               ",
        "         '   .    \ | /   .    '            ",
        "      -----------  ( ) -----------         ",
        "         .   '    / | \   '   .             ",
        "            .    /  |  \    .               ",
        "               /    |    \                  ",
        "                     '                      "
    )
    Clear-Host
    Play-TransitionSweep
    for ($p = 0; $p -lt $Pulses; $p++) {
        for ($step = 0; $step -le 10; $step++) {
            $glow = [Math]::Abs([Math]::Sin(($step / 10.0) * [Math]::PI))
            $code = Lerp-Color $edge $core $glow
            $code2 = Lerp-Color $edge $mid $glow
            Write-Host "`e[H" -NoNewline
            W "" "white"
            foreach ($line in $art) {
                Write-Host -NoNewline "  $code$line$($script:ESC)[0m"
                Write-Host ""
            }
            $capLine = "        N O V A   S O L A R   F L A R E        "
            Write-Host -NoNewline "  $code2$capLine$($script:ESC)[0m"
            Write-Host ""
            if ($step % 3 -eq 0) { Beep-Safe (300 + [Math]::Round($glow * 400)) 20 }
            Start-Sleep -Milliseconds 35
        }
    }
    Play-SuccessChime
    CinematicPause 200
}
function Aurora-Cinema {
    # Flowing rainbow "borealis curtain" animation - each vertical band ripples
    # through a shifting rainbow hue field using sine-wave noise for a drifting,
    # organic look. Renders true RGB truecolor waves top to bottom.
    # Mode "calm"  : slow, gentle, single-layer waves, softer colors.
    # Mode "storm" : fast, chaotic, multi-layer turbulence, higher saturation.
    param([string]$Mode = "calm", [int]$Frames = 0, [int]$DelayMs = 0)
    $Mode = $Mode.ToLower()
    if ($Mode -ne "storm") { $Mode = "calm" }
    if ($Frames -le 0) { $Frames = if ($Mode -eq "storm") { 55 } else { 36 } }
    if ($DelayMs -le 0) { $DelayMs = if ($Mode -eq "storm") { 30 } else { 55 } }
    Clear-Host
    Play-TransitionSweep
    $width = 80
    $height = 16
    $bandChars = @(' ', '.', ':', '-', '=', '+', '*', '#', '%', '@')
    $speedMul = if ($Mode -eq "storm") { 2.4 } else { 1.0 }
    $satBase = if ($Mode -eq "storm") { 0.75 } else { 0.5 }
    $satRange = if ($Mode -eq "storm") { 0.25 } else { 0.35 }
    for ($f = 0; $f -lt $Frames; $f++) {
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append("`e[H")
        [void]$sb.Append("`n")
        for ($y = 0; $y -lt $height; $y++) {
            for ($x = 0; $x -lt $width; $x++) {
                $wave1 = [Math]::Sin(($x / 9.0) + ($f * $speedMul / 6.0) + ($y / 4.0))
                $wave2 = [Math]::Sin(($x / 14.0) - ($f * $speedMul / 8.0) + ($y / 6.0))
                if ($Mode -eq "storm") {
                    $wave3 = [Math]::Sin(($x / 5.0) + ($f * $speedMul / 3.5) - ($y / 3.0))
                    $intensity = ($wave1 + $wave2 + $wave3 + 3) / 6.0
                }
                else {
                    $intensity = ($wave1 + $wave2 + 2) / 4.0
                }
                $hue = ((($x / [double]$width) * 200) + ($f * $speedMul * 4) + ($y * 6)) % 360
                $charIdx = [Math]::Min($bandChars.Count - 1, [Math]::Floor($intensity * $bandChars.Count))
                $ch = $bandChars[$charIdx]
                if ($ch -ne ' ') {
                    $sat = $satBase + ($intensity * $satRange)
                    $val = 0.35 + ($intensity * 0.65)
                    $rgb = HsvToRgb $hue $sat $val
                    [void]$sb.Append((AnsiRgb $rgb.r $rgb.g $rgb.b))
                    [void]$sb.Append($ch)
                }
                else {
                    [void]$sb.Append(' ')
                }
            }
            [void]$sb.Append("$($script:ESC)[0m")
            [void]$sb.Append("`n")
        }
        $capPhase = $f / [Math]::Max(1, $Frames - 1)
        $capText = if ($Mode -eq "storm") { "N O V A   A U R O R A   S T O R M" } else { "N O V A   A U R O R A   N E O N" }
        $cap = $capText.PadLeft(([Math]::Floor(($width + $capText.Length) / 2))).PadRight($width)
        $capSb = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt $cap.Length; $i++) {
            $phase = $capPhase + ($i / [Math]::Max(1.0, $cap.Length))
            [void]$capSb.Append((Rainbow-Ansi $phase 0.8 1.0))
            [void]$capSb.Append($cap[$i])
        }
        [void]$capSb.Append("$($script:ESC)[0m")
        [void]$sb.Append($capSb.ToString())
        Write-Host $sb.ToString()
        if ($f % 8 -eq 0) { Play-SpinnerTick $f }
        Start-Sleep -Milliseconds $DelayMs
    }
    Play-SuccessChime
    CinematicPause 200
}
function Curtain-Cinema {
    # Vertical rainbow "curtain fall" transition: characters rain from top to
    # bottom across the screen, Matrix-style, but in full drifting RGB hues.
    param([int]$Frames = 26, [int]$DelayMs = 45)
    $width = 80
    $height = 18
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789|/\-*+."
    $drops = New-Object int[] $width
    for ($x = 0; $x -lt $width; $x++) { $drops[$x] = Get-Random -Minimum (-$height) -Maximum 0 }
    Clear-Host
    Play-TransitionSweep
    for ($f = 0; $f -lt $Frames; $f++) {
        $grid = New-Object 'object[,]' $height, $width
        for ($x = 0; $x -lt $width; $x++) {
            $dropY = $drops[$x]
            for ($trail = 0; $trail -lt 6; $trail++) {
                $y = $dropY - $trail
                if ($y -ge 0 -and $y -lt $height) {
                    $grid[$y, $x] = [pscustomobject]@{ ch = $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]; fade = $trail }
                }
            }
            $drops[$x] = $dropY + 1
            if ($drops[$x] -gt $height + 6) { $drops[$x] = Get-Random -Minimum (-10) -Maximum 0 }
        }
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append("`e[H")
        for ($y = 0; $y -lt $height; $y++) {
            for ($x = 0; $x -lt $width; $x++) {
                $cell = $grid[$y, $x]
                if ($null -eq $cell) { [void]$sb.Append(' '); continue }
                $hue = ((($x / [double]$width) * 300) + ($f * 5)) % 360
                $val = [Math]::Max(0.15, 1.0 - ($cell.fade * 0.18))
                $rgb = HsvToRgb $hue 0.85 $val
                [void]$sb.Append((AnsiRgb $rgb.r $rgb.g $rgb.b))
                [void]$sb.Append($cell.ch)
            }
            [void]$sb.Append("$($script:ESC)[0m")
            [void]$sb.Append("`n")
        }
        Write-Host $sb.ToString() -NoNewline
        if ($f % 4 -eq 0) { Play-SpinnerTick $f }
        Start-Sleep -Milliseconds $DelayMs
    }
    Write-Host ""
    Play-SuccessChime
    CinematicPause 150
}
function Logo-Animated-Cinema {
    # Big block-letter NOVA wordmark with a genuine animated RGB gradient wave
    # sweeping across it frame by frame - true truecolor hue-cycling, not a
    # static 2-color weave. Renders standalone as a full-screen moment.
    param([int]$Frames = 40, [int]$DelayMs = 55)
    $art = @(
        " ███╗   ██╗  ██████╗ ██╗   ██╗  █████╗ ",
        " ████╗  ██║ ██╔═══██╗██║   ██║ ██╔══██╗",
        " ██╔██╗ ██║ ██║   ██║██║   ██║ ███████║",
        " ██║╚██╗██║ ██║   ██║╚██╗ ██╔╝ ██╔══██║",
        " ██║ ╚████║ ╚██████╔╝ ╚████╔╝  ██║  ██║",
        " ╚═╝  ╚═══╝  ╚═════╝   ╚═══╝   ╚═╝  ╚═╝"
    )
    $tagline = "C I N E M A   T E R M I N A L   A I"
    $width = ($art | Measure-Object -Property Length -Maximum).Maximum
    Clear-Host
    Play-TransitionSweep
    for ($f = 0; $f -lt $Frames; $f++) {
        $phase = $f / [double]$Frames
        Write-Host "`e[H" -NoNewline
        W ""
        foreach ($line in $art) {
            $sb = New-Object System.Text.StringBuilder
            for ($i = 0; $i -lt $line.Length; $i++) {
                $ch = $line[$i]
                if ($ch -ne ' ') {
                    $huePhase = $phase + ($i / [double]$width) * 0.6
                    $rgb = HsvToRgb (($huePhase * 360) % 360) 0.85 1.0
                    [void]$sb.Append((AnsiRgb $rgb.r $rgb.g $rgb.b))
                    [void]$sb.Append($ch)
                }
                else {
                    [void]$sb.Append(' ')
                }
            }
            [void]$sb.Append("$($script:ESC)[0m")
            Write-Host "  $($sb.ToString())"
        }
        W ""
        $padCount = [Math]::Max(0, [Math]::Floor(($width - $tagline.Length) / 2))
        $pad = " " * $padCount
        $tagSb = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt $tagline.Length; $i++) {
            $huePhase = $phase + 0.5 + ($i / [double]$tagline.Length) * 0.4
            $rgb = HsvToRgb (($huePhase * 360) % 360) 0.7 1.0
            [void]$tagSb.Append((AnsiRgb $rgb.r $rgb.g $rgb.b))
            [void]$tagSb.Append($tagline[$i])
        }
        [void]$tagSb.Append("$($script:ESC)[0m")
        Write-Host "  $pad$($tagSb.ToString())"
        W ""
        if ($f % 6 -eq 0) { Play-SpinnerTick $f }
        Start-Sleep -Milliseconds $DelayMs
    }
    Play-SuccessChime
    CinematicPause 400
}
# ------------------------------
# MODEL HELPERS
# ------------------------------
function Get-ModelEntry {
    param([string]$Provider = $script:provider, [string]$Model = $script:model)
    if ($script:noAuthModels.ContainsKey($Provider)) {
        foreach ($m in $script:noAuthModels[$Provider]) {
            if ($m.name.ToLower() -eq $Model.ToLower()) { return $m }
        }
    }
    if ($script:authModels.ContainsKey($Provider)) {
        foreach ($m in $script:authModels[$Provider]) {
            if ($m.name.ToLower() -eq $Model.ToLower()) { return $m }
        }
    }
    return $null
}
function Is-AuthModel {
    param([string]$Provider = $script:provider, [string]$Model = $script:model)
    if ($script:authModels.ContainsKey($Provider)) {
        foreach ($m in $script:authModels[$Provider]) {
            if ($m.name.ToLower() -eq $Model.ToLower()) { return $true }
        }
    }
    return $false
}
function Has-Key {
    param([string]$Provider = $script:provider)
    return ($script:apiKeys.ContainsKey($Provider) -and $script:apiKeys[$Provider] -ne "")
}
function Resolve-ApiModel {
    param([string]$Provider = $script:provider, [string]$Model = $script:model)
    $entry = Get-ModelEntry $Provider $Model
    if ($entry) { return [string]$entry.api }
    return $Model
}
function Model-Note {
    param([string]$Provider = $script:provider, [string]$Model = $script:model)
    $entry = Get-ModelEntry $Provider $Model
    if ($entry) { return [string]$entry.note }
    return "custom model name"
}
function Model-Cat {
    param([string]$Provider = $script:provider, [string]$Model = $script:model)
    $entry = Get-ModelEntry $Provider $Model
    if ($entry) { return [string]$entry.cat }
    return "custom"
}
function Model-Tag {
    param([string]$Provider = $script:provider, [string]$Model = $script:model)
    $entry = Get-ModelEntry $Provider $Model
    if ($entry) { return [string]$entry.tag }
    return "unknown"
}
function TagColor {
    param([string]$Tag)
    switch ($Tag) {
        "free"          { return "green" }
        "rate-limited"  { return "gold" }
        "paid"          { return "red" }
        default         { return "dim" }
    }
}
function CatColor {
    param([string]$Cat)
    switch ($Cat) {
        "chat"      { return "cyan" }
        "code"      { return "green" }
        "vision"    { return "pink" }
        "reasoning" { return "gold" }
        "roleplay"  { return "purple" }
        default     { return "dim" }
    }
}
function MemoryPercent {
    $max = $script:maxMemoryPairs * 2
    if ($max -le 0) { return 0 }
    return [Math]::Min(100, [Math]::Round(($script:memory.Count / $max) * 100))
}
# ------------------------------
# UI PIECES
# ------------------------------
function Bar {
    param([string]$Label, [int]$Value, [string]$A = "pink", [string]$B = "cyan")
    if ($Value -lt 0) { $Value = 0 }
    if ($Value -gt 100) { $Value = 100 }
    $filled = [Math]::Round($Value / 5)
    $empty = 20 - $filled
    W ($Label.PadRight(8) + " ") "dim" -NoNewline
    W "[" "dim" -NoNewline
    for ($i = 0; $i -lt $filled; $i++) {
        if ($i % 2 -eq 0) { W "█" $A -NoNewline } else { W "█" $B -NoNewline }
    }
    W ("░" * $empty) "dark" -NoNewline
    W "] " "dim" -NoNewline
    W "$Value%" $B
}
function Logo-Cinema {
    W ""
    WGR "  ███╗   ██╗  ██████╗ ██╗   ██╗  █████╗       ▓▓ CINEMA MODE v2 ▓▓" @("cyan","pink") 0.0
    WGR "  ████╗  ██║ ██╔═══██╗██║   ██║ ██╔══██╗      NEXUS ONLINE // NO-AUTH AI" @("cyan","pink") 0.08
    WGR "  ██╔██╗ ██║ ██║   ██║██║   ██║ ███████║      DUAL GATEWAY DIALOGUE ENGINE" @("pink","cyan") 0.16
    WGR "  ██║╚██╗██║ ██║   ██║╚██╗ ██╔╝ ██╔══██║      36 MODELS // 2 PROVIDERS" @("pink","cyan") 0.24
    WGR "  ██║ ╚████║ ╚██████╔╝ ╚████╔╝  ██║  ██║      CYBERDECK BUILD 2.1 // SFX" @("cyan","pink") 0.32
    WGR "  ╚═╝  ╚═══╝  ╚═════╝   ╚═══╝   ╚═╝  ╚═╝" @("pink","cyan") 0.40
}
function Draw-Header {
    if ($script:animateUI) {
        Animate-Sweep "════════════════════════════════════════════════════════════════════════════════" 10 10 "dim"
    }
    else {
        WGR "╔══════════════════════════════════════════════════════════════════════════════╗" @("pink","cyan") 0.5
    }
    W "║ " "cyan" -NoNewline
    WGR "NOVA CINEMA DECK  //  ABSOLUTE TERMINAL EXPERIENCE  //  $(Get-Date -Format 'HH:mm:ss')" @("pink","cyan") 0.6 -NoNewline
    W "   ║" "pink"
    WGR "╚══════════════════════════════════════════════════════════════════════════════╝" @("cyan","pink") 0.7
}
function Draw-StatusDeck {
    $cat = Model-Cat
    $tag = Model-Tag
    $catColor = CatColor $cat
    $tagColor = TagColor $tag
    $isAuth = Is-AuthModel
    $keyLinked = Has-Key $script:provider
    $authLabel = if ($isAuth) { if ($keyLinked) { "AUTH (linked)" } else { "AUTH (no key!)" } } else { "no-auth" }
    $authColor = if ($isAuth) { if ($keyLinked) { "green" } else { "red" } } else { "dim" }
    W "╭─ AI LINK ─────────────────────────╮  ╭─ DIRECTOR MONITOR ───────────────────╮" "cyan"
    W "│ Provider : " "cyan" -NoNewline; W ($script:provider.PadRight(21)) "gold" -NoNewline; W "│  │ Scene     : " "cyan" -NoNewline; W ("CINEMATIC CHAT".PadRight(21)) "pink" -NoNewline; W "│" "cyan"
    W "│ Model    : " "cyan" -NoNewline; W ($script:model.PadRight(21)) "gold" -NoNewline; W "│  │ API ID    : " "cyan" -NoNewline; W ((Resolve-ApiModel).PadRight(21)) "green" -NoNewline; W "│" "cyan"
    W "│ Category : " "cyan" -NoNewline; W ($cat.PadRight(21)) $catColor -NoNewline; W "│  │ Status    : " "cyan" -NoNewline; W ($tag.PadRight(21)) $tagColor -NoNewline; W "│" "cyan"
    W "│ Access   : " "cyan" -NoNewline; W ($authLabel.PadRight(21)) $authColor -NoNewline; W "│  │ Theme     : " "cyan" -NoNewline; W ($script:theme.PadRight(21)) "gold" -NoNewline; W "│" "cyan"
    W "╰───────────────────────────────────╯  ╰──────────────────────────────────────╯" "cyan"
    W ""
    if ($script:animateUI) {
        Animate-Bar "AURA"  96 "auraA" "auraB" 8 10
        Animate-Bar "LINK"  98 "cyan"  "cyan2" 8 10
        Animate-Bar "CACHE" (MemoryPercent) "red" "cyan" 8 10
        Animate-Bar "DRAMA" 100 "pink" "gold" 8 10
    }
    else {
        Bar "AURA"  96 "auraA" "auraB"
        Bar "LINK"  98 "cyan"  "cyan2"
        Bar "CACHE" (MemoryPercent) "red" "cyan"
        Bar "DRAMA" 100 "pink" "gold"
    }
}
function Draw-ChatViewport {
    W ""
    WG "╭─ HOLOGRAPHIC CHAT MEMORY ──────────────────────────────────────────────────" @("pink","cyan")
    if ($script:chatLog.Count -eq 0) {
        W "│ " "cyan" -NoNewline
        W "No messages yet. Say something and let the scene begin." "dim"
    }
    else {
        $start = [Math]::Max(0, $script:chatLog.Count - $script:maxLogLines)
        for ($i = $start; $i -lt $script:chatLog.Count; $i++) {
            $entry = $script:chatLog[$i]
            $prefix = $entry.role.ToUpper().PadRight(5)
            $color = if ($entry.role -eq "nova") { "green" } else { "cyan" }
            foreach ($line in (Wrap-Text $entry.text 64)) {
                W "│ " "cyan" -NoNewline
                W "$prefix " $color -NoNewline
                W $line "white"
                $prefix = "     "
            }
        }
    }
    WG "╰────────────────────────────────────────────────────────────────────────────" @("cyan","pink")
}
function Draw-CommandDeck {
    W ""
    W "╭─ COMMAND REEL ──────────────────────────────────────────────────────────────╮" "pink"
    W "│ " "pink" -NoNewline
    W "[1] LLM7" "cyan" -NoNewline; W "  " "dim" -NoNewline
    W "[2] Pollinations" "pink" -NoNewline; W "  " "dim" -NoNewline
    W "[3] Models" "cyan" -NoNewline; W "  " "dim" -NoNewline
    W "[4] Scan" "gold" -NoNewline; W "  " "dim" -NoNewline
    W "[5] Matrix" "green" -NoNewline; W "  " "dim" -NoNewline
    W "[6] Help" "pink" -NoNewline; W "  " "dim" -NoNewline
    W "[7] Redraw" "cyan" -NoNewline
    W "                       │" "pink"
    W "│ " "pink" -NoNewline
    W "/models code|chat|vision|reasoning|roleplay   /pick N   /theme X   /speed N" "dim"
    W "  │" "pink"
    W "│ " "pink" -NoNewline
    $animState = if ($script:animateUI) { "ON" } else { "OFF" }
    $soundState = if ($script:soundUI) { "ON" } else { "OFF" }
    W "/flare   /animate on|off (currently $animState)   /sound on|off (currently $soundState)" "dim"
    W "   │" "pink"
    W "│ " "pink" -NoNewline
    W "/credits" "dim"
    W "                                                                       │" "pink"
    W "│ " "pink" -NoNewline
    $polAuth = if (Has-Key "pollinations") { "LINKED" } else { "guest" }
    $llmAuth = if (Has-Key "llm7") { "LINKED" } else { "guest" }
    $polColor = if (Has-Key "pollinations") { "green" } else { "dim" }
    $llmColor = if (Has-Key "llm7") { "green" } else { "dim" }
    W "/authmodels   /login PROVIDER KEY   pollinations:" "dim" -NoNewline
    W $polAuth $polColor -NoNewline
    W " llm7:" "dim" -NoNewline
    W $llmAuth $llmColor -NoNewline
    W "  │" "pink"
    W "│ " "pink" -NoNewline
    W "/image PROMPT   /calc EXPR   /time   /weather CITY" "dim"
    W "                       │" "pink"
    W "│ " "pink" -NoNewline
    W "/aurora calm|storm   /curtain   /logo   (theme: aurora = live RGB engine)" "dim"
    W " │" "pink"
    W "╰────────────────────────────────────────────────────────────────────────────╯" "pink"
}
function Draw-CinemaUI {
    Clear-Host
    Logo-Cinema
    Draw-Header
    Draw-StatusDeck
    Draw-ChatViewport
    Draw-CommandDeck
    W ""
}
function Prompt-Cinema {
    if (Is-RgbTheme) {
        $phase = Next-RainbowPhase 0.06
        $line = "╭─[$($script:provider)/$($script:model)]"
        WGR $line @("cyan","pink") $phase
        W "╰─" "dim" -NoNewline
        WGR "YOU" @("cyan","pink") ($phase + 0.3) -NoNewline
        W " " "dim" -NoNewline
        WGR "▶" @("pink","cyan") ($phase + 0.5) -NoNewline
        W " " "dim" -NoNewline
    }
    else {
        W "╭─[" "dim" -NoNewline
        W $script:provider "cyan" -NoNewline
        W "/" "dim" -NoNewline
        W $script:model "pink" -NoNewline
        W "]" "dim"
        W "╰─" "dim" -NoNewline
        W "YOU" "cyan" -NoNewline
        W " ▶ " "pink" -NoNewline
    }
}
function Box {
    param([string]$Title, [string[]]$Lines, [string]$Color = "cyan")
    WG "╭─ $Title ─────────────────────────────────────────────────────────────" @("pink",$Color)
    foreach ($line in $Lines) {
        foreach ($wrapped in (Wrap-Text $line 72)) {
            W "│ " $Color -NoNewline
            W $wrapped "white"
        }
    }
    WG "╰──────────────────────────────────────────────────────────────────────" @($Color,"pink")
}
# ------------------------------
# CINEMATIC EFFECTS
# ------------------------------
function Boot-Cinema {
    Clear-Host
    Play-BootJingle
    if ($script:animateUI) {
        if (Is-RgbTheme) { Aurora-Cinema "calm" } else { Flare-Cinema 2 }
    }
    Clear-Host
    WGR "╔══════════════════════════════════════════════════════════════════════════════╗" @("gold","pink") 0.1
    WGR "║                       N O V A   C I N E M A   v 2                          ║" @("cyan","gold") 0.3
    WGR "╚══════════════════════════════════════════════════════════════════════════════╝" @("gold","pink") 0.5
    W ""
    $boot = @(
        "igniting AURORA RGB render pipeline",
        "loading black-glass HUD shaders",
        "charging live rainbow aura rails",
        "mounting Pollinations no-auth gateway (20 models)",
        "mounting LLM7 anonymous gateway (16 models)",
        "routing default display model: gpt-5-nano",
        "warming dialogue engine",
        "calibrating live animation engine",
        "priming synthesized sound rig",
        "cinema deck online"
    )
    foreach ($b in $boot) {
        W "[" "dim" -NoNewline
        W " SCENE " "gold" -NoNewline
        W "] " "dim" -NoNewline
        Play-BootTick
        Type-Text $b "cyan" 8
        CinematicPause 90
    }
    Play-SuccessChime
    CinematicPause 350
}
function Spinner-Cinema {
    $frames = @("◜","◝","◞","◟")
    W ""
    W "NOVA " "pink" -NoNewline
    W "rendering response frame " "dim" -NoNewline
    for ($i = 0; $i -lt 18; $i++) {
        W " $($frames[$i % $frames.Count])" "cyan" -NoNewline
        Play-SpinnerTick $i
        Start-Sleep -Milliseconds 50
    }
    W " " "dim"
}
function Scan-Cinema {
    W ""
    WG "╭─ CINEMATIC SYSTEM SCAN ─────────────────────────────────────────────────────" @("pink","cyan")
    $modules = @("Neural Core","Provider Gate","Prompt Lens","Memory Cache","AURA Rails","Dialogue Engine","No-Auth Link","Cyberdeck UI")
    foreach ($m in $modules) {
        $v = Get-Random -Minimum 79 -Maximum 100
        W "│ " "cyan" -NoNewline
        W ($m.PadRight(18)) "white" -NoNewline
        W " " "dim" -NoNewline
        Bar "" $v "pink" "cyan"
        Play-ScanBlip $v
        CinematicPause 80
    }
    WG "╰────────────────────────────────────────────────────────────────────────────" @("cyan","pink")
    W "NOVA: Scan complete. Visuals are immaculate." "green"
    Play-SuccessChime
}
function Matrix-Cinema {
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#$%&@"
    Clear-Host
    Play-TransitionSweep
    for ($y = 0; $y -lt 20; $y++) {
        $line = ""
        for ($x = 0; $x -lt 82; $x++) { $line += $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)] }
        if ($y % 3 -eq 0) { W $line "pink" }
        elseif ($y % 3 -eq 1) { W $line "cyan" }
        else { W $line "green" }
        if ($y % 4 -eq 0) { Play-SpinnerTick $y }
        Start-Sleep -Milliseconds 25
    }
    CinematicPause 250
    Draw-CinemaUI
}
function Glitch-Cinema {
    $glitch = @(
        "N0VA::SIGNAL_SHIFT██████",
        "FRAME_DESYNC // RESTORING",
        "CYAN RAILS: ACTIVE",
        "MAGENTA BLOOM: ACTIVE",
        "REALITY BUFFER: STABLE"
    )
    foreach ($g in $glitch) {
        WG $g @("pink","cyan","green")
        Beep-Safe (Get-Random -Minimum 150 -Maximum 900) 25
        Start-Sleep -Milliseconds 80
    }
    Play-SuccessChime
}
# ------------------------------
# COMMANDS
# ------------------------------
function Help-Cinema {
    Box "COMMANDS" @(
        "/help                          Show this command reel",
        "/ui or /clear                  Redraw cinema UI",
        "/providers                     Show providers",
        "/provider llm7                 Switch to LLM7",
        "/provider pollinations         Switch to Pollinations and gpt-5-nano display",
        "/models                        Show current provider no-auth models",
        "/models CATEGORY               Filter: chat, code, vision, reasoning, roleplay",
        "/allmodels                     Show all no-auth models, both providers",
        "/authmodels                    Show current provider AUTH (premium/paid) models",
        "/authmodels CATEGORY           Filter auth models by category",
        "/allauthmodels                 Show all auth models, both providers",
        "/login pollinations KEY        Link a Pollinations API key (enter.pollinations.ai)",
        "/login llm7 TOKEN              Link an LLM7 token (dash.llm7.io)",
        "/logout pollinations|llm7      Clear a linked key/token",
        "/pick N                        Select model N from the last /models or /authmodels listing",
        "/model NAME                    Switch model by exact name",
        "/current                       Show current config",
        "/image PROMPT                  Generate an image via Pollinations, saved to nova-images/",
        "/calc EXPRESSION               Quick arithmetic, e.g. /calc 12*7+3",
        "/time                          Show local ship clock",
        "/weather CITY                  Live weather uplink for a city",
        "/scan                          Cinematic system scan",
        "/matrix                        Matrix flash transition",
        "/glitch                        Quick glitch effect",
        "/flare                         Animated solar flare transition",
        "/animate on|off                Toggle live gradient animation engine",
        "/sound on|off                  Toggle synthesized sound effects engine",
        "/credits                       Show the credits reel",
        "/theme bloxd|void|blood|ice|solar|neon|aurora  Switch cinema palette (default: aurora)",
        "/aurora calm|storm             Animated RGB aurora borealis transition (default calm)",
        "/curtain                       Vertical rainbow curtain-fall transition",
        "/logo                          Big animated RGB gradient NOVA wordmark",
        "/speed NUMBER                  Typing speed in milliseconds, e.g. /speed 0",
        "/reset                         Clear chat memory",
        "exit                           Quit NOVA"
    )
}
function Providers-Cinema {
    $polKey = if (Has-Key "pollinations") { "LINKED" } else { "not linked" }
    $llmKey = if (Has-Key "llm7") { "LINKED" } else { "not linked" }
    Box "PROVIDERS" @(
        "pollinations : no-key text endpoint. NOVA displays gpt-5-nano and routes safely to openai-fast. 20 catalogued no-auth models spanning chat, code, vision, reasoning.",
        "               AUTH TIER: 20 premium models (GPT-5.4, Claude Opus, Gemini Large, Grok, Perplexity, and more). Key status: $polKey. Get a key at enter.pollinations.ai, then /login pollinations YOUR_KEY.",
        "llm7         : OpenAI-compatible anonymous endpoint using Bearer unused. 16 catalogued no-auth models including reasoning, code, vision and roleplay tunes.",
        "               AUTH TIER: 8 premium/token-boosted models (Pro router, full GPT-4o, DeepSeek R1, Qwen3 235B, and more). Token status: $llmKey. Get a token at dash.llm7.io, then /login llm7 YOUR_TOKEN.",
        "Free endpoints can rate-limit. If one fails, switch provider or model, or retry. Auth models may fail without a linked key/token."
    )
}
function Models-Cinema {
    param([string]$Provider = $script:provider, [string]$Filter = "")
    if (-not $script:noAuthModels.ContainsKey($Provider)) { W "Unknown provider." "red"; return }
    $list = $script:noAuthModels[$Provider]
    if ($Filter -ne "") {
        $list = $list | Where-Object { $_.cat -eq $Filter }
        if (-not $list) { W "No models found in category '$Filter'." "gold"; return }
    }
    $script:lastModelPicks = @()
    W ""
    $title = "$($Provider.ToUpper()) NO-AUTH MODEL REEL"
    if ($Filter -ne "") { $title += " // $($Filter.ToUpper())" }
    WG "╭─ $title ─────────────────────────────────────────────" @("pink","cyan")
    $idx = 1
    foreach ($m in $list) {
        $script:lastModelPicks += [pscustomobject]@{ provider = $Provider; name = $m.name }
        $tagColor = TagColor $m.tag
        $catColor = CatColor $m.cat
        W "│ " "cyan" -NoNewline
        W ("[{0}] " -f $idx).PadRight(5) "dim" -NoNewline
        W ($m.name).PadRight(24) "green" -NoNewline
        W " [" "dim" -NoNewline
        W ($m.cat).PadRight(9) $catColor -NoNewline
        W "] [" "dim" -NoNewline
        W ($m.tag).PadRight(13) $tagColor -NoNewline
        W "] " "dim" -NoNewline
        W $m.note "dim"
        $idx++
    }
    WG "╰────────────────────────────────────────────────────────────────────────────" @("cyan","pink")
    W "Tip: use /pick N to switch instantly to a listed model." "dim"
}
function AllModels-Cinema {
    Models-Cinema "pollinations"
    Models-Cinema "llm7"
}
function AuthModels-Cinema {
    param([string]$Provider = $script:provider, [string]$Filter = "")
    if (-not $script:authModels.ContainsKey($Provider)) { W "Unknown provider." "red"; return }
    $list = $script:authModels[$Provider]
    if ($Filter -ne "") {
        $list = $list | Where-Object { $_.cat -eq $Filter }
        if (-not $list) { W "No auth models found in category '$Filter'." "gold"; return }
    }
    $script:lastModelPicks = @()
    W ""
    $keyState = if (Has-Key $Provider) { "KEY SET" } else { "NO KEY" }
    $keyColor = if (Has-Key $Provider) { "green" } else { "red" }
    $title = "$($Provider.ToUpper()) AUTH MODEL REEL"
    if ($Filter -ne "") { $title += " // $($Filter.ToUpper())" }
    WG "╭─ $title ─────────────────────────────────────────────" @("gold","pink")
    W "│ " "cyan" -NoNewline
    W "Account status: " "dim" -NoNewline
    W $keyState $keyColor
    W "│ " "cyan"
    $idx = 1
    foreach ($m in $list) {
        $script:lastModelPicks += [pscustomobject]@{ provider = $Provider; name = $m.name }
        $tagColor = TagColor $m.tag
        $catColor = CatColor $m.cat
        W "│ " "cyan" -NoNewline
        W ("[{0}] " -f $idx).PadRight(5) "dim" -NoNewline
        W ($m.name).PadRight(24) "gold" -NoNewline
        W " [" "dim" -NoNewline
        W ($m.cat).PadRight(9) $catColor -NoNewline
        W "] [" "dim" -NoNewline
        W ($m.tag).PadRight(6) $tagColor -NoNewline
        W "] " "dim" -NoNewline
        W $m.note "dim"
        $idx++
    }
    WG "╰────────────────────────────────────────────────────────────────────────────" @("pink","gold")
    if ($Provider -eq "pollinations") { W "Get a key at enter.pollinations.ai, then run /login pollinations YOUR_KEY" "dim" }
    else { W "Get a token at dash.llm7.io, then run /login llm7 YOUR_TOKEN" "dim" }
    W "Tip: use /pick N to switch instantly to a listed model." "dim"
}
function AllAuthModels-Cinema {
    AuthModels-Cinema "pollinations"
    AuthModels-Cinema "llm7"
}
function Login-Cinema {
    param([string]$Provider, [string]$Key)
    $Provider = $Provider.ToLower()
    if ($Provider -ne "pollinations" -and $Provider -ne "llm7") {
        W "Usage: /login pollinations YOUR_KEY  or  /login llm7 YOUR_TOKEN" "gold"
        return
    }
    if ($Key -eq "") { W "Usage: /login $Provider YOUR_KEY" "gold"; return }
    $script:apiKeys[$Provider] = $Key
    $script:useAuth[$Provider] = $true
    $masked = if ($Key.Length -gt 6) { $Key.Substring(0,3) + "***" + $Key.Substring($Key.Length - 3) } else { "***" }
    W "NOVA: Credentials linked for $Provider ($masked). Auth models unlocked." "green"
    Play-SuccessChime
}
function Logout-Cinema {
    param([string]$Provider)
    $Provider = $Provider.ToLower()
    if ($Provider -ne "pollinations" -and $Provider -ne "llm7") {
        W "Usage: /logout pollinations  or  /logout llm7" "gold"
        return
    }
    $script:apiKeys[$Provider] = ""
    $script:useAuth[$Provider] = $false
    W "NOVA: Credentials cleared for $Provider. Falling back to no-auth mode." "gold"
    Play-ClickBlip
}
function Pick-Cinema {
    param([string]$Arg)
    $n = 0
    if (-not [int]::TryParse($Arg, [ref]$n)) { W "Usage: /pick N (run /models first)" "gold"; return }
    if ($script:lastModelPicks.Count -eq 0) { W "No model list cached yet. Run /models or /allmodels first." "gold"; return }
    if ($n -lt 1 -or $n -gt $script:lastModelPicks.Count) { W "Pick out of range." "gold"; return }
    $choice = $script:lastModelPicks[$n - 1]
    $script:provider = $choice.provider
    $script:model = $choice.name
    Play-ClickBlip
    if ((Is-AuthModel $choice.provider $choice.name) -and -not (Has-Key $choice.provider)) {
        W "NOVA: Switched to $($choice.provider)/$($choice.name). API ID: $(Resolve-ApiModel)" "green"
        W "WARNING: This is an auth-gated model and no key is linked for $($choice.provider). Run /login $($choice.provider) YOUR_KEY or requests will likely fail." "gold"
        Play-ErrorBuzz
    }
    else {
        W "NOVA: Switched to $($choice.provider)/$($choice.name). API ID: $(Resolve-ApiModel)" "green"
    }
}
function Current-Cinema {
    $isAuth = Is-AuthModel
    $accessLine = if ($isAuth) { if (Has-Key $script:provider) { "AUTH model, key linked" } else { "AUTH model, NO KEY LINKED - requests may fail" } } else { "no-auth model" }
    $polKey = if (Has-Key "pollinations") { "linked" } else { "not linked" }
    $llmKey = if (Has-Key "llm7") { "linked" } else { "not linked" }
    $promptMode = if ($script:provider -eq "llm7") { "full (NOVA Fable 5)" } else { "condensed (URL-safe)" }
    Box "CURRENT SCENE" @(
        "Provider : $($script:provider)",
        "Model    : $($script:model)",
        "API ID   : $(Resolve-ApiModel)",
        "Category : $(Model-Cat)",
        "Status   : $(Model-Tag)",
        "Access   : $accessLine",
        "Note     : $(Model-Note)",
        "Theme    : $($script:theme)",
        "Speed    : $($script:typeDelay) ms per char",
        "Sound    : $(if ($script:soundUI) { 'on' } else { 'off' })",
        "Memory   : $($script:memory.Count) lines",
        "Keys     : pollinations $polKey, llm7 $llmKey",
        "Prompt   : $promptMode"
    )
}
function Credits-Line {
    param([string]$Text, [int]$Width = 74, [switch]$Center)
    if ($Text.Length -gt $Width) { $Text = $Text.Substring(0, $Width) }
    if ($Center) {
        $padTotal = $Width - $Text.Length
        $left = [Math]::Floor($padTotal / 2)
        $right = $padTotal - $left
        $Text = (" " * $left) + $Text + (" " * $right)
    }
    else {
        $Text = $Text.PadRight($Width)
    }
    W "│ " "gold" -NoNewline
    W $Text "white" -NoNewline
    W " │" "gold"
}
function Credits-Cinema {
    W ""
    $rule = "════════════════════════════════════════════════════════════════════════════"
    if ($script:animateUI) { Animate-Sweep $rule 10 12 "dim" } else { WG $rule @("gold","pink") }
    WG "╭─ CREDITS REEL ─────────────────────────────────────────────────────────────╮" @("pink","gold")
    Credits-Line "" 74
    W "│ " "gold" -NoNewline
    WG (" N O V A   C I N E M A   T E R M I N A L   A I").PadRight(74) @("pink","cyan","gold") -NoNewline
    W " │" "gold"
    Credits-Line "" 74
    W "│ " "gold" -NoNewline
    W "Made by " "white" -NoNewline
    WG "AANNIESON DITZ" @("gold","pink","cyan","green") -NoNewline
    $usedLen = ("Made by " + "AANNIESON DITZ").Length
    W ((" " * [Math]::Max(0, 74 - $usedLen)) + " │") "gold"
    Credits-Line "" 74
    Credits-Line "Providers  : Pollinations.ai + LLM7.io (no-auth)" 74
    Credits-Line "Build      : Cinema Deck v2.1 // Solar Flare Engine // SFX Rig" 74
    Credits-Line "" 74
    WG "╰────────────────────────────────────────────────────────────────────────────╯" @("gold","pink")
    if ($script:animateUI) { Animate-Sweep $rule 10 12 "dim" } else { WG $rule @("pink","gold") }
    W ""
    Play-SuccessChime
}
function Add-Log {
    param([string]$Role, [string]$Text)
    $script:chatLog += @{ role = $Role; text = $Text }
    if ($script:chatLog.Count -gt 50) { $script:chatLog = $script:chatLog[-50..-1] }
}
# ------------------------------
# MEMORY + PROVIDERS
# ------------------------------
function Build-MemoryText {
    $out = ""
    foreach ($item in $script:memory) { $out += "$item`n" }
    return $out
}
function Save-Memory {
    param([string]$UserMessage, [string]$BotReply)
    $script:memory += "User: $UserMessage"
    $script:memory += "$($script:botName): $BotReply"
    $max = $script:maxMemoryPairs * 2
    if ($script:memory.Count -gt $max) { $script:memory = $script:memory[-$max..-1] }
}
function Ask-Pollinations {
    param([string]$UserMessage)
    # Pollinations' no-auth endpoint takes the whole prompt URL-encoded into a
    # GET path, so the condensed system prompt is used here to stay well
    # under URL length limits. The full "NOVA Fable 5" prompt is reserved for
    # LLM7's JSON POST body in Ask-LLM7, where size isn't a constraint.
    $mem = Build-MemoryText
    $prompt = @"
System: $($script:systemPromptShort)

Memory:
$mem

User: $UserMessage

$($script:botName):
"@
    $encodedPrompt = [uri]::EscapeDataString($prompt)
    $encodedModel = [uri]::EscapeDataString((Resolve-ApiModel "pollinations" $script:model))
    $keyed = (Has-Key "pollinations")
    $headers = @{}
    $keyParam = ""
    if ($keyed) {
        $headers["Authorization"] = "Bearer $($script:apiKeys.pollinations)"
        $keyParam = "&key=$([uri]::EscapeDataString($script:apiKeys.pollinations))"
    }
    $url1 = "https://text.pollinations.ai/$encodedPrompt" + "?model=$encodedModel$keyParam"
    $url2 = "https://gen.pollinations.ai/text/$encodedPrompt" + "?model=$encodedModel$keyParam"
    try {
        if ($keyed) { return [string](Invoke-RestMethod -Uri $url1 -Method Get -Headers $headers) }
        else { return [string](Invoke-RestMethod -Uri $url1 -Method Get) }
    }
    catch {
        try {
            if ($keyed) { return [string](Invoke-RestMethod -Uri $url2 -Method Get -Headers $headers) }
            else { return [string](Invoke-RestMethod -Uri $url2 -Method Get) }
        }
        catch {
            if ((Is-AuthModel "pollinations" $script:model) -and -not $keyed) {
                throw "Pollinations failed. '$($script:model)' is an auth-gated model. Run /login pollinations YOUR_KEY (get one at enter.pollinations.ai)."
            }
            throw "Pollinations failed. Try /provider llm7 or /model openai-fast."
        }
    }
}
function Ask-LLM7 {
    param([string]$UserMessage)
    # LLM7's endpoint takes a normal JSON POST body, so it isn't limited by
    # URL length. It gets the full "NOVA Fable 5" system prompt.
    $messages = @(@{ role = "system"; content = $script:systemPromptFull })
    foreach ($item in $script:memory) {
        if ($item.StartsWith("User: ")) { $messages += @{ role = "user"; content = $item.Substring(6) } }
        else {
            $prefix = "$($script:botName): "
            if ($item.StartsWith($prefix)) { $messages += @{ role = "assistant"; content = $item.Substring($prefix.Length) } }
        }
    }
    $messages += @{ role = "user"; content = $UserMessage }
    $tokenValue = if (Has-Key "llm7") { $script:apiKeys.llm7 } else { "unused" }
    $headers = @{ "Authorization" = "Bearer $tokenValue"; "Content-Type" = "application/json" }
    $body = @{ model = (Resolve-ApiModel "llm7" $script:model); messages = $messages; temperature = 0.85 } | ConvertTo-Json -Depth 10
    try {
        $response = Invoke-RestMethod -Uri "https://api.llm7.io/v1/chat/completions" -Method Post -Headers $headers -Body $body
        return [string]$response.choices[0].message.content
    }
    catch {
        if ((Is-AuthModel "llm7" $script:model) -and -not (Has-Key "llm7")) {
            throw "LLM7 failed. '$($script:model)' is an auth-gated model. Run /login llm7 YOUR_TOKEN (get one at dash.llm7.io)."
        }
        throw "LLM7 failed. Try /model default, /model fast, or /provider pollinations."
    }
}
# ------------------------------
# UTILITY COMMANDS (no AI call needed / helper API calls)
# ------------------------------
function Calc-Cinema {
    param([string]$Expr)
    if ($Expr -eq "") { W "Usage: /calc 12*7+3" "gold"; return }
    try {
        # Only allow safe arithmetic characters before evaluating.
        if ($Expr -notmatch '^[0-9\.\s\+\-\*\/\%\(\)]+$') {
            W "NOVA: Only numbers and + - * / % ( ) are allowed in /calc." "gold"
            return
        }
        $result = Invoke-Expression $Expr
        Box "CALC" @("$Expr = $result") "green"
        Play-ClickBlip
    }
    catch {
        Box "CALC ERROR" @("Could not evaluate '$Expr'.") "red"
        Play-ErrorBuzz
    }
}
function Time-Cinema {
    $now = Get-Date
    $epoch = [DateTimeOffset]::new($now.ToUniversalTime()).ToUnixTimeSeconds()
    Box "SHIP CLOCK" @(
        "Local time  : $($now.ToString('yyyy-MM-dd HH:mm:ss'))",
        "Day         : $($now.DayOfWeek)",
        "Unix epoch  : $epoch"
    ) "cyan"
}
function Weather-Cinema {
    param([string]$City)
    if ($City -eq "") { W "Usage: /weather CITY" "gold"; return }
    try {
        $encoded = [uri]::EscapeDataString($City)
        $url = "https://wttr.in/$encoded" + "?format=%l:+%C+%t+(feels+%f)+humidity+%h+wind+%w"
        for ($i = 0; $i -lt 6; $i++) { Play-SpinnerTick $i }
        $result = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 12
        Box "WEATHER UPLINK" @([string]$result) "cyan"
        Play-SuccessChime
    }
    catch {
        Box "WEATHER ERROR" @("Could not reach weather uplink for '$City'. Try a different city name.") "red"
        Play-ErrorBuzz
    }
}
function Image-Cinema {
    param([string]$Prompt)
    if ($Prompt -eq "") { W "Usage: /image a cyberpunk city at night" "gold"; return }
    try {
        if (-not (Test-Path $script:imageOutDir)) { New-Item -ItemType Directory -Path $script:imageOutDir | Out-Null }
        $encodedPrompt = [uri]::EscapeDataString($Prompt)
        $seed = Get-Random -Minimum 1 -Maximum 999999
        $url = "https://image.pollinations.ai/prompt/$encodedPrompt" + "?width=768&height=768&seed=$seed&nologo=true"
        if (Has-Key "pollinations") { $url += "&key=$([uri]::EscapeDataString($script:apiKeys.pollinations))" }
        $safeName = ($Prompt -replace '[^a-zA-Z0-9]+', '-').Trim('-').ToLower()
        if ($safeName.Length -gt 40) { $safeName = $safeName.Substring(0, 40) }
        if ($safeName -eq "") { $safeName = "nova-render" }
        $fileName = "$safeName-$seed.jpg"
        $fullPath = Join-Path $script:imageOutDir $fileName
        W ""
        W "NOVA " "pink" -NoNewline
        W "rendering image frame..." "dim"
        Play-ShutterSound
        for ($i = 0; $i -lt 10; $i++) { Play-SpinnerTick $i; Start-Sleep -Milliseconds 60 }
        Invoke-WebRequest -Uri $url -OutFile $fullPath -TimeoutSec 60
        Play-ShutterSound
        Box "IMAGE RENDERED" @(
            "Prompt : $Prompt",
            "File   : $fullPath",
            "Seed   : $seed"
        ) "green"
        Play-SuccessChime
    }
    catch {
        Box "IMAGE ERROR" @("Image generation failed. Pollinations image gateway may be busy, try again shortly.") "red"
        Play-ErrorBuzz
    }
}
function Ask-Nova {
    param([string]$UserMessage)
    try {
        Add-Log "you" $UserMessage
        Spinner-Cinema
        $start = Get-Date
        if ($script:provider -eq "pollinations") { $reply = Ask-Pollinations $UserMessage }
        elseif ($script:provider -eq "llm7") { $reply = Ask-LLM7 $UserMessage }
        else { throw "Unknown provider." }
        $ms = [Math]::Round(((Get-Date) - $start).TotalMilliseconds)
        Play-SuccessChime
        WG "╭─ NOVA RESPONSE // FRAME RENDERED IN $($ms)MS ───────────────────────────────" @("pink","cyan")
        foreach ($line in (Wrap-Text $reply 74)) {
            W "│ " "cyan" -NoNewline
            Type-Text $line "green" $script:typeDelay
        }
        WG "╰────────────────────────────────────────────────────────────────────────────" @("cyan","pink")
        W ""
        Add-Log "nova" $reply
        Save-Memory $UserMessage $reply
    }
    catch {
        Play-ErrorBuzz
        Box "NOVA ERROR" @([string]$_) "red"
    }
}
# ------------------------------
# ============================================================
# NOVA CINEMA TERMINAL AI — v3.0 ADD-ON MODULE
# Drop-in upgrade for v2.1
# Dot-source AFTER loading nova-cinema-v2.1.ps1:
#   . .\nova-cinema-v2.1.ps1  # or paste v2.1, then:
#   . .\nova-v3-addons.ps1
# ============================================================

# ---------- v3 STATE ----------
if (-not $script:nova3) { $script:nova3 = @{} }
$script:nova3.version      = "3.0-sprintA"
$script:nova3.streaming    = $true
$script:nova3.crt          = $false
$script:nova3.a11y         = $false
$script:nova3.splitPane    = $true
$script:nova3.temperature  = 0.85
$script:nova3.top_p        = 1.0
$script:nova3.voiceOut     = $false
$script:nova3.autoTheme    = $false
$script:nova3.sessionDir   = Join-Path (Get-Location) "nova-sessions"
$script:nova3.exportDir    = Join-Path (Get-Location) "nova-exports"
$script:nova3.tokenInEst   = 0
$script:nova3.tokenOutEst  = 0
$script:nova3.lastLatency  = 0

# add 4 new themes, non-destructive
$script:themes['hacker'] = @{
    pink="#00ff41"; purple="#008f11"; cyan="#00ff9c"; cyan2="#39ff14"
    blue="#003b00"; gold="#baff39";  red="#ff3b3b";  green="#00ff41"
    dim="#4a7c59";  white="#d0ffd6"; dark="#001400"; auraA="#00ff41"; auraB="#baff39"
}
$script:themes['sakura'] = @{
    pink="#ff8fab"; purple="#c9184a"; cyan="#ffc8dd"; cyan2="#ffafcc"
    blue="#a4133c"; gold="#ffd6e7";  red="#ff4d6d";  green="#ffb3c6"
    dim="#b5838d";  white="#fff0f3"; dark="#2b0a14"; auraA="#ff8fab"; auraB="#ffc8dd"
}
$script:themes['matrix'] = @{
    pink="#00ff41"; purple="#00a030"; cyan="#9dff00"; cyan2="#d0ff14"
    blue="#003b00"; gold="#9dff00";  red="#ff3131";  green="#00ff41"
    dim="#2f6f2f";  white="#c8ffc8"; dark="#000f00"; auraA="#00ff41"; auraB="#9dff00"; rgbCycle=$false
}
$script:themes['ember'] = @{
    pink="#ff6b35"; purple="#9a1f00"; cyan="#ff9e00"; cyan2="#ffca3a"
    blue="#6a040f"; gold="#ffb703";  red="#d00000";  green="#ffba08"
    dim="#a68a64";  white="#fff1d6"; dark="#1a0600"; auraA="#ff6b35"; auraB="#ffb703"
}

# ---------- UTIL ----------
function Nova3-EstimateTokens { param([string]$s) if ([string]::IsNullOrEmpty($s)) { return 0 }; return [Math]::Ceiling($s.Length / 3.8) }
function Nova3-GetConsoleWidth { try { return [Math]::Max(80, $host.UI.RawUI.WindowSize.Width) } catch { return 100 } }

function Nova3-AutoThemeTick {
    if (-not $script:nova3.autoTheme) { return }
    $h = (Get-Date).Hour
    $target = if ($h -ge 6 -and $h -lt 18) { 'solar' } elseif ($h -ge 18 -and $h -lt 22) { 'aurora' } else { 'void' }
    if ($script:themes.ContainsKey($target) -and $script:theme -ne $target) { $script:theme = $target }
}

# ---------- MARKDOWN CINEMATIC RENDER ----------
function Write-MarkdownCinema {
    param([string]$Text, [int]$Width = 74)
    $inCode = $false
    $codeLang = ""
    $codeBuf = @()
    foreach ($raw in ($Text -split "`n")) {
        if ($raw -match '^```(.*)') {
            if (-not $inCode) { $inCode = $true; $codeLang = $matches[1]; $codeBuf = @(); 
                W "│ ┌─ code" "dim"; if ($codeLang) { W " [$codeLang]" "gold" }; Write-Host ""
                continue
            } else {
                # render buffered code
                foreach ($cl in $codeBuf) {
                    W "│ │ " "dark" -NoNewline
                    # ultra-simple highlight
                    $hl = $cl -replace '\b(function|return|if|else|for|while|param|try|catch)\b', "$($script:ESC)[38;2;0;255;200m`$1$($script:ESC)[0m"
                    Write-Host $hl
                }
                W "│ └─────────────────────────────────────────────────────────" "dark"
                $inCode = $false; continue
            }
        }
        if ($inCode) { $codeBuf += $raw; continue }
        if ($raw -match '^#{1,3}\s+(.*)') { W "│ " "cyan" -NoNewline; WGR $matches[1] @("pink","cyan") 0.2; continue }
        if ($raw -match '^\s*[-*]\s+(.*)') { W "│  • " "gold" -NoNewline; W $matches[1] "white"; continue }
        foreach ($line in (Wrap-Text $raw $Width)) { W "│ " "cyan" -NoNewline; W $line "white" }
    }
}

# ---------- 3-PANE ----------
function Draw-ThreePane {
    Nova3-AutoThemeTick
    $w = Nova3-GetConsoleWidth
    $leftW = 22; $rightW = 24; $midW = $w - $leftW - $rightW - 6
    if ($midW -lt 48 -or -not $script:nova3.splitPane) { Draw-CinemaUI; return }
    Clear-Host
    Logo-Cinema
    # top ticker
    $ticker = " NOVA v3 // $($script:provider)/$($script:model) // $(Get-Date -Format 'HH:mm:ss') // tok $($script:nova3.tokenInEst + $script:nova3.tokenOutEst) // $($script:nova3.lastLatency)ms "
    if (Is-RgbTheme) { WGR $ticker.PadRight($w-1) @("pink","cyan") (Next-RainbowPhase 0.04) } else { WG $ticker.PadRight($w-1) @("cyan","pink") }
    W ("─" * ($w-1)) "dim"
    # 3 columns - simple row-by-row
    $leftLines = @(
        " AI LINK",
        " $($script:provider)",
        " $($script:model)",
        " $(Model-Cat) • $(Model-Tag)",
        "",
        " [M]odels",
        " [T]hemes",
        " [S]can"
    )
    $rightLines = @(
        " TELEMETRY",
        " tok/s ~42",
        " temp $($script:nova3.temperature)",
        " in $($script:nova3.tokenInEst)",
        " out $($script:nova3.tokenOutEst)",
        "",
        " AURA $(MemoryPercent)%",
        " SFX $(if($script:soundUI){'♪'}else{'·'})"
    )
    $chatLines = @()
    if ($script:chatLog.Count -eq 0) { $chatLines = @("No messages yet. Scene clear.") }
    else {
        $start = [Math]::Max(0, $script:chatLog.Count - 12)
        for ($i=$start; $i -lt $script:chatLog.Count; $i++) {
            $e = $script:chatLog[$i]
            foreach ($l in (Wrap-Text "$($e.role): $($e.text)" ($midW-2))) { $chatLines += $l }
        }
    }
    $rows = [Math]::Max($leftLines.Count, [Math]::Max($rightLines.Count, $chatLines.Count))
    for ($r=0; $r -lt $rows; $r++) {
        $L = if ($r -lt $leftLines.Count) { $leftLines[$r].PadRight($leftW) } else { " " * $leftW }
        $M = if ($r -lt $chatLines.Count) { $chatLines[$r].PadRight($midW) } else { " " * $midW }
        $R = if ($r -lt $rightLines.Count) { $rightLines[$r].PadRight($rightW) } else { " " * $rightW }
        W $L "dim" -NoNewline; W " │ " "cyan" -NoNewline; W $M "white" -NoNewline; W " │ " "cyan" -NoNewline; W $R "dim"
        if ($script:nova3.crt -and ($r % 3 -eq 2)) { W (" " * $leftW + "   " + ("·" * $midW)) "dark" }
    }
    W ("─" * ($w-1)) "dim"
    W " /help /models /code /persona /web /image /stats /export    split:$($script:nova3.splitPane)  crt:$($script:nova3.crt)  a11y:$($script:nova3.a11y)" "dim"
    W ""
}

# override Draw-CinemaUI if split is on
$script:nova3._origDrawCinemaUI = (Get-Command Draw-CinemaUI).ScriptBlock
function Draw-CinemaUI { if ($script:nova3.splitPane) { Draw-ThreePane } else { & $script:nova3._origDrawCinemaUI } }

# ---------- STREAMING LLM7 ----------
function Start-StreamingLLM7 {
    param([string]$UserMessage)
    $messages = @(@{ role="system"; content=$script:systemPromptFull })
    foreach ($item in $script:memory) {
        if ($item.StartsWith("User: ")) { $messages += @{ role="user"; content=$item.Substring(6) } }
        else { $p="$($script:botName): "; if ($item.StartsWith($p)) { $messages += @{ role="assistant"; content=$item.Substring($p.Length) } } }
    }
    $messages += @{ role="user"; content=$UserMessage }
    $tokenValue = if (Has-Key "llm7") { $script:apiKeys.llm7 } else { "unused" }
    $headers = @{ "Authorization"="Bearer $tokenValue"; "Content-Type"="application/json"; "Accept"="text/event-stream" }
    $bodyObj = @{ model=(Resolve-ApiModel "llm7" $script:model); messages=$messages; temperature=$script:nova3.temperature; top_p=$script:nova3.top_p; stream=$true }
    $body = $bodyObj | ConvertTo-Json -Depth 10 -Compress
    $replySb = New-Object System.Text.StringBuilder
    try {
        $req = [System.Net.HttpWebRequest]::Create("https://api.llm7.io/v1/chat/completions")
        $req.Method="POST"; $req.ContentType="application/json"; $req.Headers.Add("Authorization","Bearer $tokenValue"); $req.Accept="text/event-stream"; $req.Timeout=60000
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body); $req.ContentLength=$bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse(); $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        WG "╭─ NOVA STREAM // LLM7 ────────────────────────────────────────────────" @("pink","cyan")
        Write-Host "│ " -NoNewline -ForegroundColor Cyan
        $col=0
        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ($line -like "data: *") {
                $payload = $line.Substring(6).Trim()
                if ($payload -eq "[DONE]") { break }
                try {
                    $j = $payload | ConvertFrom-Json
                    $delta = $j.choices[0].delta.content
                    if ($delta) {
                        [void]$replySb.Append($delta)
                        # live type, color-aware
                        if (Is-RgbTheme) { $code = Rainbow-Ansi ((Next-RainbowPhase 0.008)) 0.8 1.0; Write-Host "$code$delta$($script:ESC)[0m" -NoNewline }
                        else { Write-Host $delta -NoNewline -ForegroundColor Green }
                        $col += $delta.Length
                        if ($col -gt 74) { Write-Host ""; Write-Host "│ " -NoNewline -ForegroundColor Cyan; $col=0 }
                    }
                } catch {}
            }
            if ([console]::KeyAvailable) { $k=[console]::ReadKey($true); if ($k.Key -eq 'Escape') { break } }
        }
        Write-Host ""; WG "╰────────────────────────────────────────────────────────────────────────" @("cyan","pink")
        return $replySb.ToString()
    } catch {
        throw "LLM7 stream failed: $_"
    }
}

# ---------- COMMAND PALETTE ----------
function Show-CommandPalette {
    W ""; W "╭─ COMMAND PALETTE — type to filter, empty = all ─────────" "gold"
    W "│ > " "cyan" -NoNewline
    $q = Read-Host
    $cmds = @(
        "/help","/models","/model","/provider llm7","/provider pollinations","/theme aurora","/theme hacker","/theme sakura","/theme matrix","/theme ember",
        "/code","/persona","/web","/image","/vision","/speak","/stats","/export","/save","/load","/temp","/duel","/scan","/matrix","/flare","/aurora",
        "/animate on","/animate off","/sound on","/sound off","/crt on","/crt off","/split on","/split off","/a11y on","/a11y off","/reset","/current"
    )
    if ($q) { $cmds = $cmds | Where-Object { $_ -like "*$q*" } }
    $i=1; foreach ($c in $cmds | Select-Object -First 12) { W "│ [$i] $c" "white"; $i++ }
    W "╰────────────────────────────────────────────────────────" "gold"
    W "pick # or Enter to cancel: " "dim" -NoNewline
    $p = Read-Host
    $n=0; if ([int]::TryParse($p,[ref]$n) -and $n -ge 1 -and $n -le $cmds.Count) { return $cmds[$n-1] }
    return $null
}

# ---------- SESSIONS ----------
function Save-Session { param([string]$Name="auto")
    if (-not (Test-Path $script:nova3.sessionDir)) { New-Item -ItemType Directory -Path $script:nova3.sessionDir | Out-Null }
    $file = Join-Path $script:nova3.sessionDir "nova-$Name-$(Get-Date -Format yyyyMMdd-HHmm).json"
    $obj = @{ provider=$script:provider; model=$script:model; theme=$script:theme; memory=$script:memory; chatLog=$script:chatLog; ts=Get-Date }
    ($obj | ConvertTo-Json -Depth 8) | Set-Content -Path $file -Encoding UTF8
    W "NOVA: Session saved → $file" "green"
}
function Load-Session { param([string]$Path)
    if (-not $Path -or -not (Test-Path $Path)) {
        if (Test-Path $script:nova3.sessionDir) {
            $latest = Get-ChildItem $script:nova3.sessionDir -Filter *.json | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($latest) { $Path = $latest.FullName } else { W "No sessions found." "gold"; return }
        } else { W "No sessions folder." "gold"; return }
    }
    $o = Get-Content $Path -Raw | ConvertFrom-Json
    $script:provider=$o.provider; $script:model=$o.model; $script:theme=$o.theme
    $script:memory = @($o.memory); $script:chatLog = @($o.chatLog)
    W "NOVA: Session restored from $Path" "green"
}

# ---------- WEB TOOL ----------
function Invoke-WebTool { param([string]$Query)
    if (-not $Query) { W "Usage: /web <search terms>" "gold"; return }
    try {
        $q = [uri]::EscapeDataString($Query)
        $html = Invoke-RestMethod -Uri "https://duckduckgo.com/html/?q=$q" -TimeoutSec 12 -Headers @{ "User-Agent"="Mozilla/5.0" }
        # naive strip
        $text = ($html -replace '<[^>]+>',' ' -replace '\s+',' ').Substring(0, [Math]::Min(1800, $html.Length))
        $summaryPrompt = "Summarize these web results for '$Query' in 5 concise bullets, then a 2-sentence takeaway:`n$text"
        Ask-Nova $summaryPrompt
    } catch { Box "WEB ERROR" @("Web fetch failed: $_") "red" }
}

# ---------- TTS ----------
function Speak-Reply { param([string]$Text)
    try {
        Add-Type -AssemblyName System.Speech
        $s = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $s.Rate = 0; $s.Volume = 90
        $s.SpeakAsync($Text) | Out-Null
        W "🔊 speaking…" "dim"
    } catch { W "TTS unavailable: $_" "gold" }
}

# ---------- PERSONAS ----------
$script:nova3.personas = @{
    "nova"     = $script:systemPromptFull
    "coder"    = "You are NOVA CODER. Output clean, correct code first, then a 2-line explanation. No fluff. Prefer PowerShell, Python, JS."
    "analyst"  = "You are NOVA ANALYST. Structured, concise, cite assumptions, give numbers, then recommendation."
    "roleplay" = "You are NOVA, cinematic roleplay partner. Vivid, in-character, PG-13, ask 1 question max per turn."
    "therapist"= "You are NOVA, supportive listener. Validate feelings, no diagnosis, offer general coping ideas, encourage professional help if needed."
    "fable"    = $script:systemPromptFull
}
function Set-Persona { param([string]$Name)
    $Name = $Name.ToLower()
    if ($script:nova3.personas.ContainsKey($Name)) {
        $script:systemPromptFull = $script:nova3.personas[$Name]
        W "NOVA: Persona → $Name" "green"
    } else { W "Personas: $($script:nova3.personas.Keys -join ', ')" "gold" }
}

# ---------- STATS / EXPORT ----------
function Show-Stats {
    $turns = [Math]::Floor($script:memory.Count/2)
    Box "NOVA STATS v3" @(
        "Turns        : $turns",
        "Memory lines : $($script:memory.Count)/$($script:maxMemoryPairs*2)",
        "Tokens in≈   : $($script:nova3.tokenInEst)",
        "Tokens out≈  : $($script:nova3.tokenOutEst)",
        "Last latency : $($script:nova3.lastLatency) ms",
        "Provider     : $($script:provider) / $($script:model)",
        "Temp / top_p : $($script:nova3.temperature) / $($script:nova3.top_p)",
        "Theme        : $($script:theme)",
        "Split / CRT  : $($script:nova3.splitPane) / $($script:nova3.crt)",
        "SFX / Anim   : $($script:soundUI) / $($script:animateUI)"
    ) "cyan"
}
function Export-Transcript { param([string]$Fmt="md")
    if (-not (Test-Path $script:nova3.exportDir)) { New-Item -ItemType Directory -Path $script:nova3.exportDir | Out-Null }
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $path = Join-Path $script:nova3.exportDir "nova-transcript-$ts.$Fmt"
    if ($Fmt -eq "md") {
        $md = "# NOVA Cinema Transcript — $ts`n`nProvider: $($script:provider) / $($script:model)`n`n"
        foreach ($e in $script:chatLog) { $md += "### $($e.role.ToUpper())`n$($e.text)`n`n" }
        $md | Set-Content $path -Encoding UTF8
    } else {
        ($script:chatLog | ConvertTo-Json -Depth 5) | Set-Content $path -Encoding UTF8
    }
    W "Exported → $path" "green"
}

# ---------- OVERRIDE Ask-Nova for v3 streaming ----------
$script:nova3._origAskNova = (Get-Command Ask-Nova).ScriptBlock
function Ask-Nova {
    param([string]$UserMessage)
    try {
        Add-Log "you" $UserMessage
        $script:nova3.tokenInEst += Nova3-EstimateTokens $UserMessage
        $start = Get-Date
        if ($script:provider -eq "llm7" -and $script:nova3.streaming) {
            $reply = Start-StreamingLLM7 $UserMessage
        } else {
            Spinner-Cinema
            if ($script:provider -eq "pollinations") { $reply = Ask-Pollinations $UserMessage }
            elseif ($script:provider -eq "llm7") { $reply = Ask-LLM7 $UserMessage }
            else { throw "Unknown provider." }
            WG "╭─ NOVA RESPONSE ─────────────────────────────────────────────────" @("pink","cyan")
            Write-MarkdownCinema $reply 74
            WG "╰─────────────────────────────────────────────────────────────────" @("cyan","pink")
        }
        $script:nova3.lastLatency = [Math]::Round(((Get-Date)-$start).TotalMilliseconds)
        $script:nova3.tokenOutEst += Nova3-EstimateTokens $reply
        Add-Log "nova" $reply
        Save-Memory $UserMessage $reply
        if ($script:nova3.voiceOut) { Speak-Reply $reply }
        Play-SuccessChime
    } catch {
        Play-ErrorBuzz
        Box "NOVA ERROR" @([string]$_) "red"
    }
}

# ---------- COMMAND HOOK — call this in your main input loop ----------
# Replace your big if/elseif chain with a call to Nova3-HandleCommand first.
# Returns $true if handled, $false if not — then fall through to Ask-Nova.
function Nova3-HandleCommand {
    param([string]$InputLine)
    $lower = $InputLine.ToLower()
    switch -Regex ($lower) {
        '^/palette$'            { $cmd = Show-CommandPalette; if ($cmd) { W "» $cmd" "gold"; return Nova3-HandleCommand $cmd }; return $true }
        '^/split (on|off|\s*)$' { if ($matches[1] -eq 'off') { $script:nova3.splitPane=$false } else { $script:nova3.splitPane=$true }; Draw-CinemaUI; return $true }
        '^/crt (on|off)$'       { $script:nova3.crt = ($matches[1] -eq 'on'); W "CRT: $($script:nova3.crt)" "green"; return $true }
        '^/a11y (on|off)$'      { $script:nova3.a11y = ($matches[1] -eq 'on'); if ($script:nova3.a11y){ $script:animateUI=$false; $script:typeDelay=6 }; W "A11y: $($script:nova3.a11y)" "green"; return $true }
        '^/temp ([\d\.]+)$'     { $script:nova3.temperature = [double]$matches[1]; W "temp = $($script:nova3.temperature)" "green"; return $true }
        '^/persona\s+(\w+)$'    { Set-Persona $matches[1]; return $true }
        '^/persona$'            { W "Personas: $($script:nova3.personas.Keys -join ', ')" "gold"; return $true }
        '^/code\s+(.+)$'        { $p=$matches[1]; $old=$script:systemPromptFull; $script:systemPromptFull=$script:nova3.personas['coder']; Ask-Nova $p; $script:systemPromptFull=$old; return $true }
        '^/web\s+(.+)$'         { Invoke-WebTool $matches[1]; return $true }
        '^/speak\s+(.+)$'       { Speak-Reply $matches[1]; return $true }
        '^/voice (on|off)$'     { $script:nova3.voiceOut = ($matches[1] -eq 'on'); W "Voice out: $($script:nova3.voiceOut)" "green"; return $true }
        '^/stats$'              { Show-Stats; return $true }
        '^/export(\s+\w+)?$'    { $fmt = if ($matches[1]){$matches[1].Trim()}else{"md"}; Export-Transcript $fmt; return $true }
        '^/save(\s+\w+)?$'      { $n = if ($matches[1]){$matches[1].Trim()}else{"auto"}; Save-Session $n; return $true }
        '^/load(\s+.+)?$'       { $p = if ($matches[1]){$matches[1].Trim()}else{""}; Load-Session $p; return $true }
        '^/duel\s+(.+)$'        { W "Duel mode — running llm7 default vs pollinations openai-fast…" "cyan"; $q=$matches[1]; $sp=$script:provider; $sm=$script:model; $script:provider='llm7'; $script:model='default'; Ask-Nova $q; $script:provider='pollinations'; $script:model='openai-fast'; Ask-Nova $q; $script:provider=$sp; $script:model=$sm; return $true }
        '^/stream (on|off)$'    { $script:nova3.streaming = ($matches[1] -eq 'on'); W "Streaming: $($script:nova3.streaming)" "green"; return $true }
        '^/autotheme (on|off)$' { $script:nova3.autoTheme = ($matches[1] -eq 'on'); W "Auto-theme: $($script:nova3.autoTheme)" "green"; return $true }
        default { return $false }
    }
}

# Patch tip:
# In your main while($true) loop, right after $lower = $userInput.ToLower(), insert:
#   if (Nova3-HandleCommand $userInput) { continue }
# Then your existing elseif chain stays intact.

W ""
W "╔════════════════════════════════════════════════════════════╗" "gold"
W "║  NOVA v3.0 ADD-ONS LOADED                                ║" "cyan"
W "║  /palette  /split on  /code  /persona  /web  /stats      ║" "green"
W "║  streaming LLM7 • markdown render • 4 new themes         ║" "pink"
W "╚════════════════════════════════════════════════════════════╝" "gold"
W "Hook: if (Nova3-HandleCommand `$userInput) { continue }" "dim"
W ""
# ------------------------------
# NOVA v3 UI OVERRIDES
# ------------------------------

function Logo-Cinema {
    W ""
    WGR "  ███╗   ██╗  ██████╗ ██╗   ██╗  █████╗       ▓▓ CINEMA MODE v3 ▓▓" @("cyan","pink") 0.0
    WGR "  ████╗  ██║ ██╔═══██╗██║   ██║ ██╔══██╗      NEXUS ONLINE // NO-AUTH AI" @("cyan","pink") 0.08
    WGR "  ██╔██╗ ██║ ██║   ██║██║   ██║ ███████║      DUAL GATEWAY + STREAM ENGINE" @("pink","cyan") 0.16
    WGR "  ██║╚██╗██║ ██║   ██║╚██╗ ██╔╝ ██╔══██║      36 MODELS // 11 THEMES" @("pink","cyan") 0.24
    WGR "  ██║ ╚████║ ╚██████╔╝ ╚████╔╝  ██║  ██║      CYBERDECK BUILD 3.0 // SFX+STREAM" @("cyan","pink") 0.32
    WGR "  ╚═╝  ╚═══╝  ╚═════╝   ╚═══╝   ╚═╝  ╚═╝" @("pink","cyan") 0.40
}

function Help-Cinema {
    Box "COMMANDS v3" @(
        "/help                          Show this command reel",
        "/palette                       Fuzzy command palette",
        "/ui or /clear                  Redraw cinema UI",
        "/split on|off                  Toggle 3-pane cyberdeck",
        "/providers                     Show providers",
        "/provider llm7                 Switch to LLM7",
        "/provider pollinations         Switch to Pollinations + gpt-5-nano",
        "/models [chat|code|vision|reasoning|roleplay]  Show models",
        "/allmodels                     All no-auth models",
        "/authmodels [cat]              Premium models",
        "/pick N                        Pick from last /models list",
        "/model NAME                    Switch model",
        "/current                       Show current config",
        "/temp 0.2–1.5                  Set sampling temperature",
        "/stream on|off                 Toggle LLM7 streaming",
        "/persona coder|analyst|roleplay|therapist|nova|fable  Switch system prompt",
        "/code <prompt>                 Coder persona one-shot",
        "/web <query>                   Web summarize via DuckDuckGo",
        "/image PROMPT                  Pollinations image render",
        "/vision <path> <prompt>        Vision analyze (use qwen-vision)",
        "/speak <text>                  TTS speak",
        "/voice on|off                  Auto-speak replies",
        "/calc EXPR                     Safe calculator",
        "/time                          Ship clock",
        "/weather CITY                  Live weather",
        "/stats                         Tokens, latency, turns",
        "/save [name]  /load [path]     Session persistence",
        "/export md|json                Export transcript",
        "/duel <prompt>                 Run llm7 vs pollinations",
        "/scan /matrix /glitch /flare   Cinematics",
        "/aurora calm|storm             RGB aurora",
        "/curtain /logo                 Transitions",
        "/theme bloxd|void|blood|ice|solar|neon|aurora|hacker|sakura|matrix|ember",
        "/autotheme on|off              Auto time-of-day theme",
        "/crt on|off                    CRT scanlines",
        "/a11y on|off                   Accessibility mode",
        "/animate on|off   /sound on|off",
        "/speed 0-50                    Typing speed",
        "/reset                         Clear memory",
        "/credits                       Credits reel",
        "exit                           Quit"
    )
}

# v3 Credits override
function Credits-Cinema {
    W ""
    $rule = "════════════════════════════════════════════════════════════════════════════"
    if ($script:animateUI) { Animate-Sweep $rule 10 12 "dim" } else { WG $rule @("gold","pink") }
    WG "╭─ CREDITS REEL ─────────────────────────────────────────────────────────────╮" @("pink","gold")
    Credits-Line "" 74
    W "│ " "gold" -NoNewline
    WG (" N O V A   C I N E M A   T E R M I N A L   A I   v 3").PadRight(74) @("pink","cyan","gold") -NoNewline
    W " │" "gold"
    Credits-Line "" 74
    W "│ " "gold" -NoNewline
    W "Made by " "white" -NoNewline
    WG "AANNIESON DITZ" @("gold","pink","cyan","green") -NoNewline
    $usedLen = ("Made by " + "AANNIESON DITZ").Length
    W ((" " * [Math]::Max(0, 74 - $usedLen)) + " │") "gold"
    Credits-Line "" 74
    Credits-Line "Providers  : Pollinations.ai + LLM7.io (no-auth + stream)" 74
    Credits-Line "Build      : Cinema Deck v3.0 // Stream Engine // 3-Pane HUD" 74
    Credits-Line "Features   : streaming LLM7 • markdown • personas • /code • /web" 74
    Credits-Line "             /stats • /save • /export • TTS • 11 themes" 74
    Credits-Line "" 74
    WG "╰────────────────────────────────────────────────────────────────────────────╯" @("gold","pink")
    if ($script:animateUI) { Animate-Sweep $rule 10 12 "dim" } else { WG $rule @("pink","gold") }
    W ""
    Play-SuccessChime
}

# Boot banner v3
function Boot-Cinema {
    Clear-Host
    Play-BootJingle
    if ($script:animateUI) {
        if (Is-RgbTheme) { Aurora-Cinema "calm" } else { Flare-Cinema 2 }
    }
    Clear-Host
    WGR "╔══════════════════════════════════════════════════════════════════════════════╗" @("gold","pink") 0.1
    WGR "║                       N O V A   C I N E M A   v 3                          ║" @("cyan","gold") 0.3
    WGR "╚══════════════════════════════════════════════════════════════════════════════╝" @("gold","pink") 0.5
    W ""
    $boot = @(
        "igniting AURORA RGB render pipeline v3",
        "loading 3-pane cyberdeck HUD",
        "charging live rainbow aura rails",
        "mounting Pollinations no-auth gateway (20 models)",
        "mounting LLM7 streaming gateway (16 models)",
        "enabling SSE token streamer",
        "warming markdown cinematic renderer",
        "loading personas: coder, analyst, roleplay, therapist",
        "priming TTS / web tools / session vault",
        "calibrating live animation engine",
        "priming synthesized sound rig",
        "cinema deck v3 online"
    )
    foreach ($b in $boot) {
        W "[" "dim" -NoNewline
        W " SCENE " "gold" -NoNewline
        W "] " "dim" -NoNewline
        Play-BootTick
        Type-Text $b "cyan" 6
        CinematicPause 70
    }
    Play-SuccessChime
    CinematicPause 250
}

# Update Draw-CommandDeck to v3
function Draw-CommandDeck {
    W ""
    W "╭─ COMMAND REEL v3 ───────────────────────────────────────────────────────────╮" "pink"
    W "│ " "pink" -NoNewline
    W "[1] LLM7" "cyan" -NoNewline; W "  " "dim" -NoNewline
    W "[2] Pollinations" "pink" -NoNewline; W "  " "dim" -NoNewline
    W "[3] Models" "cyan" -NoNewline; W "  " "dim" -NoNewline
    W "[4] Scan" "gold" -NoNewline; W "  " "dim" -NoNewline
    W "[5] Matrix" "green" -NoNewline; W "  " "dim" -NoNewline
    W "[6] /palette" "pink" -NoNewline; W "  " "dim" -NoNewline
    W "[7] Redraw" "cyan" -NoNewline
    W "                  │" "pink"
    W "│ " "pink" -NoNewline
    W "/models /pick N /code PROMPT /persona NAME /web QUERY /stats /export" "dim"
    W " │" "pink"
    W "│ " "pink" -NoNewline
    $animState = if ($script:animateUI) { "ON" } else { "OFF" }
    $soundState = if ($script:soundUI) { "ON" } else { "OFF" }
    $splitState = if ($script:nova3.splitPane) { "3PANE" } else { "CLASSIC" }
    W "/split on|off ($splitState)  /animate $animState  /sound $soundState  /stream $($script:nova3.streaming)" "dim"
    W " │" "pink"
    W "│ " "pink" -NoNewline
    W "/theme hacker|sakura|matrix|ember|aurora|neon|solar|ice|blood|void|bloxd   /temp N" "dim"
    W " │" "pink"
    W "│ " "pink" -NoNewline
    W "/image PROMPT  /speak TEXT  /voice on|off  /save  /load  /duel PROMPT" "dim"
    W "  │" "pink"
    W "╰────────────────────────────────────────────────────────────────────────────╯" "pink"
}

# make theme list in /theme command accept new themes
# patch: override the theme-switch block via wrapper? We'll just leave original handler – it checks $script:themes.ContainsKey which now includes 4 new themes, so it works.
# Just update error message via wrapper is optional.

# Tweak Current-Cinema to show v3 stats
$script:nova3._origCurrentCinema = (Get-Command Current-Cinema -ErrorAction SilentlyContinue).ScriptBlock
function Current-Cinema {
    $isAuth = Is-AuthModel
    $accessLine = if ($isAuth) { if (Has-Key $script:provider) { "AUTH model, key linked" } else { "AUTH model, NO KEY LINKED" } } else { "no-auth model" }
    $polKey = if (Has-Key "pollinations") { "linked" } else { "not linked" }
    $llmKey = if (Has-Key "llm7") { "linked" } else { "not linked" }
    $promptMode = if ($script:provider -eq "llm7") { "full (NOVA Fable 5)" } else { "condensed (URL-safe)" }
    Box "CURRENT SCENE v3" @(
        "Provider : $($script:provider)",
        "Model    : $($script:model)",
        "API ID   : $(Resolve-ApiModel)",
        "Category : $(Model-Cat)",
        "Status   : $(Model-Tag)",
        "Access   : $accessLine",
        "Temp     : $($script:nova3.temperature)  top_p: $($script:nova3.top_p)  stream: $($script:nova3.streaming)",
        "Theme    : $($script:theme)  split: $($script:nova3.splitPane)  crt: $($script:nova3.crt)",
        "Speed    : $($script:typeDelay) ms  Sound: $(if ($script:soundUI) { 'on' } else { 'off' })  Voice: $($script:nova3.voiceOut)",
        "Tokens≈  : in $($script:nova3.tokenInEst)  out $($script:nova3.tokenOutEst)  latency $($script:nova3.lastLatency)ms",
        "Memory   : $($script:memory.Count) lines",
        "Keys     : pollinations $polKey, llm7 $llmKey",
        "Prompt   : $promptMode",
        "Persona  : $(if($script:systemPromptFull -eq $script:nova3.personas['coder']) {'coder'} else {'nova'})"
    )
}
# START
# ------------------------------
Boot-Cinema
Credits-Cinema
CinematicPause 900
Draw-CinemaUI
while ($true) {
    Prompt-Cinema
    $userInput = Read-Host
    if ($null -eq $userInput) { continue }
    $userInput = $userInput.Trim()
    if ($userInput -eq "") { continue }
    if ($userInput -eq "1") { $userInput = "/provider llm7" }
    elseif ($userInput -eq "2") { $userInput = "/provider pollinations" }
    elseif ($userInput -eq "3") { $userInput = "/allmodels" }
    elseif ($userInput -eq "4") { $userInput = "/scan" }
    elseif ($userInput -eq "5") { $userInput = "/matrix" }
    elseif ($userInput -eq "6") { $userInput = "/help" }
    elseif ($userInput -eq "7") { $userInput = "/ui" }
    $lower = $userInput.ToLower()
    # --- NOVA v3 command router ---
    if (Get-Command Nova3-HandleCommand -ErrorAction SilentlyContinue) {
        if (Nova3-HandleCommand $userInput) { continue }
    }
    if ($lower -eq "exit") { Play-ErrorBuzz; W "NOVA: Cutting feed. Cinema deck offline." "green"; break }
    elseif ($lower -eq "/help") { Help-Cinema; continue }
    elseif ($lower -eq "/ui" -or $lower -eq "/clear") { Draw-CinemaUI; continue }
    elseif ($lower -eq "/providers") { Providers-Cinema; continue }
    elseif ($lower -eq "/models") { Models-Cinema $script:provider; continue }
    elseif ($lower.StartsWith("/models ")) {
        $cat = $userInput.Substring(8).Trim().ToLower()
        Models-Cinema $script:provider $cat
        continue
    }
    elseif ($lower -eq "/allmodels") { AllModels-Cinema; continue }
    elseif ($lower -eq "/authmodels") { AuthModels-Cinema $script:provider; continue }
    elseif ($lower.StartsWith("/authmodels ")) {
        $cat = $userInput.Substring(12).Trim().ToLower()
        AuthModels-Cinema $script:provider $cat
        continue
    }
    elseif ($lower -eq "/allauthmodels") { AllAuthModels-Cinema; continue }
    elseif ($lower.StartsWith("/login ")) {
        $rest = $userInput.Substring(7).Trim()
        $parts = $rest -split '\s+', 2
        if ($parts.Count -lt 2) { W "Usage: /login pollinations YOUR_KEY  or  /login llm7 YOUR_TOKEN" "gold" }
        else { Login-Cinema $parts[0] $parts[1] }
        continue
    }
    elseif ($lower.StartsWith("/logout")) {
        $rest = $userInput.Substring(7).Trim()
        if ($rest -eq "") { W "Usage: /logout pollinations  or  /logout llm7" "gold" }
        else { Logout-Cinema $rest }
        continue
    }
    elseif ($lower.StartsWith("/pick ")) { Pick-Cinema ($userInput.Substring(6).Trim()); continue }
    elseif ($lower -eq "/current") { Current-Cinema; continue }
    elseif ($lower.StartsWith("/calc ")) { Calc-Cinema ($userInput.Substring(6).Trim()); continue }
    elseif ($lower -eq "/time") { Time-Cinema; continue }
    elseif ($lower.StartsWith("/weather ")) { Weather-Cinema ($userInput.Substring(9).Trim()); continue }
    elseif ($lower.StartsWith("/image ")) { Image-Cinema ($userInput.Substring(7).Trim()); continue }
    elseif ($lower -eq "/scan") { Scan-Cinema; continue }
    elseif ($lower -eq "/matrix") { Matrix-Cinema; continue }
    elseif ($lower -eq "/glitch") { Glitch-Cinema; continue }
    elseif ($lower -eq "/flare") { Flare-Cinema; Draw-CinemaUI; continue }
    elseif ($lower -eq "/aurora") { Aurora-Cinema "calm"; Draw-CinemaUI; continue }
    elseif ($lower -eq "/aurora calm") { Aurora-Cinema "calm"; Draw-CinemaUI; continue }
    elseif ($lower -eq "/aurora storm") { Aurora-Cinema "storm"; Draw-CinemaUI; continue }
    elseif ($lower -eq "/curtain") { Curtain-Cinema; Draw-CinemaUI; continue }
    elseif ($lower -eq "/logo") { Logo-Animated-Cinema; Draw-CinemaUI; continue }
    elseif ($lower -eq "/credits") { Credits-Cinema; continue }
    elseif ($lower -eq "/animate on") { $script:animateUI = $true; Play-ClickBlip; W "NOVA: Live animation engine ENGAGED." "green"; continue }
    elseif ($lower -eq "/animate off") { $script:animateUI = $false; Play-ClickBlip; W "NOVA: Live animation engine PAUSED." "gold"; continue }
    elseif ($lower -eq "/sound on") { $script:soundUI = $true; Play-ClickBlip; Play-SuccessChime; W "NOVA: Synthesized sound rig ENGAGED." "green"; continue }
    elseif ($lower -eq "/sound off") { W "NOVA: Synthesized sound rig SILENCED." "gold"; $script:soundUI = $false; continue }
    elseif ($lower -eq "/reset") {
        $script:memory = @()
        $script:chatLog = @()
        W "NOVA: Memory reel wiped." "green"
        Play-ClickBlip
        continue
    }
    elseif ($lower.StartsWith("/theme ")) {
        $newTheme = $userInput.Substring(7).Trim().ToLower()
        if ($script:themes.ContainsKey($newTheme)) {
            $script:theme = $newTheme
            Play-ClickBlip
            if ($newTheme -eq "aurora" -and $script:animateUI) { Aurora-Cinema "calm" }
            Draw-CinemaUI
        }
        else { W "Unknown theme. Try: bloxd, void, blood, ice, solar, neon, aurora" "gold" }
        continue
    }
    elseif ($lower.StartsWith("/speed ")) {
        $n = 0
        if ([int]::TryParse($userInput.Substring(7).Trim(), [ref]$n)) {
            if ($n -lt 0) { $n = 0 }
            if ($n -gt 50) { $n = 50 }
            $script:typeDelay = $n
            W "NOVA: Typing speed set to $($script:typeDelay)ms." "green"
            Play-ClickBlip
        }
        else { W "Usage: /speed 0" "gold" }
        continue
    }
    elseif ($lower.StartsWith("/provider ")) {
        $newProvider = $userInput.Substring(10).Trim().ToLower()
        if ($newProvider -eq "pollinations") {
            $script:provider = "pollinations"
            $script:model = "gpt-5-nano"
            Play-ClickBlip
            W "NOVA: Provider switched to Pollinations. Model set to gpt-5-nano." "green"
        }
        elseif ($newProvider -eq "llm7") {
            $script:provider = "llm7"
            $script:model = "default"
            Play-ClickBlip
            W "NOVA: Provider switched to LLM7. Model set to default." "green"
        }
        else { W "Unknown provider. Use /provider pollinations or /provider llm7" "gold" }
        continue
    }
    elseif ($lower.StartsWith("/model ")) {
        $newModel = $userInput.Substring(7).Trim()
        if ($newModel -eq "") { W "Usage: /model modelname" "gold"; continue }
        $script:model = $newModel
        Play-ClickBlip
        W "NOVA: Model switched to $($script:model). API ID: $(Resolve-ApiModel)" "green"
        continue
    }
    Ask-Nova $userInput
}
