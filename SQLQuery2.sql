/*

Cleaning data in SQL Queries

*/

SELECT *
FROM PortfolioProject..NashVilleHousing

--Standardize date format

SELECT SaleDate, SaleDateConverted, Cast(SaleDate as Date)
FROM PortfolioProject..NashVilleHousing

--Didnt work
UPDATE PortfolioProject..NashVilleHousing
SET SaleDate = Cast(SaleDate as Date)

ALTER TABLE PortfolioProject..NashVilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashVilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




--Popuate property address data


SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null



--Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM PortfolioProject..NashVilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashVilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashVilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashVilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE PortfolioProject..NashVilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change Y and N to Yes and No in "SoldAsVacant" column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashVilleHousing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant, 
CASE When SoldAsVacant = 'Y' then 'Yes' 
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashVilleHousing

Update PortfolioProject..NashVilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes' 
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END




--Remove Duplicates


WITH RowNumCTE AS (
SELECT *,ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference 
					ORDER BY 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashVilleHousing
)

DELETE
From RowNumCTE
Where row_num>1


--Delete Unused Columns

Select*
From PortfolioProject.dbo.NashVilleHousing

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress



