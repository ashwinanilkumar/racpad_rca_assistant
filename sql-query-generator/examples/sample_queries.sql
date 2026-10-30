-- Account Management
select * from racadm.account_management_activity where store_id='03596' order by activity_date desc

-- Customer - okta_id
select okta_id,email_address,* from racadm.customer where email_address='lramostt@yahoo.com'

-- Web lead payment

select * from racadm.web_lead_payment where order_number='05221003'
select * from racadm.web_lead_payment_status

select * from racadm.web_lead_payment where first_name like '%first_name%' and last_name like '%last_name%'

-- Agreement
select * from racadm.agreement_status_type;
select * from racadm.agreement where agreement_number = '8172069058';

-- Store 
select * from racadm.store where store_number in ('08555','08522')

-- =============================================================================
-- configadm examples
-- =============================================================================

-- Look up a business rule by name (quick, no joins needed)
select * from configadm.ent_business_rule where param_key_name = 'SameAsCashDays';

-- Full config lookup with scope
select
  pk.param_key_name,
  a.association_ref_code,
  at.association_type_name,
  lov.param_value
from configadm.param_config pc
join configadm.param_key pk on pc.param_key_id = pk.param_key_id
join configadm.association a on pc.association_id = a.association_id
join configadm.association_type at on a.association_type_id = at.association_type_id
join configadm.param_config_list_of_value lov on pc.param_config_id = lov.param_config_id
where pk.param_key_name = 'SameAsCashDays'
  and a.association_ref_code = 'US';

-- =============================================================================
-- prcadm examples
-- =============================================================================

-- Current published product prices for a specific item/zone
select
  pp.rms_item_number,
  pp.zone_number,
  pp.pricing_type,
  pp.weekly_rate,
  pp.monthly_rate,
  pp.cash_price,
  pp.sac_days,
  pp.sac_days_printed,
  pp.epo_pct,
  pp.start_time,
  pp.end_time
from prcadm.product_price pp
where pp.rms_item_master_id = 12345   -- replace with your item ID
  and pp.end_time is null             -- currently active prices
order by pp.zone_number;

-- Pending pricing queue entries (awaiting approval)
select
  pq.pricing_queue_id,
  pq.submitted_by,
  pq.submitted_datetime,
  qst.ref_code        as queue_status,
  pq.company_code,
  pq.success_count,
  pq.fail_count
from prcadm.pricing_queue pq
join prcadm.queue_status_type qst on pq.queue_status_type_id = qst.queue_status_type_id
where qst.ref_code = 'PENDING'   -- replace with desired status
order by pq.submitted_datetime desc;

-- Staged pricing changes in a queue (with SAC days)
select
  pqs.pricing_queue_stage_id,
  pqs.rms_item_master_id,
  pqs.zone_id,
  pqs.weekly_rate_new,
  pqs.weekly_rate_used,
  pqs.sac_days,
  pqs.sac_days_printed,
  pqs.epo_pct,
  pqs.start_date,
  pqs.end_date
from prcadm.pricing_queue_stage pqs
where pqs.pricing_queue_id = 9999;   -- replace with your queue ID

-- Pricing parameter values (config flow)
select
  ppk.pricing_param_key_name,
  ppv.param_value,
  ppv.pricing_type,
  ppv.start_time,
  ppv.end_time
from prcadm.pricing_param_value ppv
join prcadm.pricing_param_key ppk on ppv.pricing_param_key_id = ppk.pricing_param_key_id
where ppk.pricing_param_key_name = 'SacDaysRule'   -- replace with your rule name
  and ppv.end_time is null;

-- Cost pricing rules by zone
select
  cpr.zone_id,
  cpr.rms_department_id,
  cpr.min_rate_pct,
  cpr.max_rate_pct,
  cpr.min_rate_new,
  cpr.max_rate_new,
  cpr.start_date,
  cpr.end_date
from prcadm.cost_pricing_rule cpr
where cpr.zone_id = 1    -- replace with your zone ID
  and cpr.end_date is null
order by cpr.rms_department_id;
