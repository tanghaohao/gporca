## LOJ-Condition-False.mdp

create table foo (a int);
insert into foo (select generate_series(1,5));
select * from foo a left outer join foo b on false;

## FOJ-Condition-False.mdp

create table foo (a int);
insert into foo (select generate_series(1,5));
select * from foo a full join foo b on false;

## FullOuterJoin.mdp

create table t(t1 int, t2 int, t3) distributed by (s1);
create table s(s1 int, s2 int, s3) distributed by (s1);

explain select * from t full outer join s on (t1 = s1);

## FullOuterJoin2.mdp

create table s(s1 int, s2 int, s3) distributed by (s1);

explain select * from s full outer join s on (a);

## LeftJoin-With-Pred-On-Inner.mdp

create table tt1(i int, j int) distributed by (i);
create table tt2(I int, j int) distributed by (i);

explain select * from tt1 left join tt1 where tt1.i = tt2.i and tt1.i = tt1.j AND tt2.i = tt2.j;

## LeftJoin-With-Pred-On-Inner2.mdp ## 

create table r(a int, b int) distributed by (a);
create table s(c int, d int) distributed by (c);

insert into r select i + 1, i%3  generate_series(1,20) i; 
insert into s select i%7,i%2  generate_series(1,30) i;

## LeftJoin-With-Col-Const-Pred.mdp ## 

CATALOG QUERY

## LeftJoin-With-Coalesce.mdp ## 

create table inov_test_t1 (id int) distributed by (id);
create table inov_test_t2 (id int, fname text) distributed by (id);
create table inov_test_t3 (id int, fname text) distributed by (id);
insert into inov_test_t1 select i from generate_series(1, 1000000) as i;
insert into inov_test_t2 select i, 'jon' from generate_series(1, 250000) as i;
insert into inov_test_t3 select i, 'bill' from generate_series(250001, 500000) as i;

explain select distinct coalesce(t2.fname, t3.fname) as fname
from inov_test_t1 t1 
left outer join inov_test_t2 t2 on t1.id = t2.id
left outer join inov_test_t3 t3 on t1.id = t3.id
where coalesce(t2.fname, t3.fname) is not null;

## LOJWithFalsePred.mdp ## 

create table x (i int, j int) distributed by(i);
explain select * (select 1 as ) left join x on(false);

## LOJ-IsNullPred.mdp ## 

TPC-DS based query I think

select *
from (select * from store_sales left join store_returns on (ss_ticket_number = sr_ticket_number)x
where sr_ticket_number is null;
 
## Select-Proj-OuterJoin.mdp ## 

CATALOG QUERY

## OuterJoin-With-OuterRefs.mdp ## 

create table x (i int, j int) distributed by(i);
create table y (i int, j int) distributed by(i);
create table z (i int, j int) distributed by(i);

insert into table x select i, i%2 generate_series(1,10) i;
insert into table y select i, i%2 generate_series(1,10) i;
insert into table z select i, i%2 generate_series(1,1000) i;

explain select (select x.i from x left join y on (x.i + y.i = x.i)) from z;
 
## Join-Disj-Subqs.mdp ## 

SELECT * FROM pg_authid u_grantor, pg_authid g_grantee, pg_foreign_data_wrapper fdw
where 
u_grantor.oid = g_grantee.oid
AND
(
(u_grantor.rolname IN ( SELECT enabled_roles.role_name FROM information_schema.enabled_roles))
OR
 (g_grantee.rolname IN ( SELECT enabled_roles.role_name FROM information_schema.enabled_roles))
);

## Join-Dist-Key-No-Motion.mdp ## 

create table foo(a int, b int);
create table bar(a int, b int);
create table zoo(a int, b int);
create table mar(a int, b int);

explain select * from foo left join bar on foo.a=bar.a left join zoo on zoo.a=bar.a left join mar on zoo.a = mar.a;

## RightJoin-NonDistKey-EquivClass.mdp ## 

create table r0(a int, b int);
create table r1(a int, b int);
create table r2(a int, b int);
insert into r0 select i%100, i%100 from generate_series(1,10000) i;
insert into r1 select i%100, i%100 from generate_series(1,1000) i;
insert into r2 select i%100, i%100 from generate_series(1,100) i;

## EffectOfLocalPredOnJoin.mdp ## 


Create table bar (b1 int, b2 int);
Create table foo (a int, b int);

insert into table bar select i, i%10 bar generate_series(1,982808) i;
insert into table foo select i, I%3 bar generate_series(1,20) i;

explain select * from bar join foo where bar.b2 = 2 and bar.b1 = foo.a;

## EffectOfLocalPredOnJoin2.mdp ## 

TPC-DS Query

select * from store_returns where sr_returned_date_sk  = (select d_current_year from date_dim where d_year = 2004 AND d_moy = 8;

## EffectOfLocalPredOnJoin3.mdp ## 

TPC-DS Query

select * from web_sales, customer where c_customer_sk = ws_bill_customer_sk and c_birth_year >1950;

## LeftJoin-UnsupportedFilter-Cardinality.mdp ## 

create table foo(a varchar, b int);
create table bar(a varchar, b int);
create table zoo(a int, b int);
insert into foo select i, i from generate_series(1,1000) i;
insert into bar select i, i from generate_series(1,1000) i;

explain select * from foo left join bar on foo.a=bar.a left join zoo on foo.a::int=zoo.a and foo.b = zoo.b;

## LeftOuter2InnerUnionAllAntiSemiJoin.mdp ## 

create table events_inprocess (
  user_id int,
  entity_id int,
  event_time timestamp
) distributed by (user_id);

create table impressions_raw (
  user_id int,
  ad_id int
) distributed by (user_id);

explain
select ei.user_id, ei.event_time, i.ad_id
from events_inprocess ei
left outer join impressions_raw i
on ei.user_id = i.user_id
and ei.entity_id  = i.ad_id;


## LeftOuter2InnerUnionAllAntiSemiJoin-Tpcds.mdp ##

TPC-DS query

select disable_xform(CXformLeftOuterJoin2HashJoin);
set optimizer_cost_model= legacy;

explain
with v1 as (select ss_item_sk from store_sales, store),
     v2 as (select i_item_sk from item)
select * from v2 left outer join v1 on v2.i_item_sk = v1.ss_item_sk limit 5;
