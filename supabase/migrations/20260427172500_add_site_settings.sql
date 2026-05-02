-- Add site_name and portfolio_btn_text to profiles
alter table public.profiles
add column site_name text default 'KruPortfolio',
add column portfolio_btn_text text default 'คลังสื่อการสอน';
