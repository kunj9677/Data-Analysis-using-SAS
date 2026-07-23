/* creating a library and importing the data */
/* Upstream imported TSAClaims2002_2017.csv from a SAS OnDemand home path via
   PROC IMPORT. That file is not in the repo (it ships as a .rar), so this bundle
   builds tsa.result_one from a small inline TSA-Claims-shaped sample instead.
   Everything below the DATA step is the author's original code, unchanged. */
data tsa.result_one;
  length Claim_Number $12 Incident_Date 8 Date_Received 8 Airport_Code $5
         Airport_Name $40 Claim_Type $45 Claim_Site $20 Item_Category $40
         Close_Amount 8 Disposition $30 StateName $30 State $2 County $20 City $20;
  infile datalines dsd truncover;
  input Claim_Number $ Incident_Date :date9. Date_Received :date9. Airport_Code $
        Airport_Name $ Claim_Type $ Claim_Site $ Item_Category $ Close_Amount
        Disposition $ StateName $ State $ County $ City $;
  format Incident_Date Date_Received date9. Close_Amount dollar20.2;
datalines;
2002001,04JAN2002,07JAN2002,LAX,Los Angeles Intl,Passenger Property Loss/Personal Injury,Checkpoint,Jewelry,125.50,Approved in Full,california,CA,Los Angeles,Los Angeles
2002002,15FEB2002,20FEB2002,JFK,John F Kennedy Intl,Property Damage/Personal Injury,Checked Baggage,Clothing,0,Denied,new york,NY,Queens,New York
2002003,01MAR2003,05MAR2003,SFO,San Francisco Intl,,Checkpoint,Electronics,500,Closed: Canceled,california,CA,San Mateo,San Francisco
2002004,10APR2004,12APR2004,ORD,Chicago OHare Intl,Property Damage,-,Cameras,89.99,Approved in Full,illinois,IL,Cook,Chicago
2002005,22MAY2005,25MAY2005,SAN,San Diego Intl,Passenger Property Loss,Checkpoint,Computer,1200,Settled,california,CA,San Diego,San Diego
2002006,03JUN2006,01JUN2006,LAX,Los Angeles Intl,Property Damage,Checked Baggage,Clothing,45,Denied,california,CA,Los Angeles,Los Angeles
2002007,14JUL2007,18JUL2007,SFO,San Francisco Intl,-,Checkpoint,Jewelry,0,losed: Contractor Claim,california,CA,San Mateo,San Francisco
2002008,30AUG2008,02SEP2008,SEA,Seattle Tacoma Intl,Passenger Property Loss,Checked Baggage,Sporting Equipment,320.75,Approved in Full,washington,WA,King,Seattle
2002009,09SEP2009,11SEP2009,MIA,Miami Intl,Property Damage,Checkpoint,Cameras,0,Denied,florida,FL,Miami-Dade,Miami
2002010,19OCT2010,20OCT2010,LAX,Los Angeles Intl,Passenger Property Loss,Checkpoint,Jewelry,760.4,Settled,california,CA,Los Angeles,Los Angeles
2002011,25NOV2011,28NOV2011,DFW,Dallas Fort Worth Intl,Property Damage,Checked Baggage,Clothing,55,Approved in Full,texas,TX,Tarrant,Dallas
2002012,07DEC2012,10DEC2012,SFO,San Francisco Intl,Passenger Property Loss,Checkpoint,Computer,999.99,Settled,california,CA,San Mateo,San Francisco
2002013,16JAN2013,18JAN2013,BOS,Boston Logan Intl,Property Damage,Checked Baggage,Sporting Equipment,0,Denied,massachusetts,MA,Suffolk,Boston
2002014,05FEB2014,03FEB2014,LAX,Los Angeles Intl,Passenger Property Loss,Checkpoint,Electronics,410,Approved in Full,california,CA,Los Angeles,Los Angeles
2002015,28MAR2015,30MAR2015,ATL,Hartsfield Jackson Intl,,Checkpoint,Jewelry,0,Closed: Canceled,georgia,GA,Fulton,Atlanta
2002016,11APR2016,14APR2016,SAN,San Diego Intl,Property Damage,Checked Baggage,Clothing,72.5,Denied,california,CA,San Diego,San Diego
2002017,20MAY2017,22MAY2017,SFO,San Francisco Intl,Passenger Property Loss,Checkpoint,Cameras,150,Settled,california,CA,San Mateo,San Francisco
2002018,15JUN2019,18JUN2019,LAX,Los Angeles Intl,Property Damage,Checkpoint,Jewelry,88,Approved in Full,california,CA,Los Angeles,Los Angeles
2002019,,10JUL2011,ORD,Chicago OHare Intl,Passenger Property Loss,Checked Baggage,Clothing,0,Denied,illinois,IL,Cook,Chicago
2002020,03AUG2016,01AUG2016,LAX,Los Angeles Intl,Passenger Property Loss,Checkpoint,Computer,640,Settled,california,CA,Los Angeles,Los Angeles
;
run;

/* sorting the data according to the accending order of the incedent date */
proc sort data=tsa.result_one out=tsa.Claims_NoDups_pre;
 by Incident_Date;
 run;

data tsa.data_cleaned;
set tsa.result_one;

/*formating and giving labels to all teh coloumn names as specified in the table */
format Incident_Date date9.;
format Date_Received date9.;
format Close_Amount Dollar20.2;
label Airport_Code="Airport Code"
 Airport_Name="Airport Name"
 Claim_Number="Claim Number"
 Claim_Site="Claim Site"
 Claim_Type="Claim Type"
 Close_Amount="Close Amount"
 Date_Issues="Date Issues"
 Date_Received="Date Received"
 Incident_Date="Incident Date"
 Item_Category="Item Category";


/* condition for claim_type coloumn*/
if claim_type="" or claim_type="-" then claim_type="unknown";
else if Claim_Type = 'Passenger Property Loss/Personal Injury' then
Claim_Type='Passenger Property Loss';
else if Claim_Type = 'Passenger Property Loss/Personal Injury' then
Claim_Type='Passenger Property Loss';
else if Claim_Type = 'Property Damage/Personal Injury' then
Claim_Type='Property Damage';


/* condition for claim_site coloumn*/
if claim_site="" or claim_site="-" then claim_site="unknown";


/* condition for disposition coloumn*/
if disposition="" or disposition="-" then disposition="unknown";
else if Disposition='Closed: Canceled' then
 Disposition='Closed:Canceled';
else if Disposition='losed: Contractor Claim' then
Disposition='Closed:Contractor Claim';
drop county city;

/* convrerting the value of state in upercase*/
State=upcase(state);
/* convrerting the value of stateName in propcase*/
StateName=propcase(StateName);

/* making new coloumn Date_Issues*/
if (Incident_Date > Date_Received or
 Incident_Date = . or
 Date_Received = . or
 year(Incident_Date) < 2002 or
 year(Incident_Date) > 2017 or
 year(Date_Received) < 2002 or
 year(Date_Received) > 2017) then Date_Issues="Needs Review";

run;

/* removing all the duplicate rows from the data cleaned table*/
proc sort data=tsa.data_cleaned
out=tsa.Claims_NoDups
nodupkey;
by _all_;
run;




/* -----------Analysis of the data and creating a report--------------*/


/* Analyze the overall data to answer the business questions. Be sure to add appropriate
titles.*/

ods pdf file="ClaimsReports.pdf" style=Meadow;
title1 "KUNJ JARIWALA  ROLL NO: A024 B-TECH IT";
title2 "Overall Date Issues in the Data";
proc freq data=tsa.claims_nodups;
 table Date_Issues / nocum nopercent;
run;
title;

ods graphics on;
title "Overall Claims by Year";
proc freq data=TSA.claims_nodups;
 table Incident_Date / nocum nopercent plots=freqplot;
 format Incident_Date year4.;
 where Date_Issues is null;
run;
title;

/* Analyze the state-level data to answer the business questions. Be sure to add
appropriate titles*/

%let StateName=California;
title "&StateName Claim Types, Claim Sites and Disposition
Frequencies";
proc freq data=TSA.claims_nodups order=freq;
 table Claim_Type Claim_Site Disposition / nocum nopercent;
 where StateName="&StateName" and Date_Issues is null;
run;

title "Close_Amount Statistics for &StateName";
proc means data=TSA.claims_nodups mean min max sum maxdec=0;
 var Close_Amount;
 where StateName="&StateName" and Date_Issues is null;
run;
title;
ods pdf close;
