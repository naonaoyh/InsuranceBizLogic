#to run at the cmd prompt> dbxml
#then type openContainer quotes.dbxml
#then you should be able to run the following queries

query 'for $result in collection("quotes.dbxml")/Retailer/Insured
return
     <n2>{$result/CompanyName/text()}{$result/dbxml:metadata("dbxml:name")}</n2>    
'

query  '
declare namespace xupdate="http://www.xmldb.org/xupdate";
for $result in collection("quotes.dbxml")/Retailer
where $result//CompanyName = "coffee"
return
$result
'

query 'for $result in collection("quotes.dbxml")/Retailer
where $result[dbxml:metadata("dbxml:name") = "4a56a8b0-0df9-012b-dd53-0019e33660f5"]
return
<policy>
     <key>{$result/dbxml:metadata("dbxml:name")}</key>
	{$result//CompanyName}
{
for $mta in collection("quotes.dbxml")/MTAS
where $mta/dbxml:metadata("dbxml:name") = concat($result/dbxml:metadata("dbxml:name"),"MTAS")
return
$mta
}
</policy>    
'

query 'for $result in collection("quotes.dbxml")/Retailer
where $result//CompanyName = "coffee"
return
<policy>
     <key>{$result/dbxml:metadata("dbxml:name")}</key>
	{$result//CompanyName}
{
for $mta in collection("quotes.dbxml")/MTAS
where $mta/dbxml:metadata("dbxml:name") = concat($result/dbxml:metadata("dbxml:name"),"MTAS")
return
$mta
}
</policy>    
'

#get MTA data for a policy
query 'for $result in collection("quotes.dbxml")/*
where $result[dbxml:metadata("dbxml:name") = "49484b50-7cbe-012b-da1e-0019e33660f5MTAS"]
return
$result
'

query  '
declare namespace xupdate="http://www.xmldb.org/xupdate";
for $result in collection("quotes.dbxml")/Retailer
let $i := 1
where $result//CompanyName = "coffee"
return
(
    concat(
    "@rowHash = {",
    "\'companyname\' => \'",$result//CompanyName/string(),"\',",
    "\'postcode\' => \'",$result//Insured//Postcode/string(),"\',",
    "\'key\' => \'", $result/dbxml:metadata("dbxml:name"),"\',"),
    "\'mtas\' => [",		
    for $mtas in collection("quotes.dbxml")/MTAS/MTA,
         $mta in collection("quotes.dbxml")
    where $mtas/dbxml:metadata("dbxml:name") = concat($result/dbxml:metadata("dbxml:name"),"MTAS")
    and $mta/dbxml:metadata("dbxml:name") = $mtas/@key
    return (
                concat(
                  "{",
                 "\'AD\' => \'",$mtas/@appliedDateTime/string(),"\',",
                 "\'SD\' => \'",$mtas/@startDateTime/string(),"\',",
                 "\'ED\' => \'",$mtas/@endDateTime/string(),"\',",
                 "\'RB\' => \'",$mtas/@rolledBack/string(),"\',",
                 "\'Changes\' => \'",$mta//xupdate:update/@select," -to- ",$mta//xupdate:update/string(),"\'",
                "},"
                )
            ),
    "]}"
)
'