TODO
- DONE questions DONE
    - Share SQL for updates / input?
- DONE booking source field? Why skewed toward iOS this year?

- setup meetings
    - Syed / ?
    - Fergal

- pivots
    -- counts of customers/users by date jo
    -- cummulative counts of customers/users
    -- cummulative counts of is_verified customers
    -- cummulative counts of customers with booking / without a booking
    -- cummulative counts of customers with completed/started booking

- barrier survey feedback
- catchup on slack
- adjust dob logic (per revisions user_discovery_dateOfBirth_042024.sql)
- adjust test user logic to include ezhire in email address
- add in opt outs

QUESTIONS
- DATA SOURCE: Is there a data source for attribution... booking attribution / user attribution? What is the data source for leads?
- DATA SOURCE: Is there a data source for behavior on the app... sessions, visit history, events when they visit... which pages, which significant buttons/clicks, cart details...?
- Do you think about stages of a customer signing up? For example, completed profile, completed payment info, completed documents... stages toward indicating a customer is becoming more committed?

AUTH_USER TABLE
- LAST LOGIN: Is it accurate? Only 1,717 last login dates with a year of 2024?
- IS STAFF / IS ACTIVE / IS SUPERUSER: What is the definition? Are these accurate?

RENTAL_FUSER TABLE
- RENTAL_FUSER / AUTH_USER: Logic to remove test users
- DOB - Why so many bad dates?
- DATE JOIN - What is the official definition?
- DATE JOIN - What is the official logic?
- DATE JOIN - What breakouts are possible (for count of over 1,000 join on 4/20 & 4/21)?
- IS VERIFIED - What is the official logic / definition?
- IS VERIFIED - Why only 16K verified? (576K not verified, 16K verified) 
- COUNTRY / COUNTRY CODE: what do country & country_code represent? for example, lots of country 1 with country_code 971? is country = country of residence? country code phone number code?
- IS RESIDENT: What does is_resident represent? Is it the country of primary residence or country currently residing or something else? What's the correct join?
- RENTING IN: What does renting_in represent? What is the correct join?
- ROLE TYPE: What is role_type? What is the correct join?
- PAYMENT DET ADDED: For Payment_Det_Added is 0 no and 1 yes? 
- PAYMENT DET ADDED BANK: same for payment_det_added_bank? it does look like Payment_Det_Added 1 = yes, but payment_det_added_bank looks the opposite?
- USER SOURCE 1:Is user_source1 the downloaded source? (-- user_source1, -- android, ios, web, website)
- APP VERSION / OS VERSION: Is app_version / ios_version accurate? what is the insight from older versions?
- SOCIAL UID: is this field accurate? How can it be leveraged?
- USER SOURCE: Seems like invalid field
- FIREBASE TOKEN: Is firebase token unique? Is the source of firebase token a download? Why do some tokens have count > 1?
- USER STATUS: What is this field? is it useful?
- IS ONLINE: Is this accurate? Has all 0?
- APP LANGUAGES: What are the app languages? maybe 1 = english and 2 = arabic?