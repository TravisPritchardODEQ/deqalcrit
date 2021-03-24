
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Installing deqalcrit

Install deqalcrit from github by running this code:

``` r
devtools::install_github('TravisPritchardODEQ/deqalcrit')
```

Only Oregon DEQ users with properly setup access to use the AWQMSdata
backage will be able to use all features. Other users will be able to
use the Al\_crit\_calculator(), Al\_default\_DOC(), and
Al\_default\_criteria() functions, as those do not need access to AWQMS.

# Using deqalcritpackage

This section illustrates a sample workflow for calculating aluminum
criteria.

First, lets load some needed packages:

``` r
library(deqalcrit)
library(AWQMSdata)
```

Next, get some Al data out of AWQMS. In this example, we are going to
use data from the Surface Water Ambient Monitoring program at station
10917-ORDEQ, which is on the Pudding River. We will use the AWQMSdata
package to query Oregon’s AWQMS database from the backend. To install
and setup this package, see
<https://github.com/TravisPritchardODEQ/AWQMSdata>

``` r
al_data_AWQMS <- AWQMSdata::AWQMS_Data(char = "Aluminum",
                                       media = 'Water',
                                       project = 'Surface Water Ambient Monitoring',
                                       station = '10917-ORDEQ')
```

This dataframe is very wide, so for illustration purposes, let’s get rid
of some columns we do not need. Columns that need to be present for the
calculator to work are:

-   MLocID,

-   Lat\_DD,

-   Long\_DD,

-   SampleStartDate,

-   SampleStartTime,

-   SampleMedia

-   SampleSubmedia

If these columns don’t exist, the ancillary data joins won’t work.

``` r
al_data <- al_data_AWQMS %>%
  dplyr::select(MLocID, AU_ID, Lat_DD, Long_DD, SampleStartDate, SampleStartTime,
                SampleMedia, SampleSubmedia, Char_Name, Char_Name, Sample_Fraction,
                Result_Numeric,Result_Operator,  Result_Unit )
```

That gets us:

<div
style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:500px; overflow-x: scroll; width:700px; ">

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
MLocID
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
AU\_ID
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Lat\_DD
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Long\_DD
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartDate
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartTime
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleMedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleSubmedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Char\_Name
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Sample\_Fraction
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Numeric
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Operator
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Unit
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
6.15
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
99.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
20.00
</td>
<td style="text-align:left;">
&lt;
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
53.30
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
12.80
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
54.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
23.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
923.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
30.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
885.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
</tr>
</tbody>
</table>

</div>

Next, we need to get all the ancillary data. The al\_get\_ancillary()
function will query AWQMS and fetch all ancillary data needed to
determine the criteria. It is a wrapper around the AWQMS\_Data()
function that queries the ancillary parameters from monitoring locations
in the aluminum dataset. The date range for the query is the min/max
date of the entire dataset. This supplies much more data than needed,
however, it was the easiest to implement and the code will discard
unneeded data later.

``` r
ancillary_data<- deqalcrit::al_anc_query(al_data)
```

The parameters that are queried are:

-   Organic carbon
-   pH
-   Hardness, Ca, Mg
-   Hardness, non-carbonate
-   Calcium
-   Magnesium
-   Conductivity
-   Specific conductance

Now, we have to run some calculations on these values to get the final
DOC, pH, and Hardness values. And then join them to the Aluminum
dataset. al\_combine\_ancillary() will perform the calculations
identified in the implementation document and then perform the join. The
calculations are a bit complex, but here is what is going on:

1.  Convert all ug/L units to mg/L
2.  If we have dissolved and total fractions at the same date and time,
    keep the dissolved fraction, and drop the total fraction. If we only
    have total fraction, keep the total.
3.  Convert data format from “Long” to “Wide”
4.  If we only have TOC and not DOC, convert TOC to DOC by multiplying
    by 0.83
5.  If we don’t have DOC or TOC, look up the default DOC value by
    lat/long using the published map service at
    <https://arcgis.deq.state.or.us/arcgis/rest/services/WQ/OR_Ecoregions_Aluminum/MapServer>.
6.  If we don’t have Hardness, use calcium and magnesium. If we don’t
    have one of those, use specific conductance.
7.  Split DOC, Hardness and pH into separate dataframes.
8.  Join each of the three dataframes into the aluminum dataset.
    Ancillary data must be collected on the same day. If more than 1
    daily result for an ancillary parameter, only keep the one that is
    nearest in time to the aluminum data.

