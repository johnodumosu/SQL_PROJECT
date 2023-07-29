/*

Cleaning Data in SQL Queries

*/

SELECT * from Nashville_Housing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, convert(Date, SaleDate) from Nashville_Housing

update Nashville_Housing
SET SaleDate = convert(Date, SaleDate)

-- Let's see if this works
SELECT SaleDate, convert(Date, SaleDate) from Nashville_Housing

-- This update method did not work on the SaleDate Column, lets try another method

ALTER TABLE Nashville_Housing
ADD SaleDateUpdated Date;

UPDATE Nashville_Housing
SET SaleDateUpdated = CONVERT(Date, SaleDate)

--Let's see if this works
SELECT SaleDateUpdated, CONVERT(Date, SaleDate)
FROM Nashville_Housing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate empty property address data

SELECT PropertyAddress FROM Nashville_Housing WHERE PropertyAddress is null

--A check on the entire data show that parcelID that are thesame has same address
SELECT * FROM Nashville_Housing WHERE PropertyAddress is null

SELECT * FROM Nashville_Housing ORDER BY parcelid

--We will use self join to replace empty property address with the propertyaddress of rows that has same parcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress FROM Nashville_Housing a join Nashville_Housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- use ISNULL() FUNCTION TO POPULATE IT
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a JOIN Nashville_Housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Let now update it
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a JOIN Nashville_Housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Lets check again if there are still null values
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a JOIN Nashville_Housing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)
SELECT PropertyAddress FROM Nashville_Housing 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM Nashville_Housing 

-- since CHARINDEX(',', PropertyAddress) is a position remove 1 from it to get rid of the comma at the end of address
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM Nashville_Housing 

-- add the city
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Nashville_Housing


-- it is good to extract and add the column to the table
ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- see the result
SELECT * FROM Nashville_Housing

-- We will do thesame for owner address using a function called PARSENAME
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing




-- it is good to extract the owner address and add the column to the table
ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- see the result
SELECT * FROM Nashville_Housing




----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE
			SoldAsVacant
	END

FROM Nashville_Housing

--Update SoldAsVacant field
UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE
					SoldAsVacant
					END		

-- let's see if it works
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates using CTE
-- Using Partition by to know where there's duplicate
SELECT *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num
FROM Nashville_Housing
ORDER BY ParcelID

-- using CTE to see the duplicats
WITH RowNumCTE AS (
	SELECT *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num
FROM Nashville_Housing
--ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete the duplicate
WITH RowNumCTE AS (
	SELECT *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num
FROM Nashville_Housing
--ORDER BY ParcelID
)
DELETE FROM RowNumCTE
WHERE row_num > 1


-- Let's see if it works
WITH RowNumCTE AS (
	SELECT *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num
FROM Nashville_Housing
--ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress






-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused column like property and owner address because we have already created a split of it. This is often use in views
SELECT * 
FROM Nashville_Housing

ALTER TABLE Nashville_Housing 
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

-- Let's see our table now
SELECT * 
FROM Nashville_Housing


























