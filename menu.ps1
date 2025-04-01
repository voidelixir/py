Clear-Host
function Show-Menu {
    Write-Host "================================="
    Write-Host "           Script Menu           "
    Write-Host "================================="
    Write-Host "[1] Execute Sarpili Script"
    Write-Host "[2] Execute Sharing Script"
    Write-Host "[3] Reset AnyDesk ID"
    Write-Host "[4] Exit"
    Write-Host "================================="
}

Show-Menu
while ($true) {
    Write-Host "Press the corresponding key"
    $choice = [console]::ReadKey($true).KeyChar

    switch ($choice) {
        "1" {
            Write-Host "Running Sarpili Script..."
            powershell -command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/voidelixir/py/main/app.ps1))) -App 'sarpili'"
            Pause
            Show-Menu
        }
        "2" {
            Write-Host "Running Sharing Script..."
            powershell -command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/voidelixir/py/main/app.ps1))) -App 'sharing'"
            Pause
            Show-Menu
        }
        "3" {
            Write-Host "Resetting AnyDesk ID..."
            powershell -command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/voidelixir/py/main/app.ps1))) -App 'resetad'"
            Pause
            Show-Menu
        }
        "4" {
            Write-Host "Exiting... Goodbye!"
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}
