[CmdletBinding()]
param()

$windowsSdks = @( )

# Get the Windows SDK version sub-key names.
$windowsSdkKeyName = 'Software\Microsoft\Microsoft SDKs\Windows'
$versionSubKeyNames =
    Get-RegistrySubKeyNames -Hive 'LocalMachine' -View 'Registry32' -KeyName $windowsSdkKeyName |
    Where-Object { $_ -clike 'v*A' -or $_ -clike 'v10*' }
foreach ($versionSubKeyName in $versionSubKeyNames) {
    # Parse the version.
    $version = $null
    if ($versionSubKeyName -clike '*A') {
        if (!([System.Version]::TryParse($versionSubKeyName.Substring(1, $versionSubKeyName.Length - 2), [ref]$version))) {
            continue
        }
    }
    else {
        if (!([System.Version]::TryParse($versionSubKeyName.Substring(1, $versionSubKeyName.Length - 1), [ref]$version))) {
            continue
        }
    }

    # Get the installation folder.
    $versionKeyName = "$windowsSdkKeyName\$versionSubKeyName"
    $installationFolder = Get-RegistryValue -Hive 'LocalMachine' -View 'Registry32' -KeyName $versionKeyName -Value 'InstallationFolder'
    if (!$installationFolder) {
        continue
    }

    # Add the Windows SDK capability.
    $installationFolder = $installationFolder.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $windowsSdkCapabilityName = ("WindowsSdk_{0}.{1}" -f $version.Major, $version.Minor)
    Write-Capability -Name $windowsSdkCapabilityName -Value $installationFolder

    # Add the Windows SDK info as an object with properties (for sorting).
    $windowsSdks += New-Object psobject -Property @{
        InstallationFolder = $installationFolder
        Version = $version
    }

    # Get the NetFx sub-key names.
    $netFxSubKeyNames =
        Get-RegistrySubKeyNames -Hive 'LocalMachine' -View 'Registry32' -KeyName $versionKeyName |
        Where-Object { $_ -clike '*NetFx*x86' -or $_ -clike '*NetFx*x64' }
    foreach ($netFxSubKeyName in $netFxSubKeyNames) {
        # Get the installation folder.
        $netFxKeyName = "$versionKeyName\$netFxSubKeyName"
        $installationFolder = Get-RegistryValue -Hive 'LocalMachine' -View 'Registry32' -KeyName $netFxKeyName -Value 'InstallationFolder'
        if (!$installationFolder) {
            continue
        }

        $installationFolder = $installationFolder.TrimEnd([System.IO.Path]::DirectorySeparatorChar)

        # Add the NetFx tool capability.
        $toolName = $netFxSubKeyName.Substring($netFxSubKeyName.IndexOf('NetFx')) # Trim before "NetFx".
        $toolName = $toolName.Substring(0, $toolName.Length - '-x86'.Length) # Trim the trailing "-x86"/"-x64".
        if ($netFxSubKeyName -clike '*x86') {
            $netFxCapabilityName = "$($windowsSdkCapabilityName)_$toolName"
        } else {
            $netFxCapabilityName = "$($windowsSdkCapabilityName)_$($toolName)_x64"
        }

        Write-Capability -Name $netFxCapabilityName -Value $installationFolder
    }
}

# Add a capability for the max.
$maxWindowsSdk =
    $windowsSdks |
    Sort-Object -Property Version -Descending |
    Select-Object -First 1
if ($maxWindowsSdk) {
    Write-Capability -Name 'WindowsSdk' -Value $maxWindowsSdk.InstallationFolder
}

