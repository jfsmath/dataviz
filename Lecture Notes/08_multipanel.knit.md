---
title: "Data Visualization in R"
subtitle: "MultiPanel and Layout"
author: "Fushuai Jiang"
date: "2025-09-05"
output: beamer_presentation

urlcolor: blue

---




# `facet_`

## Main functions: `facet_wrap()` and `facet_grid()`

- Reference: chapter 9 and chapter 16 of [ggplot2: Elegant Graphics for Data Analysis](https://ggplot2-book.org/facet.html)


- The `facet_` function allows us to make visually effective multi-grid plots, where each grid displays a different value of the **faceted variable**

- **Benefit:** declutter a busy picture for better comparison

- `facet_Wrap()` splits (facets) on **one variable**

- `facet_grid` splits on multiples (can get pretty busy pretty quickly)



## Main functions: `facet_wrap()` and `facet_grid()`

![](images/08_facet.png)

\tiny From *ggplot2: Elegant Graphics for Data Analysis* 


## Example: `oecd_le`

\tiny

``` r
library(socviz, ggplot2)
p <- ggplot(oecd_le, aes(x = year, y = lifeexp))
p + geom_line(aes(group = country)) # + labels
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-1-1} \end{center}



## `facet_wrap()` example: `oecd_le`

- It makes a long ribbon of panels (determined by `unique(data$var)`)

- `ncol` or `nrow` controls the dimension (only need to specify one of them)

- `dir` contorls the direction of the wrap **h**orizontal or **v**ertical



``` r
p + facet_wrap(~country)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-2-1} \end{center}


## `facet_wrap()` example: `oecd_le`


``` r
p + facet_wrap(~country, nrow = 4, dir = "v")
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-3-1} \end{center}

## `facet_wrap()` example: `oecd_le`


``` r
p + facet_wrap(~country, ncol = 7, dir = "h") + 
  geom_line()
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-4-1} \end{center}

## `facet_wrap()`: USA vs others

Suppose I want to compare USA vs other countries. How to fix the following plot?


``` r
p + facet_wrap(~is_usa) + geom_line()
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-5-1} \end{center}
## `facet_wrap()`: USA vs others


``` r
p + facet_wrap(~is_usa) + geom_line(aes(group = country))
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-6-1} \end{center}

What else can we do to tell a better story?

## 


``` r
p2 <- p + facet_wrap(~is_usa) + geom_line(aes(group = country), alpha = 0.4) + 
  geom_smooth(se = F, color= "red", linewidth = 1.7)
p2
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-7-1} \end{center}

## Labeling with faceted plots


``` r
fac.labs <- c(other = "Non-US OECD countries", 
              usa  = "USA")
p2 + facet_wrap(~is_usa, 
                labeller = labeller(is_usa = fac.labs)) + 
labs(title = "Life Expectancy of USA vs non-US OECD countries", x = "Year", y = "Life Expectancy (in years)", caption = "Source: OECD data") + ggthemes::theme_tufte()
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-8-1} \end{center}


## Named Character Vectors in `R`

- The `fac.lab` object is a **named character vector** in `R`. These are quite useful for custom labeling


``` r
fac.labs
```

```
##                   other                     usa 
## "Non-US OECD countries"                   "USA"
```

``` r
typeof(fac.labs)
```

```
## [1] "character"
```

``` r
is.vector(fac.labs)
```

```
## [1] TRUE
```

``` r
names(fac.labs)
```

```
## [1] "other" "usa"
```


## `facet_Wrap()` example: diamonds


``` r
ggplot(diamonds, aes(x = clarity, y = price)) + 
  geom_boxplot(aes(color = clarity)) + facet_wrap(~cut) + 
  scale_y_log10(labels = scales::dollar)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-10-1} \end{center}



## `facet_grid`



`facet_grid()` lays out plots in a 2d grid:

- `. ~ var` spreads the values of `var` across the columns
  
- `var ~ .` spreads the values of `var` across the rows
  
- `var1 ~ var2` spreads the values of `var1` across the rows, and `var2` across the columns
  
- The `.` is a placeholder, facilitating the comparison of the corresponding positions
  

## `facet_grid()` on diamonds

```{=latex}
\begin{columns}
\column{0.5\textwidth}
```


``` r
ggplot(diamonds) + 
  facet_grid(. ~ cut)
```



\begin{center}\includegraphics[width=1\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-11-1} \end{center}

```{=latex}
\column{0.5\textwidth}
```


``` r
ggplot(diamonds) + 
  facet_grid(clarity ~ .)
