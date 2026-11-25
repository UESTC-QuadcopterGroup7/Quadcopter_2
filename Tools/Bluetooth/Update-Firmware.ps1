[CmdletBinding(DefaultParameterSetName = 'Update')]
param(
    [Parameter(ParameterSetName = 'Ports', Mandatory)][switch]$ListPorts,
    [Parameter(ParameterSetName = 'Update')][string]$Port = 'COM9',
    [Parameter(ParameterSetName = 'Update')][string]$Firmware,
    [Parameter(ParameterSetName = 'Update')][ValidateRange(5, 120)][int]$ConnectTimeout = 25,
    [Parameter(ParameterSetName = 'Update')][switch]$Probe
)

$ErrorActionPreference = 'Stop'
if ($ListPorts) {
    [System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object -Unique
    return
}

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$image = $null
$key = $null
if (-not $Probe) {
    if (-not $Firmware) { $Firmware = Join-Path $root 'Objects\BluetoothApp\FlightController.bin' }
    $image = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Firmware).Path)
    $keyFile = Join-Path $root 'Firmware\Bootloader\BootKey.local.h'
    $hex = [regex]::Matches([System.IO.File]::ReadAllText($keyFile), '0x([0-9a-fA-F]{2})\b')
    if ($hex.Count -ne 32) { throw "Invalid device key file: $keyFile" }
    $key = [byte[]]::new(32)
    for ($i = 0; $i -lt $key.Length; $i++) {
        $key[$i] = [Convert]::ToByte($hex[$i].Groups[1].Value, 16)
    }
}
Add-Type -Path (Join-Path $PSScriptRoot 'Uploader.cs')
[QuadcopterBluetoothUploader]::Run($Port, $image, $key, $ConnectTimeout)
