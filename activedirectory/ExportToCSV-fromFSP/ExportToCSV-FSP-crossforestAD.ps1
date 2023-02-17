# Импортируем модуль Active Directory
Import-Module ActiveDirectory

#Ищем рекурсивно всех членов группы из всех лесов ActiveDirectory
$userscn = Get-ADObject -Filter {MemberOf -RecursiveMatch "CN=TerminalUsers,DC=example,DC=corp"}

#Запрос в AD по ранее полученным данным
ForEach ($user in $userscn) {

	#Ищем пользователей в локальном лесу ActiveDirectory и выгружаем данные в файл
    If ($user -notlike "CN=S-1-5-21*") {
        Get-AdUser $user -Properties emailaddress,department,company |select name,samaccountname,emailaddress,Department,company | Export-Csv -Path $PSScriptRoot\ad_rdp.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8 -Append
        } 

	#Ищем в foreignSecurityPrincipal с доверенных лесов ActiveDirectory 
    If ($user -like "CN=S-1-5-21*") {
        $fspusers = Get-ADObject -Filter {ObjectClass -eq "foreignSecurityPrincipal"} -Properties msds-principalname,memberof | Where-Object  {$_.DistinguishedName -eq $user} 
            ForEach ($fsp in $fspusers) {
                $username = $fsp.'msds-principalname'
				#ищем всех в домене NES.CORP
                if ($username -like "*NES*") {
                    $name_nes = $username.ToString().Split('\')[1]
                     Get-AdUSer $name_nes -Server sr-dc-1.nes.corp -Properties emailaddress,department,company  |select name,samaccountname,emailaddress,Department,company | Export-Csv -Path $PSScriptRoot\ad_rdp.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8 -Append
                 }#if
				 #ищем всех в домене KEP.COPR
                elseif ($username -like "*KEP*") {
                        $name_kep = $username.ToString().Split('\')[1]
                       Get-AdUSer $name_kep -Server dc-001.kep.corp -Properties emailaddress,department,company  |select name,samaccountname,emailaddress,Department,company | Export-Csv -Path $PSScriptRoot\ad_rdp.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8 -Append
                    }#elseif
				#ищем всех в домене LOP.COPR
                elseif ($username -like "*LOP*") {
                        $name_lop = $username.ToString().Split('\')[1]
                       Get-AdUSer $name_lop -Server dc-002.lop.corp -Properties emailaddress,department,company  |select name,samaccountname,emailaddress,Department,company | Export-Csv -Path $PSScriptRoot\ad_rdp.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8 -Append
                    }#elseif
               }#foreach fspusers
	}
}