``` r
al_data_joined <- deqalcrit::al_combine_ancillary(al_df = al_data,
                                       ancillary_df = ancillary_data)
```

That gets us:

<div
style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:500px; overflow-x: scroll; width:700px; ">

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
MLocID
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
AU\_ID
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Lat\_DD
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Long\_DD
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartDate
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartTime
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleMedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleSubmedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Char\_Name
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Sample\_Fraction
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Numeric
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Operator
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Unit
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
DOC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Hardness
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
pH
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
al\_ancillary\_cmt
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
6.15
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.84
</td>
<td style="text-align:right;">
75.8
</td>
<td style="text-align:right;">
7.7
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
99.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.84
</td>
<td style="text-align:right;">
75.8
</td>
<td style="text-align:right;">
7.7
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
20.00
</td>
<td style="text-align:left;">
&lt;
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.65
</td>
<td style="text-align:right;">
59.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
53.30
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.65
</td>
<td style="text-align:right;">
59.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
12.80
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.13
</td>
<td style="text-align:right;">
51.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
54.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.13
</td>
<td style="text-align:right;">
51.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
23.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.22
</td>
<td style="text-align:right;">
45.7
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
923.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.22
</td>
<td style="text-align:right;">
45.7
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
30.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
1.98
</td>
<td style="text-align:right;">
35.4
</td>
<td style="text-align:right;">
7.3
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
885.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
1.98
</td>
<td style="text-align:right;">
35.4
</td>
<td style="text-align:right;">
7.3
</td>
<td style="text-align:left;">
NA
</td>
</tr>
</tbody>
</table>

</div>

At this point, calculating the criteria is as easy as:

``` r
al_criteria <- deqalcrit::al_crit_calculator(al_data_joined)
```

<div
style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:500px; overflow-x: scroll; width:700px; ">

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
MLocID
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
AU\_ID
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Lat\_DD
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Long\_DD
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartDate
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartTime
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleMedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleSubmedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Char\_Name
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Sample\_Fraction
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Numeric
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Operator
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Unit
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
DOC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Hardness
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
pH
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
al\_ancillary\_cmt
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
CCC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
FAV
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
CMC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Final\_CMC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Final\_CCC
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Flag
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
6.15
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.84
</td>
<td style="text-align:right;">
75.8
</td>
<td style="text-align:right;">
7.7
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
884.9625
</td>
<td style="text-align:right;">
4712.758
</td>
<td style="text-align:right;">
2356.379
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
880
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
99.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.84
</td>
<td style="text-align:right;">
75.8
</td>
<td style="text-align:right;">
7.7
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
884.9625
</td>
<td style="text-align:right;">
4712.758
</td>
<td style="text-align:right;">
2356.379
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
880
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
20.00
</td>
<td style="text-align:left;">
&lt;
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.65
</td>
<td style="text-align:right;">
59.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
981.1666
</td>
<td style="text-align:right;">
4754.930
</td>
<td style="text-align:right;">
2377.465
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
53.30
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.65
</td>
<td style="text-align:right;">
59.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
981.1666
</td>
<td style="text-align:right;">
4754.930
</td>
<td style="text-align:right;">
2377.465
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
12.80
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.13
</td>
<td style="text-align:right;">
51.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
975.6439
</td>
<td style="text-align:right;">
4318.714
</td>
<td style="text-align:right;">
2159.357
</td>
<td style="text-align:right;">
2200
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
54.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.13
</td>
<td style="text-align:right;">
51.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
975.6439
</td>
<td style="text-align:right;">
4318.714
</td>
<td style="text-align:right;">
2159.357
</td>
<td style="text-align:right;">
2200
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
23.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.22
</td>
<td style="text-align:right;">
45.7
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
630.6589
</td>
<td style="text-align:right;">
3171.219
</td>
<td style="text-align:right;">
1585.609
</td>
<td style="text-align:right;">
1600
</td>
<td style="text-align:right;">
630
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
923.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.22
</td>
<td style="text-align:right;">
45.7
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
630.6589
</td>
<td style="text-align:right;">
3171.219
</td>
<td style="text-align:right;">
1585.609
</td>
<td style="text-align:right;">
1600
</td>
<td style="text-align:right;">
630
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
30.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
1.98
</td>
<td style="text-align:right;">
35.4
</td>
<td style="text-align:right;">
7.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
543.8967
</td>
<td style="text-align:right;">
2606.035
</td>
<td style="text-align:right;">
1303.018
</td>
<td style="text-align:right;">
1300
</td>
<td style="text-align:right;">
540
</td>
<td style="text-align:left;">
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
885.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
1.98
</td>
<td style="text-align:right;">
35.4
</td>
<td style="text-align:right;">
7.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
543.8967
</td>
<td style="text-align:right;">
2606.035
</td>
<td style="text-align:right;">
1303.018
</td>
<td style="text-align:right;">
1300
</td>
<td style="text-align:right;">
540
</td>
<td style="text-align:left;">
</td>
</tr>
</tbody>
</table>

</div>

If the aluminum result is missing a value for DOC, pH, or hardness; it
will lookup the default criteria values using the lat/long and querying
the GIS web service at
<https://arcgis.deq.state.or.us/arcgis/rest/services/WQ/OR_Ecoregions_Aluminum/MapServer>

And if we wanted the extra information provided in EPA’s criteria
calculation:

``` r
al_criteria_extra <- deqalcrit::al_crit_calculator(al_data_joined, verbose = TRUE)
```

<div
style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:500px; overflow-x: scroll; width:700px; ">

<table class=" lightable-paper" style="font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
MLocID
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
AU\_ID
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Lat\_DD
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Long\_DD
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartDate
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleStartTime
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleMedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
SampleSubmedia
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Char\_Name
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Sample\_Fraction
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Numeric
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Operator
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Result\_Unit
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
DOC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Hardness
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
pH
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
al\_ancillary\_cmt
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
CCC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
FAV
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
CMC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Final\_CMC
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
Final\_CCC
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Flag
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
1\_Chronic\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
1\_Chronic\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
2\_Chronic\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
2\_Chronic\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
3\_Chronic\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
3\_Chronic\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
4\_Chronic\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
4\_Chronic\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
1\_Acute\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
1\_Acute\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
2\_Acute\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
2\_Acute\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
3\_Acute\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
3\_Acute\_Genus
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
4\_Acute\_Genus\_Mean\_Value\_ug\_L
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
4\_Acute\_Genus
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
6.15
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.84
</td>
<td style="text-align:right;">
75.8
</td>
<td style="text-align:right;">
7.7
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
884.9625
</td>
<td style="text-align:right;">
4712.758
</td>
<td style="text-align:right;">
2356.379
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
880
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
1034.72679593329
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1520.08037753046
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
2429.70280579458
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
2530.44325552532
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
5733.17689272201
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
7116.27880497672
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
7889.09161952066
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
19162.4313980968
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-10-14
</td>
<td style="text-align:left;">
13:42:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
99.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.84
</td>
<td style="text-align:right;">
75.8
</td>
<td style="text-align:right;">
7.7
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
884.9625
</td>
<td style="text-align:right;">
4712.758
</td>
<td style="text-align:right;">
2356.379
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
880
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
1034.72679593329
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1520.08037753046
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
2429.70280579458
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
2530.44325552532
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
5733.17689272201
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
7116.27880497672
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
7889.09161952066
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
19162.4313980968
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
20.00
</td>
<td style="text-align:left;">
&lt;
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.65
</td>
<td style="text-align:right;">
59.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
981.1666
</td>
<td style="text-align:right;">
4754.930
</td>
<td style="text-align:right;">
2377.465
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
1089.89109192582
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1601.12028507716
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
2215.76501393158
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
2307.63516507466
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
5228.36486309281
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
7495.66833263363
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
8309.68204679272
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
17475.1599135935
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-06-22
</td>
<td style="text-align:left;">
13:37:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
53.30
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.65
</td>
<td style="text-align:right;">
59.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
981.1666
</td>
<td style="text-align:right;">
4754.930
</td>
<td style="text-align:right;">
2377.465
</td>
<td style="text-align:right;">
2400
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
1089.89109192582
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1601.12028507716
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
2215.76501393158
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
2307.63516507466
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
5228.36486309281
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
7495.66833263363
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
8309.68204679272
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
17475.1599135935
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
12.80
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.13
</td>
<td style="text-align:right;">
51.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
975.6439
</td>
<td style="text-align:right;">
4318.714
</td>
<td style="text-align:right;">
2159.357
</td>
<td style="text-align:right;">
2200
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
1041.54518227944
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1530.09702669035
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
1864.04254199501
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
1941.32955979405
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
4398.43325831024
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
7163.17189639942
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
7941.07720140902
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
14701.2166463018
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-06-30
</td>
<td style="text-align:left;">
12:31:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
54.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.13
</td>
<td style="text-align:right;">
51.7
</td>
<td style="text-align:right;">
7.8
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
975.6439
</td>
<td style="text-align:right;">
4318.714
</td>
<td style="text-align:right;">
2159.357
</td>
<td style="text-align:right;">
2200
</td>
<td style="text-align:right;">
980
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
1041.54518227944
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1530.09702669035
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
1864.04254199501
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
1941.32955979405
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
4398.43325831024
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
7163.17189639942
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
7941.07720140902
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
14701.2166463018
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
23.10
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.22
</td>
<td style="text-align:right;">
45.7
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
630.6589
</td>
<td style="text-align:right;">
3171.219
</td>
<td style="text-align:right;">
1585.609
</td>
<td style="text-align:right;">
1600
</td>
<td style="text-align:right;">
630
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
713.880083163512
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1048.7358697886
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
1532.92321220838
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
1596.4813450929
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
3617.11725301984
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
4909.6725097656
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
5442.85255157447
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
12089.7649796668
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2015-02-05
</td>
<td style="text-align:left;">
11:53:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
923.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
2.22
</td>
<td style="text-align:right;">
45.7
</td>
<td style="text-align:right;">
7.4
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
630.6589
</td>
<td style="text-align:right;">
3171.219
</td>
<td style="text-align:right;">
1585.609
</td>
<td style="text-align:right;">
1600
</td>
<td style="text-align:right;">
630
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
713.880083163512
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
1048.7358697886
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
1532.92321220838
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
1596.4813450929
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
3617.11725301984
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
4909.6725097656
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
5442.85255157447
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
12089.7649796668
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Dissolved
</td>
<td style="text-align:right;">
30.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
1.98
</td>
<td style="text-align:right;">
35.4
</td>
<td style="text-align:right;">
7.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
543.8967
</td>
<td style="text-align:right;">
2606.035
</td>
<td style="text-align:right;">
1303.018
</td>
<td style="text-align:right;">
1300
</td>
<td style="text-align:right;">
540
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
600.852277190911
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
882.690735314912
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
1201.58718144833
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
1251.40744455258
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
2835.28991563957
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
4132.32975303303
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
4581.09201693307
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
9476.60424905603
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
<tr>
<td style="text-align:left;">
10917-ORDEQ
</td>
<td style="text-align:left;">
OR\_SR\_1709000905\_02\_104088
</td>
<td style="text-align:right;">
45.23366
</td>
<td style="text-align:right;">
-122.7502
</td>
<td style="text-align:left;">
2016-02-03
</td>
<td style="text-align:left;">
13:23:00
</td>
<td style="text-align:left;">
Water
</td>
<td style="text-align:left;">
Surface Water
</td>
<td style="text-align:left;">
Aluminum
</td>
<td style="text-align:left;">
Total Recoverable
</td>
<td style="text-align:right;">
885.00
</td>
<td style="text-align:left;">
=
</td>
<td style="text-align:left;">
ug/l
</td>
<td style="text-align:right;">
1.98
</td>
<td style="text-align:right;">
35.4
</td>
<td style="text-align:right;">
7.3
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
543.8967
</td>
<td style="text-align:right;">
2606.035
</td>
<td style="text-align:right;">
1303.018
</td>
<td style="text-align:right;">
1300
</td>
<td style="text-align:right;">
540
</td>
<td style="text-align:left;">
</td>
<td style="text-align:left;">
600.852277190911
</td>
<td style="text-align:left;">
Salmo
</td>
<td style="text-align:left;">
882.690735314912
</td>
<td style="text-align:left;">
Salvelinus
</td>
<td style="text-align:left;">
1201.58718144833
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
1251.40744455258
</td>
<td style="text-align:left;">
Lampsilis
</td>
<td style="text-align:left;">
2835.28991563957
</td>
<td style="text-align:left;">
Daphnia
</td>
<td style="text-align:left;">
4132.32975303303
</td>
<td style="text-align:left;">
Micropterus
</td>
<td style="text-align:left;">
4581.09201693307
</td>
<td style="text-align:left;">
Oncorhynchus
</td>
<td style="text-align:left;">
9476.60424905603
</td>
<td style="text-align:left;">
Ceriodaphnia
</td>
</tr>
</tbody>
</table>

</div>

## Additional tools

These functions use DEQ’s map services to lookup default DOC and
criteria values. These functions send lat/long information to the map
server and returns default values based on geographic location.

``` r
deqalcrit::al_default_DOC(45.23366, -122.7502)
#> [1] 1.16

deqalcrit::al_default_criteria(45.23366, -122.7502, type = "Chronic")
#> [1] 470

deqalcrit::al_default_criteria(45.23366, -122.7502, type = "Acute")
#> [1] 940
```
