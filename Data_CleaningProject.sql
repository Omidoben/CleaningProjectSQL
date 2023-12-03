--Importing the Nashville Housing data
--Create a table and provide column names

CREATE TABLE Nashville_housing (
	UniqueID varchar(5),
	ParcelID varchar(20),
	LandUse varchar(50),
	PropertyAddress varchar(100),
	SaleDate timestamptz,
	SalePrice bigint,
	LegalReference varchar(25),
	SoldAsVacant varchar(3),
	OwnerName text,
	OwnerAddress varchar(120),
	Acreage numeric,
	TaxDistrict varchar(50),
	LandValue bigint,
	BuildingValue bigint,
	TotalValue bigint,
	YearBuilt varchar(4),
	Bedrooms int,
	FullBath int,
	HalfBath int,
	CONSTRAINT Unique_ID_key PRIMARY KEY (UniqueID));
	
COPY nashville_housing
FROM 'F:\Tutorials\sql tutorials\data_sql\Nashville Housing Data.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');


SELECT * FROM nashville_housing;

--First create a copy of the table to perform data cleaning
CREATE TABLE nashville_housing_backup AS
	(SELECT * FROM nashville_housing);
	
SELECT * FROM nashville_housing_backup;

/*Data Cleaning */
------------------------------------------------------
-- 1) Standardize the date format

SELECT saledate, TO_CHAR(saledate, 'yyyy-mm-dd') AS date_standard
FROM nashville_housing;

--Alternatively - use the DATE() function
SELECT saledate, DATE(saledate) AS date_standard2
FROM nashville_housing;

--Create a new column for the standardized date
ALTER TABLE nashville_housing ADD COLUMN date_standard date;

UPDATE nashville_housing
SET date_standard = DATE(saledate);

-- 2) Populate property address where there are null values
	--First check the null values
	
SELECT *
FROM nashville_housing
WHERE property_address IS NULL;


--Use a self join to populate null property_address values
--Use the coalesce() function to replace null values

--Below code tests whether coalesce function works well

SELECT t1.parcelid, t1.property_address, t2.parcelid, t2.property_address, 
			COALESCE(t1.property_address, t2.property_address)
FROM nashville_housing t1
JOIN nashville_housing t2 ON t1.parcelid = t2.parcelid 
	AND t1.uniqueid <> t2.uniqueid
WHERE t1.property_address IS NULL;

--update the null values
UPDATE nashville_housing t1
SET property_address = COALESCE(t1.property_address, t2.property_address)
FROM nashville_housing t2
WHERE t1.parcelid = t2.parcelid
AND t1.uniqueid <> t2.uniqueid
AND t1.property_address IS NULL;


	
-- 3) Break out the property address column into individual columns (address, city)
--Use the substring()
--A display of how it works
SELECT POSITION(',' in property_address) FROM nashville_housing;

SELECT property_address,
		SUBSTRING(property_address, 1, POSITION(',' IN property_address) - 1) AS address,
		SUBSTRING(property_address, POSITION(',' IN property_address) + 1) AS city
FROM nashville_housing;

--Add address and city columns to the table
ALTER TABLE nashville_housing ADD COLUMN address varchar(40);

UPDATE nashville_housing
SET address = SUBSTRING(property_address, 1, POSITION(',' IN property_address) - 1);
	
ALTER TABLE nashville_housing ADD COLUMN city varchar(40);

UPDATE nashville_housing
SET city = SUBSTRING(property_address, POSITION(',' IN property_address) + 1);


-- 4) Break out owner address column into address, city, and state
--SELECT RIGHT(owneraddress, 2) FROM nashville_housing;

--Use split_part() to extract address, city, and state
--Trim() is used to remove any leading or trailing spaces

SELECT owneraddress,
       TRIM(SPLIT_PART(owneraddress, ',', 1)) AS address_split,
       TRIM(SPLIT_PART(owneraddress, ',', 2)) AS city_split,
       TRIM(SPLIT_PART(owneraddress, ',', 3)) AS state_split
FROM nashville_housing;
	

--create new columns
--address_split column
ALTER TABLE nashville_housing ADD COLUMN address_split varchar(40);

UPDATE nashville_housing
SET address_split = TRIM(SPLIT_PART(owneraddress, ',', 1));

--city_split column
ALTER TABLE nashville_housing ADD COLUMN city_split varchar(40);

UPDATE nashville_housing
SET city_split = TRIM(SPLIT_PART(owneraddress, ',', 2));

--state_split column
ALTER TABLE nashville_housing ADD COLUMN state_split varchar(4);

UPDATE nashville_housing
SET state_split  = TRIM(SPLIT_PART(owneraddress, ',', 3));
	
	
-- 5) Transform the soldasvacant column (Change Y to Yes and N to No)

SELECT soldasvacant, count(*)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY count(*) ASC;
	
--Testing the code first
SELECT *,
	(CASE WHEN soldasvacant = 'Y' THEN 'Yes'
			WHEN soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
	   END)
FROM nashville_housing;

--Update the soldasvacant column in the table
UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
			WHEN soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
	   END;	
	

-- 5) Remove duplicates
--First check whether there are duplicates using parcelid, saledate, saleprice, legalreference, property address
--use row_number() and a CTE

--Deletes both duplicates
WITH t1 AS
	(SELECT *,
		ROW_NUMBER() OVER(PARTITION BY parcelid, saledate, saleprice, 
						  legalreference, property_address) AS rn
	FROM nashville_housing)
DELETE FROM nashville_housing
WHERE (parcelid, saledate, saleprice, legalreference, property_address, rn) IN (
    SELECT parcelid, saledate, saleprice, legalreference, property_address, rn
    FROM t1
    WHERE rn > 1);
	
--Keeps one copy of duplicates when you add an order by clause in row_number func

WITH t1 AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY parcelid, saledate, saleprice, 
							 legalreference, property_address ORDER BY uniqueid) AS rn
    FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE (parcelid, saledate, saleprice, legalreference, property_address, rn) IN (
    SELECT parcelid, saledate, saleprice, legalreference, property_address, rn
    FROM t1
    WHERE rn > 1
);


-- 6) Delete unused columns

ALTER TABLE nashville_housing
DROP COLUMN saledate,
DROP COLUMN taxdistrict,
DROP COLUMN property_address,
DROP COLUMN owneraddress;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	