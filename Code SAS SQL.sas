


/*EXERCICE LES DONN�ES */
/*1- Cr�ation des librairies */
LIBNAME inputs "C:\Users\Acheteur\Desktop\CERTIFICAT\LOGC-STAT\TP";
LIBNAME outputs "C:\Users\Acheteur\Desktop\CERTIFICAT\LOGC-STAT\TP";

/*2- Importation des fichiers dans la librairie inputs */
PROC IMPORT DATAFILE="C:\Users\Acheteur\Desktop\CERTIFICAT\LOGC-STAT\TP\calendar.csv"
    OUT=inputs.calendar
    DBMS=CSV
    REPLACE;
    GUESSINGROWS=MAX;
RUN;

PROC IMPORT DATAFILE="C:\Users\Acheteur\Desktop\CERTIFICAT\LOGC-STAT\TP\listings.csv"
    OUT=inputs.listings
    DBMS=CSV
    REPLACE;
    GUESSINGROWS=MAX;
RUN;

PROC IMPORT DATAFILE="C:\Users\Acheteur\Desktop\CERTIFICAT\LOGC-STAT\TP\reviews.csv"
    OUT=inputs.reviews
    DBMS=CSV
    REPLACE;
    GUESSINGROWS=MAX;
RUN;

/*3- description sommaire des tables */.
/* Description de la table calendar */
PROC CONTENTS DATA=inputs.calendar;
RUN;

/* Description de la table listings */
PROC CONTENTS DATA=inputs.listings;
RUN;

/* Description de la table reviews */
PROC CONTENTS DATA=inputs.reviews;
RUN;
/*EXERCICE SQL */
 /* 1-S�lection des neighbourhoods commen�ant par 'A' ou 'E' et comptage des listings */
PROC SQL; 
    SELECT neighbourhood,
           COUNT(*) AS nb_listings
    FROM inputs.listings
    WHERE UPCASE(SUBSTR(neighbourhood, 1, 1)) IN ('A', 'E')
    GROUP BY neighbourhood
    ORDER BY nb_listings DESC;
QUIT;

/* 2-Pour une m�me location, les clients ont-ils tous pay� le m�me prix */
PROC SQL;
    SELECT listing_id,
           COUNT(DISTINCT price) AS unique_price_count
    FROM inputs.calendar
    GROUP BY listing_id
    HAVING unique_price_count > 1;
QUIT;

/*COMENTAIRE REPONSE 2;nous constatons que la sortie est vide. Cela s'explique par le fait que la condition HAVING unique_price_count > 1 n'est remplie par aucun listing_id*/

/*3-Existe-t-il une diff�rence entre le prix pay� par les clients et le prix affich� du listing (pour les listings qui ont un prix renseign�)*/

/* �tape 1 : Conversion de la colonne `price` en num�rique dans calendar */
proc sql;
   create table inputs.calendar_cleaned as
   select *,
          /* Retirer le symbole $ et convertir en num�rique */
          input(compress(price, '$'), best12.) as paid
   from INPUTS.calendar
   where price is not missing;
quit;

/* �tape 2 : Filtrage des listings avec un prix renseign� et jointure */

proc sql;
   create table outputs.price_comparison as
   select 
       l.*,                          /* Tous les champs de listings */
       c.paid,                       /* Prix pay� de calendar */
       (l.price - c.paid) as diff_price /* Diff�rence entre prix affich� et pay� */
   from 
       inputs.listings as l
   inner join 
       inputs.calendar_cleaned as c
   on 
       l.id = c.listing_id           /* Jointure sur identifiant */
   where 
       l.price is not missing         /* Filtrer pour les prix renseign�s */
       and c.paid is not missing      /* Filtrer pour les prix pay�s renseign�s */
   order by 
       l.id asc;                      /* Ordre croissant selon l'id */
quit;

/*4 - listing ayant re�u au moins 10 reviews*/
/* �tape 1 : Calculer le nombre total d'avis, la date minimale, et la date maximale pour chaque listing */
proc sql;
   create table INPUTS.listing_review_stats as
   select 
       listing_id,
       min(date) as min_date format=date9.,     /* Date du premier avis, format�e en date9 */
       max(date) as max_date format=date9.,     /* Date du dernier avis, format�e en date9 */
       count(id) as nb_reviews                  /* Nombre total d'avis */
   from 
       inputs.reviews
   group by 
       listing_id
   having 
       nb_reviews >= 10;                        /* Garder uniquement les listings avec 10 avis ou plus */
quit;

