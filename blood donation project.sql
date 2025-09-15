--categorizes amount of people for each group (number of donation)

select top 10 number_of_donation, count (*) as 'amount of people'
from blood_donor
group by  number_of_donation 
order by 'amount of people' desc;


-- amount per blood group

select blood_group, count(*) as 'blood groups'
from blood_donor
group by blood_group


--amount available per blood group

select blood_group, count(*) as available
from blood_donor
where availability = 1
group by blood_group
order by available desc;

--amount unavailable per blood group

select blood_group, count(*) as unavailable
from blood_donor
where availability = 0
group by blood_group
order by unavailable desc;

-- safety level

SELECT
    donor_id,
    name,
    blood_group,
    number_of_donation,
    pints_donated,
    created_at,
    DATEDIFF(MONTH, created_at, GETDATE()) AS months_since_first_donation,
    CASE
        -- Flag obviously impossible data
        WHEN number_of_donation > 100 OR pints_donated > 100 THEN 'INVALID DATA'

        -- Calculate approximate donations per year and classify risk
        WHEN number_of_donation / (NULLIF(DATEDIFF(MONTH, created_at, GETDATE()),0)/12.0) > 12 
             THEN 'HIGH RISK'
        WHEN number_of_donation / (NULLIF(DATEDIFF(MONTH, created_at, GETDATE()),0)/12.0) > 8 
             THEN 'MEDIUM RISK'
        WHEN number_of_donation / (NULLIF(DATEDIFF(MONTH, created_at, GETDATE()),0)/12.0) > 6 
             THEN 'LOW RISK'
        ELSE 'SAFE'
    END AS risk_level
FROM blood_donor
ORDER BY
    CASE
        WHEN number_of_donation > 100 OR pints_donated > 100 THEN 1
        WHEN number_of_donation / (NULLIF(DATEDIFF(MONTH, created_at, GETDATE()),0)/12.0) > 12 THEN 2
        WHEN number_of_donation / (NULLIF(DATEDIFF(MONTH, created_at, GETDATE()),0)/12.0) > 8 THEN 3
        WHEN number_of_donation / (NULLIF(DATEDIFF(MONTH, created_at, GETDATE()),0)/12.0) > 6 THEN 4
        ELSE 5
    END;

    -- not avaiable based on donation count 

SELECT 
    number_of_donation,
    COUNT(*) AS not_available_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percent_not_available
FROM blood_donor
WHERE availability = 0
GROUP BY number_of_donation
ORDER BY not_available_count DESC;


-- avg number of donations when avaiable by blood group

SELECT 
    blood_group,
    AVG(number_of_donation * 1.0) AS avg_donations_available
FROM blood_donor
WHERE availability = 1
GROUP BY blood_group
ORDER BY avg_donations_available DESC;

--percentage of being available per blood group
 SELECT 
    blood_group,
    COUNT(CASE WHEN availability = 1 THEN 1 END) * 100.0 / COUNT(*) AS availability_percentage
FROM blood_donor
GROUP BY blood_group
ORDER BY availability_percentage DESC;


-- percent of availability out of 100 based on blood group

SELECT 
    blood_group,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS availability_percentage
FROM blood_donor
WHERE availability = 1
GROUP BY blood_group
ORDER BY availability_percentage DESC;


--chance of being available
SELECT 
    blood_group,
    availability,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY blood_group) AS chance_percentage
FROM blood_donor
GROUP BY blood_group, availability
ORDER BY blood_group, availability DESC;

--most available/not blood groups

SELECT TOP 1
    blood_group,
    COUNT(CASE WHEN availability = 1 THEN 1 END) * 100.0 / COUNT(*) AS chance_available
FROM blood_donor
GROUP BY blood_group
ORDER BY chance_available DESC;

SELECT TOP 1
    blood_group,
    COUNT(CASE WHEN availability = 0 THEN 1 END) * 100.0 / COUNT(*) AS chance_not_available
FROM blood_donor
GROUP BY blood_group
ORDER BY chance_not_available DESC;

