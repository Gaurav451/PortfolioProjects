select *
from PortfolioProject.dbo.[ NashvilleHousings]

-- Changing SaleDate to only Date Format

select SaleDateChanged, CONVERT(date, SaleDate) as Date
from PortfolioProject..[ NashvilleHousings]

-- Updating above changes in the main table

ALTER  TABLE PortfolioProject..[ NashvilleHousings]
add SaleDateChanged Date;

UPDATE PortfolioProject..[ NashvilleHousings]
Set SaleDateChanged = CONVERT(Date, SaleDate)


-- Populating Property address field

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[ NashvilleHousings] a
join PortfolioProject..[ NashvilleHousings] b
 on  a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[ NashvilleHousings] a
join PortfolioProject..[ NashvilleHousings] b
 on  a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null


-- Checking the data again

select *
from PortfolioProject.dbo.[ NashvilleHousings]

-- Checking on the Property address and owner address column

select PropertyAddress
from PortfolioProject.dbo.[ NashvilleHousings]

-- As it contains City name too, we will separate that using ',' as the delimeter

select SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
      ,SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as city_split

from PortfolioProject.dbo.[ NashvilleHousings]

ALTER  TABLE PortfolioProject..[ NashvilleHousings]
add AddressSplit nvarchar(255);

UPDATE PortfolioProject..[ NashvilleHousings]
Set AddressSplit = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

ALTER  TABLE PortfolioProject..[ NashvilleHousings]
add CitySplit nvarchar(255);

UPDATE PortfolioProject..[ NashvilleHousings]
Set CitySplit = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select * 
from PortfolioProject..[ NashvilleHousings]

-- cleaning of owner address column

select OwnerAddress
from PortfolioProject..[ NashvilleHousings]

select PARSENAME(replace(OwnerAddress, ',', '.'), 3)
      ,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
	  ,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..[ NashvilleHousings]

ALTER  TABLE PortfolioProject..[ NashvilleHousings]
add OwnerAddressSplit nvarchar(255);

UPDATE PortfolioProject..[ NashvilleHousings]
Set OwnerAddressSplit = PARSENAME(replace(OwnerAddress, ',', '.'), 3)


ALTER  TABLE PortfolioProject..[ NashvilleHousings]
add OwnerCitySplit nvarchar(255);

UPDATE PortfolioProject..[ NashvilleHousings]
Set OwnerCitySplit = PARSENAME(replace(OwnerAddress, ',', '.'), 2)


ALTER  TABLE PortfolioProject..[ NashvilleHousings]
add OwnerStateSplit nvarchar(255);

UPDATE PortfolioProject..[ NashvilleHousings]
Set OwnerStateSplit = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject..[ NashvilleHousings]


ALTER  TABLE PortfolioProject..[ NashvilleHousings]
drop column AddressSplit1, CitySplit1, StateSplit;

select *
from PortfolioProject..[ NashvilleHousings]


-- Cleaning SoldAsVacant Column

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..[ NashvilleHousings]
group by SoldAsVacant
order by 2

-- We will change N to No and Y to Yes to maintain standardization

select SoldAsVacant
      ,Case when SoldAsVacant = 'N' then 'No'
	        when SoldAsVacant = 'Y' then 'Yes'
			else SoldAsVacant
			end
from PortfolioProject..[ NashvilleHousings]

update PortfolioProject..[ NashvilleHousings]
set SoldAsVacant = Case when SoldAsVacant = 'N' then 'No'
	        when SoldAsVacant = 'Y' then 'Yes'
			else SoldAsVacant
			end

select *
from PortfolioProject..[ NashvilleHousings]


-- Remove Duplicates(Using CTE and Window function)


with RowCte as (
select *,
       row_number() over (
	                        partition by ParcelID,
							             PropertyAddress,
										 SalePrice,
										 SaleDate,
										 LegalReference
										 order by UniqueID
                         ) row_num
from PortfolioProject..[ NashvilleHousings]
)
select * 
from RoWCte
where row_num > 1


-- Deleting Unused Columns


select *
from PortfolioProject..[ NashvilleHousings]

alter table PortfolioProject..[ NashvilleHousings]
drop column OwnerAddress, PropertyAddress, TaxDistrict

alter table PortfolioProject..[ NashvilleHousings]
drop column SaleDate


