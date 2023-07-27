#region disclaimer
	#===============================================================================
	# PowerShell script sample														
	# Author: Markus Koechl															
	# Copyright (c) Autodesk 2020													
	#																				
	# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER     
	# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   
	# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.    
	#===============================================================================
#endregion

#region ConnectToVault

		# NOTE - click licensing v5 requires to copy AdskLicensingSDK_7.dll to PowerShell execution folder C:\Windows\System32\WindowsPowerShell\v1.0 before Powershell runtime starts

		[System.Reflection.Assembly]::LoadFrom('C:\Program Files\Autodesk\Autodesk Vault 2024 SDK\bin\x64\Autodesk.Connectivity.WebServices.dll')
		$serverID = New-Object Autodesk.Connectivity.WebServices.ServerIdentities
			$serverID.DataServer = "192.168.85.128"
			$serverID.FileServer = "192.168.85.128"
		$VaultName = "PDMC-Sample"
		$UserName = "CAD Admin"
		$password = ""
		#Select license type by licensing agent enum "Client" (=Named User) "Server" (= (legacy) Multi-User) or "None" (=readonly access)
		$licenseAgent = [Autodesk.Connectivity.WebServices.LicensingAgent]::Client
		
		$cred = New-Object Autodesk.Connectivity.WebServicesTools.UserPasswordCredentials($serverID, $VaultName, $UserName, $password, $licenseAgent)
		$vault = New-Object Autodesk.Connectivity.WebServicesTools.WebServiceManager($cred)

		#region ExecuteInVault

			#Reference Item Service
			$ItemSvc = $vault.ItemService

			#Get target item category Id
			$mEntityCategories = $vault.CategoryService.GetCategoriesByEntityClassId("ITEM", $true)
			$mEntCatId = ($mEntityCategories | Where-Object {$_.Name -eq "General" }).ID
			$mEntCatId2 = ($mEntityCategories | Where-Object {$_.Name -eq "Part" }).ID

			#Create new item and commit (Step 1)
			[Autodesk.Connectivity.WebServices.Item]$NewItem = $ItemSvc.AddItemRevision($mEntCatId)
			$NewItem.Title = "My New Item"
			$NewItem.Detail = "2 steps: create, update category"
			$NewItem.Comm = "initial item, no cat properties added"
			#save the item;
			$ItemSvc.UpdateAndCommitItems(@($NewItem))
			[Autodesk.Connectivity.WebServices.Item]$ItemResult = $ItemSvc.GetLatestItemByItemMasterId($NewItem.MasterId)
			#edit the new item to add category properties (Step 2)
			[Autodesk.Connectivity.WebServices.Item]$EditItem = $ItemSvc.EditItems(@($ItemResult.RevId))[0]
			#the UpdateItemCategories includes the commit
			$NewItem = ($ItemSvc.UpdateItemCategories(@($EditItem.MasterId), @($mEntCatId2), "New Item with UDPs for Part Category"))[0]
            			
		#endregion ExecuteInVault
		
		$vault.Dispose() #don't forget to release the connection, to return the (server) license you also can log out: $cred.SignOut($vault.AuthService, $vault.WinAuthService)


#endregion ConnectToVault