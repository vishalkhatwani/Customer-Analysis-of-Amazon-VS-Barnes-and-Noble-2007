libname project2 "E:\Fall 17\adv sas\project 2";
DATA  abap2;
	set project2.aba_project2_data_books;
	IF education="99" THEN education="."; /*Replacing missing values with '.'*/ 
	IF region="*" THEN region="."; 
	IF age="99" THEN age=".";
run;
PROC SQL;
CREATE TABLE project2.table1 as
(SELECT Unique(USERID),REGION,EDUCATION,HHSZ,AGE,INCOME,CHILD,RACE,COUNTRY,DOMAIN,SUM(QTY)AS COUNT
FROM abap2
GROUP BY USERID,DOMAIN);
QUIT;
DATA project2.table2;
SET project2.table1;
IF domain='amazon.com' THEN DO AMAZON=COUNT;BarnesNoble=0;END;
ELSE IF domain='barnesandnoble.com' THEN DO AMAZON=0; BarnesNoble=COUNT;END;
DROP COUNT;
RUN;
PROC SQL;
CREATE TABLE project2.BarnesNoble AS
(SELECT UNIQUE(USERID),EDUCATION,REGION,HHSZ,AGE,INCOME,CHILD,RACE,COUNTRY,SUM(AMAZON)AS AMAZON,SUM(BarnesNoble)AS BarnesNoble
FROM project2.table2
GROUP BY USERID);
Quit;
DATA project2.final;
SET project2.BarnesNoble;
DROP AMAZON;
RUN;
proc print data=project2.BarnesNoble(obs=10);
TITLE "10 observations of the count data set";
run;

Proc sql;
Create Table project2.nbd1 as
(select BarnesNoble,count(userid)as freq from project2.final
group by BarnesNoble);
run;
proc print data=project2.nbd1;
TITLE "10 observations of the count data set";
run;
PROC NLMIXED DATA=project2.nbd1;
PARMS a=1,r=1;

ll=freq*log(((gamma(r+BarnesNoble))/(gamma(r)*fact(BarnesNoble))*((a/(a+1))**r)* (1/(a+1))**BarnesNoble));;

Model freq~general(ll);
run;

Proc NLMIXED DATA=project2.final;
parms m0=1 b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0;
m=m0*exp(b1*REGION+b2*HHSZ+b3*AGE+b4*INCOME+b5*CHILD+b6*RACE+b7*COUNTRY);
ll=BarnesNoble*log(m)-m-log(fact(BarnesNoble));
MODEL BarnesNoble~general(ll);
run;

Proc NLMIXED DATA=project2.final;
parms b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 a=0.1 r=0.1;
m=exp(b1*REGION+b2*HHSZ+b3*AGE+b4*INCOME+b5*CHILD+b6*RACE+b7*COUNTRY);
ll=log(gamma(r+BarnesNoble)/(gamma(r)*fact(BarnesNoble))*(a/(a+m))**r*(m/(a+m))**BarnesNoble);
MODEL BarnesNoble~general(ll);
run;


Proc NLMIXED DATA=project2.final;
parms  b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 a=0.1 r=0.1;
m=exp(b2*HHSZ+b3*AGE+b4*INCOME+b5*CHILD+b6*RACE+b7*Region);
ll=log(gamma(r+BarnesNoble)/(gamma(r)*fact(BarnesNoble))*(a/(a+m))**r*(m/(a+m))**BarnesNoble);
MODEL BarnesNoble~general(ll);
run;
DATA  project2.final;
	set project2.final;
	IF region="*" THEN region="5"; 
run;

Proc NLMIXED DATA=project2.final;
parms  b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 a=0.1 r=0.1;
m=exp(b2*HHSZ+b3*AGE+b4*INCOME+b5*CHILD+b6*REGION+b7*RACE);
ll=log(gamma(r+BarnesNoble)/(gamma(r)*fact(BarnesNoble))*(a/(a+m))**r*(m/(a+m))**BarnesNoble);
MODEL BarnesNoble~general(ll);
run;
\
