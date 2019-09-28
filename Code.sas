dm 'clear log'; dm 'clear output'; dm 'odsresults; clear'; /* clear log and output */

libname data "E:\himaja";
title;

proc import out = data.vehicles_raw
	 datafile = "E:\himaja\craigslistVehiclesFull.csv"
	 dbms = tab replace;
	 delimiter = ",";
	 getnames = yes;
	 datarow = 2;
run;

proc datasets;
	 copy in = data out = work;
	 select vehicles_raw;
run;

proc contents data = vehicles_raw varnum;
run;

data vehicles_raw;
	 set vehicles_raw;
	 price_new = input(price,7.);
	 year_new = input(year,6.);
	 odometer_new = input(odometer,8.);
	 drop price;
	 drop year;
	 drop odometer;
	 rename price_new = price;
	 rename year_new = year;
	 rename odometer_new = odometer;
run;

proc sql;
	 create table vehicles14_tmp1 as
	 select city,price,year,manufacturer,condition,
			cylinders,fuel,odometer,title_status,
			transmission,drive,size,type,paint_color
	 from vehicles_raw;
quit;

proc freq data = vehicles14_tmp1;
	 tables city manufacturer condition cylinders
			fuel title_status transmission drive
			size type paint_color / missing;
run;

proc sql;
	 create table vehicles8_tmp1 as
	 select city,price,year,manufacturer,fuel,odometer,title_status,transmission
	 from vehicles_raw;
quit;

data vehicles14_tmp1;
	 set vehicles14_tmp1;
	 if cmiss(city,price,year,manufacturer,condition,
			  cylinders,fuel,title_status,transmission,
			  drive,size,type,paint_color) then delete;
run;

data vehicles8_tmp1;
	 set vehicles8_tmp1;
	 if cmiss(city,price,year,manufacturer,fuel,title_status,transmission) then delete;
run;

proc univariate data = vehicles14_tmp1;
	 var price year;
	 histogram; inset n mean std min max;
run;

proc univariate data = vehicles8_tmp1;
	 var price year;
	 histogram; inset n mean std min max;
run;

proc sql;
	 create table vehicles14_tmp2 as
	 select * from vehicles14_tmp1
	 where price >= 1000 and price <= 46995 and year >= 1985;
quit;

proc sql;
	 create table vehicles8_tmp2 as
	 select * from vehicles8_tmp1
	 where price >= 975 and price <= 49900 and year >= 1985;
quit;

proc univariate data = vehicles14_tmp2;
	 var odometer;
	 histogram; inset n mean std min max;
run;

proc univariate data = vehicles8_tmp2;
	 var odometer;
	 histogram; inset n mean std min max;
run;

proc sql;
	 create table vehicles14_odotest as
	 select * from vehicles14_tmp2 where odometer = .;
quit;

proc sql;
	 create table vehicles14_odotrain as
	 select * from vehicles14_tmp2 where odometer >= 15600 and odometer <= 301000;
quit;

proc sql;
	 create table vehicles8_odotest as
	 select * from vehicles8_tmp2 where odometer = .;
quit;

proc sql;
	 create table vehicles8_odotrain as
	 select * from vehicles8_tmp2 where odometer >= 11715 and odometer <= 287000;
quit;

proc datasets;
	 copy in = work out = data;
	 select vehicles14_odotest vehicles14_odotrain vehicles8_odotest vehicles8_odotrain;
run;