/* �tape 2 : Calculer le nombre de jours entre la date la plus ancienne et la date la plus r�cente */
data outputs.reviews_analysis;
   set inputs.listing_review_stats;
   nb_days = max_date - min_date;               /* Calculer la diff�rence en jours */
run;

/* �tape 3 : Trier la table par nb_reviews en ordre d�croissant */
proc sort data=outputs.reviews_analysis;
   by descending nb_reviews;
run;

/*5 - V�rification colonne number_of_reviews*/
/* �tape 1 : Calculer le nombre de reviews dans la table reviews pour chaque listing_id */
proc sql;
   create table inputs.review_counts as
   select 
       listing_id,
       count(id) as computed_reviews /* Calcul du nombre d'avis pour chaque listing_id */
   from 
       inputs.reviews
   group by 
       listing_id;
quit;

/* �tape 2 : Joindre review_counts avec listings et comparer les r�sultats */
proc sql;
   create table outputs.review_verification as
   select 
       l.id as listing_id,
       l.number_of_reviews,
       r.computed_reviews
   from 
       inputs.listings as l
   left join 
       inputs.review_counts as r
   on 
       l.id = r.listing_id
   where 
       l.number_of_reviews ne 0             /* Exclure les listings avec 0 avis */
       and (r.computed_reviews ne l.number_of_reviews
            or r.computed_reviews is null); /* V�rifier les discordances ou l'absence d'avis */
quit;
/*COMMENTAIRE REPONSE 5;cela signifie qu�il n�y a aucune discordance entre number_of_reviews dans la table listings et le nombre d'avis calcul� dans reviews 
Ce r�sultat confirme que les donn�es de listings et reviews sont coh�rentes*/

/* 6-h�te ayant le plus de propri�t�s en location*/
/* �tape 1 : V�rifier que chaque host_id correspond � un seul host_name */
proc sql;
   create table inputs.unique_hosts as
   select 
       host_id, 
       count(distinct host_name) as name_count
   from 
       inputs.listings
   group by 
       host_id
   having 
       name_count > 1;
quit;

/*  table work.unique_hosts est vide, cela signifie qu'il n'y a aucune anomalie,
   chaque host_id correspond bien � un unique host_name. */

/* �tape 2 : Calculer le nombre total de propri�t�s par h�te */
proc sql;
   create table inputs.host_property_counts as
   select 
       host_id,
       host_name,
       count(id) as total_properties
   from 
       inputs.listings
   group by 
       host_id, 
       host_name;
quit;

/* �tape 3 : Comparer le champ calcul� avec calculated_host_listings_count */
proc sql;
   create table inputs.validation as
   select 
       a.host_id,
       a.host_name,
       a.total_properties,
       b.calculated_host_listings_count
   from 
       inputs.host_property_counts as a
   inner join 
       inputs.listings as b
   on 
       a.host_id = b.host_id
   group by 
       a.host_id, 
       a.host_name
   having 
       total_properties ne calculated_host_listings_count; /* V�rifier les diff�rences */
quit;

/* table work.validation est vide, alors le champ calculated_host_listings_count est correct */

/* �tape 4 : Identifier l�h�te avec le plus de propri�t�s */
proc sql;
   create table outputs.top_host as
   select 
       host_id,
       host_name,
       total_properties
   from 
       inputs.host_property_counts
   where 
       total_properties = (select max(total_properties) from inputs.host_property_counts)
   order by 
       total_properties desc;
quit;

/*7 - Durant quel mois de l�ann�e le nombre de reviews est-il le plus �lev�*/
/* �tape 1 : Extraire le mois de chaque review et calculer le nombre de reviews par mois */
proc sql;
   create table inputs.monthly_reviews as
   select 
       month(date) as review_month,  /* Extraction du mois de la date */
       count(*) as total_reviews     /* Comptage des avis par mois */
   from 
       inputs.reviews
   group by 
       review_month;
quit;

/* �tape 2 : Identifier le mois avec le plus grand nombre de reviews */
proc sql;
   create table outputs.top_review_month as
   select 
       review_month,
       total_reviews
   from 
       inputs.monthly_reviews
   where 
       total_reviews = (select max(total_reviews) from inputs.monthly_reviews)
   order by 
       review_month;
quit;

/*8-listings pour lesquels neighbourhood_group est egale � west-seattle*/

