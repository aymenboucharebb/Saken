# Seed rich demo data on Saken Render via admin web UI.
$ErrorActionPreference = 'Stop'
$base = 'https://saken-1-bc4z.onrender.com'

function Get-Csrf($session, $url) {
    $p = Invoke-WebRequest -Uri $url -WebSession $session -TimeoutSec 90 -UseBasicParsing
    if ($p.Content -match 'name="csrf-token"\s+content="([^"]+)"') { return $Matches[1] }
    if ($p.Content -match 'name="_token"\s+value="([^"]+)"') { return $Matches[1] }
    throw "No CSRF on $url (len=$($p.RawContentLength))"
}

function Invoke-Form($session, $url, $body) {
    return Invoke-WebRequest -Uri $url -Method POST -WebSession $session -Body $body -TimeoutSec 90 -UseBasicParsing -MaximumRedirection 5
}

$residents = @(
    @{ name='Karim Benali';   email='karim@saken.dz';  number='A1' },
    @{ name='Sara Mansouri';  email='sara@saken.dz';   number='A2' },
    @{ name='Youcef Haddad';  email='youcef@saken.dz'; number='B1' },
    @{ name='Amine Khelifi';  email='amine@saken.dz';  number='B2' },
    @{ name='Nadia Cherif';   email='nadia@saken.dz';  number='C1' },
    @{ name='Omar Belkacem';  email='omar@saken.dz';   number='C2' },
    @{ name='Lina Messaoud';  email='lina@saken.dz';   number='D1' },
    @{ name='Riad Bouzid';    email='riad@saken.dz';   number='D2' },
    @{ name='Fatima Zohra';   email='fatima@saken.dz'; number='E1' },
    @{ name='Mehdi Saadi';    email='mehdi@saken.dz';  number='E2' },
    @{ name='Ines Hamidi';    email='ines@saken.dz';   number='F1' },
    @{ name='Samir Boudiaf';  email='samir@saken.dz';  number='F2' }
)

Write-Output '== Register residents =='
foreach ($res in $residents) {
    $s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    try {
        $csrf = Get-Csrf $s "$base/register"
        Invoke-Form $s "$base/register" @{
            _token = $csrf
            name = $res.name
            email = $res.email
            password = 'password'
            password_confirmation = 'password'
        } | Out-Null
        "REG OK $($res.email)"
    } catch {
        "REG skip/exists $($res.email)"
    }
}

Write-Output '== Admin login =='
$admin = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$csrf = Get-Csrf $admin "$base/login"
Invoke-Form $admin "$base/login" @{
    _token = $csrf
    email = 'admin@saken.dz'
    password = 'password'
} | Out-Null

# Build resident email -> id from apartments/create select
function Get-ResidentMap($session) {
    $page = Invoke-WebRequest -Uri "$base/apartments/create" -WebSession $session -TimeoutSec 60 -UseBasicParsing
    $map = @{}
    foreach ($m in [regex]::Matches($page.Content, '(?s)<option value="(\d+)"[^>]*>\s*([^<]+?)\s*</option>')) {
        $id = $m.Groups[1].Value
        $label = ($m.Groups[2].Value -replace '\s+', ' ').Trim()
        if ($label -match '@') {
            $email = ($label -split '\s+') | Where-Object { $_ -match '@' } | Select-Object -First 1
            if (-not $email) {
                # label like "Name (email@...)"
                if ($label -match '\(([^)]+@[^)]+)\)') { $email = $Matches[1] }
            }
            if ($email) { $map[$email.ToLower()] = $id }
        }
        # Also map by name for labels without email
        if ($label -and $label -ne '— Choisir —' -and $label -ne '-') {
            $map["name:$label"] = $id
        }
    }
    return $map
}

$residentMap = Get-ResidentMap $admin
"Residents in select: $($residentMap.Keys.Count)"

Write-Output '== Ensure apartments =='
foreach ($res in $residents) {
    $rid = $null
    foreach ($k in $residentMap.Keys) {
        if ($k -eq $res.email.ToLower() -or $k -match [regex]::Escape($res.email) -or ($k.StartsWith('name:') -and $k -match [regex]::Escape($res.name))) {
            $rid = $residentMap[$k]
            break
        }
    }

    # Try find existing apartment by scanning index/edit pages later; create if missing
    $csrf = Get-Csrf $admin "$base/apartments/create"
    try {
        Invoke-Form $admin "$base/apartments" @{
            _token = $csrf
            number = $res.number
            resident_id = $(if ($rid) { $rid } else { '' })
        } | Out-Null
        "APT create $($res.number)"
    } catch {
        "APT exists/skip $($res.number)"
    }
}

