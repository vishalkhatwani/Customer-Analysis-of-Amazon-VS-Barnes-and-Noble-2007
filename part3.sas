libname project2 "E:\Fall 17\adv sas\project 2";
data project2.logistic; 
set project2.BarnesNoble; 
if BarnesNoble > 0 then flag_bn = 1; 
else flag_bn = 0;
if AMAZON > 0 then flag_am = 1; 
else flag_am = 0; 
run;
proc logistic data = project2.logistic; 
model flag_bn =  REGION HHSZ AGE INCOME CHILD RACE COUNTRY/expb; 
run;
proc logistic data = project2.logistic; 
model flag_am =  REGION HHSZ AGE INCOME CHILD RACE COUNTRY/expb; 
run;

Data project2.loyalty;
Set project2.BarnesNoble;
loyalty_Barnes=0;
if Amazon=0 AND BarnesNoble > 0 then loyalty_Barnes=1;
run;
Data project2.loyalty;
Set project2.loyalty;
loyalty_Amazon=0;
if BarnesNoble=0 AND Amazon > 0 then loyalty_Amazon=1;
run;

proc NLMIXED DATA=project2.loyalty;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7= 0  a=1 r=1; 
m=exp(b1*HHSZ+b2*AGE+b3*INCOME+b4*CHILD+b5*REGION+b6*RACE+b7*loyalty_Barnes);
ll=log(gamma(r+BarnesNoble)/(gamma(r)*fact(BarnesNoble))*(a/(a+m))**r*(m/(a+m))**BarnesNoble);
MODEL BarnesNoble~general(ll);
run;
proc NLMIXED DATA=project2.loyalty;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7= 0  a=0.1 r=0.1; 
m=exp(b1*HHSZ+b2*AGE+b3*INCOME+b4*CHILD+b5*REGION+b6*RACE+b7*loyalty_Amazon);
IF AMAZON > 160 THEN ll=LOG(exp(-300));
else ll=log(gamma(r+Amazon)/(gamma(r)*fact(Amazon))*(a/(a+m))**r*(m/(a+m))**Amazon);
MODEL Amazon~general(ll);
run;
proc print data=project2.loyalty;
TITLE "10 observations of the count data set";
run;
PROC SQL;
Delete from project2.loyalty
where userid=14648719;
Quit;
