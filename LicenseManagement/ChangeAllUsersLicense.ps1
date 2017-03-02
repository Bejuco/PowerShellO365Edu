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

###############################################################################
# CHANGE Here
$LicenseIndex = 1; #This is a base 0 index. It means that if you want the third, you'll use "2"
#Use an integer, don't use " " or '', just the number.
##############################################################################

Connect-MsolService

clear;

#This Script will take ALL of your users, remove their licenses, and assign the selected one.
$licenses = Get-MsolAccountSku | Select-Object AccountSkuId
$newLicense = $licenses[$LicenseIndex];

$ErrorsDetected = @(); #array for the errors found in the user's creation.

$Users = Get-MsolUser -MaxResults Unlimited;
$ErrorActionPreference = “SilentlyContinue”;

Foreach ($us in $Users)
{
  foreach ($lic in $us.Licenses )
  {
      Set-MsolUserLicense -RemoveLicenses $lic.AccountSkuId -UserPrincipalName $us.UserPrincipalName
  }
  Set-MsolUserLicense -UserPrincipalName $usuario.UserPrincipalName -AddLicenses $newLicense
  if($? -eq $false)
    { #let's check for errors here. If no errors, we try to add the user location and then the licenses
      $ErrorsDetected +=, $us;
    }
} #Main for each closing

$ErrorsDetected | Select-Object @{Name = "License Change Errors"; Expression= {$_}}| Export-Csv -Path "C:/ps/LicenseChangeErrors.csv" -Force -NoTypeInformation
Write-Warning "Script ran with $($ErrorsDetected.Count) Errors"
