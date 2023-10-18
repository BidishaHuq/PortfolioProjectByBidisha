/*

Cleaning Data in SQL Queires

*/

Select * from
PortfolioProject..NashVilleHousing

-- Standardize date format

Select SaleDate, CONVERT(date, SaleDate) from
PortfolioProject..NashVilleHousing

Update NashVilleHousing
set SaleDate = Convert(date, SaleDate)

select SaleDateConverted from PortfolioProject..NashVilleHousing

Alter table NashVilleHousing
Add SaleDateConverted date

Update NashVilleHousing
set SaleDateConverted = Convert(date, SaleDate)


-- Populate Property Address Data

Select * from PortfolioProject..NashVilleHousing
-- Where PropertyAddress is null
order by ParcelID

-- find out where the Property address is missing for some parcel id 
-- but there is duplicate parcel id, use it to update the missing property address 
-- by joining same table twice

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashVilleHousing a
join PortfolioProject..NashVilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update the table

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashVilleHousing a join PortfolioProject..NashVilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into indivual columns (address, city, state)

Select PropertyAddress from PortfolioProject..NashVilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from PortfolioProject..NashVilleHousing

Alter table NashVilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashVilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashVilleHousing
Add PropertySplitCity nvarchar(255);                

Update NashVilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))


Select * from NashVilleHousing


select OwnerAddress from NashVilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from NashVilleHousing 

Alter table NashVilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashVilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashVilleHousing
Add OwnerSplitCity nvarchar(255);                

Update NashVilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter table NashVilleHousing
Add OwnerSplitState nvarchar(255);

Update NashVilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--- change Y and N to yes and no in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashVilleHousing
group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' Then 'Yes'
	else SoldAsVacant
	end
from NashVilleHousing

Update NashVilleHousing
set SoldAsVacant =Case When SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' Then 'Yes'
	else SoldAsVacant
	end


--- Remove duplicates

WITH RowNumCTE as(
	select *,
	ROW_NUMBER() Over(
		PARTITION By ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by 
			UniqueID
	) row_num
	from NashVilleHousing
)
Select * from
RowNumCTE
where row_num >1
order by PropertyAddress


WITH RowNumCTE as(
	select *,
	ROW_NUMBER() Over(
		PARTITION By ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by 
			UniqueID
	) row_num
	from NashVilleHousing
)
Delete --Select * from
RowNumCTE
where row_num >1
--order by PropertyAddress


--remove unused columns

select * from PortfolioProject..NashVilleHousing


Alter Table PortfolioProject..NashVilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict

Alter Table NashVilleHousing
Drop column Saledate