libname project2 "E:\Fall 17\adv sas\project 2";
DATA  abap24;
	set project2.em_save_train;
	IF education="99" THEN education="."; /*Replacing missing values with '.'*/ 
	IF region="*" THEN region="5"; 
	IF age="99" THEN age=".";
run;

PROC SQL;
CREATE TABLE project2.try1 as
(SELECT Unique(USERID),REGION,HHSZ,AGE,INCOME,CHILD,RACE,COUNTRY,WEEKEND,WEEKEND_1,DOMAIN,SUM(QTY)AS COUNT
FROM abap24
GROUP BY USERID,DOMAIN);
QUIT;
DATA project2.try2;
SET project2.try1;
IF domain='amazon.com' THEN DO AMAZON=COUNT;BarnesNoble=0;END;
ELSE IF domain='barnesandnoble.com' THEN DO AMAZON=0; BarnesNoble=COUNT;END;
if weekend = 1 then do weekendqty=COUNT;end;
if weekend_1 = 1 then do weekdqty=COUNT; end;
DROP COUNT;
RUN;
PROC SQL;
CREATE TABLE project2.BarnesNobleupd AS
(SELECT UNIQUE(USERID),REGION,HHSZ,AGE,INCOME,CHILD,RACE,COUNTRY,SUM(weekendqty)AS weekend_qty,SUM(weekdqty)AS weekday_qty,SUM(BarnesNoble)AS BarnesNoble
FROM project2.try2
GROUP BY USERID);
Quit;
proc print data=project2.BarnesNobleupd;
TITLE "10 observations of the count data set";
run;
data project2.BarnesNobleupd1;
set project2.BarnesNobleupd;
if weekend_qty="." then do weekend_qty=0;end;
if weekday_qty="." then do weekday_qty=0;end;
run;
DATA project2.BarnesNobleupd1fn;
SET project2.BarnesNobleupd1;
DROP AMAZON;
RUN;
PROC SQL;
Delete from project2.BarnesNobleupd1fn
where userid=12555609;
Quit;
proc print data=project2.BarnesNobleupd1fn;
TITLE "10 observations of the count data set";
run;
Proc NLMIXED DATA=project2.BarnesNobleupd1fn;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 b8=0  a=1 r=1;
m=exp(b1*HHSZ+b2*AGE+b3*INCOME+b4*CHILD+b5*REGION+b6*RACE+b7*weekend_qty+b8*weekday_qty);
ll=log(gamma(r+BarnesNoble)/(gamma(r)*fact(BarnesNoble))*(a/(a+m))**r*(m/(a+m))**BarnesNoble);
MODEL BarnesNoble~general(ll);
run;



PROC SQL;
CREATE TABLE project2.bn as
(SELECT Unique(USERID),REGION,HHSZ,AGE,INCOME,CHILD,RACE,COUNTRY,WEEKEND,WEEKEND_1,DOMAIN,SUM(QTY)AS COUNT_BN, SUM(price) AS BN_Sales,(SUM(price)/SUM(QTY)) AS avg_bn, (AGE*Income) AS AgeIncome, (AGE*CHILD) AS AgeChild, (CHILD*Region) as ChildRegion, (Region*Income) as RegionIncome 
FROM abap24
where domain = 'barnesandnoble.com'
GROUP BY USERID);
QUIT;
Data project2.bn;
set project2.bn;
if Count_bn > 0 then bn_loyalty=1;end;
else do bn_loyalty=0; end;
Proc NLMIXED DATA=project2.bn;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7= 0  a=1 r=1; 
m=exp(b1*HHSZ+b2*AGE+b3*INCOME+b4*CHILD+b5*REGION+b6*RACE+b7*bn_loyalty);
ll=log(gamma(r+COUNT_BN)/(gamma(r)*fact(COUNT_BN))*(a/(a+m))**r*(m/(a+m))**COUNT_BN);
MODEL COUNT_BN~general(ll);
run;

PROC SQL;
CREATE TABLE project2.az as
(SELECT Unique(USERID),REGION,HHSZ,AGE,INCOME,CHILD,RACE,COUNTRY,WEEKEND,WEEKEND_1,DOMAIN,SUM(QTY)AS COUNT_AZ, SUM(price) AS AZ_Sales, (SUM(price)/SUM(QTY)) AS avg_AZ
FROM abap24
where domain = 'amazon.com'
GROUP BY USERID);
QUIT;
proc print data=project2.az;
TITLE "10 observations of the count data set";
run;
PROC SQL;
Delete from project2.az
where userid=13921766;
Quit;
PROC SQL;
Delete from project2.az
where userid=14647730;
Quit;
Proc NLMIXED DATA=project2.az;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 b6=0  a=0.1 r=0.1;
m=exp(b1*HHSZ+b2*AGE+b3*INCOME+b4*CHILD+b5*avg_AZ+b6*AZ_Sales);
ll=log(gamma(r+COUNT_AZ)/(gamma(r)*fact(COUNT_AZ))*(a/(a+m))**r*(m/(a+m))**COUNT_AZ);
MODEL COUNT_AZ~general(ll);
run;

Proc NLMIXED DATA=project2.bn;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 a=0.1 r=0.1;
m=exp(b1*HHSZ+b2*RACE+b3*REGION+b4*CHILD+b5*AgeIncome);
ll=log(gamma(r+COUNT_BN)/(gamma(r)*fact(COUNT_BN))*(a/(a+m))**r*(m/(a+m))**COUNT_BN);
MODEL COUNT_BN~general(ll);
run;

Proc NLMIXED DATA=project2.bn;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 a=0.1 r=0.1;
m=exp(b1*HHSZ+b2*RACE+b3*REGION+b4*Income+b5*AgeChild);
ll=log(gamma(r+COUNT_BN)/(gamma(r)*fact(COUNT_BN))*(a/(a+m))**r*(m/(a+m))**COUNT_BN);
MODEL COUNT_BN~general(ll);
run;
Proc NLMIXED DATA=project2.bn;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 a=0.1 r=0.1;
m=exp(b1*HHSZ+b2*RACE+b3*AGE+b4*Income+b5*ChildRegion);
ll=log(gamma(r+COUNT_BN)/(gamma(r)*fact(COUNT_BN))*(a/(a+m))**r*(m/(a+m))**COUNT_BN);
MODEL COUNT_BN~general(ll);
run;
Proc NLMIXED DATA=project2.bn;
parms  b1=0 b2=0 b3=0 b4=0 b5=0 a=0.1 r=0.1;
m=exp(b1*HHSZ+b2*RACE+b3*AGE+b4*Child+b5*RegionIncome);
ll=log(gamma(r+COUNT_BN)/(gamma(r)*fact(COUNT_BN))*(a/(a+m))**r*(m/(a+m))**COUNT_BN);
MODEL COUNT_BN~general(ll);
run;