foreach ($vacant in @('G1','G2','H1')) {
    $csrf = Get-Csrf $admin "$base/apartments/create"
    try {
        Invoke-Form $admin "$base/apartments" @{ _token=$csrf; number=$vacant; resident_id='' } | Out-Null
        "APT vacant $vacant"
    } catch { "APT vacant skip $vacant" }
}

# Refresh apartment ids and link residents
$index = Invoke-WebRequest -Uri "$base/apartments" -WebSession $admin -TimeoutSec 60 -UseBasicParsing
$aptIds = [regex]::Matches($index.Content, '/apartments/(\d+)/edit') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
$apartmentByNumber = @{}

foreach ($id in $aptIds) {
    $edit = Invoke-WebRequest -Uri "$base/apartments/$id/edit" -WebSession $admin -TimeoutSec 60 -UseBasicParsing
    $number = if ($edit.Content -match 'name="number"[^>]*value="([^"]+)"') { $Matches[1] } else { $null }
    if (-not $number) { continue }
    $apartmentByNumber[$number] = $id

    $match = $residents | Where-Object { $_.number -eq $number } | Select-Object -First 1
    if (-not $match) { continue }

    $rid = $null
    foreach ($m in [regex]::Matches($edit.Content, '(?s)<option value="(\d+)"[^>]*>\s*([^<]*?)\s*</option>')) {
        $label = $m.Groups[2].Value
        if ($label -match [regex]::Escape($match.email) -or $label -match [regex]::Escape($match.name)) {
            $rid = $m.Groups[1].Value
            break
        }
    }
    if (-not $rid) { continue }

    $csrf = Get-Csrf $admin "$base/apartments/$id/edit"
    Invoke-Form $admin "$base/apartments/$id" @{
        _token = $csrf
        _method = 'PUT'
        number = $number
        resident_id = $rid
    } | Out-Null
    "LINK $number -> $($match.email)"
}

Write-Output '== Contributions =='
$contributions = @(
    @{ title='Charges communes 2025'; amount='4500' },
    @{ title='Travaux ascenseur'; amount='12000' },
    @{ title='Entretien espaces verts 2026'; amount='2500' },
    @{ title='Assurance immeuble 2025'; amount='3000' },
    @{ title='Charges communes 2026'; amount='5000' }
)

foreach ($c in $contributions) {
    $csrf = Get-Csrf $admin "$base/contributions/create"
    try {
        Invoke-Form $admin "$base/contributions" @{
            _token = $csrf
            title = $c.title
            amount_per_apartment = $c.amount
        } | Out-Null
        "CONTRIB OK $($c.title)"
    } catch {
        "CONTRIB skip $($c.title)"
    }
}

# Map contribution title -> id from payments/create
$payCreate = Invoke-WebRequest -Uri "$base/payments/create" -WebSession $admin -TimeoutSec 60 -UseBasicParsing
$contribMap = @{}
$inContrib = $false
foreach ($m in [regex]::Matches($payCreate.Content, '(?s)<select[^>]*name="contribution_id"[^>]*>(.*?)</select>')) {
    foreach ($opt in [regex]::Matches($m.Groups[1].Value, '(?s)<option value="(\d+)"[^>]*>\s*([^<]+?)\s*</option>')) {
        $title = (($opt.Groups[2].Value -split '—')[0]).Trim()
        $contribMap[$title] = $opt.Groups[1].Value
    }
}
$aptMap = @{}
foreach ($m in [regex]::Matches($payCreate.Content, '(?s)<select[^>]*name="apartment_id"[^>]*>(.*?)</select>')) {
    foreach ($opt in [regex]::Matches($m.Groups[1].Value, '(?s)<option value="(\d+)"[^>]*>\s*([^<]+?)\s*</option>')) {
        $num = (($opt.Groups[2].Value -split '\s|\(')[0]).Trim()
        if ($num -match '^[A-Z]\d+$') { $aptMap[$num] = $opt.Groups[1].Value }
    }
}
"APT map: $($aptMap.Keys -join ',')"
"CONTRIB map: $($contribMap.Keys -join ',')"

function Add-Payment($session, $aptId, $contribId, $amount, $date) {
    $csrf = Get-Csrf $session "$base/payments/create"
    try {
        Invoke-Form $session "$base/payments" @{
            _token = $csrf
            apartment_id = $aptId
            contribution_id = $contribId
            amount_paid = $amount
            date = $date
        } | Out-Null
        return $true
    } catch {
        return $false
    }
}

$occupiedNumbers = $residents.number
Write-Output '== Payments history =='

# Charges 2025
$cId = $contribMap['Charges communes 2025']
$i = 0
foreach ($num in $occupiedNumbers) {
    $aptId = $aptMap[$num]
    if (-not $aptId -or -not $cId) { continue }
    $amount = if ($i % 3 -eq 0) { '2000' } else { '4500' }
    $date = (Get-Date '2025-03-10').AddDays($i * 3).ToString('yyyy-MM-dd')
    $ok = Add-Payment $admin $aptId $cId $amount $date
    "PAY 2025 $num $amount -> $ok"
    $i++
}

# Ascenseur installments
$cId = $contribMap['Travaux ascenseur']
$i = 0
foreach ($num in ($occupiedNumbers | Select-Object -First 8)) {
    $aptId = $aptMap[$num]
    if (-not $aptId -or -not $cId) { continue }
    foreach ($pair in @(
        @{ amount='4000'; date=(Get-Date '2025-06-01').AddDays($i*5).ToString('yyyy-MM-dd') },
        @{ amount='4000'; date=(Get-Date '2025-08-15').AddDays($i*4).ToString('yyyy-MM-dd') }
    )) {
        $ok = Add-Payment $admin $aptId $cId $pair.amount $pair.date
        "PAY ASC $num $($pair.amount) -> $ok"
    }
    if ($i % 2 -eq 0) {
        $d = (Get-Date '2025-10-20').AddDays($i*2).ToString('yyyy-MM-dd')
        $ok = Add-Payment $admin $aptId $cId '4000' $d
        "PAY ASC3 $num -> $ok"
    }
    $i++
}

# Espaces verts
$cId = $contribMap['Entretien espaces verts 2026']
$i = 0
foreach ($num in $occupiedNumbers) {
    $aptId = $aptMap[$num]
    if (-not $aptId -or -not $cId) { continue }
    $amount = if ($i -eq 1) { '1000' } else { '2500' }
    $date = (Get-Date '2026-01-08').AddDays($i*2).ToString('yyyy-MM-dd')
    $ok = Add-Payment $admin $aptId $cId $amount $date
    "PAY VERT $num $amount -> $ok"
    $i++
}

# Assurance fully paid then close
$cId = $contribMap['Assurance immeuble 2025']
$i = 0
foreach ($num in $occupiedNumbers) {
    $aptId = $aptMap[$num]
    if (-not $aptId -or -not $cId) { continue }
    $date = (Get-Date '2025-11-05').AddDays($i).ToString('yyyy-MM-dd')
    $ok = Add-Payment $admin $aptId $cId '3000' $date
    "PAY ASS $num -> $ok"
    $i++
}

# Charges 2026 partial
$cId = $contribMap['Charges communes 2026']
$i = 0
foreach ($num in ($occupiedNumbers | Select-Object -First 9)) {
    $aptId = $aptMap[$num]
    if (-not $aptId -or -not $cId) { continue }
    $amount = switch ($i % 4) { 0 { '5000' } 1 { '2500' } 2 { '1500' } default { '500' } }
    $date = (Get-Date '2026-02-01').AddDays($i*3).ToString('yyyy-MM-dd')
    $ok = Add-Payment $admin $aptId $cId $amount $date
    "PAY 2026 $num $amount -> $ok"
    $i++
}

Write-Output '== Close historical contributions =='
$contribIndex = Invoke-WebRequest -Uri "$base/contributions" -WebSession $admin -TimeoutSec 60 -UseBasicParsing
# close links: /contributions/{id}/close
foreach ($title in @('Assurance immeuble 2025', 'Charges communes 2025')) {
    $id = $contribMap[$title]
    if (-not $id) { "CLOSE miss $title"; continue }
    $csrf = Get-Csrf $admin "$base/contributions"
    try {
        Invoke-Form $admin "$base/contributions/$id/close" @{ _token = $csrf } | Out-Null
        "CLOSE OK $title"
    } catch {
        "CLOSE fail $title : $($_.Exception.Message)"
    }
}

Write-Output 'DONE'