```



\begin{center}\includegraphics[width=1\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-12-1} \end{center}

```{=latex}
\end{columns}
```






## `facet_grid()` on diamonds


``` r
ggplot(dplyr::slice_sample(diamonds, n = 5000)) + 
  facet_grid(clarity ~ cut) + 
  geom_point(aes(x = carat, y = price), size = 0.6, alpha = 0.4) + 
  geom_smooth(aes(x = carat, y = price), se = F)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-13-1} \end{center}




## `facet_grid()` on `mpg`, labeling


``` r
str(mpg)
```

```
## tibble [234 x 11] (S3: tbl_df/tbl/data.frame)
##  $ manufacturer: chr [1:234] "audi" "audi" "audi" "audi" ...
##  $ model       : chr [1:234] "a4" "a4" "a4" "a4" ...
##  $ displ       : num [1:234] 1.8 1.8 2 2 2.8 2.8 3.1 1.8 1.8 2 ...
##  $ year        : int [1:234] 1999 1999 2008 2008 1999 1999 2008 1999 1999 2008 ...
##  $ cyl         : int [1:234] 4 4 4 4 6 6 6 4 4 4 ...
##  $ trans       : chr [1:234] "auto(l5)" "manual(m5)" "manual(m6)" "auto(av)" ...
##  $ drv         : chr [1:234] "f" "f" "f" "f" ...
##  $ cty         : int [1:234] 18 21 20 21 16 18 18 18 16 20 ...
##  $ hwy         : int [1:234] 29 29 31 30 26 26 27 26 25 28 ...
##  $ fl          : chr [1:234] "p" "p" "p" "p" ...
##  $ class       : chr [1:234] "compact" "compact" "compact" "compact" ...
```
## Exercise: `facet_grid()` on `mpg`



- Suppose we want to visualize the relationship between the engine displacement (`displ`) and the highway fuel efficiency (`mpg`), 
- categorized by drive train (`drv`) and the types of car (`class`), 
- and use colors to distinguish years.


## `facet_grid()` on `mpg`


``` r
p <- ggplot(mpg, aes(x=displ, y = hwy))+ 
  geom_point(aes(color = as.factor(year))) + 
  facet_grid(class~drv)
p
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-15-1} \end{center}




## `facet_grid()` on `mpg`, LABELING



``` r
unique(mpg$drv)
```

```
## [1] "f" "4" "r"
```

``` r
unique(mpg$class)
```

```
## [1] "compact"    "midsize"    "suv"        "2seater"    "minivan"   
## [6] "pickup"     "subcompact"
```


``` r
r_labs <- c("4" = "Four Wheel Drive", 
            "f"= "Front Wheel Drive", 
            "r" = "Rear Wheel Drive")
c_labs <- c('2seater' ="Two seater", 
'compact'="Compact", 'midsize'="Mid-size", 
'minivan'="Minivan", 'pickup'="Pickup truck", 
'subcompact'="Subcompact", 'suv'="Suv")
```




## `facet_grid()` on `mpg`, LABELING


``` r
p + facet_grid(drv~class,labeller = labeller(
  drv = r_labs, class = c_labs))
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-18-1} \end{center}




## Axial scaling


In `facet_`, you can control  if position scales are the same in all panels (`fixed`) or allowed to vary between panels (`free`) with the scales parameter

- `scales = "fixed"`: both x and y scales are fixed

- `scales = "free_x"` or `"free_y"`: free one, fix the other

- `scales = "free"`: both free

- **Why fixed?** -- easier to see patterns across panels

- **Why free?** -- easier to see patterns within panels


## Default: fixed scales


``` r
p + geom_abline(intercept = c(0,0), slope =10)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-19-1} \end{center}

``` r
# a reference line with intercept at the origin 
# and slope 10, see ?geom_abline
```


## `scales = "free_y"`


``` r
p + geom_abline(intercept = c(0,0), slope =10) + 
  facet_grid(class~drv, scales = "free_y")
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-20-1} \end{center}

## `scales = "free"`


``` r
p + geom_abline(intercept = c(0,0), slope =10) + 
  facet_grid(class~drv, scales = "free")
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-21-1} \end{center}





## When free scaling matters


``` r
# ?economics_long
str(economics_long)
```

```
## tibble [2,870 x 4] (S3: tbl_df/tbl/data.frame)
##  $ date    : Date[1:2870], format: "1967-07-01" "1967-08-01" ...
##  $ variable: chr [1:2870] "pce" "pce" "pce" "pce" ...
##  $ value   : num [1:2870] 507 510 516 512 517 ...
##  $ value01 : num [1:2870] 0 0.000265 0.000762 0.000471 0.000916 ...
```

``` r
unique(economics_long$variable)
```

```
## [1] "pce"      "pop"      "psavert"  "uempmed"  "unemploy"
```


## When free scaling matters


``` r
ggplot(economics_long, aes(date, value)) + geom_line() + 
  facet_wrap(~variable, ncol=1)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-23-1} \end{center}





