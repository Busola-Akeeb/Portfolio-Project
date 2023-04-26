--Cleaning Data in SQL Queries

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted =CONVERT(Date, SaleDate);


-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
     AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
     AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


-- Breaking Address into individual columns (Address, City, State)

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Breaking Owner's Address into individual columns

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in Sold As Vacant field

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END;


-- Remove Duplicates

WITH Row_NumCTE AS(
SELECT *,
      ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	  PropertyAddress, 
	  SalePrice, 
	  SaleDate, 
	  LegalReference
	  ORDER BY 
	     UniqueID
		 ) AS Row_Num
FROM NashvilleHousing
)
DELETE 
FROM Row_NumCTE
WHERE Row_Num > 1



-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;



















