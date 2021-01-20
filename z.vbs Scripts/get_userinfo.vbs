' **********************************************************************
'
' VBScript: SIG_AD_UserInfos
' 
' Author: Ruben
' Date:   2014-10-22
' Version: 1
'
' Description:
' This script displays some additional user information by receivng
'  the input by right clicking a user object in ADUC.
' 
' Attention: 
' This VB script comes with ABSOLUTELY NO WARRANTY; for details
' see gnu-gpl. This is free software, and you are welcome
' to redistribute it under certain conditions; see gnu-gpl for details.
' 
' **********************************************************************


'*  Reading import file using UNICODE instead of ANSI
Const TristateTrue = -1

'* Authenticating against active directory with kerberos
Const ADS_SECURE_AUTHENTICATION = 1
Const ADS_FAST_BIND = 32 
Const ADS_USE_SIGNING = 64
Const ADS_USE_SEALING = 128

'Const vbInformation = 64

Dim objDSE, objConn, objRS, objdso, objADSUser, objWShell, key
Dim arrUserAccountData, strDefaultNamingContext, strLine, strADSUser, strErrorMsg
Dim strInpTitle, strInpSurName, strInpGivenName, strInpCompanyKey, strStaffCN, strStaffNo, strInpUserID, strStaffCompanyKey, strStaffLastLogon, strStaffPwdLastSet, strStaffbadPasswordTime, strStaffbadPwdCount

key = "S1GisN1T.1"

Set wshArguments = WScript.Arguments
Set objUser = GetObject(wshArguments(0))

strInpUserID = objUser.SamAccountName

Set objWShell = CreateObject("WScript.Shell")

lngBiasKey = objWShell.RegRead("HKLM\System\CurrentControlSet\Control\" _
    & "TimeZoneInformation\ActiveTimeBias")
If (UCase(TypeName(lngBiasKey)) = "LONG") Then
    lngBias = lngBiasKey
ElseIf (UCase(TypeName(lngBiasKey)) = "VARIANT()") Then
    lngBias = 0
    For k = 0 To UBound(lngBiasKey)
        lngBias = lngBias + (lngBiasKey(k) * 256^k)
    Next
End If
		
'* Binding to Active Directory using ADO (+Kerberos) to get the distinguished name of the user object
Set objdso = GetObject("LDAP:")
Set objDSE = GetObject("LDAP://rootDSE")
Set objConn = CreateObject("ADODB.Connection")
objConn.Provider = "ADSDSOObject"
objConn.Properties("ADSI Flag") = ADS_SECURE_AUTHENTICATION + ADS_USE_SEALING + ADS_USE_SIGNING + ADS_FAST_BIND
objConn.Open "Active Directory Provider"

strDefaultNamingContext = "<LDAP://" & objDSE.Get("defaultNamingContext") &">"

'* Reading the specified values converting values into a string a calling the import function

Function ConvertTimeToString(dtmInDate)		
	
	Set objDate = dtmInDate
	lngHigh = objDate.HighPart
	lngLow = objDate.LowPart					
	
	If (lngLow < 0) Then
		lngHigh = lngHigh + 1
	End If
	If (lngHigh = 0) And (lngLow = 0 ) Then
		''dtmDate = #1/1/1601#
		dtmDate = "No information available."
	Else
		dtmDate = #1/1/1601# + (((lngHigh * (2 ^ 32)) _
			+ lngLow)/600000000 - lngBias)/1440
	End If

	ConvertTimeToString =  CStr(dtmDate)

End Function

Function Decrypt(str,key)
 Dim lenKey, KeyPos, LenStr, x, Newstr
 
 Newstr = ""
 lenKey = Len(key)
 KeyPos = 1
 LenStr = Len(Str)
 
 Str=StrReverse(str)
 For x = LenStr To 1 Step -1
      Newstr = Newstr & Chr(Asc(Mid(str,x,1)) - Asc(Mid(key,KeyPos,1)))
      KeyPos = KeyPos+1
      If KeyPos > lenKey Then KeyPos = 1
      Next
      Newstr=StrReverse(Newstr)
      Decrypt = Newstr
End Function