## When free scaling matters


``` r
ggplot(economics_long, aes(date, value)) + geom_line() + 
  facet_wrap(~variable, ncol=1, scales = "free_y")
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-24-1} \end{center}


- How would you set the $y$-label in this plot?




## Labeling, in faceted variable names


\begin{center}\includegraphics[width=1\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-25-1} \end{center}


## Labeling, in caption


\begin{center}\includegraphics[width=1\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-26-1} \end{center}




## Scales for categorical variables


``` r
mpg2 <- subset(mpg, cyl != 5 & drv %in% c("4", "f") & class != "2seater")
dplyr::slice_sample(mpg2,n=5)
```

```
## # A tibble: 5 x 11
##   manufacturer model       displ  year   cyl trans drv     cty   hwy fl    class
##   <chr>        <chr>       <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
## 1 ford         explorer 4~   5    1999     8 auto~ 4        13    17 r     suv  
## 2 chevrolet    k1500 taho~   5.7  1999     8 auto~ 4        11    15 r     suv  
## 3 dodge        caravan 2wd   4    2008     6 auto~ f        16    23 r     mini~
## 4 land rover   range rover   4.6  1999     8 auto~ 4        11    15 p     suv  
## 5 volkswagen   jetta         2    2008     4 auto~ f        22    29 p     comp~
```
Let's compare the city fuel efficiency by manufacturer. 

## `space` in `facet_grid()`


``` r
ggplot(mpg2, aes(cty, model)) + geom_point() + 
  facet_grid(manufacturer ~ ., scales = "free") + 
  ggthemes::theme_solarized_2() +
  theme(strip.text.y = element_text(angle = 0))
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-28-1} \end{center}



## `space` in `facet_grid()`

`facet_grid()` has an additional parameter called `space` that takes the same value as `scales`

- `space` is free -- each column/row will have width/height proportional to the data range

- Yields **equal scaling across the whole plot** (1 cm on each panel)

- Useful for categorical scales


## `space` in `facet_grid()`


``` r
ggplot(mpg2, aes(cty, model)) + geom_point() + 
  facet_grid(manufacturer ~ ., 
             scales = "free", space = "free") + 
  ggthemes::theme_solarized_2() + 
  theme(strip.text.y = element_text(angle = 0))
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-29-1} \end{center}



## Example: `gapminder` + `oecd_le`, alternative visualization


``` r
oecd2 <- left_join(socviz::oecd_le, gapminder::gapminder, by = "country")
sum(is.na(oecd2$continent))
```

```
## [1] 162
```

``` r
unique(oecd2[is.na(oecd2$continent), ]$country)
```

```
## [1] "Korea"      "Luxembourg" "Estonia"    "Latvia"
```


``` r
oecd2[oecd2$country=="Korea",]$continent <- "Asia"
oecd2[oecd2$country=="Luxembourg",]$continent <- "Europe"
oecd2[oecd2$country=="Estonia",]$continent <- "Europe"
oecd2[oecd2$country=="Latvia",]$continent <- "Europe"
```


## Example: `gapminder` + `oecd_le`



``` r
ggplot(oecd2, aes(lifeexp, y = country)) + geom_point() + 
  facet_grid(continent~., scales = "free", space = "free") + 
  ggthemes::theme_fivethirtyeight() + 
  theme(strip.text.y = element_text(angle = 0))
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-32-1} \end{center}


## Without cleaning the data?



``` r
ggplot(left_join(socviz::oecd_le, gapminder::gapminder, by = "country"), aes(lifeexp, y = country)) + geom_point() + 
  facet_grid(continent~., scales = "free", space = "free") + 
  ggthemes::theme_fivethirtyeight() + 
  theme(strip.text.y = element_text(angle = 0))
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-33-1} \end{center}


## Faceting vs Grouping?

- **Faceting:**  each group is far apart (in its own panel), no group overlap

  - Good if the groups do overlap a lot
  - Hard to see small differences

- **Grouping:** different groups all overlap in the same plot
  - Good if the groups have separation
  - Easier to spot small differences
  
  
## Faceting vs Grouping?
\tiny

``` r
library(gapminder)
library(patchwork)
p1 <- ggplot(subset(gapminder, year %in% c(1952, 2007)), aes(gdpPercap, lifeExp, color = as.factor(year))) + geom_point() + scale_x_log10()
p2 <- ggplot(subset(gapminder, year %in% c(1952, 2007)), aes(gdpPercap, lifeExp, color = as.factor(year))) + geom_point() + scale_x_log10() + facet_wrap(~year)
p1 + p2
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-34-1} \end{center}


