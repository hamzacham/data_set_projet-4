CONTEXTE :
Nous allons analyser les données de Airbnb à Seattle.
DONNÉES :
Description :
Source : https://www.kaggle.com/code/pruthvish115/price-tag-a-deep-dive-into-airbnb-listings/input?select=listings.csv
Fichiers de données :
listings.csv : la liste de tous les listings Airbnb de Seattle.
calendar.csv : la dynamique de location des propriétés Airbnb à Seattle.
reviews.csv : la liste des commentaires laissés par les clients des Airbnb de Seattle.
Directives générales :
Le logiciel SAS Enterprise EST utilisé pour réaliser le projet

PARTIE I -Les données 
1 – Créez deux librairies que vous nommerez : inputs et outputs.
2 – Importez, dans la librairie inputs créée à la question précédente, les trois fichiers suivants :
calendar.csv/ listings.csv/ reviews.csv
Vous les nommerez respectivement :
calendar, listings et reviews
3 - Sortez une description sommaire des tables : nombre de lignes, nom des colonnes, format des colonnes.
PARTIE II SQL 
1 - Imprimez la liste de tous les neighbourhood dont la première lettre est ‘a’ ou ‘e’, ainsi que le nombre de listings associés.
Ordonnez cette sortie par ordre décroissant du nombre de listings.Ne créez pas de table intermédiaire.
2 - Pour une même location, les clients ont-ils tous payé le même prix?
3 - Existe-t-il une différence entre le prix payé par les clients et le prix affiché du listing (pour les listings qui ont un prix renseigné)?
Enregistrez dans la librairie outputs la table de résultat que vous nommerez price_comparison. La table de résultat comprendra tous les champs de la table listing, 
la colonne prix de la table calendar renommée paid ainsi qu’une colonne diff_price construite comme la différence entre le prix affiché et le prix payé.
Notez que nous ne souhaitons pas le détail des prix payés, nous souhaitons simplement savoir s’il y a eu des différences et à combien s’élève cette différence.
4 - Pour chaque listing ayant reçu au moins 10 reviews, calculez le nombre de jours qu’il s’est écoulé entre la plus ancienne et la plus récente publication.
La table de sortie sera enregistrée dans la librairie outputs, elle s’appellera reviews_analysis et elle sera ordonnée par ordre décroissant du nombre de reviews. 
En plus du listing_id, la table devra comprendre la date minimum de publication (min_date), la date maximum de publication (max_date),
le nombre de jours qu’il s’est écoulé entre la première et la dernière publication (nb_days), ainsi que le nombre de reviews (nb_reviews).
Attention : le format des colonnes max_date et min_date devra être date9.
5 - Vérifiez que la colonne number_of_reviews de la table listings est effectivement égale au nombre de review que vous comptabilisez dans la table reviews.
Notez que number_of_reviews égal à 0 dans la table listings équivaut à aucune ligne dans la table review. 
Nous ne devrions donc pas avoir de ligne dans ma table en sortie pour ce cas de figure.
6 - Recherchons l’hôte ayant le plus de propriétés en location :
- Assurez-vous que chaque host_id est bien attribué à un seul host_name.
- Identifiez le nom de l’hôte possédant le plus de propriétés sur le marché, donnez l’host_id.
Attention, si vous utilisez le champ calculated_host_listings_count, il vous faudra démontrer que ce champ est correctement calculé.
7 - Durant quel mois de l’année le nombre de reviews est-il le plus élevé?
8 - Seulement pour les listings pour lesquels le neighbourhood_group est égal à West Seattle, créez une table de données que vous nommerez comments_lenght,
que vous enregistrerez dans la librairie temporaire, qui contiendra l’index du listing, le nom du listing, le commentaire, le nombre de caractères
utilisés dans le commentaire que vous nommerez comment_length, ainsi qu’une variable catégorielle, que vous nommerez comment_length_cat, qui renseignera sur la longueur des commentaires laissés par les clients comme suit :
‘moins de 100 caractères’
‘de 100 à 300 caractères’
‘de 300 à 500 caractères’
‘plus de 500 caractères’
Notez que la longueur de la chaîne de caractères ne sera calculée qu’une seule fois. Le tout devra être fait dans une seule requête.
PARTIE III SAS
Note – vous ne devez pas utiliser de proc SQL pour répondre aux questions qui suivent.
1 - Dans la table Listings, cherchez toutes les annonces contenant le mot ‘wonderful’ (la casse et la position dans la chaîne de caractères n’ont pas d’importance).
Vous enregistrerez la table de sortie dans la librairie outputs et vous nommerez la table table_wonderful.
2 - Créez une macro variable appelée neighbourhoods_of_interest qui contiendra une liste de nom de différents quartiers qui nous intéressent.
Attribuez à cette macro variable les valeurs Alki et Ravenna.
Imprimez cette variable (faire apparaître cette valeur dans la sortie du log).
3 -Création d’une fonction dans SAS :
Nom de la fonction stat_desc
Paramètres en entrée :
entry_data : la table en entrée de la fonction, elle contient au minimum les 2 colonnes sur lesquelles nous travaillerons : variable_of_interest (une variable continue) et split_variable (une variable catégorielle).
variable_of_interest : le nom d’une variable continue faisant partie de la table entry_data.
split_variable : le nom d'une variable discrète faisant partie de la table entry_data.
split_values : un sous-ensemble de valeurs faisant partie des valeurs que prend la colonne split_variable.
intermediate_plots : une variable booléenne qui indique si on veut les sorties graphiques intermédiaires ou pas (True/False). Valeur par défaut = False.
Pour chaque valeur du paramètre split_values, nous souhaitons obtenir les statistiques sommaires de la variable_of_interest.
Après avoir calculé la moyenne de la variable_of_interest pour une catégorie en particulier, nous créerons une variable catégorielle, nommez variable_of_interest_range, qui prendra les valeurs suivantes :
‘High range’ si variable_of_interest est supérieure ou égale à 1.1 fois la moyenne.
‘Low range’ si la variable_of_interest est inférieure ou égale à 0.9 fois la moyenne.
‘Average’ sinon.
Ensuite, si la variable intermediate_plots est égale à True, un histogramme de la distribution de la variable_of_interest sera tracé en fonction de la variable que nous venons de tracer variable_of_interest_range. Le titre de l’axe des abscisses sera changé pour ‘Categories’ et le titre de l’histogramme sera ‘Distribution in XXX’, XXX faisant référence à la valeur actuellement considérée de la split_values.
Les observations de la table entry_data pour lesquelles variable_of_interest_range = ‘Average’ seront sauvegardées dans une table nommée not_extreme dans laquelle les résultats pour chaque split_values seront consignés.
Finalement, à partir de la table not_extreme, vous ferez un histogramme de la variable_of_interest par split_variable.
Pour vous aider, voici à quoi la structure de votre fonction devrait ressembler :
Début de la fonction
*0 - Étape d’une table nommée table_average_f ayant la même structure que la table en entrée de la fonction entry_data
Data XXX;
set XXXX;
stop;
run;
Dans une boucle :
*1 - Étape data pour filtrer sur le sous-ensemble de données qui nous intéresse à cette étape de la fonction;
*2 - Étape pour obtenir la moyenne de la variable d’intérêt sur les observations filtrées à l’étape précédente;
*3 - Création de la variable qui contient la valeur moyenne;
*4 - Création de la variable variable_of_interest_range;
*5 - Test logique sur la variable intermediate_plots;
*6 - Création de l’histogramme (Utilisez la procédure PROC SGPLOT);
*7 - Stocker dans la table_average_f au fur et à mesure les observations pour lesquelles la variable variable_of_interest_range vaut « Average ».
Fin de la boucle.
*8 - À partir de la table finale (table_average_f), faire l’histogramme de la variable d’intérêt avec toutes les observations « average », tracez l’histogramme de la variable_of_interest.
Fin de la fonction.
4 - Testez votre fonction avec les paramètres suivants :
Data_entry=inputs.listings
Variable_of_interest=price
Split_variable=neighbourhood
Split_values= les valeurs de la macro variable neighbourhoods_of_interest, créée à la question 2.
intermediate_plots = True
