-- most effective way I've found to clean all undesierable characters from a specified column 
-- add or remove as many additional special characters from the '@special" variable, the query takes care of it's self
Declare @Special varchar(256)
Set @Special = '!"#$%&''()*+,-./:;<=>?@[\\]^_`{|}~'

Select
    Replace(TRANSLATE(my_dirty_column, @Special, Replicate(' ',LEN(@Special))),' ','')
From [mydatabase].[dbo].[mytable]