## Faceting continous variables


First discretize them! `ggplots` has three helper functions:

- `cut_interval(x,n)`: divide `x` into `n` bins of the same length

- `cut_width(x,width)`: divide `x` into bins of width `width`

- `cut_number(x, n = N)`: divide `x` into `N` bins each with approximately the same number of points


## Faceting continous variables: `carat` in `diamonds`



``` r
# diamonds are just rocks
rocks <- diamonds
# bins of width 1
rocks$by_w <- cut_width(rocks$carat, 1)
# six bins of equal length
rocks$by_l <- cut_interval(rocks$carat, 6)
# eight bins of roughly equal number point
rocks$by_n <- cut_number(rocks$carat, 8)
```




## Faceting continous variables: `carat` in `diamonds`


``` r
p1 <- ggplot(rocks, aes(cut,price)) + geom_boxplot() + 
  facet_wrap(~by_w, nrow = 2)
p1
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-36-1} \end{center}



## Faceting continous variables: `carat` in `diamonds`


``` r
p2 <- ggplot(rocks, aes(cut,price)) + geom_boxplot() + 
  facet_wrap(~by_l, nrow = 2)
p2
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-37-1} \end{center}



## Faceting continous variables: `carat` in `diamonds`


``` r
p3 <- ggplot(rocks, aes(cut,price)) + geom_boxplot() + 
  facet_wrap(~by_n, nrow = 2)
p3
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-38-1} \end{center}



# Patchwork


## Patchwork

`patchwork`: show multiple plots side-by-side using `+`


``` r
library(patchwork)
p1 + p2 + p3
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-39-1} \end{center}

## Arranging the `geom_` side-by-side


``` r
p1 <- ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy))
p2 <- ggplot(mpg) + 
  geom_bar(aes(x = as.character(year), fill = drv), position = "dodge") + labs(x = "year")
p3 <- ggplot(mpg) + 
  geom_density(aes(x = hwy, fill = drv), color = NA) + facet_grid(rows = vars(drv))
p4 <- ggplot(mpg) + 
  stat_summary(aes(x = drv, y = hwy, fill = drv), geom = "col", fun.data = mean_se) + 
  stat_summary(aes(x = drv, y = hwy), geom = "errorbar", fun.data = mean_se, width = 0.5)
```

## 

``` r
p1+p2+p3+p4
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-41-1} \end{center}



## `+plot_layout()`


``` r
p1 + p2 + p3 + p4 +  plot_layout(nrow = 1)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-42-1} \end{center}

## Forcing a single row `|` 


``` r
p1 | p2
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-43-1} \end{center}

## Forcing a single column `/`


``` r
p1 / p2
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-44-1} \end{center}



## Mix and match


``` r
((p1 + p2) / p3) | p4 
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-45-1} \end{center}


## Using the `design` function


``` r
picasso <- "AAB
C#B
CDD"
p1 + p2 + p3 + p4 + plot_layout(design = picasso)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-46-1} \end{center}

## Removing redundant legends using `guides`


``` r
p1 + p2 + p3 + p4 + plot_layout(
  design = picasso,
  guides = "collect")
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-47-1} \end{center}


## You can group them as well


``` r
p12 <- p1 + p2
p12 | p4 
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-48-1} \end{center}

## Modifying all plots

What's wrong with the following plots


``` r
p12 <- p1 + p2
p12 | p4 + ggthemes::theme_solarized(light = F)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-49-1} \end{center}

## Modifying all plots

The fix: using `&` and change the order of the operation (expect trial and error :-))


``` r
(p12 | p4) & ggthemes::theme_solarized(light = F)
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-50-1} \end{center}

## Plots and annotations

After assemply, plots are a single object and annotation (via `plot_annotation`) works on the whole figure


``` r
p34 <- p3 + p4 + 
  plot_annotation(title = "Effect of Drive Train", caption = "Source: mpg dataset")
p34
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-51-1} \end{center}



## Plots and annotations

Annotations are wiped after you assemble using patchwork again.


``` r
p34 / p12
```



\begin{center}\includegraphics[width=0.75\linewidth]{08_multipanel_files/figure-beamer/unnamed-chunk-52-1} \end{center}





