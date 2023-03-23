/*
Cleaning data in SQL Queries
*/
SELECT *
FROM ProjectA..NationalHousing
------------------------------------------------------------------
-- Standardize Data Format
SELECT SaleDate,CONVERT(Date,SaleDate)
FROM ProjectA..NationalHousing

UPDATE NationalHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NationalHousing
ADD SaleDateConverted Date

UPDATE NationalHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data

SELECT *
FROM ProjectA..NationalHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectA..NationalHousing a
JOIN ProjectA..NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectA..NationalHousing a
JOIN ProjectA..NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into Individual Columns(Address, city, states)

SELECT PropertyAddress
FROM ProjectA..NationalHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING (PropertyAddress,1, CHARINDEX (',',PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)-
+1, LEN(PropertyAddress)) AS Address
FROM ProjectA..NationalHousing

ALTER TABLE NationalHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NationalHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX (',',PropertyAddress)-1)

ALTER TABLE NationalHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NationalHousing
SET PropertySplitCity= SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)-
+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM ProjectA..NationalHousing

SELECT 
PARSENAME (REPLACE (OwnerAddress,',','.'),3),
PARSENAME (REPLACE (OwnerAddress,',','.'),2),
PARSENAME (REPLACE (OwnerAddress,',','.'),1)
FROM ProjectA..NationalHousing

ALTER TABLE NationalHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NationalHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress,',','.'),3)

ALTER TABLE NationalHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NationalHousing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress,',','.'),2)

ALTER TABLE NationalHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NationalHousing
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectA..NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	  WHEN SoldAsVacant ='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM ProjectA..NationalHousing

UPDATE NationalHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	  WHEN SoldAsVacant ='N' THEN 'No'
	  ELSE SoldAsVacant
	  END

--Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,SalePrice,SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM ProjectA..NationalHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

--Delete unused Columns
SELECT *
FROM ProjectA..NationalHousing

ALTER TABLE ProjectA..NationalHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress