#region disclaimer
	#===============================================================================
	# PowerShell script sample														
	# Author: Markus Koechl															
	# Copyright (c) Autodesk 2017													
	#																				
	# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER     
	# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   
	# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.    
	#===============================================================================
#endregion

#region ConnectToVault
		# NOTE - click licensing v3 requires to copy AdskLicensingSDK_3.dll to PowerShell execution folder C:\Windows\System32\WindowsPowerShell\v1.0 before Powershell runtime starts

		[System.Reflection.Assembly]::LoadFrom('C:\Program Files\Autodesk\Autodesk Vault 2021 SDK\bin\x64\Autodesk.Connectivity.WebServices.dll')
		$serverID = New-Object Autodesk.Connectivity.WebServices.ServerIdentities
			$serverID.DataServer = "<ServerName or IP>"
			$serverID.FileServer = "<ServerName or IP>"
		$VaultName = "<Name of Vault>"
		$UserName = "<User Name>"
		$password = "<Password>"
		#Select license type by licensing agent enum "Client" (=Named User) "Server" (= (legacy) Multi-User) or "None" (=readonly access)
		$licenseAgent = [Autodesk.Connectivity.WebServices.LicensingAgent]::Client
		
		$cred = New-Object Autodesk.Connectivity.WebServicesTools.UserPasswordCredentials($serverID, $VaultName, $UserName, $password, $licenseAgent)
		$vault = New-Object Autodesk.Connectivity.WebServicesTools.WebServiceManager($cred)

		#region ExecuteInVault
		# Referenc to Document Service

			#Reference Item Service
			$ItemSvc = $vault.ItemService

			#Get target item category Id
			$mEntityCategories = $vault.CategoryService.GetCategoriesByEntityClassId("ITEM", $true)
			$mEntCatId = ($mEntityCategories | Where-Object {$_.Name -eq "Document" }).ID

			#Create new item and commit
			[Autodesk.Connectivity.WebServices.Item]$NewItem = $ItemSvc.AddItemRevision($mEntCatId)
			$NewItem.Title = "My Document Item"
			$NewItem.Detail = "Long Description of my doc item"
			$NewItem.Comm = "PS script initiated item"
			$NewItemRev = $ItemSvc.UpdateAndCommitItems($NewItem)

		#endregion ExecuteInVault

		$vault.Dispose() #don't forget to release the connection
#endregion ConnectToVault