proc sql;
   create table inputs.comments_length as
   select 
       l.id as listing_id,                      /* Index du listing */
       l.name as listing_name,                  /* Nom du listing */
       r.comments,                              /* Commentaire */
       length(r.comments) as comment_length,    /* Longueur du commentaire */
       /* D�finition de la cat�gorie de longueur du commentaire */
       case 
           when length(r.comments) < 100 then 'moins de 100 caract�res'
           when length(r.comments) between 100 and 300 then 'de 100 � 300 caract�res'
           when length(r.comments) between 301 and 500 then 'de 300 � 500 caract�res'
           else 'plus de 500 caract�res'
       end as comment_length_cat
   from 
       inputs.listings as l
   inner join 
       inputs.reviews as r
   on 
       l.id = r.listing_id                      /* Jointure sur l'id du listing */
   where 
       l.neighbourhood_group = 'West Seattle';  /* Filtre pour West Seattle */
quit;
/*EXERCICE SAS */
/*1-les annonces contiennent le mot'wonderfull'*/

/*rechercher 'wonderful' dans les annonces */
data outputs.table_wonderful;
   set inputs.listings;
/* Rechercher 'wonderful' dans la colonne `name` (insensible � la casse) */
   if find(lowcase(name), 'wonderful') > 0 then output;
run;

/*2-Cr�ation une macro variable appel�e neighbourhoods_of_interest*/

/* D�finir la macro variable neighbourhoods_of_interest */
%let neighbourhoods_of_interest = Alki Ravenna;

/* Afficher dans le log avec un message personnalis� */
%put NOTE: neighbourhoods of interest : &neighbourhoods_of_interest;

/*3-Cr�ation d�une fonction dans SAS*/
%macro stat_desc(entry_data=, variable_of_interest=, split_variable=, split_values=, intermediate_plots=False);

    /* �tape 0 : Cr�er une table vide pour stocker les observations 'Average' */
    data inputs.table_average_f;
        set &entry_data;
        if 0;
    run;

    /* Boucle sur chaque valeur dans split_values */
    %let n = %sysfunc(countw(&split_values));
    %do i = 1 %to &n;
        %let current_value = %scan(&split_values, &i);

        /* �tape 1 : Filtrer les donn�es pour la valeur actuelle de split_values */
        data inputs.filtered_data;
            set &entry_data;
            if &split_variable = "&current_value";
        run;

        /* �tape 2 : Calcul de la moyenne de la variable d'int�r�t pour cette cat�gorie sans `proc means` */
        /* Utilisation de deux �tapes pour calculer la somme et la moyenne */
        data _null_;
            retain sum_value 0 count_value 0;
            set inputs.filtered_data end=last;
            sum_value + &variable_of_interest;
            count_value + 1;
            if last then do;
                call symputx('mean_value', sum_value / count_value);
            end;
        run;

        /* �tape 4 : Cr�ation de la variable variable_of_interest_range */
        data inputs.categorized_data;
            set inputs.filtered_data;
            if &variable_of_interest >= 1.1 * &mean_value then variable_of_interest_range = 'High range';
            else if &variable_of_interest <= 0.9 * &mean_value then variable_of_interest_range = 'Low range';
            else variable_of_interest_range = 'Average';
        run;

        /* �tape 5 : Cr�ation d'un comptage pour histogramme sans `proc sgplot` */
        %if &intermediate_plots = True %then %do;
            data inputs.histogram_data;
                set inputs.categorized_data;
                select (variable_of_interest_range);
                    when ('High range') high_count + 1;
                    when ('Low range') low_count + 1;
                    when ('Average') average_count + 1;
                    otherwise;
                end;
            run;
        %end;

        /* �tape 7 : Stocker les observations 'Average' dans table_average_f */
        data inputs.table_average_f;
            set inputs.table_average_f inputs.categorized_data(where=(variable_of_interest_range = 'Average'));
        run;

    %end;

    /* �tape 8 : Cr�er un comptage final pour la distribution de la variable d�int�r�t */
    data inputs.final_histogram;
        set inputs.table_average_f;
        by &split_variable;
        if first.&split_variable then do;
            high_count = 0;
            low_count = 0;
            average_count = 0;
        end;
        select (variable_of_interest_range);
            when ('High range') high_count + 1;
            when ('Low range') low_count + 1;
            when ('Average') average_count + 1;
            otherwise;
        end;
        if last.&split_variable;
    run;

%mend stat_desc;

/*5-test de fonction*/

%let neighbourhoods_of_interest = Alki Ravenna;
%stat_desc(
    entry_data=inputs.listings, 
    variable_of_interest=price, 
    split_variable=neighbourhood, 
    split_values=&neighbourhoods_of_interest, 
    intermediate_plots=True
);

