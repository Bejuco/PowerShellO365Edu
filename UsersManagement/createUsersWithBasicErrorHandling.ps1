################################################################################
# MIT License
#
# Copyright (c) 2016 José P. Cortés
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################

Connect-MsolService

clear
$licenses = Get-MsolAccountSku | Select-Object AccountSkuId
$usrResults = @(); #array for the results 
$ErrorsCreating = @(); #array for the errors found in the user's creation.
#Here the CSV should be loaded. Using an In-Memory Array just to make things easier.
$usersToCreate = ("Testupn@jpcortes.net", "Testupn1@jpcortes.net", "Testupn2@jpcortes.net","Testupn@jpcortes.net")
$ErrorActionPreference = “SilentlyContinue”;
#We change the error reporting preference to avoid the full dump of errors, as we are not that interested in why it fail, more in "who" failed in.
foreach( $newUser in $usersToCreate) {

    $usr = New-MsolUser -UserPrincipalName $newUser -DisplayName "Delete Test User DELETE" #add your own data, depending on what you have on the CSV.
    if($? -eq $false) { #let's check for errors here. If no errors, we try to add the user location and then the licenses
        $ErrorsCreating +=, $newUser;

        }
    else{
      #you might want to change the Usage Location. Here is set to Costa Rica.
    Set-MsolUser -UserPrincipalName $newUser -UsageLocation CR;
    Set-MsolUserLicense -UserPrincipalName $newUser -AddLicenses $licenses[2].AccountSkuId;
    #I'm explicitly selecting the third license available in my tenant. You can/should change at will.
    $usrResults += ,$usr;
    }
}
$ErrorActionPreference = “Continue”
#We get back to default error reporting preference
#Log writing.... Will Overwrite.
$usrResults | Select-Object UserPrincipalName, Password | Export-Csv -Path "c:/ps/output.csv" -Force -NoTypeInformation
$ErrorsCreating | Select-Object @{Name = "Users Not Created"; Expression= {$_}}| Export-Csv -Path "C:/ps/errors.csv" -Force -NoTypeInformation

Write-Warning "Script ran with $($ErrorsCreating.Count) Errors"
#This could be changed to just report IF there was errors and how many users were created. I just didn't.