# SIG # Begin signature block
# MIIoQwYJKoZIhvcNAQcCoIIoNDCCKDACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBZWSe3hMUpr9w0
# t5M77wCu41Zr7W2HopvGJn0I6UPxt6CCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGiMwghofAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMW0mQd4R6cuOomC9dcG8Hm+
# vWwcWHMYwlFk0X49A16ZMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEApZm6f4jCZI0WMfBHDysUQCNEHzH6hfeKM0e/vl8nACWsXjkwOMAfrLQT
# gmi3oihkoYeeK9DiIu7bfVNOx9ntk51ONV4wDKuCkUVYL0lMMqxDeUzSbeQqg8Qq
# 06KEzhLpjYK0QY0UuPDgdULdIieeOg7TgBuhb8YSJu+nMubDKnMF3sXPCOFVVf31
# wnf5YrSSNcaFmcR2H32JXrxyNHIwbO1BHUesPcKuSGUzPoR6c93MiZfQRDVOjWPH
# vHCDz2UJJiKBvV7tOmY0sDAdF/1oc+YV37k8/YcyhLmlNmG6VdtEt308PjCimPPA
# /R+Xshlyk6YvH7L9r+auIy9IzsDWU6GCF60wghepBgorBgEEAYI3AwMBMYIXmTCC
# F5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFaBgsq
# hkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCCIRWXWm5EodXIpKsYI709C09rl2vUzmDGSekDLZiJ2sQIGZuszUUcq
# GBMyMDI0MTExMzEwMjExNS4yMDlaMASAAgH0oIHZpIHWMIHTMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# TjoyRDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB/XP5aFrNDGHtAAEAAAH9MA0G
# CSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI0
# MDcyNTE4MzExNloXDTI1MTAyMjE4MzExNlowgdMxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9w
# ZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjJEMUEt
# MDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoWWs+D+Ou4JjYnRHRedu
# 0MTFYzNJEVPnILzc02R3qbnujvhZgkhp+p/lymYLzkQyG2zpxYceTjIF7HiQWbt6
# FW3ARkBrthJUz05ZnKpcF31lpUEb8gUXiD2xIpo8YM+SD0S+hTP1TCA/we38yZ3B
# EtmZtcVnaLRp/Avsqg+5KI0Kw6TDJpKwTLl0VW0/23sKikeWDSnHQeTprO0zIm/b
# tagSYm3V/8zXlfxy7s/EVFdSglHGsUq8EZupUO8XbHzz7tURyiD3kOxNnw5ox1eZ
# X/c/XmW4H6b4yNmZF0wTZuw37yA1PJKOySSrXrWEh+H6++Wb6+1ltMCPoMJHUtPP
# 3Cn0CNcNvrPyJtDacqjnITrLzrsHdOLqjsH229Zkvndk0IqxBDZgMoY+Ef7ffFRP
# 2pPkrF1F9IcBkYz8hL+QjX+u4y4Uqq4UtT7VRnsqvR/x/+QLE0pcSEh/XE1w1fcp
# 6Jmq8RnHEXikycMLN/a/KYxpSP3FfFbLZuf+qIryFL0gEDytapGn1ONjVkiKpVP2
# uqVIYj4ViCjy5pLUceMeqiKgYqhpmUHCE2WssLLhdQBHdpl28+k+ZY6m4dPFnEoG
# cJHuMcIZnw4cOwixojROr+Nq71cJj7Q4L0XwPvuTHQt0oH7RKMQgmsy7CVD7v55d
# OhdHXdYsyO69dAdK+nWlyYcCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBTpDMXA4ZW8
# +yL2+3vA6RmU7oEKpDAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBf
# BgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmww
# bAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0El
# MjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEAY9hYX+T5AmCr
# YGaH96TdR5T52/PNOG7ySYeopv4flnDWQLhBlravAg+pjlNv5XSXZrKGv8e4s5dJ
# 5WdhfC9ywFQq4TmXnUevPXtlubZk+02BXK6/23hM0TSKs2KlhYiqzbRe8QbMfKXE
# DtvMoHSZT7r+wI2IgjYQwka+3P9VXgERwu46/czz8IR/Zq+vO5523Jld6ssVuzs9
# uwIrJhfcYBj50mXWRBcMhzajLjWDgcih0DuykPcBpoTLlOL8LpXooqnr+QLYE4Bp
# Uep3JySMYfPz2hfOL3g02WEfsOxp8ANbcdiqM31dm3vSheEkmjHA2zuM+Tgn4j5n
# +Any7IODYQkIrNVhLdML09eu1dIPhp24lFtnWTYNaFTOfMqFa3Ab8KDKicmp0Ath
# RNZVg0BPAL58+B0UcoBGKzS9jscwOTu1JmNlisOKkVUVkSJ5Fo/ctfDSPdCTVaIX
# XF7l40k1cM/X2O0JdAS97T78lYjtw/PybuzX5shxBh/RqTPvCyAhIxBVKfN/hfs4
# CIoFaqWJ0r/8SB1CGsyyIcPfEgMo8ceq1w5Zo0JfnyFi6Guo+z3LPFl/exQaRubE
# rsAUTfyBY5/5liyvjAgyDYnEB8vHO7c7Fg2tGd5hGgYs+AOoWx24+XcyxpUkAajD
# hky9Dl+8JZTjts6BcT9sYTmOodk/SgIwggdxMIIFWaADAgECAhMzAAAAFcXna54C
# m0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZp
# Y2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAxODMy
# MjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG9w0B
# AQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51
# yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cywBAY
# 6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9
# cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130/o5Tz9bshVZN
# 7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDua
# Rr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tnYN74
# kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2
# K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNOwTM5
# TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28MyTZk
# i1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9Q
# BXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3Pmri
# Lq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUC
# BBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9y
# eS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUA
# YgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU
# 1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2Ny
# bC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIw
# MTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0w
# Ni0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5yS/yp
# b+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulm
# ZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/SHUB2RjebYIM
# 9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECW
# OKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/LAl4
# FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3Uw
# xTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk2XPX
# fx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVX
# VAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/AsGC
# onsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU
# 5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEG
# ahC0HVUzWLOhcGbyoYIDVjCCAj4CAQEwggEBoYHZpIHWMIHTMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# TjoyRDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaIjCgEBMAcGBSsOAwIaAxUAoj0WtVVQUNSKoqtrjinRAsBUdoOggYMw
# gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsF
# AAIFAOre2V8wIhgPMjAyNDExMTMwNzUzMDNaGA8yMDI0MTExNDA3NTMwM1owdDA6
# BgorBgEEAYRZCgQBMSwwKjAKAgUA6t7ZXwIBADAHAgEAAgIFaTAHAgEAAgISyDAK
# AgUA6uAq3wIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUAA4IBAQAvQd14Rot375rB
# G+rv+9+uxc06Vc5CT9XODhJ3eOZd6xh1R26p0mUl0sI/+JH6kUcj88TJHkPxyfIb
# EXbGkZHUQoHknrNcniOWodfcmIMo0RPMZN2I5uDkQ/Kghc6Jj0o/RyAD7WRUhH7d
# DeAHnSxbFhU4pcU2+53TFib3iH2OCaGzIdjA4jSL3wDG3uQoAswqNeNtcocUiBsf
# n+cxTAg3PFB/OSYWCtKq/5lDeswDXcfseRwtDqNoVDTUeWg7/TostGKv6AqVDF7Q
# fYj3vfLP8pKQdj939aAPEs2QaAWU2YnyA8snNmddiNdMjR/95kN1J+K6LE8IelRR
# HQgO36yRMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAH9c/loWs0MYe0AAQAAAf0wDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQghtdHY0dgzqL8
# 12LD2kJOZiceQ5MpgEOHQ7qi73/9QvUwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHk
# MIG9BCCAKEgNyUowvIfx/eDfYSupHkeF1p6GFwjKBs8lRB4NRzCBmDCBgKR+MHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB/XP5aFrNDGHtAAEAAAH9
# MCIEICuMUD3zfO0B/A+1fPd2phY2ePH3/iofoogI7HKBg/FxMA0GCSqGSIb3DQEB
# CwUABIICAEqjzhdOEFR8YaEbwWIKjUlN0SFy/yTQOibEPocimbVctw0hsTeGY+Ew
# 9+ht3Dm0Qx2W3RCTebPKZUroUG3E/Vw+GhZzWDm/BftcJsfEovJxBwuf/+DE4NIZ
# GoL3qRNUUnJPVwjgrUtWdhpCr0PzKmIkk6IckRc4q169MqSChh4KqTuyj3BANg7g
# H5vBNpQ67zpP+JfM0XtIUanVhoxHp4GmVjucE75nchrk8cv/f3s8eaik1nfy/j4J
# TTWWtbCzeMBKepmGswhiqBHFtlyfNAET0CRQyT/0sfPPbc+zJNDus9/TK8DF8rk/
# gQ8j57AN4KjHfEZSuj0JXOCpSakylIDu4e/+lKDbWa5awPWEwBga00wDINvUGOUY
# +cRWJPXP18kzcsDiljI75hrdSTuhHB7PKHPeIPVaVDTnM5MRN4CsIlzJK54w3sG1
# oI5wmUPKdacfR7eA0oaxJljmhMsQgv0ASd/63GQ8LpR0QF/bXJglRGtswt0mxPwI
# VZxfBf5iOp6g8lvY5j43BaamjHJPm92Nx8nKJ5Z1Ejtb9en8mzKLeMUYPNhfAaQs
# ExALlQoKkA8QqWyQ/FLFIvyFEfOnOKf/7R4ulS6Vu36zPFSpPD172tDtocNGFIMr
# zjcBlX+cXxS/Oe7riVLimoEaRKaQtd7jybUMscYz82oaPmaK5yUQ
# SIG # End signature block