Call GetADSInfo(strInpUserID)            

'* Binding to Active Directory using ADSI (+Kerberos) writing the data into ADS

Function GetADSInfo(strInpUserID)

	strErrorMsg = "No information available."
	
	Set objRS = objConn.Execute _
	  (strDefaultNamingContext &";(sAMAccountName="&strInpUserID&");" _
	  & "sAMAccountName,ADsPath;SubTree")
	
	If objRS.RecordCount < 1 Then
		MsgBox "Error: No ADS - User found: " &strInpUserID
		WScript.Quit(1)
	Else
		
		If Not IsNull(objRS.Fields.Item("ADsPath").Value) Then
				strADSUser = objRS.Fields.Item("ADsPath").Value
				
				Set objADSUser = objdso.OpenDSObject(strADSUser,vbNullString,vbNullString,ADS_SECURE_AUTHENTICATION + ADS_USE_SEALING + ADS_USE_SIGNING + ADS_FAST_BIND)
		
				strStaffCN = objADSUser.Get("cn")

																			
				If Not IsNull(objADSUser.extensionAttribute5) And Not IsEmpty(objADSUser.extensionAttribute5) Then
					strStaffNo = objADSUser.extensionAttribute5
				Else
					strStaffNo = "ExtensionAttribute5 not set."
				End If		
								
				If Not IsNull(objADSUser.extensionAttribute1) And Not IsEmpty(objADSUser.extensionAttribute1) Then
					strStaffCompanyKey = objADSUser.extensionAttribute1
				Else
					strStaffCompanyKey = "ExtensionAttribute1 not set."
				End If											
														
				If Not IsNull(objADSUser.lastLogonTimestamp) And Not IsEmpty(objADSUser.lastLogonTimestamp) Then										
					strStaffLastLogon = ConvertTimeToString(objADSUser.lastLogonTimestamp)
				Else
					strStaffLastLogon = strErrorMsg
				End If
				
				If Not IsNull(objADSUser.pwdLastSet) And Not IsEmpty(objADSUser.pwdLastSet) Then
					strStaffPwdLastSet = ConvertTimeToString(objADSUser.pwdLastSet)
				Else
					strStaffPwdLastSet = strErrorMsg
				End If
				
				If Not IsNull(objADSUser.badPasswordTime) And Not IsEmpty(objADSUser.badPasswordTime)Then
					strStaffbadPasswordTime = ConvertTimeToString(objADSUser.badPasswordTime)					
				Else
					strStaffbadPasswordTime = strErrorMsg
				End If
				
				If Not IsNull(objADSUser.badPwdCount) And Not IsEmpty(objADSUser.badPwdCount) Then
					strStaffbadPwdCount = objADSUser.badPwdCount					
				Else
					strStaffbadPwdCount = strErrorMsg
				End If		

				If Not IsNull(objADSUser.street) And Not IsEmpty(objADSUser.street) Then
					strComputerNameEnc = objADSUser.street
					strComputerName = Decrypt(strComputerNameEnc,key)					
				Else
					strComputerName = "Not found."
				End If		
				
												
				If Err.Number <> 0 Then				
					MsgBox "Error occured while gathering informatino for:  " & strADSUser &" "& Err.Description 
					Err.Clear
				Else
					MsgBox 	   "Personel Number:"  & vbTab & strStaffNo & VbCrLf _
									& "Company Key:"  & vbTab & strStaffCompanyKey & VbCrLf _
									&vbNewLine _
									& "Last Logon:"  & vbTab & strStaffLastLogon & VbCrLf _			
									& "Current Computer:"  & vbTab & strComputerName & VbCrLf _																		
									& "Password Last Set:"  & vbTab & strStaffPwdLastSet & VbCrLf _									
									& "Bad Password Last entered:"  & vbTab & strStaffbadPasswordTime & VbCrLf _									
									& "Bad Password  count:"  & vbTab & strStaffbadPwdCount & VbCrLf, vbInformation, "SIG-IT: Additional user information for" & vbTab &strStaffCN
				End If
								
		End If			
				
	End If

	Set objRS = Nothing

End Function

objConn.Close	
	