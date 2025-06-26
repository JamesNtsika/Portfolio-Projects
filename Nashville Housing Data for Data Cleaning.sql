USE PortfolioProject

SELECT *
FROM NashvilleHousing


/*

Cleaning Data 

*/


------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDateConverted
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;

/* If the ParcelID is the same, the PropertyAddress is Always the same 
   so we can populate the Property Addresses that are null with the ones that 
   have the same ParcelID
*/

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
AND 
	   a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
AND 
	   a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


-- PROPERTY ADDRESS


SELECT *
FROM NashvilleHousing

SELECT PropertyAddress
FROM NashvilleHousing


SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress;

SELECT *
FROM NashvilleHousing

-- OWNER ADDRESS

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS State
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress;

SELECT *
FROM NashvilleHousing

------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" Column

SELECT *
FROM NashvilleHousing;

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END AS SoldAsVacant
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END
;

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing;


------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROM NashvilleHousing;

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY ParcelID,
								   PropertySplitAddress,
								   SaleDateConverted,
								   SalePrice, 
								   LegalReference
								   ORDER BY UniqueID
			         ) AS RowNum
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE RowNum > 1
--ORDER BY PropertySplitAddress



WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY ParcelID,
								   PropertySplitAddress,
								   SaleDateConverted,
								   SalePrice, 
								   LegalReference
								   ORDER BY UniqueID
			         ) AS RowNum
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1
ORDER BY PropertySplitAddress



------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict 

/*======================================END=================================================*/






