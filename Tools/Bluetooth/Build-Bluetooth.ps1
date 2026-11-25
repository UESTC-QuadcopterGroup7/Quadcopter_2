param(
    [ValidateSet('All', 'Bootloader', 'App')]
    [string]$Component = 'All',
    [string]$KeilRoot = 'C:\Keil_v5'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$builder = Join-Path $KeilRoot 'UV4\uVision.com'
$fromElf = Join-Path $KeilRoot 'ARM\ARMCC\bin\fromelf.exe'
$keyFile = Join-Path $root 'Firmware\Bootloader\BootKey.local.h'

function New-LocalKey {
    if (Test-Path -LiteralPath $keyFile) { return }
    $bytes = [byte[]]::new(32)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $initializer = ($bytes | ForEach-Object { '0x{0:X2}' -f $_ }) -join ', '
    $stream = [System.IO.File]::Open($keyFile, [System.IO.FileMode]::CreateNew)
    try {
        $writer = [System.IO.StreamWriter]::new($stream)
        try { $writer.WriteLine("#define QBT_IMAGE_KEY $initializer") } finally { $writer.Dispose() }
    } finally { $stream.Dispose() }
    Write-Host 'Created a local device key. Keep this file private and backed up.'
}

function New-KeilProject {
    param ([string]$Kind, [string]$Base, [string]$Size, [string]$Output)
    $project = [System.Xml.XmlDocument]::new()
    $project.PreserveWhitespace = $true
    $project.Load((Join-Path $root 'LED.uvprojx'))
    $target = $project.Project.Targets.Target
    $target.TargetName = "Bluetooth$Kind"
    $common = $target.TargetOption.TargetCommonOption
    $options = $target.TargetOption.TargetArmAds
    $common.OutputName = $Output
    $common.OutputDirectory = ".\Objects\Bluetooth$Kind\"
    $common.ListingPath = ".\Listings\Bluetooth$Kind\"
    $common.CreateHexFile = '1'
    $common.Cpu = $common.Cpu -replace 'IROM\(0x[0-9a-f]+,0x[0-9a-f]+\)', "IROM($Base,$Size)"
    $options.LDads.TextAddressRange = $Base
    foreach ($memory in @($options.ArmAdsMisc.OnChipMemories.IROM, $options.ArmAdsMisc.OnChipMemories.OCR_RVCT4)) {
        $memory.StartAddress = $Base
        $memory.Size = $Size
    }
    $options.Cads.VariousControls.IncludePath += ';.\Firmware\Bootloader'

    if ($Kind -eq 'Bootloader') {
        $groups = $target.SelectSingleNode('Groups')
        $groups.RemoveAll()
        $group = $project.CreateElement('Group')
        $name = $project.CreateElement('GroupName')
        $name.InnerText = 'Bluetooth bootloader'
        [void]$group.AppendChild($name)
        $files = $project.CreateElement('Files')
        foreach ($path in @(
            'Firmware\Bootloader\BootMain.c',
            'Firmware\Bootloader\ImageIntegrity.c',
            'Drivers\CMSIS\Device\ST\STM32F4xx\Source\startup_stm32f401xe.s',
            'Drivers\CMSIS\Device\ST\STM32F4xx\Source\system_stm32f4xx.c'
        )) {
            $file = $project.CreateElement('File')
            $values = @{
                FileName = (Split-Path -Leaf $path)
                FileType = $(if ($path.EndsWith('.s')) { '2' } else { '1' })
                FilePath = ".\$path"
            }
            foreach ($element in @('FileName', 'FileType', 'FilePath')) {
                $node = $project.CreateElement($element)
                $node.InnerText = $values[$element]
                [void]$file.AppendChild($node)
            }
            [void]$files.AppendChild($file)
        }
        [void]$group.AppendChild($files)
        [void]$groups.AppendChild($group)
    } else {
        $options.Cads.VariousControls.Define += ', QBT_APP'
    }
    $projectPath = Join-Path $root "Bluetooth$Kind.uvprojx"
    [System.IO.File]::WriteAllText($projectPath, $project.OuterXml, [System.Text.UTF8Encoding]::new($false))
    $projectPath
}

function Invoke-KeilBuild {
    param ([string]$Kind, [string]$Base, [string]$Size, [string]$Name)
    $projectPath = New-KeilProject $Kind $Base $Size $Name
    $out = Join-Path $root "Objects\Bluetooth$Kind"
    $log = Join-Path $out 'build.log'
    $null = New-Item -Path $out, (Join-Path $root "Listings\Bluetooth$Kind") -ItemType Directory -Force
    & $builder -r (Split-Path -Leaf $projectPath) -t "Bluetooth$Kind" -j0 -o $log
    if ($LASTEXITCODE -gt 1) { throw "Keil build failed. See $log" }
    $image = Join-Path $out "$Name.axf"
    if (-not (Test-Path -LiteralPath $image)) { throw "Keil did not produce $image" }
    if ($Kind -eq 'App') {
        $binary = Join-Path $out "$Name.bin"
        & $fromElf --bin "--output=$binary" $image
        if ($LASTEXITCODE -ne 0) { throw 'fromelf did not create the application BIN.' }
        Write-Host "Bluetooth application: $binary"
    } else {
        Write-Host "SWD bootstrap project: $projectPath"
        Write-Host "Bootloader HEX: $(Join-Path $out "$Name.hex")"
    }
}

if (-not (Test-Path -LiteralPath $builder) -or -not (Test-Path -LiteralPath $fromElf)) {
    throw "Keil MDK with ARM Compiler 5 was not found under $KeilRoot."
}
Push-Location $root
try {
    if ($Component -ne 'App') {
        New-LocalKey
        Invoke-KeilBuild 'Bootloader' '0x08000000' '0x4000' 'Bootloader'
    }
    if ($Component -ne 'Bootloader') {
        Invoke-KeilBuild 'App' '0x08004000' '0x3BFD4' 'FlightController'
    }
} finally {
    Pop-Location
}
